# Previously included: '<file:///C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1>'

# main entry point for VS Code
gi $PSCommandPath | Join-String -f 'loading: {0}' -doubleQuote

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

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

Write-Warning "?? $PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"



return

if ($false -and 'to cleanup/delete') {
    . (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1')
    "enter ==> Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}' $($PSCommandPath)" | Write-Warning

    $VsCodeProfileCfg = @{
        AlwaysInvokeNormalProfile = $true
    }
    Set-Alias 'label' -Value (Get-Date) -Force -ea ignore
    # main entry for Vs Code Addon
    # full restart of main pwsh profile: 2022-11-30
    Write-Warning 'next: new PSModulePath'
    'disabled,see {0}`n=> {1}' -f @(
        'H:/data/2021/pwsh_myDocs'
        | Join-String -DoubleQuote
        $PSCommandPath
        | Join-String -DoubleQuote
    ) | Write-Host -ForegroundColor blue

    if ($global:__nin_enableTraceVerbosity) { "enter ==> dotsourcing: ==> Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Debug }

    if ($VsCodeProfileCfg.AlwaysInvokeNormalProfile) {
        . ( Join-Path -Path "${Env:UserProfile}/skydrive/Documents/PowerShell" -ChildPath 'Microsoft.Powershell_profile.ps1'
            | Get-Item -ea 'continue' ) *>$null
    }
    if ($global:__nin_enableTraceVerbosity) { "exit  <== dotsourcing: <== Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Warning }

    if ($global:__nin_enableTraceVerbosity) {
        'Import: => Import-CommandSuite ... ' | Write-Verbose
    }
    Import-CommandSuite

    if ($global:__nin_enableTraceVerbosity) {
        "exit  <== Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}'"
        | Write-Warning
    }
    if ($global:__nin_enableTraceVerbosity) {
        "$PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"
        | Write-Debug
    }



    if ($global:__nin_enableTraceVerbosity) {
        "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning
    }
    [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


}