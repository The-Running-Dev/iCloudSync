# iCloudSync

A set of PowerShell scripts to download and organize iCloud media. The scripts use the awesome iCloud downloader from <https://github.com/icloud-photos-downloader/icloud_photos_downloader> to
do the actual download. And the organization happens in a specific way, please read below.

Here is what the ```iCloudSync.ps1``` does:

1. Gets the settings from ```iCloudSync.ini``` file. If the file does not exist,
   it creates it in the ```$env:AppData\iCloudSync``` directory.

2. If the ```-install``` switch is specified, it installs the ```iCloudSync.ps1``` script to
   run as a scheduled task. The settings for the scheduled task are in the ```iCloudSync.ini``` file.

3. If the ```-editSettings``` switch is specified, it opens the ```iCloudSync.ini``` file to be
   edited in the system default text editor. If you want to run the scripts as a scheduled task, do this first to view/modify the default settings.

4. Syncs all media to the specified directory, based on settings in ```iCloudSync.ini``` file.

5. Processes all media downloaded in the media directory:
   1. Makes a backup of the touched media to the ```backupDir``` (if ```skipBackup``` is not set)
   2. Renames the media with the pattern ```yyyy.MM.dd.HH.mm.ss``` (controlled by the ```MediaFileNameFormatString``` setting in ```iCloudSync.ini```)
   3. Finds any duplicates and moves them to the ```duplicatesDir``` (if ```skipDuplicates``` is not set)
   4. Moves all media to the ```destinationDir``` (if ```skipOrganize``` is not set) into the folder structure ```Year/Month/File.ext```. If ```videosDestinationDir``` is specified, then moves all videos (filtered by VideoFilter in ```iCloudSync.ini```) to that directory instead.

## How to Use

There are two scripts you can use directly in PowerShell:

Sync with the default options:

```powershell
./iCloudSync.ps1
```

### Sync Arguments

Name | Type | Default | Description
---|---|---|---
directory | string | Z:\\@iCloud\\.Organize | The directory where the media will be downloaded
destinationDir | string | Z:\\@iCloud | The directory where the media will be moved when organized
videosDestinationDir | string | Z:\\@iCloud\Videos | The directory where the videos will be moved when organized
backupDir | string | Z:\\@iCloud\\.Organize\\.Original | The directory where backups will be moved
duplicatesDir | string | Z:\\@iCloud\\.Organize\\.Duplicates | The directory where the duplicate media will be moved
skipDownload | switch | false | Should the download step be skipped
skipProcessing | switch | false | Should the download step be skipped
skipBackup | switch | false | Should the backup step be skipped
skipRename | switch | false | Should the rename step be skipped
skipDuplicates | switch | false | Should the duplicates check step be skipped
skipOrganize | switch | false | Should the media organization step be skipped
install | switch | false | Installs the script as a scheduled task
editSettings | switch | false | Opens the ```iCloudSync.ini``` file to be edited

Organize only:

```powershell
./Organize-Media.ps1
```

### Organize Arguments

Name | Type | Default | Description
---|---|---|---
directory | string | Z:\\@iCloud\\.Organize | The directory where the media will be downloaded
destinationDir | string | Z:\\@iCloud | The directory where the media will be moved when organized
videosDestinationDir | string | Z:\\@iCloud\Videos | The directory where the videos will be moved when organized
backupDir | string | Z:\\@iCloud\\.Organize\\.Original | The directory where backups will be moved
duplicatesDir | string | Z:\\@iCloud\\.Organize\\.Duplicates | The directory where the duplicate media will be moved
skipProcessing | switch | false | Should the download step be skipped
skipBackup | switch | false | Should the backup step be skipped
skipRename | switch | false | Should the rename step be skipped
skipDuplicates | switch | false | Should the duplicates check step be skipped
skipOrganize | switch | false | Should the media organization step be skipped

## Settings

These are the settings in the ```iCloudSync.ini``` that you can modify. Self explanatory for the most part.

Name | Value
---|---
SettingsPath | $(Join-Path $env:AppData 'iCloudSync\iCloudSync.ini')
ImageFilter | \\.(jpg\|jpeg\|png)
VideoFilter | \\.(mov\|3gp\|mp4)
MediaFilter | \\.(jpg\|jpeg\|png\|mov\|3gp\|mp4)
MediaFileNameFormatString | yyyy.MM.dd.HH.mm.ss
ScheduledTaskName | iCloudSync
RunEveryXHours | 12
PowerShellExePath | C:\\Program Files\\PowerShell\\7\\pwsh.exe
PowerShellArguments | -ExecutionPolicy Bypass "$(Join-Path (Split-Path $PSScriptRoot -Parent) iCloudSync.ps1)"
DownloaderExePath | $(Join-Path $PSScriptRoot 'tools\\icloudpd-1.13.4-windows-amd64.exe')
DownloaderArguments | --skip-live-photos --folder-structure none --delete-after-download --no-progress-bar --recent 100
JheadExePath | $(Join-Path $PSScriptRoot 'tools\\jhead.exe')
ExifToolExePath | $(Join-Path $PSScriptRoot 'tools\\exiftool.exe')
CredentialsPath | $(Join-Path $env:AppData 'iCloudSync\\Credentails.xml')