using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace Globalization
# using namespace System.Collections

$script:moduleConfig = @{
    hardPath = Join-Path 'g:\temp' -ChildPath '2023_11_13' 'ArgumentCompleter.log'
    SuperVerbose = $true
}
# New-Item -ItemType File -Path (Join-Path 'g:\temp' -ChildPath '2023_11_13' 'ArgumentCompleter.log') -Force
if( -not (Test-Path $moduleConfig.hardPath) ) {
    New-Item -ItemType File -Path $moduleConfig.hardPath -Force
}
$ModuleConfig.hardPath | Join-String -f 'Using Log: {0}' | write-host -BackgroundColor 'darkred'
# if (-not (Test-Path)) {
#     Touch -Path $hardPath
# }

function WriteJsonLog {
    param(
        [ALias('.Log')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [switch]$PassThru
    )
    begin {
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@(
            $InputObject ))
    }
    end {
        $Now = [Datetime]::Now
        $Data =
            $items | ConvertTo-Json -Depth 2

        $logLine =
            Join-String -inp @( $Data )  -op 'JSON:{ ' -os ' }:JSON'
                | Join-String -op "[$Now] "

        Add-Content -Path $moduleConfig.hardPath -Value $logLine -PassThru:$PassThru
    }
}

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#class-based-argument-completers

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#dynamic-validateset-values-using-classes
class NamedDateTemplate {
    <#
    .SYNOPSIS
        nicely render date info for a tooltip
    .LINK
        System.Globalization.DateTimeFormatInfo
    #>
    [string]$Delim = ' ⁞ '
    [string]$ShortName = '' # Ex: 'Git Dto'
    [string]$BasicName = '' # Ex: 'Github DateTimeZone'
    [string]$Description = '' # Ex: 'Github DateTimeOffset UTC'
    [string]$Fstr = '' # Ex: 'D'
    [string]$RenderExample = "`u{2400}"
    [string]$Culture = 'en-US' # 'de-de'
    [string]$CompletionName = '' # Ex: 'GitHub.DateTimeOffset' # not always rendered
    [CompletionResultType]$ResultType = [CompletionResultType]::ParameterValue

    # hidden [hashtable]$Options = @{
    #     AutoQuoteIfQuote = $true
    # }

