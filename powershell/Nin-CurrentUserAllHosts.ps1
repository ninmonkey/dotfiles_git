#Requires -Version 7.0.0
using namespace PoshCode.Pansies
using namespace System.Collections.Generic #
using namespace System.Management.Automation # [ErrorRecord]

Write-Warning "Find func: 'Lookup()'"
'reached bottom'

$script:__superVerboseAtBottom = $true # at end of profile load, turn on then
$script:__superTraceAtBottomLevel = 0
$script:__superEnableDebugAtBottom = $false
$DisabledForPerfTest = $false
$superVerboseAtTop = $false
$manualVSCodeIntegrationScript = $false

if ($superVerboseAtTop) {
    $VerbosePReference = 'continue'
    $WarningPreference = 'continue'
    $debugpreference = 'continue'

}


function b.wrapLikeWildcard {
    <#
    .SYNOPSIS
        converts like-patterns to always wrap wildcards
    .example
        'cat', 'CAT*' | b.wrapLikeWildcard
        '*cat*', '*cat*
    #>
   process {
    @( '*', $_.ToLower(), '*') -join '' -replace '\^\*{2}', '*' -replace '\*{2}$', '*'
   }
}

function b.fm {
    <#
    .SYNOPSIS
        Find member, sugar to show full name, and enforce wildcard
    .EXAMPLE
        Pwsh> $eis | b.fm fetch


    #>
   param( [string]$Pattern )
   process {
      $pattern = $pattern | b.wrapLikeWildcard
      # $pattern = @( '*', $patter.ToLower(), '*') -join '' -replace '\^\*{2}', '*'

        if($Pattern) {
            $_ | Find-Member $Pattern | Sort  Name | ft Name, DisplayString
        } else {
            $_ | Find-Member | Sort  Name | ft Name, DisplayString
        }
   }
}


function _srcGenerateClassRecord {
    <#
    .SYNOPSIS
        source generator, output is powershell
    .EXAMPLE
        Pwsh> $me = Get-JCUser -email '*jbolton*'
              _srcGenerateClassRecord $Me2 -WithFzf
    #>
    param( [object]$InputObject, [switch]$WithFzf )
    $propNames = $InputObject.psobject.Properties.name
    if($WithFzf) {
        $propNames = $propNames | & fzf '-m'
    }

     $propNames | %{
    '[string]${0}' -f @( $_  )

    }
    "`n`n# .... `n`n"
    $Inner  = $propNames | %{
    '    $This.{0} = $Object.{0}' -f @( $_  )
    } | Join-String -sep "`n"

@"
className ( [object]`$Object ) {
$Inner
}
"@

}

Write-Warning 'hardcoded PQ import'
. 'C:\Users\cppmo_000\SkyDrive\Documents\2022\Power-BI\My_Github\Ninmonkey.PowerQueryLib\source-pwsh\src\Text to PowerQueryLiterals.ps1'

# this is very important, the other syntax for UTF8 defaults to UTF8+BOM which
# breaks piping, like piping returning from FZF contains a BOM
# which actually causes a full exception when it's piped to Get-Item
[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()
Import-Module pansies
[PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'

$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::Ansi # wip dev,nin: todo:2022-03 # Keep colors when piping Pwsh in 7.2
<#
begin => section:consolidate somewhere
#>
function __profileGreet {
    <#
    .SYNOPSIS
        # greet function, do one per day ? currently not throttled
    .NOTES
        see: <https://devblogs.microsoft.com/powershell/announcing-the-release-of-get-whatsnew/#using-get-whatsnew>
    .LINK
        https://devblogs.microsoft.com/powershell/announcing-the-release-of-get-whatsnew/#using-get-whatsnew
    #>
    $binGlow = gcm -CommandType Application 'glow' -ea Ignore
    $splat = @{
        Daily = $true
        # Version = '7.3'
        Version =  '7.1', '7.2','7.3'
    }
    if(-not $binGlow ) {
        Get-WhatsNew @splat
    } else {
        Get-WhatsNew @splat
        | & $binGlow @('-')
    }
    hr 2 -fg '#8fc0df'
}

function _formatPath {
    <#
    .synopsis
        fix paths, translate to forward slash, like JSON
    .NOTES
    .example
        # from clipboard
        Pwsh> 'c:\foo\bar' | _formatPath
            'c:/foo/bar'
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Content,

        [Alias('toClip')][switch]$SaveClipboard
    )
    process {
        if (-not $Content) { $Content = Get-Clipboard }
        $render = $Content -replace '\\', '/'
        if ( $CopyToClipboard ) { $render | Set-Clipboard ; return; }
        return $render
    }
}


function Err.2xp {
    # sugar when in debug mode
    <#
    todo: param set that that will use

        err 0           : index paramset $error[0]
        err -num 3      : first 3     $error | select -first 3
        err 2:4         : $errors[2..4]

        alias Gerr      : autopipe global to Get-Error
        alias Rerr      : prints errors in reverse
        param tac       : errors

    #>
    [Alias('gErr🎨')]
    [CmdletBinding()]
    param( [switch]$Clear,
        [Alias('At')][int]$Index,
        [Alias('Number')] # 'count' and 'clear' are too close for tying
        [int]$Limit )

        # count still grabs the newest, but  output in reverse
        [Alias('tac')]
        [switch]$Reverse

    if ($Clear) { $global:error.Clear() }

    if ($Index) {
        $global:error | At $Index
        # | reverseIt # redundant, but intent
        return
    }
    if ($Limit) {
        $global:error
        | Select-Object -First $Count
        | ReverseIt
        return
    }

    return $global:error
}

function _errPreview {
    $Input | %{ $_ | io | ft Reported, Name, ShortValue, ShortType -auto }
}
function Err {
    # sugar when in debug mode
    <#
    todo: param set that that will use

        err 0           : index paramset $error[0]
        err -num 3      : first 3     $error | select -first 3
        err 2:4         : $errors[2..4]

    #>
    [OutputType('[object[]]')]
    param( [switch]$Clear,
        [Alias('At')][int]$Index,
        [Alias('Number')] # 'count' and 'clear' are too close for tying
        [int]$Limit,

        # select count still grabs the newest, this just prints newest at bottom
        [Alias('tac')][switch]$Reverse
        # [Alias('gerr')][switch]$ToGetError
    )

    if ($Clear) { $global:error.Clear() }

    if ($Index) {
        $global:error | At $Index
        return
        # | select -Index $INdex
    }
    if ($Limit) {
        if($Reverse) {
            $global:error | Select-Object -First $Limit | ReverseIt
        } else {
            $global:error | Select-Object -First $Limit
        }
        return
    }

    if($Reverse) {
        $global:error | ReverseIt
    } else {
        $global:error
    }
    return

    # return $global:error
}

function ToastIt {
    # mini sugar using defaults
    param(
        [parameter(Mandatory)]
        [string[]]$Text,

        [string]$Title,

        # [string]$Sound #
        [switch]$NotSilent
    )
    $textList = @(
        if ($title) { $title }
        $Text | Join-String -sep "`n"
    )

    $splatIt = @{
        # The parameter requires at least 0 value(s) and no more than 3
        Text   = $TextList
        Silent = $true
    }
    if ($NotSilent) { $SplatIt.Silent = $False }
    New-BurntToastNotification @splatIt
}

