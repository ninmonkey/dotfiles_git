using namespace PoshCode.Pansies
<#

start with, but remove most of:
    <C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinSettings.ps1>

<#
    [section]: default params

details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-Fzf:OutVariable'] = 'Fzf'
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'


<#
    [section]: Env Vars
#>

<#
    [section]: a
#>

<#
    [section]: a
#>

<#
    [section]: a
#>

<#
    [section]: a
#>

<#
    [section]: a
#>

<#
    [section]: a
#>

<#
    [section]: NativeApp Env Vars

- fd customization: <https://github.com/sharkdp/fd#integration-with-other-programs>
- fd-autocompleter reference: <https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd>
- fzf keybindings <https://github.com/junegunn/fzf#key-bindings-for-command-line>


#>
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_OPTS = '--ansi'
$Env:FZF_CTRL_T_COMMAND = "$Env:FZF_DEFAULT_COMMAND" # does this work?
$Nin_ModulePath = "$Env:UserProfile\Documents\2021\Powershell\My_Github"

$nin_dotfiles = @{
    Todo                   = 'rewrite from scatch. A Prediction Source could be neat.Or else just autocomplete prop dynames (dynamic completer if needed)'
    # PowershellCore         = $profile # redundant unless you want vscode vs normal
    PowerShellProfilesAll  = Get-Item 'C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell'
    Bat                    = Get-Item -ea SilentlyContinue "$Env:UserProfile\Documents\2020\dotfiles_git\bat\.batrc"
    RipGrep                = Get-Item -ea SilentlyContinue "$Env:UserProfile\Documents\2020\dotfiles_git\ripgrep\.ripgreprc"
    BashProfile            = 'nyi'
    WindowsTerminalPreview = Get-Item -ea silent 'C:\Users\cppmo_000\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'
    WindowsTerminal        = Get-Item -ea silent 'C:\Users\cppmo_000\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    vscode                 = @{
        ExtensionDir = Get-Item "$env:UserProfile\.vscode\extensions"
        User         = Get-Item "$env:appdata\Code\User\settings.json"
    }
    Git                    = @{
        GlobalIgnore = Get-Item $Env:UserProfile\Documents\2020\dotfiles_git\git\global_ignore.gitignore
    }
    PowerBI                = @{
        'ExternalToolsConfig' = Get-Item 'C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools'
    }

}


# dev import path per-profile
if (Test-Path $nin_env_vars.AddPSModulePath) {
    $env:PSModulePath = $env:PSModulePath, $nin_env_vars.AddPSModulePath -join ';'
}

$Env:Nin_EnvTestFromProfile = 'yes'
Export-ModuleMember -Variable 'nin_dotfiles'
Write-Host 'test, did env: set correctly?' -ForegroundColor red
