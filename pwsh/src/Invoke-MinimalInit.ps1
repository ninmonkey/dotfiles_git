﻿$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.PromptBasic = $PSCommandPath | Get-Item
$global:__ninBag.Profile.PrevErrorCount = 0


function minimal.prompt.render.crumbs {
    <#
    .synopsis
        colorize prompt like: H: ⊢ env ⊢ py ⊢ global_tools ⊢ 2022-11
    .notes
        this is no longer minimal.
        autohides folder when same dir

    .example
        # plus colors
        Pwsh 7.3.2> [3] 🐧
    #>
    begin {
        $Color = @{}
        $Color.Error = $PSStyle.Foreground.FromRgb('#ce6060')
        $mod = 0.35
        $digit = [int](255 * $mod) | ForEach-Object tostring 'x'
        $Color.FgDim = $PSStyle.Foreground.FromRgb( "#${digit}${digit}${digit}" )
        $Color.Fg = $PSStyle.Foreground.FromRgb('#9e9e9e')
    }
    process {
        $innerConfig = @{
            hideSameLocation = $true
        }
        $isSameDir = (Get-Item .).FullName -eq $script:__bagLastLocation.FullName
        $script:__bagLastLocation = (Get-Item .)

        $global:__ninBag.Profile.PrevErrorCount = $NumErrors

        # todo: not quite working
        $NumErrors = $global:Error.Count
        $isNewErrors = $NumErrors -ne $global:__ninBag.Profile.PrevErrorCount
        $global:__ninBag.Profile.PrevErrorCount = $numErrors


        @(

            $Color.FgDim

            $PSVersionTable
            | Join-String PSVersion -op 'Pwsh ' -os '> '

            if ( $NumErrors ) {
                if ($IsNewErrors) {
                    $Color.Error
                    '[{0}] ' -f @($NumErrors)
                    $Color.FgDim
                }
            }

            $renderLocation = (Get-Location) -split '\\' | Join-String -sep ' ⊢ '
            if ($isSameDir) {
                '🐧'
            }
            else {
                $renderLocation
            }
            # if(-not $innerConfig.hideSameLocation -and -not $isSameDir) {
            #     $renderLocation
            # }
            $PSStyle.Reset
            "`n"
            ''
        ) -join ''
    }
}
function minimal.Prompt {
    param(

    )
    @(

        # ''
        ''
        minimal.prompt.render.crumbs

        # amazon AWS profile set?
        if (Test-Path env:\AWS_PROFILE) { # appears to never load
            $Env:AWS_PROFILE | Join-String -f "aws:{0}`n"
        }
    ) | Join-String
}
# ⟞⊢




function prompt {
    # todo: capture previous prompt
    minimal.Prompt
}


Set-PSReadLineOption -ContinuationPrompt ''


