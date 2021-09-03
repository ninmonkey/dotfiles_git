#Requires -Version 7.0.0
using namespace PoshCode.Pansies
using namespace System.Collections.Generic #
using namespace System.Management.Automation # [ErrorRecord]
# $PSDefaultParameterValues['Import-Module:DisableNameChecking'] = $true # temp dev hack
# $PSDefaultParameterValues['Import-Module:ErrorAction'] = 'continue'
# $ErrorActionPreference = 'continue'

$__ninConfig ??= @{
    # HackSkipLoadCompleters     = $true
    EnableGreetingOnLoad       = $true
    UseAggressiveAlias         = $true
    ImportGitBash              = $true  # __doc__: Include gitbash binaries in path+gcm
    UsePSReadLinePredict       = $true  # __doc__: uses beta PSReadLine [+Predictor]
    UsePSReadLinePredictPlugin = $false # __doc__: uses beta PSReadLine [+Plugin]
    OnLoad                     = @{
        IgnoreImportWarning = $true # __doc__: Ignore warnings from any modules imported on profile first load
    }
    Prompt                     = @{
        # __doc__: Controls the look of your prompt, not 'Terminal'
        # __uri__: Terminal
        Profile                      = 'default'    # __doc__: default | debugPrompt | Spartan
        IncludeGitStatus             = $false # show git branch, files changed, etc?
        PredentLineCount             = 1
        IncludePredentHorizontalLine = $false
        BreadCrumb                   = @{
            MaxCrumbCount    = -1 # __doc__: default is 3. Negative means no limit
            CrumbJoinText    = ' '
            CrumbJoinReverse = $true
            ColorStart       = '#CD919E' # __doc__: default is random. the most significant bit of breadcrumb
            ColorEnd         = '#454545' # __doc__: default is random. the least significant bit of breadcrumb

        }
    }
    Terminal                   = @{
        # __doc__: Detects or affects the environment, not 'Prompt'
        # __uri__: Prompt
        <#
        Terminal.CurrentTerminal = <code | 'Code - Insiders' | 'windowsterminal' | ... >
        Terminal.IsVsCode = <bool> # true when code or code insiders
        Terminal.IsVSCodeAddon_Terminal = <bool> # whether it's the addon debug term, or a regular one
        Terminal.ColorMode = [PoshCode.Pansies.ColorMode]

        others terminals:
            pwsh7 from start -> comes up as 'explorer'
            cmd /C Pwsh -> comes up as 'cmd'

        #>
        ColorBackground        = '#2E3440' # defer typing until later?
        CurrentTerminal        = (Get-Process -Id $pid).Parent.Name # cleaned up name below
        IsVSCode               = $false # __doc__: this is a VS Code terminal
        IsVSCodeAddon_Terminal = $false # __doc__: this is a [vscode-powershell] extension debug terminal
        #IsAdmin = Test-UserIsAdmin # __doc__: set later to delay load. very naive test. just for styling
    }
    IsFirstLoad                = $true

}


function TestError {
    <#
    .synopsis
        shortcut for the cli: list error counts, first error, and autoclear
    .description
        .

    #>
    [Alias('Err?')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # DoNotClear error variable
        [Parameter()][switch]$AlwaysClear,
        # first X
        [Parameter(Position = 0)][int]$Limit = 1

    )
    end {
        $script:__moduleMetaData_DidError_PrevCount ??= 0 # Gross, but module itself is
        $Template = @'


{2}
errors: {0}, new {1}
'@
        # forced to be in user scope to access $error, I think.
        $curCount = $error.count
        $delta = $curCount - $script:__moduleMetaData_DidError_PrevCount
        $script:__moduleMetaData_DidError_PrevCount = $curCount

        $i++
        $c = @{
            errorFg     = '#E7B3B3'
            errorBg     = '#802D2D'
            normalFg    = '#B88591'
            normalFgDim = '#534C55'
            # errorBg = 80
            #E75252
            #E75252
            # errorBg = '#BED5BD'
        }

        $PSBoundParameters | Format-Table | Out-String | Write-Debug

        $exceptionText = $error
        # | Select-Object -First $Limit
        | ForEach-Object {
            $curErr = $_
            Write-Debug "Handling: $curError"
            $curErr.ToString() | ShortenString 90 | ForEach-Object {
                if ($_ -eq 0) {
                    $_ | New-Text -fg $c.normalFgDim
                }
                else {
                    $_ | New-Text -fg $c.normalFg
                }
            }
            | New-Text -fg $c.errorFg -bg $c.errorBg | ForEach-Object tostring
        } | Select-Object -First $Limit


        $Template -f @(
            $curCount
            $delta
            $exceptionText
        )
        # "Did $i"
        # $global:err = $global:error

        if ( $AlwaysClear) {
            $error.clear()
        }
    }
}


& {


    $colorA = '#CD919E'
    $colorB = '#454545'
    ($__ninConfig.Prompt.BreadCrumb).ColorStart = $colorB
    ($__ninConfig.Prompt.BreadCrumb).ColorEnd = $colorA
    ($__ninConfig.Prompt.BreadCrumb).CrumbJoinReverse = $false
    $__ninConfig.Prompt.BreadCrumb.CrumbJoinText = ' ▸ ' | New-Text -fg 'gray35'
}

