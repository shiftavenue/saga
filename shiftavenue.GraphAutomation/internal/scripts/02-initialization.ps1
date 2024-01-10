$paramSetPSFLoggingProvider = @{
    Name         = 'logfile'
    InstanceName = '<saga>'
    FilePath     = Join-Path -Path (Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.LogPath -Fallback "$home") -ChildPath 'Saga-%Date%.log'
    FileType     = 'CMTrace'
    Enabled      = $true
}

Set-PSFLoggingProvider @paramSetPSFLoggingProvider