function unroll {
    <#
    .synopsis
        sugar to unroll items
    .description
        # Sometimes Join on proc, is simpler to first collect
        # example:

            function _Csv4 { process{ $Input | Join-String -sep ', ' }}
            'a'..'d' | _Csv4

            # out:

                a
                b
                c
                d

            'a'..'d' | rollup | _Csv4

            # out:

                a, b, c, d
    .link
        profile\unroll
    .link
        profile\rollup
    #>

    $input | ForEach-Object { $_ }
}
function rollup {
    <#
    .synopsis
    .description
        # Sometimes Join on proc, is simpler to first collect
        # example:

            function _Csv4 { process{ $Input | Join-String -sep ', ' }}
            'a'..'d' | _Csv4

            # out:

                a
                b
                c
                d

            'a'..'d' | rollup | _Csv4

            # out:

                a, b, c, d
    .link
        profile\unroll
    .link
        profile\rollup
    #>
    [OutputType('[object[]]')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin { [list[object]]$items = @() }
    process {
        $Items.AddRange( $InputObject )
    }
    end {
        , $Items
    }
}

function Fmd {
    # Find-Member abbrviated, simplified defaults
    # param(
    #     [Parameter(Mandatory,ValueFromPipeline)]
    # )
    param(
        [switch]$PassThru
    )
    process {
        if ($PassThru ) {
            return ($input | Fm | Sort-Object -Unique Name)
        }

        $input | Fm | Sort-Object -Unique Name | Format-Table -AutoSize -Wrap
    }
}
function iot_both {
    param(
        $Obj
        # [switch]
    )
    $Obj | Fmd
    Hr
    $Obj | iot2
}
function _colorHexToRgb {
    # oh gosh. terrible hack.
    [OutputType('System.Drawing.Color')]
    param( [string]$HexStr )
    if ($HexStr.Length -eq 8) { throw 'wip' }

    $alpha = 0xff
    $strRgb = $HexStr.Substring(0, 6)
    $r, $g, $b = [rgbcolor]::FromRgb( $strRgb ).ToRgb()

    return [System.Drawing.Color]::FromArgb( $alpha, $r, $g, $b)
}
class excelColor {
    [int]$Red = 0xff
    [int]$Green = 0xff
    [int]$Blue = 0xff
    [int]$Alpha = 0xff
    [System.Drawing.Color]$Color = 'white'


    excelColor ( [string]$HexStr ) {
        $this.Color = [excelColor]::FromHex( $HexStr )

    }
    excelColor ( [int]$Red, [int]$Green, [int]$Blue ) {
        $This.Red = $Red
        $This.Green = $Green
        $This.Blue = $Blue
        $This.Color = [excelColor]::FromRGBA( $this.Red, $This.Green, $This.Blue )

    }
    excelColor ( [int]$Red, [int]$Green, [int]$Blue, [int]$Alpha ) {
        $This.Red = $Red
        $This.Green = $Green
        $This.Blue = $Blue
        $This.Alpha = $Alpha
        $This.Color = [excelColor]::FromRGBA( $this.Red, $This.Green, $This.Blue, $This.Alpha )
    }

    # static [excelColor] FromHex( [string]$HexStr) {
    static [System.Drawing.Color] FromHex( [string]$HexStr) {
        [System.Drawing.Color]$res = _colorHexToRgb -HexStr $HexStr
        return $res
    }
    static [System.Drawing.Color] FromRGB( [int]$Red, [int]$Green, [int]$Blue ) {
        return [System.Drawing.Color]::FromArgb( $Red, $Green, $Blue)
    }
    static [System.Drawing.Color] FromRGBA( [int]$Red, [int]$Green, [int]$Blue, [int]$Alpha ) {
        return [System.Drawing.Color]::FromArgb( $Alpha, $Red, $Green, $Blue)
    }

}

<#
todo: move above to profile module
#>

if ($env:TERM_PROGRAM -eq 'vscode') {
    #  . "$(code --locate-shell-integration-path pwsh)"
    # Note: is this only rquired if injection fails?
    if ( $manualVSCodeIntegrationScript ) {
        . "$(code.cmd --locate-shell-integration-path pwsh)"
    }
}

<#
end <== section:consolidate somewhere
#>


# must-have guard aliases, that prevent shadowing, or prevent invoking
# binary by accident if a module isn't imported
Set-Alias 'Label' -Value 'Ninmonkey.Console\Write-ConsoleLabel'
Set-Alias 'sc' -Value 'Set-Content'
Set-Alias 'To->Csv' -Value 'ConvertTo-Csv'
Set-Alias 'To->Json' -Value 'ConvertTo-Json'
Set-Alias 'Join-Hashtable' -Value 'Ninmonkey.Console\Join-Hashtable'
# Set-Alias 'Join-Hashtable' -Value 'Ninmonkey.Console\Join-Hashtable'

# __countDuplicateLoad

Write-Debug "run --->>>> '$PSCommandPath'"

<#
don't forget to collect

Write-Warning '🦈'

# Import-Module Dev.Nin -Force
'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\buffer\2021-07',
'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\buffer\2021-10'
| Get-Item | Where-Object { Test-Path $_ } | ForEach-Object FullName
| Sort-Object -Unique
| Join-String -sep "`n  - " -DoubleQuote -op "experiments🧪`n  - "

#>


# I am not sure what's the right *nix env vars for encoding
# grep specifically required this
$env:LC_ALL = 'en_US.utf8'
$__ConfigOnlyuseFast = $false

$env:PATH += ';', 'G:\programs_nin_bin' -join ''
$env:PATH += ';', "$Env:UserProfile/SkyDrive/Documents/2022/Pwsh/my_Github" -join ''

if (-not( Get-Module BDG_lib -ea ignore)) {
    $Env:PSModulePath += ';', (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self')
    # 'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib\
}
if ($False) {
    # if you want random window names
    Import-Module NameIt
    $Host.UI.RawUI.WindowTitle = NameIt\Invoke-Generate '[noun]-[syllable]-[verb]-[syllable]-[color]'
    $Host.UI.RawUI.WindowTitle = NameIt\Invoke-Generate '[noun]-[verb]-[color]'
}




<#
    [section]: Seemingly Sci imports
#>
$pathSeem = Get-Item -ea continue 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
if (! $PathSeem) {
    Write-Warning "Attempted to import SeeminglySci failed: 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'"
} else {
    Import-Module pslambda -DisableNameChecking
    Import-Module -DisableNameChecking (Get-Item -ea stop (Join-Path $PathSeem 'Utility.psm1'))
    Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
    Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
    Write-Verbose 'SeeminglySci: Imported'
}
$me = Get-Process -Id $PID
if ($me.Parent.Name -match 'Azure') {
    $IsAzureDataStudio = $True
}
# if($Host.Name -match 'studio code host') {
#     $IsAzureDataStudio = $true
#     'skippping VSCode host...' | write-warning
# }
# Write-Warning '㏒ : IsAzureDataStudio?'
if (! $IsAzureDataStudio ) {
    Write-Warning '     ㏒ : NinIsLoaded?d'
    if ( Get-Module 'Ninmonkey.Console') {

    } else {
        Write-Warning '㏒ : Nin failed, skipping command predictor'
    }
} else {
    Write-Warning 'skipping predictor because of ADS...'
}

if ($__ConfigOnlyuseFast) { return }

<#
    [section]: essential imports
#>
Import-Module Ninmonkey.Console -DisableNameChecking
Import-Module Dev.Nin -DisableNameChecking

Write-Warning '㏒ : Load-NinCoreAliases?'
if (Get-Module 'Ninmonkey.Console') {
    # slow
    Enable-NinCoreAlias
    Ninmonkey.Console\nin.ImportPSReadLine MyDefault_HistListView
} else {
    Write-Warning '㏒ : Nin failed, skipping aliases'
}

<#
    [section]: secondary imports
#>


$Env:PSModulePath += ';', (Get-Item -ea ignore 'G:\2021-github-downloads\PowerShell\Santisq🧑\PSTree\') -join ''
$Env:PSModulePath += ';', (Get-Item -ea ignore 'G:\2021-github-downloads\PowerShell\Santisq🧑\Get-Hierarchy\') -join ''
$Env:RIPGREP_CONFIG_PATH = (Get-Item 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\cli\ripgrep\.ripgreprc')


<#
first: 🚀
    - [ ] ask about how to namespace enums?

    - [ ] step pipepline
        do { Set-Content @someExistingVar }.GetSteppablePipeline() and play with it

    - [ ] edit sci's bits to a _colorizeBits

#>
# Get-Command __doc__ | Join-String -op ' loaded?'
# see also: C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\buffer\2021-10\AddDocstring-Sketch\Add-Docstring-sketch-iter3.ps1

# Export-ModuleMember -Function '__PromptMini'
function __PromptMini {
    <#
    .synopsis
        minimal (more-so), only dependency is Pansies (actually I could remove that)
    #>
    $c = @{
        Yellow = $PSStyle.Foreground.FromRgb('#ffff00')
        Gray40 = $PSStyle.Foreground.FromRgb(
            255 * 0.4, 255 * 0.4, 255 * 0.4 )

        Gray80 = $PSStyle.Foreground.FromRgb(
            255 * 0.8, 255 * 0.8, 255 * 0.8 )

        Reset  = $PSStyle.Reset
    }
    @(
        # PSStyle.Foreground.FromRgb($C.Yellow), 'hi', -join ''
        $true ? "`n" : ''
        if ($Error.Count -gt 0) {
            ' '
            $C.Yellow
            $Error.Count
            ' '
            # $Error.count | Join-String -os ' ' | New-Text -fg 'yellow'
        }
        $C.Gray40
        $PSVersionTable.PSVersion.ToString()
        $C.Gray80
        '🐒> '
        # New-Text -fg gray80 ''
        $c.Reset
    ) -join ''
}

function __noop__ {
    <#
    .synopsis
        "polyfill" air qoute, it's a stub that just consumes all pipes or arguments
    .example
        # none of these will error
        0..4 | __noop__
        0..4 | __noop__ 'foo'
        __noop__ 'foo'
        __noop__ -foo bar
    #>
    param()
}

function Warn {
    [cmdletbinding()]
    [Alias('Warn🛑')]
    param(
        [AllowEmptyCollection()]
        [AllowNull()]
        [Alias('Message', 'Warn')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if (! $__ninConfig.LogFileEntries) {
            return
        }

        # if (! $__ninConfig.debug.GlobalWarn) {
        if ($null -eq $InputObject) {
            return
        }
        if ($__ninConfig.debug.GlobalWarn ?? $__warn) {
            if ($InputObject) {
                $InputText | Write-Warning
            }
            return
        }
    }
}

if ($false) {

    'should not be required:'

    Remove-Module 'psfzf', 'psscripttools', 'zlocation' -ea silentlycontinue
    'psfzf', 'psscripttools', 'zlocation' | Join-String -sep ', ' -op 'Removing: ' | Warn🛑
}

# next: refactor as 'ThrottledTask's

if (!(Test-Path (Get-Item Temp:\complete_gh.ps1))) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Generate "complete_gh.ps1"'
    gh completion --shell powershell | Set-Content -Path temp:\complete_gh.ps1
} else {
    Write-Verbose '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> complete_gh.ps1'
    . (Get-Item Temp:\complete_gh.ps1)
}

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\'
    $Env:PSModulePath

) -join ';'

if ($OneDrive.Enable_MyDocsBugMapping) {
    $Env:PSModulePath = @(
        $Env:PSModulePath
        'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell'
    ) -join ';'
}

<#
    - initalizes '$__ninConfig'
#>
if ($false -and 'future') {
    #     $__rConfigf ??= @{} | __doc__ "`$__ninConfig initializes here '$PSCommandPath'"
    # fn __doc__ will auto-collect filepaths automatically

    @'
    $__ninConfig.LogFileEntries
    later I can run

        help($__ninConfig)  | __doc__ "`$__ninConfig initializes here: '$PSCommandPath'"
        help($__ninConfig)  | __doc__ "`$__ninConfig initializes'"

        help($__ninConfig.SomeFeature)
'@
}


$script:__ninConfig ??= @{
    # HackSkipLoadCompleters     = $true
    EnableGreetingOnLoad       = $true
    UseAggressiveAlias         = $true
    ImportGitBash              = $true  # __doc__: Include gitbash binaries in path+gcm
    UsePSReadLinePredict       = $true  # __doc__: uses beta PSReadLine [+Predictor]
    UsePSReadLinePredictPlugin = $true # __doc__: uses beta PSReadLine [+Plugin]
    Import                     = @{
        SeeminglyScience = $true
    }
    Config                     = @{
        PSScriptAnalyzerSettings2 = Get-Item -ea ignore 'C:\Users\cppmo_000\Documents\2020\dotfiles_git\vs code profiles\user\PSScriptAnalyzerSettings.psd1'
        PSScriptAnalyzerSettings  = Get-Item -ea ignore 'C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell\PSScriptAnalyzerSettings.psd1'
    }
    OnLoad                     = @{
        IgnoreImportWarning = $true # __doc__: Ignore warnings from any modules imported on profile first load
    }
    Prompt                     = @{
        # __doc__: Controls the look of your prompt, not 'Terminal'
        # __uri__: Terminal
        Profile                      = 'default' # __doc__: errorSummary | debugPrompt | bugReport | oneLine | twoLine | spartan | default
        # Profile = 'default' #
        ForceSafeMode                = $false
        IncludeGitStatus             = $false # __doc__: Enables Posh-Git status
        PredentLineCount             = 1 # __doc__: number of newlines befefore prompt
        IncludePredentHorizontalLine = $false
        BreadCrumb                   = @{
            MaxCrumbCount    = -1 # __doc__: default is 3. Negative means no limit
            CrumbJoinText    = ' '
            CrumbJoinReverse = $true
            ColorStart       = '#CD919E' # __doc__: default is random. the most significant bit of breadcrumb
            ColorEnd         = '#454545' # __doc__: default is random. the least significant bit of breadcrumb

        }
    }
    Terminal                   = @{
        # __doc__: Detects or affects the environment, not 'Prompt'
        # __uri__: Prompt
        <#
        Terminal.CurrentTerminal = <code | 'Code - Insiders' | 'windowsterminal' | ... >
        Terminal.IsVsCode = <bool> # true when code or code insiders
        Terminal.IsVSCodeAddon_Terminal = <bool> # whether it's the addon debug term, or a regular one
        Terminal.ColorMode = [PoshCode.Pansies.ColorMode]

        others terminals:
            pwsh7 from start -> comes up as 'explorer'
            cmd /C Pwsh -> comes up as 'cmd'

        #>
        ColorBackground        = '#2E3440' # defer typing until later?
        CurrentTerminal        = (Get-Process -Id $pid).Parent.Name # cleaned up name below
        IsVSCode               = $false # __doc__: this is a VS Code terminal
        IsVSCodeAddon_Terminal = $false # __doc__: this is a [vscode-powershell] extension debug terminal
        #IsAdmin = Test-UserIsAdmin # __doc__: set later to delay load. very naive test. just for styling
    }
    IsFirstLoad                = $true
} #| __doc__ 'root to user-facing configuration options, see files and __doc__ for more'

if ($env:NINProfileForceSafeMode) {
    $__ninConfig.Prompt.ForceSafeMode = $true
}
# $__ninConfig.Prompt.ForceSafeMode = $true

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> main body start'
if ($OneDrive.Enable_MyDocsBugMapping) {
    $__ninConfig.Config['PSScriptAnalyzerSettings'] = Get-Item -ea ignore 'C:\Users\cppmo_000\Skydrive\Documents\2021\dotfiles_git\powershell\PSScriptAnalyzerSettings.psd1'
}
& {
    $colorA = '#CD919E'
    $colorB = '#454545'
    ($__ninConfig.Prompt.BreadCrumb).ColorStart = $colorB
    ($__ninConfig.Prompt.BreadCrumb).ColorEnd = $colorA
    ($__ninConfig.Prompt.BreadCrumb).CrumbJoinReverse = $false
    $__ninConfig.Prompt.BreadCrumb.CrumbJoinText = ' ▸ ' | New-Text -fg 'gray35'
}

<#
npm /w node.js
    https://docs.npmjs.com/try-the-latest-stable-version-of-npm#upgrading-on-windows
$toadd = Get-Item -ea Continue "$Env:AppData\Npm"
$Env:path = $toAdd, $Env:path -join ';'
#>



function _reRollPrompt {
    # reset vars used when random fallbacks
    ($__ninConfig.Prompt.BreadCrumb).ColorStart = $null
    ($__ninConfig.Prompt.BreadCrumb).ColorEnd = $null
    Reset-RandomPerSession -Name 'prompt.crumb.colorBreadEnd', 'prompt.crumb.colorBreadStart'
}

<#
env vars to check
'ChocolateyInstall', 'ChocolateyToolsLocation', 'FZF_CTRL_T_COMMAND', 'FZF_DEFAULT_COMMAND', 'FZF_DEFAULT_OPTS', 'HOMEPATH', 'Nin_Dotfiles', 'Nin_Home', 'Nin_PSModulePath', 'NinNow', 'Pager', 'PSModulePath', 'WSLENV', 'BAT_CONFIG_PATH', 'RIPGREP_CONFIG_PATH', 'Pager', 'PSMODULEPATH'
#>
function _reloadModule {
    # reload all dev modules in my profile's scope
    [cmdletBinding()]
    param(
        [cmdletbinding()]
        [parameter(Position = 0)]
        [ArgumentCompletions('BasicModuleTemplate', 'CollectDotfiles', 'Dev.Nin', 'Jake.Pwsh.AwsCli', 'ModuleData', 'ninLog', 'Ninmonkey.Console', 'Ninmonkey.Factorio', 'Ninmonkey.Profile', 'Ninmonkey.TemplateText', 'Portal.Powershell', 'Powershell.Cv', 'Powershell.Jake', 'Template.Autocomplete')]
        [string[]]$Name,
        # Temporarily enable warnings
        [parameter()][switch]$AllowWarn,

        # normally _enumerateMyModule is used, verses this hard coded value
        [parameter()][switch]$ForceDefault
    )
    $hardCodedNames = @(
        # 'Ninmonkey.Profile'
        'Dev.Nin'
        'Ninmonkey.Console'
        'ninLog'
        # 'BasicModuleTemplate'
        # 'CollectDotfiles'
        # 'Jake.Pwsh.AwsCli'
        # 'Ninmonkey.Factorio'
        # 'Ninmonkey.TemplateText'
        'ModuleData'
        # 'Portal.Powershell'
        # 'Powershell.Cv'
        # 'Powershell.Jake'
        # 'Template.Autocomplete'
    )
    # quickly reload my modules for dev
    $importModuleSplat = @{
        # Name = 'Ninmonkey.Console', 'Dev.nin'
        Name                = _enumerateMyModule
        Force               = $true
        DisableNameChecking = $true
        Scope               = 'Global'
    }

    if ($ForceDefault ) {
        $importModuleSplat = $hardCodedNames
    }

    $importModuleSplat | Format-Table -AutoSize -Wrap | Out-String | Write-Debug

    Write-Warning 'todo: Stopwatch here for full-time and per-module timings'
    function _tryImportSingle {
        param( [string]$ModuleName, [hashtable]$importSplat ) {

        }
        $importSplat['Scope'] = 'global'
        $importSplat | Format-Table | Out-String | Write-Debug
        try {
            # Ignore warnings, allow errors
            if (!$AllowWarn) {
                Import-Module @importSplat 3>$null
            } else {
                Import-Module @importSplat
            }
        } catch {
            Write-Error -ea continue -m (
                'Failed loading: {0}{1}{2}' -f @(
                    $ModuleName
                    "`n"
                    "Exception: $_"
                )
            )

        }
    }
    $names = @($importModuleSplat.Name)
    $importModuleSplat.Remove('Name')
    $names | ForEach-Object {
        # to ask: where is [PSScriptCmdlet] in docs, it's not, it's sealed?

        Write-Information 'infa part is wip'
        # $PSCmdlet.WriteInformation(
        #     <# messageData: #> $_, $null
        #     <# tags: #> )
        [console]::Write('.')
        _tryImportSingle -ea continue -ModuleName $_ -ImportSplat $importModuleSplat
    }
}
<#
    $wil = Find-Member -MemberType Method 'writeinformation'
    $wil | ft
    $PSCmdlet.WriteInformation
    [InformationRecord]::New('bob', 'text')
    $ir = [InformationRecord]::New('bob', 'text')
    $ir | fl *
    $ir | % gettype
    $ir | % gettype()
    $ir | jProp
    $ir | jProp | sort type
    $ExecutionContext
    $ExecutionContext | Jprop
#>

if ($PSEditor) {
    Import-EditorCommand -Module EditorServicesCommandSuite
}

$eaIgnore = @{
    'ErrorAction' = 'Ignore'
    'PassThru'    = $True
}
@(

    Set-Alias 'Repl->Pt
    Py' -Value 'ptpython' -Description 'repl from: <https://github.com/prompt-toolkit/ptpython>'
    Set-Alias @eaIgnore 'rel' -Value '_reloadModule'

    # Set-Alias 'Join-Hashtable' -Value 'Ninmonkey.Console\Join-Hashtable' -Description 'to prevent shadowing by PSSCriptTools'
    Set-Alias @eaIgnore -Name 'DismSB' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'sci''s SB to Expressions module'
    Set-Alias @eaIgnore -Name 'Sci->Dism' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'tags: Sci,DevTool; sci''s SB to Expressions module'
    Set-Alias @eaIgnore -Name 'Dev->SBtoDismExpression' -Value 'ScriptBlockDisassembler\Get-ScriptBlockDisassembly' -Description 'tags: Sci,DevTool; sci''s SB to Expressions module'
)
# & {
$parent = (Get-Process -Id $pid).Parent.Name
if ($parent -eq 'code') {
    $__ninConfig.Terminal.CurrentTerminal = 'code'
    $__ninConfig.Terminal.IsVSCode = $true
} elseif ($parent -eq 'Code - Insiders') {
    $__ninConfig.Terminal.CurrentTerminal = 'code_insiders'
    $__ninConfig.Terminal.IsVSCode = $true
} elseif ($parent -eq 'windowsterminal') {
    # preview still uses this name
    $__ninConfig.Terminal.CurrentTerminal = 'windowsterminal'
}
if ($pseditor) {
    # previously was: if (Get-Module 'PowerShellEditorServices*' -ea ignore) {
    # Test whether term is running, in order to run EditorServicesCommandSuite
    $__ninConfig.Terminal.IsVSCodeAddon_Terminal = $true
}
# if ($psEditor) {
#     Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> EditorServicesCommandSuite'
#     $escs = Import-Module EditorServicesCommandSuite -PassThru -DisableNameChecking
#     if ($null -ne $escs -and $escs.Version.Major -lt 0.5.0) {
#         Import-EditorCommand -Module EditorServicesCommandSuite
#     }
# }
# if ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) {
#     Import-Module EditorServicesCommandSuite
# Set-PSReadLineKeyHandler -Chord "$([char]0x2665)" -Function AddLine # work around for shift+enter pasting a newline
# }
# }


<#
    [section]: Nin.* Environment Variables


## Rationale for '$Env:2021' or '$Env:Now'

    verses using a profile-wide '$Nin2021'

    When using filepath parames like
        $x | copy-item -Destination '$NinNow\something

    Tab completion does not complete. but environment variables will.
    This means you have to  remember exact filepaths.

    Using Env vars allows typing:

        -dest $env:Nin2021\*bug'

        which resolves to
            'C:\Users\cppmo_000\Documents\2021\reporting_bugs\


#>
# set vars if not already existing
$Env:TempNin ??= "$Env:UserProfile\SkyDrive\Documents\2021\profile_dump"
$Env:Nin_Home ??= "$Env:UserProfile\Documents\2021" # what is essentially my base/root directory
$Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
$env:NinNow = "$Env:Nin_Home"


# Env-Vars are all caps because some apps check for env vars case-sensitive
# double check that profile isn't failing to set the global env vars
$Env:LESS ??= '-R'
$ENV:PAGER ??= 'bat'
# $ENV:PAGER ??= 'less -R'
$Env:Nin_PSModulePath = "$Env:Nin_Home\Powershell\My_Github" | Get-Item -ea ignore # should be equivalent, but left the fallback just in case
$Env:Nin_PSModulePath ??= "$Env:UserProfile\Documents\2021\Powershell\My_Github"

$Env:Pager ??= 'less' # todo: autodetect 'bat' or 'less', fallback  on 'git less'

# now function:\help tests for the experimental feature and gcm on $ENV:PAger
$Env:Pager = 'less -R' # check My_Github/CommandlineUtils for- better less args

$ENV:PAGER = 'bat'
$ENV:PYTHONSTARTUP = Get-Item -ea continue "${Env:Nin_Dotfiles}/cli/python/nin-py3-x-profile.py"

# if (! (Test-Path $Env:BAT_CONFIG_PATH)) {
#     $maybeRelative = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc #@eaIgnore
#     if ($maybeRelative) {
#         $Env:BAT_CONFIG_PATH = $MaybeRelativePath
#     }
# }
$Env:BAT_CONFIG_PATH = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc #@eaIgnore
<#
bat
    --force-colorization --pager <command>
    --pager "Less -RF"
    #>




<#
# enable specific bugfix if you have 'PSUtil'
if (Get-Module 'psutil' -ListAvailable -ea ignore) {
    # extra case to make sure it runs until 'IsVSCode' is perfect
    $StringModule_DontInjectJoinString = $true # to fix psutil, see: <https://discordapp.com/channels/180528040881815552/467577098924589067/750401458750488577>
}
#>

# if (Import-Module 'Pansies' -ea ignore) {
#     [PoshCode.Pansies.RgbColor]::ColorMode = [PoshCode.Pansies.ColorMode]::Rgb24Bit
#     $__ninConfig.Terminal.ColorMode = [PoshCode.Pansies.RgbColor]::ColorMode
# }


# 'Config: ', $__ninConfig | Join-String | Write-Debug
<#
check old config for settings
    <C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinSettings.ps1>

Shared entry point from:
    $Profile.CurrentUserAllHosts
aka
    $Env:UserProfile\Documents\PowerShell\profile.ps1

#>

<#

    [section]: VS ONLY


#>


<#

    [section]: $PSDefaultParameterValues

        details why: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.1#changing-the-default-encoding>
#>
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
# $PSDefaultParameterValues['Code-Venv:Infa'] = 'continue'    # test it off
$PSDefaultParameterValues['Install-Module:Verbose'] = $true

$PSDefaultParameterValues['New-Alias:ErrorAction'] = 'SilentlyContinue' # mainly for re-running profile in the same session
$PSDefaultParameterValues['Ninmonkey.Console\Get-ObjectProperty:TitleHeader'] = $true
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Ninmonkey.Console\Out-Fzf:OutVariable'] = 'fzf'
$PSDefaultParameterValues['Ninmonkey.Console\Out-Fzf:OutVariable'] = 'fzf'
$PSDefaultParameterValues['Ninmonkey.Console\Out-Fzf:MultiSelect'] = $true
$PSDefaultParameterValues['Set-NinLocation:AlwaysLsAfter'] = $true
$PSDefaultParameterValues['Microsoft.PowerShell.Core\Get-Help:detailed'] = $true
$PSDefaultParameterValues['Get-Help:detailed'] = $true
$PSDefaultParameterValues['help:detailed'] = $true
$PSDefaultParameterValues['Dev.Nin\Measure-ObjectCount:Infa'] = 'Continue'


<#
    [section]: $PSDefaultParameterValues

        But settings for dev.nin / meaning any of these could be obsolete
        because it's experimental

    todo future:
        - [ ] linter warn when parameter name isn't valid, like a code change, or datatype change
#>
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'

# $PSDefaultParameterValues['Dev.Nin\Invoke-VSCodeVenv:ForceMode'] = 'insiders' # < code | insiders >
# $PSDefaultParameterValues['Code-Venv:ForceMode'] = 'insiders' # < code | insiders >
# $PSDefaultParameterValues['Dev.Nin\Invoke-VSCodeVenv:infa']='ignore'
# Dev.Nin\Invoke-VSCodeVenv
$PSDefaultParameterValues['Select-NinProperty:OutVariable'] = 'SelProp'
# $PSDefaultParameterValues['Ninmonkey.Console\Get-:TitleHeader'] = $true # Was this a typo?


$PSDefaultParameterValues['Get-RandomPerSession:Verbose'] = $true
$PSDefaultParameterValues['Reset-RandomPerSession:Verbose'] = $true
$PSDefaultParameterValues['Invoke-GHRepoList:Infa'] = 'Continue'
# $PSDefaultParameterValues['ls:dir'] = $true
$PSDefaultParameterValues['_PeekAfterJoinLinesMaybe:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\_Peek-NewestItem:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\Peek-NewestItem:infa'] = 'Continue'
$PSDefaultParameterValues['Dev.Nin\Pipe->Error:infa'] = 'Continue'
# $PSDefaultParameterValues['Dev.Nin\Pipe->*:infa'] = 'Continue'

# Import-Module Ninmonkey.Console

# function _profileEventOnFinalLoad {
#     <#
#     minimal final function ran on end
#     #>
#     Write-Debug '$__ninConfig.EnableGreetingOnLoad'
#     function _writeTodoGreeting {
#         Get-Gradient -StartColor gray20 -EndColor gray50 -Width $seg -ColorSpace Hsl
#         | Join-String
#         Hr
#         # h1 'Todo' | New-Text -fg yellow -bg magenta
#         '🐵'
#     }

#     if ($__ninConfig.EnableGreetingOnLoad) {
#         _writeTodoGreeting
#     }

#     if (
#         ((Get-Location).Path -eq (Get-Item "$Env:Userprofile" )) -and
#         $__ninConfig.Terminal.IsVSCode -and
#         $__ninConfig.IsFirstLoad
#     ) {
#         # if Vs Code didn't set a directory, fallback to pwsh
#         # Set-Location "$Env:UserProfile/Documents/2021/Powershell"
#         # $Env:UserProfile/SkyDrive/Documents/2022/Pwsh/

#     }
#     "FirstLoad? $($__ninConfig.IsFirstLoad)" | Write-Host -fore green

#     $__ninConfig.IsFirstLoad = $false

# }


function Get-ProfileAggressiveItem {
    <#
    .synopsis
        todo: refactor into profile. Which *super* aggressive aliases are being used?
    .description
        *super* aggressive aliases, these are not suggessted to be used
    .example
        PS> Get-ProfileAggressiveItem | Fw
    #>
    param ()
    $meta = [ordered]@{}
    $meta['Alias'] = Get-Alias -Name 's', 'cl', 'f', 'cd' -ea silentlycontinue -Scope global

    $meta['Types'] = @(
        'psco'
    ) | ForEach-Object {
        $typeInstance = $_ -as 'type'
        [pscustomobject]@{
            Name = $_
            Type = $typeInstance ?? '$null'
        }
    }
    [PSCustomObject]$meta
}

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> final body'
}



if ($true) {
    # todo: now it should fully run in profile
    # $__innerStartAliases = Get-Alias # -Scope local
    $splatAlias = @{
        Scope       = 'global'
        ErrorAction = 'Ignore'
    }

    # todo:  # can I move this logic to profile? at first I thought there was scope issues, but that doesn't matter
    # Remove-Alias -Name 'cd' -ea ignore
    Remove-Alias -Name 'cd'-ea ignore -Scope global -Force
    New-Alias @splatAlias -Name 'cd' -Value Ninmonkey.Console\Set-NinLocation -Description 'A modern "cd", Personal Profile'
    Set-Alias @splatAlias -Name 's' -Value Select-Object -Description 'aggressive: to override other modules'
    Set-Alias @splatAlias -Name 'cl' -Value Set-Clipboard -Description 'aggressive: set clip'
    Set-Alias @splatAlias -Name 'resCmd' -Value 'Resolve-CommandName' -Description '.'
    New-Alias @splatAlias 'CodeI' -Value 'code-insiders' -Description 'quicker cli toggling whether to use insiders or not'
    # New-Alias 'jp' -Value 'Join-Path' -Description '[Disabled because of jp.exe]. quicker for the cli'
    # New-Alias @splatAlias 'joinPath' -Value 'Join-Path' -Description 'quicker for the cli'
    New-Alias @splatAlias 'jp' -Value 'Join-Path' -Description 'quicker for the cli'
    New-Alias @splatAlias 'js' -Value 'Join-String' -Description 'quicker for the cli'

    # if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
    #     New-Alias -Name 'f' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    # }

    # For personal profile only. Maybe It's too dangerous,
    # should just use 'go' instead? It's not in the actual module
    # Usually not a great idea, but this is for a interactive command line profile

    $Profile | Add-Member -NotePropertyName 'NinProfileMainEntryPoint' -NotePropertyValue $PSCommandPath -ea Ignore
    $Profile | Add-Member -NotePropertyName '$Profile' -NotePropertyValue (Get-Item $PSCommandPath) -ea Ignore
    # $historyLists = Get-ChildItem -Recurse "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine" -Filter '*_history.txt'
    # $historyLists = Get-ChildItem (Split-Path (Get-PSReadLineOption).HistorySavePath) *history.txt # captures both, might even help on *nix
    # $Profile | Add-Member -NotePropertyName 'PSReadLineHistory' -NotePropertyValue $historyLists -ErrorAction Ignore
    $Profile | Add-Member -NotePropertyName 'PSDefaultParameterValues' -NotePropertyValue $PSCommandPath -ErrorAction Ignore
    $Profile | Add-Member -NotePropertyName '$Profile.PrevGlobalEntryPoint' -NotePropertyValue 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-PrevGlobalProfile_EntryPoint.ps1' -ErrorAction Ignore

    # experimenting:
    $Accel = [PowerShell].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $Accel::Add('po', [System.Management.Automation.PSObject])
    $Accel::Add('obj', [System.Management.Automation.PSObject])
    # expected values:
    # "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    # "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\Visual Studio Code Host_history.txt"



    # $MyInvocation.MyCommand.ModuleName
    # $MyInvocation.MyCommand.Name
    # $MyInvocation.PSScriptRoot
    # $MyInvocation.PSCommandPath
    # $PSScriptRoot
    # $PSCommandPath
    if ($false) {
        # Neither way was dynamically capturing mine, I had hoped local scope  would be good enough.
        $deltaAliasList = Get-Alias #-Scope local
        | Where-Object { $_.Name -notin $__innerStartAliases.Name }

        $deltaAliasList | Sort-Object | Join-String -sep "`n" {
            "Alias: $($_.Name)" | New-Text -fg pink
        }
    }
}

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> start PSReadLine'

<# play nice
(gcm 'Set-PSReadLineOption' | % Parameters | % keys) -contains 'PredictionViewStyle'
(gcm 'Set-PSReadLineOption' | % Parameters | % keys) -contains 'PredictionSource'
#>

$eaIgnore = @{
    ErrorAction = 'ignore'
}

if ($true) {
    Write-Warning "remove temp inline definition: '$PSCommandPath'"
    function Test-CommandHasParameterNamed {
        <#
    .synopsis
        Quick test if a parameter exists, without throwing
    .description
        sugar for:
            (Get-Command 'Set-PSReadLineOption'
            | ForEach-Object Parameters | ForEach-Object keys) -contains 'PredictionViewStyle'
    .notes
        future: move to ninmonkey/Testning

    .example
        Test-CommandHasParameterNamed -Command 'Microsoft.PowerShell.Management\Get-ChildItem' -Param 'Path'
    .example
        Test-CommandHasParameterNamed 'ls' -Param 'Path'
    #>
        [outputType([System.Boolean])]
        [CmdletBinding(DefaultParameterSetName = 'TestNamed')]
        param(
            # Which command ? # future: complete command names
            [ALias('Name')]
            [Parameter(Mandatory, Position = 0, ParameterSetName = 'TestNamed')]
            [Parameter(Mandatory, Position = 0, ParameterSetName = 'ListNames')]
            [string]$CommandName,

            # Give the parameter name
            [Parameter(
                Mandatory, Position = 1, ValueFromPipeline,
                ParameterSetName = 'TestNamed'
            )]
            [string]$ParameterName,

            # enumerate possible parameters
            [Parameter(Mandatory, ParameterSetName = 'ListNames')]
            [switch]$List
        )
        process {
            # sugar for:
            #     (Get-Command 'Set-PSReadLineOption'
            #     | ForEach-Object Parameters | ForEach-Object keys) -contains 'PredictionViewStyle'
            switch ($PSCmdlet.ParameterSetName) {
                'TestNamed' {
                    $cmd = rescmd $CommandName
                    $cmd.Parameters.Keys -contains $ParameterName

                }
                'ListNames' {
                    $cmd = rescmd $CommandName
                    $cmd.Parameters.Keys | Sort-Object -Unique

                }

                default {
                    Write-Error -Message "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName) at '$($PSCommandPath)'" #-TargetObject $PSCmdlet
                }
            }

        }
        end {
            Write-Warning "Remove this inline hack: '$PSCommandPath'"
        }
    }
}

function nin.ImportPSReadLine.profile {
    <#
    AddLine
        moves to next line, bringing any remaining text with it
    AddLineBelow
        Adds and moves to next line, leaving text where it was.

     now VS Code supports it, making it the default
    #>
    param(
        # Default includes list view but not
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions(
            'MyDefault_HistListView',
            'Using_Plugin'
        )]
        [string]$ImportType
    )



    switch ($ImportType) {
        'Using_Plugin' {
            Write-Debug '
            import: CompletionPredictor
                1] PredictionSource: History+Plugin
        '
            Import-Module CompletionPredictor -Verbose -Scope global
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin
            break
        }
        'MyDefault_HistListView' {
            Write-Debug '
            1] predict list view
            2] ctrl+f/d
            3] alt+enter    addLine
            4] ctrl+enter   insertLine

            predictSource: History, style: ListView
            '

            Set-PSReadLineOption @eaIgnore -PredictionSource History
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView

            Set-PSReadLineOption -ContinuationPrompt ((' ' * 4) -join '')

            Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
            Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function BackwardWord
            # Get-PSReadLineKeyHandler -Bound -Unbound | Where-Object key -Match 'Enter|^l$' | Write-Debug
            Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
            Set-PSReadLineKeyHandler -Chord 'ctrl+enter' -Function InsertLineAbove
            'no-op' | Write-Debug
            break
        }

        default {
            throw "Unhandled Parameter mode: $ImportType"
        }
    }

    Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
    # Set-PSReadLineOption -ContinuationPrompt (' ' * 4 | New-Text -fg gray80 -bg gray30 | ForEach-Object tostring )
}



