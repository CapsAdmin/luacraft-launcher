#/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -f "$ROOT_DIR/temp.zip"

download () 
{
   url=$1
   dir=$2
   move_files=$3
   
   if [ -d "$ROOT_DIR/$dir" ]; then
        echo "folder $dir already exists. skipping"
   else
        temp_file="$ROOT_DIR/temp.zip"
	out_dir="$ROOT_DIR/$dir"
	
	echo "downloading $url to $temp_file"
	wget "$url" -O "$temp_file"
	unzip "$temp_file" -d "$out_dir"
	
	if [ -n "$move_files" ]; then
            mv $out_dir/*/* $out_dir/
        fi
   fi
}

download "http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip" "minecraft"
download "https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-linux-amd64-image.zip" "jdk" 1

if ! [ -f "$ROOT_DIR/minecraft/src/build.gradle" ]; then
    rm -rf "$ROOT_DIR/minecraft/src"
fi

download "https://github.com/luastoned/LuaCraft/archive/master.zip" "minecraft/src" 1

cd minecraft

export JAVA_HOME="$ROOT_DIR/jdk"
bash gradlew setupDecompWorkspace --refresh-dependencies
bash gradlew build