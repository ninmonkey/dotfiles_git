$PROFILE | Add-Member -NotePropertyName 'Pwsh.Nin.Posh' -NotePropertyValue (Get-item $PSCommandPath ) -Force -ea 'ignore'
Import-Module 'Posh'

# $script:__np_recencyState ??= @{}
[ValidateNOtNull()][hashtable]$script:__np = @{}

$script:__np.errorRecencyState = @{
    LastCount = 0
    LastTimeNow = [Datetime]::Now
    TimeSinceReset = 0
    DurationThreshold = [timespan]::new( 0, 0, 20 )
}
<#
$start = get-date
$DurationThreshold = [timespan]::new( 0, 0, 3 )
do {
'.'
sleep 0.3
} while( ((get-date) - $start ) -lt $DurationThreshold  )

#>

# function NinPosh.GroupBy.Type {
#     $Input | Group { $_.GetType() | Format-ShortTypeName } -NoElement
# }

function Nin.Posh.ConvertTo.TimeSpan {
    [OutputType('Timespan')]
    [Alias('.np.to.Timespan')]
    param()
    process { $Obj = $_
    $timespan? = if( $Obj -is 'timespan') {
        return $Obj
    } elseif ( $Obj.Time -is 'timespan') {
        return $Obj.Time
    } elseif( $Obj.Duration -is 'timespan') {
        return $Obj.Duration
    } else {
        throw "Unexpected type: $( $Obj | Format-ShortTypeName )"
    }
    return $timespan?
} }

function Nin.Posh.GroupBy.TypeName {
    <#
    .SYNOPSIS
        conditionally group
    .notes
        later could
    #>
    [CmdletBinding()]
    [Alias('GroupBy.TypeName')]
    param(
        [Parameter(Position=0)]
        [ValidateSet(
            'ShortType',
            'Name', 'NameSpace',
            'Namespace,Name',
            'PSTypes',
            'FullName'
        )]
        [string]$TypeKind = 'ShortType',

         [Parameter(
            Mandatory,
            ValueFromPipeline)]
        [object[]]$InputObject,

        [switch]$NoElement
    )
    begin {
        [Collections.Generic.List[Object]]$items =  @()
    }
    process {
        foreach($Item in $InputObject) { $items.add( $Item ) }
    }
    end {
        $items | Group-Object -NoElement:$NoElement {
            $curObj = $_
            $tinfo = $curObj | Resolve.TypeInfo
            # $tinfo = $curObj.GetType()
            $value = switch($TypeKind) {
                'ShortType' {
                    $curObj | Format-ShortTypeName
                }
                'Name' { $tinfo.Name }
                'NameSpace' { $tinfo.Namespace, $tinfo.Name }
                'NameSpace' { $tinfo.Namespace }
                'PSTypes' { $tinfo.Namespace }
                'FullName' { $tinfo.FullName }
                default {
                    throw "Unhandled TypeKind: $TypeKind"
                }
            }
            $value | write-debug
            return $value
        }
    }
}

function NinPosh.Group-Kind {
    param(
        # What kind? fuzzy ?
        [Alias('Kind', 'Name')]
        [Parameter( Position=0 )]
        [ValidateSet(
            'Auto',
            'Date.Recent',
            'Date.Year',
            'TypeName'
        )][string]$GroupKind = 'Auto',

        [Parameter(
            Mandatory,
            ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        write-warning 'nyi; or requires confirmation; mark;'
        [List[Object]]$Items = @()
        $Config.PropertyName = 'Name'
    }
    process {
        $items.AddRange(@($InputObject))
    }
    end {
        $Items | Sort-Object
        switch($GroupKind) {
            'Auto' {
                $func = {}
            }
            'Date.Recent' {
                $func = {}
            }
            'Date.Year' {
                $func = {}
            }
            'TypeName' {
                $func = {}
            }
            default {
                throw "Unhandled GroupKind: $GroupKind"
            }
        }

    }
}
function NinPosh.Write-ErrorRecency {
    <#
    how many errors relative the previous call
    .NOTES
        todo: future: wip:
        - [ ] instead of per-prompt, mark recent based on time
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateSet('Number', 'DeltaVsTotal', 'Default')]
        [string]$OutputFormat = 'Number',

        # don't increment
        [Alias('NoSave')][switch]$WithoutSave
    )
    $script:__np.errorRecencyState |ft -AutoSize | oss| Write-debug
    $count_now = $global:Error.count
    [int]$delta = $count_now - $script:__np.errorRecencyState.LastCount
    write-warning 'nyi, to write'

    if( -not $WithoutSave) {
        $script:__np.errorRecencyState.LastCount = $count_now
    }
    $script:__np.errorRecencyState.LastTimeNow = [Datetime]::Now


    $script:__np.errorRecencyState.LastCount = $count_now
    switch($OutputFormat){
        'DeltaVsTotal' {
            $template = '{0} of {1}'
            <#
            when new:
             prints [3] 15

            when old:
                15

             #>
            $template -f @(
                $count_now
                $delta
            )
            | New-Text -fg 'orange'
            | Join-String -f " {0} "

        }
        'Number' {
            $delta
            | New-Text -fg 'orange'
            | Join-String -f " {0} "

        }
        default { "UnhandledFormat: $OutputFormat "}
    }
}