# if ($__ninConfig.UsePSReadLinePredict) {
#     try {
#         if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionSource') {
#             Set-PSReadLineOption @eaIgnore -PredictionSource History # SilentlyContinue #stop
#         }
#         if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionViewStyle') {
#             Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView # SilentlyContinue
#         }
#     } catch {
#         Warn🛑 'Failed: -PredictionSource History & ListView'
#     }
# }
# if ($__ninConfig.UsePSReadLinePredictPlugin) {
#     try {
#         if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionSource') {
#             Set-PSReadLineOption @eaIgnore -PredictionSource HistoryAndPlugin
#         }
#         if (Test-CommandHasParameterNamed 'Set-PSReadLineOption' 'PredictionViewStyle') {
#             Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView
#         }
#     } catch {
#         Warn🛑 'Failed: -PredictionSource HistoryAndPlugin'
#     }
# }



if ($false) {
    <#
    AddLine
        moves to next line, bringing any remaining text with it
    AddLineBelow
        Adds and moves to next line, leaving text where it was.

     now VS Code supports it, making it the default
    #>
    # Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView # SilentlyContinue
    # Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
    # Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function BackwardWord
    # # Get-PSReadLineKeyHandler -Bound -Unbound | Where-Object key -Match 'Enter|^l$' | Write-Debug
    # Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
    # Set-PSReadLineKeyHandler -Chord 'ctrl+enter' -Function InsertLineAbove
    # Set-PSReadLineOption -ContinuationPrompt ((' ' * 4) -join '')
    # # Set-PSReadLineOption -ContinuationPrompt (' ' * 4 | New-Text -fg gray80 -bg gray30 | ForEach-Object tostring )
}