    [string] ToString() {
        return $this.Format('Default')
    }
    [CompletionResult] AsCompletionResult () {
        # ensure calculated values

        $this.Format()
        $FinalCompletion = $this.Fstr
        $AutoQuoteIfQuote = $true
        $AlwaysSingleQuote = $false

        if($AutoQuoteIfQuote -and $This.Fstr -match "'") {
            $FinalCompletion =
                $This.Fstr | Join-String -DoubleQuote

        } elseif ( $AlwaysSingleQuote ) {
            $FinalCompletion =
                $This.FStr -replace "'", "''"
                    | Join-String -SingleQuote
        }
        return [CompletionResult]::new(
            <# completionText: #> $FinalCompletion,
            <# listItemText: #> $this.CompletionName, # ex: 'GitHub.DateTimeOffset'
            <# resultType: #> ($this.ResultType ?? [CompletionResultType]::ParameterValue),
            <# toolTip: #> $this.Format()
        )
        # [CompletionResult]
        #     $quoted  =
        #         $This.Fstr | Join-String -DoubleQuote
        #     $ce = [CompletionResult]::new(
        #         <# completionText: #> $quoted,
        #         <# listItemText: #> $this.CompletionName, # ex: 'GitHub.DateTimeOffset'
        #         <# resultType: #> ($this.ResultType ?? [CompletionResultType]::ParameterValue),
        #         <# toolTip: #> $this.Format()
        #     )
        #     return $ce
        # }

        # $ce = [CompletionResult]::new(
        #     <# completionText: #> $this.fStr,
        #     <# listItemText: #> $this.CompletionName, # ex: 'GitHub.DateTimeOffset'
        #     <# resultType: #> ($this.ResultType ?? [CompletionResultType]::ParameterValue),
        #     <# toolTip: #> $this.Format()
        # )
        # return $ce
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
                        "`n"
                        "`n"
                    .Fg $Colors.DimGray
                    # .Fg $Colors.DarkWhite

                    if( -not [string]::IsNullOrWhiteSpace( $This.LongName )) {
                        $this.LongName
                        "`n"
                    }
                    if( -not [string]::IsNullOrWhiteSpace( $This.BasicName )) {
                        $this.BasicName
                        "`n"
                    }
                    if( -not [string]::IsNullOrWhiteSpace( $This.Description )) {
                        $this.Description
                        "`n"
                    }

                    # .Fg $Colors.Fg
                    # .Color.Reset


                        # $this.Description
                    # .Fg $Colors.DimBlue
                        "`n"
                    # .Fg $Colors.DimGreen
                        # $this.BasicName
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
        <#
        .example

        > try.Named.Fstr yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
        GitHub.DateTimeOffset  ShortDate (Default)    LongDate (Default)

            Git Dto ⁞ 2023-11-11T18:58:42Z
            yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
            Github DateTimeZone
            Github DateTimeOffset UTC
        #>

        [List[CompletionResult]]$resultList = @()
        $DtNow = [datetime]::Now
        $DtoNow = [DateTimeOffset]::Now
        $Config = @{
            IncludeAllDateTimePatterns = $true

        }

        [Globalization.DateTimeFormatInfo]$DtFmtInfo = (Get-Culture).DateTimeFormat

        if($script:moduleConfig.SuperVerbose) {
            'DateNamedFormatCompleter::CompleteArgument'
                | WriteJsonLog
        }


        $tlate = [NamedDateTemplate]@{
            CompletionName = 'GitHub.DateTimeOffset'
            Delim = ' ⁞ '
            Fstr = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
            ShortName = 'Git Dto'
            BasicName = 'Github DateTimeZone'
            Description = @(
                'Github DateTimeOffset UTC'
            ) -join "`n"
        }
        $resultList.Add( $tlate.AsCompletionResult() )
        # try {
        # } catch {
        #     $_ | out-HOst
        # }

        $tlate = [NamedDateTemplate]@{
            CompletionName = 'd'
            Delim = ' ⁞ '
            Fstr = "d"
            ShortName = 'ShortDate'
            BasicName = ''
            Description = @(
                'Short date (Standard)'
            ) -join "`n"
        }
        $resultList.Add( $tlate.AsCompletionResult() )




        $curFStr = $DtFmtInfo.ShortDatePattern
        $tlate = [NamedDateTemplate]@{
            CompletionName = 'ShortDate'
            Delim = ' ⁞ '
            Fstr = $DtFmtInfo.ShortDatePattern
            ShortName = 'ShortDatePattern'
            BasicName = ''
            Description = @(
                'Culture.DateTimeFormatInfo.ShortDatePattern'
            ) -join "`n"
        }
        $resultList.Add( $tlate.AsCompletionResult() )

        $DtFmtInfo.GetAllDateTimePatterns()
        foreach($fstr in $DtFmtInfo.GetAllDateTimePatterns()) {
            $tlate = [NamedDateTemplate]@{
                CompletionName = $Fstr
                Delim = ' ⁞ '
                Fstr = $fstr
                ShortName = ''
                BasicName = ''
                Description = @(
                    'From: DtFmtInfo.GetAllDateTimePatterns()'
                ) -join "`n"
            }
            $resultList.Add( $tlate.AsCompletionResult() )
        }







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

if($false -and 'enable debug' ) {
    write-warning 'debug example output enabled '
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
    DateNamedFormatCompletionsAttribute() {
        $this.Options = @{}
    }
    # DateNamedFormatCompletionsAttribute( $ExcludeDateTimeFormatInfoPatterns = $false ) {
    DateNamedFormatCompletionsAttribute( $Options ) {
        # $this.Options = $Options ?? @{}
        $this.Options = $Options ?? @{
            ExcludeDateTimeFormatInfoPatterns = $false
        }
        # $this.Options.ExcludeDateTimeFormatInfoPatterns = $ExcludeDateTimeFormatInfoPatterns
    }

    [IArgumentCompleter] Create() {
        # return [DateNamedFormatCompleter]::new($this.From, $this.To, $this.Step)
        # return [DateNamedFormatCompleter]::new( @{} )

        '🚀DateNamedFormatCompletionsAttribute..Create()'
            | WriteJsonLog -PassThru
            # | .Log -Passthru
        $This.Options
            | WriteJsonLog -PassThru

        if( $This.Options.ExcludeDateTimeFormatInfoPatterns ) {
            return [DateNamedFormatCompleter]::new( @{
                ExcludeDateTimeFormatInfoPatterns = $This.Options.ExcludeDateTimeFormatInfoPatterns
            } )
        } else {
            return [DateNamedFormatCompleter]::new()
        }
    }
}

# function Try.Named.DateString {
    function Datetime.Format {
        <#
        .SYNOPSIS
            Sugar to format dates that are piped using the same format string

            Get-Date | Datetime.Format -FormatString 'o'
            get-date | Datetime.Format -FormatString "MMMM d"
        #>
        [CmdletBinding()]
        param(
            # which format string to use?
            [Parameter(
                Mandatory, Position = 0,
                ValueFromRemainingArguments
            )]
                [DateNamedFormatCompletionsAttribute()]
                [Alias('Named')]
                [string]$FormatString,

            # dates/times/whatever
            [Parameter(
                Mandatory, ValueFromPipeline
            )]
                [object[]]$InputObject,


            [string]$Culture = 'en-us'

        )
        begin {
            $CultInfo = Get-Culture $Culture
        }
        process {
            $InputObject | %{
                $ExpectedTypes = @(
                    'datetime'
                    'datetimeoffset'
                    'timespan'
                )
                $CurObj = $_

                [bool]$ExpectedType? =
                    $CurObj -is 'Datetime' -or $CurObj -is 'DatetimeOffset' -or $CurObj -is 'timespan'



                if( -not $ExpectedType? ) {
                    throw ( $CurObj.GetType() | Join-String  -F "UnexpectedType, was not a [datetime|datetimeoffset|timespan]: {0}" )
                }

                'Formatting: Fstr: {0}, Culture: {1}, Input: {2}' -f @(
                    $FormatString, $CultInfo, $CurObj
                ) | write-verbose -Verbose

                return $CurObj.ToString( $FormatString, $CultInfo )
            }

        }
    }
function Datetime.NamedFormatStr {
    <#
    .SYNOPSIS
        Generates datetime strings based on human readable format
    .EXAMPLE
        Get-Date -Format (Try.Named.Fstr h:mm tt)
    .EXAMPLE
        Try.Named.Fstr 'Git.Dto'
    .EXAMPLE
        Dotils.Datetime.ShowExamples -FormatStrings ( Try.Named.Fstr yyyy'-'MM'-'dd'T'HH':'mm':'ssZ )
    .LINK
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    .LINK
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
    .LINK
        https://docs.github.com/en/rest/overview/resources-in-the-rest-api?apiVersion=2022-11-28#timezones
    #>
    [Alias(
        'Try.Named.Fstr',
        'Datetime.Named'
    )]
    [CmdletBinding(
        DefaultParameterSetName = 'UsingFullList'
    )]
    param(
        [Parameter(
            Mandatory, Position = 0, ValueFromRemainingArguments,
            ParameterSetName = 'UsingFullList'
        )]
            [DateNamedFormatCompletionsAttribute()]
            [Alias('Name')]
            [string] $DateFormat
        ,

        [Parameter(
            Mandatory, Position = 0, ValueFromRemainingArguments,
            ParameterSetName = 'UsingShortList'
        )]
            [DateNamedFormatCompletionsAttribute( ExcludeDateTimeFormatInfoPatterns = $True )]
            [Alias('WithoutAuto')]
            [string]$ShortFormats
        ,

        [hashtable]$Options
    )

    $PSCmdlet.ParameterSetName | Join-String -f 'ParameterSetName: {0}' | Write-Verbose

    switch($PSCmdlet.ParameterSetName) {
        'UsingFullList' {}
        'UsingShortList' {}
        default { throw "Unknown ParameterSetName: $PSCmdlet.ParameterSetName" }
    }

    $DateFormat
    # write-warning 'next wip: completions may '
}

@(
    'Wip: Currently it doesn''t filter any completiosn for Completions.NamedDateFormatString.psm1'
    "    Source: $PSCommandPath"
    'Todo: Finish descriptions and links: https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings'
    "    Source: $PSCommandPath"
) -join "`n"
    | Write-Warning

Export-ModuleMember -Function @(
    'Datetime.NamedFormatStr'
    'Datetime.Format'
    'WriteJsonLog'
 ) -alias @(
    '.Log'
    'Try.Named.Fstr'
    'Datetime.Named'
    # 'Try.Named.Fstr'
    # 'Datetime.Named'
    # 'Datetime.NamedFormatStr'
 )  -Verbose





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