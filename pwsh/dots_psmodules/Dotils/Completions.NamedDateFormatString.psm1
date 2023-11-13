using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
# using namespace System.Collections


# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#class-based-argument-completers

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#dynamic-validateset-values-using-classes
class NamedDateTemplate {
    <#
        .SYNOPSIS
        nicely render date info for a tooltip
    #>
    [string]$Delim = ' ⁞ '
    [string]$ShortName = 'Git Dto'
    [string]$BasicName = 'Github DateTimeZone'
    [string]$Description = @(
        'Github DateTimeOffset UTC'
    ) -join "`n"
    [string]$Fstr = 'D'
    [string]$RenderExample = "`u{2400}"
    [string]$Culture = 'en-US'

    [string] ToString() {
        return $this.Format('Default')
    }

    [string] Format() {
        <#
        .SYNOPSIS
        nicely render date info for a tooltip
        #>
        return $this.Format('Default')
    }
    [string] Format( $Template = 'Default' ) {
        $Colors = $Script:Colors

        [string]$Render = ''
        $Cult = Get-Culture $This.Culture
        $this.RenderExample =
            try {
                [datetime]::Now.ToString( $this.FStr, $Cult )
            } catch {
                "`u{2400}"
            }
        switch($Template) {
            'Default' {
                $render = @(
                    .Fg $Colors.Fg2
                        $this.ShortName
                    .Color.Reset
                        $this.Delim

                    .Fg $Colors.Fg3
                        $this.RenderExample
                    .Color.Reset
                        "`n"
                    .Fg $Colors.DimBlue
                        $this.Fstr
                    .Fg $Colors.DimGray
                    # .Fg $Colors.DarkWhite
                        $this.LongName

                    # .Fg $Colors.Fg
                    # .Color.Reset

                        "`n"
                        $this.Description
                    # .Fg $Colors.DimBlue
                        "`n"
                    # .Fg $Colors.DimGreen
                        $this.BasicName
                    .Color.Reset
                ) | Join-String -sep ''

            }
            'Iter1' {
                $render = @(
                    .Fg $Colors.Fg2
                        $this.ShortName
                    .Color.Reset
                        $this.Delim

                    .Fg $Colors.Fg3
                        $this.RenderExample
                    .Color.Reset
                        "`n"
                    .Fg $Colors.DimBlue
                        "`n"
                        $this.Fstr
                    .Fg $Colors.DimGray
                        $this.LongName
                    # .Fg $Colors.Fg
                    # .Color.Reset
                        "`n"
                        $this.Description
                    # .Fg $Colors.DimBlue
                        "`n"
                    # .Fg $Colors.DimGreen
                        $this.BasicName
                    .Color.Reset

                ) | Join-String -sep ''

            }
            default {
                throw "Unknown Template: $Template"
            }
        }
        return $render
    }
}

class DateNamedFormatCompleter : IArgumentCompleter {

    [hashtable]$Options

    # DateNamedFormatCompleter([int] $from, [int] $to, [int] $step) {

