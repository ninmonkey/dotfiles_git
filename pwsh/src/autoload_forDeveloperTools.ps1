
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