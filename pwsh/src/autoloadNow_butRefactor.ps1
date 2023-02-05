"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>



function Test-ModuleWasModified {
    <#
    .SYNOPSIS
        simplify autoimporting changes
    .EXAMPLE
        Test-ModuleWasModified -Duration 30seconds -Path '.'
    #>
    [OutputType('System.Boolean')]
    [CmdletBinding()]
    param(
        # duration to test modified against
        [ArgumentCompletions('30seconds', '2minutes', '2hours', '1days')]
        [string]$Duration,

        # filters? -e parameter
        [ArgumentCompletions('ps1', 'md', 'png', 'log')]
        [string[]]$Extension,

        # path
        [Alias('Path')]
        [Parameter(Mandatory, Position = 0)]
        [string]$BaseDirectory
    )

    $binFd = Get-Command -CommandType Application 'fd' -ea 'stop'
    $resolvedPath = Get-Item -ea 'stop' $BaseDirectory

    [Collections.Generic.List[Object]]$fd_args = @(
        if ($Extension) {
            $Extension | ForEach-Object { '-e', $_ }
        }
        '--changed-within'
        $Duration
        '--search-path'
        (Get-Item -ea stop $resolvedPath)
    )

    $fd_query = & fd @binFd
    [bool]$hasChanged = $fd_query.count -gt 0

    $renderArgs = $fd_args | Join-String -sep ' ' -op 'invoke: fd '
    | Write-Debug

    'testing for changes...:
    Changed? {0}
    Extensions: {1}
    Path: {2}' -f @(
        $hasChanged
        $Extension | Join-String -sep ', ' -op ''
        $resolvedPath | Join-String -DoubleQuote -op ''
    ) | Write-Verbose

    return $hasChanged
}

function Err {
    <#
    .SYNOPSIS
        Useful sugar when debugging inside a module Sugar for quickly using errors in the console.  2023-01-01
    .DESCRIPTION
        For different contexts, $error.count can return 0 values even though
        there are errors. Explicitly referencing global:errors will work
        for regular mode, or module breakpoints.

        Useful when debugging inside a module Sugar for quickly using errors in the console.  2023-01-01
    .EXAMPLE
        err -TotalCount
            1
        err -TestHasAny
            $true

        err -Num 4
            errors[0..3]

        err -clear
            resets even global errors.
    #>
    [Alias('prof.Err')]
    param(
        [int]$Num = 10,
        [switch]$Clear,
        [Alias('Count')]
        [switch]$TotalCount,

        [Alias('HasAny')]
        [switch]$TestHasAny
    )
    if ($TestHasAny) {
        return ($global:error.count -gt 0)
    }
    if ($TotalErrorCount) {
        return $global:error.count
    }

    if ( $Clear) { $global:error.Clear() }
    if ($num -le $global:error.count ) {
        "Number of Errors: $($global:error.count)" | Write-Verbose
    }
    return $global:error | Select-Object -First $Num
}


function prof.hack.dumpExcel {
    # super quick hack, do not use
    [Alias('out-xl', 'to-xl')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TableName = 'default',

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        $Items.AddRange( $InputObject )
    }
    end {
        $items
        | Export-Excel -work 'a' -table $TableName -AutoSize -Show -Append -TableStyle Light2 #-Verbose -Debug
    }
}


"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>