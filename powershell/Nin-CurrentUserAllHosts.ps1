#Requires -Version 7.0.0
using namespace PoshCode.Pansies
using namespace System.Collections.Generic #
using namespace System.Management.Automation # [ErrorRecord]

Import-Module Dev.Nin -Force

# Keep colors when piping Pwsh in 7.2
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::Ansi


<#
    [section]: Seemingly Sci imports
#>
if ($true -and $__ninConfig.LogFileEntries) {
    $strToLog = "{0}`n{1}" -f @(
        # "㏒ `naka $($PSCommandPath)""
        #  "㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1]`naka $($PSCommandPath)''
        '㏒ => [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1]'
        '   aka: {0} ' -f @(
            $PSCommandPath | To->RelativePath -BasePath $Env:Nin_Dotfiles
        )
    )



    #$__ninConfig.Import.SeeminglyScience) {
    # refactor: temp test to see if it loads right
    if ($__ninConfig.LogFileEntries) {
        $strToLog | Write-Warning
        Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> seemSci'
    }
}

if ($true) {
    # some reason import for sci's module requires full path, even with psmodule path
    $pathSeem = Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
    if ($pathSeem) {
        Import-Module pslambda
        Import-Module (Get-Item -ea stop (Join-Path $PathSeem 'Utility.psm1'))
        Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
        Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
        Import-Module (Join-Path $PathSeem 'Utility.psm1') #-Force
    }
} else {
    $pathSeem = Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
    $Env:PSModulePath = $Env:PSModulePath, ';', (Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell') -join ''
    $Env:PSModulePath = $Env:PSModulePath, ';', (Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience') -join ''
    # Import-Module pslambda
    Import-Module Utility
    Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
    Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
}

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Dev.Nin'
}

<#
first: 🚀
    - [ ] ask about how to namespace enums?

    - [ ] step pipepline
        do { Set-Content @someExistingVar }.GetSteppablePipeline() and play with it

    - [ ] edit sci's bits to a _colorizeBits

#>


# Get-Command __doc__ | Join-String -op ' loaded?'
# see also: C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\buffer\2021-10\AddDocstring-Sketch\Add-Docstring-sketch-iter3.ps1
# try {
#     . Get-Item -ea stop (Join-Path $PSScriptRoot 'Add-DocstringMemberInfo.ps1')
# }
# catch {
#     Write-Host '♥ :('
#     Write-Host '♥ :( Failed to import __doc__'
#     Warn🛑 '♥ :( Failed to import __doc__, falling back on no-op polyfill'
#     # Set-Alias '__doc__' -Value '__noop__' -Description 'failback for silent errors on documentation, as an experiment' -ea silentlyignore -Force
# }
# Get-Command __doc__ | Join-String -op ' loaded?'
# . Get-Item -ea stop (Join-Path $PSScriptRoot 'Add-DocstringMemberInfo.ps1')
# Get-Command __doc__ | Join-String -op ' loaded?'
function __noop__ {
    <#
    .synopsis
        "polyfill" air qoute, it's a stub that just consumes all pipes or arguments
    .example
        # none of these will error
        0..4 | __noop__
        0..4 | __noop__ 'foo'
        __noop__ 'foo'
        __noop__ -foo bar
    #>
    param()
}

$__warn = $false
function Warn {
    [cmdletbinding()]
    [Alias('Warn🛑')]
    param(
        [AllowEmptyCollection()]
        [AllowNull()]
        [Alias('Message', 'Warn')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if (! $__ninConfig.LogFileEntries) {
            return
        }

        # if (! $__ninConfig.debug.GlobalWarn) {
        if ($null -eq $InputObject) {
            return
        }
        if ($__ninConfig.debug.GlobalWarn ?? $__warn) {
            if ($InputObject) {
                $InputText | Write-Warning
            }
            return
        }
    }
}

if ($false) {

    'should not be required:'

    Remove-Module 'psfzf', 'psscripttools', 'zlocation' -ea silentlycontinue
    'psfzf', 'psscripttools', 'zlocation' | Join-String -sep ', ' -op 'Removing: ' | Warn🛑
}

# next: refactor as 'ThrottledTask's

if (!(Test-Path (Get-Item Temp:\complete_gh.ps1))) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Generate "complete_gh.ps1"'
    gh completion --shell powershell | Set-Content -Path temp:\complete_gh.ps1
} else {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> complete_gh.ps1'
    . (Get-Item Temp:\complete_gh.ps1)
}


# Measure-Command { & {
#   gh completion --shell powershell | Set-Content -Path temp:\complete_gh.ps1
#   . (gi Temp:\complete_gh.ps1)
# } }
# Measure-Command { & {
#   Invoke-Expression -Command $(gh completion -s powershell | Out-String)
# } }

# try {
#     . Get-Item (Join-Path $PSScriptRoot 'Nin-OneDriveFix.ps1')
# } catch {
#     Warn🛑 'Failed parsing: Nin-OneDriveFix.ps1'
# }
# $PSDefaultParameterValues['Import-Module:DisableNameChecking'] = $true # temp dev hack
# $PSDefaultParameterValues['Import-Module:ErrorAction'] = 'continue'
# $ErrorActionPreference = 'continue'

# Warn🛑 "run --->>>> '$PSCommandPath'"

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\'
    $Env:PSModulePath

) -join ';'

