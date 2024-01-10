<#
.SYNOPSIS
    Gets the last signin time for all users in the Saga tenant.
.DESCRIPTION
    Gets the last signin time for all users in the Saga tenant.
.EXAMPLE
    Get-SagaUserLastSignIn

    Gets the last signin time for all users in the Saga tenant.
#>
function Get-SagaUserLastSignIn
{
    [CmdletBinding()]
    param
    ( )

    Connect-SagaGraph
    Invoke-GraphRequest -Query "users?`$filter=accountEnabled eq true&`$select=UserPrincipalName,id,signInActivity"
}
