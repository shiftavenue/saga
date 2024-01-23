---
external help file: shiftavenue.GraphAutomation-help.xml
Module Name: shiftavenue.GraphAutomation
online version:
schema: 2.0.0
---

# Export-SagaAppPermission

## SYNOPSIS
Exports all service principals and their permissions to an Excel file.

## SYNTAX

```
Export-SagaAppPermission [-ServicePrincipal] <Object[]> [[-SingleReportPath] <String>]
 [[-SummaryReportPath] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Exports all service principals and their permissions to an Excel file.

## EXAMPLES

### EXAMPLE 1
```
Export-SagaAppPermission -SingleReportPath 'C:\temp\GraphAppInventory.xlsx' -SummaryReportPath 'C:\temp\GraphAppInventorySummary.xlsx'
```

Exports all service principals and their permissions to an Excel file.

## PARAMETERS


### -ServicePrincipal
The service principal to export.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SingleReportPath
The path to the Excel file to export the data to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: "$(Get-Date -Format 'yyyy-MM-dd')_GraphAppInventory.xlsx"
Accept pipeline input: False
Accept wildcard characters: False
```

### -SummaryReportPath
The path to the Excel file to export the summary data to.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Report.xslx
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable and -ProgressAction. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
