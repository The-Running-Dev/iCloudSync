function Get-UniqueFilename {
    param(
        [Parameter()][string] $path,
        [Parameter()][string] $uniquePath,
        [Parameter()][string] $counter = 0
    )

    if (Test-Path $uniquePath) {
        $counter += 1
        $item = Get-Item $path
        $uniquePath = "$($item.DirectoryName)\$($item.BaseName)-$counter$($item.Extension)";

        return Get-UniqueFilename $path $uniquePath $counter
    }

    return $uniquePath
}