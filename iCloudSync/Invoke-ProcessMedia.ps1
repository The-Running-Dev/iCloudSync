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

    Write-Debug "Organizing All Media..."
    New-Item -ItemType Directory $destinationDir -ErrorAction SilentlyContinue | Out-Null

    & $settings.ExifToolExePath `
        -o $destinationDir `
        -d "%Y.%m.%H.%M.%S.%%le" `
        '-filename<filemodifydate' `
        '-filename<createdate' `
        '-filename<datetimeoriginal' `
        -ext jpg -ext jpeg -ext png -ext mp4 -ext mov -ext webm -ext 3gp `
        $directory
    <#
    -q `
    Rename-Media `
        -Directory $directory `
        -BackupDirectory $backupDir `
        -Settings $settings `
        -SkipBackup:$skipBackup `
        -SkipRename:$skipRename `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference
    #>

    Write-Debug "Rotating All Pictures..."
    & $settings.JheadExePath -autorot "$destinationDir\*.jpg"

    Find-Duplicates `
        -Directory $directory `
        -DuplicatesDirectory $duplicatesDir `
        -Settings $settings `
        -SkipDuplicates:$skipDuplicates `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference

    <#
    Write-Debug "Organizing All Pictures..."
    & $settings.ExifToolExePath `
        -o . `
        -d "$destinationDir/%Y/%m/%Y.%m.%H.%M.%S.%%le" `
        '-filename<filemodifydate' `
        '-filename<createdate' `
        '-filename<datetimeoriginal' `
        -ext jpg -ext jpeg -ext png `
        $directory | Set-Content (Join-Path $directory '.organize-pictures.log')

    Write-Debug "Organizing All Videos..."
    & $settings.ExifToolExePath `
        -o . `
        -d "$videosDestinationDir/%Y/%m/%Y.%m.%H.%M.%S.%%le" `
        '-filename<filemodifydate' `
        '-filename<createdate' `
        '-filename<datetimeoriginal' `
        -ext mp4 -ext mov -ext webm -ext 3gp `
        $directory | Set-Content (Join-Path $directory '.organize-videos.log')
    Move-Media `
        -Directory $directory `
        -DestinationDir $destinationDir `
        -VideosDestinationDir $videosDestinationDir `
        -Settings $settings `
        -SkipOrganize:$skipOrganize `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference
    #>
}