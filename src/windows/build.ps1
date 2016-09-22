$URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-windows-amd64-image.zip"
$URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
$URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
$URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

$arg=$args[0]

function Error($title, $detail) {
	Write-Error $title
	Write-Error $detail
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[System.Windows.Forms.MessageBox]::Show($detail, $title)
	pause
	exit
}

function Is-Directory($path) {
	Test-Path "$path" -PathType Container
}

function Is-File($path) {
	Test-Path "$path" -PathType Leaf
}

function Copy($from, $to) {
	Copy-Item -Force -Recurse -Confirm:$false $from $to
}

function Create-Directory($location) {
	New-Item -ItemType Directory -Force -Path "$location" | Out-Null
	if (!(Is-Directory "$location")) {
		Error "create directory error" "tried to create directory '$location' but it doesn't exist"
	}
}

function Remove($path) {
	if(Is-Directory "$path") {
		Write-Host -NoNewline "removing directory: '$pwd\$path' ... "
		Get-ChildItem -Path "$path\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $path -Recurse -Force
		if(Is-Directory "$path") {
			Error "directory remove error", "tried to remove directory '$path' but the directory still exists"
		} else {
			Write-Host "OK"
		}
	} elseif(Is-File "$path") {
		Write-Host -NoNewline "removing file: '$pwd\$path' ... "
		Remove-Item -Force "$path"
		if(Is-File "$path") {
			Error "file remove error", "tried to remove file '$path' but the directory still exists"
		}		
		Write-Host "OK"
	}
}

function Move($from, $to) {
	Move-Item -Confirm:$false -Force -Path "$from" -Destination "$to"
}

function Download($url, $location) {
	if(!(Test-Path "$location")) {
		Write-Host -NoNewline "Download $url ... "
		Remove "$pwd\$location.tmp"
		(New-Object System.Net.WebClient).DownloadFile($url, "$pwd\$location.tmp")
		if(!(Test-Path "$location.tmp")) {
			Error "download error", "'$location.tmp' does not exist after attempting to download '$url'`ndetails may be in console"
		}
		Move "$location.tmp" "$location"
		Write-Host "OK"
	} else {
		Write-Host "'$pwd\$location' already exists. Skipping"
		Write-Host "OK"
	}
}

function Extract($file, $location, $move_files) {
	Write-Host -NoNewline "Extract $file ... "

	$shell = New-Object -Com Shell.Application
	
	$zip = $shell.NameSpace($([System.IO.Path]::GetFullPath("$pwd\$file")))
	
	if (!$zip) {
		Error "zip extract error" "could not extract $pwd\$file!"
	}
	
	if (!(Test-Path $location -PathType Container)) {
		Create-Directory $location
	}

	foreach($item in $zip.items()) {
		$shell.Namespace("$pwd\$location").CopyHere($item, 0x14)
	}
	
	if ($move_files)
	{
		Move "$location\*\*" "$location"
	}

	Write-Host "OK"
}

function fetch($url, $zip_name, $dir, $move_files) {
	Download $url $zip_name
	Remove $dir
	Extract $zip_name $dir $move_files
}

function setup_run_directory($what)
{
	if (!(Is-File "minecraft\.cache_$what")) {
		Create-Directory "minecraft\run_$what"
	}

	Remove "minecraft\run_$what\addons"
	cmd /c mklink /d /j "minecraft\run_$what\addons" "..\shared\addons" | Out-Null

	Remove "minecraft\run_$what\lua"
	cmd /c mklink /d /j "minecraft\run_$what\lua" "..\shared\lua" | Out-Null
	
	if (!(Is-Directory "minecraft\.home_$what") -And (Is-Directory "minecraft\.home_shared")) {
		Copy "minecraft\.home_shared" "minecraft\.home_$what"	
	}
	
	if (!(Is-Directory "minecraft\.cache_$what") -And (Is-Directory "minecraft\.cache_shared")) {
		Copy "minecraft\.cache_shared" "minecraft\.cache_$what"	
	}
}

