#/bin/bash

URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-linux-amd64-image.zip"
URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

download () 
{
	url=$1
	dir=$2
	move_files=$3
   
	rm -f "$ROOT_DIR/temp.zip"
	temp_file="$ROOT_DIR/temp.zip"
	out_dir="$ROOT_DIR/$dir"
	
	echo "downloading $url to temp.zip"
	wget "$url" -O temp.zip
	unzip temp.zip -d "$out_dir"
	
	if [ -n "$move_files" ]; then
		mv -f $out_dir/*/* $out_dir/
	fi
	
	rm -f "$ROOT_DIR/temp.zip"
}

build ()
{
	#if minecraft/src/build.gradle does not exist 
	# just delete the whole folder and redownload
	if ! [ -f "$ROOT_DIR/minecraft/build.gradle" ]; then
		rm -rf "$ROOT_DIR/minecraft"
	fi
	
	if ! [ -f "$ROOT_DIR/jdk/bin/java" ]; then
		download $URL_JAVA "jdk" 1
	fi
	
	if ! [ -f "$ROOT_DIR/minecraft/build.gradle" ]; then
		download $URL_FORGE "minecraft"
		sed -i "/runDir = / s/=.*/= run_dir/" $ROOT_DIR/minecraft/build.gradle
		rm -rf $ROOT_DIR/minecraft/src
	fi
	
	if ! [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
		download $URL_LUACRAFT "minecraft/src" 1
		sed -i "/runDir = / s/=.*/= run_dir/" $ROOT_DIR/minecraft/src/build.gradle
	fi	

	export JAVA_HOME="$ROOT_DIR/jdk"
	
	cd minecraft
		bash gradlew setupDecompWorkspace --refresh-dependencies -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
		bash gradlew build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	cd ..
	
	mkdir -p $ROOT_DIR/minecraft/run_client
	mkdir -p $ROOT_DIR/minecraft/run_server
	
	#remove any previous home and cache folders
	rm -rf $ROOT_DIR/minecraft/.cache_client
	rm -rf $ROOT_DIR/minecraft/.home_client
	rm -rf $ROOT_DIR/minecraft/.cache_server
	rm -rf $ROOT_DIR/minecraft/.home_server
	
	#duplicate the home and cache folders to client and server to prevent crashing and file lock errors
	cp -r -f $ROOT_DIR/minecraft/.cache_shared $ROOT_DIR/minecraft/.cache_client
	cp -r -f $ROOT_DIR/minecraft/.cache_shared $ROOT_DIR/minecraft/.cache_server
	cp -r -f $ROOT_DIR/minecraft/.home_shared $ROOT_DIR/minecraft/.home_server
	cp -r -f $ROOT_DIR/minecraft/.home_shared $ROOT_DIR/minecraft/.home_client
	
	#some default properties
	echo -e "pauseOnLostFocus:false\n" > $ROOT_DIR/minecraft/run_client/options.txt
	echo -e "online-mode=false\n" > $ROOT_DIR/minecraft/run_server/server.properties
}

update_luacraft()
{
	download $URL_LUACRAFT "temp"
	cp -r -f $ROOT_DIR/temp/*/* $ROOT_DIR/minecraft/src
	rm -r -f $ROOT_DIR/temp/
	build
}

link_folders()
{	
	if ! [ -e "$ROOT_DIR/minecraft/run_$1/addons" ]; then
		ln -s -d $ROOT_DIR/../shared/addons/ minecraft/run_$1/addons
	fi

	if ! [ -e "$ROOT_DIR/minecraft/run_$1/lua" ]; then
		ln -s -d $ROOT_DIR/../shared/lua/ minecraft/run_$1/lua
	fi
}

if [ "$1" == "build" ] || [ "$1" == "" ]; then
	build
fi

if [ "$1" == "ide" ]; then
	if ! [ -f "$ROOT_DIR/ide/zbstudio.sh" ]; then
		download $URL_IDE "ide" 1
	fi

	cd ide/
	./zbstudio.sh -cfg ../../shared/ide/config.lua
fi

if [ "$1" == "client" ] || [ "$1" == "server" ]; then
	if ! [ -d "$ROOT_DIR/minecraft" ]; then
		build
	fi

	link_folders client
	link_folders server
	
	export JAVA_HOME="$ROOT_DIR/jdk"
	
	if [ "$1" == "client" ]; then
		run=runClient
	elif [ "$1" == "server" ]; then
		run=runServer
		echo -e "eula=true\n" > $ROOT_DIR/minecraft/run_server/eula.txt
	fi
	
	cd minecraft
		bash gradlew $run -Prun_dir="run_$1" --project-cache-dir .cache_$1 --gradle-user-home .home_$1 -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
	cd ..
fi

if [ "$1" == "update" ]; then
	rm -r -f $ROOT_DIR/../shared/ide
	rm -r -f $ROOT_DIR/../shared/lua/examples
	rm -r -f $ROOT_DIR/../shared/lua/tutorial
	rm -r -f $ROOT_DIR/../shared/lua/autorun
	
	download $URL_REPO "temp"
	cp -r -f $ROOT_DIR/temp/*/* $ROOT_DIR/../
	rm -r -f $ROOT_DIR/temp/
	
	if [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
		update_luacraft
	fi
fi

if [ "$1" == "update_luacraft" ]; then
	update_luacraft
fi

if [ "$1" == "clean" ]; then
	rm -r -f $ROOT_DIR/ide
	rm -r -f $ROOT_DIR/jdk
	rm -r -f $ROOT_DIR/minecraft
	rm -f $ROOT_DIR/temp.zip
fi
