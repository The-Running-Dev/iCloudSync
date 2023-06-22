function Get-MediaData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()][string] $filePath,
        [Parameter()][hashtable] $settings
    )

    $createdOnAsString = & $settings.ExifToolExePath $filePath -T -createdate
    $file = Get-Item $filePath
    [datetime]$createdOn = $file.CreationTime

    if (-not ([DateTime]::TryParseExact($createdOnAsString, 'yyyy:MM:dd HH:mm:ss', $null, 'None', [ref]$createdOn))) {
        $createdOn = $file.CreationTime
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