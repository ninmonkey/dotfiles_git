#Requires -Version 7.0

param(
    [Parameter(Mandatory)]
    [string]$Path
)

@(
    '::ExportPipeScript::'
    'I am: {0}' -f @( $PSCommandPath )
) | Join-String -sep "`n" -os $PSStyle.Reset -f '  > {0}'

$jStr_RedPrefixPaths = @{
    Separator = "`n"
    OutputSuffix = $PSStyle.Reset
    FormatString = '  > {0}'
    OutputPrefix = $PSStyle.Foreground.FromRgb('#933136')
}

@(
    '::ExportPipeScript::'
    'I am: {0}' -f @( $PSCommandPath )
) | Join-String @jStr_RedPrefixPaths

<#
.synopsis
    Experimenting a script runner to export the currently selected file in VS Code
.EXAMPLE
    # outside invoke
    Ps> pwsh -NoP -F 'thisScript.ps1' $target
.NOTES
    future:
        better performance if implemented as editor command, allowing from cached imports etc
#>

Import-Module Pipescript
Import-Module BurntToast
# Import-Module Powershell-Yaml

function invokeTranspileSingleFile {
    param(
        # path to one file, future may include patterns
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-not(Test-Path $Path)) {
        Toast -Text 'Failed, file does not exist!', ($Path | Join-String -double )
        throw @("'Failed, file does not exist!"; ($Path | Join-String -double ))
    }
    $targetItem = $Path | Get-Item
    $targetItem | Get-Item | Join-String -f 'TargetItem: path: {0}' | Write-Verbose -Verbose

    # final invoke as
    $ShortName = $targetItem | Gi | % Name
    Toast -silent -Text 'exportPipe', "Start: '$shortName', <x of y>"
    Export-Pipescript $targetItem -Verbose -Debug

}

invokeTranspileSingleFile -Path $Path
Toast -Silent -Text 'exportPipe', "Finished all <count> items"

# Import-Module
# h:\data\2023\dotfiles.2023\pwsh\vscode\editorServicesScripts\ExportPipescript.ps1