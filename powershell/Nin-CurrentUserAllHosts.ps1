using namespace PoshCode.Pansies
#Requires -Version 7.0.0

$__ninConfig = @{
    UseAggressiveAlias         = $true
    ImportGitBash              = $true
    UsePSReadLinePredictPlugin = $false
    UsePSReadLinePredict       = $true
    Terminal                   = @{
        <#
        Terminal.CurrentTerminal = <code | 'Code - Insiders' | 'windowsterminal' | ... >
        Terminal.IsVsCode = <bool> # true when code or code insiders
        Terminal.IsVSCodeAddon_Terminal = <bool> # whether it's the addon debug term, or a regular one
        Terminal.ColorMode = [PoshCode.Pansies.ColorMode]

        others terminals:
            pwsh7 from start -> comes up as 'explorer'
            cmd /C Pwsh -> comes up as 'cmd'

        #>
        CurrentTerminal        = (Get-Process -Id $pid).Parent.Name # cleaned up name below
        IsVSCode               = $false
        IsVSCodeAddon_Terminal = $false

    }
}
& {
    $parent = (Get-Process -Id $pid).Parent.Name
    if ($parent -eq 'code') {
        $__ninConfig.Terminal.CurrentTerminal = 'code'
        $__ninConfig.Terminal.IsVSCode = $true
    }
    elseif ($parent -eq 'Code - Insiders') {
        $__ninConfig.Terminal.CurrentTerminal = 'code_insiders'
        $__ninConfig.Terminal.IsVSCode = $true
    }
    elseif ($parent -eq 'windowsterminal') {
        # preview still uses this name
        $__ninConfig.Terminal.CurrentTerminal = 'windowsterminal'
    }
    if ($pseditor) {
        # previously was: if (Get-Module 'PowerShellEditorServices*' -ea ignore) {
        # Test whether term is running, in order to run EditorServicesCommandSuite
        $__ninConfig.Terminal.IsVSCodeAddon_Terminal = $true
    }
    if ($__ninConfig.VSCodePowershell_IsExtensionTerminal) {
        Import-Module EditorServicesCommandSuite
    }
}

<#
# enable specific bugfix if you have 'PSUtil'
if (Get-Module 'psutil' -ListAvailable -ea ignore) {
    # extra case to make sure it runs until 'IsVSCode' is perfect
    $StringModule_DontInjectJoinString = $true # to fix psutil, see: <https://discordapp.com/channels/180528040881815552/467577098924589067/750401458750488577>
}
#>
if (Import-Module 'Pansies' -ea ignore) {
    [PoshCode.Pansies.RgbColor]::ColorMode = [PoshCode.Pansies.ColorMode]::Rgb24Bit
    $__ninConfig.Terminal.ColorMode = [PoshCode.Pansies.RgbColor]::ColorMode
}


'Config: ', $__ninConfig | Join-String | Write-Debug
<#
check old config for settings
    <C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinSettings.ps1>

Shared entry point from:
    $Profile.CurrentUserAllHosts
aka
    $Env:UserProfile\Documents\PowerShell\profile.ps1

#>

# explicit color because it's before imports
"`e[96mBegin: -->`e[0m'$PSScriptRoot'"
| Write-Host

<#

    [section]: VS ONLY


#>


<#

    [section]: $PSDefaultParameterValues

        details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-Fzf:OutVariable'] = 'FzfSelected'
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'
$PSDefaultParameterValues['New-Alias:ErrorAction'] = 'SilentlyContinue' # mainly for re-running profile in the same session
$PSDefaultParameterValues['Set-NinLocation:AlwaysLsAfter'] = $true
<#
    [section]: Nin.* Environment Variables
#>
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"

$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"
$Env:Pager = 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'


function Get-ProfileAggressiveItem {
    <#
    .synopsis
        Which *super* aggressive aliases are being used?
    .description
        *super* aggressive aliases, these are not suggessted to be used
    .example
        PS> Get-ProfileAggressiveItem | Fw
    #>
    param ()
    $meta = [ordered]@{}
    $meta['Alias'] = Get-Alias -Name 's', 'cl', 'f', 'cd' -ea silentlycontinue -Scope global

    $meta['Types'] = @(
        'psco'
    ) | ForEach-Object {
        $typeInstance = $_ -as 'type'
        [pscustomobject]@{
            Name = $_
            Type = $typeInstance ?? '$null'
        }
    }
    [PSCustomObject]$meta
}

