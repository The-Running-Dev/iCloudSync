function Move-Media {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $directory,
        [Parameter(Mandatory)][string] $destinationDir,
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

        $counter += 1
        $percentComplete = [int](($counter / $totalCount) * 100)
        $subDirectory = Join-Path $destinationDir ($_.Name -replace '-', '\')

        Write-Progress -Activity "Organizing Files by Year/Month...." -Status "$counter/$totalCount, $percentComplete% Complete" -PercentComplete $percentComplete

        if (-not (Test-Path $subDirectory)) {
            if ($PSCmdlet.ShouldProcess($subDirectory, "New-Item")) {
                New-Item -ItemType Directory $subDirectory | Out-Null
            }
        }

        $_.Group | ForEach-Object {
            $s = $_.Path
            $d = Join-Path $subDirectory $_.Name

            if ($PSCmdlet.ShouldProcess($s, "Move-Item --> $d")) {
                Move-Item $s $d
            }
        }
    }
}