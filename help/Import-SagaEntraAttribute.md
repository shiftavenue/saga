---
external help file: shiftavenue.GraphAutomation-help.xml
Module Name: shiftavenue.GraphAutomation
online version:
schema: 2.0.0
---

# Import-SagaEntraAttribute

## SYNOPSIS
Import attributes to users in Entra ID

## SYNTAX

### Json (Default)
```
Import-SagaEntraAttribute [-JsonPath <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Csv
```
Import-SagaEntraAttribute [-CsvPath <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Import attributes to users in  Entra ID.
Bulk import can be done using CSV or JSON.
All
objects must have the property UserPrincipalName as either the actual UPN or the object GUID of
each user.
All other properties will be used as attributes which are updated.
There is no schema validation against available Entra attributes!

## EXAMPLES

### EXAMPLE 1
```
Import-SagaEntraAttribute -CsvPath 'C:\temp\users.csv'
```

Import attributes to users in Entra ID from a CSV file.

## PARAMETERS

### -CsvPath
Column UserPrincipalName, Attribute1Name, Attribute2Name, ...

```yaml
Type: String
Parameter Sets: Csv
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JsonPath
Array of objects with UserPrincipalName, Attribute1Name, Attribute2Name, ...
       \[
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
       \]

```yaml
Type: String
Parameter Sets: Json
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```


### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable and -ProgressAction. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
