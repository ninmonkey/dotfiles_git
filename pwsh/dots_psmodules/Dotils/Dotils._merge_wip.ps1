Class SoundNames : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $SoundPaths = '/System/Library/Sounds/',
            '/Library/Sounds','~/Library/Sounds'
        $SoundNames = ForEach ($SoundPath in $SoundPaths) {
            If (Test-Path $SoundPath) {
                (Get-ChildItem $SoundPath).BaseName
            }
        }
        return [string[]] $SoundNames
    }
}

function Dotils.Date.FromObject {
    throw 'nyi; wip: this would take FileSystemInfo inputs, then Select-Namish datetimes'
}
function Dotils.Date.Now {
    <#
    .synopsis
    #>
    [OutputType('Datetime')]
    [CmdletBinding()]
    [Alias('Now')]
    param(
        [Alias('Hour')][string]$HoursAgo,
        [Alias('Sec')][string]$SecondsAgo,
        [Parameter()]
        [string]$RelativeTimeString
    )
    write-warning 'add using hashtable for dynamic completers'
    $Now = [Datetime]::now
    if($PsBoundParameters.ContainsKey('HoursAgo')) {
        $Now = $Now.AddHours( - $HoursAgo )
    }
    if($PsBoundParameters.ContainsKey('SecondsAgo')) {
        $Now = $Now.AddSeconds( - $HoursAgo )
    }
    return $Now
}
$dateFormatMapping = @{
    'o' = 'o'
    'u' = 'u'
    'SafeFiletime.AsSecond' = ''
}





function Dotils.Get-FunctionMetadata {
    <#
    .NOTES
        see more: <https://gist.github.com/StartAutomating/d75cd9eaccfea1b50bc6523256e539a5>
    #>
    [CmdletBinding()]
    param()

    $meta = [ordered]@{

    }

    $gcm.ScriptBlock.Attributes | fl * -Force
}

function Format-NumberMinRequiredPrecision {
    <#
    .SYNOPSIS
        silly function
    #>
    param(  [Parameter(Mandatory, ValueFromPipeline)]
            [Alias('InputObject')]$Number )

    process {
        $renderBig = '{0:n18}' -f $Number
        if($renderBig -match '\..*?[^0]') {
            $min = $matches.values.length - 0
            $fstr = '{{0:n{0}}}' -f ($min)

            # Join-String -op "fstr = '$fstr'"
            # | Join-String -op "min = $Min"
            # | Join-String -op "Number = $Number"
            # | Write-verbose -verbose

            $Number | Join-String -FormatString $fstr
        } else {
            throw ('UnexpectedInput? {0}' -f $InputObject )

            # $innerException = [System.Management.Automation.ErrorRecord]::new(
            #     <# exception: #> $exception,
            #     <# errorId: #> $errorId,
            #     <# errorCategory: #> $errorCategory,
            #     <# targetObject: #> $targetObject)

            # [System.IO.InvalidDataException]::new(
            #     <# message: #> $message,
            #     <# innerException: #> $innerException)
        }
    }
}

0.1, 0.00004, 0.003 | %{ $cur = $_
    [pscustomobject]@{
        Before   = '{0:n7}' -f $cur
        Big = '{0:n16}' -f $cur
        Implicit = $cur
        After    = $cur | Format-NumberMinRequiredPrecision
     }
}
function PsBoundSugarTest {
    [CmdletBinding()]
    param(
        [switch]$WithoutColor,

        [switch]$Without2,
        [switch]$Without3
    )
    $PSCmdlet.MyInvocation.BoundParameters
        | ConvertTo-Json -Depth 2
        | Join-String -op 'Func: ' -sep "`n"
        | write-verbose -verbose

    $noColor = $true
    if($PSBoundParameters.ContainsKey('WithoutColor')) {
        $noColor = $WithoutColor
    }
    $noColor2 = $Without2 ?? $true
    $noColor3 ??= $Without3 ?? $true
    [ordered]@{
        WithoutColor = $WithoutColor ?? '␀'
        Without2 = $Without2 ?? '␀'
        Without3 = $Without3 ?? '␀'

        NoColor = $NoColor
        NoColor2 = $noColor3
        NoColor3 = $noColor3

    }
}

function ninInvoke-NewBurntToastProxy {
    param(
        [Microsoft.Toolkit.Uwp.Notifications.ToastHeader]$Header,
        [Microsoft.Toolkit.Uwp.Notifications.IToastButton[]]$Button,
        [Microsoft.Toolkit.Uwp.Notifications.AdaptiveSubgroup[]]$Column,
        [string[]]$Text,
        [string]$AppId,
        [string]$AppLogo,
        [string]$HeroImage,
        [switch]$Silent,
        [switch]$SuppressPopup,
        [switch]$SnoozeAndDismiss,
        [Microsoft.Toolkit.Uwp.Notifications.AdaptiveProgressBar[]]$ProgressBar,
        [switch]$Confirm,
        [switch]$Whatif,
        [scriptBlock]$DismissedAction,
        [scriptBlock]$ActivatedAction,
        [datetime]$CustomTimestamp,
        [string]$UniqueIdentifier,
        [hashtable]$Databinding
    )
}
