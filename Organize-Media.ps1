[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ValueFromPipeline)] $directory = 'Z:\@iCloud\.Organize',
    [Parameter(ValueFromPipeline)] $destinationDir = 'Z:\@iCloud',
    [Parameter(ValueFromPipeline)] $backupDir = 'Z:\@iCloud\.Organize\.Original',
    [Parameter(ValueFromPipeline)] $duplicatesDir = 'Z:\@iCloud\.Organize\.Duplicates',
	[Parameter()][switch] $skipProcessing = $false,
	[Parameter()][switch] $skipBackup = $false,
	[Parameter()][switch] $skipRename = $false,
	[Parameter()][switch] $skipDuplicates = $false,
	[Parameter()][switch] $skipOrganize = $false
)

Import-Module (Join-Path $PSScriptRoot 'iCloudSync.psm1') -Force

$settings = Read-Settings `
    -File (Join-Path $PSScriptRoot 'iCloudSync.ini') `
    -WhatIf:$WhatIfPreference `
    -Debug:$DebugPreference

Write-Debug $settings

Invoke-ProcessMedia `
	-Directory $directory `
	-DestinationDir $destinationDir `
	-BackupDir $backupDir `
	-DuplicatesDir $duplicatesDir `
	-Settings $settings `
	-SkipProcessing:$skipProcessing `
	-SkipBackup:$skipBackup `
	-SkipRename:$skipRename `
	-SkipDuplicates:$skipDuplicates `
	-SkipOrganize:$skipOrganize `
	-WhatIf:$WhatIfPreference `
	-Debug:$DebugPreference