$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.MainEntry_VSCode = $PSCommandPath | Get-Item

'Import-CommandSuite ... ' | Write-Verbose
Import-CommandSuite -Verbose -Debug


# /h:/ vscode only
if ($global:__nin_enableTraceVerbosity) {  "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; }  [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

<#
$DescLoc = '. Source: {0}' -f @(
    $PSCommandPath | Join-String -DoubleQuote
)
$splat_Show = @{
    PassThru = $true
}
@(
    already set in <file:///H:\data\2023\dotfiles.2023\pwsh\src\Build-ProfileCustomMembers.ps1>
    Set-Alias 'fcc' 'ninmonkey.console\Format-ControlChar' -PassThru -Description "Format-ControlChar abbr. ${DescLoc}"
    Set-Alias 's' -Value 'Select-Object' -PassThru -Description "Select-Object abbr. ${DescLoc}"
    Set-Alias @splat_Show 'cl' -Value 'Set-ClipBoard'
    Set-Alias @splat_Show 'Cl' -Value 'Set-ClipBoard' -Description "Set Clipboard. ${DescLoc}"
    Set-Alias @splat_Show 'fromJson' -Value 'ConvertFrom-Json'
    Set-Alias @splat_Show 'gcl' -Value 'Get-ClipBoard'
    Set-Alias @splat_Show 'Gcl' -Value 'Get-ClipBoard' -Description "Get Clipboard. ${DescLoc}"
    Set-Alias @splat_Show 'impo' -Value 'Import-Module'
    Set-Alias @splat_Show 'Impo' -Value 'Import-Module' -Description "Impo. ${DescLoc}"
    Set-Alias @splat_Show 'Json' -Value 'ConvertTo-Json'
    Set-Alias @splat_Show 'ls' -Value 'Get-ChildItem'
    Set-Alias @splat_Show 'Ls' -Value 'Get-ChildItem' -Description "gci. ${DescLoc}"
    Set-Alias @splat_Show 'sc' -Value 'Set-Content'
    Set-Alias @splat_Show 'Sc' -Value 'Set-Content' -Description "set content. ${DescLoc}"
) | Join-String -sep ', ' -SingleQuote -op 'set alias ' DisplayName
| Join-String -op "SetBy: '<${PSSCommandPath}>'`n" { $_ }
#>


if ($global:__nin_enableTraceVerbosity) {  "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
return













<#

dead














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




if ($global:__nin_enableTraceVerbosity) { "enter ==> dotsourcing: ==> Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Debug }

if ($VsCodeProfileCfg.AlwaysInvokeNormalProfile) {
    . ( Join-Path -Path "${Env:UserProfile}/skydrive/Documents/PowerShell" -ChildPath 'Microsoft.Powershell_profile.ps1'
        | Get-Item -ea 'continue' ) *>$null
}
if ($global:__nin_enableTraceVerbosity) { "exit  <== dotsourcing: <== Pid: '${pid}' regularProfile; (from: Microsoft.VsCode_profile.ps1)" | Write-Warning }

if ($global:__nin_enableTraceVerbosity) {
    'Import: => Import-CommandSuite ... ' | Write-Verbose
}
Import-CommandSuite

if ($global:__nin_enableTraceVerbosity) {
    "exit  <== Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}'"
    | Write-Warning
}
if ($global:__nin_enableTraceVerbosity) {
    "$PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"
    | Write-Debug
}



if ($global:__nin_enableTraceVerbosity) {
"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning;
}
[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

#>