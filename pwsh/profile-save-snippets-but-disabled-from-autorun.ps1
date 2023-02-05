throw 'inspect me'

# for vscode terminal integration, ctrl+ breaking  'FixShellIntegration_Clearscreen'
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -ScriptBlock {
    [Console]::Write("$([char]0x1b)]633;C`a")
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
} -Description 'used to fix ShellIntegration Clearscreen, the jump-to-prompt gutter icons from ansi escapes, src: <https://github.com/PowerShell/vscode-powershell/issues/4280#issuecomment-1325612979>' -BriefDescription 'Fix ClearScreen using ShellIntegration'



Write-Warning "Find func: 'Lookup()'"
'reached bottom'

$__dbgSuperVerbose = $true
if ($__dbgSuperVerbose) {
    $VerbosePReference = 'continue'
    $debugpreference = 'continue'
    $WarningPreference = 'continue'
    $PSDefaultParameterValues['Import-Module:Verbose'] = $true
    $PSDefaultParameterValues['Update-Module:Verbose'] = $true
    $PSDefaultParameterValues['Install-Module:Verbose'] = $true
    $PSDefaultParameterValues['get-Module:Verbose'] = $true

    $PSDefaultParameterValues['Import-Module:debug'] = $true
    $PSDefaultParameterValues['Update-Module:debug'] = $true
    $PSDefaultParameterValues['Install-Module:debug'] = $true
    $PSDefaultParameterValues['get-Module:debug'] = $true
}

$debugpreference = 'silentlycontinue'
$verbosepreference = 'silentlycontinue'
$debugpreference = 'silentlycontinue'
$VerbosePreference = 'silentlycontinue'
$WarningPreference = 'silentlycontinue'
$PSDefaultParameterValues.Remove('*:Debug')
$PSDefaultParameterValues.Remove('*:Verbose')

$PSDefaultParameterValues['Import-Module:Verbose'] = $true
$PSDefaultParameterValues['Install-Module:Verbose'] = $true

<#
Pwsh> $PROFILE | s *

AllUsersAllHosts              : C:\Program Files\PowerShell\7\profile.ps1
AllUsersCurrentHost           : C:\Program Files\PowerShell\7\Microsoft.VSCode_profile.ps1
CurrentUserAllHosts           : C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\profile.ps1
CurrentUserCurrentHost        : C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1
NinProfileMainEntryPoint      : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1
$Profile                      : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1
PSDefaultParameterValues      : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1
$Profile.PrevGlobalEntryPoint : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-PrevGlobalProfile_EntryPoint.ps1
Ninmonkey.Profile/*           : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Ninmonkey.Profile
Ninmonkey.Profile.psm1        : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Ninmonkey.Profile\Ninmonkey.Profile.psm1
Nin_Dotfiles                  : C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git
Nin_PSModules                 : C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github
Pwsh                          : {[Ninmonkey.Profile/*, C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Ninmonkey.Profile], [Nin_PSModules,
                                C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github], [PSModules, System.Object[]], [Nin_Dotfiles, C:\Users\cppmo
Git                           : {[Global, System.Collections.Hashtable]}
Venv                          : {[GlobalRoot, H:\env]}
VSCode                        : {[AppData, System.Collections.Hashtable]}
Length                        : 77
#>

if ($true) {
    #$__ninConfig.Import.SeeminglyScience) {
    # refactor: temp test to see if it loads right
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> seemSci'
    $pathSeem = Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
    if ($pathSeem) {
        Import-Module pslambda
        Import-Module (Join-Path $PathSeem 'Utility.psm1') #-Force
        Import-Module (Get-Item -ea stop (Join-Path $PathSeem 'Utility.psm1'))
        Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
        Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
    }
}

$env:PSModulePath += ';', (Get-Item "$Env:UserProfile\SkyDrive\Documents\PowerShell\Modules" -ea continue) -join ''
if ($OneDrive.Enable_MyDocsBugMapping) {
    $Env:Nin_Dotfiles = "$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git"
    Write-Warning 'WARNING: ㏒ [docs/dsfsdfaspowershell/profile.ps1] -> Nin-CurrentUserAllHosts'
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
}
else {
    # dotsource or symlink
    $Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> Nin-CurrentUserAllHosts'
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
}
