---
external help file: shiftavenue.GraphAutomation-help.xml
Module Name: shiftavenue.GraphAutomation
online version:
schema: 2.0.0
---

# Enable-SagaPrincipal

## SYNOPSIS
Enables a service principal or user account in Entra ID.

## SYNTAX

```
Enable-SagaPrincipal [-PrincipalId] <String[]> [[-AccountType] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enables a service principal or user account in Entra ID.

## EXAMPLES

### EXAMPLE 1
```
Enable-SagaPrincipal -ServicePrincipalAppId '00000000-0000-0000-0000-000000000000' -AccountType 'servicePrincipal'
```

Enables the service principal with the app id '00000000-0000-0000-0000-000000000000'.

## PARAMETERS

### -AccountType
The type of account to enable.
Valid values are 'servicePrincipal' or 'user'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ServicePrincipal
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrincipalId
The principal id to enable.
User can be guid or SPN

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
