<#
.SYNOPSIS
    Connects to the Microsoft Graph API.
.DESCRIPTION
    Connects to the Microsoft Graph API with the configured settings, Get-PSFConfig -Module shiftavenue.GraphAutomation.
    If the connection is already established, this function does nothing.
.EXAMPLE
    Connect-SagaGraph

    Connects to the Microsoft Graph API with the configured settings.
#>
function Connect-SagaGraph
{
    [CmdletBinding()]
    param ( )

    $clientId = Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.GraphClientId
    $tenantId = Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.GraphTenantId

    if (-not $clientId -or -not $tenantId)
    {
        Stop-PSFFunction -Message 'Please configure GraphClientId and GraphTenantId' -EnableException $true
    }

    $graphMethod = Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.GraphConnectionMode

    $mg = Get-Module -Name MiniGraph
    $alreadyConnected = & $mg { $null -ne $script:token }

    if ($alreadyConnected) { return }

    switch ($graphMethod)
    {
        'DeviceCode'
        {
            Write-PSFMessage -Message 'Using DeviceCode Authentication'
            Connect-GraphDeviceCode -ClientID $ClientId -TenantID $TenantId
        }
        'Certificate'
        {
            Write-PSFMessage -Message 'Using Certificate Authentication'
            $certificate = Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.GraphCertificate
            if (-not $certificate)
            {
                Stop-PSFFunction -Message 'Please configure GraphCertificate or switch to DeviceCode/Browser auth' -EnableException
            }
            Connect-GraphCertificate -Certificate $certificate -ClientID $clientId -TenantID $tenantId
        }
        'Browser'
        {
            Write-PSFMessage -Message 'Using Browser Authentication'
            Connect-GraphBrowser -ClientID $ClientId -TenantID $TenantId
        }
        'ClientSecret'
        {
            Write-PSFMessage -Message 'Using ClientSecret Authentication'
            $clientSecret = Get-PSFConfigValue -FullName shiftavenue.GraphAutomation.GraphClientSecret
            if (-not $clientSecret)
            {
                Stop-PSFFunction -Message 'Please configure GraphClientSecret or switch to DeviceCode/Browser auth' -EnableException
            }

            Connect-GraphClientSecret -ClientID $ClientId -ClientSecret $ClientSecret.Password -TenantID $TenantId
        }
    }

    Set-GraphEndpoint -Type beta
}
