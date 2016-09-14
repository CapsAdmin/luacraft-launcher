#/bin/bash

URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-linux-amd64-image.zip"
URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

fetch ()
{
	url=$1
	zip_name=$2
	dir=$3
	move_files=$4

	if ! [ -f "$ROOT_DIR/$zip_name.zip" ]; then
		echo "downloading $url to $zip_name.zip"
		wget "$url" -O "$ROOT_DIR/$zip_name.zip"
	fi

	rm -rf "$dir"
	unzip "$ROOT_DIR/$zip_name.zip" -d "$dir"

	if [ -n "$move_files" ]; then
		mv -f $dir/*/* "$dir/"
	fi
}

build ()
{
	echo "building luacraft..."

	#if minecraft/src/build.gradle does not exist
	# just delete the whole folder and redownload
	if ! [ -f "$ROOT_DIR/minecraft/build.gradle" ]; then
		rm -rf "$ROOT_DIR/minecraft"
	fi

	if ! [ -f "$ROOT_DIR/jdk/bin/java" ]; then
		fetch $URL_JAVA jdk "$ROOT_DIR/jdk" 1
		rm -f "$ROOT_DIR/jdk/src.zip" #not needed
	else
		echo "jdk is already downloaded"
	fi

	if ! [ -f "$ROOT_DIR/minecraft/build.gradle" ]; then
		fetch $URL_FORGE forge "$ROOT_DIR/minecraft"
		sed -i "/runDir = / s/=.*/= run_dir/" "$ROOT_DIR/minecraft/build.gradle"
		rm -rf "$ROOT_DIR/minecraft/src"
	else
		echo "forge is already downloaded"
	fi

	if ! [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
		fetch $URL_LUACRAFT luacraft "$ROOT_DIR/minecraft/src" 1
		sed -i "/runDir = / s/=.*/= run_dir/" "$ROOT_DIR/minecraft/src/build.gradle"
	else
		echo "luacraft is already downloaded"
	fi

	(
		export JAVA_HOME="$ROOT_DIR/jdk"
		cd minecraft || exit
		bash gradlew setupDecompWorkspace --refresh-dependencies -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
		bash gradlew build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	)
	mkdir -p "$ROOT_DIR/minecraft/run_client"
	mkdir -p "$ROOT_DIR/minecraft/run_server"

	#remove any previous home and cache folders
	rm -rf "$ROOT_DIR/minecraft/.cache_client"
	rm -rf "$ROOT_DIR/minecraft/.home_client"
	rm -rf "$ROOT_DIR/minecraft/.cache_server"
	rm -rf "$ROOT_DIR/minecraft/.home_server"

	#duplicate the home and cache folders to client and server to prevent crashing and file lock errors
	cp -rf "$ROOT_DIR/minecraft/.cache_shared" "$ROOT_DIR/minecraft/.cache_client"
	cp -rf "$ROOT_DIR/minecraft/.cache_shared" "$ROOT_DIR/minecraft/.cache_server"
	cp -rf "$ROOT_DIR/minecraft/.home_shared" "$ROOT_DIR/minecraft/.home_server"
	cp -rf "$ROOT_DIR/minecraft/.home_shared" "$ROOT_DIR/minecraft/.home_client"

	world_seed="3;minecraft:bedrock,59*minecraft:stone,3*minecraft:dirt,minecraft:grass;1;village,mineshaft,stronghold,biome_1,dungeon,decoration,lake,lava_lake"

	#some default properties
	echo -e "pauseOnLostFocus:false\n" > "$ROOT_DIR/minecraft/run_client/options.txt"
	echo -e "online-mode=false\nlevel-type=CUSTOMIZED\ngenerator-settings=$world_seed\n" > "$ROOT_DIR/minecraft/run_server/server.properties"

	echo "finished building luacraft"
}

update_luacraft()
{
	rm -f "$ROOT_DIR/luacraft.zip"

	fetch $URL_LUACRAFT luacraft "$ROOT_DIR/temp"
	rm -f "$ROOT_DIR/temp.zip"

	cp -rf "$ROOT_DIR/temp/*/*" "$ROOT_DIR/minecraft/src"
	rm -rf "$ROOT_DIR/temp/"

	build
}

link_folders()
{
	rm -f "$ROOT_DIR/minecraft/run_$1/addons"
	ln -s -d "$ROOT_DIR/../shared/addons/" "$ROOT_DIR/minecraft/run_$1/addons"

	rm -f "$ROOT_DIR/minecraft/run_$1/lua"
	ln -s -d "$ROOT_DIR/../shared/lua/" "$ROOT_DIR/minecraft/run_$1/lua"
}

if [ "$1" == "build" ] || [ "$1" == "" ]; then
	build
fi

if [ "$1" == "ide" ]; then
	if ! [ -f "$ROOT_DIR/ide/zbstudio.sh" ]; then
		fetch $URL_IDE ide "$ROOT_DIR/ide" 1
	fi

	(
		cd ide/ || exit
		./zbstudio.sh -cfg ../../shared/ide/config.lua
	)
fi

if [ "$1" == "client" ] || [ "$1" == "server" ]; then
	if ! [ -d "$ROOT_DIR/minecraft" ]; then
		build
	fi

	link_folders client
	link_folders server

	if [ "$1" == "client" ]; then
		run=runClient
	elif [ "$1" == "server" ]; then
		run=runServer
		echo -e "eula=true\n" > "$ROOT_DIR/minecraft/run_server/eula.txt"
	fi

	(
		export JAVA_HOME="$ROOT_DIR/jdk"
		cd minecraft || exit
		bash gradlew $run -Prun_dir='run_$1' --project-cache-dir .cache_$1 --gradle-user-home .home_$1 -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
	)
fi

if [ "$1" == "update" ]; then
	rm -rf "$ROOT_DIR/../shared/ide"
	rm -rf "$ROOT_DIR/../shared/lua/examples"
	rm -rf "$ROOT_DIR/../shared/lua/tutorial"
	rm -rf "$ROOT_DIR/../shared/lua/autorun"

	fetch $URL_REPO temp "$ROOT_DIR/temp"
	rm -f "$ROOT_DIR/temp.zip"

	cp -rf "$ROOT_DIR/temp/*/*" "$ROOT_DIR/../"
	rm -rf "$ROOT_DIR/temp/"

	if [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
		update_luacraft
	fi
fi

if [ "$1" == "update_luacraft" ]; then
	update_luacraft
fi

if [ "$1" == "clean" ]; then
	rm -rf "$ROOT_DIR/ide"
	rm -rf "$ROOT_DIR/jdk"
	rm -rf "$ROOT_DIR/minecraft"
	rm -f "$ROOT_DIR/temp.zip"
fi
