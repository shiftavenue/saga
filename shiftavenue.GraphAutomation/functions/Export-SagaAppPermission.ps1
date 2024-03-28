<#
.SYNOPSIS
    Exports all service principals and their permissions to an Excel file.
.DESCRIPTION
    Exports all service principals and their permissions to an Excel file.
.PARAMETER ServicePrincipal
    The service principal to export.
.PARAMETER SingleReportPath
    The path to the Excel file to export the data to.
.PARAMETER SummaryReportPath
    The path to the Excel file to export the summary data to.
.EXAMPLE
    Export-SagaAppPermission -SingleReportPath 'C:\temp\GraphAppInventory.xlsx' -SummaryReportPath 'C:\temp\GraphAppInventorySummary.xlsx'

    Exports all service principals and their permissions to an Excel file.
#>
function Export-SagaAppPermission {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]
        $ServicePrincipal,

        [Parameter()]
        [string]
        $SingleReportPath = "$(Get-Date -Format 'yyyy-MM-dd')_GraphAppInventory.xlsx",

        [Parameter()]
        $SummaryReportPath = "Report.xlsx"
    )

    begin {
        $preparedOutput = [System.Collections.ArrayList]::new()
    }

    process {
        foreach ($sp in $ServicePrincipal) {
            $null = $preparedOutput.Add([PSCustomObject][ordered]@{
                    "Service Principal Name"             = $SP.displayName
                    "Application Name"                   = $SP.appDisplayName
                    "Publisher"                          = if ($SP.PublisherName) { $SP.PublisherName } else { $null }
                    "Verified"                           = if ($SP.verifiedPublisher.verifiedPublisherId) { $SP.verifiedPublisher.displayName } else { "Not verified" }
                    "Homepage"                           = if ($SP.Homepage) { $SP.Homepage } else { $null }
                    "Created on"                         = if ($SP.createdDateTime) { (Get-Date($SP.createdDateTime) -format g) } else { $null }
                    "ApplicationId"                      = $SP.AppId
                    "ObjectId"                           = $SP.id
                    "AccountEnabled"                     = $SP.AccountEnabled
                    "AccountEnabledDesiredState"         = if ($SP.AccountEnabledDesiredState) { $SP.AccountEnabledDesiredState } else { $false }
                    "Last modified"                      = $sp.lastModified
                    "Permissions (application)"          = $sp.permissionsByApplication
                    "Authorized By (application)"        = $sp.authorizedByApplication
                    "Permissions (delegate)"             = $sp.delegatePermissions
                    "Valid until (delegate)"             = $sp.delegateValidUntil
                    "Authorized By (delegate)"           = $sp.delegateAuthorizedBy
                    "SignIns last $TimeFrameInDays days" = $sp.signInsTimePeriod
                    "Active Users $TimeFrameInDays days" = $sp.activeUsersTimePeriod
                    "Detailed SignIns"                   = $sp.signInsTimePeriodDetail
                    "SignInAudience"                     = $sp.signInAudience
                }
            )
        }
    }

    end {
        #Export the result to Excel file
        $output | Export-Excel -Path $SingleReportPath
        $output | Export-Excel -Path $SummaryReportPath -WorksheetName "$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))_GraphAppInv" -TableName "GraphAppInv_$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))"

        # Prep table
        Copy-Item -Path $SummaryReportPath -Destination "$SummaryReportPath.bak" -Force
        Remove-Worksheet -WorksheetName Reporting -Path $SummaryReportPath -ErrorAction SilentlyContinue
        $package = Open-ExcelPackage -Path $SummaryReportPath -KillExcel

        $summaryData = foreach ($worksheet in $package.Workbook.Worksheets.Where({ $_.Name -ne 'Reporting' })) {
            $doc = Import-Excel -Path $SummaryReportPath -WorksheetName $worksheet.Name
            [pscustomobject]@{
                Date             = $worksheet.Name
                'NumberSPs'      = $doc.Count
                'NumberDisabled' = $doc.Where({ $_.PSObject.Properties.Name -contains 'Enabled' -and -not $_.Enabled }).Count
                'NumberEnabled'  = $doc.Where({ $_.PSObject.Properties.Name -contains 'Enabled' -and $_.Enabled }).Count
            }
        }

        $chart = New-ExcelChartDefinition -Title "Service principals over time" -ChartType Area -XRange 'Date' -YRange "NumberSPs", "NumberDisabled" -SeriesHeader "Number SPs", "Number disabled"

        $summaryData | Export-Excel -AutoNameRange -WorksheetName Reporting -MoveToStart -Path $SummaryReportPath -ExcelChartDefinition $chart
    }
}