# if ($false -and 'ask for command equiv') {
#     $setPSReadLineOptionSplat = @{
#         ContinuationPrompt            = '    '
#         HistoryNoDuplicates           = $true
#         AddToHistoryHandler           = 'Func<string,Object>'
#         CommandValidationHandler      = '<Action[CommandAST]>'
#         MaximumHistoryCount           = 9999999
#         HistorySearchCursorMovesToEnd = $true
#         MaximumKillRingCount          = 999999
#         ShowToolTips                  = $true
#         ExtraPromptLineCount          = 1
#         CompletionQueryItems          = 30
#         DingTone                      = 3
#         DingDuration                  = 2
#         BellStyle                     = 'Visual'
#         WordDelimiters                = ', '
#         HistorySearchCaseSensitive    = $true
#         HistorySaveStyle              = 'SaveIncrementally'
#         HistorySavePath               = 'path'
#         AnsiEscapeTimeout             = 4
#         PromptText                    = 'PS> '
#         PredictionSource              = 'History'
#         PredictionViewStyle           = 'ListView'
#         Colors                        = @{}
#     }
#     Set-PSReadLineOption @setPSReadLineOptionSplat
# }

# Set-PSReadLineOption -ContinuationPrompt '    ' -HistoryNoDuplicates -AddToHistoryHandler 'Func<string,Object>' -CommandValidationHandler '<Action[CommandAST]>' -MaximumHistoryCount 9999999 -HistorySearchCursorMovesToEnd -MaximumKillRingCount 999999 -ShowToolTips -ExtraPromptLineCount 1 -CompletionQueryItems 30 -DingTone 3 -DingDuration 2 -BellStyle Visual -WordDelimiters ', ' -HistorySearchCaseSensitive -HistorySaveStyle SaveIncrementally -HistorySavePath 'path' -AnsiEscapeTimeout 4 -PromptText 'PS> ' -PredictionSource History -PredictionViewStyle ListView -Colors @{}
<#

    [section]: Environment Variables

