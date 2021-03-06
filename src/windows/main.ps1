$URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-windows-amd64-image.zip"
$URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
$URL_LUACRAFT="https://github.com/CapsAdmin/LuaCraft/archive/master.zip"
$URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$URL_REPO="https://github.com/CapsAdmin/luacraft-launcher/archive/master.zip"

$arg=$args[0]

function Error($title, $detail) {
	Write-Error $title
	Write-Error $detail
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($detail, $title)
	pause
	exit
}

function Is-Directory($path) {
	Test-Path -Path "$path" -PathType Container
}

function Is-File($path) {
	Test-Path -Path "$path" -PathType Leaf
}

function Copy-Item2($from, $to) {
	Write-Host -NoNewline "Copy $from to $to ... "
	Copy-Item -Path "$from" -Destination "$to" -Force -Recurse -Confirm:$false 
	Write-Output "OK"
}

function Create-Directory($location) {
	Write-Host -NoNewline "Create directory $location ... "
	New-Item -Path "$location" -ItemType Directory -Force | Out-Null
	if (!(Is-Directory "$location")) {
		Error "create directory error" "tried to create directory '$location' but it doesn't exist"
	}
	Write-Output "OK"
}

function Remove-Link($path) {
	if (Is-Directory $path) {
		$res = cmd /c rmdir "$path" 2>&1
		if ($lastExitCode -ne 0) {
			Error "remove junction error" "$res $path"
		}
	}
}

function Create-Link($from, $to) {
	$res = cmd /c mklink /d /j `"$from`" `"$to`" 2>&1
	if ($lastExitCode -ne 0) {
        Error "create junction error" "$res"
	}
}

function Remove($path) {
	if(Is-Directory "$path") {
		Write-Host -NoNewline "Remove directory: '$pwd\$path' ... "
		Get-ChildItem -Path "$path\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item -Path "$path" -Recurse -Force
		if(Is-Directory "$path") {
			Error "directory remove error", "tried to remove directory '$path' but the directory still exists"
		} else {
			Write-Host "OK"
		}
	} elseif(Is-File "$path") {
		Write-Host -NoNewline "Remove file: '$pwd\$path' ... "
		Remove-Item -Path "$path" -Force
		if(Is-File "$path") {
			Error "file remove error", "tried to remove file '$path' but the directory still exists"
		}		
		Write-Host "OK"
	}
}

function Move($from, $to) {
	Move-Item -Path "$from" -Destination "$to" -Confirm:$false -Force
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
		Write-Host -NoNewline "skipping '$pwd\$location' as it already exists. "
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
	
	if (!(Is-File $location)) {
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

function Kill-Processes-With-Title($title) {
	$info = (tasklist /v /fo csv | Select-String $title)
	
	if ($info) {
		$parent_pid = (gwmi win32_process -Filter "processid='$pid'").parentprocessid
		foreach ($line in ($info -Split '`n')) {
			$arr = ($line.Replace('"', '') -Split ',')
			if ($arr[1] -Ne $parent_pid) {
				Write-Output "killing existing process with $title"
				cmd /c taskkill /F /T /PID $arr[1]
			}
		}		
	}
}

function Gradle($what, $which) {
	$env:JAVA_HOME = "$pwd\jdk"
	Set-Location minecraft

	$skip_args = @(
		"-x sourceApiJava", 
		"-x compileApiJava",
		"-x processApiResources",
		"-x apiClasses",
		"-x sourceMainJava",
		"-x compileJava",
		"-x processResources",
		"-x classes",
		"-x jar",
		"-x getVersionJson",
		"-x extractNatives",
		"-x extractUserdev",
		"-x getAssetIndex",
		"-x getAssets",
		"-x makeStart"
	);
	
	$dir_args = '-Prun_dir="run_' + $which + '" --project-cache-dir .cache_' + $which + ' --gradle-user-home .home_' + $which
		
	if($what -Eq "setup") {
		$arg_line = "setupDecompWorkspace --refresh-dependencies" + " " + $dir_args
	} elseif($what -Eq "build") {
		$arg_line = "build " + $dir_args
	} elseif($what -Eq "run") {
		if($which -Eq "client") {
			$run_arg = "runClient"
		} elseif ($which -Eq "server") {
			$run_arg = "runServer"
		}
	
		$arg_line = "build" + " " + $run_arg + " " + $dir_args + " " + $skip_args
	}
	
	$arg_line = " -i " + $arg_line
	
	Start-Process -FilePath "$pwd\gradlew.bat" -ArgumentList $arg_line -Wait -NoNewWindow 
	Set-Location ..
	
	# --refresh-dependencies -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared
	#.\gradlew.bat build -Prun_dir="run" --project-cache-dir .cache_shared --gradle-user-home .home_shared			
	#.\gradlew -i $run -Prun_dir=run_$arg --project-cache-dir .cache_$arg --gradle-user-home .home_$arg -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
}

