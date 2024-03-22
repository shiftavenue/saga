<#
.SYNOPSIS
    Import attributes to users in Entra ID
.DESCRIPTION
    Import attributes to users in  Entra ID. Bulk import can be done using CSV or JSON. All
    objects must have the property UserPrincipalName as either the actual UPN or the object GUID of
    each user. All other properties will be used as attributes which are updated.
    There is no schema validation against available Entra attributes!
.EXAMPLE
    Import-SagaEntraAttribute -CsvPath 'C:\temp\users.csv'

    Import attributes to users in Entra ID from a CSV file.
.PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.
.PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.
#>
function Import-SagaEntraAttribute {
    [CmdletBinding(DefaultParameterSetName = 'Json', SupportsShouldProcess, ConfirmImpact = 'High')]
    param
    (
        # Column UserPrincipalName, Attribute1Name, Attribute2Name, ...
        [Parameter(ParameterSetName = 'Csv')]
        [string]
        $CsvPath,

        <# Array of objects with UserPrincipalName, Attribute1Name, Attribute2Name, ...
        [
            {
                "UserPrincipalName" : "john@contoso.com",
                "Attribute1Name" : "Attribute1Value",
                "Attribute2Name" : "Attribute2Value"
            },
            {
                "UserPrincipalName" : "sally@contoso.com",
                "Attribute1Name" : "Attribute1Value",
                "Attribute2Name" : "Attribute2Value"
            }
        ]
        #>
        [Parameter(ParameterSetName = 'Json')]
        [string]
        $JsonPath
    )

    Connect-SagaGraph

    $bulkData = if ($PSCmdlet.ParameterSetName -eq 'Json') {
        Get-Content -Path $JsonPath | ConvertFrom-Json
    }
    else {
        Import-Csv -Path $CsvPath
    }

    if (-not $PSCmdlet.ShouldProcess("$($bulkData.Count) users", "Update")) { return }

    $batchCounter = 1
    $idToUser = @{}

    [hashtable[]] $requests = foreach ($item in $bulkData) {
        $body = @{}

        foreach ($property in $item.PsObject.Properties.Where({ $_.Name -ne 'UserPrincipalName' })) {
            $body[$property.Name] = $property.Value
        }

        @{
            url     = "/users/$($item.UserPrincipalName)"
            method  = "PATCH"
            id      = $batchCounter
            body    = $body
            headers = @{
                "Content-Type" = "application/json"
            }
        }
        $idToUser[$batchCounter] = $item
        $batchCounter++
    }

    $userUpdate = Invoke-GraphRequestBatch -Request $requests

    foreach ($userUpdate in ($userUpdate | Where-Object { $_.status -in 200..299 })) {
        $user = $idToUser[[int]$userUpdate.Id]
        Write-PSFMessage -Message "Updated $($user.UserPrincipalName)"
    }

    foreach ($userUpdate in ($userUpdate | Where-Object { $_.status -notin 200..299 })) {
        $user = $idToUser[[int]$userUpdate.Id]
        Write-PSFMessage -Message "Failed to update $($user.UserPrincipalName) with $($userUpdate.status)"
    }
}