#>
<#
    [section]: NativeApp Env Vars

- fd customization: <https://github.com/sharkdp/fd#integration-with-other-programs>
- fd-autocompleter reference: <https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd>
- fzf keybindings <https://github.com/junegunn/fzf#key-bindings-for-command-line>

#>
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_COMMAND = 'fd --type file --hidden --exclude .git --color=always'
$Env:FZF_DEFAULT_OPTS = '--ansi --no-height'
$Env:FZF_CTRL_T_COMMAND = "$Env:FZF_DEFAULT_COMMAND"

$env:path += @(
    'C:\bin_nin\SysinternalsSuite\'
    <#
    [section]: Optional Paths

        add git-bash on windows
    #>

    if ($__ninConfig.ImportGitBash) {
        'C:\Program Files\Git\usr\bin'
    }


) | Join-String -Separator ';' -op ';'

<#
    [section]: Explicit Import Module
#>
# local dev import path per-profile
Write-Debug "Add module Path: $($Env:Nin_PSModulePath)"
if (Test-Path $Env:Nin_PSModulePath) {
    # don't duplicate, and don't use Sort -Distinct, because that alters priority

    if ($Env:Nin_PSModulePath -notin @($Env:PSModulePath -split ';' )) {
        $env:PSModulePath = $Env:Nin_PSModulePath, $env:PSModulePath -join ';'
    }
}