function fetch($url, $zip_name, $dir, $move_files) {
	Download $url $zip_name
	Remove $dir
	Extract $zip_name $dir $move_files
}

function setup_run_directory($what)
{
	if (!(Is-Directory "minecraft\run_$what")) {
		Create-Directory "minecraft\run_$what"
	}
	
	Remove-Link "minecraft\run_$what\addons"
	Create-Link "minecraft\run_$what\addons" "..\shared\addons"
	
	Remove-Link "minecraft\run_$what\lua"
	Create-Link "minecraft\run_$what\lua" "..\shared\lua"
	
	if (!(Is-Directory "minecraft\.home_$what") -And (Is-Directory "minecraft\.home_shared")) {
		Copy-Item2 "minecraft\.home_shared" "minecraft\.home_$what"
	}
	
	if (!(Is-Directory "minecraft\.cache_$what") -And (Is-Directory "minecraft\.cache_shared")) {
		Copy-Item2 "minecraft\.cache_shared" "minecraft\.cache_$what"
	}
}

function build($skip_setup_decomp)
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

	if (!$skip_setup_decomp) {
		Gradle setup shared
	}
	Gradle build shared

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
	
	Write-Output "finished building luacraft"
}

function launch_ide() {
	if(!(Is-File "ide\zbstudio.exe"))	{
		fetch $URL_IDE "ide.zip" "ide" $true
	}
	
	Set-Location ide
		.\zbstudio.exe -cfg ../../shared/ide/config.lua
	Set-Location ..
}

if($arg -eq "build") {
	build
}

if($arg -eq "ide") {
	launch_ide
}

if($arg -eq "run") {
	if (!(Is-File "minecraft\.cache_shared\2.7\taskArtifacts\fileSnapshots.bin")) {
		build
	}
	
	launch_ide
}

if($arg -eq "client" -Or $arg -eq "server") {
	if (!(Is-File "minecraft\build\libs\modid-1.0.jar")) {
		Error "project is not built" "please run run_luacraft.cmd or src\windows\build.cmd"
	}
	
	setup_run_directory "$arg"

	if($arg -Eq "client") {
		$run = "runClient"
		if(!(Is-File "minecraft\run_client\options.txt")) {
			Add-Content "minecraft\run_client\options.txt" "pauseOnLostFocus:false"
		}
	} elseif ($arg -Eq "server") {
		$run = "runServer"
		Add-Content "minecraft\run_server\eula.txt" "eula=true"
		if(!(Is-File "minecraft\run_server\server.properties")) {
			Add-Content "minecraft\run_server\server.properties" "online-mode=false`ngamemode=1`nlevel-type=CUSTOMIZED`ngenerator-settings=3;minecraft:bedrock,59*minecraft:stone,3*minecraft:dirt,minecraft:grass;1;village,mineshaft,stronghold,biome_1,dungeon,decoration,lake,lava_lake`n"
		}
	}
		
	Kill-Processes-With-Title "luacraft_$arg"
	
	Gradle run $arg
}

if($arg -eq "update-scripts") {
	Remove "..\shared\ide"
	Remove "..\shared\lua\examples"
	Remove "..\shared\lua\tutorial"
	Remove "..\shared\lua\autorun"

	fetch $URL_REPO "temp.zip" "temp"
	Copy-Item2 "temp\*\*" "..\..\"
	
	Remove "temp.zip"
	Remove "temp"
}

if($arg -eq "update-luacraft") {
	Remove "luacraft.zip"
	Remove "minecraft\src"
	build $true
}

if($arg -eq "update-ide") {
	Remove "ide.zip"
	Remove "ide"
	launch_ide
}

