Function Read-IniFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $filePath,
        [Parameter()][string] $defaultSection = 'Settings'
    )

    Write-Debug "Reading Settings form $filePath..."
    
    $ini = @{}

    # Create a default section if none exist in the file. Like a java prop file.
    $section = $defaultSection
    $ini[$section] = @{}

    switch -regex -file $filePath {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{}
        }
        "^\s*([^#].+?)\s*=\s*(.*)?" {
            $name, $value = $matches[1..2]

            # skip comments that start with semicolon:
            if (-not ($name.StartsWith(";")) -and $value) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }

    $ini
}