if ($OneDrive.Enable_MyDocsBugMapping) {
    $Env:PSModulePath = @(
        $Env:PSModulePath
        'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell'
    ) -join ';'
}

<#
    - initalizes '$__ninConfig'
#>
if ($false -and 'future') {
    $__rConfigf ??= @{} | __doc__ "`$__ninConfig initializes here '$PSCommandPath'"
    # fn __doc__ will auto-collect filepaths automatically

    @'
    $__ninConfig.LogFileEntries
    later I can run

        help($__ninConfig)  | __doc__ "`$__ninConfig initializes here: '$PSCommandPath'"
        help($__ninConfig)  | __doc__ "`$__ninConfig initializes'"

        help($__ninConfig.SomeFeature)
'@
}


$script:__ninConfig ??= @{
    # HackSkipLoadCompleters     = $true
    EnableGreetingOnLoad       = $true
    UseAggressiveAlias         = $true
    ImportGitBash              = $true  # __doc__: Include gitbash binaries in path+gcm
    UsePSReadLinePredict       = $true  # __doc__: uses beta PSReadLine [+Predictor]
    UsePSReadLinePredictPlugin = $false # __doc__: uses beta PSReadLine [+Plugin]
    Import                     = @{
        SeeminglyScience = $true
    }
    Config                     = @{
        PSScriptAnalyzerSettings2 = Get-Item -ea ignore 'C:\Users\cppmo_000\Documents\2020\dotfiles_git\vs code profiles\user\PSScriptAnalyzerSettings.psd1'
        PSScriptAnalyzerSettings  = Get-Item -ea ignore 'C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell\PSScriptAnalyzerSettings.psd1'
    }
    OnLoad                     = @{
        IgnoreImportWarning = $true # __doc__: Ignore warnings from any modules imported on profile first load
    }
    Prompt                     = @{
        # __doc__: Controls the look of your prompt, not 'Terminal'
        # __uri__: Terminal
        Profile                      = 'default' # __doc__: errorSummary | debugPrompt | bugReport | oneLine | twoLine | spartan | default
        # Profile = 'default' #
        ForceSafeMode                = $false
        IncludeGitStatus             = $false # __doc__: Enables Posh-Git status
        PredentLineCount             = 1 # __doc__: number of newlines befefore prompt
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
} #| __doc__ 'root to user-facing configuration options, see files and __doc__ for more'

if ($env:NINProfileForceSafeMode) {
    $__ninConfig.Prompt.ForceSafeMode = $true
}
# $__ninConfig.Prompt.ForceSafeMode = $true

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> main body start'
if ($OneDrive.Enable_MyDocsBugMapping) {
    $__ninConfig.Config['PSScriptAnalyzerSettings'] = Get-Item -ea ignore 'C:\Users\cppmo_000\Skydrive\Documents\2021\dotfiles_git\powershell\PSScriptAnalyzerSettings.psd1'
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
    } else {
        Import-Module @importModuleSplat
    }
}

