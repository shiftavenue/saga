<#
.SYNOPSIS
    Disables or enables a service principal or user account in Azure AD.
.DESCRIPTION
    Disables or enables a service principal or user account in Azure AD.
.PARAMETER PrincipalId
    The principal id to disable or enable. User can be guid or SPN
.PARAMETER AccountType
    The type of account to disable or enable. Valid values are 'servicePrincipal' or 'user'.
.PARAMETER Enabled
    Whether to enable or disable the account.
.EXAMPLE
    Set-SagaAccountStatus -ServicePrincipalAppId '00000000-0000-0000-0000-000000000000' -AccountType 'servicePrincipal' -Enabled $false

    Disables the service principal with the app id '00000000-0000-0000-0000-000000000000'.
#>
function Set-SagaAccountStatus
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $PrincipalId,

        [Parameter()]
        [ValidateSet('servicePrincipal', 'user')]
        [string]
        $AccountType = 'servicePrincipal',

        [Parameter(Mandatory = $true)]
        [bool]
        $Enabled
    )

    $accountEnabledCounter = 1
    $idToSp = @{}

    $disableRequest = foreach ($sp in $PrincipalId)
    {
        @{
            url     = "$($AccountType)s/$($sp)"
            method  = "PATCH"
            id      = $accountEnabledCounter
            body    = @{"accountEnabled" = $Enabled }
            headers = @{
                "Content-Type" = "application/json"
            }
        }
        $idToSp[$accountEnabledCounter] = $sp
        $accountEnabledCounter++
    }

    $responses = Invoke-GraphRequestBatch -Request $disableRequest

    foreach ($response in $responses)
    {
        $sp = $idToSp[$response.id]
        if ($response.status -in 200 - 299)
        {
            Write-PSFMessage -Message "Disabled '$($sp)'"
        }
        else
        {
            Write-PSFMessage -Message "Error disabling '$($sp)': $($response.body.error.message)" -Level Error
        }
    }
}