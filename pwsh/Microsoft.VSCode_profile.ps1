# Previously included: '<file:///C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1>'
return

# main entry point for VS Code
gi $PSCommandPath | Join-String -f 'loading: "<file:///{0}>"' #-doubleQuote

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; }  [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.MainEntry_VSCode = $PSCommandPath | Get-Item

'Import-CommandSuite ... ' | write-host -ForegroundColor blue
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

# /h:/ vscode only
