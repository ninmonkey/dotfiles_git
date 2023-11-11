using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#class-based-argument-completers

# // https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Functions_Argument_Completion?view=powershell-7.4&WT.mc_id=ps-gethelp#dynamic-validateset-values-using-classes


Class NamedDateFormatStringsBasic : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $basicDates =
            'o', 'O', 'RoundTrip', 'ShortDate', 'LongDate'
        # $SoundNames = ForEach ($SoundPath in $SoundPaths) {
        #     If (Test-Path $SoundPath) {
        #         (Get-ChildItem $SoundPath).BaseName
        #     }
        # }
        return [string[]] $basicDates
    }
}

function Named.DateString.Basic {
    param(
        [Parameter(Mandatory, Position = 0)]

        [ValidateSet([NamedDateFormatStringsBasic])]
        [string] $NamedDate
    )
    $NamedDate
}

Named.DateString.Basic ShortDate
hr
Class NamedDateFormatStringsWithoutCE : IValidateSetValuesGenerator {
    # tw.New-CompletionResult -Name
    # 'o', 'O', 'RoundTrip', 'ShortDate', 'LongDate'

    # [CompletionResult[]] GetValidValues() {
    [string[]] GetValidValues() {
        [List[Object]]$CompletionResults = @(
            New-TypeWriterCompletionResult -Text 'ShortDate' -listItemText 'ShortDate2' -resultType Text -toolTip 'ShortDate (default)'
            New-TypeWriterCompletionResult -Text 'LongDate' -listItemText 'LongDate2' -resultType Text -toolTip 'LongDate (default)'
        )

        # return $CompletionResult
        # return [string[]] $CompletionResults
        # return [string[]]( $CompletionResults )
        return [string[]]( $CompletionResults ).CompletionText
    }
}

function Named.DateStringWithoutCE {
    param(
        [Parameter(Mandatory, Position = 0)]

        [ValidateSet([NamedDateFormatStringsWithoutCE])]
        [string] $NamedDate
    )
    $NamedDate
}

Named.DateStringWithoutCE 'ShortDate'

# Named.DateString ShortDate