function build()
{	
	#setup java
	if(!(Is-File "jdk\bin\java.exe")) {
		fetch $URL_JAVA "jdk.zip" "jdk" $true
		
		#this file takes up space and is not needed
		Remove "jdk\src.zip"
	}
	
	#setup minecraft forge
	if(!(Is-File "minecraft\build.gradle")) {
		fetch $URL_FORGE "forge.zip" "minecraft"
		
		if(!(Is-File "minecraft\build.gradle")) {
			Error "download/extract error" "unable to find minecraft\build.gradle."
		}
		
		#modify build.gradle so we can pass a custom runDir argument
		(Get-Content "minecraft\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "minecraft\build.gradle"
		
		#this folder is not needed and will be replaced by luacraft
		Remove "minecraft\src"
	}

	if(!(Is-File "minecraft\src\build.gradle")) {
		fetch $URL_LUACRAFT "luacraft.zip" "minecraft\src" $true
		
		if(!(Is-File "minecraft\src\build.gradle")) {
			Error "download/extract error" "unable to find minecraft\src\build.gradle."
		}
		
		#modify build.gradle so we can pass a custom runDir argument
		(Get-Content "minecraft\src\build.gradle") -replace 'runDir = "[a-z_]+"', 'runDir = run_dir' | Set-Content "minecraft\src\build.gradle"
	}
	
	Write-Output "building luacraft..."

	$env:JAVA_HOME = "$pwd\jdk"
	Set-Location minecraft
		.\gradlew.bat setupDecompWorkspace --refresh-dependencies -Prun_dir="run" --refresh-dependencies --project-cache-dir .cache_shared --gradle-user-home .home_shared
		.\gradlew.bat build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	Set-Location ..
	
	if (!(Is-File "minecraft\build\libs\modid-1.0.jar")) {
		Error "build error!" "unable to find build output minecraft\build\libs\modid-1.0.jar"
	} else {
		Write-Output "build successful"
	}
	
	Remove "minecraft\.cache_client"
	Remove "minecraft\.cache_server"
	Remove "minecraft\.home_server"
	Remove "minecraft\.home_client"
	
	setup_run_directory "client"
	setup_run_directory "server"
	
	#setup client directories
	Add-Content "minecraft\run_client\options.txt" "pauseOnLostFocus:false"
			
	#setup server directories
	Add-Content "minecraft\run_server\server.properties" "online-mode=false`nlevel-type=CUSTOMIZED`ngenerator-settings=3;minecraft:bedrock,59*minecraft:stone,3*minecraft:dirt,minecraft:grass;1;village,mineshaft,stronghold,biome_1,dungeon,decoration,lake,lava_lake`n"
	
	Write-Output "finished building luacraft"
}

function update_luacraft()
{
	Remove "luacraft.zip"

	fetch $URL_LUACRAFT "temp.zip" "temp"
	Remove "temp.zip"

	Copy "temp\*\*" "minecraft\src"
	Remove "temp"

	build
}

if($arg -eq "build") {
	build
}

if($arg -eq "ide") {
	if(!(Is-File "ide\zbstudio.exe"))	{
		fetch $URL_IDE "ide.zip" "ide" $true
	}
	
	if (!(Is-File "minecraft\build\libs\modid-1.0.jar")) {
		build
	}

	Set-Location ide
		.\zbstudio.exe -cfg ../../shared/ide/config.lua
	Set-Location ..
}

if($arg -eq "client" -Or $arg -eq "server") {
	if (!(Is-File "minecraft\build\libs\modid-1.0.jar" -PathType Leaf)) {
		build
	}

	setup_run_directory "client"
	exit
	setup_run_directory "server"
	

	if($arg -eq "client") {
		$run="runClient"
	} elseif ($arg -eq "server") {
		$run="runServer"
		Add-Content "minecraft\run_server\eula.txt" "eula=true"
	}

	$env:JAVA_HOME = "$pwd\jdk"
	Set-Location minecraft
		.\gradlew $run -Prun_dir="run_$arg" --project-cache-dir .cache_$arg --gradle-user-home .home_$arg -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
	Set-Location ..
}

if($arg -eq "update") {
	Remove "..\shared\ide"
	Remove "..\shared\lua\examples"
	Remove "..\shared\lua\tutorial"
	Remove "..\shared\lua\autorun"

	fetch $URL_REPO temp "temp"
	Remove "temp.zip"

	Copy "temp\*\*" "..\"
	Remove "temp"

	if(Is-File "minecraft\src\build.gradle") {
		update_luacraft
	}
}

if($arg -eq "update_luacraft") {
	update_luacraft
}

if($arg -eq "clean") {
	Remove "ide"
	Remove "jdk"
	Remove "minecraft"
	Remove "temp.zip"
}
