#/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d "$ROOT_DIR/minecraft" ]; then
    bash build.bash
fi

cd minecraft
export JAVA_HOME="$ROOT_DIR/jdk"
bash gradlew runServer