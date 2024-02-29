<#
.SYNOPSIS
    Get the signin methods and license status for all enabled users in the tenant.
.DESCRIPTION
    Get the signin methods and license status for all enabled users in the tenant.
.EXAMPLE
    Get-SagaUserSigninAndLicenseStatus

    Get the signin methods and license status for all users in the tenant.
#>
function Get-SagaUserSigninAndLicenseStatus
{
    [CmdletBinding()]
    param
    ( )

    Connect-SagaGraph

    [System.Collections.Arraylist]$users = Invoke-GraphRequest -Query "users?`$filter=accountEnabled eq true&`$select=UserPrincipalName,id"

    $batchCounter = 1
    $idToUser = @{}
    $requests = foreach ($user in $users)
    {
        @{
            url    = "/users/$($user.id)/authentication/methods"
            method = "GET"
            id     = $batchCounter
        }
        $idToUser[$batchCounter] = $user
        $batchCounter++
    }

    $methods = Invoke-GraphRequestBatch -Request $requests

    foreach ($method in $methods)
    {
        [string[]] $formatedMethod = foreach ($authMethod in $method.body.value)
        {
            if ($authMethod.psobject.properties.name -contains 'createdDateTime' -and -not $authMethod.createdDateTime) { $authMethod.createdDateTime = [datetime]::MinValue }
            switch -Regex ($authMethod.'@odata.type')
            {
                'phoneAuthentication' { '{0}_{1}_{2}_SMSSigninEnabled_{3}' -f 'PhoneAuthentication', $authMethod.phoneNumber, $authMethod.phoneType, $authMethod.smsSignInState }
                'microsoftAuthenticatorAuthentication' { '{0}_{1}_{2}_{3}' -f 'AuthenticatorApp', $authMethod.displayName, $authMethod.deviceTag, $authMethod.phoneAppVersion }
                'fido2Authentication' { '{0}_{1:yyyyMMdd}_{2}_{3}' -f 'FIDO2', $authMethod.createdDateTime, $authMethod.attestationLevel, $authMethod.model }
                'windowsHelloForBusinessAuthentication' { '{0}_{1:yyyyMMdd}_{2}_strength_{3}' -f 'Hello', $authMethod.createdDateTime, $authMethod.displayName, $authMethod.keyStrength }
                'passwordAuthentication' { '{0}_{1:yyyyMMdd-HHmmss}' -f 'Password', $_.createdDateTime }
                'emailAuthentication' { $authMethod.emailAddress }
            }
        }

        $idToUser[[int]$method.id] | Add-Member -MemberType NoteProperty -Name AuthenticationMethods -Value ($formatedMethod -join '#') -Force
    }

    $batchCounter = 1
    $idToUser = @{}
    $requests = foreach ($user in $users)
    {
        @{
            url    = "/users/$($user.id)/authentication/signInPreferences"
            method = "GET"
            id     = $batchCounter
        }
        $idToUser[$batchCounter] = $user
        $batchCounter++
    }

    $preferences = Invoke-GraphRequestBatch -Request $requests

    foreach ($preference in $preferences)
    {
        $idToUser[[int]$preference.id] | Add-Member -MemberType NoteProperty -Name SystemPreferredAuthenticationMethodEnabled -Value $preference.body.isSystemPreferredAuthenticationMethodEnabled
        $idToUser[[int]$preference.id] | Add-Member -MemberType NoteProperty -Name UserPreferredMethodForSecondaryAuthentication -Value $preference.body.userPreferredMethodForSecondaryAuthentication
        $idToUser[[int]$preference.id] | Add-Member -MemberType NoteProperty -Name SystemPreferredAuthenticationMethod -Value $preference.body.systemPreferredAuthenticationMethod
    }

    $batchCounter = 1
    $idToUser = @{}
    $requests = foreach ($user in $users)
    {
        @{
            url    = "/users/$($user.id)/licenseDetails?`$select=skuPartNumber,servicePlans"
            method = "GET"
            id     = $batchCounter
        }
        $idToUser[$batchCounter] = $user
        $batchCounter++
    }

    $licenses = Invoke-GraphRequestBatch -Request $requests

    foreach ($license in $licenses)
    {
        $idToUser[[int]$license.id] | Add-Member -MemberType NoteProperty -Name License -Value ($license.body.value.skuPartNumber)
        $idToUser[[int]$license.id] | Add-Member -MemberType NoteProperty -Name ServicePlans -Value (($license.body.value.servicePlans | Where-Object { $_.provisioningStatus -eq 'Success' -and $_.AppliesTo -eq 'User' }).servicePlanName)
    }

    $idToUser.Values
}