$Env:PSModulePath = @(
    $Env:PSModulePath
    'C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell'
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell'
    $pathSeem
) | Join-String -sep ';'
Write-Debug "New `$Env:PSModulePath: $($env:PSModulePath)"

<#
    [section]: Optional imports
#>
# & {
$splatMaybeWarn = @{}

if ($__ninConfig.Module.IgnoreImportWarning) {
    $splatMaybeWarn['Warning-Action'] = 'Ignore'
    $splatMaybeWarn['Warning-Action'] = 'Continue'
}
# Soft/Optional Requirements
$OptionalImports = @(
    # 'Utility' # loaded above
    'Pansies'
    'ClassExplorer'
    'Ninmonkey.Console'
    'Dev.Nin'
    # 'Posh-Git'

    # 'PSFzf'
    # 'ZLocation'
)
# Warn🛑 'Disabled [Posh-Git] because of performance issues' # maybe the prompt function is in a recursive loop

Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> optional imports start'
$OptionalImports
| Join-String -sep ', ' -SingleQuote -op '[v] Loading Modules:' | Write-Verbose


$OptionalImports | ForEach-Object {
    Write-Debug "[v] Optional: Import-Module: $_"
    Write-Warning "[v] Optional: Import-Module: $_"
    # Import-Module $_ @splatMaybeWarn -DisableNameChecking
    $importSplat = @{
        # WarningAction = 'continue'
        # ErrorAction = 'continue'
        DisableNameChecking = $true
        Name                = $_
    }

    Import-Module @importSplat
}
# }