if($arg -eq "reset") {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	$OUTPUT = [System.Windows.Forms.MessageBox]::Show("Everything will be deleted and you will have to run build.cmd again." , "confirm" , 4)
	if ($OUTPUT -eq "YES" ){
		Remove-Link "minecraft\run_client\lua"
		Remove-Link "minecraft\run_client\addons"
		Remove-Link "minecraft\run_server\lua"
		Remove-Link "minecraft\run_server\addons"
	
		Remove "ide"
		Remove "jdk"
		Remove "minecraft"
		
		Remove "ide.zip"
		Remove "jdk.zip"
		Remove "forge.zip"
		Remove "luacraft.zip"
	}
}

if($arg -eq "clean") {	
	Remove "ide.zip"
	Remove "jdk.zip"
	Remove "forge.zip"
	Remove "luacraft.zip"
	
	Remove "minecraft\.cache_client"
	Remove "minecraft\.cache_server"
	Remove "minecraft\.home_client"
	Remove "minecraft\.home_server"
	
	Remove-Link "minecraft\run_client\lua"
	Remove-Link "minecraft\run_client\lua"
	Remove-Link "minecraft\run_client\addons"
	Remove-Link "minecraft\run_server\lua"
	Remove-Link "minecraft\run_server\addons"
	
	Remove "minecraft\run_client"
	Remove "minecraft\run_server"
	Remove "minecraft\build\taskLogs"
	
	Remove "minecraft\.cache_shared\gradle.log"
	Remove "minecraft\.cache_shared\caches\2.7\scripts"
	Remove "minecraft\.home_shared\caches\2.7\scripts"
	
	Remove "minecraft\.cache_shared\2.7\taskArtifacts\fileSnapshots.bin"
	Remove "minecraft\.cache_shared\2.7\taskArtifacts\taskArtifacts.bin"
	
	Remove "minecraft\.home_shared\caches\modules-2\metadata-2.15\artifact-at-repository.bin"
	Remove "minecraft\.home_shared\caches\modules-2\metadata-2.15\artifact-at-url.bin"
	
	Remove "minecraft\.home_shared\caches\minecraft\net\minecraftforge\forge\1.8.9-11.15.1.1722\start\GradleStart.class"
	Remove "minecraft\.home_shared\caches\minecraft\net\minecraftforge\forge\1.8.9-11.15.1.1722\start\GradleStart.java"
	Remove "minecraft\.home_shared\caches\minecraft\net\minecraftforge\forge\1.8.9-11.15.1.1722\start\net\minecraftforge\gradle\GradleStartCommon.class"
	Remove "minecraft\.home_shared\caches\minecraft\net\minecraftforge\forge\1.8.9-11.15.1.1722\start\net\minecraftforge\gradle\GradleStartCommon.java"
	
	Remove "ide\bin\linux"
	Remove "ide\bin\lua.app"
	Remove "ide\bin\clibs52"
	Remove "ide\bin\clibs53"
	
	Remove "ide\api\cg"
	Remove "ide\api\glsl"
	Remove "ide\api\hlsl"
	Remove "ide\api\opencl"
	
	Remove "ide\api\lua\corona.lua"
	Remove "ide\api\lua\gideros.lua"
	Remove "ide\api\lua\glewgl.lua"
	Remove "ide\api\lua\glfw.lua"
	Remove "ide\api\lua\glfw3.lua"
	Remove "ide\api\lua\love2d.lua"
	Remove "ide\api\lua\luajit2.lua"
	Remove "ide\api\lua\marmalade.lua"
	Remove "ide\api\lua\moai.lua"
	Remove "ide\api\lua\wxwidgets.lua"
	
	Remove-Item "ide\bin\lua52*" -Recurse -Force
	Remove-Item "ide\bin\lua53*" -Recurse -Force
	Remove-Item "ide\bin\*.dylib" -Recurse -Force
	Remove-Item "ide\bin\clibs\*.dylib" -Recurse -Force
	Remove-Item "ide\bin\clibs\git\*.dylib" -Recurse -Force
	Remove-Item "ide\bin\clibs\mime\*.dylib" -Recurse -Force
	Remove-Item "ide\bin\clibs\socket\*.dylib" -Recurse -Force
	
	Write-Output "clean successful"
}