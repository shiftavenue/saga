Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphConnectionMode -Value DeviceCode -Validation string -Description 'DeviceCode, Browser, or ClientSecret' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientId -Value '' -Validation string -Description 'Client ID for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphTenantId -Value '' -Validation string -Description 'Tenant ID for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientSecret -Value '' -Validation secret -Description 'Client Secret for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name Logpath -Value (Join-Path -Path $HOME -ChildPath '.saga/logs') -Validation string -Default -Description 'Path to CMtrace log files'

# GUID bauen validation