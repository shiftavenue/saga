<#
.SYNOPSIS
    Gets the permissions of all service principals in the tenant.
.DESCRIPTION
    Gets the permissions, OAuth scopes, Signins and delegations of all service principals in the tenant.
.PARAMETER TimeFrameInDays
    The number of days to look back for signins.
.PARAMETER ExcludeBuiltInServicePrincipals
    Whether to exclude built-in service principals.
.PARAMETER ExcludeDisabledApps
    Whether to exclude disabled apps.
.EXAMPLE
    Get-SagaAppPermission -TimeFrameInDays 30 -ExcludeBuiltInServicePrincipals -ExcludeDisabledApps

    Gets the permissions, OAuth scopes, Signins and delegations of all service principals in the tenant for the last 30 days.
#>
function Get-SagaAppPermission {
    [CmdletBinding()]
    param
    (
        [uint16]
        $TimeFrameInDays = 30,

        [bool]
        $ExcludeBuiltInServicePrincipals = $true,

        [bool]
        $ExcludeDisabledApps = $true
    )

    $TimeFrameDate = (Get-Date -format u ((Get-Date).AddDays(-$TimeFrameInDays)).Date).Replace(' ', 'T')

    Connect-SagaGraph

    $servicePrincipals = [System.Collections.ArrayList]::new()

    if ($ExcludeBuiltInServicePrincipals) {
        $query = "servicePrincipals?&`$filter=tags/any(t:t eq 'WindowsAzureActiveDirectoryIntegratedApp')"
    }

    $query = if (-not $ExcludeDisabledApps) {
        "servicePrincipals?&`$filter=accountEnabled eq true"
    }
    else {
        "servicePrincipals"
    }

    $servicePrincipals.AddRange([array](Invoke-GraphRequest -Query $query))


    $araCounter = 1
    $idToSp = @{}
    $appRoleAssignmentsRequest = foreach ($sp in $servicePrincipals) {
        @{
            url    = "/servicePrincipals/$($sp.id)/appRoleAssignments"
            method = "GET"
            id     = $araCounter
        }
        $idToSp[$araCounter] = $sp
        $araCounter++
    }

    $responses = Invoke-GraphRequestBatch -Request $appRoleAssignmentsRequest
    foreach ($response in $responses) {
        if ($null -eq $response.id) { continue }
        $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'appRoleAssignments' -NotePropertyValue $response.body.value -Force
    }

    $assignedPrincipals = ($servicePrincipals | Where-Object { $_.appRoleAssignments.Count -gt 0 }).appRoleAssignments.resourceId | Select-Object -Unique
    foreach ($principal in $assignedPrincipals) {
        if ($servicePrincipals.id -notcontains $principal) {
            $null = $servicePrincipals.Add((Invoke-GraphRequest -Query "servicePrincipals/$principal"))
        }
    }

    foreach ($sp in ($servicePrincipals | Where-Object { $_.appRoleAssignments.Count -gt 0 })) {
        $date = ($sp.appRoleAssignments.CreationTimestamp | Select-Object -Unique | Sort-Object -Descending | Select-Object -First 1) -as [datetime]
        if (-not $date) { $date = [DateTime]::MinValue }
        $sp | Add-Member -NotePropertyName 'lastModified' -NotePropertyValue $date.ToString('g') -Force

        $permissionsByApplication = foreach ($appRoleAssignment in $sp.appRoleAssignments) {
            $roleId = (($servicePrincipals | Where-Object id -eq $appRoleAssignment.resourceId).appRoles | Where-Object { $_.id -eq $appRoleAssignment.appRoleId }).Value | Select-Object -Unique
            if (!$roleID) { $roleId = "Orphaned ($($appRoleAssignment.appRoleId))" }

            "[$($appRoleAssignment.ResourceDisplayName)]:$($roleId -join ',')"
        }

        $sp | Add-Member -NotePropertyName permissionsByApplication -NotePropertyValue $permissionsByApplication -Force
        $sp | Add-Member -NotePropertyName authorizedByApplication -NotePropertyValue 'An administrator (application permissions)' -Force
    }

    $oauthCounter = 1
    $idToSp = @{}
    $oauth2PermissionGrantsRequest = foreach ($sp in $servicePrincipals) {
        @{
            url    = "/servicePrincipals/$($sp.id)/oauth2PermissionGrants"
            method = "GET"
            id     = $oauthCounter
        }
        $idToSp[$oauthCounter] = $sp
        $oauthCounter++
    }

    $responses = Invoke-GraphRequestBatch -Request $oauth2PermissionGrantsRequest
    foreach ($response in $responses) {
        if ($null -eq $response.id) { continue }
        $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'oauth2PermissionGrants' -NotePropertyValue $response.body.value -Force
    }

    $users = [System.Collections.ArrayList]::new()
    $grantedPrincipals = $servicePrincipals | Where-Object { $_.oauth2PermissionGrants.Count -gt 0 } | ForEach-Object { $_.oauth2PermissionGrants.principalId } | Select-Object -Unique

    $userCounter = 1
    $idToSp = @{}
    $grantedUsersRequest = foreach ($principal in $grantedPrincipals) {
        if ($users.id -notcontains $principal) {
            @{
                url    = "/users/$($principal)?`$select=UserPrincipalName"
                method = "GET"
                id     = $userCounter
            }
            $idToSp[$userCounter] = $principal
            $userCounter++
        }
    }

    if ($grantedUsersRequest) {
        $responses = Invoke-GraphRequestBatch -Request $grantedUsersRequest

        $users = @{}
        foreach ($response in $responses) {
            if ($null -eq $response.id) { continue }
            $users[$idToSp[[int]$response.id]] = $response.body.UserPrincipalName
        }
    }

    foreach ($sp in ($ServicePrincipals | Where-Object { $_.oauth2PermissionGrants.Count -gt 0 })) {
        $perms = foreach ($oauth2PermissionGrant in $sp.oauth2PermissionGrants) {
            $resID = ($servicePrincipals | Where-Object id -eq $appRoleAssignment.resourceId).appDisplayName
            if ($null -ne $oauth2PermissionGrant.PrincipalId) {
                $userId = "($($users[$oauth2PermissionGrant.principalId]))"
            }
            else { $userId = $null }
            "[$($resID)$($userId)]:$($oauth2PermissionGrant.Scope.TrimStart().Split(' ') -join ',')"
        }

        $validUntil = ($sp.oauth2PermissionGrants.ExpiryTime | Sort-Object -Descending | Select-Object -Unique  -First 1) -replace 'Z$'
        $sp | Add-Member -NotePropertyName delegatePermissions -NotePropertyValue $perms -Force
        $sp | Add-Member -NotePropertyName delegateValidUntil -NotePropertyValue $validUntil -Force

        $assignedTo = [System.Collections.Generic.List[string]]::new()
        if (($sp.oauth2PermissionGrants.ConsentType | Select-Object -Unique) -eq "AllPrincipals") { $assignedto.Add("All users (admin consent)") }
        if ($null -ne [string[]]($perms | ForEach-Object { if ($_ -match "\((.*@.*)\)") { $Matches[1] } })) { $assignedto.AddRange() }

        $sp | Add-Member -NotePropertyName delegateAuthorizedBy -NotePropertyValue ($assignedto | Select-Object -Unique) -Force
    }

    $accountEnabledCounter = 1
    $idToSp = @{}
    $signInRequest = foreach ($sp in ($servicePrincipals | Where-Object AccountEnabled)) {
        @{
            url    = "/auditLogs/signIns?`$filter=(CreatedDateTime ge $TimeFrameDate) and (appid eq '$($sp.appId)') and signInEventTypes/any(t: t eq 'interactiveUser' or t eq 'nonInteractiveUser' or t eq 'managedIdentity' or t eq 'servicePrincipal')"
            method = "GET"
            id     = $accountEnabledCounter
        }
        $idToSp[$accountEnabledCounter] = $sp
        $accountEnabledCounter++
    }

    $responses = Invoke-GraphRequestBatch -Request $signInRequest

    foreach ($response in $responses) {
        if ($null -eq $response.id) { continue }
        $signinsCurrent = $response.body.value
        $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'signInsTimePeriod' -NotePropertyValue $signinsCurrent.Count -Force
        $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'activeUsersTimePeriod' -NotePropertyValue ($signinsCurrent | Group-Object userPrincipalName).Name.Count -Force

        if (($signinsCurrent | Group-Object userPrincipalName).Name.Count -gt 0) {
            $detailed = $signinsCurrent | Group-Object userPrincipalName | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) - $($_.Count)" }
            $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'signInsTimePeriodDetail' -NotePropertyValue $detailed -Force
            $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'AccountEnabledDesiredState' -NotePropertyValue $true -Force
        }
        else {
            $idToSp[[int]$response.id] | Add-Member -NotePropertyName 'AccountEnabledDesiredState' -NotePropertyValue $false -Force
        }
    }

    $servicePrincipals
}