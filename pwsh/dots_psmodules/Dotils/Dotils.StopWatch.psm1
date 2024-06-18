using namespace System.Timers
using namespace System.Collections.Generic
using namespace System.Diagnostics

write-warning 'finish cleanup implmenent'

[Timers.Timer]$Timer = @{
     Interval = 100
     AutoReset = $false
     Enabled = $true
}

# $sw = [Stopwatch]::StartNew()
# $sw.ElapsedMilliseconds
$script:_watches = [ordered]@{}
function Dt.Stopwatch.New {
    <#
    .SYNOPSIS
        wrapper that tracks a collection of stopWatches by name
    #>
    [OutputType('System.Diagnostics.StopWatch')]
    [Alias('w.New')]
    param(
        [Alias('Name')]
        [Parameter()]
        [string]$Label,
        # default will return and start a new instance
        [switch]$WithoutAutoStart
    )
    $prevCount = $script:_watches.Count
    $props = @{
        Label = $Label
        CreatedByCmd = $MyInvocation.MyCommand.Name
    }
    $addMemberSplat = @{
        NotePropertyMembers = $Props
        PassThru = $true
        Force = $true
    }

    'Watcher::Removed watches -All, count = {0} [ was: {1} ]' -f @(
            $script:_watches.Count
            $prevCount
        ) | Dotils.Write-DimText | Infa

    if($WithoutAutoStart) {
            # anti-performant

        $w = [Diagnostics.StopWatch]::new()
            | Add-Member @addMemberSplat
    } else {
        $w = [Diagnostics.Stopwatch]::StartNew()
            | Add-Member @addMemberSplat
    }
    if(  -not [string]::IsNullOrWhiteSpace($Label) ) {
        $script:_watches[ $Label ] = $w
    }
    return $w
}

function Dt.StopWatch.Get {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Alias(
        'w.Get'
    )]
    param(
        # label for lookup
        [Parameter(ParameterSetName='ByName')]
        [Alias('Name')]
        [string]$Label,
        # else dump all
        [Parameter(Mandatory, ParameterSetName='ActOnAll')]
        [switch]$All
# #
#         [switch]$AsValue = $true
    )

    if($All) {
        # return $script:_watches.GetEnumerator() | % Value
        return $script:_watches
    }
    if($Script:_watches.Contains($Label)){
        return $script:_watches[ $Label ]
    }
}
function Dt.StopWatch.Remove {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Alias(
        'w.Remove'
    )]
     param(
        # Label for lookup
        [Parameter(ParameterSetName='ByName')]
        [Alias('Name')]
        [string]$Label,

        # else drump all
        [Parameter(Mandatory, ParameterSetName='ActOnAll')]
        [switch]$All
    )
    $prevCount = $script:_watches.Count
    if($All) {
        $script:_watches.clear()

        'Watcher::Removed watches -All, count = {0} [ was: {1} ]' -f @(
            $script:_watches.Count
            $prevCount
        ) | Dotils.Write-DimText | Infa

        return
    }
    if($Script:_watches.Contains($Label)){
        $script:_watches.Remove[ $Label ]
    }
    'Watcher::Removed watch {0}, count = {1} [ was: {2} ]' -f @(
        $Label
        $script:_watches.Count
        $prevCount
    ) | Dotils.Write-DimText | Infa
}

Dt.Stopwatch.New -Label 'first'
Sleep 0.3
Dt.Stopwatch.New -Label 'later'
Sleep 0.3
Dt.StopWatch.Get -All

$Action = {
    $colors = gci fg: | Get-Random -count 4
    $colors | %{ $_.X11ColorName | New-text -fg $_ }  | Join-String -sep ' '
    | Infa

}



# return

# if($false) {
# $GitPromptSettings.DefaultPromptSuffix = '$($global:pos = [console]::GetCursorPosition()) $((Get-History -Count 1).Duration.ToString() -replace "^(00:)+" -replace "^0" -replace "(?<=\.\d{2}).*")$($PSStyle.Foreground.BrightCyan)[$(Get-date -f "HH:mm:ss")]$($PSStyle.Reset)' + $GitPromptSettings.DefaultPromptSuffix.Text

# $timer = [System.Timers.Timer]::new()
# $timer.Interval = 1000
# $timer.AutoReset = $true
# $action = {
#     $currentPos = [console]::GetCursorPosition()
#     if ($global:lastupdatetime -lt (Get-Date).AddSeconds(-2)) {
#         $global:pos = [console]::GetCursorPosition()
#     }
#     $global:lastupdatetime = get-date
#     [console]::SetCursorPosition(0,$Global:pos.item2)
#     [console]::Write((prompt))
#     [console]::SetCursorPosition($currentPos.Item1, $currentPos.Item2)
# }
# $start = Register-ObjectEvent -InputObject $timer -SourceIdentifier 100 -EventName Elapsed -Action $action
# $timer.start()

# }
