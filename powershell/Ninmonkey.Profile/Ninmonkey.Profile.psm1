$script:_state = @{}

# & {
$s_optionalItem = @{
    'ErrorAction' = 'silentlycontinue'
    # 'ErrorAction' = 'ignore'
}
<#
    Handling $NinProfile_Dotfiles as a script variable that's exported has the benifit that
        - it acts like a 'global' for the user
        - dies if you call 'remove-module' in the current session
    #>
$script:NinProfile_Dotfiles = @{
    # todo: should be a commandlet response ?
    Bat                    = Get-Item @s_optionalItem "$env:Nin_Dotfiles\cli\bat\.batrc"
    RipGrep                = Get-Item @s_optionalItem "$env:Nin_Dotfiles\cli\ripgrep\.ripgreprc"
    BashProfile            = Get-Item @s_optionalItem "$env:Nin_Dotfiles\wsl\home\.bash_profile"
    WindowsTerminalPreview = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    WindowsTerminal        = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    vscode                 = @{
        ExtensionDir = Get-Item "$env:UserProfile\.vscode\extensions"
        User         = Get-Item "$env:appdata\Code\User\settings.json"
    }
    Git                    = @{
        GlobalIgnore = Get-Item @s_optionalItem "$env:Nin_Dotfiles\git\global_ignore.gitignore"
        Config       = @(
            Get-Item @s_optionalItem '~\.gitconfig' # symlink or to dotfile?
            Get-Item @s_optionalItem "$env:Nin_Dotfiles\git\homedir\.gitconfig"
        ) | Sort-Object -Unique FullName

        PowerBI      = @{
            # See my PowerBI module for tons of PBI paths
            'ExternalToolsConfig' = Get-Item 'C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools'
        }

    }
}

# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
$Env:RIPGREP_CONFIG_PATH = $script:NinProfile_Dotfiles.RipGrep.FullName

# }
Export-ModuleMember -Variable 'NinProfile_Dotfiles'

# & {
New-Alias 'codei' -Value 'code-insiders' -Description 'VS Code insiders version' -PassThru
New-Alias -Name 'CtrlChar' -Value Format-ControlChar -Description 'Converts ANSI escapes to safe-to-print text' -PassThru
New-Alias -Name 'wi' -Value 'Write-Information'

Export-ModuleMember -Alias @(
    'codei'
    'CtrlChar'
    'wi'
)
# }


function _Write-PromptGitStatus {
    <#
    .synopsis
        temp placement for posh-git
    .outputs
        either $null, or a string based on git status
    #>
    $dir_git = Get-GitDirectory
    [bool]$isGetRepo = $null -ne $dir_git

    if (! $isGetRepo) {
        return
    }

    New-Text 'git' -ForegroundColor (Get-GitBranchStatusColor).ForegroundColor
}

function _Write-PromptIsAdminStatus {
    <#
    .synopsis
        basic bright red, make it hard to forget you're admin
    .description
        1. big red

        wt already sets tab titlen
    #>
    "`n"
    if (!(Test-UserIsAdmin)) {
        return
    }
    New-Text -bg red -fg white 'Admin      '
    "`n"
}
function _Write-PathToBreadCrumbs {

    param(
        # FormatMode
        [ValidateSet('Default', 'LimitSegmentCount')]
        [Parameter(Position = 0)]
        [string]$FormatMode = 'LimitSegmentCount'
    )

    $crumbs = (Get-Location | ForEach-Object Path) -split '\\'
    switch ($FormatMode) {
        'a' {
            break
        }
        'Reverse' {
            # todo: like 'default' but reverse, so brightest path is left
            break
        }
        'LimitSegmentCount' {
            # todo: like 'default' but reverse, so brightest path is left
            $maxSize = 3
            $gradient = Get-Gradient -StartColor gray40 -EndColor gray90 -Width 4
            $finalList = @(
                $crumbs | Select-Object -First 1


                ($crumbs | Select-Object -Skip 1)
                | Select-Object -Last $maxSize
            )


            $finalString = $finalList | ForEach-Object -Begin { $i = 0 ; } -Process {
                New-Text -Object $_ -fg $gradient[$i++]
            }
            $finalString | Join-String -sep ' '
            break
        }
        default {
        }

    }
}
$script:__temp ??= @{} #??= @{}
$script:__temp.IncludeDebugPrompt ??= $true

