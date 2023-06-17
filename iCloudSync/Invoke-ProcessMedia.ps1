function Invoke-ProcessMedia {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string] $directory,
        [Parameter(Mandatory, ValueFromPipeline)][string] $destinationDir,
        [Parameter(ValueFromPipeline)][string] $videosDestinationDir,
        [Parameter(ValueFromPipeline)][string] $backupDir,
        [Parameter(ValueFromPipeline)][string] $duplicatesDir,
        [Parameter()][hashtable] $settings,
        [Parameter()][switch] $skipBackup = $false,
        [Parameter()][switch] $skipProcessing = $false,
        [Parameter()][switch] $skipRename = $false,
        [Parameter()][switch] $skipDuplicates = $false,
        [Parameter()][switch] $skipOrganize = $false
    )

    if ($skipProcessing) {
        Write-Debug "Skipping Processing..."

        return
    }

    Rename-Media `
        -Directory $directory `
        -BackupDirectory $backupDir `
        -Settings $settings `
        -SkipBackup:$skipBackup `
        -SkipRename:$skipRename `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference

    Find-Duplicates `
        -Directory $directory `
        -DuplicatesDirectory $duplicatesDir `
        -Settings $settings `
        -SkipDuplicates:$skipDuplicates `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference

    Move-Media `
        -Directory $directory `
        -DestinationDir $destinationDir `
        -VideosDestinationDir $videosDestinationDir `
        -Settings $settings `
        -SkipOrganize:$skipOrganize `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference
}