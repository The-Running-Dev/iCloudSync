function Get-Media {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string] $directory,
        [Parameter()][hashtable] $settings,
        [Parameter()][string] $excludeDirectories = '\.(Original)'
    )

    Write-Debug $directory

    $filesToProcess = @()
    $files = Get-ChildItem -Recurse $directory | `
        Where-Object {
            $_.DirectoryName -NotMatch $excludeDirectories `
            -and $settings.MediaFilter -imatch $_.Extension
        }

    $totalCount = $files | Measure-Object | Select-Object -ExpandProperty Count

    $files | Sort-Object FullName | `
        ForEach-Object {
        $counter += 1
        $percentComplete = [int](($counter / $totalCount) * 100)
        $fullName = $_.FullName

        $depth = ($fullName.Replace($directory, '').ToCharArray() | Where-Object { $_ -eq '\' } | Measure-Object).Count
        $tabs = "".PadLeft($depth, "`t")

        if ($DebugPreference) {
            Write-Debug "$tabs$fullName"
        }

        Write-Progress -Activity "Finding Media...." -Status "$counter/$totalCount, $percentComplete% Complete" -PercentComplete $percentComplete

        if ($settings.ImageFilter -imatch $_.Extension) {
            $filesToProcess += Get-ImageData -FilePath $fullName -Settings $settings
        }
        elseif ($settings.VideoFilter -imatch $_.Extension) {
            $filesToProcess += Get-VideoData -FilePath $fullName -Settings $settings
        }
    }

    return $filesToProcess
}