function _Write-ErrorSummaryPrompt {
    <#
    .synopsis
        summarize errors briefly, for screenshots / interactive animation
    #>
    param(
        #
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )

    if ( $script:__temp.IncludeDebugPrompt ) {
        _Write-VerboseDebugPrompt
    }

    $script:__temp.LastErrorCount ??= $error.count
    $newErrorCount = $error.count - $script:__temp.LastErrorCount
    $script:__temp.LastErrorCount = $error.count


    @(
        "New Error Count: $NewErrorCount."
    ) | Join-String -sep "`n"

    # $template
    # $lastCount = $error.count
    #1 / 0
    # ($error.count) - $lastCount


    # $error[0].Message
    # $error[1].Exception.Message
}
function _Write-VerboseDebugPrompt {
    <#
    .synopsis
        verbose prompt to test term detection
    #>
    $chunk = @()
    $template = "TermName: {0}`nIsVsCode: {1}`nIsPSIT: {2}"
    $chunk += $template -f @(
        $__ninConfig.Terminal.CurrentTerminal
        ($__ninConfig.Terminal.IsVSCode) ? 'Y' : 'N'
        ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) ? 'Y' : 'N'
    ) | Join-String
    $chunk | Join-String -sep "`n"
}

function _Write-Predent {
    param(
        # Number of newlines
        [Parameter(Position = 0)]
        [int]$NewlineCount = 2,
        # Include extra Horizontal line
        [Parameter()][switch]$IncludeHorizontalLine
    )
    @(
        "`n" * $NewlineCount -join ''
        if ($IncludeHorizontalLine) {
            New-Text -fg 'gray30' '___________' # extra pre-dent
        }
    ) | Join-String
}

function Write-NinProfilePrompt {
    <#
    .synopsis
        A dynamic prompt, that function:\prompt can always point to
    .description
        Not profiled for performance at all

        Does this excessively use the pipeline, and Join-Ytring when it's not necessary?
            Yes. To allow future experiments to be easier
            Performance cost here doesn't matter.$
    .example
        PS>
    .notes
        .
    #>
    param (
    )
    # do not use extra newlines on missing segments
    switch ($__ninConfig.Prompt.Profile) {
        'errorSummary' {
            _Write-ErrorSummaryPrompt
            break
        }
        'debugPrompt' {
            _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
            _Write-VerboseDebugPrompt
            break
        }

        'spartan' {
            _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
            "`n🐒> "
            break
        }

        default {


            $segments = @(
                $splatPredent = @{
                    NewlineCount          = ($__ninConfig.Prompt)?.PredentLineCount ?? 2
                    IncludeHorizontalLine = ($__ninConfig.Prompt)?.IncludePredentHorizontalLine ?? $false
                }

                _Write-Predent @splatPredent
                # _Write-Predent -NewlineCount 2 -IncludeHorizontalLine:$false
                _Write-PromptIsAdminStatus
                _Write-PathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'
                if ($__ninConfig.Prompt.IncludeGitStatus) {
                    _Write-PromptGitStatus # todo: better git status line
                }
                "`n🐒> "
            )
            $segments | Join-String
        }
    }
}

Export-ModuleMember -Function Write-NinProfilePrompt
# if debug mode
if ($true) {
    Export-ModuleMember -Function @(
        '_Write-PromptIsAdminStatus'
        '_Write-PathToBreadCrumbs'
        '_Write-PromptGitStatus'
        '_Write-VerboseDebugPrompt'
        '_Write-ErrorSummaryPrompt'
    )
}

& {
    $src = Join-Path $PSScriptRoot 'backup_vscode.ps1'
    if (Test-Path $src) {
        . $src
        Export-ModuleMember -Function 'Backup-VSCode'
    }
}

Get-ChildItem fg: | Where-Object { $_.X11ColorName -match 'alm|moun' } | Sort-Object Rgb | ForEach-Object { New-Text $_.x11ColorName -fg $_ } | Join-String -sep ' . '
| Write-Host
