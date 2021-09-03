$script:_state = @{}

$PROFILE | Add-Member -ea ignore -NotePropertyName 'Ninmonkey.Profile.psm1' -NotePropertyValue (Get-Item $PSScriptRoot)
# adds full filepath this file's directory
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
$splatIgnorePass = @{
    ErrorAction = 'Ignore'
    'PassThru'  = $true
    # scope = script? global because it's export module?
}
$splatIgnoreGlobal = $splatIgnorePass += @{
    Scope = 'Global'
}
Remove-Alias -Name 'cd' -ea ignore
Remove-Alias -Name 'cd' -Scope global -Force -ea Ignore
[object[]]$newAliasList = @(
    New-Alias @splatIgnorePass   -Name 'CodeI'     -Value 'code-insiders'      -Description 'VS Code insiders version'
    New-Alias @splatIgnorePass   -Name 'CtrlChar'  -Value 'Format-ControlChar' -Description 'Converts ANSI escapes to safe-to-print text'
    New-Alias @splatIgnorePass   -Name 'Wi'        -Value 'Write-Information'  -Description 'Write Information'
    Set-Alias @splatIgnorePass   -Name 'Gpi'       -Value 'ClassExplorer\Get-Parameter'  -Description 'Write Information'
    # New-Alias @splatIgnorePass   -Name 'SetNinCfg' -Value 'nyi'                 -Description '<todo> Ninmonkey.Console\Set-NinConfiguration'
    # New-Alias @splatIgnorePass   -Name 'GetNinCfg' -Value 'nyi'                 -Description '<todo> Ninmonkey.Console\Get-NinConfiguration'
    New-Alias @splatIgnoreGlobal -Name 'Cd'        -Value 'Set-NinLocation'    -Description 'A modern "cd"'
    Set-Alias @splatIgnorePass   -Name 'S'         -Value 'Select-Object'      -Description 'aggressive: to override other modules'
    Set-Alias @splatIgnorePass   -Name 'Cl'        -Value 'Set-Clipboard'      -Description 'aggressive: set clip'
    New-Alias @splatIgnorePass   -Name 'CodeI'     -Value 'code-insiders'      -Description 'quicker cli toggling whether to use insiders or not'
    New-Alias @splatIgnorePass   -Name 'F'         -Value 'PSScriptTools\Select-First' -Description 'quicker cli toggling whether to use insiders or not'
    New-Alias @splatIgnorePass   -Name 'Len'         -Value 'Ninmonkey.Console\Measure-ObjectCount' -Description 'A quick count of objects in the pipeline'
    # New-Alias 'jp' -Value 'Join-Path' -Description '[Disabled because of jp.exe]. quicker for the cli'
    # New-Alias 'joinPath' -Value 'Join-Path' -Description 'quicker for the cli'
    # guard did not catch this correctly anyway, maybe -ea disables loading? i don not want to use an -all
    #   on a profile load, for performance.
    #   the 'nicest' way could be to delay binding using a profile 'async'? or just allow it to bind without existing.
    # if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
    #     New-Alias -Name 'f ' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    # }
)

Export-ModuleMember -Alias $newAliasList
$newAliasList | Sort-Object Name | Join-String -sep ', ' -SingleQuote -op 'New Alias: '
| New-Text -fg 'pink' | Join-String -op 'Ninmonkey.Profile: '
| Write-Debug

function _reRollPrompt {
    # Re-randomizes the breadcrumb key names
    Reset-RandomPerSession -Name 'prompt.crumb.colorBreadEnd', 'prompt.crumb.colorBreadStart'
}

function toggleErrors {
    # todo: cleanup: move to a better location
    $__ninConfig.Prompt.NumberOfPromptErrors = if($__ninConfig.Prompt.NumberOfPromptErrors -eq 0) { 3 } else { 0 }
}


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
function _Write-PromptPathToBreadCrumbs {
    <#
    .synopsis
        write current directory as crumbs
    .notes
        future:

        -[ ] abbrevate mode

            in:
                C:\\Users\\cppmo_000\\Documents\\2021\\Powershell\\My_Gist\\FinalDirectory
            out:
                # A
                $EnvUserProfile⋯Docs⋯2021⋯Powe⋯My_Gist⋯FinalDirectory

                # B
                U⋯c⋯D⋯2⋯P⋯My_Gi⋯FinalDirectory


    #>
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # FormatMode
        [ValidateSet('Default', 'LimitSegmentCount')]
        [Parameter(Position = 0)]
        [string]$FormatMode = 'LimitSegmentCount'
    )

    try {
        $FinalOutputString = switch ($FormatMode) {
            'a' {
                'Ps> '
                break
            }
            'Reverse' {
                'Todo> '
                # todo: like 'default' but reverse, so brightest path is left
                break
            }
            'LimitSegmentCount' {
                # size is currently disabled being used
                $maxSize = ($__ninConfig.Prompt.BreadCrumb)?.MaxCrumbCount ?? 3 # __doc__: default is 3. Negative means no limit
                $crumbJoinText = ($__ninConfig.Prompt.BreadCrumb)?.CrumbJoinText ?? ' ' # __doc__: default is ' ' . Join String.
                $crumbJoinReverse = ($__ninConfig.Prompt.BreadCrumb)?.CrumbJoinReverse ?? $true # __doc__: default is $false ' right to left
                # todo: config: after config wrapper, also setup these:
                # 'gray40'

                $gradientStart = ($__ninConfig.Prompt.BreadCrumb)?.ColorStart
                $gradientStart ??= Get-RandomPerSession -Name 'prompt.crumb.colorBreadStart' { Get-ChildItem fg: }
                $gradientEnd = ($__ninConfig.Prompt.BreadCrumb)?.ColorEnd
                $gradientEnd ??= Get-RandomPerSession -Name 'prompt.crumb.colorBreadEnd' { Get-ChildItem fg: }

                $crumbs = (Get-Location | ForEach-Object Path) -split '\\'
                $numCrumbs = $crumbs.count
                $getGradientSplat = @{
                    StartColor = $gradientStart
                    EndColor   = $gradientEnd
                    Width      = [math]::Clamp( $numCrumbs, 3, [int]::MaxValue )
                }
                # if ($true) {
                #     $colorsFg = Get-ChildItem fg:
                #     $getGradientSplat.StartColor = $colorsFg | Get-Random -Count 1
                #     $getGradientSplat.EndColor = $colorsFg | Get-Random -Count 1
                # }

                $gradient = Get-Gradient @getGradientSplat
                $finalSegments = $crumbs | ForEach-Object -Begin { $i = 0 } {
                    $curLine = $_
                    if ($i -ge $numCrumbs) {
                        Write-Error "OutofBoundException:`$i '$i' >= `$numCrumbs!"
                    }
                    New-Text -Object $curLine -ForegroundColor $gradient[$i]
                    $i++
                }
                if ($crumbJoinReverse) {
                    # $finalSegments.reverse() | Out-null
                    $FinalSegments | Out-ReversePipeline
                    | Join-String -sep $crumbJoinText
                }
                else {
                    $finalSegments
                    | Join-String -sep $crumbJoinText
                }

                # no removal for now, just show all segments
                break
            }

            default {
            }

        }

        $FinalOutputString | Join-String -sep ''
    }
    catch {
        $PSCmdlet.WriteError( $_ )
    }
}
$script:__temp ??= @{} #??= @{}
$script:__temp.IncludeDebugPrompt ??= $true