<#
npm /w node.js
    https://docs.npmjs.com/try-the-latest-stable-version-of-npm#upgrading-on-windows
$toadd = Get-Item -ea Continue "$Env:AppData\Npm"
$Env:path = $toAdd, $Env:path -join ';'
#>


function _reRollPrompt {
    # reset vars used when random fallbacks
    ($__ninConfig.Prompt.BreadCrumb).ColorStart = $null
    ($__ninConfig.Prompt.BreadCrumb).ColorEnd = $null
    Reset-RandomPerSession -Name 'prompt.crumb.colorBreadEnd', 'prompt.crumb.colorBreadStart'
}

<#
env vars to check
'ChocolateyInstall', 'ChocolateyToolsLocation', 'FZF_CTRL_T_COMMAND', 'FZF_DEFAULT_COMMAND', 'FZF_DEFAULT_OPTS', 'HOMEPATH', 'Nin_Dotfiles', 'Nin_Home', 'Nin_PSModulePath', 'NinNow', 'Pager', 'PSModulePath', 'WSLENV', 'BAT_CONFIG_PATH', 'RIPGREP_CONFIG_PATH', 'Pager', 'PSMODULEPATH'
#>
function _reloadModule {
    # reload all dev modules in my profile's scope
    param(
        # Temporarily enable warnings
        [parameter()][switch]$AllowWarn
    )
    # quickly reload my modules for dev
    $importModuleSplat = @{
        # Name = 'Ninmonkey.Console', 'Dev.nin'
        Name  = _enumerateMyModule # 'Dev.Nin', 'Ninmonkey.Console', 'Ninmonkey.Powershell', 'Ninmonkey.Profile'
        Force = $true
    }

    # Ignore warnings, allow errors
    if (!$AllowWarn) {
        Import-Module @importModuleSplat 3>$null
    }
    else {
        Import-Module @importModuleSplat
    }
}

