---
external help file: shiftavenue.GraphAutomation-help.xml
Module Name: shiftavenue.GraphAutomation
online version:
schema: 2.0.0
---

# Get-SagaAppPermission

## SYNOPSIS
Gets the permissions of all service principals in the tenant.

## SYNTAX

```
Get-SagaAppPermission [[-TimeFrameInDays] <UInt16>] [[-ExcludeBuiltInServicePrincipals] <Boolean>]
 [[-ExcludeDisabledApps] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Gets the permissions, OAuth scopes, Signins and delegations of all service principals in the tenant.

## EXAMPLES

### EXAMPLE 1
```
Get-SagaAppPermission -TimeFrameInDays 30 -ExcludeBuiltInServicePrincipals -ExcludeDisabledApps
```

Gets the permissions, OAuth scopes, Signins and delegations of all service principals in the tenant for the last 30 days.

## PARAMETERS

### -ExcludeBuiltInServicePrincipals
Whether to exclude built-in service principals.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDisabledApps
Whether to exclude disabled apps.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```


### -TimeFrameInDays
The number of days to look back for signins.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 30
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable and -ProgressAction. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