function _Write-ErrorSummaryPrompt {
    <#
    .synopsis
        can't access global scope?
        summarize errors briefly, for screenshots / interactive animation
    #>
    param(
        #
        [Parameter(Position = 0)]
        [string]$Name
    )

    Dev.Nin\Test-DidErrorOccur -Limit 3

    # $script:__temp.LastErrorCount ??= $error.count
    # $newErrorCount = $error.count - $script:__temp.LastErrorCount
    # $script:__temp.LastErrorCount = $error.count


    # @(
    #     "New Error Count: $NewErrorCount."
    # ) | Join-String -sep "`n"

    # $template
    # $lastCount = $error.count
    #1 / 0
    # ($error.count) - $lastCount


    # $error[0].Message
    # $error[1].Exception.Message
}
function _Write-PromptDetectParent {
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
    $chunk | Join-String -os "`n"
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
    [cmdletbinding(PositionalBinding = $false)]
    param (
    )
    try {
        $__ninConfig.Prompt.NumberOfPromptErrors ??= 2
        $configErrorLinesLimit = $__ninConfig.Prompt.NumberOfPromptErrors ?? 2

        # do not use extra newlines on missing segments
        switch ($__ninConfig.Prompt.Profile) {
            'errorSummary' {
                @(
                    "`n"
                    # err?
                    # hr
                    _Write-ErrorSummaryPrompt
                    "`n🐒> "
                ) | Join-String
                break
            }
            'debugPrompt' {
                # __doc__: Clearly shows whether you're in the PSIT or not
                @(
                    _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
                    _Write-PromptDetectParent
                    # "`n"
                    "🐛> "
                ) | Join-String
                break
            }

            'oneLine' {
                @(
                    '🐒> '
                ) | Join-String
                break
            }
            'twoLine' {
                @(
                    "`n"
                    '🐒> '
                ) | Join-String
                break
            }
            'spartan' {
                @(
                    _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
                    "`n🐒> "
                ) | Join-String
                break
            }

            default {

                # __doc__: 'main' prompt with breadcrumbs


                $segments = @(
                    $splatPredent = @{
                        NewlineCount          = ($__ninConfig.Prompt)?.PredentLineCount ?? 2
                        IncludeHorizontalLine = ($__ninConfig.Prompt)?.IncludePredentHorizontalLine ?? $false
                    }


                    function _Write-PromptDetectError {
                        if($global:Error.count -gt 0 -and $configErrorLinesLimit -gt 0) {
                            Dev.Nin\Test-DidErrorOccur -Limit $configErrorLinesLimit
                            "`n"
                        }
                    }
                    _Write-Predent @splatPredent
                    # _Write-Predent -NewlineCount 2 -IncludeHorizontalLine:$false
                    _Write-PromptIsAdminStatus
                    _Write-PromptDetectError
                    _Write-PromptPathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'
                    if ($__ninConfig.Prompt.IncludeGitStatus) {
                        _Write-PromptGitStatus # todo: better git status line
                    }
                    "`n🐒> "
                )
                $segments | Join-String
            }
        }
    }
    catch {
        $PSCmdlet.WriteError( $_ )
    }
}

Export-ModuleMember -Function Write-NinProfilePrompt
# if debug mode
if ($true) {
    Export-ModuleMember -Function @(
        'toggleErrors'
        '_Write-PromptIsAdminStatus'
        '_Write-PromptPathToBreadCrumbs'
        '_Write-PromptGitStatus'
        '_Write-PromptDetectParent'
        '_Write-ErrorSummaryPrompt'
    )
}

# & {
$src = Join-Path $PSScriptRoot 'backup_vscode.ps1'
if (Test-Path $src) {
    . $src
    Export-ModuleMember -Function 'Backup-VSCode'
}
# }

# Get-ChildItem fg: | Where-Object { $_.X11ColorName -match 'alm|moun' } | Sort-Object Rgb | ForEach-Object { New-Text $_.x11ColorName -fg $_ } | Join-String -sep ' . '
# | Write-Host
