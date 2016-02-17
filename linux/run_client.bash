#/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [ -d "$ROOT_DIR/minecraft" ]; then
    bash build.bash
fi

cd minecraft
export JAVA_HOME="$ROOT_DIR/jdk"
bash gradlew runClient -x deobfCompileDummyTask -x deobfProvidedDummyTask -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart