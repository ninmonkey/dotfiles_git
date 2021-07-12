using namespace PoshCode.Pansies

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

# $Profile in VS Code directly runs this
$StringModule_DontInjectJoinString = $true # to fix psutil, see: https://discordapp.com/channels/180528040881815552/467577098924589067/750401458750488577

<#

    [section]: $PSDefaultParameterValues

        details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-Fzf:OutVariable'] = 'FzfSelected'
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'
$PSDefaultParameterValues['New-Alias:ErrorAction'] = 'SilentlyContinue' # mainly for re-running profile in the same session

<#
    [section]: Nin.* Environment Variables
#>
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"

$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"


& {
    $Profile | Add-Member -NotePropertyName 'NinProfileMainEntryPoint' -NotePropertyValue $PSCommandPath

    # Testing out differences
    # $Profile | Add-Member -NotePropertyName 'a1' -NotePropertyValue $MyInvocation.MyCommand.ModuleName
    # $Profile | Add-Member -NotePropertyName 'a2' -NotePropertyValue $MyInvocation.MyCommand.Name
    # $Profile | Add-Member -NotePropertyName 'a3' -NotePropertyValue $MyInvocation.PSScriptRoot
    # $Profile | Add-Member -NotePropertyName 'a4' -NotePropertyValue $MyInvocation.PSCommandPath
    # $Profile | Add-Member -NotePropertyName 'a5' -NotePropertyValue $PSScriptRoot
    # $Profile | Add-Member -NotePropertyName 'a6' -NotePropertyValue $PSCommandPath

}

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
    Import-Module -Name $p #-ea stop
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

[PoshCode.Pansies.RgbColor]::ColorMode = [PoshCode.Pansies.ColorMode]::Rgb24Bit


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

function Write-NinPrompt {
    <#
    .synopsis
        A dynamic prompt, that function:\prompt can always point to
    .description
        Does this excessively use the pipeline, and Join-Ytring when it's not necessary?
            Yes. To allow future experiments to be easier
            Performance cost here doesn't matter.
    .example
        PS>
    .notes
        .
    #>
    param (
    )

    function _Write-GitStatus {
        <#
        .synopsis

        #>
        $dir_git = Get-GitDirectory
        [bool]$isGetRepo = $null -ne $dir_git

        if (! $isGetRepo) {
            return
        }

        New-Text 'git' -ForegroundColor (Get-GitBranchStatusColor).ForegroundColor
    }
    function _Path-ToBreadCrumbs {

        param(
            # FormatMode
            [ValidateSet('Default')]
            [Parameter(Position = 0)]
            [string]$FormatMode = 'Default'
        )

        $crumbs = (Get-Location | ForEach-Object Path) -split '\\'
        switch ($FormatMode) {
            'a' {
                break
            }
            'b' {
                break
            }
            default {
                $gradient = Get-Gradient -StartColor gray40 -EndColor gray90 -Width 4
                $finalList = @(
                    $crumbs | Select-Object -First 1


                    ($crumbs | Select-Object -Skip 1)
                    | Select-Object -Last 3
                )


                $finalString = $finalList | ForEach-Object -Begin { $i = 0 ; } -Process {
                    New-Text -Object $_ -fg $gradient[$i++]
                }
                $finalString | Join-String -sep ' '
            }

        }
    }

    $segments = @(
        "`n"
        _Path-ToBreadCrumbs
        _Write-GitStatus
        "`n"
        '🐒> '
    )
    $segments | Join-String
}
function Prompt {
    Write-NinPrompt
}


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


$seg = 4
Get-Gradient -StartColor gray20 -EndColor gray50 -Width $seg -ColorSpace Hsl

'
| Join-String
