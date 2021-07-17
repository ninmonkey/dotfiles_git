$script:_state = @{}

& {
    $s_optionalItem = @{
        'ErrorAction' = 'SilentlyContinue'
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
        WindowsTerminalPreview = Get-Item @s_optionalItem "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        WindowsTerminal        = Get-Item @s_optionalItem "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
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
}


Export-ModuleMember -Variable 'NinProfile_Dotfiles'

function _Write-PromptGitStatus {
    <#
    .synopsis
        temp placement for posh-git
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



    $segments = @(
        "`n"
        _Write-PromptIsAdminStatus
        _Write-PathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'
        "`n"
        _Write-PromptGitStatus # todo: better git status line
        "`n"
        '🐒> '
    )
    $segments | Join-String
}

Export-ModuleMember -Function Write-NinProfilePrompt
# if debug mode
if ($true) {
    Export-ModuleMember -Function @(
        '_Write-PromptIsAdminStatus'
        '_Write-PathToBreadCrumbs'
        '_Write-PromptGitStatus'
    )
}
