[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(ValueFromPipeline)] $directory = 'Z:\@iCloud\.Organize',
    [Parameter(ValueFromPipeline)] $destinationDir = 'Z:\@iCloud',
	[Parameter(ValueFromPipeline)] $videosDestinationDir = 'Z:\@iCloud\Videos',
	[Parameter(ValueFromPipeline)] $backupDir = 'Z:\@iCloud\.Organize\.Original',
	[Parameter(ValueFromPipeline)] $duplicatesDir = 'Z:\@iCloud\.Organize\.Duplicates',
	[Parameter()][switch] $skipDownload = $false,
	[Parameter()][switch] $skipProcessing = $false,
	[Parameter()][switch] $skipBackup = $false,
	[Parameter()][switch] $skipRename = $false,
	[Parameter()][switch] $skipDuplicates = $false,
	[Parameter()][switch] $skipOrganize = $false,
	[Parameter()][switch] $install = $false,
	[Parameter()][switch] $editSettings = $false
)

Import-Module (Join-Path $PSScriptRoot 'iCloudSync.psm1') -Force

$settings = Get-Settings `
    -WhatIf:$WhatIfPreference `
    -Debug:$DebugPreference

Write-Debug ($settings | Out-String)


if ($install) {
	Install-iCloudSync -Settings $settings

	return
}

if ($editSettings) {
	& $settings.SettingsPath

	return
}

Sync-Media `
	-Directory $directory `
	-SkipDownload:$skipDownload `
	-Settings $settings `
	-WhatIf:$WhatIfPreference `
	-Debug:$DebugPreference

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