<#
.SYNOPSIS
Base class representing a generic entity passed between modules.

.DESCRIPTION
`ZtEntity` defines minimal fields that modules use to exchange objects.
Additional properties can be attached in the `Properties` hashtable so
specialized modules remain interoperable.

.EXAMPLE
$entity = [ZtEntity]::new('ActiveDirectory','User','jsmith', @{ DisplayName = 'John Smith' })
#>

class ZtEntity {
    [string]   $Source
    [string]   $ObjectType
    [string]   $Identifier
    [hashtable]$Properties

    ZtEntity([string]$Source, [string]$ObjectType, [string]$Identifier, [hashtable]$Properties) {
        $this.Source      = $Source
        $this.ObjectType  = $ObjectType
        $this.Identifier  = $Identifier
        $this.Properties  = $Properties
    }
}