New-Alias 'Repl->PtPy' -Value 'ptpython' -Description 'repl from: <https://github.com/prompt-toolkit/ptpython>'
New-Alias 'rel' -Value '_reloadModule' -ea ignore
New-Alias 'resolveCmd' -Value 'Resolve-CommandName' -ea ignore
New-Alias 'Join-Hashtable' -Value 'Ninmonkey.Console\Join-Hashtable' -Description 'to prevent shadowing by PSSCriptTools'
New-Alias -ea ignore -Name 'DismSB' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'sci''s SB to Expressions module'
New-Alias -ea ignore -Name 'Sci->Dism' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'tags: Sci,DevTool; sci''s SB to Expressions module'
New-Alias -ea ignore -Name 'Dev->SBtoDismExpression' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'tags: Sci,DevTool; sci''s SB to Expressions module'
& {
    $parent = (Get-Process -Id $pid).Parent.Name
    if ($parent -eq 'code') {
        $__ninConfig.Terminal.CurrentTerminal = 'code'
        $__ninConfig.Terminal.IsVSCode = $true
    } elseif ($parent -eq 'Code - Insiders') {
        $__ninConfig.Terminal.CurrentTerminal = 'code_insiders'
        $__ninConfig.Terminal.IsVSCode = $true
    } elseif ($parent -eq 'windowsterminal') {
        # preview still uses this name
        $__ninConfig.Terminal.CurrentTerminal = 'windowsterminal'
    }
    if ($pseditor) {
        # previously was: if (Get-Module 'PowerShellEditorServices*' -ea ignore) {
        # Test whether term is running, in order to run EditorServicesCommandSuite
        $__ninConfig.Terminal.IsVSCodeAddon_Terminal = $true
    }
    if ($psEditor) {
        Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> EditorServicesCommandSuite'
        $escs = Import-Module EditorServicesCommandSuite -PassThru
        if ($null -ne $escs -and $escs.Version.Major -lt 0.5.0) {
            Import-EditorCommand -Module EditorServicesCommandSuite
        }
    }
    # if ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) {
    #     Import-Module EditorServicesCommandSuite
    # Set-PSReadLineKeyHandler -Chord "$([char]0x2665)" -Function AddLine # work around for shift+enter pasting a newline
    # }
}


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
# set vars if not already existing
$Env:TempNin ??= "$Env:UserProfile\SkyDrive\Documents\2021\profile_dump"
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
$env:NinNow = "$Env:Nin_Home"


# Env-Vars are all caps because some apps check for env vars case-sensitive
# double check that profile isn't failing to set the global env vars
$Env:LESS ??= '-R'
$ENV:PAGER ??= 'bat'
# $ENV:PAGER ??= 'less -R'
$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"

$Env:Pager ??= 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'

# now function:\help tests for the experimental feature and gcm on $ENV:PAger
$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args

$ENV:PAGER = 'bat'
$ENV:PYTHONSTARTUP = Get-Item -ea continue "${Env:Nin_Dotfiles}/cli/python/nin-py3-x-profile.py"
<#
bat
    --force-colorization --pager <command>
    --pager "Less -RF"
    #>




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


# 'Config: ', $__ninConfig | Join-String | Write-Debug
<#
check old config for settings
    <C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinSettings.ps1>

Shared entry point from:
    $Profile.CurrentUserAllHosts
aka
    $Env:UserProfile\Documents\PowerShell\profile.ps1

#>

<#

    [section]: VS ONLY


#>


<#

    [section]: $PSDefaultParameterValues

        details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Code-Venv:Infa'] = 'continue'    # test it off
$PSDefaultParameterValues['Install-Module:Verbose'] = $true
$PSDefaultParameterValues['New-Alias:ErrorAction'] = 'SilentlyContinue' # mainly for re-running profile in the same session
$PSDefaultParameterValues['Ninmonkey.Console\Get-ObjectProperty:TitleHeader'] = $true
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Ninmonkey.Console\Out-Fzf:OutVariable'] = 'fzf'
$PSDefaultParameterValues['Ninmonkey.Console\Out-Fzf:MultiSelect'] = $true
$PSDefaultParameterValues['Set-NinLocation:AlwaysLsAfter'] = $true
$PSDefaultParameterValues['Microsoft.PowerShell.Core\Get-Help:detailed'] = $true
$PSDefaultParameterValues['Get-Help:detailed'] = $true
$PSDefaultParameterValues['help:detailed'] = $true