New-Alias 'rel' -Value '_reloadModule' -ea ignore
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
    if ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) {
        Import-Module EditorServicesCommandSuite
        Set-PSReadLineKeyHandler -Chord "$([char]0x2665)" -Function AddLine # work around for shift+enter pasting a newline
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
if ($false) {
    "`e[96mBegin: -->`e[0m'$PSScriptRoot'" | Write-Host
}

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
$PSDefaultParameterValues['Install-Module:Verbose'] = $true
$PSDefaultParameterValues['Ninmonkey.Console\Get-ObjectProperty:TitleHeader'] = $true


<#

    [section]: $PSDefaultParameterValues

        But settings for dev.nin / meaning any of these could be obsolete
        because it's experimental
#>
$PSDefaultParameterValues['Ninmonkey.Console\Get-:TitleHeader'] = $true
$PSDefaultParameterValues['Get-RandomPerSession:Verbose'] = $true
$PSDefaultParameterValues['Reset-RandomPerSession:Verbose'] = $true

<#
    [section]: Nin.* Environment Variables


## Rationale for '$Env:2021' or '$Env:Now'

    verses using a profile-wide '$Nin2021'

    When using filepath parames like
        $x | copy-item -Destination '$NinNow\something

    Tab completion does not complete. but environment variables will.
    This means you have to  remember exact filepaths.

    Using Env vars allows typing:

        -dest $env:Nin2021\*bug'

        which resolves to
            'C:\Users\cppmo_000\Documents\2021\reporting_bugs\


#>
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
$env:NinNow = Get-Item $Env:Nin_Home


$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"

$Env:Pager = 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'
$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args


# Import-Module Ninmonkey.Console

function _profileEventOnFinalLoad {
    function _writeTodoGreeting {

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
        Hr
        # h1 'Todo' | New-Text -fg yellow -bg magenta
        '🐵'
    }
    Backup-VSCode -infa Continue

    if ($__ninConfig.EnableGreetingOnLoad) {
        _writeTodoGreeting
    }

    if (
        ((Get-Location).Path -eq (Get-Item "$Env:Userprofile" )) -and
        $__ninConfig.Terminal.IsVSCode -and
        $__ninConfig.IsFirstLoad
    ) {
        # if Vs Code didn't set a directory, fallback to pwsh
        Set-Location "$Env:UserProfile/Documents/2021/Powershell"

    }
    "FirstLoad? $($__ninConfig.IsFirstLoad)" | Write-Host -fore green

    $__ninConfig.IsFirstLoad = $false

}


function Get-ProfileAggressiveItem {
    <#
    .synopsis
        todo: refactor into profile. Which *super* aggressive aliases are being used?
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

if ($true) {
    # $__innerStartAliases = Get-Alias # -Scope local
    $splatAlias = @{
        Scope       = 'global'
        ErrorAction = 'Ignore'
    }

    # todo:  # can I move this logic to profile? at first I thought there was scope issues, but that doesn't matter
    Remove-Alias -Name 'cd' -ea ignore
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Description 'A modern "cd"'
    Set-Alias @splatAlias -Name 's'  -Value Select-Object   -Description 'aggressive: to override other modules'
    Set-Alias @splatAlias -Name 'cl' -Value Set-Clipboard   -Description 'aggressive: set clip'
    New-Alias 'CodeI' -Value code-insiders -Description 'quicker cli toggling whether to use insiders or not'
    # New-Alias 'jp' -Value 'Join-Path' -Description '[Disabled because of jp.exe]. quicker for the cli'
    New-Alias 'joinPath' -Value 'Join-Path' -Description 'quicker for the cli'

    if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
        New-Alias -Name 'f ' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    }

    Remove-Alias 'cd' -Scope global -Force
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Scope global -Description 'Personal Profile for easier movement'
    # For personal profile only. Maybe It's too dangerous,
    # should just use 'go' instead? It's not in the actual module
    # Usually not a great idea, but this is for a interactive command line profile

    $Profile | Add-Member -NotePropertyName 'NinProfileMainEntryPoint' -NotePropertyValue $PSCommandPath -ea SilentlyContinue
    # $historyLists = Get-ChildItem -Recurse "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine" -Filter '*_history.txt'
    $historyLists = Get-ChildItem (Split-Path (Get-PSReadLineOption).HistorySavePath) *history.txt # captures both, might even help on *nix
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
    if ($false) {
        # Neither way was dynamically capturing mine, I had hoped local scope  would be good enough.
        $deltaAliasList = Get-Alias #-Scope local
        | Where-Object { $_.Name -notin $__innerStartAliases.Name }

        $deltaAliasList | Sort-Object | Join-String -sep "`n" {
            "Alias: $($_.Name)" | New-Text -fg pink
        }
    }


}

if ($__ninConfig.UsePSReadLinePredict) {

    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    catch {
        Write-Warning 'Failed: -PredictionSource History'
    }
}
if ($__ninConfig.UsePSReadLinePredictPlugin) {
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    catch {
        Write-Warning 'Failed: -PredictionSource HistoryAndPlugin'
    }
}

if ($true) {
    <#
    AddLine
        moves to next line, bringing any remaining text with it
    AddLineBelow
        Adds and moves to next line, leaving text where it was.
    #>
    Get-PSReadLineKeyHandler -Bound -Unbound | Where-Object key -Match 'Enter|^l$' | Write-Debug
    Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
    Set-PSReadLineKeyHandler -Chord 'ctrl+enter' -Function InsertLineAbove
    Set-PSReadLineOption -ContinuationPrompt ((' ' * 4) -join '')
    # Set-PSReadLineOption -ContinuationPrompt (' ' * 4 | New-Text -fg gray80 -bg gray30 | ForEach-Object tostring )
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

$env:path += @(
    'C:\bin_nin\SysinternalsSuite\'
    <#
    [section]: Optional Paths

        add git-bash on windows
    #>

    if ($__ninConfig.ImportGitBash) {
        'C:\Program Files\Git\usr\bin'
    }


) | Join-String -Separator ';' -op ';'

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
$Env:PSModulePath = $Env:PSModulePath, 'C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell' -join ';'
Write-Debug "New `$Env:PSModulePath: $($env:PSModulePath)"

<#
    [section]: Optional imports
#>
# & {
$splatMaybeWarn = @{}

if ($__ninConfig.Module.IgnoreImportWarning) {
    $splatMaybeWarn['Warning-Action'] = 'Ignore'
}
# Soft/Optional Requirements
$OptionalImports = @(
    'ClassExplorer'
    'Pansies'
    'Dev.Nin'
    'Ninmonkey.Console'
    'Ninmonkey.Powershell'
    'PSFzf'
    'Posh-Git'
    # 'ZLocation'
)
$OptionalImports
| Join-String -sep ', ' -SingleQuote -op '[v] Loading Modules:' | Write-Verbose

$OptionalImports | ForEach-Object {
    Write-Debug "[v] Import-Module: $_"
    Import-Module $_ @splatMaybeWarn -DisableNameChecking
}
# }


# finally "profile"
Import-Module Ninmonkey.Profile -DisableNameChecking
# & {

# currently, all profiles use utf8
Set-ConsoleEncoding Utf8 | Out-Null
if (!(Test-UserIsAdmin)) {
    Import-NinPSReadLineKeyHandler
    # Maybe also remove modules 'Dev.Nin', 'PSFzf', or PSReadLineBeta ?
}
# }

<#
    [section]: Chocolately
#>
& {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
}


<#
    [section]: Aliases

        see Ninmonkey.Profile.psm1
#>

function Prompt {
    <#
    .synopsis
        directly redirect to real prompt. not profiled for performance at all
    .description
    #>
    Write-NinProfilePrompt
    # IsAdmin = Test-UserIsAdmin
}


# ie: Lets you set aw breakpoint that fires only once on prompt
# $prompt2 = function:prompt  # easily invoke the prompt one time, for a debug breakpoint, that only fires once
# $prompt2

_profileEventOnFinalLoad
New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Write-Debug
