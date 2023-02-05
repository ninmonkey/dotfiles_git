# /h:/ vscode only
"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath )
"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
return


























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

$splat_Show = @{
    PassThru = $true
}
@(
    Set-Alias @splat_Show 'ls' -Value 'Get-ChildItem' # unless nin is imported
    Set-Alias @splat_Show 'sc' -Value 'Set-Content' # unless nin is imported
    Set-Alias @splat_Show 'cl' -Value 'Set-ClipBoard'
    Set-Alias @splat_Show 'gcl' -Value 'Get-ClipBoard'
    Set-Alias @splat_Show 'impo' -Value 'Import-Module'
) | Join-String -sep ', ' -SingleQuote -op 'set alias ' DisplayName
| Join-String -op "SetBy: '<${PSSCommandPath}>'`n" { $_ }


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



"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>