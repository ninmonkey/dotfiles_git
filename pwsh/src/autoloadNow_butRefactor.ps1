"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


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