<#

Shared entry point from:
    $Profile.CurrentUserAllHosts
aka
    $Env:UserProfile\Documents\PowerShell\profile.ps1

#>

# explicit color because it's before imports
"`e[96mBegin: -->`e[0m'$PSScriptRoot'"
| Write-Host

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

    [section]: Environment Variables

#>
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_OPTS = '--ansi'
$Env:FZF_CTRL_T_COMMAND = "$Env:FZF_DEFAULT_COMMAND" # does this work?

<#
    [section]: Nin.* Environment Variables
#>
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"

$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"

<#
    [section]: Explicit Import Module
#>
# local dev import path per-profile
Write-Debug "Add module Path: $($Env:Nin_PSModulePath)"
if (Test-Path $Env:Nin_PSModulePath) {
    $env:PSModulePath = $Env:Nin_PSModulePath, $env:PSModulePath -join ';'
}
Write-Debug "New `$Env:PSModulePath: $($env:PSModulePath)"

& {
    $p = (Get-Item -ea stop (Join-Path  $Env:Nin_Dotfiles 'powershell\Ninmonkey.Profile\Ninmonkey.Profile.psd1' ))
    Write-Debug "Import-Module: '$p'"
    Import-Module -Name $p -ea stop
}


<#
    [section]: Optional imports
#>
& {
    # Soft/Optional Requirements
    $OptionalImports = @(
        'chocolateyProfile'
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
    [section]: Aliases
#>

New-Alias -Name 'CtrlChar' -Value Format-ControlChar -Description 'Converts ANSI escapes to safe-to-print text'
New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan'
