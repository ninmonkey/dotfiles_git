
function GL.nin.ShowLocalAzureWebpage {
    # opens localhjost at whichever port was used
    $m1 = Get-Job | Receive-Job -Keep
    | Select-String 'http://localhost:\d+/SHowGitLogger' | Select-Object -First 1
    throw 'not finished'
@'
based on log file
    1] grep an endpoint
    2] open it on the port
    3] use func command to give me the endoints

'@

}
function GL.nin.ShowAzureFuncLogs {
    <#
    .SYNOPSIS
        quickly view log output of the local azure HTTP server
    .notes
        # if you don't include -keep by default, then add-content would work
        # but it's keep so every invoke returns the entire log file, so truncating it is ok
    .example
        # Original:
        # 1] Start server:
        Start-Job -WorkingDirectory 'H:\data\2023\pwsh\GitLogger\Azure\Function' -ScriptBlock { func start }

        # 2] read log, including IP
        Get-Job | receive-Job -Keep | set-content Foo.log -PassThru
    #>
    param(
        [string]$Dest = 'G:\temp\xl\gitLogger_localAzure_receiveJob.log',
        [switch]$AutoOpen
    )
    # $Dest = 'G:\temp\xl\gitLogger_localAzure_receiveJob.log'

    Get-Job
    | Receive-Job -Keep
    | CountOf 'Jobs: '
    | Set-Content $Dest -PassThru
    | CountOf 'LogLines: '

    $Dest | Get-Item -ea stop | Join-String -f 'Wrote: <file:///{0}>'

}

function nb.renderHash {
    <#
    .synopsis
        pretty print hashtable, automatically drop nested
    .example

        nb.renderHash $yak
        nb.renderHash $yak -IgnoreNested
    #>
    [CmdletBinding()]
    [Alias('prof.nb.renderHash', 'Nancy.Render.Hashtable',
        'toRefactor.Nancy.Render.Hashtable')]
    param(
        $InputObject, # dictionary/hash/peypairs type,
        [switch]$IgnoreNested
    )

    $Longest = $InputObject.Keys.Length | Measure-Object -Maximum | % Maximum
    $template = @{}
    $template.BeforePadding = '{{0,{0}}} : {{1}}'
    $template.PadRight = $template -f @( $Longest )

    $InputObject.GetEnumerator()
    | Join-String {
        [bool]$isNested = $_.Value.values.count -gt 0
        if ($isNested -and $IgnoreNested) {
            return
        }
        $template.BeforePadding -f $Longest -f @(
            $_.Key
            $_.Value
        )
    } -sep "`n"
}

function nb.where-ValuesAreNotNestedHash {
    <#
    .SYNOPSIS
        when enumerating key collections, this will filter based on whether they are nested or flat
    .EXAMPLE
        $yak.GetEnumerator() | nb.where-ValuesAreNotNestedHash
        $yak.GetEnumerator() | nb.where-ValuesAreNotNestedHash -OnlyNested
    #>
    param( [switch]$OnlyNested )

    if ($OnlyNested) {
        $input | ? { $_.Value.values.count -gt 0 }
    }
    else {
        $input | ? { $_.Value.values.count -le 0 }
    }
}

Import-Module Ninmonkey.Console
