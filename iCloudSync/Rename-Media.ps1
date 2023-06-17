function Rename-Media {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $directory,
        [Parameter(Mandatory)][string] $backupDirectory,
        [Parameter()][hashtable] $settings,
        [Parameter()][switch] $skipRename = $false,
        [Parameter()][switch] $skipBackup = $false
    )

    if ($skipRename) {
        Write-Debug "Skipping Rename & Rotate..."

        return
    }

    if (-not $skipBackup) {
        New-Item -ItemType Directory $backupDirectory -ErrorAction SilentlyContinue | Out-Null
    }

    $files = @()
    $files = Get-Media -Directory $directory -Settings $settings
    $totalCount = $files | Measure-Object | Select-Object -ExpandProperty Count

    if ($totalCount -eq 0) {
        Write-Debug "No Media Found to Rename..."

        return
    }

    $files | ForEach-Object {
        $counter += 1
        $percentComplete = [int](($counter / $totalCount) * 100)
        $sourcePath = $_.Path
        $extension = $_.Extension
        $destinationPath = $_.DestinationPath;

        Write-Progress -Activity "Renaming & Rotating...." -Status "$counter/$totalCount, $percentComplete% Complete" -PercentComplete $percentComplete

        if (-not $skipBackup) {
            if ($PSCmdlet.ShouldProcess($sourcePath, "Copy-Item --> $backupDirectory")) {
                Copy-Item $sourcePath $backupDirectory
            }
        }

        if ($extension -imatch '\.jpg|\.jpeg') {
            & $settings.JheadExePath -autorot $sourcePath | Out-Null
        }

        if ($sourcePath -cne $destinationPath) {
            if ($DebugPreference) {
                Write-Output "$sourcePath --> $destinationPath"
            }

            if (-not (Test-Path $destinationPath)) {
                if ($PSCmdlet.ShouldProcess($sourcePath, "Move-Item --> $destinationPath")) {
                    Move-Item $sourcePath $destinationPath | Out-Null
                }
            }
            else {
                Write-Error $destinationPath
            }
        }
    }
}