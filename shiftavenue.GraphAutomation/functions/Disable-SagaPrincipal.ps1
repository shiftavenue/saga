<#
.SYNOPSIS
    Disables a service principal or user account in Entra ID.
.DESCRIPTION
    Disables a service principal or user account in Entra ID.
.PARAMETER PrincipalId
    The principal id to enable. User can be guid or SPN
.PARAMETER AccountType
    The type of account to disable. Valid values are 'servicePrincipal' or 'user'.
.PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.
.PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.
.EXAMPLE
    Disable-SagaPrincipal -ServicePrincipalAppId '00000000-0000-0000-0000-000000000000' -AccountType 'servicePrincipal'
    
    Disables the service principal with the app id '00000000-0000-0000-0000-000000000000'.
#>
function Disable-SagaPrincipal
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param
    (

        [Parameter(Mandatory = $true)]
        [string[]]
        $PrincipalId,

        [Parameter()]
        [ValidateSet('servicePrincipal', 'user')]
        [string]
        $AccountType = 'servicePrincipal'
    )

    Connect-GraphClientSecret -ClientID $ClientId -ClientSecret $ClientSecret -TenantID $TenantId
    Set-GraphEndpoint -Type beta

    if ($PSCmdlet.ShouldProcess("$($PrincipalId.Count) accounts", "Disable"))
    {
        Set-SagaAccountStatus -PrincipalId $PrincipalId -AccountType $AccountType -Enabled $false
    }
}