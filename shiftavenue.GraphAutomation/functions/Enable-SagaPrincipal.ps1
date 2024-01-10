﻿<#
.SYNOPSIS
    Enables a service principal or user account in Entra ID.
.DESCRIPTION
    Enables a service principal or user account in Entra ID.
.PARAMETER PrincipalId
    The principal id to enable. User can be guid or SPN
.PARAMETER AccountType
    The type of account to enable. Valid values are 'servicePrincipal' or 'user'.
.EXAMPLE
    Enable-SagaPrincipal -ServicePrincipalAppId '00000000-0000-0000-0000-000000000000' -AccountType 'servicePrincipal'
    
    Enables the service principal with the app id '00000000-0000-0000-0000-000000000000'.
.PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.
.PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.
#>
function Enable-SagaPrincipal
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

    if ($PSCmdlet.ShouldProcess("$($PrincipalId.Count) accounts", "Disable"))
    {
        Set-SagaAccountStatus -ServicePrincipalAppId $PrincipalId -AccountType $AccountType -Enabled $true
    }
}