$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.DynamicProfileMembers = $PSCommandPath | Get-Item

$eaSilent = @{ ErrorAction = 'silentlyContinue' }
$eaNone = @{ ErrorAction = 'ignore' }

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

write-verbose 'to strip/refactor/rewrite: <file:///C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1>'

$Env:BAT_CONFIG_PATH = Get-Item @eaSilent (Join-Path $Env:Nin_Dotfiles 'cli/bat/.batrc')
$Env:LESS = '-R'
$Env:Pager = 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'
$Env:Pager = 'bat'
$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args
$DescLoc = '. Source: {0}' -f @(
    $PSCommandPath | Join-String -DoubleQuote
)

$NotePropertyMembers_hash = @{
    Nin      = @{
        DotfilesRoot = Get-Item @eaSilent $Env:Nin_Dotfiles
        DataRoot     = Get-Item @eaSilent $Env:Nin_Data
        Legacy       = [Collections.Generic.List[Object]]@(
            Get-ChildItem env:\legacy_* @eaNone
        )
        Env          = @{
            Root   = Get-Item @eaNone 'h:/env'
            Code   = Get-Item @eaNone 'H:/env/code'
            Ivy    = Get-Item @eaNone 'H:/env/code-insider'
            Python = Get-Item @eaNone 'H:/env/py'
            Scoop  = Get-Item @eaNone 'H:/env/scoop'

        }
    }

    Dotfiles = @{
        Fzf              = '<nyi>'
        # Bat              = Get-Item @eaSilent $env:BAT_CONFIG_PATH
        Bat              = $env:BAT_CONFIG_PATH
        Rg               = '<nyi>'
        Git              = '<nyi>'
        PSScriptAnalyzer = '<nyi>'
        Pester           = '<nyi>'
        Aws              = '<nyi>'
        Bash             = [object[]]@(
            Get-ChildItem @eaNone -Path ~ *bash*
        )

        # Less / ...
    }
} | Out-Null
if ($null -eq $NotePropertyMembers_hash) {
    if ($global:__nin_enableTraceVerbosity) {
        Write-Warning '🎌hash is null'
        Write-Warning '$Profile.AddMember is failing'
    }
}
else {
    $PROFILE
    | Add-Member -PassThru -Force -NotePropertyMembers $NotePropertyMembers_hash
    | Out-Null
}

# $Env:PSModulePath = @(
#     # 'H:\data\2023\pwsh\PsModules' # should already be in there
#     # 'E:\PSModulePath_base\all'
#     # 'E:\PSModulePath_2022'
#     # 'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib'
#     # 'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'
#     $Env:PSModulePath
# ) | Join-String -sep ';'

# 'Updated PSModulePath: 🐧 {0}' -f @(
#     $Env:PSModulePath
# )
# | Write-Verbose

# $PSDefaultParameterValues['Import-Module:Verbose'] = $true
$PSDefaultParameterValues['Update-Module:Verbose'] = $true
$PSDefaultParameterValues['Install-Module:Verbose'] = $true
$PSDefaultParameterValues['Set-ClipBoard:PassThru'] = $true

# $Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
# $Env:Nin_PSModulePath ??= "$Env:UserProfile\SkyDrive\Documents\2021\Powershell\My_Github"

$splat_Show = @{
    PassThru = $true
}
@(

    Set-Alias @splat_Show 'Cl' -Value 'Set-ClipBoard' -Description "Set Clipboard. ${DescLoc}"
    Set-Alias @splat_Show 'fcc' 'ninmonkey.console\Format-ControlChar' -PassThru -Description "Format-ControlChar abbr. ${DescLoc}"
    Set-Alias @splat_Show 'FromJson' 'ConvertFrom-Json' -PassThru -Description "Format-ControlChar abbr. ${DescLoc}"
    Set-Alias @splat_Show 'Gcl' -Value 'Get-ClipBoard' -Description "Get Clipboard. ${DescLoc}"
    Set-Alias @splat_Show 'Impo' -Value 'Import-Module' -Description "Impo. ${DescLoc}"
    Set-Alias @splat_Show 'Json' 'ConvertTo-Json' -PassThru -Description "Format-ControlChar abbr. ${DescLoc}"
    Set-Alias @splat_Show 'Ls' -Value 'Get-ChildItem' -Description "gci. ${DescLoc}"
    Set-Alias @splat_Show 's' -Value 'Select-Object' -PassThru -Description "Select-Object abbr. ${DescLoc}"
    Set-Alias @splat_Show 'Sc' -Value 'Set-Content' -Description "set content. ${DescLoc}"

) | Join-String -sep "`n    " -op "Set alias: `n    " DisplayName
| Join-String -op "<${PSSCommandPath}>`n" { $_ }
| write-verbose
# | Join-String -op "${fg:a4dcf1}"
# | Write-ConsoleColorZd -Fg '#a4dcf1'

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }


# $Env:Pager ??= 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'
# # now function:\help tests for the experimental feature and gcm on $ENV:PAger
# $Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args
# $ENV:PAGER = 'bat'
# $ENV:PYTHONSTARTUP = Get-Item -ea continue "${Env:Legacy_Nin_Dotfiles}/cli/python/nin-py3-x-profile.py"
# # if (! (Test-Path $Env:BAT_CONFIG_PATH)) {
# #     $maybeRelative = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc #@eaIgnore
# #     if ($maybeRelative) {
# #         $Env:BAT_CONFIG_PATH = $MaybeRelativePath
# #     }
# # }
# <#
# bat
#     --force-colorization --pager <command>
#     --pager "Less -RF"
#     #>
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>