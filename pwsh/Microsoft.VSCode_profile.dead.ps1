
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

Write-Warning "?? $PSCommandPath => Merge into 2021\dotfiles_git\powershell\profile.ps1"

if ($false -and 'to cleanup/delete') {
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
        "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning
    }
    [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


}
