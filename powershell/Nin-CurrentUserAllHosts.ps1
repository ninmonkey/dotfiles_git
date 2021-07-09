<#

Shared entry point from:
    $Profile.CurrentUserAllHosts
aka
    $Env:UserProfile\Documents\PowerShell\profile.ps1

#>

Write-Host "Begin: -> $PSScriptRoot"

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
        'ZLocation'
    )
    $OptionalImports
    | Join-String -sep ', ' -SingleQuote -op 'Loading Modules:'
    | Write-Verbose
    $OptionalImports | ForEach-Object {
        Import-Module $_
    }
}


$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
$p = (Get-Item -ea stop (Join-Path  $Env:Nin_Dotfiles 'powershell\Ninmonkey.Profile\Ninmonkey.Profile.psd1' ))
Import-Module -Name $p

Write-Host "End: <-- $PSScriptRoot"
