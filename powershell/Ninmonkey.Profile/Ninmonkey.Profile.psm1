<#

start with, but remove most of:
    C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinSettings.ps1

# details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-Fzf:OutVariable'] = 'Fzf'
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'
