function Get-VideoData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string] $filePath,
        [Parameter()][hashtable] $settings
    )

    $file = Get-Item $filePath
    $creationDate = & $settings.ExifToolExePath $filePath -createdate | `
        Select-String '\d+.*' | `
        Select-Object -ExpandProperty Matches -First 1 | `
        Select-Object -ExpandProperty Value

    if (-not $creationDate) {
        $createdOn = [DateTime]::ParseExact($creationDate, "yyyy MM dd HH:mm:ss", $null)
    }
    else {
        $createdOn = $file.LastWriteTime
    }

    $partialSeconds = Get-Date -f 'ffff'
    $destinationName = "$($createdOn.ToString($settings.MediaFileNameFormatString)).$partialSeconds$($file.Extension.toLower())"

    return @{
        Path            = $file.FullName;
        Name            = $file.Name;
        Extension       = $file.Extension;
        CreatedOn       = $createdOn;
        DestinationPath = Join-Path $file.DirectoryName $destinationName;
    }
}