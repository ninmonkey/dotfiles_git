using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
# using namespace System.Collections


# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#class-based-argument-completers

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#dynamic-validateset-values-using-classes





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
        <#.example

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

'Wip: Currently it doesn''t filter any completiosn for Completions.NamedDateFormatString.psm1'
| Write-warning

Export-ModuleMember -Function @( 'Try.Named.Fstr'  ) -Verbose





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