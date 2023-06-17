function Get-ImageData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string] $filePath,
        [Parameter()][hashtable] $settings
    )
    $dateTimeCreatedPropertyId = 36867
    $image = [System.Drawing.Image]::FromFile($filePath)

    $dateTimeAsBytes = $image.PropertyItems | `
        Where-Object id -EQ $dateTimeCreatedPropertyId | `
        Select-Object -ExpandProperty Value

    if ($dateTimeAsBytes) {
        $dateTimeFromExif = [System.Text.Encoding]::ASCII.GetString($dateTimeAsBytes) -replace "`0$"
        $createdOn = [DateTime]::ParseExact($dateTimeFromExif, "yyyy:MM:dd HH:mm:ss", $null)
    }
    else {
        $createdOn = (Get-Item $_.FullName).LastWriteTime
    }

    $partialSeconds = Get-Date -f 'ffff'
    $destinationName = "$($createdOn.ToString($settings.MediaFileNameFormatString)).$partialSeconds$($_.Extension.toLower())"

    $image.Dispose()

    return @{
        Path            = $_.FullName;
        Name            = $_.Name;
        Extension       = $_.Extension;
        CreatedOn       = $createdOn;
        DestinationPath = Join-Path $_.DirectoryName $destinationName;
    }
}