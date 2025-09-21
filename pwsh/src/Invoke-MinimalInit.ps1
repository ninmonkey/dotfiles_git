$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.PromptBasic = $PSCommandPath | Get-Item
$global:__ninBag.Profile.PrevErrorCount = 0

$PROFILE | Add-Member -NotePropertyName 'MiniPromptEntry' -NotePropertyValue (Get-item $PSCommandPath ) -Force -ea 'ignore'

Import-Module -Name 'Dotils'  #-ea 'ignore'
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
	# can error if user is in a folder that no longer exists.
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
                '🐒'  # '🐧'
            }
            else {
                $renderLocation
            }
            # if(-not $innerConfig.hideSameLocation -and -not $isSameDir) {
            #     $renderLocation
            # }
            $PSStyle.Reset
            if($PredentExtra) {
                "`n    "
                '    '
            } else {
                "`n"
                ''
            }
        ) -join ''
    }
}

$global:__minimalPromptConfig = @{
    Enable = @{
        RecentAsUL = $true
        RecentRecurse_ByDate = $True
        FiletypeDistribution = $true
        FiletypeDistribution_B = $True
        FiletypeDistribution_A = $false
        QuickDisableAll = $true
    }
    Is = @{}
    In = @{}
}
function minimal.Prompt.Render.RecentItems {
    <#
    .synopsis
        render items with recency rather than depth as the primary
    #>
    $global:__minimalPromptConfig |  write-debug
    if($global:__minimalPromptConfig.Enable.QuickDisableAll) {
        return
    }



    # fd --changed-within 2hours -d 3 -tf


    if($global:__minimalPromptConfig.Enable.RecentRecurse_ByDate) {
        fd --changed-within 7hours -d 3 -tf --color always
            | Join-String -sep ', ' -op ('recent: ' | New-Text -fg 'gray60' -bg '20' )
            # | Join-String -sep ', ' -op ('recent: ' | Dotils.Write-DimText)
    }
    if($global:__minimalPromptConfig.Enable.FiletypeDistribution_B) {
        # & {
            $kinds = gci .  | group Extension -NoElement | Sort-Object Count -Descending
            $i_grads = 0
            $numberOfCrumbs = $kinds.Count
            $grads = Get-Gradient -StartColor 'gray75' -EndColor 'gray10' -Width ([Math]::Max($numberOfCrumbs, 3))
            $numGrads = $grads.count
            $kinds
                | Join-String {
                    Join-String -sep ':' -InputObject $_.Count, $_.Name
                        | New-Text -fg $grads[ $i_grads++ ]
                } -sep ', '
        # }
    }
    if($global:__minimalPromptConfig.Enable.FiletypeDistribution_A) {
        $kinds = gci .  | group Extension -NoElement | Sort-Object Count -Descending
        $kinds | Join-String { Join-String -sep ':' -InputObject $_.Count, $_.Name } -sep ', '

    }
    if($global:__minimalPromptConfig.Enable.RecentAsUL) {
        fd --changed-within 2hours -d 3 -tf --color always | CountOf -CountLabel 'a' | Join.ul

    }
}
function minimal.Prompt {
    param(

    ) @(
        # "`n"
#
        if(-not $global:__minimalPromptConfig.Enable.QuickDisableAll) { ## todo: major refactor : 2024-06-09
            minimal.Prompt.Render.RecentItems

        }
        # ''
        ''
        minimal.prompt.render.crumbs



        # amazon AWS profile set?
        # if (Test-Path env:\AWS_PROFILE) { # appears to never load
        #     $Env:AWS_PROFILE | Join-String -f "aws:{0}`n"
        # }
    ) | Join-String
}
# ⟞⊢



function minimal.Prompt.WriteCwdSequence {
    <#
    .SYNOPSIS
        writes the sequence: ␛]9;9;"c:\foo\bar"␛\PS c:\foo\bar>
    .link
        https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#configure-your-shell
    #>
    param(
        # don't write a prompt at all, just the escapes
        [bool] $AsEscapeOnly
    )
    @(
        $loc = $executionContext.SessionState.Path.CurrentLocation
        [string] $str = ''

        if ( $loc.Provider.Name -eq "FileSystem" ) {
            $str += "`e]9;9;`"$($loc.ProviderPath)`"`e\"
        }
        if( -not $AsEscapeOnly ) {
            $str += "Pwsh> $loc$('>' * ($nestedPromptLevel + 1)) ";
        }
        $str
        # if you want to debug: if( $true ) {  $str -replace "`e", '␛' | Write-Host -fg 'green' -NoNewline }
    ) | Join-String -sep "`n"
}



function prompt {
    # todo: capture previous prompt
    @(
        minimal.Prompt.WriteCwdSequence -AsEscapeOnly
        "`n"
        minimal.Prompt
    ) | Join-String
}


Set-PSReadLineOption -ContinuationPrompt ''
# 'minimal.Prompt is controlled by "$global:__minimalPromptConfig.Enable"' | Dotils.Write-DimText
