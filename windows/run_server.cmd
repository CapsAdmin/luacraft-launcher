if not exist minecraft build.cmd
cd minecraft
set JAVA_HOME=%~dp0jdk
gradlew runServer