if not exist minecraft build.cmd
cd minecraft
set JAVA_HOME=%~dp0jdk
gradlew runServer -x deobfCompileDummyTask -x deobfProvidedDummyTask -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart