
function minimal.prompt.render.crumbs {
    # colorize prompt like: H: ⊢ env ⊢ py ⊢ global_tools ⊢ 2022-11
    begin {
        $Color = @{}
        $Color.Error = $PSStyle.Foreground.FromRgb('#ce6060')
        $mod = 0.35
        $digit = [int](255 * $mod) | ForEach-Object tostring 'x'
        $Color.FgDim = $PSStyle.Foreground.FromRgb( "#${digit}${digit}${digit}" )
        $Color.Fg = $PSStyle.Foreground.FromRgb('#9e9e9e')
    }
    process {
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

            (Get-Location) -split '\\' | Join-String -sep ' ⊢ '
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


