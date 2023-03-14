function Prompt.NoColor {
    # spartan
    @(
        "`n"
        $PSVersionTable.PSVersion -join ''
        ' '
        Get-Location
        "`nPwsh> "
    ) -join ''
}

Set-PSReadLineOption -ContinuationPrompt '    | '
Set-PSReadLineOption -ContinuationPrompt '   | '
Set-PSReadLineKeyHandler -Chord 'Alt+Enter' -Function AddLine

@(
    Set-Alias -PassThru -ea ignore 'cl' -value 'Set-ClipBoard'
    set-Alias -PassThru -ea ignore 'Gcl' -value 'Get-ClipBoard'
    set-Alias -PassThru -ea ignore 'S' -value 'Select-Object'
    # set-Alias -PassThru -ea ignore 'ls' -value 'get-childitem'

)  | Join-String -sep ', '

$Colors = @{
    # Reset        = "`e[0m"
    Reset        = $PSStyle.Reset
    # just use PSStyle
    # CtrlBlinkOff = "`e[25m"
    # CtrlBlink    = "`e[5m"
    # CtrlBoldOff = "`e[22m"
    # CtrlBold    = "`e[1m"

    FgGreen      = $PSStyle.Foreground.FromRgb('#80a36b')
    FgBoldGreen  = $PSStyle.Foreground.FromRgb('#8fc600') # neon
    # FgBlue   = $PSStyle.Foreground.FromRgb('#5a7a84')
    FgBlue       = $PSStyle.Foreground.FromRgb('#97dcff')
    FgWhite      = $PSStyle.Foreground.FromRgb('#dcdfe4')
    FgBlue2      = $PSStyle.Foreground.FromRgb('#699ab2')
    FgBoldBlue   = $PSStyle.Foreground.FromRgb('#3d7bd9')
    FgBoldOrange = $PSStyle.Foreground.FromRgb('#e69622')
    FgBoldYellow = $PSStyle.Foreground.FromRgb('#fbd600')
    FgGold       = $PSStyle.Foreground.FromRgb('#cca238')
    FgRed        = $PSStyle.Foreground.FromRgb('#e06c75')
    FgOrangeDim  = $PSStyle.Foreground.FromRgb('#c99076')
    FgPurple     = $PSStyle.Foreground.FromRgb('#b786c1')
    FgYellow     = $PSStyle.Foreground.FromRgb('#dbdc9e')
    FgGray       = $PSStyle.Foreground.FromRgb('#505867')



    FgDark15     = $PSStyle.Foreground.FromRgb('#282c34')
    BgDark15     = $PSStyle.Background.FromRgb('#282c34')
    # BgDark15   = $PSStyle.Background.FromRgb('#282c34')
    BgGray15     = "${bg:gray15}"
    BgGray30     = "${bg:gray30}"
    BgGray40     = "${bg:gray40}"
}

$Colors.FgDefault = $Colors.FgGray

function colorsTryAll {
    $Colors.Values | ForEach-Object { $str = $_ ;
        Get-Location | abbrPath | jstr -op $str -os '..'
    }; $Colors.Reset
}


function setDemoSetting {
    # // switch
}
write-warning 'currently AbbrPath is returning whitespace'

# if( -not (gcm Err -ea ignore)) {
function Err！ {
        # sugar when in debug mode
    param( [switch]$Clear,
        [Alias('At')][int]$Index,
        [Alias('Limit')][int]$Count )

        if($Clear){
            'cleared: {0} errors' -f ($global:error.count)
            $global:error.clear()
            return
        }
        if($At) { $global:error | at $Index ; return;} # sci
        $global:error | Select -first $Count
}

function Prompt {
    $runes = '！ꜝ︕'
    (@(
        "`n"
        if($global:error.Count -gt 0) {
            @( $Colors.FgRed ; $global:Error.Count) -join ''
            '！'
        }

        $Colors.FgBlue2
        $PSVersionTable.PSVersion -join ''
        ' '
        # "${fg:green}"
        $Colors.FgGreen
        Get-Location
        # | abbrPath
        "${fg:clear}"
        "`nPwsh> "
    ) -join '')
}

function Prompt.1 {
    @(
        "`n"
        $Colors.FgBlue2
        $PSVersionTable.PSVersion -join ''
        ' '
        # "${fg:green}"
        $Colors.FgGreen
        Get-Location | abbrPath
        "${fg:clear}"
        "`nPwsh> "
    ) -join ''
}

function renderPath {
    <#
    .SYNOPSIS
        partially normalize paths
    .DESCRIPTION
        sugar for: Get-Item (Join-Path $Env:USERPROFILE 'SkyDrive/Documents') | ForEach-Object Fullname
        mainly for: abbrPath()
    #>
    param( $Path , [switch]$NoEscape)
    $render = Get-Item $Path | % FullName
    if($NoEscape) { return $render }
    return [regex]::escape($render)
}


function abbrPath {
    param( [Alias('PSPath', 'InputObject')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]$Path,

            [Parameter()]
            [ValidateSet('Basic', '', 'Extra', 'Style2', 'Med')]
            [string]$OutputMode = 'Basic'

        )
    process {

        # $render = Get-Item (Join-Path $Env:USERPROFILE 'SkyDrive/Documents') | ForEach-Object Fullname
        # $render2 = renderPath (Join-Path $Env:USERPROFILE 'SkyDrive/Documents')
        $me = $Path | Get-Item
        switch($OutputMode) {
            'Extra'  {
                $me = renderPath -NoEscape $Path
                $accum = $me
                $accum  = $accum -replace 'cppmo_000', 'nin'
                $accum = $accum -replace '.*my_gists', '/myGist:'
                $accum = $accum -replace '.*my_github', '/myGitHub:'
            #    $accum = $accum -replace (renderPath (Join-Path $Env:USERPROFILE 'SkyDrive/Documents')), '/sky:'
            }
            # most specific first, least last
            'Basic' {
            $me = renderPath -NoEscape $Path
                $accum = $me.FullName
                $accum = $accum -replace '',''
                $accum = $accum -replace (renderPath 'nin_temp') ,'/temp:'

                # $accum = $me.FulLname -replace ([regex]::Escape($Render)), 'Docs:' -replace '\\', '/'
            }
            'Style2' {
                $accum = renderPath -NoEscape $Path

            }
            default {
                $accum = renderPath -NoEscape $Path
            }
        }
        if(-not [string]::isnullorwhitespace($accum)) {
            return $accum
        }
        return $Path # original
    }

}

Set-PSReadLineOption -ContinuationPrompt @(
    "${bg:\gray15}"
    "${fg:\gray40}"
    '      '
    "${bg:clear}${fg:clear}"
    | Join-String).ToString()