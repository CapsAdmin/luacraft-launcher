if not exist %~dp0minecraft build.cmd
if not exist %~dp0minecraft/run/addons mklink "%~dp0../shared/addons/" "%~dp0minecraft/run/addons"
if not exist %~dp0minecraft/run/lua mklink "%~dp0../shared/lua/" "%~dp0minecraft/run/lua"

cd minecraft
set JAVA_HOME=%~dp0jdk
gradlew runClient -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
