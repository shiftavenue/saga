<#
.SYNOPSIS
    Add permissions to a user, group, or service principal.
.DESCRIPTION
    Add permissions to a user, group, or service principal.
.PARAMETER ServicePrincipalDisplayName
    The display name of the service principals to add permissions to.
.PARAMETER GroupDisplayName
    The display name of the groups to add permissions to.
.PARAMETER UserPrincipalName
    The user principal name of the users to add permissions to.
.PARAMETER ApplicationId
    The application id of the resource to add permissions to. Default is Graph.
.PARAMETER AppRoleId
    The app role id to add.
.EXAMPLE
    Add-SagaAppPermission -AppRoleId bf7b1a76-6e77-406b-b258-bf5c7720e98f -ServicePrincipalDisplayName 'MyServicePrincipal'

    Add Group.Create permissions on the app with display name MyServicePrincipal.
#>
function Add-SagaAppPermission {
    param
    (
        [string[]]
        $ServicePrincipalDisplayName,

        [string[]]
        $GroupDisplayName,

        [string[]]
        $UserPrincipalName,

        [string]
        $ApplicationId = "00000003-0000-0000-c000-000000000000", # Graph

        [Parameter(Mandatory = $true)]
        [string[]]
        $AppRoleId
    )

    Connect-SagaGraph

    if ($ServicePrincipalDisplayName.Count -eq 0 -and $GroupDisplayName.Count -eq 0 -and $UserPrincipalName.Count -eq 0) {
        Write-PSFMessage -Level Error -Message "What do you want to add permissions to? Specify at least one of ServicePrincipalName, GroupName, or UserName."
        return
    }

    # Get Resource App ID
    $resource = MiniGraph\Invoke-GraphRequest -Query "servicePrincipals(appId='$ApplicationId')"

    $counter = 1
    $requests = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($group in $GroupDisplayName) {
        $sp = MiniGraph\Invoke-GraphRequest -Query "groups?`$filter=displayName eq '$group'"
        foreach ($role in $AppRoleId) {
            $requests.Add(@{
                    url     = "groups/$($sp.id)/appRoleAssignments"
                    method  = "POST"
                    id      = $counter
                    body    = @{
                        principalId = $sp.id
                        resourceId  = $resource.id
                        appRoleId   = $role
                    }
                    headers = @{
                        "Content-Type" = "application/json"
                    }
                })
            
            $counter++
        }

    }
    foreach ($user in $UserPrincipalName) {
        $sp = MiniGraph\Invoke-GraphRequest -Query "users?`$filter=userPrincipalName eq '$user'"
        foreach ($role in $AppRoleId) {
            $requests.Add(@{
                    url     = "users/$($sp.id)/appRoleAssignments"
                    method  = "POST"
                    id      = $counter
                    body    = @{
                        principalId = $sp.id
                        resourceId  = $resource.id
                        appRoleId   = $role
                    }
                    headers = @{
                        "Content-Type" = "application/json"
                    }
                })

            $counter++
        }

    }
    foreach ($principal in $ServicePrincipalDisplayName) {
        $sp = MiniGraph\Invoke-GraphRequest -Query "servicePrincipals?`$filter=displayName eq '$principal'"
        foreach ($role in $AppRoleId) {
            $requests.Add(@{
                    url     = "servicePrincipals/$($sp.id)/appRoleAssignments"
                    method  = "POST"
                    id      = $counter
                    body    = @{
                        principalId = $sp.id
                        resourceId  = $resource.id
                        appRoleId   = $role
                    }
                    headers = @{
                        "Content-Type" = "application/json"
                    }
                })

            $counter++
        }
    
    }

    MiniGraph\Invoke-GraphRequestBatch -Request $requests
}
