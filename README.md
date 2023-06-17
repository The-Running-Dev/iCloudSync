# iCloudSync

A set of PowerShell scripts to download and organize iCloud media. The scripts use the awesome iCloud downloader from <https://github.com/icloud-photos-downloader/icloud_photos_downloader> to
do the actual download. And the organization happens in a specific way, please read below.

## Table of Contents

- [iCloudSync](#icloudsync)
  - [Table of Contents](#table-of-contents)
  - [How it Works](#how-it-works)
  - [How to Use](#how-to-use)
    - [Sync Arguments](#sync-arguments)
    - [Organize Arguments](#organize-arguments)
  - [Settings](#settings)
  - [Skipping Steps](#skipping-steps)
  - [Testing](#testing)

## How it Works

Here is what the ```iCloudSync.ps1``` script does in order:

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

Sync by specifying the directories to sync to and the final destination:

```powershell
./iCloudSync.ps1 -Directory 'Z:\@iCloud\.Organize' -DestinationDir = 'Z:\@iCloud'
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

These are the settings in the ```iCloudSync.ini``` that you can modify.

Name | Value | Description
---|---|---
SettingsPath | $(Join-Path $env:AppData 'iCloudSync\iCloudSync.ini') | The path to the user settings file, you shouldn't have to change this
ImageFilter | \\.(jpg\|jpeg\|png) | The extensions to filter images by
VideoFilter | \\.(mov\|3gp\|mp4) | The extensions to filter videos by
MediaFilter | \\.(jpg\|jpeg\|png\|mov\|3gp\|mp4) | The combined list of media extensions
MediaFileNameFormatString | yyyy.MM.dd.HH.mm.ss | The format of the file name when renaming files
ScheduledTaskName | iCloudSync | The name of the scheduled task created with ```-install```
RunEveryXHours | 12 | The repeat interval in hours for the scheduled task
PowerShellExePath | C:\\Program Files\\PowerShell\\7\\pwsh.exe | The path to the PowerShell executable for the scheduled task
PowerShellArguments | -ExecutionPolicy Bypass "$(Join-Path (Split-Path $PSScriptRoot -Parent) iCloudSync.ps1)" | The PowerShell arguments for the scheduled task
DownloaderExePath | $(Join-Path $PSScriptRoot 'tools\\icloudpd-1.13.4-windows-amd64.exe') | The path to the ```icloudpd``` executable
DownloaderArguments | --skip-live-photos --folder-structure none --delete-after-download --no-progress-bar --recent 100 | The arguments used by the ```icloudpd``` downloader
JheadExePath | $(Join-Path $PSScriptRoot 'tools\\jhead.exe') | The path to the ```jhead``` executable
ExifToolExePath | $(Join-Path $PSScriptRoot 'tools\\exiftool.exe') | The path to the ```exiftool``` executable
CredentialsPath | $(Join-Path $env:AppData 'iCloudSync\\Credentails.xml') | The path to where the credentials file is stored

## Skipping Steps

You can skip any of the steps the script takes by passing the appropriate ```skip``` parameter.

* Passing ```-skipDownload``` skips the download step all together

   ```powershell
   ./iCloudSync.ps1 -skipDownload
   ```

* Passing ```-skipProcessing``` skips the processing steps all together

   ```powershell
   ./iCloudSync.ps1 -skipProcessing
   ```

* Passing ```-skipBackup``` skips the backup and it does not create a backup of the media

   ```powershell
   ./iCloudSync.ps1 -skipBackup
   ```

* Passing ```-skipRename``` skips rename the downloaded media

   ```powershell
   ./iCloudSync.ps1 -skipRename
   ```

* Passing ```-skipDuplicates``` skips the check for duplicates step

   ```powershell
   ./iCloudSync.ps1 -skipDuplicates
   ```

* Passing ```-skipOrganize``` skips the organize step

   ```powershell
   ./iCloudSync.ps1 -skipOrganize
   ```

* You can also pass all of them at once

   ```powershell
   ./iCloudSync.ps1 -skipDownload -skipProcessing -skipBackup -skipRename -skipDuplicates -skipOrganize
   ```

## Testing

There is a couple of parameters you can pass the script if you only want to simulate the work being done and not make any changes.

* Passing ```-whatIf``` will output to the console all the actions the script will take, but not
  actually take them

   ```powershell
   ./iCloudSync.ps1 -whatIf
   ```

* Passing ```-debug``` will output extra debug information

   ```powershell
   ./iCloudSync.ps1 -debug
   ```

* You can also pass both ```-whatIf -debug``` for a combination of both

   ```powershell
   ./iCloudSync.ps1 -whatIf -debug
   ```