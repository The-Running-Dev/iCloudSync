function Move-Media {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $directory,
        [Parameter(Mandatory)][string] $destinationDir,
        [Parameter(ValueFromPipeline)][string] $videosDestinationDir,
        [Parameter()][hashtable] $settings,
        [Parameter()][switch] $skipOrganize = $false
    )

    if ($skipOrganize) {
        Write-Debug "Skipping Image Organize..."

        return
    }

    $counter = 0
    $files = Get-Media -Directory $directory -Settings $settings
    $totalCount = $files | Measure-Object | Select-Object -ExpandProperty Count

    if ($totalCount -eq 0) {
        Write-Debug "No Media Found to Move..."

        return
    }

    $files | Group-Object { $_.CreatedOn.ToString("yyyy-MM") } | `
        Sort-Object Name | ForEach-Object {

        $yearAndMonth = $_.Name
        $counter += 1
        $percentComplete = [int](($counter / $totalCount) * 100)

        Write-Progress -Activity "Organizing Files by Year/Month...." -Status "$counter/$totalCount, $percentComplete% Complete" -PercentComplete $percentComplete

        $_.Group | ForEach-Object {
            $sourcePath = $_.Path
            $fileName = $_.Name

            if ($settings.ImageFilter -imatch $_.Extension) {
                $subDirectory = Join-Path $destinationDir ($yearAndMonth -replace '-', '\')
            }
            elseif ($settings.VideoFilter -imatch $_.Extension) {
                $subDirectory = Join-Path $videosDestinationDir ($yearAndMonth -replace '-', '\')
            }

            if (-not (Test-Path $subDirectory)) {
                if ($PSCmdlet.ShouldProcess($subDirectory, "New-Item")) {
                    New-Item -ItemType Directory $subDirectory | Out-Null
                }
            }

            $destination = Join-Path $subDirectory $fileName

            if ($PSCmdlet.ShouldProcess($sourcePath, "Move-Item --> $destination")) {
                Move-Item $source $destination
            }
        }
    }
}