﻿"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

$eaSilent = @{ ErrorAction = 'ignore' }

$PROFILE
| Add-Member @eaSilent -PassThru -Force -NotePropertyMembers @{
    Nin      = @{
        DotfilesRoot = Get-Item -ea ignore $Env:Nin_Dotfiles
        DataRoot     = Get-Item -ea ignore $Env:Nin_Data
        Legacy       = [Colections.Generic.List[Object]]@(
            Get-ChildItem env:\legacy_* @eaSilent
        )
        Env          = @{
            Root   = Get-Item @eaSilent 'h:\env'
            Code   = Get-Item @eaSilent 'H:\env\code'
            Ivy    = Get-Item @eaSilent 'H:\env\code-insider'
            Python = Get-Item @eaSilent 'H:\env\py'
            Scoop  = Get-Item @eaSilent 'H:\env\scoop'

        }
        # = @{
        #     # H:\env\code
        #     # H:\env\code-insider
        #     # H:\env\py
        #     # H:\env\scoop
        # }
    }
    Dotfiles = @{
        Fzf              = '<nyi>'
        Bat              = '<nyi>'
        Rg               = '<nyi>'
        Git              = '<nyi>'
        PSScriptAnalyzer = '<nyi>'
        Pester           = '<nyi>'
        Aws              = '<nyi>'
        Bash             = @(
            Get-ChildItem @eaSilent -Path ~ *bash*
        )

        # Less / ...
    }
} | Out-Null

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib'
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'

    'E:\PSModulePath_2022'
    'E:\PSModulePath_base\all'
    $Env:PSModulePath
) | Join-String -sep ';'

'Updated PSModulePath: 🐧 {0}' -f @(
    $Env:PSModulePath
)
| Write-Warning


# $PSDefaultParameterValues['Import-Module:Verbose'] = $true
$PSDefaultParameterValues['Update-Module:Verbose'] = $true
$PSDefaultParameterValues['Install-Module:Verbose'] = $true
$PSDefaultParameterValues['Set-ClipBoard:PassThru'] = $true
$Env:LESS = '-R'
$Env:Pager = 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'
$Env:Pager = 'bat'

$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args












return
Write-Warning 'early exit'
throw 'ShouldNeverReach'
# Env-Vars are all caps because some apps check for env vars case-sensitive
# double check that profile isn't failing to set the global env vars
$Env:LESS ??= '-R'
$ENV:PAGER ??= 'bat'
# $ENV:PAGER ??= 'less -R'
$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\SkyDrive\Documents\2021\Powershell\My_Github"

$Env:Pager ??= 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'

# now function:\help tests for the experimental feature and gcm on $ENV:PAger
$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args

$ENV:PAGER = 'bat'
$ENV:PYTHONSTARTUP = Get-Item -ea continue "${Env:Nin_Dotfiles}/cli/python/nin-py3-x-profile.py"

# if (! (Test-Path $Env:BAT_CONFIG_PATH)) {
#     $maybeRelative = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc #@eaIgnore
#     if ($maybeRelative) {
#         $Env:BAT_CONFIG_PATH = $MaybeRelativePath
#     }
# }
$Env:BAT_CONFIG_PATH = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc #@eaIgnore
<#
bat
    --force-colorization --pager <command>
    --pager "Less -RF"
    #>




"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>