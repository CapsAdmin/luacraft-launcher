$URL_JAVA="https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-windows-amd64-image.zip"
$URL_FORGE="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.8.9-11.15.1.1722/forge-1.8.9-11.15.1.1722-mdk.zip"
$URL_LUACRAFT="https://github.com/luastoned/LuaCraft/archive/master.zip"
$URL_IDE="https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$URL_REPO="https://gitlab.com/CapsAdmin/luacraft-deployment/repository/archive.zip?ref=master"

$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$arg = $env:arg

function download($url, $dir, $move_files)
{
	if(Test-Path "$ROOT_DIR\$dir")
	{
		Write-Output "folder $dir already exists. skipping"
	}
	else
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
			mkdir $out_dir
		}
		
		foreach($item in $zip.items())
		{
			$shell.Namespace("$ROOT_DIR\$dir").copyhere($item)
		}
		
		Remove-Item $temp_file -ErrorAction SilentlyContinue -Confirm:$false
		
		if ($move_files)
		{
			Move-Item -Path "$out_dir\*\*" -Destination "$out_dir"
		}
	}
}

function build()
{
	download $URL_JAVA "jdk" 1
	download $URL_JAVA "minecraft"

	if(!(Test-Path "$ROOT_DIR\minecraft\src\build.gradle"))
	{
		Remove-Item minecraft\src\ -ErrorAction SilentlyContinue -Recurse:$true
	}

	download $URL_LUACRAFT "minecraft\src" 1

	cd minecraft

	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	.\gradlew setupDecompWorkspace --refresh-dependencies | Out-Null
	.\gradlew build | Out-Null
	
	mkdir run
	
	cd ..
}

if($arg -eq "build")
{
	build
}

if($arg -eq "ide")
{
	download $URL_IDE "ide" 1

	cd ide
	.\zbstudio.exe -cfg ../../shared/ide/config.lua
}

if($arg -eq "client" -Or $arg -eq "server")
{
	if(!(Test-Path "$ROOT_DIR\minecraft"))
	{
		build
	}
	
	if(!(Test-Path "$ROOT_DIR\minecraft\run\addons"))
	{
		cmd /c mklink /d /j "$ROOT_DIR\minecraft\run\addons" "$ROOT_DIR\..\shared\addons" 
	}
	
	if(!(Test-Path "$ROOT_DIR\minecraft\run\lua"))
	{
		cmd /c mklink /d /j "$ROOT_DIR\minecraft\run\lua" "$ROOT_DIR\..\shared\lua" 
	}
	
	$env:JAVA_HOME = "$ROOT_DIR\jdk"
	
	if($arg -eq "client")
	{
		$run="runClient"
	}
	elseif ($arg -eq "server")
	{
		$run="runServer"
	}
	
	cd minecraft
	
	.\gradlew $run -x sourceApiJava -x compileApiJava -x processApiResources -x apiClasses -x sourceMainJava -x compileJava -x processResources -x classes -x jar -x getVersionJson -x extractNatives -x extractUserdev -x getAssetIndex -x getAssets -x makeStart
}

if($arg -eq "update")
{
	download $URL_REPO "temp"
	Copy-Item -ErrorAction SilentlyContinue -Confirm:$false -force -recurse "$ROOT_DIR\temp\*\*" "$ROOT_DIR\..\"
	Remove-Item -ErrorAction SilentlyContinue -Confirm:$false -force -recurse "$ROOT_DIR\temp"
}

if($arg -eq "clean")
{
	Remove-Item -ErrorAction SilentlyContinue -Confirm:$false -recurse -force "$ROOT_DIR\ide"
	Remove-Item -ErrorAction SilentlyContinue -Confirm:$false -recurse -force "$ROOT_DIR\jdk"
	Remove-Item -ErrorAction SilentlyContinue -Confirm:$false -recurse -force "$ROOT_DIR\minecraft"
	Remove-Item -ErrorAction SilentlyContinue -Confirm:$false -recurse -force "$ROOT_DIR\temp.zip"
}