& {
    $splatAlias = @{
        Scope       = 'global'
        ErrorAction = 'Ignore'
    }

    Remove-Alias -Name 'cd'
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Description 'A modern "cd"'
    Set-Alias @splatAlias -Name 's'  -Value Select-Object   -Description 'aggressive: to override other modules'
    Set-Alias @splatAlias -Name 'cl' -Value Set-Clipboard   -Description 'aggressive: set clip'

    if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
        New-Alias -Name 'f ' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    }

    Remove-Alias 'cd' -Scope global -Force
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Scope global -Description 'Personal Profile for easier movement'
    # For personal profile only. Maybe It's too dangerous,
    # should just use 'go' instead? It's not in the actual module
    # Usually not a great idea, but this is for a interactive command line profile

    $Profile | Add-Member -NotePropertyName 'NinProfileMainEntryPoint' -NotePropertyValue $PSCommandPath -ea SilentlyContinue
    $historyLists = Get-ChildItem -Recurse "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine" -Filter '*_history.txt'
    $Profile | Add-Member -NotePropertyName 'PSReadLineHistory' -NotePropertyValue $historyLists -ErrorAction SilentlyContinue

    $Accel = [PowerShell].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $Accel::Add('psco', [System.Management.Automation.PSObject])
    # expected values:
    # "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    # "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\Visual Studio Code Host_history.txt"



    # $MyInvocation.MyCommand.ModuleName
    # $MyInvocation.MyCommand.Name
    # $MyInvocation.PSScriptRoot
    # $MyInvocation.PSCommandPath
    # $PSScriptRoot
    # $PSCommandPath

}

if ($__ninConfig.UsePSReadLinePredict) {
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    catch {
        Write-Error 'Failed: -PredictionSource History'
    }
}
if ($__ninConfig.UsePSReadLinePredictPlugin) {
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    catch {
        Write-Error 'Failed: -PredictionSource HistoryAndPlugin'
    }
}



if ($false -and 'ask for command equiv') {
    $setPSReadLineOptionSplat = @{
        ContinuationPrompt            = '    '
        HistoryNoDuplicates           = $true
        AddToHistoryHandler           = 'Func<string,Object>'
        CommandValidationHandler      = '<Action[CommandAST]>'
        MaximumHistoryCount           = 9999999
        HistorySearchCursorMovesToEnd = $true
        MaximumKillRingCount          = 999999
        ShowToolTips                  = $true
        ExtraPromptLineCount          = 1
        CompletionQueryItems          = 30
        DingTone                      = 3
        DingDuration                  = 2
        BellStyle                     = 'Visual'
        WordDelimiters                = ', '
        HistorySearchCaseSensitive    = $true
        HistorySaveStyle              = 'SaveIncrementally'
        HistorySavePath               = 'path'
        AnsiEscapeTimeout             = 4
        PromptText                    = 'PS> '
        PredictionSource              = 'History'
        PredictionViewStyle           = 'ListView'
        Colors                        = @{}
    }
    Set-PSReadLineOption @setPSReadLineOptionSplat
}

# Set-PSReadLineOption -ContinuationPrompt '    ' -HistoryNoDuplicates -AddToHistoryHandler 'Func<string,Object>' -CommandValidationHandler '<Action[CommandAST]>' -MaximumHistoryCount 9999999 -HistorySearchCursorMovesToEnd -MaximumKillRingCount 999999 -ShowToolTips -ExtraPromptLineCount 1 -CompletionQueryItems 30 -DingTone 3 -DingDuration 2 -BellStyle Visual -WordDelimiters ', ' -HistorySearchCaseSensitive -HistorySaveStyle SaveIncrementally -HistorySavePath 'path' -AnsiEscapeTimeout 4 -PromptText 'PS> ' -PredictionSource History -PredictionViewStyle ListView -Colors @{}
<#

    [section]: Environment Variables

#>
<#
    [section]: NativeApp Env Vars

- fd customization: <https://github.com/sharkdp/fd#integration-with-other-programs>
- fd-autocompleter reference: <https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd>
- fzf keybindings <https://github.com/junegunn/fzf#key-bindings-for-command-line>

