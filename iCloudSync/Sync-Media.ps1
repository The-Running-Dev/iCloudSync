function Sync-Media {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)] $directory,
        [Parameter()][hashtable] $settings,
        [Parameter()][switch] $skipDownload = $false
    )

    if ($skipDownload) {
        Write-Debug "Skipping Download..."

        return
    }

    if (-not (Test-Path $settings.CredentialsPath)) {
        Get-Credential -Title "Enter Your iCloud Credentials" -Message " " | Export-Clixml -Path $settings.CredentialsPath
    }

    try {
        $credentials = Import-Clixml -Path $settings.CredentialsPath -ErrorAction SilentlyContinue
    }
    catch {
        $credentials = Get-Credential -Title "Enter Your iCloud Credentials" -Message " "
        $credentials | Export-Clixml -Path $settings.CredentialsPath
    }

    $iCloudUser = $credentials.UserName
    $iCloudPassword = $credentials.Password | ConvertFrom-SecureString -AsPlainText

    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory $directory | Out-Null
    }

    $arguments = @()
    $arguments += "--directory $directory"
    $arguments += "--username $iCloudUser"
    $arguments += "--password $iCloudPassword"
    $arguments += $ExecutionContext.InvokeCommand.ExpandString($settings.DownloaderArguments)

    Write-Debug ($arguments -Join ' ')

    & $settings.DownloaderExePath ($arguments -Join ' ').Split(' ')
}