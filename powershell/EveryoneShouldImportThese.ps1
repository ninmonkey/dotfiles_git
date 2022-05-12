using namespace PoshCode.Pansies # optional, use if [RgbColor] doesn't resolve
# using namespace System.Collections.Generic #
# using namespace System.Management.Automation # [ErrorRecord]

<#
Optional namespaces, they shorten types,
which isn ice in interactive mode, like:

    PS> [RgbColor]'red'

    PS> $l = [list[object]]::new()
#>

<#
Note:
    This is the right way to set utf8.
    The other method uses BOMs by default, which causes errors when piping
#>
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()


# (This shouldn't be required any more ) Preserve colors when piping Pwsh.
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::Ansi

# skip to use automatic mode
[PoshCode.Pansies.RgbColor]::ColorMode = [PoshCode.Pansies.ColorMode]::Rgb24Bit

if (Test-Path 'C:\Program Files\Git\usr\bin') {
    $Env:Path += ';', 'C:\Program Files\Git\usr\bin'
}

# Powershell uses env vars to switch how it pages. Less is super fast verses the default
$Env:LESS = '-R' # enable colors when piping
$ENV:PAGER = 'bat'     # pick: bat or less
$ENV:PAGER = 'less'
$eaIgnore = @{ ErrorAction = 'ignore' }

<#

    I suggest these 3 from the chocolately packages
        'less', 'bat', 'ripgrep'

        'less' comes with 'git' on windows, and
        all the standard linux commands:
            less, grep, tail, ls, find, etc.

        try:
            PS> gci 'C:\Program Files\Git\usr\bin'

        It comes with all the standard linux commands:

        commands:
        - <https://community.chocolatey.org/packages/Less>
        - <https://github.com/BurntSushi/ripgrep>
        - <https://github.com/sharkdp/bat>
#>

### not as required, but nice to have
$Env:BAT_CONFIG_PATH = Join-Path $Env:Nin_Dotfiles '/cli/bat/.batrc' | Get-Item @eaIgnore
$Env:PYTHONSTARTUP = Join-Path $Env:Nin_Dotfiles '/cli/python/nin-py3-x-profile.py' | Get-Item @eaIgnore
$Env:RIPGREP_CONFIG_PATH = Join-Path $Env:Nin_Dotfiles '/cli/ripgrep/.ripgreprc' | Get-Item @eaIgnore

<#
My fav bat config: .batrc
    # keep colors, remove extras like line numbers
    --force-colorization
    --plain
#>

# If Fzf
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_OPTS = '--ansi --no-height'

# If RipGrep

<#
.ripgreprc
I suggest Smart or none , then opt-in as needed

    # --case-sensitive # -s
    --ignore-case # -i
    # --smart-case # -S
    --color=always
    --max-columns=300 # prevent spamming when it's a super long line

#>
function MinimalPrompt {
    <#
    .synopsis
        minimal, keeps the prompt in the same spot
    #>
    @(
        "`n`n"
        Get-Location
        'PS> '
    ) -join "`n"
}

function Format-RemoveAnsiEscape {
    <#
    .synopsis
        pipe any ansi escaped colors and it will remove ansi escaped colors
    .notes
        strips ansi colors (or optionally, all ansi control sequences)
    .DESCRIPTION
        ### Note on forcing colors

            I use --color=always

                I enable colors on almost everything, then if needed
                I pipe to 'stripAnsi'
                This means I never need a '--color=auto|none|never'

                PS> # this prints files with tons of colors

                    fd --color=always
                    | Get-Item # this would break

                PS> fd --color=always
                    | StripAnsi
                    | Get-Item # Resolves to a real Get-Item instance
        .LINK
            Ninmonkey.Console\Format-RemoveAnsiEscape
    #>

    [Alias('StripAnsi', 'Remove-AnsiEscape')]
    [cmdletbinding()]
    param(
        # pipe any text
        [Alias('Text')]
        [AllowNull()]
        [AllowEmptyString()]
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$InputObject,

        # misc label
        [alias('All')]
        [switch]$StripEverything
    )
    begin {
        # Regex from Jaykul
        $Regex = @{
            StripColor = '\u001B.*?m'
            StripAll   = '\u001B.*?\p{L}'
        }
    }
    process {
        if ($null -eq $InputObject) {
            return
        }
        if ($StripEverything) {
            $InputObject -replace $Regex.StripAll, ''
        } else {
            $InputObject -replace $Regex.StripColor, ''
        }

    }
}
