param(
    [Parameter(Mandatory)]
    [string]$Path
)
# short version. See './ExportPipescript.ps1' for fancy output
Import-Module Pipescript
Export-Pipescript $Path #-Verbose -Debug
