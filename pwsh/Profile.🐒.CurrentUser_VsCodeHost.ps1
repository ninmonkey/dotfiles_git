# $PSDefaultParameterValues.remove('import-module:verbose')
$PSCommandPath | Join-String -f ' ==> Entering: "{0}"' | Out-Host
$PSCommandPath | Get-Item | Join-String -f ' ==> Entering: <file:///{0}>' -p FullName | Write-Warning


# Short log, followed by extra details on which script[s] execute
if( $Pseditor ) {
    'is $PSEditor ?: Yes' | New-Text -fg 'darkred' | Write-warning
} else {
    'is $PSEditor ?: No'  | new-Text -fg 'darkgreen' | Write-warning
}
if ( $psEditor ) {
    Write-Host '📌 from pwsh, at path: ''<file:///H:\data\2023\dotfiles.2023\pwsh\Profile.🐒.CurrentUser_VsCodeHost.ps1>''. <added: 2025-07-14>'
    write-host "Should clean up old PS Command suite config, below: $( $PSCommandPath ) "
    write-warning "Early exit: PSEditor was found! ( from: '$PSCommandPath' ). 🙀";

    "  => Should Import PSES / Language Service? : 'Import-CommandSuite -Verbose' ? " | Write-Warning
    "       Came from: <file:///H:/data/2023/dotfiles.2023/pwsh/Profile.🐒.CurrentUser_VsCodeHost.ps1> " | Write-Warning

    if( $false ) {
        'running: "Import-CommandSuite"' | Write-Verbose
        Import-CommandSuite -Verbose
    } else {
        'skipped: "Import-CommandSuite"' | Write-Warning
    }

}
# WhoAmI?
#   whoAmI? => $PROFILE.CurrentUserCurrentHost
#   pathAbs => $Env:UserProfile\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1
# $Env:PSModulePath = @(
#     # for:  'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Dotils.psm1'
#     gi -ea 'stop' 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules'
#     $Env:PSModulePath
# ) | Join-String -sep ([IO.Path]::PathSeparator)

$PSCommandPath | Join-String -op 'End Of: ' -f  -p FullName
    | write-host -fg 'gray50' -bg 'gray20'

return


<#
New PSeditorServiceds install.

    module
        Install-Module -Scope CurrentUser -AllowPrerelease EditorServicesCommandSuite
    profile:
        Import-CommandSuite

set keybind:
        {
            "key": "ctrl+.",
            "command": "PowerShell.InvokeRegisteredEditorCommand",
            "args": { "commandName": "Invoke-DocumentRefactor" },
            "when": "editorLangId == 'powershell'"
        },
        {
            "key": "ctrl+shift+s",
            "command": "PowerShell.InvokeRegisteredEditorCommand",
            "args": { "commandName": "ConvertTo-SplatExpression" },
            "when": "editorLangId == 'powershell'"
        },

try:
    PowerShell.DebugPesterTestsFromFile",
    PowerShell.RunPesterTestsFromFile",
    PowerShell.RunPesterTests",
    PowerShell.ShowAdditionalCommands"
    PowerShell.ShowHelp"
    PowerShell.ShowAdditionalCommands",
    PowerShell.InvokeRegisteredEditorCommand",
    PowerShell.InvokeRegisteredEditorCommand",
    PowerShell.InvokeRegisteredEditorCommand",
    PowerShell.InvokeRegisteredEditorCommand",
    PowerShell.InvokeRegisteredEditorCommand",

examples

     {
        "key": "alt+shift+n",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": {
            "commandName": "AddResolvedNamespace"
        },
        "when": "editorLangId == 'powershell'"
    },
    {
        "key": "alt+shift+m",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": {
            "commandName": "ExpandMemberExpression"
        },
        "when": "editorLangId == 'powershell'"
    },

    // {
    //     "key": "ctrl+shift+,",
    //     "command": "PowerShell.InvokeRegisteredEditorCommand",
    //     "args": {
    //         "commandName": "Invoke-DocumentRefactor"
    //     },
    //     "when": "editorLangId == 'powershell'"
    // },
    {
        "key": "ctrl+shift+s",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": {
            "commandName": "ConvertTo-SplatExpression"
        },
        "when": "editorLangId == 'powershell'"
    },
    {
        // # old: "key": "ctrl+.",
        "key": "ctrl+shift+m",
        "when": "editorLangId == 'powershell'",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": {
            "commandName": "Invoke-DocumentRefactor"
        },
    },
    { // #default
        "key": "ctrl+t",
        "command": "workbench.action.showAllSymbols",
        "args": {} // what args can I pass to change default filter and sort
    },

#>
return
