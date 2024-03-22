Register-PSFConfigValidation -Name "x509certificate" -ScriptBlock {
    Param (
        $Value
    )
	
    $Result = [PSCustomObject]@{
        Success = $True
        Value   = $null
        Message = ""
    }
	
    try { [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate = $Value }
    catch {
        $Result.Message = "Not an X509Certificate2: $Value"
        $Result.Success = $False
        return $Result
    }
	
    $Result.Value = $certificate
	
    return $Result
}

Register-PSFConfigValidation -Name "guid" -ScriptBlock {
    Param (
        $Value
    )
	
    $Result = [PSCustomObject]@{
        Success = $True
        Value   = $null
        Message = ""
    }
	
    try { [guid]$guid = $Value }
    catch {
        $Result.Message = "Not a GUID: $Value"
        $Result.Success = $False
        return $Result
    }
	
    $Result.Value = $guid
	
    return $Result
}


Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphConnectionMode -Value DeviceCode -Validation string -Description 'DeviceCode, Browser, Certificate, or ClientSecret' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientId -Value '' -Validation guid -Description 'Client ID for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphTenantId -Value '' -Validation guid -Description 'Tenant ID for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphClientSecret -Value '' -Validation secret -Description 'Client Secret for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name GraphCertificate -Value '' -Validation x509certificate -Description 'Certificate for Graph API' -Default
Set-PSFConfig -Module shiftavenue.GraphAutomation -Name Logpath -Value (Join-Path -Path $HOME -ChildPath '.saga/logs') -Validation string -Default -Description 'Path to CMtrace log files'
