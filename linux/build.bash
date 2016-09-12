#/bin/bash

URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-linux-amd64-image.zip"
URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
URL_LUACRAFT="https://github.com/luastoned/LuaCraft/archive/master.zip"
URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

download () 
{
	url=$1
	dir=$2
	move_files=$3
   
	if [ -d "$ROOT_DIR/$dir" ]; then
		echo "folder $dir already exists. skipping"
	else
		rm -f "$ROOT_DIR/temp.zip"
		temp_file="$ROOT_DIR/temp.zip"
		out_dir="$ROOT_DIR/$dir"
		
		echo "downloading $url to temp.zip"
		wget "$url" -O temp.zip
		unzip temp.zip -d "$out_dir"
		
		if [ -n "$move_files" ]; then
			mv $out_dir/*/* $out_dir/
		fi
		
		rm -f "$ROOT_DIR/temp.zip"
	fi
}

build ()
{
	download $URL_FORGE "minecraft"
	download $URL_JAVA "jdk" 1

	if ! [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
		rm -rf "$ROOT_DIR/minecraft/src"
	fi

	download $URL_LUACRAFT "minecraft/src" 1

	cd minecraft

	export JAVA_HOME="$ROOT_DIR/jdk"
	bash gradlew setupDecompWorkspace --refresh-dependencies
	bash gradlew build
	
	mkdir -p $ROOT_DIR/minecraft/run
	cp -f $ROOT_DIR/../shared/options.txt $ROOT_DIR/minecraft/run/options.txt
	
	cd ..
}

if [ "$1" == "build" ] || [ "$1" == "" ]; then
	build
fi

if [ "$1" == "ide" ]; then
	download $URL_IDE "ide" 1

	cd ide/
	./zbstudio.sh -cfg ../../shared/ide/config.lua
fi

if [ "$1" == "client" ] || [ "$1" == "server" ]; then
	if ! [ -d "$ROOT_DIR/minecraft" ]; then
		build
	fi

	if ! [ -e "$ROOT_DIR/minecraft/run/addons" ]; then
		ln -s -d $ROOT_DIR/../shared/addons/ minecraft/run/addons
	fi

	if ! [ -e "$ROOT_DIR/minecraft/run/lua" ]; then
		ln -s -d $ROOT_DIR/../shared/lua/ minecraft/run/lua
	fi
	
	if [ "$1" == "client" ]; then
		run=runClient
	elif [ "$1" == "server" ]; then
		run=runServer
	fi
	
	cd minecraft	
	export JAVA_HOME="$ROOT_DIR/jdk"
	bash gradlew $run -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
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
fi

if [ "$1" == "clean" ]; then
	rm -r -f $ROOT_DIR/ide
	rm -r -f $ROOT_DIR/jdk
	rm -r -f $ROOT_DIR/minecraft
	rm -f $ROOT_DIR/temp.zip
fi
