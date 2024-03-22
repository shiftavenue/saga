# shiftavenue.GraphAutomation

This repo contains the PowerShell module shiftavenue.GraphAutomation, serving as a collection of automation tasks our operatives had in the past.

## Getting started

Install the module from the PowerShell Gallery, allowing clobbering to overwrite Invoke-Graph which may or
may not be on disk already:

```powershell
Install-Module -Name shiftavenue.GraphAutomation -AllowClobber -Scope CurrentUser
```

Configure the module with the Graph authentication method of your choice. By registering
the config you only need to do the setup once 👍

```powershell
# Configure Client and Tenant ID. If using a personal account, the tenant ID would be 'common'
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientId -Value '' -PassThru | Register-PSFConfig
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphTenantId -Value '' -PassThru | Register-PSFConfig

# Default, not necessary to configure. Possible: DeviceCode, Browser, Certificate, or ClientSecret
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphConnectionMode -Value "DeviceCode" -PassThru | Register-PSFConfig

# Depending on your authentication method:
$cred = Get-Credential
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientSecret -Value $cred.Password -PassThru | Register-PSFConfig

$cert = Get-Item cert:\currentuser\my\AValidThumbprint
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphCertificate -Value $cert -PassThru | Register-PSFConfig
```

From here on out, try any of the contained cmdlets and of course, use the comment-based help:

```powershell
Get-Command -Module shiftavenue.GraphAutomation
Get-Help Get-SagaAppPermission
```
