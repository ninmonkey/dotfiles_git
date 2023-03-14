#Requires -Version 7.0.0
using namespace PoshCode.Pansies
using namespace System.Collections.Generic #
using namespace System.Management.Automation

$__miniConfig ??= @{
    LoadNinConsole = $true
    LoadNinDev     = $false
    MinImport      = $True
}

Set-Alias 'sc' -Value 'Set-Content'
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::Ansi

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\'
    $Env:PSModulePath
) -join ';'

if ($__miniConfig.LoadNinConsole) {
    Import-Module Ninmonkey.Console -DisableNameChecking -wa ignore
}
if ($__miniConfig.DevNin) {
    Import-Module Dev.Nin -DisableNameChecking -wa ignore
}
Enable-NinCoreAlias

$Env:RIPGREP_CONFIG_PATH = (Get-Item 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\cli\ripgrep\.ripgreprc')


function _minProfile-importModule {
    <#
    .synopsis
        special sugar used for minimum profile import
    #>
    [Alias('imp')]
    [cmdletBinding()]
    param(
        [cmdletbinding()]
        [parameter(Position = 0)]
        [ArgumentCompletions('BasicModuleTemplate', 'CollectDotfiles', 'Dev.Nin', 'Jake.Pwsh.AwsCli', 'ModuleData', 'ninLog', 'Ninmonkey.Console', 'Ninmonkey.Factorio', 'Ninmonkey.Profile', 'Ninmonkey.TemplateText', 'Portal.Powershell', 'Powershell.Cv', 'Powershell.Jake', 'Template.Autocomplete')]
        [string[]]$Name,
        # Temporarily enable warnings
        [parameter()][switch]$AllowWarn,

        # force is default
        [parameter()][switch]$NotForce
    )

    $importModuleSplat = @{
        Name                = $Name
        DisableNameChecking = $true
        Scope               = 'global'
        Force               = $NotForce ? $false : $true
        Wa                  = $AllowWarn ? 'Continue' : 'Ignore'
    }

    Import-Module @importModuleSplat # or script, or doesn't matter?
}

function prompt {
    # minimal sugar for minprofile prompt
    @(
        "`n`n"
        (Get-Location)
        "`nMin> "

    ) -join ''
}
