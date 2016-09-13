$URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-windows-amd64-image.zip"
$URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
$URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
$URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$arg = $env:arg

function remove_folder($folder)
{
	if(Test-Path "$folder")
	{
		Get-ChildItem -Path "$folder\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $folder -Recurse -Force | Write-Host
	}
}

function download($url, $dir, $move_files)
{
	$temp_file = "$ROOT_DIR\temp.zip"
	$out_dir = "$ROOT_DIR\$dir"
	
	Write-Output "downloading $url to $temp_file"			
	(New-Object System.Net.WebClient).DownloadFile($url, $temp_file)		
	
	Write-Output "extracting $temp_file to $out_dir"
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($temp_file)
	
	if (!(Test-Path $out_dir)) 
	{		
		New-Item -ItemType directory -Path $out_dir
	}
	
	foreach($item in $zip.items())
	{
		$shell.Namespace("$ROOT_DIR\$dir").copyhere($item)
	}
	
	Remove-Item $temp_file -ErrorAction SilentlyContinue
	
	if ($move_files)
	{
		Move-Item -Path "$out_dir\*\*" -Destination "$out_dir"
	}
}

function build()
{
	#if minecraft/src/build.gradle does not exist 
	# just delete the whole folder and redownload
	if(!(Test-Path "$ROOT_DIR\minecraft\src\build.gradle")) {
		remove_folder "$ROOT_DIR\minecraft\src"
	}

	if(!(Test-Path "$ROOT_DIR\jdk\bin\java.exe")) {
		download $URL_JAVA "jdk" 1
	}
	
	if(!(Test-Path "$ROOT_DIR\minecraft\gradle.build")) {
		download $URL_FORGE "minecraft"	
		(Get-Content "$ROOT_DIR\minecraft\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "$ROOT_DIR\minecraft\build.gradle"
		remove_folder "$ROOT_DIR\minecraft\src" 
	}
	
	if(!(Test-Path "$ROOT_DIR\minecraft\src\gradle.build")) {
		download $URL_LUACRAFT "minecraft\src" 1
		(Get-Content "$ROOT_DIR\minecraft\src\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "$ROOT_DIR\minecraft\src\build.gradle"
	}
	
	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	
	Set-Location minecraft
		.\gradlew.bat setupDecompWorkspace --refresh-dependencies -Prun_dir="run" --refresh-dependencies --project-cache-dir .cache_shared --gradle-user-home .home_shared
		.\gradlew.bat build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	Set-Location ..
	
	New-Item -ItemType Directory -Force -Path "$ROOT_DIR\minecraft\run_client"
	New-Item -ItemType Directory -Force -Path "$ROOT_DIR\minecraft\run_server"
	
	#remove any previous home and cache folders
	remove_folder "$ROOT_DIR\minecraft\.cache_client"
	remove_folder "$ROOT_DIR\minecraft\.home_client"
	remove_folder "$ROOT_DIR\minecraft\.cache_server"
	remove_folder "$ROOT_DIR\minecraft\.home_server"
	
	#duplicate the home and cache folders to client and server to prevent crashing and file lock errors
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.cache_shared" "$ROOT_DIR\minecraft\.cache_client"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.cache_shared" "$ROOT_DIR\minecraft\.cache_server"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.home_shared" "$ROOT_DIR\minecraft\.home_server"
	Copy-Item -Force -Recurse "$ROOT_DIR\minecraft\.home_shared" "$ROOT_DIR\minecraft\.home_client"
		
	#some default properties
	"pauseOnLostFocus:false`n" | Out-File "$ROOT_DIR\minecraft\run_client\options.txt"
	"eula=true`n" | Out-File "$ROOT_DIR\minecraft\run_server\eula.txt"
	"online-mode=false`n" | Out-File "$ROOT_DIR\minecraft\run_server\server.properties"
}

function update_luacraft()
{
	download $URL_LUACRAFT "temp"
	Copy-Item -Force -Recurse "$ROOT_DIR\temp\*\*" "$ROOT_DIR\minecraft\src"
	remove_folder "$ROOT_DIR\temp"
	
	build
}

function link_folders($what)
{
	if(!(Test-Path "$ROOT_DIR\minecraft\run_$what\addons")) {
		cmd /c mklink /d /j "$ROOT_DIR\minecraft\run_$what\addons" "$ROOT_DIR\..\shared\addons" 
	}
	
	if(!(Test-Path "$ROOT_DIR\minecraft\run_$what\lua")) {
		cmd /c mklink /d /j "$ROOT_DIR\minecraft\run_$what\lua" "$ROOT_DIR\..\shared\lua" 
	}	
}

if($arg -eq "build")
{
	build
}

if($arg -eq "ide")
{
	if(!(Test-Path "$ROOT_DIR\ide\zbstudio.exe"))
	{
		download $URL_IDE "ide" 1
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
	
	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	
	if($arg -eq "client") {
		$run="runClient"
	}
	elseif ($arg -eq "server") {
		$run="runServer"
	}
	
	Set-Location minecraft
		.\gradlew $run -Prun_dir="run_$arg" --project-cache-dir .cache_$arg --gradle-user-home .home_$arg -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
	Set-Location ..
}

if($arg -eq "update") {
	remove_folder "$ROOT_DIR\..\shared\ide"
	remove_folder "$ROOT_DIR\..\shared\lua\examples"
	remove_folder "$ROOT_DIR\..\shared\lua\tutorial"
	remove_folder "$ROOT_DIR\..\shared\lua\autorun"

	download $URL_REPO "temp"
	Copy-Item -Force -Recurse "$ROOT_DIR\temp\*\*" "$ROOT_DIR\..\"
	remove_folder "$ROOT_DIR\temp"
	
	if(Test-Path "$ROOT_DIR\minecraft\src\build.gradle") {
		update_luacraft
	}
}

if($arg -eq "update_luacraft") {
	update_luacraft
}

if($arg -eq "clean") {
	remove_folder "$ROOT_DIR\ide"
	remove_folder "$ROOT_DIR\jdk"
	remove_folder "$ROOT_DIR\minecraft"
	Remove-Item -Recurse -Force "$ROOT_DIR\temp.zip"
}
