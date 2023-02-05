"enter ==> Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}'" | Write-Warning
# full restart of main pwsh profile: 2022-11-30
Write-Warning 'next: new PSModulePath'
'disabled,see {0}`n=> {1}' -f @(
    'H:/data/2021/pwsh_myDocs'
    | Join-String -DoubleQuote
    $PSCommandPath
    | Join-String -DoubleQuote
) | Write-Host -ForegroundColor blue

"exit  <== Profile: docs/Microsoft.VsCode_profile.ps1/ => Pid: '${pid}'" | Write-Warning


Set-Alias 'ls' -Value 'Get-ChildItem' # unless nin is imported
Set-Alias 'sc' -Value 'Set-Content' # unless nin is imported
# Set-Alias 'Join-Hashtable' -Value 'Ninmonkey.Console\Join-Hashtable' # unless nin is imported

'Import: => Import-CommandSuite ... '
| Join-String -op "source <${PSCommandPath}> "
| Write-Warning

Import-CommandSuite

'try command: nin.ImportPSReadLine ==>'
| Join-String -op "source <${PSCommandPath}> "
| Write-Warning
nin.ImportPSReadLine MyDefault_HistListView

'end (essentially)' | Write-Warning
<#
    {
        "key": "ctrl+.",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": { "commandName": "Invoke-DocumentRefactor" },
        "when": "editorLangId == 'powershell'"
    },
    {
        "key": "ctrl+shift+s",
        "command": "PowerShell.InvokeRegisteredEditorCommand",
        "args": { "commandName": "ConvertTo-SplatExpression" },
        "when": "editorLangId == 'powershell'"
    },

    #>

# Set-Alias 'Label' -Value 'Ninmonkey.Console\wri' # unless nin is imported
# __countDuplicateLoad

# $OneDrive ??= @{ Enable_MyDocsBugMapping = $true ; $First }
# dotsource or symlink
# $Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"


# . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
# C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1
# dotsource or symlink
# $Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
# . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
# throw "ShouldNeverReachHereAnymore (warning to prevent double load)"

# $global:__dupCounter[ $PSCOmmandPath.Name ] += 1
# some func

if ( $superVerboseAtBottom2) {


    $VerbosePReference = 'continue'
    $WarningPreference = 'continue'
    $debugpreference = 'continue'

    $PSDefaultParameterValues['*:Debug'] = $true
    $PSDefaultParameterValues['*:Verbose'] = $true
    $PSDefaultParameterValues['Import-Module:Debug'] = $false #
    $PSDefaultParameterValues['Set-Alias:Debug'] = $false #

    # Set-PSDebug -Trace 1


    # $__dbgSuperVerbose = $true
    # if($__dbgSuperVerbose) {
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
    # }

    Set-PSDebug -Trace $superVerboseAtBottom2_traceLevel
    Set-PSDebug -Trace $superVerboseAtBottom2_traceLevel
    "end => NinCurrentALlHosts: '$PSComandPath'" | Write-Warning

    label 'superVerbBot?' $superVerboseAtBottom2
}

$PSDefaultParameterValues['Import-Module:Verbose'] = $false
$PSDefaultParameterValues.Remove('Import-Module:Verbose')

# $VerbosePReference = 'continue'
$debugpreference = 'silentlycontinue'
$VerbosePreference = 'silentlycontinue'
$WarningPreference = 'silentlycontinue'
$PSDefaultParameterValues.Remove('*:Debug')
$PSDefaultParameterValues.Remove('*:Verbose')

$PSDefaultParameterValues['get-module:Verbose'] = $false
$PSDefaultParameterValues['Import-Module:Verbose'] = $true
$PSDefaultParameterValues['Import-Module:Verbose'] = $false
$PSDefaultParameterValues['Import-Module:PassThru'] = $true
$PSDefaultParameterValues['Install-Module:Verbose'] = $true


"Actual End of '$PSCOmmandPath"
"=>vscode pid: ${pid}"
