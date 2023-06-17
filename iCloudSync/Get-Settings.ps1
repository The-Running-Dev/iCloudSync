function Get-Settings {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $settingsDir = Join-Path $env:AppData 'iCloudSync'

    New-Item -ItemType Directory $settingsDir -Force | Out-Null

    $defaultSettingsFilePath = Join-Path $PSScriptRoot 'DefaultSettings.ini'
    $userSettingsFilePath = Join-Path $settingsDir 'iCloudSync.ini'

    if (-not (Test-Path $userSettingsFilePath)) {
        Copy-Item $defaultSettingsFilePath $userSettingsFilePath | Out-Null
    }

    $defaultSection = 'Settings'
    $settings = Read-IniFile `
        -File $userSettingsFilePath `
        -DefaultSection $defaultSection `
        -WhatIf:$WhatIfPreference `
        -Debug:$DebugPreference

    $s = @{}
    $settings.$defaultSection.Keys | ForEach-Object {
        $variable = $_
        $value = $ExecutionContext.InvokeCommand.ExpandString($settings.$defaultSection[$_])
        $s.$variable = $value
    }

    ([System.Collections.SortedList] $s)
}