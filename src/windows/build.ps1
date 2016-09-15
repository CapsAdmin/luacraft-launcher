$URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-windows-amd64-image.zip"
$URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
$URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
$URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$arg = $env:arg

function Remove-Folder($folder)
{
	if(Test-Path "$folder")
	{
		Get-ChildItem -Path "$folder\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $folder -Recurse -Force | Write-Host
	}
}

function fetch($url, $zip_name, $dir, $move_files)
{
	$file = "$ROOT_DIR\$zip_name.zip"

	Write-Output $file

	if(!(Test-Path "$file")) {
		Write-Output "downloading $url to $file"
		(New-Object System.Net.WebClient).DownloadFile($url, $file)
	}

	Remove-Folder $dir

	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)

	if (!(Test-Path $dir))
	{
		New-Item -ItemType directory -Path $dir
	}

	foreach($item in $zip.items())
	{
		$shell.Namespace($dir).CopyHere($item, 0x14)
	}

	if ($move_files)
	{
		Move-Item -Confirm:$false -Force -Path "$dir\*\*" -Destination "$dir"
	}
}

function build()
{
	Write-Output "building luacraft..."

	#if minecraft/src/build.gradle does not exist
	# just delete the whole folder and redownload
	if(!(Test-Path "$ROOT_DIR\minecraft\src\build.gradle")) {
		Remove-Folder "$ROOT_DIR\minecraft\src"
	}

	if(!(Test-Path "$ROOT_DIR\jdk\bin\java.exe")) {
		fetch $URL_JAVA jdk "$ROOT_DIR\jdk" 1
		Remove-Item "$ROOT_DIR\jdk\src.zip" -ErrorAction SilentlyContinue
	} else {
		echo "java is already downloaded"
	}

	if(!(Test-Path "$ROOT_DIR\minecraft\build.gradle")) {
		fetch $URL_FORGE forge "$ROOT_DIR\minecraft"
		(Get-Content "$ROOT_DIR\minecraft\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "$ROOT_DIR\minecraft\build.gradle"
		Remove-Folder "$ROOT_DIR\minecraft\src"
	} else {
		echo "forge is already downloaded"
	}

	if(!(Test-Path "$ROOT_DIR\minecraft\src\build.gradle")) {
		fetch $URL_LUACRAFT luacraft "$ROOT_DIR\minecraft\src" 1
		(Get-Content "$ROOT_DIR\minecraft\src\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "$ROOT_DIR\minecraft\src\build.gradle"
	} else {
		echo "luacraft is already downloaded"
	}

	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	Set-Location minecraft
		.\gradlew.bat setupDecompWorkspace --refresh-dependencies -Prun_dir="run" --refresh-dependencies --project-cache-dir .cache_shared --gradle-user-home .home_shared
		.\gradlew.bat build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	Set-Location ..

	New-Item -ItemType Directory -Force -Path "$ROOT_DIR\minecraft\run_client"
	New-Item -ItemType Directory -Force -Path "$ROOT_DIR\minecraft\run_server"

	#remove any previous home and cache folders
	Remove-Folder "$ROOT_DIR\minecraft\.cache_client"
	Remove-Folder "$ROOT_DIR\minecraft\.home_client"
	Remove-Folder "$ROOT_DIR\minecraft\.cache_server"
	Remove-Folder "$ROOT_DIR\minecraft\.home_server"

	#duplicate the home and cache folders to client and server to prevent crashing and file lock errors
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.cache_shared" "$ROOT_DIR\minecraft\.cache_client"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.cache_shared" "$ROOT_DIR\minecraft\.cache_server"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.home_shared" "$ROOT_DIR\minecraft\.home_server"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.home_shared" "$ROOT_DIR\minecraft\.home_client"

	#some default properties
	Add-Content "$ROOT_DIR\minecraft\run_client\options.txt" "pauseOnLostFocus:false"
	Add-Content "$ROOT_DIR\minecraft\run_server\server.properties" "online-mode=false`nlevel-type=CUSTOMIZED`ngenerator-settings=3;minecraft:bedrock,59*minecraft:stone,3*minecraft:dirt,minecraft:grass;1;village,mineshaft,stronghold,biome_1,dungeon,decoration,lake,lava_lake`n"

	Write-Output "finished building luacraft"
}

function update_luacraft()
{
	Remove-Item "$ROOT_DIR\luacraft.zip" -ErrorAction SilentlyContinue

	fetch $URL_LUACRAFT temp "$ROOT_DIR\temp"
	Remove-Item "$ROOT_DIR\temp.zip" -ErrorAction SilentlyContinue

	Copy-Item -Force -Recurse -Confirm:$false "$ROOT_DIR\temp\*\*" "$ROOT_DIR\minecraft\src"
	Remove-Folder "$ROOT_DIR\temp"

	build
}

function link_folders($what)
{
	cmd /c rmdir "$ROOT_DIR\minecraft\run_$what\addons"
	cmd /c mklink /d /j "$ROOT_DIR\minecraft\run_$what\addons" "$ROOT_DIR\..\shared\addons"

	cmd /c rmdir "$ROOT_DIR\minecraft\run_$what\lua"
	cmd /c mklink /d /j "$ROOT_DIR\minecraft\run_$what\lua" "$ROOT_DIR\..\shared\lua"
}

if($arg -eq "build") {
	build
}

if($arg -eq "ide") {
	if(!(Test-Path "$ROOT_DIR\ide\zbstudio.exe"))
	{
		fetch $URL_IDE ide "$ROOT_DIR\ide" 1
	}

	Set-Location ide
	.\zbstudio.exe -cfg ../../shared/ide/config.lua
	Set-Location ..
}

if($arg -eq "client" -Or $arg -eq "server") {
	if(!(Test-Path "$ROOT_DIR\minecraft")) {
		build
	}

	link_folders "client"
	link_folders "server"

	if($arg -eq "client") {
		$run="runClient"
	} elseif ($arg -eq "server") {
		$run="runServer"
		Add-Content "$ROOT_DIR\minecraft\run_server\eula.txt" "eula=true"
	}

	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	Set-Location minecraft
		.\gradlew $run -Prun_dir="run_$arg" --project-cache-dir .cache_$arg --gradle-user-home .home_$arg -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
	Set-Location ..
}

if($arg -eq "update") {
	Remove-Folder "$ROOT_DIR\..\shared\ide"
	Remove-Folder "$ROOT_DIR\..\shared\lua\examples"
	Remove-Folder "$ROOT_DIR\..\shared\lua\tutorial"
	Remove-Folder "$ROOT_DIR\..\shared\lua\autorun"

	fetch $URL_REPO temp "$ROOT_DIR\temp"
	Remove-Item -Recurse -Force "$ROOT_DIR\temp.zip"

	Copy-Item -Force -Recurse -Confirm:$false "$ROOT_DIR\temp\*\*" "$ROOT_DIR\..\"
	Remove-Folder "$ROOT_DIR\temp"

	if(Test-Path "$ROOT_DIR\minecraft\src\build.gradle") {
		update_luacraft
	}
}

if($arg -eq "update_luacraft") {
	update_luacraft
}

if($arg -eq "clean") {
	Remove-Folder "$ROOT_DIR\ide"
	Remove-Folder "$ROOT_DIR\jdk"
	Remove-Folder "$ROOT_DIR\minecraft"
	Remove-Item -Recurse -Force "$ROOT_DIR\temp.zip"
}
