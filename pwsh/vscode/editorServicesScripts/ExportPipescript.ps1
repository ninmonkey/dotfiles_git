param(
    [Parameter(Mandatory)]
    [string]$Path
)
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
Import-Module Powershell-Yaml

function invokeTranspileSingleFile {
    param(
        # path to one file, future may include patterns
        [Parameter(Mandatory)]
        [string]$Path
    )
    if(-not(Test-Path $Path)) {
        Toast -Text 'Failed, file does not exist!', ($Path | Join-String -double )
        throw @("'Failed, file does not exist!"; ($Path | Join-String -double ))
    }
    $FullPath = $Path | Get-Item
    $Path | Gi | Join-String -f 'path?: {0}' | write-verbose -verbose

    # final invoke as
    Export-PipeScript $target -Verbose -Debug


    Toast -Text 'exportPipe', $Path
}

invokeTranspileSingleFile -Path $Path

# Import-Module
# h:\data\2023\dotfiles.2023\pwsh\vscode\editorServicesScripts\ExportPipescript.ps1