# Import-Module Dev.Nin -DisableNameChecking
# Import-Module posh-git -DisableNameChecking
# finally "profile"
# Import-Module Ninmonkey.Profile -DisableNameChecking

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Backup-VSCode() start'
}

# todo: ThrottledTask
Write-Warning 'Nyi: Throttle VSCode-Backup'
# Backup-VSCode -infa SilentlyContinue
# & {

# currently, all profiles use utf8
Set-ConsoleEncoding Utf8 | Out-Null
if (!(Test-UserIsAdmin)) {
    Import-NinPSReadLineKeyHandler
    # Maybe also remove modules 'Dev.Nin', 'PSFzf', or PSReadLineBeta ?
}
# }

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> Choco start'
}
<#
    [section]: Chocolately
#>
& {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
}


<#
    [section]: Aliases

        see Ninmonkey.Profile.psm1
#>

$env:NinEnableToastDebug = $True


function __prompt_noModuleLoaded {
    @(
        "`n`n"

        $(if (Test-Path variable:/PSDebugContext) {
                '[DBG]🐛> '
            } else {
                ''
            }) + 'Pwsh ' + "`n" + $(Get-Location) + "`n" +
        $(if ($NestedPromptLevel -ge 1) {
                '>>'
            }) + '> '
    ) -join ''
}


[object[]]$Cs ??= '#DDA0DD', '#9370DB', '#008B8B'
$__colors = $cs
function Prompt_Nin.2 {
    $Config ??= @{
        ShowVSCodeStatus = $true
        ShowVSCodeAllVersions = $true
        OutputFormat = 'dbgInfo'
    }
    $colors = $Cs ?? [object[]]@('#DDA0DD', '#9370DB', '#008B8B')
    $uniStr = '˫！︕'

    (@(
        "`n"
        if ($global:error.count -gt 0) {
            $PSStyle.Foreground.FromRgb('#c77445')
            $global:error.count
            '！'
            # '˫'
        }
        ''
        $PSStyle.Foreground.FromRgb( $Colors[0])
        $PSVersionTable.PSVersion -join ''
        ' '
        # "${fg:green}"
        $PSStyle.Foreground.FromRgb( $Colors[1])
        #        Get-Location | abbrPath
        Get-Location
        "${fg:clear}"

        if($Config.ShowVSCodeStatus) {
            # "`n"
            # 'PS ExtensionTerm: '
        }
        if($Config.ShowVSCodeAllVersions) {


            $script:____promptMiniCache ??= @{
                FinalRender = ''
                ModulesString = Get-Module *editor*, *service* | sort Name
                    | Join-String -sep ', ' { '{0} = {1}' -f @(
                        $_.Name, $_.Version )
                    }
                EditorServicesRunning = if( (get-module 'EditorServicesCommandSuite', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode').count -gt 2 ) {
                    'ES჻ '
                } else {
                    'ꜝ¡ǃꜟ'
                }
                EditorName = (ps -id $pid).Parent.name
                ExtensionVersion = & 'code.cmd' --list-extensions --show-versions | sls '(ms-vscode.power|powerquery)' -Raw | Join-string -sep ', '
            }

            "`n"
            <#
            future
                - detect which extension is actually running [1] s-vscode extension enabled is [1] pwsh-preview or not
                    - [ms-vscode.powershell@2022.8.5, ms-vscode.powershell-preview@2022.10.0]
                - detect other extensions, powerquery
            #>
            switch($Config.OutputFormat) {
                'dbgInfo' {
                    $render = @(
                        $PSStyle.Foreground.FromRgb('#999999')
                        'extensionTerm: '
                        $script:____promptMiniCache.ModulesString
                        "`n"
                        $script:____promptMiniCache.EditorName ?? '<Edit?> '
                        ': '
                        $script:____promptMiniCache.ExtensionVersion

                        $PSStyle.Reset
                    ) -join ''
                }
                default  {
                    $render = @(
                        $PSStyle.Foreground.FromRgb('#999999')
                        $script:____promptMiniCache.ModulesString
                        "`n"
                        $script:____promptMiniCache.EditorName ?? '<Edit?> '
                        ': '
                        $script:____promptMiniCache.ExtensionVersion

                        $PSStyle.Reset
                    ) -join ''
                }
            }
            $render
        }

        "`nPwsh> "
    ) -join '')
}

function Prompt_Nin.1 {
    <#
    .synopsis
        directly redirect to real prompt. not profiled for performance at all
    .description
    #>

    if ('HardcodedExperiment') {
        Invoke-NinPrompt
        # __prompt_usingColorExperiment_v2
        return
    }

    $profile_isLoaded = $false
    if (!$profile_isLoaded) {
        __prompt_noModuleLoaded
        return

    }

    if (Get-Module Ninmonkey.Profile -ea ignore) {
        $profile_isLoaded = $true
    }

    $devNin_isLoaded = $false
    if (Get-Command Dev.Nin\Test-HasNewError -ea ignore) {
        $devNin_isLoaded = $true
    }

    if ($profile_isLoaded -and $devNin_isLoaded) {
        Write-NinProfilePrompt
        return
    }

    @(
        "`n"
        ($error.count -gt 0) ? $error.Count : $null
        Get-Location
        'safe> '
    ) | Join-String -sep "`n"

    # ) | Join-String -sep "`nPS> "
    # IsAdmin = Test-UserIsAdmin
}

if ( -not $DisabledForPerfTest ) {

    function prompt {
        # wrapper, prevents gitbash autolading on default prompt
        Prompt_Nin.2
    }

    # ie: Lets you set aw breakpoint that fires only once on prompt
    # $prompt2 = function:prompt  # easily invoke the prompt one time, for a debug breakpoint, that only fires once
    # $prompt2}}
    # New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Write-Debug
    # New-Text "End: <-- '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Warn🛑
    if ($__ninConfig.LogFileEntries) {
        New-Text "<-- '$PSScriptRoot' before onedrive mapping" -fg 'cyan'
        | ForEach-Object ToString | Warn🛑
    }

    # if (! $OneDrive.Enable_MyDocsBugMapping) {
    #     _profileEventOnFinalLoad
    # }

    if ($true -or $EnableHistHandler) {
        Enable-NinHistoryHandler
    }
}


# if (! (Get-Command 'Out-VSCodeVenv' -ea ignore)) {
#     Warn🛑 'Out-VSCodeVenv did not load!'
#     # $src = gi -ea ignore (gc 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1')
#     $src = Get-Item -ea ignore 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1'
#     if ($src) {
#         . $src
#     }
# }

# if ($false) {
#     Import-Module PsFzf

#     if (Get-Command Set-PsFzfOption -ea ignore) {
#         # Set reverse hist fzf

#         # Really needs filtering
#         Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+shift+r'
#         # 'Ctrl+r' | write-blue
#         # | str prefix 'PsFzf: History set to '

#         Hr 1
#         'keybind ↳ History set to ↳ '

# 'Ctrl+r' | Write-Color blue
# | str prefix ([string]@(
#         'PsFzf:' | Write-Color gray60
#         'keybind ↳ History set to ↳ '
#         #     ))

#         Hr 1
#     }
# }
if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] -> final invokevscode dotsource, should not exist '
}

# # temp hack
# if ($false -and 'probably obsolete') {
#     if (! (Get-Command 'code-venv' -ea ignore) ) {
#         Set-Alias 'code' 'code-insiders.cmd'
#         # somehow didn't load, so do it now
#         $src = Get-Item -ea ignore 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Invoke-VSCodeVenv.ps1'
#         if ($src) {
#             . $src
#         }
#         Set-Alias 'code' -Value 'Invoke-VSCodeVenv'
#         $Value = (@(
#                 Get-Command -ea ignore -CommandType Application code-insiders.cmd
#                 Get-Command -ea ignore -CommandType Alias code.cmd
#                 Get-Command -ea ignore 'venv-code'
#             ) | Select-Object -First 1)
#         New-Alias 'code.exe' -Description 'Attempts to use "code-insiders.cmd", then "code.cmd", then "venv-code".' -Value $Value
#         # try {
#         #     . gi (join-path $PSScriptRoot 'Out-VSCodeVenv.ps1')
#         # }
#         # catch {
#         #     Warn🛑 'Failed parsing: Out-VSCodeVenv.ps1'
#         # }
#     }
# }
<#>
if ($OneDrive.Enable_MyDocsBugMapping) {
    Remove-Module 'psfzf', 'psscripttools', 'zlocation'
    Set-Alias 'code' -Value 'Invoke-VSCodeVenv' -Force
    # Push-Location 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell'
}
#>
# New-Text "End <-- True end: '$PSScriptRoot'" -fg 'cyan' | ForEach-Object ToString | Warn🛑

