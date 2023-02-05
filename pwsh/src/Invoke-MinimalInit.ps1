
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

        $isSameDir = (get-item .).FullName -eq $script:__bagLastLocation.FullName
        $script:__bagLastLocation = (get-item .)
        $NumErrors = $global:Error.Count
        @(

            $Color.FgDim

            $PSVersionTable
            | Join-String PSVersion -op 'Pwsh ' -os '> '

            if ( $NumErrors ) {
                $Color.Error
                '[{0}] ' -f @($NumErrors)
                $Color.FgDim
            }

            $renderLocation =  (Get-Location) -split '\\' | Join-String -sep ' ⊢ '
            if($isSameDir) {
                '🐧'
            } else {
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
    ) | Join-String
}
# ⟞⊢

function prompt {
    # todo: capture previous prompt
    minimal.Prompt
}


Set-PSReadLineOption -ContinuationPrompt ''


