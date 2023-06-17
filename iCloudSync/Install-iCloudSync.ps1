function Install-iCloudSync {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][hashtable] $settings
    )

    $taskName = $settings.ScheduledTaskName
    $runEveryXHours = $settings.RunEveryXHours

    $exe = $settings.PowerShellExePath
    $arguments = $ExecutionContext.InvokeCommand.ExpandString($settings.PowerShellArguments)

    if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        $timeSpan = New-TimeSpan -Hours $runEveryXHours
        $action = New-ScheduledTaskAction -Execute "`"$exe`"" -Argument $arguments
        $trigger = New-ScheduledTaskTrigger -RepetitionInterval $timeSpan -Once -At (Get-Date)

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger | Out-Null
    }
    else {
        $timeSpan = New-TimeSpan -Hours $runEveryXHours
        $action = New-ScheduledTaskAction -Execute $exe -Argument $arguments
        $trigger = New-ScheduledTaskTrigger -RepetitionInterval $timeSpan -Once -At (Get-Date)

        Set-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger | Out-Null
    }
}