<#
    [section]: $PSDefaultParameterValues

        But settings for dev.nin / meaning any of these could be obsolete
        because it's experimental

    todo future:
        - [ ] linter warn when parameter name isn't valid, like a code change, or datatype change
#>
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'

# $PSDefaultParameterValues['Dev.Nin\Invoke-VSCodeVenv:ForceMode'] = 'insiders' # < code | insiders >
# $PSDefaultParameterValues['Code-Venv:ForceMode'] = 'insiders' # < code | insiders >
# $PSDefaultParameterValues['Dev.Nin\Invoke-VSCodeVenv:infa']='ignore'
# Dev.Nin\Invoke-VSCodeVenv
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'
$PSDefaultParameterValues['Ninmonkey.Console\Get-:TitleHeader'] = $true # Was this a typo?
$PSDefaultParameterValues['Get-RandomPerSession:Verbose'] = $true
$PSDefaultParameterValues['Reset-RandomPerSession:Verbose'] = $true
$PSDefaultParameterValues['Invoke-GHRepoList:Infa'] = 'Continue'
# $PSDefaultParameterValues['ls:dir'] = $true
$PSDefaultParameterValues['_PeekAfterJoinLinesMaybe:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\_Peek-NewestItem:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\Peek-NewestItem:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\Pipe->Error:infa'] = 'Continue'
# $PSDefaultParameterValues['Dev.Nin\Pipe->*:infa'] = 'Continue'

# Import-Module Ninmonkey.Console

function _profileEventOnFinalLoad {
    <#
    minimal final function ran on end
    #>
    Write-Debug '$__ninConfig.EnableGreetingOnLoad'
    function _writeTodoGreeting {
        Get-Gradient -StartColor gray20 -EndColor gray50 -Width $seg -ColorSpace Hsl
        | Join-String
        Hr
        # h1 'Todo' | New-Text -fg yellow -bg magenta
        '🐵'
    }

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

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> final body'
}



if ($true) {
    # todo: now it should fully run in profile
    # $__innerStartAliases = Get-Alias # -Scope local
    $splatAlias = @{
        Scope       = 'global'
        ErrorAction = 'Ignore'
    }

    # todo:  # can I move this logic to profile? at first I thought there was scope issues, but that doesn't matter
    Remove-Alias -Name 'cd' -ea ignore
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Description 'A modern "cd"'
    Set-Alias @splatAlias -Name 's' -Value Select-Object -Description 'aggressive: to override other modules'
    Set-Alias @splatAlias -Name 'cl' -Value Set-Clipboard -Description 'aggressive: set clip'
    Set-Alias @splatAlias -Name 'resCmd' -Value 'Resolve-CommandName' -Description '.'
    New-Alias @splatAlias 'CodeI' -Value code-insiders -Description 'quicker cli toggling whether to use insiders or not'
    # New-Alias 'jp' -Value 'Join-Path' -Description '[Disabled because of jp.exe]. quicker for the cli'
    New-Alias @splatAlias 'joinPath' -Value 'Join-Path' -Description 'quicker for the cli'
    New-Alias @splatAlias 'jp' -Value 'Join-Path' -Description 'quicker for the cli'

    if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
        New-Alias -Name 'f' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    }

    Remove-Alias 'cd' -Scope global -Force -ea ignore
    New-Alias @splatAlias -Name 'cd' -Value Set-NinLocation -Description 'Personal Profile for easier movement'
    # For personal profile only. Maybe It's too dangerous,
    # should just use 'go' instead? It's not in the actual module
    # Usually not a great idea, but this is for a interactive command line profile

    $Profile | Add-Member -NotePropertyName 'NinProfileMainEntryPoint' -NotePropertyValue $PSCommandPath -ea Ignore
    $Profile | Add-Member -NotePropertyName '$Profile' -NotePropertyValue (Get-Item $PSCommandPath) -ea Ignore
    $historyLists = Get-ChildItem -Recurse "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine" -Filter '*_history.txt'
    $historyLists = Get-ChildItem (Split-Path (Get-PSReadLineOption).HistorySavePath) *history.txt # captures both, might even help on *nix
    $Profile | Add-Member -NotePropertyName 'PSReadLineHistory' -NotePropertyValue $historyLists -ErrorAction Ignore
    $Profile | Add-Member -NotePropertyName 'PSDefaultParameterValues' -NotePropertyValue $PSCommandPath -ErrorAction Ignore

    # experimenting:
    $Accel = [PowerShell].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $Accel::Add('po', [System.Management.Automation.PSObject])
    $Accel::Add('obj', [System.Management.Automation.PSObject])
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

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> start PSReadLine'

