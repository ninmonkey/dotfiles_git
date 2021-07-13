$script:_state = @{}

$global:NinProfile_Dotfiles = @{
    # todo: should be a commandlet response ?
    Bat                    = Get-Item -ea SilentlyContinue "$env:Nin_Dotfiles\cli\ripgrep\.ripgreprc"
    RipGrep                = Get-Item -ea SilentlyContinue "$env:Nin_Dotfiles\cli\ripgrep\.ripgreprc"
    BashProfile            = Get-Item -ea SilentlyContinue "$env:Nin_Dotfiles\wsl\home\.bash_profile"
    WindowsTerminalPreview = Get-Item -ea SilentlyContinue "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    WindowsTerminal        = Get-Item -ea SilentlyContinue "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    vscode                 = @{
        ExtensionDir = Get-Item "$env:UserProfile\.vscode\extensions"
        User         = Get-Item "$env:appdata\Code\User\settings.json"
    }
    Git                    = @{
        GlobalIgnore = Get-Item -ea SilentlyContinue $env:Nin_Dotfiles\git\global_ignore.gitignore
        PowerBI      = @{
            'ExternalToolsConfig' = Get-Item 'C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools'
        }

    }
}



Export-ModuleMember -Variable 'NinProfile_Dotfiles'

function _Write-GitStatus {
    <#
        .synopsis

        #>
    $dir_git = Get-GitDirectory
    [bool]$isGetRepo = $null -ne $dir_git

    if (! $isGetRepo) {
        return
    }

    New-Text 'git' -ForegroundColor (Get-GitBranchStatusColor).ForegroundColor
}

function Write-NinProfilePrompt {
    <#
    .synopsis
        A dynamic prompt, that function:\prompt can always point to
    .description
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


    function _Path-ToBreadCrumbs {

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

    $segments = @(
        "`n"
        _Path-ToBreadCrumbs
        "`n"
        _Write-GitStatus # todo: better git status line
        "`n"
        '🐒> '
    )
    $segments | Join-String
}

Export-ModuleMember -Function Write-NinProfilePrompt