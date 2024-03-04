$PSDefaultParameterValues.remove('import-module:verbose')

# WhoAmI?
#   whoAmI? => $PROFILE.CurrentUserCurrentHost
#   pathAbs => $Env:UserProfile\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1
# $Env:PSModulePath = @(
#     # for:  'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Dotils.psm1'
#     gi -ea 'stop' 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules'
#     $Env:PSModulePath
# ) | Join-String -sep ([IO.Path]::PathSeparator)

$PSCommandPath.Name | Join-String -op 'entry: vscode => ' | write-host -fg 'gray50' -bg 'gray20'
Import-CommandSuite -Verbose

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