#>
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_OPTS = '--ansi --no-height'
$Env:FZF_CTRL_T_COMMAND = "$Env:FZF_DEFAULT_COMMAND"

$env:path = $env:Path, 'C:\Program Files\Git\usr\bin' -join ';'


<#
    [section]: Explicit Import Module
#>
# local dev import path per-profile
Write-Debug "Add module Path: $($Env:Nin_PSModulePath)"
if (Test-Path $Env:Nin_PSModulePath) {
    # don't duplicate, and don't use Sort -Distinct, because that alters priority

    if ($Env:Nin_PSModulePath -notin @($Env:PSModulePath -split ';' )) {
        $env:PSModulePath = $Env:Nin_PSModulePath, $env:PSModulePath -join ';'
    }
}
Write-Debug "New `$Env:PSModulePath: $($env:PSModulePath)"

& {
    $p = (Get-Item -ea stop (Join-Path  $Env:Nin_Dotfiles 'powershell\Ninmonkey.Profile\Ninmonkey.Profile.psd1' ))
    Write-Debug "Import-Module: '$p'"
    Import-Module -Name $p -Force #-ea stop
}

<#
    [section]: Optional imports
#>
& {
    # Soft/Optional Requirements
    $OptionalImports = @(
        'ClassExplorer'
        'Pansies'
        'Dev.Nin'
        'Ninmonkey.Console'
        'Ninmonkey.Powershell'
        'PSFzf'
        # 'ZLocation'
    )
    $OptionalImports
    | Join-String -sep ', ' -SingleQuote -op 'Loading Modules:'
    | Write-Verbose

    $OptionalImports | ForEach-Object {
        Write-Debug "Import-Module: $_"
        Import-Module $_
    }
}

<#
    [section]: Optional Paths
#>
& {
    if ($__ninConfig.ImportGitBash) {
        $env:path = $env:Path, 'C:\Program Files\Git\usr\bin' -join ';'
    }
}

<#
    [section]: Chocolately
#>

# Chocolatey profile
& {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
}


<#
    [section]: Aliases
#>

New-Alias -Name 'CtrlChar' -Value Format-ControlChar -Description 'Converts ANSI escapes to safe-to-print text'
New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString

function Prompt {
    #
    Write-NinProfilePrompt
}

function prompt_verbose_debug {
    <#
    .synopsis
        verbose prompt to test term detection
    #>
    $chunk = @()
    $chunk += "`n`n"
    $chunk += (Get-Location).ToString()
    $template = "TermName: {0}`nIsVsCode: {1}`nIsPSIT: {2}"
    $chunk += $template -f @(
        $__ninConfig.Terminal.CurrentTerminal
        ($__ninConfig.Terminal.IsVSCode) ? 'Y' : 'N'
        ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) ? 'Y' : 'N'
    ) | Join-String
    $chunk += '🐒> '
    $chunk -join "`n"
}

# $prompt2 = function:prompt
# $prompt2


# Get-Module Microsoft.PowerShell.Utility | Where-Object {
#     $isActive = $false

#     $_ | Where-Object {

#         $isActive = $false;
#         $_.ExportedCommands.GetEnumerator()
#         | ForEach-Object {
#             if ('join-string' -in $_.Key) { $isActive = $true; return; }   #{ getenumerator | % Key | rg -i 'join-string'
#         }
#     }
#     return $isActive

# }

New-Text -fg gray70 -bg gray30 'next
    - if vscode:
        - [ ] prompt name: "VS Code Pwsh>"

    - if vscode as PSIT
        - [ ] prompt name: "VS Code Integrated Terminal>"
        - [ ] editor services import
        - [ ] and that string import

    - if wt
        - [ ] auto-import: Import-NinKeys

    - if admin:
        - [ ] skip import-keys
        - [ ] red prompt


------------------

first:
    [5] dotfile backup
    [1] move: Write-NinPrompt to module: profile
    [2] colorize breadcrumbs using gradient
    [3] editfunction jump to line number
    [4] ripgreb bat env dotfiles load

[1]
    alt+enter/ctrl+enter hotkeys for newline

[2]
    dotfiles missing
        [rg] bat? less?


$seg = 4
Get-Gradient -StartColor gray20 -EndColor gray50 -Width $seg -ColorSpace Hsl

'
| Join-String