<# play nice
(gcm 'Set-PSReadLineOption' | % Parameters | % keys) -contains 'PredictionViewStyle'
(gcm 'Set-PSReadLineOption' | % Parameters | % keys) -contains 'PredictionSource'
#>

$eaIgnore = @{
    ErrorAction = 'ignore'
}
if ($__ninConfig.UsePSReadLinePredict) {
    try {
        if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionSource') {
            Set-PSReadLineOption @eaIgnore -PredictionSource History # SilentlyContinue #stop
        }
        if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionViewStyle') {
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView # SilentlyContinue
        }
    } catch {
        Warn🛑 'Failed: -PredictionSource History & ListView'
    }
}
if ($__ninConfig.UsePSReadLinePredictPlugin) {
    try {
        if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionSource') {
            Set-PSReadLineOption @eaIgnore -PredictionSource HistoryAndPlugin
        }
        if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionViewStyle') {
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView
        }
    } catch {
        Warn🛑 'Failed: -PredictionSource HistoryAndPlugin'
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


# if ($false -and 'ask for command equiv') {
#     $setPSReadLineOptionSplat = @{
#         ContinuationPrompt            = '    '
#         HistoryNoDuplicates           = $true
#         AddToHistoryHandler           = 'Func<string,Object>'
#         CommandValidationHandler      = '<Action[CommandAST]>'
#         MaximumHistoryCount           = 9999999
#         HistorySearchCursorMovesToEnd = $true
#         MaximumKillRingCount          = 999999
#         ShowToolTips                  = $true
#         ExtraPromptLineCount          = 1
#         CompletionQueryItems          = 30
#         DingTone                      = 3
#         DingDuration                  = 2
#         BellStyle                     = 'Visual'
#         WordDelimiters                = ', '
#         HistorySearchCaseSensitive    = $true
#         HistorySaveStyle              = 'SaveIncrementally'
#         HistorySavePath               = 'path'
#         AnsiEscapeTimeout             = 4
#         PromptText                    = 'PS> '
#         PredictionSource              = 'History'
#         PredictionViewStyle           = 'ListView'
#         Colors                        = @{}
#     }
#     Set-PSReadLineOption @setPSReadLineOptionSplat
# }

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
$Env:PSModulePath = @(
    $Env:PSModulePath
    'C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell'
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell'
    $pathSeem
) | Join-String -sep ';'
Write-Debug "New `$Env:PSModulePath: $($env:PSModulePath)"

<#
    [section]: Optional imports
#>
# & {
$splatMaybeWarn = @{}

if ($__ninConfig.Module.IgnoreImportWarning) {
    $splatMaybeWarn['Warning-Action'] = 'Ignore'
    $splatMaybeWarn['Warning-Action'] = 'Continue'
}
# Soft/Optional Requirements
$OptionalImports = @(
    # 'Utility' # loaded above
    'ClassExplorer'
    'Pansies'
    # 'Dev.Nin'
    'Ninmonkey.Console'
    'Ninmonkey.Powershell'
    # 'Posh-Git'

    # 'PSFzf'
    # 'ZLocation'
)
# Warn🛑 'Disabled [Posh-Git] because of performance issues' # maybe the prompt function is in a recursive loop

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> optional imports start'
$OptionalImports
| Join-String -sep ', ' -SingleQuote -op '[v] Loading Modules:' | Write-Verbose


$OptionalImports | ForEach-Object {
    Write-Debug "[v] Import-Module: $_"
    Write-Warning "[v] Import-Module: $_"
    # Import-Module $_ @splatMaybeWarn -DisableNameChecking
    Import-Module $_ -wa continue -ea continue # -DisableNameChecking
}
# }

Import-Module Dev.Nin -DisableNameChecking
Import-Module posh-git
# finally "profile"
Import-Module Ninmonkey.Profile -DisableNameChecking

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Backup-VSCode() start'
}

