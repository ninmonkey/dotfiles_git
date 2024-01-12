# WhoAmI?
#   whoAmI? => $PROFILE.CurrentUserCurrentHost
#   pathAbs => $Env:UserProfile\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1
# $Env:PSModulePath = @(
#     # for:  'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Dotils.psm1'
#     gi -ea 'stop' 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules'
#     $Env:PSModulePath
# ) | Join-String -sep ([IO.Path]::PathSeparator)

Set-Alias 'Label' -value 'Ninmonkey.Console\Write-ConsoleLabel' -Force

# [2023.02] this is $PROFILE => entry point /w vscode + debug terminal
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
# $PROFILE.CurrentUserCurrentHost when in debug term

Import-CommandSuite -Verbose

$VerbosePreference = 'silentlycontinue'
$PSDefaultParameterValues.remove('import-module:verbose')

$src = (Get-Item -ea 'continue' (Join-Path $Env:Nin_Dotfiles 'pwsh/Microsoft.VSCode_profile.ps1'))
if(-not $src) { # both resolve to the same place
    $src = (Get-Item -ea 'continue' 'H:\data\2023\dotfiles.2023\pwsh\Microsoft.VSCode_profile.ps1')
}
. $src

return
## temp hardcoded fix
# this is the non-vscode-debug's version of AllHosts
# . '<file:///C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1>'
# . 'C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
# invoke dotfile location
#   ex: H:/data/2023/dotfiles.2023/pwsh/Microsoft.VSCode_profile.ps1
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

'refactor/bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) | Write-Warning


return
# invoke dotfile location
#   ex: H:/data/2023/dotfiles.2023/pwsh/profile.ps1

Write-Warning "$PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"
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





"enter ==> dotsourcing: ==> Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Warning

if ($VsCodeProfileCfg.AlwaysInvokeNormalProfile) {
    . ( Join-Path -Path "${Env:UserProfile}/skydrive/Documents/PowerShell" -ChildPath 'Microsoft.Powershell_profile.ps1'
        | Get-Item -ea 'continue' ) *>$null
}
"exit  <== dotsourcing: <== Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Warning

'Import: => Import-CommandSuite ... ' | Write-Verbose
Import-CommandSuite

"exit  <== Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}'" | Write-Warning
Write-Warning "$PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"




if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

$VerbosePreference = 'silentlycontinue'
$PSDefaultParameterValues.remove('import-module:verbose')
