﻿<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,
	
	[switch]
	$SkipPublish,
	
	[switch]
	$AutoVersion
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory)
{
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS)
	{
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

# Prepare publish folder
Write-Host "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
Copy-Item -Path "$($WorkingDirectory)\shiftavenue.GraphAutomation" -Destination $publishDir.FullName -Recurse -Force

New-ExternalHelp -Path (Join-Path $WorkingDirectory -ChildPath help) -OutputPath (Join-Path $publishDir.FullName shiftavenue.GraphAutomation) -Force

#region Gather text data to compile
$text = @()

# Gather commands
Get-ChildItem -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\internal\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
Get-ChildItem -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}

# Gather scripts
Get-ChildItem -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\internal\scripts\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}

#region Update the psm1 file & Cleanup
[System.IO.File]::WriteAllText("$($publishDir.FullName)\shiftavenue.GraphAutomation\shiftavenue.GraphAutomation.psm1", ($text -join "`n`n"), [System.Text.Encoding]::UTF8)
Remove-Item -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\internal" -Recurse -Force
Remove-Item -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\functions" -Recurse -Force
#endregion Update the psm1 file & Cleanup

#region Updating the Module Version
if ($AutoVersion)
{
	Write-Host  "Updating module version numbers."
	try { [version]$remoteVersion = (Find-Module 'shiftavenue.GraphAutomation' -Repository $Repository -ErrorAction Stop).Version }
	catch
	{
		throw "Failed to access $($Repository) : $_"
	}
	if (-not $remoteVersion)
	{
		throw "Couldn't find shiftavenue.GraphAutomation on repository $($Repository) : $_"
	}
	$newBuildNumber = $remoteVersion.Build + 1
	[version]$localVersion = (Import-PowerShellDataFile -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\shiftavenue.GraphAutomation.psd1").ModuleVersion
	Update-ModuleManifest -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation\shiftavenue.GraphAutomation.psd1" -ModuleVersion "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
}
#endregion Updating the Module Version

#region Publish
if ($SkipPublish) { return }
if ($LocalRepo)
{
	# Dependencies must go first
	Write-Host  "Creating Nuget Package for module: PSFramework"
	New-PSMDModuleNugetPackage -ModulePath (Get-Module -Name PSFramework).ModuleBase -PackagePath .
	Write-Host  "Creating Nuget Package for module: shiftavenue.GraphAutomation"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\shiftavenue.GraphAutomation" -PackagePath .
}
else
{
	# Publish to Gallery
	Write-Host  "Publishing the shiftavenue.GraphAutomation module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\shiftavenue.GraphAutomation" -NuGetApiKey $ApiKey -Force -Repository $Repository
}
#endregion Publish