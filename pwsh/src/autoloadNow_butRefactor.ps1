"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


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