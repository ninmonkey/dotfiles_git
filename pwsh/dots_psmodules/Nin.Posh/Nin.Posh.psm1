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

function Nin.Posh.Write-CountOf {
    <#
    .SYNOPSIS
        Count the number of items in the pipeline, ie: @( $x ).count
    .NOTES
        Any alias to this function named 'null' something
        will use '-OutNull' as a default parameter
    .EXAMPLE
        gci | CountOf # outputs files as normal *and* counts
        'a'..'e' | Null🧛  # count only
        'a'..'e' | Null🧛  # labeled
        'a'..'e' | Null🧛 -Extra  # count only /w type names
        'a'..'e' | Null🧛 -Extra -Name 'charList'  # labeled type names
    .EXAMPLE
        for unit test

            . $redot
            $stuff = 'a'..'c'
            $stuff | CountOf
            $stuff | Null🧛

            $stuff | CountOf -Label 'Count' -Extra
            $stuff | Null🧛 -Label 'Null' -Extra

    .EXAMPLE
        ,@('a'..'e' + 0..3) | CountIt -Out-Null
        @('a'..'e' + 0..3) | CountIt -Out-Null

        # outputs
        1 items
        9 items
    #>
    # [CmdletBinding()]
    # [Alias('Len', 'Len🧛‍♀️')] # warning this breaks crrent parameter sets
    [Alias(
        'CountOf', 'Len',
        # '🧛Of',
        # 'Len',
        # '-OutNull', # works, but does not generate completions
        '🧛', # puns are fun
        # 'Out-Null🧛',
        'OutNull',
        'Null🧛' # puns are fun
    )]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        # Show type names of collection and items
        [Alias('TypeOf')]
        [switch]$Extra,

        # optionally label numbers
        [Alias('Name', 'Label')]
        [Parameter(Position = 0)]
        [string]$CountLabel,

        # Also consume output (pipe to null)
        [switch]${Out-Null},

        [ArgumentCompletions(
            '@{ LabelFormatMode = "SpaceClear" }'
        )][hashtable]$Options
    )
    begin {
        [int]$totalCount = 0
        [COllections.Generic.List[Object]]$Items = @()
        $Config = $Options
    }
    process { $Items.Add( $InputObject ) }
    end {
        $null = 0
        # wait-debugger
        if ( ${Out-Null}.IsPresent -or $PSCmdlet.MyInvocation.InvocationName -match 'null|(Out-?Null)') {
            # $items | Out-Null # redundant?
        }
        else {
            $items
        }
        $colorBG = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg = $PSStyle.Foreground.FromRgb('#e5701c')
        $colorFg = $PSStyle.Foreground.FromRgb('#f2962d')
        $colorBG_count = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg_count = $PSStyle.Foreground.FromRgb('#f2962d')
        $colorFg_label = $PSStyle.Foreground.FromRgb('#4cc5f0')
        $colorBG_label = $PSStyle.Background.FromRgb('#376bce')
        @(

            $render_count = '{0} items' -f @(
                $items.Count
            )
            if ($CountLabel) {
                @(
                    $LabelFormatMode = 'SpaceClear'

                    switch ($Config.LabelFormatMode) {
                        'SpaceClear' {
                            $colorFg_label, $colorBG_label
                            # style 1
                            $CountLabel
                            $PSStyle.Reset
                            ' ' # space before, between, or last color?

                            $ColorFg_count
                            $ColorBg_count
                            $render_count
                        }
                        default {
                            $colorFg_label, $colorBG_label
                            # style 1
                            $CountLabel
                            '' # space before, between, or last color?
                            # $PSStyle.Reset
                            $PSStyle.Reset
                            $ColorFg_count
                            $ColorBg_count
                            $render_count

                        }
                    }
                )
                $renderLabel -join ''
            }
            else {
                $ColorFg_count
                $ColorBg_count
                $render_count
            }

            # $PSStyle.Reset
            # $PSStyle.Foreground.FromRgb('#e5701c')
            "${fg:gray60}"
            if ($Extra) {
                ' {0} of {1}' -f @(
                    ($Items)?.GetType().Name ?? "[`u{2400}]"
                    # $Items.GetType().Name ?? ''
                    # @($Items)[0].GetType().Name ?? ''
                    @($Items)[0]?.GetType() ?? "[`u{2400}]"
                )
            }
            $PSStyle.Reset
        ) -join ''
        | Write-Information -infa 'Continue'


    }
}

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

function NinPosh.Show-ModuleSummary {
    Import-Module 'ImportExcel' -pass
    | Dotils.Summarize.Module

    write-verbose 'check the sketch that already builds an excel sheet summary'

}