# todo: ThrottledTask
Backup-VSCode -infa Continue
# & {

# currently, all profiles use utf8
Set-ConsoleEncoding Utf8 | Out-Null
if (!(Test-UserIsAdmin)) {
    Import-NinPSReadLineKeyHandler
    # Maybe also remove modules 'Dev.Nin', 'PSFzf', or PSReadLineBeta ?
}
# }

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Choco start'
}
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

$env:NinEnableToastDebug = $True

function Prompt {
    <#
    .synopsis
        directly redirect to real prompt. not profiled for performance at all
    .description
    #>
    Write-NinProfilePrompt
    # IsAdmin = Test-UserIsAdmin
}
function SafePrompt {
    "`nSafe> "
}

# ie: Lets you set aw breakpoint that fires only once on prompt
# $prompt2 = function:prompt  # easily invoke the prompt one time, for a debug breakpoint, that only fires once
# $prompt2}}
# New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Write-Debug
# New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Warn🛑
if ($__ninConfig.LogFileEntries) {
    New-Text "<-- '$PSScriptRoot' before onedrive mapping" -fg 'cyan'
    | ForEach-Object ToString | Warn🛑
}

if (! $OneDrive.Enable_MyDocsBugMapping) {
    _profileEventOnFinalLoad
}



# if (! (Get-Command 'Out-VSCodeVenv' -ea ignore)) {
#     Warn🛑 'Out-VSCodeVenv did not load!'
#     # $src = gi -ea ignore (gc 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1')
#     $src = Get-Item -ea ignore 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1'
#     if ($src) {
#         . $src
#     }
# }

Import-Module PsFzf
if (Get-Command Set-PsFzfOption -ea ignore) {
    # Set reverse hist fzf

    # Really needs filtering
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+shift+r'
    # 'Ctrl+r' | write-blue
    # | str prefix 'PsFzf: History set to '

    hr 1
    'keybind ↳ History set to ↳ '

    # 'Ctrl+r' | Write-Color blue
    # | str prefix ([string]@(
    #         'PsFzf:' | Write-Color gray60
    #         'keybind ↳ History set to ↳ '
    #     ))

    hr 1
}
if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> final invokevscode dotsource, should not exist '
}

# temp hack
if (! (Get-Command 'code-venv' -ea ignore) ) {
    Set-Alias 'code' 'code-insiders.cmd'
    # somehow didn't load, so do it now
    $src = Get-Item -ea ignore 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1'
    if ($src) {
        . $src
    }
    Set-Alias 'code' -Value 'Invoke-VSCodeVenv'
    $Value = (@(
            Get-Command -ea ignore -CommandType Application code-insiders.cmd
            Get-Command -ea ignore -CommandType Alias code.cmd
            Get-Command -ea ignore 'venv-code'
        ) | Select-Object -First 1)
    New-Alias 'code.exe' -Description 'Attempts to use "code-insiders.cmd", then "code.cmd", then "venv-code".' -Value $Value
    # try {
    #     . gi (join-path $PSScriptRoot 'Out-VSCodeVenv.ps1')
    # }
    # catch {
    #     Warn🛑 'Failed parsing: Out-VSCodeVenv.ps1'
    # }
}
if ($OneDrive.Enable_MyDocsBugMapping) {
    Remove-Module 'psfzf', 'psscripttools', 'zlocation'
    Set-Alias 'code' -Value 'Invoke-VSCodeVenv' -Force
    Push-Location 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell'
}

# New-Text "End <-- True end: '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Warn🛑

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] <-- end of file'
}


if ($false) {
    Get-PSDrive -PSProvider FileSystem
    | ForEach-Object {
        @(
            $l = @(
                Lookup -InputObject $_ -LiteralPropertyName Name
                Lookup -InputObject $_ -LiteralPropertyName Free
            ) | Merge-HashtableList
            $l

        )
    }
} else {
    Get-PSDrive -PSProvider FileSystem
    | ForEach-Object {
        [pscustomobject]@{
            Free = '{0,-6:n0}GB' -f ($_.Free / 1gb)
            Name = $_.Name
        }
    }
}