    DateNamedFormatCompleter( ) {
    }
    DateNamedFormatCompleter( $options ) {
        $this.Options = $Options ?? @{}
        # if ($from -gt $to) {
        #     throw [ArgumentOutOfRangeException]::new("from")
        # }
        # $this.From = $from
        # $this.To = $to
        # $this.Step = $step -lt 1 ? 1 : $step
    }



    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters) {

        [List[CompletionResult]]$resultList = @()
        $DtNow = [datetime]::Now

        $fStr = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        $rendExample = ($DtNow).ToString($Fstr)

        $Props = @{
            Delim = ' ⁞ '
            ShortName = 'Git Dto'
            BasicName = 'Github DateTimeZone'
            Description = @(
                'Github DateTimeOffset UTC'
            ) -join "`n"
            Fstr = $Fstr
            RenderExample = $RendExample
        }
        <#
        .example

        > try.Named.Fstr yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
        GitHub.DateTimeOffset  ShortDate (Default)    LongDate (Default)

            Git Dto ⁞ 2023-11-11T18:58:42Z
            yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
            Github DateTimeZone
            Github DateTimeOffset UTC
        #>

        [string]$renderTooltip = @(
            @(
                $Props.ShortName
                $Props.RenderExample
            ) -join $Props.Delim
            $Props.Fstr
            $Props.BasicName
            $Props.Description

            # "Github DateTimeOffset UTC Format (Default) ⁞ $rendExample"
            # "`nText: $rendExample"
            # "`nFstr: $fStr "
        ) | Join-String -sep "`n"

            # "Github DateTimeOffset UTC Format (Default) ⁞ $rendExample"
            # "`nText: $rendExample"
            # "`nFstr: $fStr "
        <#
        Try.Named.Fstr yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
            GitHub.DateTimeOffset  ShortDate (Default)    LongDate (Default)
            Github DateTimeOffset UTC Format (Default) ⁞ 2023-11-11T18:54:09Z
            Text: 2023-11-11T18:54:09Z
            Fstr: yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
        #>

        $resultList.Add(
            [CompletionResult]::new(
                # <# completionText: #> 'GitHub.DateTimeOffset',
                <# completionText: #> $fStr,
                <# listItemText: #> 'GitHub.DateTimeOffset',
                <# resultType: #> [CompletionResultType]::ParameterValue,
                # <# toolTip: #> "Short ┎┏┎ ▸·⇢⁞ ┐⇽▂ $RendExample")
                # "Github DateTimeOffset UTC Format (Default) ⁞ $rendExample | $fStr "
                <# toolTip: #> $renderTooltip) )

        # standard built ins
        $rendExample = ($DtNow).ToString('d')
         [string]$renderTooltip = @(
            "Long ⁞ $rendExample"
            "`nLine2 | Example "
        ) | Join-String -sep "`n"

        $resultList.Add(
            [CompletionResult]::new(
                <# completionText: #> 'd',
                <# listItemText: #> 'ShortDate (Default)',
                <# resultType: #> [CompletionResultType]::ParameterValue,
                # <# toolTip: #> "Short ┎┏┎ ▸·⇢⁞ ┐⇽▂ $RendExample")
                <# toolTip: #> "Short ⁞ $rendExample") )

        # $rendExample = ($DtNow).ToString('D')
        $rendExample = ($DtNow).ToString('D')

        [string]$renderTooltip = @(
            "Long ⁞ $rendExample"
            "`nLine2 | Example "
        ) | Join-String -sep "`n"

        $resultList.Add(
            [CompletionResult]::new(
                <# completionText: #> 'D',
                <# listItemText: #> 'LongDate (Default)',
                <# resultType: #> [CompletionResultType]::ParameterValue,
                # <# toolTip: #> "Short ┎┏┎ ▸·⇢⁞ ┐⇽▂ $RendExample")
                <# toolTip: #> $renderTooltip)
        )

            # New-TypeWriterCompletionResult -Text 'LongDate' -listItemText 'LongDate2' -resultType Text -toolTip 'LongDate (default)'
            # New-TypeWriterCompletionResult -Text 'ShortDate' -listItemText 'ShortDate2' -resultType Text -toolTip 'ShortDate (default)'
        return $resultList
    }
}

$Colors = @{
    BlueGray = '#5f7a8b'
    DimGray = '#819696'
    DimBlue = '#405e7c'
    Fg = '#d4d4d4'
    DimYellow = '#dbce80'
    DimGreen = '#3a705f'
    DarkWhite = '#595949'
}
$Colors.Fg = $Colors.Fg
$Colors.Fg2 = $Colors.FgBlue = $Colors.BlueGray
$Colors.Fg3 = $Colors.FgYellow = $Colors.DimYellow
function Color.Reset {
    [Alias('.Color.Reset')]
    param()
    $PSStyle.Reset
}
function __writeColorForeground {
    <#
    .SYNOPSIS
        sugar to write ansi colors
    .EXAMPLE
        .Fg '#fe9911'
    .LINK
        __writeColorForeground
    .LINK
        __writeColorBackground
    #>
    [Alias('.Fg')]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Color
    )
    $PSStyle.Foreground.FromRgb( $Color )
}
function __writeColorBackground {
    <#
    .SYNOPSIS
        sugar to write ansi colors
    .EXAMPLE
        .Fg '#fe9911'
    .LINK
        __writeColorForeground
    .LINK
        __writeColorBackground
    #>
    [Alias('.Bg')]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Color
    )
    $PSStyle.Background.FromRgb( $Color )
}
function __renderTooltip {
    <#
    .EXAMPLE
    # sample output:

        Git Dto ⁞ 11/13/2023
        d
        Github DateTimeOffset UTC
        Github DateTimeZone

    #>
    param(
        [Alias('Props', 'Kwargs')]
        [hashtable]$Options,

        [ArgumentCompletions('Default')]
        [string]$Template = 'Default'
        # [string]$ShortName,
        # [string]$LongName,
        # [string]$ExampleFormat
    )
    [string]$Render = ''

    switch($Template) {
        'Default' {
            $render = @(
                .Fg $Colors.Fg2
                    $Options.ShortName
                .Color.Reset
                    $Options.Delim

                .Fg $Colors.Fg3
                    $Options.RenderExample
                .Color.Reset
                    "`n"
                .Fg $Colors.DimBlue
                    $Options.Fstr
                .Fg $Colors.DimGray
                # .Fg $Colors.DarkWhite
                    $Options.LongName

                # .Fg $Colors.Fg
                # .Color.Reset

                    "`n"
                    $Options.BasicName
                # .Fg $Colors.DimBlue
                    "`n"
                    $Options.Description
                # .Fg $Colors.DimGreen
                .Color.Reset

            ) | Join-String -sep ''

        }
        'Iter1' {
            $render = @(
                .Fg $Colors.Fg2
                    $Options.ShortName
                .Color.Reset
                    $Options.Delim

                .Fg $Colors.Fg3
                    $Options.RenderExample
                .Color.Reset
                    "`n"
                .Fg $Colors.DimBlue
                    "`n"
                    $Options.Fstr
                .Fg $Colors.DimGray
                    $Options.LongName

                # .Fg $Colors.Fg
                # .Color.Reset

                    "`n"
                    $Options.Description
                # .Fg $Colors.DimBlue
                    "`n"
                # .Fg $Colors.DimGreen
                    $Options.BasicName
                .Color.Reset

            ) | Join-String -sep ''

        }
        default {
            throw "Unknown Template: $Template"
        }
    }

    return $render


    # return $render
    # $ShortName

    #   [string]$renderTooltip = @(


    #     # "Github DateTimeOffset UTC Format (Default) ⁞ $rendExample"
    #     # "`nText: $rendExample"
    #     # "`nFstr: $fStr "
    # ) | Join-String -sep "`n"

}

$t =
    [NamedDateTemplate]@{
        Delim = ' ⁞ '
        ShortName = 'Git Dto'
        BasicName = 'Github DateTimeZone'
        Description = @(
            'Github DateTimeOffset UTC'
        ) -join "`n"
        Fstr = 'D'
        # Fstr = 'D'
        # RenderExample =
        #     [datetime]::Now.ToString('D')
            # $RendExample
    }
hr -fg magenta | write-warning
$t | Json -depth 1 #| out-host
$t | ft
hr
$t.Format('Default') | Out-Host

$t.ToString() | Out-Host

$t.ToString() | Out-Host

function try.renderTip {
        $Fstr = 'd'
        $Props = @{
            Delim = ' ⁞ '
            ShortName = 'Git Dto'
            BasicName = 'Github DateTimeZone'
            Description = @(
                'Github DateTimeOffset UTC'
            ) -join "`n"
            Fstr = $Fstr
            RenderExample =
                [datetime]::Now.ToString($Fstr)
                # $RendExample
        }
        $__renderTooltipSplat = @{ Options = $Props }
        __renderTooltip @__renderTooltipSplat
}

class DateNamedFormatCompletionsAttribute : ArgumentCompleterAttribute, IArgumentCompleterFactory {
    <#
    .example
        Pwsh> [DateNamedFormatCompletionsAttribute]::new()
        Pwsh> [DateNamedFormatCompletionsAttribute]::new( @{ 'stuff' = 'far' } )
    #>
    [hashtable]$Options
    # [int] $From
    # [int] $To
    # [int] $Step

    # DateNamedFormatCompletionsAttribute( $options[int] $from, [int] $to, [int] $step) {
    DateNamedFormatCompletionsAttribute(  ) {
        $this.Options = @{}
    }
    DateNamedFormatCompletionsAttribute( $options ) {
        $this.Options = $Options ?? @{}
    }

    [IArgumentCompleter] Create() {
        # return [DateNamedFormatCompleter]::new($this.From, $this.To, $this.Step)
        # return [DateNamedFormatCompleter]::new( @{} )
        return [DateNamedFormatCompleter]::new()
    }
}

# function Try.Named.DateString {
function Try.Named.Fstr {
    <#
    .SYNOPSIS
        Generates datetime strings based on human readable format
    #>
    param(
        [Parameter(Mandatory, Position = 0)]
        # [ValidateSet([DateNamedFormatCompletionsAttribute])]
        [DateNamedFormatCompletionsAttribute()]
        [Alias('Name')]
        [string] $DateFormat
    )
    $DateFormat
}

@(
    'Wip: Currently it doesn''t filter any completiosn for Completions.NamedDateFormatString.psm1'
    "    Source: $PSCommandPath"
    'Todo: Finish descriptions and links: https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings'
    "    Source: $PSCommandPath"
) -join "`n"
    | Write-Warning

Export-ModuleMember -Function @(
    'Try.Named.Fstr'
    'Try.renderTip'
 ) -Verbose


try.renderTip


# return





# Class NamedDateFormatStringsBasic : IValidateSetValuesGenerator {
#     [string[]] GetValidValues() {
#         $basicDates =
#             'o', 'O', 'RoundTrip', 'ShortDate', 'LongDate'
#         # $SoundNames = ForEach ($SoundPath in $SoundPaths) {
#         #     If (Test-Path $SoundPath) {
#         #         (Get-ChildItem $SoundPath).BaseName
#         #     }
#         # }
#         return [string[]] $basicDates
#     }
# }

# function Named.DateString.Basic {
#     param(
#         [Parameter(Mandatory, Position = 0)]

#         [ValidateSet([NamedDateFormatStringsBasic])]
#         [string] $NamedDate
#     )
#     $NamedDate
# }

# Named.DateString.Basic ShortDate
# hr
# Class NamedDateFormatStringsWithoutCE : IValidateSetValuesGenerator {
#     # tw.New-CompletionResult -Name
#     # 'o', 'O', 'RoundTrip', 'ShortDate', 'LongDate'

#     # [CompletionResult[]] GetValidValues() {
#     [string[]] GetValidValues() {
#         [List[Object]]$CompletionResults = @(
#             New-TypeWriterCompletionResult -Text 'ShortDate' -listItemText 'ShortDate2' -resultType Text -toolTip 'ShortDate (default)'
#             New-TypeWriterCompletionResult -Text 'LongDate' -listItemText 'LongDate2' -resultType Text -toolTip 'LongDate (default)'
#         )

#         # return $CompletionResult
#         # return [string[]] $CompletionResults
#         # return [string[]]( $CompletionResults )
#         return [string[]]( $CompletionResults ).CompletionText
#     }
# }

# function Named.DateStringWithoutCE {
#     param(
#         [Parameter(Mandatory, Position = 0)]

#         [ValidateSet([NamedDateFormatStringsWithoutCE])]
#         [string] $NamedDate
#     )
#     $NamedDate
# }

# Named.DateStringWithoutCE 'ShortDate'

# # Named.DateString ShortDate