if ($__ninConfig.LogFileEntries) {
    Write-Warning '㏒ [dotfiles/powershell/Nin-CurrentUserAllHosts.ps1] <-- end of file'
}

Write-Warning "Find func: 'Lookup()'"
'reached bottom'

if (-not $DisabledForPerfTest) {

    if ($false) {
        Get-PSDrive -PSProvider FileSystem
        | ForEach-Object {
            @(
                $l = @(
                    Lookup -InputObject $_ -LiteralPropertyName Name
                    Lookup -InputObject $_ -LiteralPropertyName Free
                ) | Merge-HashtableList
                $l

            )
        }
    } else {
        Get-PSDrive -PSProvider FileSystem
        | ForEach-Object {
            [pscustomobject]@{
                Free = '{0,-6:n0}GB' -f ($_.Free / 1gb)
                Name = $_.Name
            }
        } | Format-Table -AutoSize
    }
}

function prompt {
    if ($true) {
        Prompt_Nin.2
    } else {
        @(
            "`n"
            $PSVersionTable.PSVersion -join ''
            ' '
            Get-Location
            "`nPwsh>"
        ) -join ''
    }
}
function _tempImportAws {
    Import-Module -Force 'C:\Users\cppmo_000\SkyDrive\Documents\2022\Pwsh\my_Github\aws_utils.nin\aws_utils.nin\' -verbose -scope Global
}

'--- last line of profile has completed -- ' | write-debug


# if (!(Get-Module dev.nin)) {
#     Import-Module Dev.Nin
# }

# function Csv2 {
#     $Input | Microsoft.PowerShell.Utility\Join-String -sep ', '
# }

# . 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\Inspect-LocationPathInfoStackState.ps1'

# inline exports

@'
(Get-Alias 'at').ResolvedCommand | fileFromScriptBlock
    finish your pwsh dump
'@

function resolveAliasedCommand {
    <#
    .SYNOPSIS
        converts patterns and aliases, resolving to the actual functions
    .example
        Pwsh> from->Alias '.' -Module Ninmonkey | sort Name, Source -Unique

        Pwsh> (Get-Alias 'at').ReferencedCommand | editFunc -infa Continue
        loading:... <G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell\Utility.psm1>
    #>
    # [Alias('to->Func')]
    [Alias('from->Alias')]
    [OutputType('System.Management.Automation.FunctionInfo')]
    [CmdletBinding()]
    param(
        # name/alias
        [Parameter(Mandatory, Position = 0)][string]$Name = '.',

        # suggest some common ones
        [Parameter(Position = 1)][ArgumentCompletions(
            'ClassExplorer', 'Utility', 'Microsoft.PowerShell', 'Ninmonkey',
            'PSReadLine', 'PSScriptAnalyzer', 'ImportExcel', 'ugit'
        )][string]$Module = '',

        # default is regex, switch to 'normal' wildcards
        [Alias('Like')][switch]$UsingLike
    )
    if ($UsingLike) {
        # change empty regexes to match everything
        if( $Name -eq '.' ) {  $Name = '*' }
        if( [string]::IsNullOrWhiteSpace( $Module ) ) {
             $Module = '*'
        }
        (Get-Alias | ? Source -like $Module | ? Name -Like $Name).ReferencedCommand
       return
    }

    (Get-Alias | ? Source -Match $Module | ? Name -Match $Name).ReferencedCommand
}


#  https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.ScriptBlock?view=powershellsdk-7.0.0#properties



function cmdToScriptBlock {
    # barely-sugar, more so for semantics
    # converts functions and scriptblocks to scriptblocks
    <#
    .example
        Pwsh>
            gcm prompt  | cmdToScriptBlock
            (gcm prompt).ScriptBlock | cmdToScriptBlock
    #>
    [OutputType('System.Management.Automation.ScriptBlock')]
    [CmdletBinding()]
    param()
    process {
        if($_ -is 'ScriptBlock') { return $_ }
        return $_.ScriptBlock
    }
}

function scriptBlockToFile {
    # barely-sugar, more so for semantics
    process {
        $_.Ast.Extent.File
    }
}
function fileFromScriptBlock {
    # barely-sugar, more so for semantics
    #    param( [])
    process {
        $_.ScriptBlock.Ast.Extent.File
    }
}

write-warning 'end... now verbose'
# $VerbosePReference = 'continue'
# $debugpreference = 'continue'
# $PSDefaultParameterValues['Import-Module:Verbose'] = $true
# $PSDefaultParameterValues['Import-Module:Debug'] = $true

'SuperVerbose?: ', $script:__superVerboseAtBottom -join '' | write-warning
if ($script:__superVerboseAtBottom) {

    $VerbosePReference = 'continue'
    $WarningPreference = 'continue'
    # $debugpreference = 'continue'

    # $PSDefaultParameterValues['*:Debug'] = $true
    $PSDefaultParameterValues['*:Verbose'] = $true
    $PSDefaultParameterValues['Import-Module:Debug'] = $false #
    $PSDefaultParameterValues['Set-Alias:Debug'] = $false #

        $PSDefaultParameterValues['Import-Module:Verbose'] = $true
        $PSDefaultParameterValues['Update-Module:Verbose'] = $true
        $PSDefaultParameterValues['Install-Module:Verbose'] = $true
        $PSDefaultParameterValues['get-Module:Verbose'] = $true

        $PSDefaultParameterValues['Import-Module:debug'] = $true
        $PSDefaultParameterValues['Update-Module:debug'] = $true
        $PSDefaultParameterValues['Install-Module:debug'] = $true
        $PSDefaultParameterValues['get-Module:debug'] = $true
    # }

    # Set-PSDebug -Trace 0
    # Set-PSDebug -Trace 2
    "end => NinCurrentALlHosts: '$PSComandPath'" | write-warning
}
# $WarningPreference = 'continue'
if ($true -or $script:__superVerboseAtBottom) {

    $PSDefaultParameterValues['*:Verbose'] = $true
    $VerbosePReference = 'continue'

    $PSDefaultParameterValues['Import-Module:Verbose'] = $true
    $PSDefaultParameterValues['Update-Module:Verbose'] = $true
    $PSDefaultParameterValues['Install-Module:Verbose'] = $true
    $PSDefaultParameterValues['get-Module:Verbose'] = $true

    $PSDefaultParameterValues['Set-KeyHandler*:Verbose'] = $true
    $PSDefaultParameterValues['Set-PSReadLine*:Verbose'] = $true
    $PSDefaultParameterValues['Import-CommandSuite*:verbose'] = $true
} else {
    $VerbosePReference = 'silentlyContinue'
}
$PSDefaultParameterValues.Remove('Import-Module:Verbose')
$PSDefaultParameterValues.Remove('*:Verbose')
$PSDefaultParameterValues.Remove('Get-Module:Verbose')
$PSDefaultParameterValues['Import-Module:Verbose'] = $false
$PSDefaultParameterValues['get-Module:Verbose'] = $false



if($script:__superEnableDebugAtBottom) {
    $PSDefaultParameterValues['*:Debug'] = $true

    $debugpreference = 'silentlyContinue'
    $debugpreference = 'continue'

    $PSDefaultParameterValues['Set-Alias:Debug'] = $false #
    $PSDefaultParameterValues['Import-Module:debug'] = $false # creates prompts
    $PSDefaultParameterValues['Update-Module:debug'] = $true
    $PSDefaultParameterValues['Install-Module:debug'] = $true
    $PSDefaultParameterValues['get-Module:debug'] = $true
} else {
    $debugpreference = 'silentlyContinue'
    $PSDefaultParameterValues['Import-Module:debug'] = $false # creates prompts
}

# always disable for now/
$PSDefaultParameterValues.Remove('*:Debug')
$PSDefaultParameterValues.Remove('*:Verbose')
$DebugPreference = 'silentlycontinue'

    # }

    Set-PSDebug -Trace $script:__superTraceAtBottomLevel
    "end => NinCurrentALlHosts: '$PSComandPath'" | write-warning

'autoload _tempImportAws'  | label 'util.Invoke -> '
_tempImportAws
__profileGreet

write-warning '- [ ] todo: flush all (3?4?) histories for perf'
write-warning '- [ ] todo: explictly disable modules like AWS to improve command delays'
Write-warning '- [ ] todo perf:
    delete obsolete global unsaved workspaces polliting history ?
'
Write-warning '- [ ] todo perf:
    [1] should I delete all of history?
    [2] is this normal or pwsh or something?
    [3] "$Env:AppData\Code\User\History"'