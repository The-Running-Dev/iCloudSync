function Find-Duplicates {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $directory,
        [Parameter(Mandatory)][string] $duplicatesDirectory,
        [Parameter()][hashtable] $settings,
        [Parameter()][switch] $skipDuplicates = $false,
        [Parameter()][string] $excludeDirectories = '\.(Original)'
    )

    if ($skipDuplicates) {
        Write-Debug "Skipping Duplicates Check..."

        return
    }

    if ($PSCmdlet.ShouldProcess($duplicatesDirectory, "New-Item")) {
        New-Item -ItemType Directory $duplicatesDirectory -ErrorAction SilentlyContinue | Out-Null
    }

    $counter = 0
    $files = Get-ChildItem -File -Recurse -Path $directory | `
        Where-Object DirectoryName -NotMatch $excludeDirectories | `
        Where-Object { $settings.MediaFilter -imatch $_.Extension } | `
        Sort-Object CreationTime | `
        Group-Object -Property Length | `
        Where-Object { $_.Count -gt 1 } | `
        Select-Object -ExpandProperty Group | `
        Get-FileHash | `
        Group-Object -Property Hash | `
        Where-Object { $_.Count -gt 1 } | `
        ForEach-Object {
            $_.Group | Select-Object -Skip 1 -ExpandProperty Path
        }

    $totalCount = $files | Measure-Object | Select-Object -ExpandProperty Count

    if ($totalCount -eq 0) {
        Write-Debug "No Duplicate Media Found..."

        return
    }

    $files | ForEach-Object {
        $counter += 1
        $percentComplete = [int](($counter / $totalCount) * 100)

        Write-Progress -Activity "Moving Duplicates...." -Status "$counter/$totalCount, $percentComplete% Complete" -PercentComplete $percentComplete

        $item = Get-Item $_
        $s = $item.FullName
        $d = Join-Path $duplicatesDirectory $item.Name

        if ($PSCmdlet.ShouldProcess($item.Name, "Move-Item --> $d")) {
            Move-Item $s $d
        }
    }
}