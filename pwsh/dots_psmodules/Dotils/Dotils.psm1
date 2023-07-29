function Console.GetColumnCount {
    [OutputType('System.Int32')]
    param()
    $w = $host.ui.RawUI.WindowSize.Width
    return $w
}


function Dotils.Format.Write-DimText {
    <#
    .SYNOPSIS
        # sugar for dim gray text,
    .EXAMPLE
        # pipes to 'less', nothing to console on close
        get-date | Dotils.Write-DimText | less

        # nothing pipes to 'less', text to console
        get-date | Dotils.Write-DimText -PSHost | less
    .EXAMPLE
        > gci -Name | Dotils.Write-DimText |  Join.UL
        > 'a'..'e' | Dotils.Write-DimText  |  Join.UL
    #>
    [OutputType('String')]
    [Alias('Dotils.Write-DimText')]
    param(
        # write host explicitly
        [switch]$PSHost
    )
    $ColorDefault = @{
        ForegroundColor = 'gray60'
        BackgroundColor = 'gray20'
    }

    if($PSHost) {
        return $Input
            | Pansies\write-host @colorDefault
    }

    return $Input
        | New-Text @colorDefault
        | % ToString
}
function Dotils.Write.Info {
    [Alias('Write.Info')]
    param()
    # render as text, to the information stream
    # mainly sugar to enable it
    $Input
    | Out-String -w 1kb
    | Write-Information -infa 'Continue'
}
function Dotils.Write.Info.Fence {
    [Alias('Write.Info.Fence')]
    param()
    $content = $Input
    $content -split '\r?\n'
    | Join-String -f '    {0}'
    | Join-String -op "`nfence`n" -os "`ncloseFence`n"
}
function Dotils.String.Normalize.LineEndings {
    # replace all \r\n sequences with \n
    [Alias('String.Normalize.LineEndings')]
    param()
    process {
        $_ -replace '\r?\n', "`n"
    }
}
function Dotils.ClampIt {
    # polyfill. Pwsh Can use [Math]::Clamp directly.
    [Alias('ClampIt')]
    param ( $value, $min, $max )

    [Math]::Min(
        [Math]::Max( $value, $min ), $max )
}
function Dotils.String.Visualize.Whitespace {
    [Alias('String.Visualize.Whitespace')]
    param( [switch]$Quote)
    process {
        ( $InputObject = $_ )
        | Join-String -SingleQuote:$quote
        | New-Text -bg 'gray30' -fg 'gray80' | % tostring
    }
}
function Dotils.Debug.Find-Variable {
    # gives metadata to querry against
    get-variable
        | %{
            <#
                $_.Value
                    # can you do this as a coalesce? might require error record
                    | Format-ShortTypeName -ea 'ignore' || '<missing>'

            see also:
                LocalVariable
                NullVariable
                PSCultureVariable
                PSUICultureVariable
                PSVariable
                QuestionMarkVariable

            Now the normal version
            #>

# function Dotils.Format-TaggedUnionString {

    #  System.Management.Automation.PSVariable
        [pscustomobject]@{
            # PSTypeName = 'Dotils.PSVariable'
            PSTypeName = 'sma.PSVariable'
            what       = $_.Name
            value      = $_.Value
            Kind       = $_.Value.GetType().Name
            ShortName  =
                $_.Value
                | Format-ShortTypeName -ea 'ignore' #|| '<missing>' # can you do this ?
        }
    }
      #| to-xl

}

function Dotils.String.Transform.AlignRight {
    # replace all \r\n sequences with \n
    [Alias('String.Transform.AlignRight')]
    param(
        [switch]$ShowDebugOutput
    )
    process {

        $InputObject = $_
        $re = '^\s*(?<Content>.*?)\s*$'

        $InputObject -split '\r?\n'
        | % {
            [string]$curLine = $_

            if ($ShowDebugOutput) {
                label 'what' 'orig'
                $curLine
                | String.Visualize.Whitespace
                | Write.Info
            }

            if ($curLine -match $Re) { } else { return }
            $withoutPadding = $matches.Content ?? ''

            if ($ShowDebugOutput) {
                label 'what' 'without pad'
                $withoutPadding
                | String.Visualize.Whitespace
                | Write.Info
            }

            $width = (Console.GetColumnCount) ?? 120
            $render = $withoutPadding.ToString().PadLeft( $width, ' ')
            if ($ShowDebugOutput) {
                label 'what' 'new pad'

                $render
                | String.Visualize.Whitespace
                | Write.Info
            }
            return $render
        }
    }
}

if($false) {
    $reason = 'write-warning param binding keeps breaking on import, often silently'

function Dotils.PSDefaultParams.ToggleAllVerboseCommands {
    <#
    .SYNOPSIS
        sugar to toggle PSDefaultParameterValues on and off for a lot of commands
    .DESCRIPTION
        Attempts to import the module first.
        currently only selects 'function' commands
        aliases might not be included ?

    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(position=0, Mandatory)]
        [ArgumentCompletions(
            'ImportExcel', 'Pipescript',
            'Ninmonkey.Console',
            'ExcelAnt',
            'Dotils',
            'TypeWriter',
            'ugit', 'GitLogger'
        )]
        [string]$ModuleName,

        [Parameter(position=1, Mandatory)]
        [ValidateSet('Enable', 'Disable')]
        [string]$VerboseMode

        # [Alias('On')][switch]$Enable,
        # [Alias('Off')][switch]$Disable
    )


    if($Enable)  { $VerboseMode = 'Enable'  }
    if($Disable) { $VerboseMode = 'Disable' }

    import-module $ModuleName -ea 'stop'

    gcm -m $ModuleName
        | ? CommandType -eq 'function'
        | Sort-Object -Unique
        | %{
            $keyName = "{0}:Verbose" -f $_.Name
            $keyName | Join-String -f 'add/remove key: "{0}"' -sep "`n"
                    | write-verbose
            if($VerboseMode -eq 'Enable') {
                $PSDefaultParameterValues[ $keyName ] = $true
            } else {
                $PSDefaultParameterValues.
                    Remove( $keyName )
            }
        }

    $PSDefaultParameterValues.
        GetEnumerator()
        | Sort-Object Name
        | OutNull 'DefaultParams'

    }
}
function Dotils.Grid {

    <#
    .SYNOPSIS
    all the docs were in the other place

    .EXAMPLE
        0..50 | Grid -Count 10 -PadLeft 5
        0..50 | Grid -Count 10 -PadLeft 1
        0..50 | Grid -Auto -Count 3
    #>
    [Alias(
        'Grid',
        'Nancy.OutGrid'
    )]
    param(
        [int]$Count = 8,
        [int]$PadLeft,
        [switch]$Auto
    )
    $all_items = $Input
    if ($Auto) {
        $w = $host.ui.RawUI.WindowSize.Width
        $perCell = $PadLeft -gt 0 ? $PadLeft : 6
        [int]$numItems = $w / $perCell # auto floors ?
        #             $perCell = $w / ( $PadLeft ?? 6 )
        $Count = $numItems
    }

    $all_items | Ninmonkey.Console\Iter->ByCount -Count $Count | % {
        $_
        | Join-String -sep ', ' {
            if (-not $PadLeft) { return $_ }
            return $_.ToString().PadLeft( $PadLeft, ' ' )

        }
        # | Join-String -sep '' { $Template.Hex -f $_ }
        | Format-Predent -PassThru -TabWidth 4
    } | Join-String -sep ''
}


function Dotils.Stdout.CollectUntil.Match {
    #  Dotils.Stdout.CollectUntil.Match #  PipeUntil.Match
    <#
    .synopsis
    asfdsf
    .notes
    warning need naming clarification.

                wait until a pattern is found in the input stream.

                collect until : match found
                Get?Until -match $regex -then quit
                    or -then become silent pass through ?
                    out: a..f


                or
                    Collect|Capture|ProcUntil
                    param:
    future:
        -ProcessUntil RegexMatch 'gateway' # ie: Ignores, but allows rest to continue
        - allow context, so last match plus N lines
    .EXAMPLE
        ipconfig /all
        | Dotils.Stdout.CollectUntil.Match 'gate'
        | CountOf

        ipconfig /all
        | Dotils.Stdout.CollectUntil.Match 'gate' -WithoutIncludingFinalMatch
        | CountOf

    #>
    [Alias(
        # 'Dotils.Stdout.WatchUntil.Match',
        'PipeUntil.Match'
    )]
    param(
        # Should it continue to output all text while waiting?
        # like set-content -passthru
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('InputText', 'Text', 'Content')]
        [object[]]$InputObject,

        [Parameter(Mandatory, Position = 0)]
        [Alias('Regex' , 'Re')]
        [string]$Pattern,

        # allow context, so last match plus result plus +N lines before or after or both
        [int]$Context, # default to 0 or null?  = 0,


        # should the match be part of the result set?
        [switch]$WithoutIncludingFinalMatch,
        [Alias('Kwargs')][hashtable]$Options
    )
    begin {
        $HasFoundPattern = $false
        if ($Context) { throw 'NotYetImplementedException: flags like grep. -Context/-Before/-After:' }

    }
    process {
        if ($HasFoundPattern) { return }

        Foreach ($item in $InputObject) {
            if ($HasFoundPattern) { return }
            if ($Item -match $Pattern) {
                $HasFoundPattern = $true
                if ( $WithoutIncludingFinalMatch ) { return }
            }
            $Item
        }
    }
    end {

    }
}


function Dotils.Debug.Get-Variable {
    <#
    .SYNOPSIS
        Get variable, using regex patterns
    .example
        Dotils.Get-Variable '\d+' -Scopes Local
    .example
        Dotils.Get-Variable 'path' -Scopes 0..10
    .link
        Dotils.Debug.Compare-VariableScope
    .link
        Dotils.Debug.Get-Variable
    #>
    [OutputType(
        'PSVariable[]',
        'System.Management.Automation.PSVariable[]')]
    [CmdletBinding()]
    param(
        [Alias('Pattern', 'Regex')]
        [Parameter(Mandatory)]
        [string[]]$InputPattern,

        [ArgumentCompletions(
            'Global', 'Script', 'Local',
            '0', '1', '2', '3', '4', '5', '6'
        )]
        [Parameter(Mandatory)]
        [string[]]$Scopes = 'Local'
    )
    write-warning 'double check output works with debugger scope as expected, maybe embedded session is better with explicit global scope in cases'

    $whoAmI =
        $PSCmdlet.
            MyInvocation.
            MyCommand.
            Name # ( $parentCmdlet = Get-Variable 'PSCmdlet' -Scope 1 )

    [Collections.Generic.List[Object]]$results =
        @()
    '⭝ enter: Dotils.Debug.Get-Variable'
        | Join-String -op $WhoAmi
    foreach($curScope in $Scopes) {
        foreach($curRegex in $InputPattern) {

            $query = Get-Variable -Scope $curScope -Name '*'
            # experimenting with making misleading continuations
            'Num?: {0} -Scope {1} | Where: {2}' -f
                @(  $query.
                        Count, $curScope, $curRegex
                )
            | Write-Verbose

            if(-not $query) {'failed' | write-verbose  }
            # use raw for now, maybe transform later
            $results.AddRange(@( $Query ))
        }

    }
    '⭂ exit: Dotils.Debug.Get-Variable'
        | Join-String -op $WhoAmi
    return $results
}

function Dotils.Debug.Compare-VariableScope {
    <#
    .SYNOPSIS
        Compare-Object on variables by name (and value?) returns only compare-object
    .link
        Dotils.Debug.Compare-VariableScope
    .link
        Dotils.Debug.Get-Variable
    #>
    [CmdletBinding()]
    param(
        [string]$Scope1 = '0',
        [string]$Scope2 = '1'

    )
    $getVars1 = Get-Variable -scope $Scope1 -ea 'continue'
    $getVars2 = Get-Variable -scope $Scope2 -ea 'continue'

    @{
        Vars1Count = $getVars1.Count
        Vars2Count = $getVars2.Count
        Names1 =
            $getVars1.Name
                | Sort-Object -Unique
                | Join-string -sep ', ' -p {
                    $_ | New-text -fg gray80 -bg gray30
                }

        Names2 =
            $getVars2.Name
                | Sort-Object -Unique
                | Join-string -sep ', ' -p {
                    $_ | New-text -fg gray80 -bg gray30
                }

    } | ft  | out-string
            | Write-Information -ea 'continue'
        # | write-verbose -verbose
    Compare-Object ($getVars1) ($getVars2)
    return
}

function Dotils.Write-NancyCountOf {
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
        ,@('a'..'e' + 0..3) | CountOf -Out-Null
        @('a'..'e' + 0..3) | CountOf -Out-Null

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
        , 'nin.exportMe'
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

        # Count and Consume all output. (pipes to null)
        # Equivalent to calling CountOf and then | Out-Null
        # Automatically defaults to be on when alias to 'Write-NancyCountOf'
        # has the string null in it, like 'OutNull' (the command alias, rather than this param alias does this)
        [Alias('Out-Null')]
        [switch]${OutNull},

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
        if ( $OutNull -or ${OutNull}.IsPresent -or $PSCmdlet.MyInvocation.InvocationName -match 'null|(Out-?Null)') {
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
                            ' '
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
                            ' '
                            $render_count

                        }
                    }
                )
                $renderLabel -join ''
            }
            else {
                $ColorFg_count
                $ColorBg_count
                ' '
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

function Dotils.FindExceptionSource  {
    <#
    .SYNOPSIS
    .LINK
        Dotils.JoinString.As
    .notes
        future:
        - [ ] auto bind using parameternames, so piping $error array works automatic

        see methods: $serr | fime * -Force

    .example
        PS> $error[0]       | Dotils.FindExceptionSource
        PS> $error[0..3]    | Dotils.FindExceptionSource
        PS> $error          | Dotils.FindExceptionSource
    .example
        $serr|Dotils.FindExceptionSource
        $serr|Dotils.FindExceptionSource -Kind GetError
        $serr|Dotils.FindExceptionSource -Kind InnerDebug
        $serr|Dotils.FindExceptionSource -Kind Minimal
        $serr|Dotils.FindExceptionSource -Kind Overrides
    .example
        # related:
        PS> $ErrorView | Dotils.JoinString.As Enum
        # outputs:
            [ 'CategoryView' | 'ConciseView' | 'DetailedView' | 'NormalView' ]
    .LINK
        System.Management.Automation.ErrorRecord
    #>
    [CmdletBinding()]
    param(
        # Expects an ErrorRecord or child exception
        [Alias(
            # 'Exception'
            # not sure if this will unroll the outer exception losing a layer
            # using:    ValueFromPipelineByPropertyName
        )]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $InputObject,
        # [Exception]

        [Alias('Find.As')]
        [ValidateSet(
            # 'Default',
            'GetError',
            'InnerDebug',
            'Minimal',
            'Overrides'
        )]
        [string[]]$Kind,

        [hashtable]$Options = @{}
    )
    process {
        $t = $InputObject
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            # Separator = ', '
            IncludeFirstChild = $false
        }
        $UniNull        = '[␀]' # "[`u{2400}]'"
        $UniDotDotDot   = '…' # "`u{2026}"
        $Config | Json -depth 4 -Compress
                | Join-String -f "Dotils.FindExceptionSource: Options = {0}"
                | Write-Verbose

        $InputObject    | Format-ShortTypeName | Join-String -f '$InputObject is {0}'
                        | write-debug

        if($Config.IncludeFirstChild) { throw 'NYI: IncludeFirstChild'}
        if($null -eq $t) {
            write-error 'InputObject Was Null'
            return
        }

        $meta = [ordered]@{}


        $meta.SelectStar =
            $t | Select-Object '*'

        $meta.PSObjectPropertiesAll =
            $t.PsObject.Properties

        $meta.IterProps =
            $t | io
        $meta.IterPropsNoBlank =
            $t | io -SkipMost -SkipNull -SkipBlank

        if( -not $t.Exception -or -not $Config.IncludeFirstChild ) {
            $meta.FirstChild = $UniNull
        }
        if($Config.IncludeFirstChild) {
            $meta.FirstChild =
                Dotils.FindExceptionSource -input $t.Exception
        }


        # tempTest





        # copy direct properties

        $meta.CategoryInfo =
            ($t)?.CategoryInfo ?? $UniNull

        $meta.ErrorCategoryInfo =
            ($t)?.ErrorCategoryInfo ?? $UniNull

        $meta.ErrorDetails =
            ($t)?.ErrorDetails      ?? $UniNull

        # Obj.Exception.ErrorRecord
        $meta.ErrorRecord =
            ($t)?.ErrorRecord      ?? $UniNull

        # first child
        $meta.Exception =
            ($t)?.Exception         ?? $UniNull
        $Meta.ExceptionTypeName =
            $t | Format-ShortSciTypeName

        $meta.FullyQualifiedErrorId =
            ($t)?.FullyQualifiedErrorId ?? $UniNull

        $meta.InvocationInfo =
            ($t)?.InvocationInfo         ?? $UniNull
        $meta.PipelineIterationInfo =
            ($t)?.PipelineIterationInfo         ?? $UniNull

        $meta.PSMessageDetails =
            ($t)?.PSMessageDetails ?? $UniNull

        $meta.ScriptStackTrace =
            ($t)?.ScriptStackTrace ?? $UniNull

        $meta.TargetObject =
            ($t)?.TargetObject     ?? $UniNull



        switch ($Kind) {
            'GetError'  {
                $meta.FromGetError =
                    ($t | Get-Error) ?? $UniNull
                continue
            }
            'Minimal' {
                $meta.remove('IterProps')
                $meta.remove('IterPropsNoBlank')
                # $meta.remove('ScriptStackTrace')
                return [pscustomobject]$meta
                continue
            }
            'Overrides' {
                # maybe more, see: full list
                #   $serr | fime * -Force
                $meta._serializedErrorCategoryMessageOverride =
                    ($t)?._serializedErrorCategoryMessageOverride     ?? $UniNull
                $meta._reasonOverride =
                    ($t)?._reasonOverride     ?? $UniNull
                return [pscustomobject]$meta
                continue
            }
            'InnerDebug' {

                <#
                Original was
                    $serr | Format-ShortTypeName
                    $serr.Exception | Format-ShortTypeName

                    $z.Inner_Exception =

                    if($serr.Exception.ErrorRecord) {
                        $serr.Exception.ErrorRecord | Format-ShortTypeName  } else { "<null>" }

                    $meta.Inner_Exception =
                        if($serr.Exception.ErrorRecord) {
                            $serr.Exception.ErrorRecord | Format-ShortTypeName
                        } ?? $StrNull
                    $meta.Inner_ExceptionTypeName =
                        $what ?
                        ($what | Format-ShortTypeName) :
                        'null'
                #>
                $meta.Inner_Json =
                    $t  | ConvertTo-Json -Depth 1

                $meta.Inner_PSCO =
                    $t  | ConvertTo-Json -Depth 1
                        | ConvertFrom-Json

                $what = $t
                $meta.Inner_TypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.Exception
                $meta.Inner_ExceptionTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.ErrorRecord
                $meta.Inner_ErrorRecordTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.Exception.ErrorRecord
                $meta.Inner_Exception_ErrorRecordTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull
                continue
            }
            # 'Default' {
            #     #
            #     continue
            # }
            default { throw "UnhandledJoinKind: $Kind" }
        }
        return [pscustomobject]$meta
    }
    end {}
}

function Dotils.JoinString.As {
    <#
    .SYNOPSIS
    .example
        PS> $ErrorView | Dotils.JoinString.As Enum

        # outputs:
            [ 'CategoryView' | 'ConciseView' | 'DetailedView' | 'NormalView' ]
    .example
        PS> impo importexcel -PassThru
                | Join.As -Kind 'Module'

        # outputs:
            importexcel = 7.8.4
    .example
        PS> Get-PSCallStack
            | Join.As PSCallStack.Location
            | Join.UL

        # Output

            - mainEntryPoint.ps1: line 70
            - bdg_lib.psm1: line 8
            - mainEntryPoint.ps1: line 321
            - <No file>


    #>
    [CmdletBinding()]
    param(
        [Alias('Join.As')]
        [ValidateSet(
            'Enum',
            'Module',
            'InternalScriptExtent'
        )]
        [string]$Kind,

        [hashtable]$Options = @{}
    )
    process {
        $InputObject = $_
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            Separator = ', '
        }
        switch ($Kind) {
            'Enum' {
                $InputObject
                | Find-Member | % name | Sort-Object -Unique
                | ? { $_ -ne 'value__' }
                | Join-String -sep ' | ' -op ' [ ' -os ' ] ' -SingleQuote
                break
            }
            'InternalScriptExtent' {
                # 'c:\foo\bar.ps1:134'
                # in vs code / grep format
                $InputObject.Position
                | Join-String {
                    $_.File, $_.StartLineNumber -join ':'
                }
                break
            }
            'PSCallStack.Locations' {
                # ex: usage: Get-PSCallStack | %{ $_ | Join-String { $_.Location } } | Join.UL
                $InputObject | % {
                    $_ | Join-String { $_.Location }
                }
                break
            }
            'Module' {
                $InputObject
                | Join-String { $_.Name, $_.Version -join ' = ' } -sep $Config.Separator
                break

            }
            default { throw "UnhandledJoinKind: $Kind" }
        }
    }
}

function Dotils.Join.Brace {
    <#
    .synopsis
    .example
        Get-Variable | % gettype | Format-ShortTypeName | Sort-Object -Unique | Dotils.Join.Brace
    .example
        'a', 'b', 'c' | Dotils.Join.Brace
        'a', 'b', 'c' | Join-String -DoubleQuote |  Dotils.Join.Brace
        'a', 'b', 'c' | Join-String -DoubleQuote -sep ' | ' |  Dotils.Join.Brace

        [a][b][c]
        ["a""b""c"]
        ["a" | "b" | "c"]
    #>
    # [CmdletBinding()]
    # [Alias('Join.Brace.Dotils')]
    param(
        [ValidateSet('Padding', 'Wrap', 'Thin')]
        [string]$OutputFormat = 'Padding'
    )
    $Config = @{
        Prefix = ' '
        Suffix = ' '
    }

    switch($WhichMode) {
        'Wrap' {
            # $Config = @{
            #     Prefix = ' '
            #     Suffix = ' '
            # }
            $Input | Join-String -op $Config.Prefix -os $Config.Suffix
        }
        'Padding' {
            $Input | Join-String -f "[ {0} ]" #-op ' ' -os ' '
        }
        'Thin' {
            $Input | Join-String -f "[{0}]" -op '' -os ''
        }
        default {
            $Input | Join-String -f "[{0}]" -op ' ' -os ' '
        }
    }
}
function Join.Pad.Item {
    <#
    .SYNOPSIS
       Proc Item,  like -join except the output is an array, not one string.

    #>
    switch($OutputMode){
        default {
            # surround with single space
            $Input -split '\r?\n' | %{  " <{0}> " -f $_ }
        }
    }
    return
    # or basic
    #$Input -split '\r?\n' | %{  "<{0}>" -f $_ }
        # | Join-String -f "`n<{0}>"
}

function Dotils.Start-WatchForFilesModified {
    <#
    .synopsis
        Invoke a scriptblock if files are newer than the last invoke
    .NOTES
        better solution: use events for file watcher
    .EXAMPLE
        Pwsh>
        $error.Clear(); impo Dotils -Force -Verbose -DisableNameChecking

        $sb = { 'hi world' }
        Dotils.Start-WatchForFilesModified -RootWatchDirectory 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs' -FileKinds .psm1 -Verbose -infa Continue -SleepMilliseconds 150 -ScriptBlock $sb
    .EXAMPLE
        Dotils.Start-WatchForFilesModified -RootWatchDirectory H:\data\2023\pwsh\PsModules.dev\GitLogger\docs -FileKinds .ps1 -ScriptBlock {
            $bps_Splat = @{
                BaseDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
                InputObject   = 'MyRepos2.ps.*'
            }
            bps.🐍 @bps_Splat
        } -SleepMilliseconds 1400
    .EXAMPLE
        impo Dotils -Force -Verbose -DisableNameChecking
        $dotils_watch = @{
            FileKinds          = '.psm1', '.ps1', '.psd1'
            InformationAction  = 'Continue'
            RootWatchDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
            SleepMilliseconds  = 450
            Verbose            = $true
            ScriptBlock        = {
                $bps_Splat = @{
                    BaseDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
                    InputObject   = 'MyRepos2.ps.*'
                }
                bps.🐍 @bps_Splat
            }
        }

        Dotils.Start-WatchForFilesModified @dotils_watch

    #>
    [CmdletBinding()]
    param(
        [Alias('Path')]
        [Parameter(Mandatory, Position=0)]
        [ArgumentCompletions(
            'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs')]
        [string]$RootWatchDirectory,

        # not currently a regex
        [ArgumentCompletions(
            '.ps1', '.psm1', '.psd1', '.md', '.js', '.html', '.css', '.ts', '.svg', '.md'
        )]
        [Parameter(Mandatory, Position=1)]
        [string[]]$FileKinds,


        # Action to run
        [Alias('Expression', 'Action')]
        [ArgumentCompletions(
            '{
        $bps_Splat = @{
            BaseDirectory = ''H:\data\2023\pwsh\PsModules.dev\GitLogger\docs''
            InputObject   = ''MyRepos2.ps.*''
        }
        bps.🐍 @bps_Splat
    }'
    #-replace '\^M', "`n")
        )]
        [Parameter(Mandatory, Position=2)]
        [ScriptBlock]$ScriptBlock,

        # sleep milliseconds cycle until ctrl+c
        [Alias('SleepAsMs')]
        [int]$SleepMilliseconds  = 1400,

        [switch]$NotSilent
    )
    $script:__dotilsStartWatch ??= @{ LastInvokeTime = 0 }
    $state = $script:__dotilsStartWatch

    function __handleIteration {
        [cmdletBinding()]
        $now = [Datetime]::Now
        # $state = $script:__dotilsStartWatch

        $files = gci -LiteralPath $RootWatchDirectory -Recurse -file
            | CountOf -CountLabel 'Files'
            | ?{ $_.Extension.ToLower() -In @( $FileKinds ) }
            | CountOf -CountLabel 'FilesOfType'
            # | ?{ $_.LastWriteTime -gt $state.LastInvokeTime }
            | ?{ $_.LastWriteTime -gt $script:__dotilsStartWatch.LastInvokeTime }
            | sort-object LastWriteTIme -Descending
            | CountOf -CountLabel 'ModifiedFiles'
        $files
            | Write-Information

        if($files.count -gt 0) {
            # wait-debugger
        } else {
            'none found: ' | write-debug # write-host -back darkyellow
            return
        }
        if($Files.count -gt 0){
            $State.lastInvokeTime | Join-String -op 'most recently: ' | write-verbose -verbose

            $files
                | Join-String -sep ', ' -single -p Name -op 'Found New files! (newest): '
                | Write-Information
            'invoke-scriptblock' | write-verbose
            & $ScriptBlock
            $script:__dotilsStartWatch.LastInvokeTime = $now
            $null = 0
        } else {
            'still cached' | write-debug
        }


    }
    try {
        while($true) {
            sleep -Milliseconds $SleepMilliseconds
            'tick' |write-debug
            . __handleIteration
        }
    } catch {
        write-warning 'Dotils.Start-WatchForFilesModified: => catch'
        write-verbose 'Dotils.Start-WatchForFilesModified: => catch'
        throw
    } finally {
        write-verbose 'Dotils.Start-WatchForFilesModified: => finally'
    } clean {
        write-verbose 'Dotils.Start-WatchForFilesModified: => clean'
    }

    'Dotils.Start-WatchForFilesModified: => exit'
        | write-host -fore green

}
function Dotils.Format-TaggedUnionString {
    <#
    .synopsis
        renders a tagged union of the distinct set of [Type]-Name's of the values
    .EXAMPLE
        Pwsh>

        Get-Variable | % Gettype | % Name
            | Dotils.Format-TaggedUnionString

        [ "LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable" ]
    .EXAMPLE
        gci .
            | % GetType
            | Dotils.Format-TaggedUnionString

        [ "System.IO.DirectoryInfo" | "System.IO.FileInfo" ]

    .example
        $sample = Get-Variable | % gettype | % Name | sort -Unique -Descending
        $sample | dotils.Format-TaggedUnionString -OutputFormat Default |

        # output: ["LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable"]
    .example
        $sample | Dotils.Format-TaggedUnionString -AsTypeName
            ["LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable"]

        $sample | Dotils.Format-TaggedUnionString
            ["string" | "string" | "string" | "string" | "string" | "string"]

        .EXAMPLE
        [System.ConsoleColor]
            | fime | % Name | Dotils.Format-TaggedUnionString

        #  ["Black" | "Blue" | "Cyan" | "DarkBlue" | "DarkCyan" | "DarkGray" | "DarkGreen" | "DarkMagenta" | "DarkRed" | "DarkYellow" | "Gray" | "Green" | "Magenta" | "Red" | "value__" | "White" | "Yellow"]
    #>
    param(
        [switch]$AsTypeName,

        [ArgumentCompletions(
            'AsTypeName', 'AsTypeName2',
            'AsTypeName.Name.NinTils',
            'Default'
        )]
        [string]$OutputFormat
    )

    $choices = $Input | Sort-Object -Unique
    if($AsTypeName) { $OutputFormat = 'AsTypeName' }

    # throw 'cat attack this was maybe broken'
    write-warning 'cat attack this was maybe broken'

    switch($OutputFormat) {
        'AsTypeName.Name.NinTils' {
            $choices
                | Format-ShortTypeName
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        'AsTypeName.Name' {
            $choices
                | % GetType | % Name
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        'AsTypeName' {
            $choices
                | % GetType
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        default  {
            $choices
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding
        }

    }
        # $sample | Dotils.Format-TaggedUnionString | Dotils.Join.Brace
}
# $sample | Dotils.Format-TaggedUnionString | Dotils.Join.Brace

function Dotils.Html.Table.FromHashtable {
    <#
    .SYNOPSIS
        generate HTML table based on a hashtable
    .EXAMPLE

    $selectEnvVarKeys = 'TMP', 'TEMP', 'windir'
    $selectKeysOnlyHash = @{}
    gci env: | ?{
        $_.Name -in @($selectEnvVarKeys)
    } | %{ $selectKeysOnlyHash[$_.Name] = $_.Value}

    Dotils.Html.Table.FromHashtable -InputHashtable $selectKeysOnlyHash
#output
    <table>
    <tr><td>TMP</td><td>C:\Users\nin\AppData\Local\Temp</td></tr>
    <tr><td>TEMP</td><td>C:\Users\nin\AppData\Local\Temp</td></tr>
    <tr><td>windir</td><td>C:\WINDOWS</td></tr>
    </table>

    #>
    [OutputType('System.String')]
    [Alias('Marking.Html.Table.From.Hashtable')]
    param(
        [Parameter(Mandatory)]
        [hashtable]$InputHashtable #= @{}
    )
    $renderBody = $InputHashTable.GetEnumerator() | % {
        '<tr><td>{0}</td><td>{1}</td></tr>' -f @(
            $_.Key ?? '?'
            $_.Value ?? '?'
        )
    } | Join-String -sep "`n"
    $renderFinal = @(
        '<table>'
        $renderBody
        '</table>'
    ) | Join-String -sep "`n"
    return $renderFinal
    # '<table>'
    # '</table>'

}
function Dotils.Out.XL-AllPropOfBoth {
    [CmdletBinding()]
    param(
        $Obj1, $Obj2,
        [switch]$PassThru

    )

    if($null -eq $Obj1 -or $Null -eq $Obj2) { throw "OneOrBothAreNull!" }

    $tInfo1 = $Obj1.GetType()
    $tInfo2 = $Obj2.GetType()
    $info = [ordered]@{
        LeftName  = $Obj1.username ?? '<no name>'
        RightName = $Obj2.username ?? '<no name>'
        LeftType  = $tInfo1.FullName
        RightType = $tInfo2.FullName
    }

    $info
        | ConvertTo-Json -depth 3
        | Join-String -op 'User compare: ' | write-verbose -verbose

    $propNames = @(
        $Obj1.PsoObject.Properties.Name
        $Obj2.PsoObject.Properties.Name
    ) | Sort-Object -Unique

    $mergedKind1 = [ordered]@{}
    $mergedKind2 = [ordered]@{}
    $mergedKind1.Source = 'Left'
    $mergedKind2.Source = 'Right'

    $mergedKind1.Type = ($tInfo1)?.GetType().Name ?? "`u{2400}"
    $mergedKind2.Type = ($tInfo2)?.GetType().Name ?? "`u{2400}"
    $mergedKind1.FullTypeName = ($tInfo1)?.GetType().FullName ?? "`u{2400}"
    $mergedKind2.FullTypeName = ($tInfo2)?.GetType().FullName ?? "`u{2400}"

    foreach($name in $PropNames) {
        $mergedKind1.$Name = $Obj1.$Name
        $mergedKind2.$Name = $Obj2.$Name

        $mergedKind1.$Name ??= "`u{2400}"
        $mergedKind2.$Name ??= "`u{2400}"
    }
    Wait-Debugger

    $query = @(
        [pscustomobject]$mergedKind1
        [pscustomobject]$mergedKind2
    )
    if($PassThru) { return $query }
    $query | to-xl
}
# $JCUpdateCsvRecord.psobject.Properties.name

function Dotils.SamBuild {
    [CmdletBinding()]
    param(
        [switch]$Fast,
        [string]$LogPath = 'g:\temp\last_sam.log'
    )
    write-warning 'maybe not fuly done'
    Get-Location
        | Join-String -f 'SamBuild::FromDir: "{0}"'
        | write-host -back 'red'

    [Collections.Generic.List[Object]]$SamArgs = @(
        '--debug'
        'build', '--use-container',
        '--parallel'
        if(-not $Fast) {
            '--cached',
            '--skip-pull-image'
        }
    )
    (get-date).ToString('o')
        | Join-String -op 'SamBuild.ps1: ' -os "`n`n"
        | Add-Content $LogPath -PassThru

    $SamArgs
        | Join-String -sep ' ' -op 'Invoke Sam: => '
    & 'sam' @SamArgs
        | Add-Content $LogPath -PassThru

    $LogPath
        | Join-String -f 'SamBuild::Wrote Log: <file:///"{0}">'
        | Write-host -back 'darkyellow'
}


function Dotils.Measure-CommandDuration {
    <#
    .synopsis
        sugar to run a command and time it. low precision. just a ballpark
    #>
    [Alias(
        'TimeOfSb',
        'Dotils.Measure-CommandDuration',
        'Dotils.Measure.CommandDuration',
        'Dotils.Measure-CommandDuration',
        'DeltaOfSBScriptBlock',
        'DeltaOfScriptBlock',
        'DeltaOfSB',
        'dotils.DeltaOfSB',
        'debug.Measure.ScriptDuration'
    )][CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [object]$Expression )

    if (-not $Expression -is 'scriptblock') {
        throw "Unhandled type: [$($Expression.GetType().Name)] !"
    }

    class DeltaOfRecord {
        [datetime]$Start
        [datetime]$End
        [object]$Result

        # [Alias('NotFailed')]
        [bool]$Success
        hidden [object]$OriginalScriptBlock

        DeltaOfRecord ( [object]$InputScriptBlock ) {
            $this.OriginalScriptBlock = $InputScriptBlock # maybe as text to be safer? smaller?
            $this.Start = [Datetime]::Now
            try {
                $this.Result = & $InputScriptBlock
                $this.Success = $true
            }
            catch {
                $this.Success = $false
                $_ | Join-String -f 'Something Failed 😢: {0}'
                | Write-Error
            }
            $this.End = [Datetime]::Now
        }
        [timespan] Delta() { return $this.End - $this.Start }

    }
    $start = Get-Date
    $result = & $Expression
    $end = Get-Date
    [pscustomobject]@{
        Result     = $result
        Start      = $start
        End        = $end
        Duration   = ($end - $start)
        DurationMs = ($end - $start).TotalMilliseconds
    }
}

function Dotils.Tablify.ErrorRecord {
    [CmdletBinding()]
    param (
        [Alias('ErrorRecord', 'Exception')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object]$InputObject,

        [Alias('List')]
        [switch]$ListPropertySets,
        [switch]$Fancy,

        [ArgumentCompletions(
            'ErrorRecord_AutoFindMember',
            'ErrorRecord_Basic',
            'ErrorRecord_FindMember_Basic',
            'ErrorRecord_FindMember_Static',
            'ErrorRecord_GetProperty_Auto',
            'ErrorRecord_GetProperty_Basic',
            'ErrorRecord_GetProperty_Static',
            'ExceptionRecord_Basic'
        )]
        [string[]]$PropertySets
    )
    begin {
        if ($PSBoundParameters.ContainsKey('PropertySets')) { throw "NYI: Property sets are wip: $PSCommandPath" }
        $script:__dPropList ??= @{} # redundanly calculated
        $__propList = $script:__dPropList
        $__propList.ErrorRecord_AutoFindMember = @(
            [System.Management.Automation.ErrorRecord]
            | fime -Force
            | % Name | sort -Unique
        )
        $__propList.ErrorRecord_GetProperty_Auto = @() # todo: Psobject.Properties.Name nyi  'nyi, need to move to process or end'

        <#
        ErrorRecord_AutoFindMember
            type | Find-Member
        ErrorRecord_FindMember
            manual names from
        ErrorRecord_BasicFindMember
            type | Find-Member  - someProps
        ErrorRecord_AutoFindProperty
            psobject.properties
        ErrorRecord_BasicAutoFindProperty
            psobject.properties - someProps

        #>
        $__propList.ErrorRecord_FindMember_Static = @( # from: [ErrorRecord] | Find-Member -force
            '_activityOverride'
            '_category'
            '_categoryInfo'
            '_error'
            '_errorId'
            '_invocationInfo'
            '_isSerialized'
            '_pipelineIterationInfo'
            '_reasonOverride'
            '_scriptStackTrace'
            '_serializedErrorCategoryMessageOverride'
            '_serializedFullyQualifiedErrorId'
            '_serializeExtendedInfo'
            '_target'
            '_targetNameOverride'
            '_targetTypeOverride'
            '.ctor'
            '<>c'
            '<ErrorDetails>k__BackingField'
            '<PreserveInvocationInfoOnce>k__BackingField'
            '<ToPSObjectForRemoting>b__12_0'
            '<ToPSObjectForRemoting>b__12_1'
            '<ToPSObjectForRemoting>b__12_10'
            '<ToPSObjectForRemoting>b__12_11'
            '<ToPSObjectForRemoting>b__12_14'
            '<ToPSObjectForRemoting>b__12_15'
            '<ToPSObjectForRemoting>b__12_2'
            '<ToPSObjectForRemoting>b__12_3'
            '<ToPSObjectForRemoting>b__12_4'
            '<ToPSObjectForRemoting>b__12_5'
            '<ToPSObjectForRemoting>b__12_6'
            '<ToPSObjectForRemoting>b__12_7'
            '<ToPSObjectForRemoting>b__12_8'
            '<ToPSObjectForRemoting>b__12_9'
            'CategoryInfo'
            'ConstructFromPSObjectForRemoting'
            'ErrorDetails'
            'Exception'
            'FromPSObjectForRemoting'
            'FullyQualifiedErrorId'
            'GetInvocationTypeName'
            'GetNoteValue'
            'GetObjectData'
            'InvocationInfo'
            'IsSerialized'
            'LockScriptStackTrace'
            'NotNull'
            'PipelineIterationInfo'
            'PopulateProperties'
            'PreserveInvocationInfoOnce'
            'ScriptStackTrace'
            'SerializeExtendedInfo'
            'SetInvocationInfo'
            'SetTargetObject'
            'TargetObject'
            'ToPSObjectForRemoting'
            'ToString'
            'WrapException'
        )
        $innerConfig = @{
            IgnoreDunder = $true
            IgnoreUnder  = $true
        }
        $__propList.ErrorRecord_FindMember_Basic = @( # dynamic, yet simplified list
            @(
                $propList.ErrorRecord_AutoFindMember
                $propList.ErrorRecord_FindMember_Static
            )
            | Sort-Object -Unique
            | ? {
                if ($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
                if ($_ -match [regex]::escape('k__BackingField')) { return $false }
                if ($_ -match [regex]::escape('^.ctor')) { return $false }
                if ( $innerConfig.IgnoreUnder -and $_ -match '^_{1}') { return $false }
                if ( $innerConfig.IgnoreDunder -and $_ -match '^_{2}') { return $false }
                $true
            }
        )
        $__propList.ErrorRecord_GetProperty_Static = @(
            '_activityOverride'
            '_category'
            '_categoryInfo'
            '_error'
            '_errorId'
            '_invocationInfo'
            '_isSerialized'
            '_pipelineIterationInfo'
            '_reasonOverride'
            '_scriptStackTrace'
            '_serializedErrorCategoryMessageOverride'
            '_serializedFullyQualifiedErrorId'
            '_serializeExtendedInfo'
            '_target'
            '_targetNameOverride'
            '_targetTypeOverride'
            '<ErrorDetails>k__BackingField'
            '<PreserveInvocationInfoOnce>k__BackingField'
            'CategoryInfo'
            'ErrorDetails'
            'Exception'
            'FullyQualifiedErrorId'
            'InvocationInfo'
            'IsSerialized'
            'PipelineIterationInfo'
            'PreserveInvocationInfoOnce'
            'PSMessageDetails'
            'ScriptStackTrace'
            'SerializeExtendedInfo'
            'TargetObject'
        )
        $__propList.ErrorRecord_GetProperty_Basic = @(
            @(
                $__propList.ErrorRecord_GetProperty_Static
                $__propList.ErrorRecord_GetProperty_Auto
            ) | ? {
                if ($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
                if ($_ -match [regex]::escape('k__BackingField')) { return $false }
                if ($_ -match [regex]::escape('^.ctor')) { return $false }
                if ( $innerConfig.IgnoreUnder -and $_ -match '^_{1}') { return $false }
                if ( $innerConfig.IgnoreDunder -and $_ -match '^_{2}') { return $false }
                $true
            }
        )

    }
    process {
        $meta = [ordered]@{}
        $IncludeFancy = $true
        $target = $InputObject
        $metaFancy = @{}

        switch ($target) {
            { $_ -is 'System.Management.Automation.ErrorRecord' } {
                Write-Verbose 'found type: [ErrorRecord]'
                $captureProps = $_ | Select-Object *

                $curPropSet = @{}
                if ($IncludeFancy) {
                    foreach ($Prop in $__propList.ErrorRecord_Basic) {
                        $curPropSet[$Prop] = ($Target.$Prop)?.ToString() ?? '<␀>'
                    }
                    $metaFancy['ErrorRecord_Basic'] = $curPropSet ?? @{}
                }
                break
            }
            { $_ -is 'System.Exception' } {
                Write-Verbose 'found type: [Exception]'
                $captureProps = $_ | select *

                $curPropSet = @{}
                if ($IncludeFancy) {
                    foreach ($Prop in $__propList.ExceptionRecord_Basic) {
                        $curPropSet[$Prop] = ($Target.$Prop)?.ToString() ?? '<␀>'
                    }
                    $metaFancy['Exception_Basic'] = $curPropSet ?? @{}
                }
                break
            }
            default {
                throw "UnhandledTypeException: $($Switch.GetType().Name)"
            }
        }
        if (-not $Fancy) {
            return $CaptureProps | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
                PSShortType    = $Target | Format-ShortTypeName
                OriginalObject = $Target
            }
            # $CaptureProps
        }
        return [pscustomobject]$metaFancy | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
            PSShortType    = $Target | Format-ShortTypeName | Join-String -op 'Fancy.'
            OriginalObject = $Target
        }
        # meta not actually used
    }
    end {
        if ($ListPropertySets) {
            return ([pscustomobject]$__propList)
        }
    }
}
function Dotils.Render.ErrorVars {
    # auto hide values that are empty  or null, from the above functions
    [CmdletBinding()]
    param()
    process {
        $t = $_
        if ( -not $t -is 'System.Management.Automation.ErrorRecord' ) {
            $t | Format-ShortTypeName
            | Join-String -f 'Expected [ErrorRecord], got {0}'
            | Write-Verbose
        }
        $target = $InputObject
        [ordered]@{
            Type = $InputObject | Format-ShortTypeName
        }
        # throw 'nyi, wip'
    }
    # a bunch of mmaybe
}
function Dotils.Render.ErrorRecord.Fancy {
    param(
        [ArgumentCompletions(
            'OneLine',
            'UL', 'List'
        )]
        [string]$OutputFormat
    )
    process {
        $InputObject = $_

        switch ($OutputFormat) {
            'OneLine' {
                $InputObject
                | Dotils.Tablify.ErrorRecord -ListPropertySets
                | % { $_.PsObject.Properties }
                | % {
                    $_.name
                    $_.Value | Join-String -sep ', ' -op "`n$($_.name)"
                }
                | Join-String -sep ( Hr 1 )
                break
            }
            { $_ -in @('UL', 'List') } {
                $InputObject
                | Dotils.Tablify.ErrorRecord -ListPropertySets
                | % { $_.PsObject.Properties }
                | % {
                    $_.name
                    $_.Value | join.UL
                }
                | Join-String -sep ( Hr 1)

                break
            }
            default {
                throw "Unhandled OutputFormat $OutputFormat"

            }
        }
    }
}

function Dotils.Join.CmdPrefix {
    process {
        $_ | % {
            label '>' -Separator ' ' $_ | Write.Info
        }
    }
}

function Dotils.LogObject {
    # short minimal log
    [OutputType('String')]
    [Alias('㏒')]
    [CmdletBinding()]
    param(
        [Alias('NoCompress')][switch]$Expand,
        [switch]$PassThru
    )
    $jsonSplat = @{
        Compress = -not $Expand
        Depth = 2
    }
    $data = $Input
    $renderJson =
        $data | ConvertTo-Json @jsonSplat

    $actualWidth = $host.ui.RawUI.WindowSize.Width
    $finalRender = @(
        '  ㏒'
        "${fg:gray60}${bg:gray15}"
        $renderJson | shortStr -Length ($actualWidth - 8 )
        $PSStyle.Reset
    ) -join ''

    if($Passthru) {
        return $finalRender # currently still truncates value, returns as string
    }
    return $finalRender
        | Write-Information -infa 'continue'
}
function Dotils.Build.Find-ModuleMembers {
    # find items to export
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [switch]$Recurse
    )

    write-warning 'slightly broke in last  patch'
    $splat = @{
        InputObject = $InputObject
        Recurse = $Recurse
    }
    $outPassThru = @{ OutputFormat = 'PassThru' }
    $outResult   = @{ OutputFormat =   'Result' }

    $astVar      = @{ AstKind = 'Variable' }
    $astFunc  = @{ AstKind = 'Function' }

    # dotils.search-Pipescript.Nin @splat -AstKind Function -OutputFormat Result | % Name | sort-object -Unique |
    # Same thing currently:
    $meta = [ordered]@{}
    # throw "${PSCommandPath}: NYI, lost pipe reference"

    $Meta.Function = @(
        dotils.search-Pipescript.Nin @splat @astFunc @outResult
            | % Name | Sort-Object -Unique
    )

    $Meta.Variable = @(
        dotils.search-Pipescript.Nin @splat @astVar @outPassThru
            | % Result  |  % tokens | % Text
    )
    $Meta.Variable_Content = @(
        dotils.search-Pipescript.Nin @splat @astVar @outPassThru
            | % Result  |  % tokens | % Content
    )
    return $meta

    if($false -and 'old') {

        $Meta.Function = @(
            dotils.search-Pipescript.Nin @splat -AstKind Function -OutputFormat Result
                | % Name | Sort-Object -Unique
        )

        $Meta.Variable = @(
            dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
                | % Result  |  % tokens | % Text
        )
        $Meta.Variable_Content = @(
            dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
                | % Result  |  % tokens | % Content
        )
    }
    # dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
}

Function Dotils.Search-Pipescript.Nin {
    <#
    .synopsis
    sugar to pass fileinfo or filepath or contents, as the source to search
    .example
        dotils.search-Pipescript.Nin -Path (gcl|gi) -AstKind Function
            | % Result | % Name | sort -Unique
    .example
        $src = Get-Item 'foo\bar.psm1'
        Dotils.Search-Pipescript.Nin -Path $src -AstKind 'Function'
    .example
        Dotils.Search-Pipescript.Nin -Path 'C:\foo\utils.psm1' -AstKind 'Function'
        Dotils.Search-Pipescript.Nin -Path 'C:\foo\utils.psm1' -AstKind 'Variable'
    .example
        $content = gc -raw -Path 'C:\foo\utils.psm1'
        $sb = [scriptblock]::Create( $content )
        Dotils.Search-Pipescript.Nin -Path C:\foo\utils.psm1' -AstKind 'Variable'
    .example
        # Several output shapes defined as sugar

            $splatSearch = @{
                InputObject = $srcWrapModule
                AstKind = 'Function'
            }

            dotils.search-Pipescript.Nin @splatSearch -OutputFormat PassThru
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Result
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Tokens
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Value
    #>
    param(
        # Make paramset that allow paging or not, but positional is automatic
        [Parameter(Mandatory, Position=0)]
        [Alias('LiteralPath', 'Path')]
        [object]$InputObject,

        # This is AstKind, not defined inline, yet
        [Parameter(Mandatory, Position=1)]
        [ArgumentCompletions(
            # "'Function'", "'Variable'"
            'Function', 'Variable', 'wipAutoGenKinds'
        )][string]$AstKind,


        # this is not an AST type, it's properties on the value returned
        # by find-pipescript, drilling down
        [Parameter(Mandatory, Position=2)]
        [Alias('As')][ValidateSet(
            'PassThru', 'Result', 'Tokens', 'Value',
            'VariablePath'
        )][string]$OutputFormat = 'PassThru',

        [switch]$Recurse
    )
    function __getSBContent {
        # file info, filepath, script block, or string?
        param(
            [Parameter(Mandatory)]
            [object]$InputObject
        )
        if( Test-Path $InputObject ) { # already is path/fileinfo
            $content = gc -raw -Path (gi -ea 'stop' $InputObject)
            return $content
        }
        if($InputObject -is 'ScriptBlock') {
            $content = $InputObject
            return $content
        }
        if($InputObject -is 'String') {
            $content = [ScriptBlock]::Create( $InputObject )
            return $content
        }
        throw "Unknown coercion, UnhandledType: $($InputObject.GetType().Name)"
    }
    $content = __getSBContent -InputObject $InputObject
    $sb = [scriptblock]::Create( $content )

    # dotils.search-Pipescript.Nin -Path $srcWrapModule -AstKind Variable | % Result | % Tokens | ft


    $query = Pipescript\Search-PipeScript -InputObject $sb -AstType $AstKind -recurse $Recurse
    switch($OutputFormat) {
        'PassThru' {
            $query
            write-verbose "Using: $AstKind"
            break
        }
        'Result' {
            $query | % Result
            write-verbose "Using: $AstKind | % Result"
            break
        }
        'VariablePath' {
            $query | % Result | % VariablePath
            write-verbose "Using: $AstKind | % Result.VariablePath"
            break
        }
        'Value' {
            $query | % Result | % Value
            Write-warning 'type "value" doesn''t work? or wrong type?'
            write-verbose "Using: $AstKind | % Result.Value"
            break
        }
        'Tokens' {
            $query | % Result | % Tokens
            write-verbose "Using: $AstKind | % Result.Tokens"
            break
        }
        default { throw "UnhandledOutputFormat: '$OutputFormat'" }
    }

    # if($InputObject -is 'ScriptBlock') {
    #     $content = $InputObject
    # }
    # if( -not (Test-Path $InputObject) -and $InputObject -is 'String' ) {
    #     $content = $InputObject # if not a path, assume  content
    # }
    # $sb = [scriptblock]::Create( $content )
}




function Dotils.CompareCompletions {
    <#
    .synopsis
        capture completion texts, easier
    .description
        two ways to invoke for simplicity. if you pass a 2nd string it will take that as the position.
    .EXAMPLE
        two ways to invoke for simplicity. if you pass a 2nd string it will take that as the position.

        > CompareCompletions -Prompt '[int3' -verb -ColumnOrSubstring '[in'
        > CompareCompletions -Prompt '[int3' -verb -ColumnOrSubstring 3

    #>
    [Alias('CompareCompletions')]
    [CmdletBinding()]
    param(
        # text to be completed
        [string]$Prompt,

        # offset or the substring, it will take that as the position.
        [object]$ColumnOrSubstring


        # [int]$Limit = 5
        # [switch]$Fancy,

        # [switch]$PassThru = $true
    )
    # if($ColumnOrSubstring -is 'int') {}

    # if ($false) {
    #     $Column = $ColumnOrSubString -as 'int'
    #     $Column ??= $ColumnOrSubstring.Length
    #     $Column ??= $Prompt.Length
    # # $Column++ # because it's 1-based
    #     if ($Column -le 0 -or $column -gt $Prompt.Length ) {
    #         Write-Error "out of bounds: $Column from $ColumnOrSubString, actual = $($Prompt.Length)"
    #         return
    #     }
    # }
    # $Column = [Math]::Clamp( ($Column ?? 0), 1, $Prompt.Length)
    if ($ColumnOrSubstring -is 'int') { $Col = $ColumnOrSubstring -as 'int' }
    else { $Col = $ColumnOrSubstring.Length }

    # else { $Col = $ColumnOrSubstring.Length - 1 }
    $Col | Join-String -f 'Column: {0}' | Write-Verbose

    # $query = TabExpansion2_Original -inputScript $Prompt -cursorColumn $Column
    $query = TabExpansion2 -inputScript $Prompt -cursorColumn $Col
    $results = $query.CompletionMatches

    if ($true -or $PassThru) { return $results }

    # $results | Sort CompletionText | select -First $Limit -Last $Limit
    # $results | Sort ListItemText | select -First $Limit -Last $Limit
    # $results | Sort ResultType | select -First $Limit -Last $Limit
    # $results | sort Tooltip | select -First $Limit -Last $Limit
}



function Dotils.Testing.Validate.ExportedCmds {
    <#
    .EXAMPLE
        [string[]]$cmdList = @(
            $mod.ExportedAliases.Keys
            $mod.ExportedFunctions.Keys
        ) | Sort-Object -Unique
    #>
    [Alias('MonkeyBusiness.Vaidate.ExportedCommands')]
    [CmdletBinding()]
    param(
        [string[]]$CommandName,
        [string]$ModuleName

        # # import before testing names
        # [Alias('ForceImport')]
        # [switch]$PreImport
    )
    if (-not $PSBoundParameters.ContainsKey('CommandName')) {
        # from
        if ($ModuleName -ne 'dotils') {
            Import-Module -Force -Name $ModuleName -ea 'stop' -PassThru | Write.Info
        }
        $mod = Get-Module -Name $ModuleName

        [string[]]$cmdList =
        @(  $Mod.ExportedCommands.keys
            $Mod.ExportedAliases.keys )
        | Sort-Object -Unique
    }
    else {
        [string[]]$cmdList =
        $CommandName
        | Sort-Object -Unique
    }

    $cmdList | join.UL | Join-String -op 'Commands found: ' | Write-Verbose

    $stats = $cmdList | % {
        # label '>' -Separator ' ' $_ | Write.Info
        [pscustomobject]@{
            Name      = $_
            IsAFunc   = ( $is_func = Test-Path function:\$_ )
            IsAnAlias = ( $is_alias = Test-Path alias:\$_    )
            IsBad     = $is_func -and $is_alias
        }
    }
    $stats
}


function Dotils.GetCommand {
    [Alias(
        # 'Dotility.GetCommand',
    )]
    param()

    @(
        Get-Command -Module 'dotils'
    ) | Sort-Object -Unique

    if ($true) { return } # skip older code
    $gcmSplat = @{
        ErrorAction = 'continue'
        Name        = @(
            # 'Dotility.CompareCompletions'
            # 'Dotility.GetCommand'
            'Dotils.CompareCompletions'
            'Dotils.GetCommand'
            'Dotils.Render.ErrorRecord.Fancy'
            'Dotils.Render.ErrorRecord'
            'Dotils.Tablify.ErrorRecord'
            'Dotils.Measure-CommandDuration'
            # was:
            # 'Dotils.Measure-CommandDuration'
            # 'Dotils.Tabilify.ErrorRecord'
            # 'Dotils.Render.ErrorVars'
            # 'Dotils.Render.ErrorRecord.Fancy'
        )
    }
}
function Dotils.Out.Grid2 {
    <#
    .SYNOPSIS
        from jaykul thread: <https://discord.com/channels/180528040881815552/446156137952182282/1112247580848554015>
    .NOTES
        from jaykul thread:
            start:  <https://discord.com/channels/180528040881815552/446156137952182282/1112247580848554015>
            end:    <https://discord.com/channels/180528040881815552/446156137952182282/1112151356644524123>
    #>
    $csv = "${fg:gray40}${bg:gray30}.${fg:clear}${bg:clear}"
    $flags = [System.Reflection.BindingFlags]60 # is: Instance, Static, Public, NonPublic
    filter tosser {
        # jaykul cli test
        $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue($MyInvocation) -join $Csv
    }
    filter generator {
        param(
            [Parameter(ValueFromPipeline)][int]$Inputobject ) 1..$Inputobject
    }
    filter outer { <# jaykul cli test #>   1..($args[0]) }
    filter inner { <# jaykul cli test #> $_ | generator | tosser }


    $input | tosser
    if ($false) {
        Hr -fg Magenta

        filter tosser { $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue($MyInvocation) -join $Csv }
        filter t2 {
            $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue( $MyInvocation ) -join '_'
        }
        0..3 | tosser | grid
        Hr
        0..3 | t2 | grid

        Hr -fg green
    }
}
function Dotils.Select-ExcludeBlankProperty {
    <#
    .SYNOPSIS
        take an object, automatically hide any empty properties
    .EXAMPLE
        Pwsh> Get-Process | Select-ExcludeBlankProperty | fl -force *
    .EXAMPLE
        Pwsh> Get-Command  mkdir
            | Select-Object *
            | Select-ExcludeBlankProperty
            | fl * -Force
    .DESCRIPTION
        'Dotils.Select-ExcludeBlankProperty' => { 'Select-ExcludeBlankProperty' }
        propertes are removed using Select-Object -Exclude so their type changes.

        or rather it's PSTypeName changes from:
            [Diagnostics.Process] , to
            [Selected.Diagnostics.Process]
    .NOTES
        future:
            - [ ] can I preserve the original type, and apply 'hidden' attribute on those members?
        new excludes
            - [ ] ExcludeLongProperties (or truncate them visually. maybe dynamic view)

    #>
    [Alias('Select-ExcludeBlankProperty')]
    [CmdletBinding()]
    [OutputType(
        'System.Object',
        'Selected.System.Diagnostics.Process',
        'System.Management.Automation.PSCustomObject'
    )]
    param(
        [ValidateNotNullOrEmpty()]
        [Alias('Obj')][Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        $Props = $InputObject.PSObject.Properties
        [Collections.Generic.List[object]]$exclusionList = @()

        $Props
            | ForEach-Object {
                if ( [string]::IsNullOrWhiteSpace( $_.Value ) ) {
                    $exclusionList.Add( $_.Name )
                }
            }

        $exclusionList
            | Join-String -sep ', ' -SingleQuote -op '$exclusionList: '
            | Write-Verbose

        return $InputObject | Select-Object -ExcludeProperty $exclusionList
    }
}

function Dotils.Log.Format-WriteHorizontalRule {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}
function Dotils.Log.WriteFromPipe {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}
function Dotils.Log.WriteNowHeader {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}

function Dotils.Select-NotBlankKeys {
    <#
    .SYNOPSIS
        enumerate hashtable, drop any keys that have blankable vlaues
    #>
    [Alias(
        'Dotils.DropBlankKeys',
        'Dotils.Where-NotBlankKeys'
    )]
    [CmdletBinding()]
    [OutputType('Hashtable')]
    param(
        [Parameter(mandatory)]
        [hashtable]$InputHashtable,

        [switch]$NoMutate
    )
    throw 'untested from other module'
    $strUserKeyId = '[User={2} <CoId={0}, EmpId={1}>]' -f @(
        $finalObj.companyId
        $finalObj.employeeIdentifier
        $finalObj.userName
    )
    if ($NoMutate) {
        $targetHash = [hashtable]::new( $InputHashtable )
    }
    else {
        $targetHash = $InputHashtable
    }

    $msg =
        $targetHash.GetEnumerator()
            | Where-Object { [string]::IsNullOrEmpty( $_.Value ) }
            | ForEach-Object Name | Sort-Object -Unique
            | Join-String -sep ', ' -op "dropped blank fields on ${strUserKeyId}: "

    @{ Message = $msg }
        | bdgLog -Category DataIntegrity -Message $msg -PassThru
        | Write-Verbose

    $toDrop =
        $targetHash.GetEnumerator()
            | Where-Object { [string]::IsNullOrEmpty( $_.Value ) }
            | ForEach-Object Name

    foreach ($k in $toDrop) {
        $targetHash.Remove( $k )
    }
    return $targetHash

}


function Dotils.Invoke-TipOfTheDay  {
    <#
    .SYNOPSIS
        grab a random example command from the docs of a random command, or maybe from json files, or, KnowMoreTangent. there even is an official PwshRandomPatchNotes command
    .DESCRIPTION
        grab a random example command from the docs of a random command, or maybe from json files, or, KnowMoreTangent. there even is an official PwshRandomPatchNotes command
    #>
    [CmdletBinding()]
    param(
        # sources
        [Parameter()]
        [string[]]$ModuleName
    )

    $ModuleName ??=
        'Pansies', 'ImportExcel', 'Dotils', 'ExcelAnt', 'Ugit', 'Ninmonkey.Console', 'PsReadLine', 'TypeWriter', 'ClassExplorer' | Sort-Object -Unique

    $ModuleName
        | Join-String -op 'ModuleSources: ' -sep ', ' -SingleQuote | write-verbose

    # '<Insert Tip from Get-Help Examples>'
    # Get-Command  mkdir
    #         | Select-Object *

    # Get-Command  mkdir
    #         | Select-Object *

    function _randomCommand {

    }

    $innerLimit = 0
    while( $true ) {
        if( ($innerLimit++) -gt 15) {
            throw "Did not find a valid example in $InnerLimit Iterations!"
        }
        "Iter = $innerLimit, continue until a non blank example is found" | write-verbose
        $getModuleSplat = @{
            Name = $ModuleName
        }

        function _rand.Module {
            param()
            Get-Module @getModuleSplat
                | Get-Random -count 1
        }
        function _rand.Command {
            param(
                [string]$whichModule
            )
            $cmds =
                Get-Command -Module $whichModule
                    | Sort-Object -unique

            $cmds
                | Get-Random -Count 1
        }
        function _rand.Example {
            param()

            [object[]]$examples =
                (gcm $whichCmd | Get-Help -Examples).examples.example
            $whichExample =
                gcm $whichCmd
                | Get-Help -Examples
                | % Examples
                | Get-Random -Count 1
        }

        $whichModule =
            _rand.Module

        $whichCmd =
           _rand.Command

        $whichModule
            | Join-String -op 'RandomModule: ' | write-verbose

        $whichCmd
            | Join-String -op 'WhichCmd: ' | write-verbose



# $q.examples.example



        if($whichExample) {
            $whichExample
            break
        }
    }

    if(-not $whichExample -or $whichExample.Count -eq 0){
        $errMsg = "ShouldNeverReachException: Failed on: Gcm $whichCmd | Get-Help -Example; Args = $WhichModule, $WhichCmd."
        throw $ErrMsg # [Exception]::new($errMsg)
    }

    # gcm -m ImportExcel

}
function Dotils.SelectBy-Module {
    <#
    .SYNOPSIS
        Filters (command|modules) by inclusion or exclusion lists

    .EXAMPLE
        Pwsh> Get-Command  mkdir
            | Select-Object *
            | Select-ByModule
            | fl * -Force
    .DESCRIPTION
        'Dotils.Select-ByModule' => { 'Select-ByModule' }
        propertes are removed using Select-Object -Exclude so their type changes.

        or rather it's PSTypeName changes from:
            [Diagnostics.Process] , to
            [Selected.Diagnostics.Process]
    .NOTES
        future:
            - [ ] get the [command.Source] or [PSModuleInfo.Name]
        new excludes
            - [ ] ExcludeLongProperties (or truncate them visually. maybe dynamic view)

    #>
    [Alias(
        # Dotils.Select-ByModule
        # 'Dotils.Filter-ByModule',
        # 'SelectBy-ByModule',
        'Dotils.FilterBy-Module',
        'SelectBy-Module'
    )]
    [CmdletBinding()]
    [OutputType(
        'System.Object'
    )]
    param(
        # Module, commands, or script blocks
        [ValidateNotNullOrEmpty()]
        [Alias('Obj')][Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # optional filter for [CommandTypes] enum that GCM uses
        [ValidateNotNullOrEmpty()]
        [Alias('TypeIs')][Parameter()]
        [Management.Automation.CommandTypes[]]$CommandType,

        # optional filter for [CommandTypes] enum that GCM uses
        [ValidateNotNullOrEmpty()]
        [Alias('GroupName')][Parameter()]
        [ValidateSet('Mine', 'Debug', 'Fav', 'BuiltIn')]
        [string[]]$GroupKind,

        # names to keep, inverse of exclusions
        # [ArgumentCompletions()] # todo: nin [ArgumentCompletion__ModuleNames]
        # AutoCompleter on fuzzy loader uses write progress ?
        # [ArgumentCompletions()] # todo: nin [ArgumentCompletion__CommandNames]
        [ArgumentCompletions(
            'AngleParse',
            'AppBackgroundTask',
            'Appx',
            'AssignedAccess',
            # 'AWS.Tools.ApplicationInsights', # 'AWS.Tools.AutoScaling', # 'AWS.Tools.ChimeSDKIdentity', # 'AWS.Tools.CloudFormation', # 'AWS.Tools.CloudWatch', # 'AWS.Tools.CloudWatchLogs', # 'AWS.Tools.CodeDeploy', # 'AWS.Tools.Common', # 'AWS.Tools.ConnectParticipant', # 'AWS.Tools.DynamoDBv2', # 'AWS.Tools.EC2', # 'AWS.Tools.ECR', # 'AWS.Tools.ECS', # 'AWS.Tools.ElasticLoadBalancing', # 'AWS.Tools.ElasticLoadBalancingV2', # 'AWS.Tools.IdentityManagement', # 'AWS.Tools.IdentityStore', # 'AWS.Tools.Installer', # 'AWS.Tools.KeyManagementService', # 'AWS.Tools.Lambda', # 'AWS.Tools.Organizations', # 'AWS.Tools.Polly', # 'AWS.Tools.RDS', # 'AWS.Tools.ResourceGroups', # 'AWS.Tools.Route53', # 'AWS.Tools.S3', # 'AWS.Tools.SecretsManager', # 'AWS.Tools.SecurityToken', # 'AWS.Tools.SimpleEmail', # 'AWS.Tools.SimpleEmailV2', # 'AWS.Tools.SimpleNotificationService', # 'AWS.Tools.SimpleSystemsManagement', # 'AWS.Tools.SQS', # 'AWS.Tools.SSOAdmin', # 'AWSLambdaPSCore',
            'Az',
            'Az.*',
            'BasicModuleTemplate',
            'bdg_lib',
            'Benchpress',
            'BitLocker',
            'BitsTransfer',
            'BranchCache',
            'BuildHelpers',
            'BurntToast',
            'CimCmdlets',
            'ClassExplorer',
            'CommunityAnalyzerRules',
            'CompletionPredictor',
            'ConfigDefenderPerformance',
            'Configuration',
            'DataMashup',
            'Defender',
            'DeliveryOptimization',
            'Dev.Nin',
            'DirectAccessClientComponents',
            'Dism',
            'DnsClient',
            'Dotils',
            'DSCResourceModule',
            'EditorServicesCommandSuite',
            'Eventful',
            'EventTracingManagement',
            'examplemodule',
            'ExcelAnt',
            'EZOut',
            'EzTheme',
            'GitLogger',
            'GitLogger.ChartJs.Utils',
            'GitLoggerAwsUtils',
            'HelpOut',
            'HgsClient',
            'HgsDiagnostics',
            'Hyper-V',
            'ImpliedReflection',
            'ImportExcel',
            'Indented.ChocoPackage',
            'Indented.ScriptAnalyzerRules',
            'Indented.StubCommand',
            'IntelNetCmdlets',
            'International',
            'InvokeBuild',
            'Irregular',
            'Jake.Pwsh.AwsCli',
            'Jaykul👨Grouping',

            # 'Kds',
            # 'LanguagePackManagement',
            # 'LAPS',
            'Metadata',
            'Microsoft.PowerShell.Archive', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.Crescendo', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.LocalAccounts', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.TextUtility', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.WhatsNew', 'Microsoft.WSMan.Management',
            'mintils',
            'MMAgent',
            'ModuleBuild',
            'ModuleBuilder',
            'ModuleFast',
            'NameIT',
            'Nancy',
            'NetAdapter',
            'NetConnection',
            'NetEventPacketCapture',
            'NetLbfo',
            'NetNat',
            'NetQos',
            'NetSecurity',
            'NetSwitchTeam',
            'NetTCPIP',
            'NetworkConnectivityStatus',
            'NetworkSwitchManager',
            'NetworkTransition',
            'Ninmonkey.Console',
            'Ninmonkey.Factorio',
            'PackageManagement',
            'Pansies',
            'PcsvDevice',
            'Pester',
            'PipeScript',
            'Pipeworks',
            'PKI',
            'platyPS',
            'PnpDevice',
            'Portal.Powershell',
            'posh-git',
            'Posh-SSH',
            'powershell-yaml',
            'Powershell.Cv',
            'Powershell.Jake',
            'PowerShellAI',
            'PowerShellGet',
            'PowerShellHumanizer',
            'PowerShellNotebook',
            'PowerShellPivot',
            'PrintManagement',
            'ProcessMitigations',
            'Profiler',
            'Provisioning',
            'PSAdvantage',
            'PSCompatibilityCollector',
            'PSDevOps',
            'PSDiagnostics',
            'PSEventViewer',
            'PSMetrics',
            'PSparklines',
            'PSParseHTML',
            'PSProfiler',
            'PSReadLine',
            'PSScriptAnalyzer',
            'PSScriptTools',
            'PSStringTemplate',
            'PSTree',
            'PSWriteColor',
            'PSWriteExcel',
            'PSWriteHTML',
            'PSWriteline',
            'PSWriteOffice',
            'PSWriteWord',
            'Pwsh.PackageTemplate',
            'Revoke-Obfuscation',
            'samplerule',
            'SampleRuleWithVersion',
            'ScheduledTasks',
            'ScriptBlockDisassembler',
            'ScriptCop',
            'SecretManagement.LastPass',
            'SecureBoot',
            'ShowPSAst',
            'ShowUI',
            'SmbShare',
            'SmbWitness',
            'Splatter',
            'SQLPS',
            'SqlServer',
            'StartLayout',
            'Storage',
            'SysInternals',
            'Template.Autocomplete',
            'Terminal-Icons',
            'TerminalBlocks',
            'TestBadModule',
            'TestGoodModule',
            'Theme.PowerShell',
            'Theme.PSReadLine',
            'Theme.PSStyle',
            'ThreadJob',
            'TLS',
            'TroubleshootingPack',
            'TrustedPlatformModule',
            'UEV',
            'ugit',
            'VpnClient',
            'Wdac',
            'Whea',
            'WindowsDeveloperLicense',
            'WindowsErrorReporting',
            'WindowsSearch',
            'WindowsUpdate',
            'WindowsUpdateProvider'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('ModuleName')][Parameter()]
        [string[]]$IncludeName,

        # regex patterns to exclude
        [ValidateNotNullOrEmpty()]
        [ArgumentCompletions(
            '^Az\.'
        )]
        [Alias('ModulePattern')][Parameter()]
        [string[]]$ExcludePattern
    )
    begin {
        Write-Warning @'
left off: filter funcs or commands or aliases or moduleinfo, based on the source


to ask: how to compare vs 0 to many enum values
    this broke

    #impo Dotils -Force
        gcm -Name  'gci'  -CommandType Function
        | countOf
        | SelectBy-Module -CommandType Function, All
        | CountOf
'@

    }
    process {
        if($GroupKind) { throw 'middle of wip' }

@'

GroupKindCompleter filters Get-Module, checking for any shared root directories
        H:\data\2023\pwsh
        H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils
        C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Modules\ugit\0.4
        C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell
        C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\mintils
'@ | Out-null


        if ($IncludeName) { throw 'in middle of wip' }
        if ($ExcludePattern) { throw 'in middle of wip' }

        $item = $InputObject
        $InputObject
        | ? { # filter: Keep unless filters are specified
            $curItem = $_
            $shouldKeep = $true
            [Management.Automation.CommandTypes]$commandType? = $curItem.CommandType

            if (-not $PSBoundParameters.ContainsKey('CommandType')) { return $true }
            if (-not $CommandType?) { return $true }

            foreach ($incName in @($IncludeName)) {
                if ($incName -eq $commandType?) { $shouldKeep = $true ; break; }
            }

            return $false
        }
        # $Props = $InputObject.PSObject.Properties
        # [Collections.Generic.List[object]]$exclusionList = @()

        # $Props | ForEach-Object {
        #     if( [string]::IsNullOrWhiteSpace( $_.Value ) ) {
        #         $exclusionList.Add( $_.Name )
        #     }
        # }

        # $exclusionList
        #     | Join-string -sep ', ' -SingleQuote -op '$exclusionList: '
        #     | write-verbose

        # return $InputObject | Select-Object -excludeProperty $exclusionList
    }
}

function Dotils.Find-MyWorkspace {
    <#
    .SYNOPSIS
        quick search of my recent files by category, similar to
            ext:code-workspace dm:last2weeks
    .NOTES
        super not performant, but more than fast enough
    .EXAMPLE
        Find-MyWorkspace
    .EXAMPLE
        Find-MyWorkspace -ChangedWithin 1year
    #>
    [Alias(
        'Find-MyWorkspace'
    )]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            '20minutes', '8hours', '1week', '3weeks', '1year')
        ][string]$ChangedWithin = '2weeks',

        [Parameter( #not using a param set temporarily since it'll rewrite sometime
            # Mandatory, ParameterSetName='QueryGroupName')]
        )][ValidateSet('All', 'Fast', 'PwshOnly', '2022')]
        [string]$QueryGroupName,

        [string[]]$BasePath
    )

    $QueryKindList = @{
        All = @(
            'H:\data\2023'
            'H:\data\2022'
            'H:\data\2023\pwsh\PsModules\KnowMoreTangent'
            'H:\data\client_bdg'
            'C:\Users\cppmo_000\SkyDrive\Documents\2022'
        )
        Fast = @(
            'H:\data\2023'
        )
        PwshOnly = @(
            'H:\data\2023\pwsh'
            'H:\data\client_bdg' # for now
            'C:\Users\cppmo_000\SkyDrive\Documents\2022\Pwsh' # for now

        )
        2022 = @(
            'H:\data\2022'
            'C:\Users\cppmo_000\SkyDrive\Documents\2022'
        )
    }

    if($PSBoundParameters.ContainsKey('QueryGroupName') -and $PSBoundParameters.ContainsKey('BasePath')) {
        throw "CannotCombineparameters: QueryGroupName with BasePath"
    }
    $DefaultGroup = 'Fast'

    if($QueryKindList -and $QueryKindList.$QueryGroupName ) {
        $explicitPaths = $QueryKindList.$QueryGroupName
    } else {
        if($BasePath) {
            $explicitPaths = @($BasePath)
        } else {
            $explicitPaths = @($QueryKindList.$DefaultGroup)
        }
    }

    # -not $PSBoundParameters.ContainsKey('QueryGroupName') {

    # if (-not $BasePath.count -gt 0) {
    #         # $BasePath = $QueryKindList[$QueryGroupName]

    #     $ExplicitPaths = @(
    #         $QueryGroupName.$DefaultGroup
    #     )
    # } else {
    #     $ExplicitPaths = $BasePath
    # }
    # if($QueryGroupName) {
    #     $explicitPaths = @( $QueryKindList.$QueryGroupName )
    # }

    # Join-String 'searching {0}' $
    $explicitPaths
        | Join-String -sep ', ' -SingleQuote -op '$ExplicitPaths: '
        | write-information -infa 'Continue'

        [Collections.Generic.List[Object]]$Files = @(
            foreach ($item in $ExplicitPaths) {
                'write-progress: InvokeFd: changed?: {0}, dir?: {1}' -f @(
                    $ChangedWithin
                    $item
                )
                | Write-Information -infa 'Continue'


                & 'fd' @(
                    '--absolute-path',
                    '--extension', 'code-workspace',
                    '--type', 'file'
                    if($ChangedWithin) {
                        '--changed-within', $ChangedWithin
                    }

                    '--base-directory',
                    (gi -ea 'stop' $item)
                )
                | Get-item
            }
        )

        $files = $Files
            | Sort-Object FullName -Unique
            | Sort-Object LastWriteTime -Descending

        $global:MyWorkspaceQuery = $files
        # $global:MyWorkspaceQuery
        '$MyWorkspaceQuery saved' | New-Text -fg gray30 -bg gray50 | Join-String | Write-Information -infa 'continue'
        return $files
            | CountOf -CountLabel "ChangedWithin: $( $ChangedWithin )"

}


function Dotils.InferCommandCategory {
    # process commands, returns group names
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        write-warning '80% wip'
    }
    process {

        # foreach($curCmd in $InputObject) {
        $InputObject | %{

            $curCmd = gcm -ea 'continue' $_
            $baseName = $curCmd.Path | Get-Item | % BaseName

            # could return multiple
            [object[]]$kinds = switch -regex ($CurCmd.Base) {
                '^([i]?py[w]?(thon)?.*)' {
                    'Python'
                }
                '^pwsh|powershell' { 'PowerShell', 'cli' }
                '^tsc?$' { 'TypeScript', 'Javascript', 'BuildTool', 'cli' }
                '^code(-insiders)?' { 'VsCode' }
                '^sql(.*)cmd'  { 'SQL', 'BuildTool'}
                {
                    $CurCmd.Path -match ('^' + [regex]::Escape('C:\Windows\system32'))
                } { 'Windows' }
                default {
                    $_  | Join-String -f 'Dotils.Find-MyNativeCommandKind: UnhandledKind: {0}'
                        | Write-error
                        return 'None'
                }
            }
            $kinds.count
                | Join-String -f 'Kinds: {0}'
                | Join-String -f "${fg:green}{0}${fg:clear}" -op $PSStyle.Reset
                | Join-String -os $($Kinds -join ', ' )
                | write-information -infa 'continue'

            $kinds.count
                | Join-String -op 'Kinds: {0}'
                | Join-String -f "{0} = $($kinds -join ', ' )"
                | Write-Verbose

            $kinds -join ', '
                | write-information

            $kinds.count
                | Join-String -op 'Kinds: {0}'
                | Join-String -f "{0} = $($kinds -join ', ' )"
                | Write-Verbose

            $kinds -join ', '
                | Write-verbose

            return ,$kinds
        }
    }
}

function Dotils.Find-MyNativeCommandCategory {
    # generates metadata on command, including GroupKind categories
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {

    }
    process {
        $addMemberSplat = @{
            PassThru    = $true
            Force       = $true
            ErrorAction = 'ignore'

        }

        foreach ($Item in $InputObject) {
            $Item | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
                PSShortType = $Item | Format-ShortTypeName
                Group     = $Item | Dotils.InferCommandCategory
            }

        }
    }

}

function Dotils.Find-MyNativeCommand {
    write-warning
    @'
FrontEnd for finding executables by categories

reuse pattern from:
    Find-MyWorkspace
'@
    $binList = Get-Command -CommandType Application -ea 'continue'
    throw 'this will either be gcm but nicer, or it will also filter to the important modules'


}
function Dotils.Get-NativeCommand {
    <#
    .SYNOPSIS
        Returns only Applications, or executables, excluding all commands and aliases
    #>
    # [Alias('')]
    param(
        [Alias('Path', 'LiteralPath')]
        # future: customAttributes: Find-MyNativeCommand
        [ArgumentCompletions(
            '7z', '7za', '7zfm', '7zg', 'cargo-clippy', 'com.docker.cli', 'dmypy', 'dnSpy-x86', 'dnSpy', 'docker-compose-v1', 'docker-compose', 'docker-credential-desktop', 'docker-credential-ecr-login', 'docker-credential-wincred', 'docker-index', 'docker', 'dotnet-counters', 'dotnet-coverage', 'dotnet-dump', 'dotnet-gcdump', 'dotnet-ildasm', 'dotnet-lambda', 'dotnet-monitor', 'dotnet-repl', 'dotnet-stack', 'dotnet-suggest', 'dotnet-symbol', 'dotnet-trace', 'dotnet-try', 'dotnet', 'fd', 'Fiddler', 'http-server', 'http', 'httpie', 'https', 'ILSpy', 'ipython', 'ipython3', 'jupyter-run', 'jupyter', 'mpyq', 'mypy', 'powershell', 'putty', 'puttygen', 'pwsh', 'py', 'pygmentize', 'python3', 'pyw', 'Robocopy', 'Winobj', 'wt', 'xcopy'
        )]
        [Parameter(Mandatory)][string]$Name
    )
    $found = Get-Command -ea 'stop' -CommandType Application $Name | Select-Object -First 1
    if (-not $Found) { throw "Did not match command: $Name" }
    return $Found
}

function Dotils.Render.ColorName {
    <#
    .SYNOPSIS
        emits items one at a time, so you don't have to otherwise split them after, like a join-string
    .example
        '232311', 'blue', 'darkred'
            | Dotils.Render.ColorName -Foreground -Text '_'
            | Join-String

        # out: ---
        # which is:

        ␛[38;2;35;35;17m_␛[39m␛[38;2;0;0;255m_␛[39m␛[38;2;128;0;0m_␛[39m

    .example
        PS> fmt.Render.ColorName -Text 'darkyellow' -bg | fcc

            ␛[38;2;128;128;0mdarkyellow␛[39m
    .example

        PS> 'red', '#fefe9e' | fmt.Render.ColorName -fg | Join.UL
            - red
            - #fefe9e
    .example
        PS> 'red', '#fefe9e' | fmt.Render.ColorName -fg | Join-String | fcc

            ␛[48;2;255;0;0mred␛[49m␛[48;2;254;254;158m#fefe9e␛[49m
    .example
        PS> Get-Gradient -StartColor 'gray10' -end 'gray50' -Width 10
            | Dotils.Render.ColorName -bg '.'
            | Join-String

        PS> Get-Gradient -StartColor 'gray10' -end 'gray50' -Width 10
            | Dotils.Render.ColorName -bg '.'
            | Join.UL
    #>
    [OutputType('System.String', 'PoshCode.Pansies.Text')]
    [CmdletBinding()]
    # [NinDependsInfo( # this does not yet exist
    #     Modules='Pansies', Powershell='7.0.0', NativeCommands=$false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('InputObject', 'Name')][object]$ColorName,

        # text to render, if not color name
        [Alias('Content')]
        [Parameter(Position=0)]
        [Alias('Object')][string]$Text,


        [Alias('Bg')][switch]$Background,
        [Alias('Fg')][switch]$Foreground,

        # Instead, return the raw [PoshCode.Pansies.Text]
        [switch]$PassThru
    )
    begin {
        if(-not $PSCmdlet.MyInvocation.ExpectingInput) {
            $target = $ColorName
        }
    }
    process {
        if($PSCmdlet.MyInvocation.ExpectingInput) {
            $target = $ColorName
        }
        if(-not $Foreground -and  -not $Background) {
            throw 'Missing BG, FG, must be one or the other' }
        $splat = @{}
        if($Background) { $splat.bg = $ColorName }
        if($Foreground) { $splat.fg = $ColorName }
        if($ColorName) { $splat.Object = $ColorName }
        if($PSBoundParameters.ContainsKey('Text')) {
            $splat.Object = $Text
        }

        if($PassThru){
            return Pansies\New-Text @splat
        }
        return (Pansies\New-Text @splat).ToString()

    }
    end {
    }
}
function Dotils.Format.Color {
    <#
    .SYNOPSIS
        format without forcing joining strings, just emit the values one at a time
    .EXAMPLE
        '#fefff1', 'red' | Fmt.Color ByProp X11ColorName | Join-String

        # out: IvoryRed
        # ansi:[48;2;254;255;241mIvory[49m[48;2;255;0;0mRed[49m
    #>
    param(
        [AllowEmptyString()]
        [Alias('Text', 'InputObject')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputText,

        # exactly how to render the color?
        [Parameter(position=0)]
        [ValidateSet(
            'Implicit',
            'ByProp')]
        [string]$FormatMode,

        [Parameter(position=1)]
        [ValidateSet(
            'RGB', 'BGR', 'ConsoleColor',
            'XTerm256Index', 'X11ColorName',
            'Mode',
            'R', 'G', 'B'
            # 'Ordinals'
        )]
        [string]$PropName
    )
    begin {
        $str = @{
            PansiesResetAll = "${fg:clear}${bg:clear}"
            PSStyleReset = $PSStyle.Reset
        }
    }
    process {
        if( [string]::IsNullOrWhiteSpace($InputText)) {
            return [string]::Empty
        }



        $jStr_splat = @{
            Separator = ''
            # Object = $InputText
        }
        switch($FormatMode) {
            'Implicit' {
                $InputText | Dotils.Render.ColorName -bg
            }
            'ByProp' {
                # [PoshCode.Pansies.Text]
                $textObj = $InputText | Dotils.Render.ColorName -bg -PassThru
                # $textObj.BackgroundColor is [PoshCode.Pansies.RgbColor]
                $value? = ($textObj.BackgroundColor)?.$PropName ?? '-'
                $InputText | Dotils.Render.ColorName -bg -Text $Value?
            }
            default {
                throw "UnhandledFormatMode: $FormatMode"
            }
        }
        # $InputText | Join-String

    }
}
# function Dotils.Is.Type {
function Dotils.Debug.GetTypeInfo { # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }
    <#
    .SYNOPSIS
        Quick Summary of types of an object. terribly written, testing breaking rules with  code that is still valid (ie: correct)
    .DESCRIPTION
        I give you many possible formatters, some use raw text parsing
        some return actual [type] info objects

    - future:
        - [ ] if a type does not resolve using 'as type', then attempt
            a 'find-type -fullName *name*' query to resolve it
    #>
    [Alias('Dotils.Is.Type', 'Is.Type', '.IsType', 'IsType')]
    param(
        [ValidateSet(
            'Type',
            'ElemType',
            'FullName',
            'Name',
            'PSTypesRaw',
            'PSTypes',
            'PSTypesInfo',
            'PSTypesString',
            'PassThru'
            )]
        [Parameter(Position=0)][string]$Style = 'PassThru',

        [Parameter(ValueFromPipeline)][object]$InputObject,

        [switch]$PassThru
    )
    write-warning 'finish writing dotils.GetTypeInfo, including formatter that auto renders string else type info instance'
    $t = $InputObject
    if( $t -is 'type' ) {
        $tInfo = $t.GetType()
    } else {
        $tInfo = $t
    }

    $info = [pscustomobject]@{
        PSTypeName = 'Dotils.Debug.GetTypeInfo'

        Type =
            $t.
                GetType() ??
                '<missing>'

        ElemType =
            @( $t )[0].
                GetType() ??
                '<missing>'

        FullName =
            $t.
                GetType().FullName ??
                '<missing>'
        Name =
            $t.
                GetType().Name ??
                '<missing>'
        PSTypesRaw =
            $tInfo.
                PSTypeNames ??
                '<missing>'
        PSTypes = # alias to TypesInfo
            $tinfo.PSTypeNames ?? '' | %{  $_ -as 'type' }

        PSTypesInfo =
            $tinfo.PSTypeNames ?? '' | %{  $_ -as 'type' }

        PSTypesString =
            $tinfo.
                PSTypeNames
                    | Sort-Object -Unique
                    | %{ $_ -replace '\System\.', '' }
                    | Ninmonkey.Console\Format-WrapText -Style Bracket
    }
    if($PassThru -or $Style -eq 'PassThru') {
        return $info
    }

    return $info.$Style
}

function Dotils.DB.toDataTable {
<#
.synopsis
	output DataTable from an object
.example
	Get-Service | Dotils.DB.toDataTable
.example
	Get-Date    | Dotils.DB.toDataTable
.notes
    started: <https://gist.github.com/indented-automation/2dd91c24c2ef0a985ae9454bd713f7da#file-license-txt-L2>
#>
    [Alias('Dotils.ConvertTo-DataTable')]
    [OutputType('System.Data.DataTable')]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Object]$InputObject
    )

    begin {
        $dataTable = [System.Data.DataTable]::new()
    }

    process {
        if ($dataTable.Columns.Count -eq 0) {
            $null = foreach ($property in $InputObject.PSObject.Properties) {
                $dataTable.Columns.Add($property.Name, $property.TypeNameOfValue)
            }
        }

        $values = foreach ($property in $InputObject.PSObject.Properties) {
            ,$property.Value
        }
        $null = $dataTable.Rows.Add($values)
    }

    end {
        ,$dataTable
    }
}

# 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
# 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }
function Dotils.Format-ShortString.Basic {    <#
    .synopsis
        Shorten string in a way that never errors. Keep it simple
    .NOTES
        future:
            ability to write num chars relative root.
    .link
        Dotils\Dotils.Format-ShortString.Basic
    .link
        Dotils\Dotils.Format-ShortString

    #>
    [Alias('Dotils.ShortString.Basic')]
    [OutputType('String')]
    [CmdletBinding()]
    param(
        # Text to format
        [Alias('Text', 'String')]
        [Parameter(Mandatory, Position=0,
            ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$InputObject,

        # future: validatescript to assert length?
        [int]$maxLength = 80
    )
    if($null -eq $InputObject) { return '␀' }

    $Len = $InputObject.Length
    $maxOffset = $input.Length - 1 # not used

    <#
    must be updated if position is every relative a non-zero
        because it's not an offset, it's a length
    #>
    [int]$selectedCount = [math]::Clamp(
        <# value #> $maxLength,
        <# min #> 0, <# max #> $Len )

    return $InputObject.SubString(0, $selectedCount )

}
function Dotils.Format-ShortString {    <#
    .synopsis
        Shorten string in a way that never errors. Keep it simple
    .NOTES
        future:
            ability to write num chars relative root.
    .link
        Dotils\Dotils.Format-ShortString.Basic
    .link
        Dotils\Dotils.Format-ShortString

    #>
    [Alias('Dotils.ShortString')]
    [OutputType('String')]
    [CmdletBinding()]
    param(
        # Text to format
        [Alias('Text', 'String')]
        [Parameter(Mandatory, Position=0,
            ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$InputObject,

        # future: validatescript to assert length?
        # Null or empty
        [Alias('Number', 'Count', 'MaxChars', 'MaxCols')]
        [Parameter()]
        [int]$maxLength = 80,
        # can be negative
        [Alias('StartAt')]
        [Parameter()]
        [int]$startPosition = 0 #
    )
    if($null -eq $InputObject) { return '␀' }

    $Len = $InputObject.Length
    if($StartPosition -lt 0) {
        # $MaxOffset = $Input.Length
        $startAt = $input.Length + $startPosition # which is -1
    } else {
        $startAt = $startPosition
    }

    $maxOffset =
        $input.Length - 1
    $maxCount =
        $maxOffset - $startAt

    # $possibleMaxSubstrLength =
    #     $maxOffset


    <#
    must be updated if position is every relative a non-zero
        because it's not an offset, it's a length
    #>
    [int]$selectedCount = [math]::Clamp(
        <# value #> $maxLength,
        <# min #> 0, <# max #> $Len )

    [ordered]@{
        StartAt = $startAt
        StartPosition = $startPosition
        InputLen = $input.Length
        MaxOffset = $MaxOffset
        SelectedCount = $SelectedCount
        MaxCount = $MaxCount
    }
        | Json | Join-String -op 'Format-ShortString: '
        | write-debug

    return $InputObject.SubString(0, $selectedCount )

}
# 'Dotils.Object.QuickInfo' = { 'QuickInfo' }
function Dotils.Object.QuickInfo {
    [Alias('QuickInfo')]
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position=0)]
        $InputObject
    )
    $InputObject.psobject.properties | %{
        #$_.Name, $_.TypeNameOfvalue | Join-String -sep ' ⇒ '
        try {
        # or I could grab the type from Value
            $tinfoFromStr = $_.TypeNameOfValue -as 'type'
        } catch {
            $tinfoFromStr = $_.TypeNameOfValue
        }
        [pscustomobject][ordered]@{
            Name = $_.Name

            Kind =
                ($tinfoFromStr | Format-ShortSciTypeName) ??
                    $tinfoFromStr

            tInfoInstance = # auto hide
                $tInfoFromStr
      }
    }
}

function Dotils.Type.Info {
    <#
    .SYNOPSIS
    convert/coerce values into type info easier
    .example
        @( 'IPropertyCmdletProvider'
        'ICmdletProviderSupportsHelp'
        'IContentCmdletProvider' ) | .Type.Info


    .example
        'rgbcolor'  |  Dotils.Type.Info
                    | %{ $_.GetTypeInfo().FullName }
                    | Should -Be 'PoshCode.Pansies.RgbColor'
    #>
    [Alias('.As.TypeInfo')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, mandatory)]
        [object]$InputObject,

        [switch]$CompareAsLower,

        [Alias('All')][switch]$WildCard
    )
    process {
        if(-not $WildCard -and ($InputObject -match '\*')) {
            write-error 'wildcard not enabled, are you sure?'
        }
        if($CompareAsLower) {
            $InputObject = $InputObject.ToLower()
        }
        $query = Find-Type $InputObject
        if(-not $query) { write-error 'failed type' ; return }
        return $query
    }
}
function Dotils.Render.CallStack {
    <#
    .SYNOPSIS
        quickly, render PS CallStack else the current one
    .DESCRIPTION
        'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }
    .EXAMPLE
        Dotils.Render.CallStack
    .EXAMPLE
        Get-PSCallStack
            | Dotils.Render.CallStack Default
    .EXAMPLE
        # piping allows user to reverse, or even automatically trim segments for abbreviation
        Get-PSCallStack
            | ReverseIt
            | Dotils.Render.CallStack
    #>
    [Alias(
        '.CallStack', 'Render.Stack'
    )]
    [CmdletBinding()]
    param(
        # Json to make copy-paste easier
        [ValidateSet(
            'Default', 'Line',
            'List', 'Json'
        )][string]$OutputFormat = 'Default',

        # input else current
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CallStack', 'Frames', 'Stack', 'CallStackFrame', 'Command')]
        [Management.Automation.CallStackFrame[]]$InputObject,

        [switch]$ClipIt,

        [switch]$ExtraVerbose
    )
    begin {
        # [Collections.Generic.List[Object]]$Items = @()
        [Collections.Generic.List[Management.Automation.CallStackFrame]]$Items = @()
        if ($ExtraVerbose) {
            '-begin Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }
    }
    process {
        if ($ExtraVerbose) {
            '-proc  Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }
        # if pipeline expecting input, merge list of items
    }
    end {
        if ($ExtraVerbose) {
            '-end   Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }

        if ( -not $MyInvocation.ExpectingInput -or -not $items) {
            $items = Get-PSCallStack
        }

        # if(-not $PSBoundParameters.)
        [string[]]$render = ''
        switch ($OutputFormat) {
            'Default' {
                $render = $Items | Join-String -Property Command -sep ' ▸ '
            }
            'Line' {
                $render = $Items | Join-String -Property Command -sep ' Ⳇ '
            }
            'List' {
                $render = $Items | Join-String -Property Command -f "`n - {0}"
            }

            default {
                throw "UnhandledOutputFormat: $OutputFormat"
                # 'sdfds'
            }
        }
        $sbRaw = "${bg:gray80}${fg:gray30}[Sb]${bg:clear}${fg:clear}" # color tbd
        $sbRaw = '{Sb}'
        [string]$render = $render -join "`n" -replace [Regex]::Escape('<ScriptBlock>'), $sbRaw
        if ($ClipIt) {
            return $render | Set-Clipboard -PassThru
        }
        return $render

    }
}


function Dotils.Random.Module { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random module from the list of modules
    .DESCRIPTION
        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.
    .example
        Dotils.Random.Module | Dotils.Random.Command
    .example
        'pansies', 'ImportExcel', 'ugit' | Dotils.Random.Module
    .example
        Dotils.Random.Module  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.Module
    .NOTES
        test each invoke mode
        - [x] Dotils.Random.Module -ModuleName 'ClassExplorer', 'ugit'
        - [x] 'ClassExplorer', 'ugit' | Dotils.Random.Module
        - [x] Dotils.Random.Module
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [CmdletBinding()]
    param(
        # defaults to parameter, else to pipeline, else default value
        [Parameter(ValueFromPipeline, Position=0)]
        [string[]]$ModuleName
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($ModuleName))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($ModuleName) {
                $Items.AddRange(@($ModuleName))
            }
        }

        if($items.count -eq 0){
            write-warning "InputNames not collected! $ModuleName"
            write-verbose 'fallback to defaults'
            $items.AddRange(@(
                'Pansies', 'ImportExcel', 'Dotils', 'ExcelAnt', 'Ugit', 'Ninmonkey.Console', 'PsReadLine', 'TypeWriter', 'ClassExplorer'

            ))
        }
        # $ModuleName ??= $ModuleName
        # $ModuleName ??= @(
        # )
        $items
            | Join-String -sep ', ' -op 'ModuleNames: ' -SingleQuote
            | Write-Verbose

        $items =
            $items | Sort-Object -Unique

        # does not enforce loading
        $maybeModules? = @(
            Get-Module -name $items
        )
        if($maybeModules?.count -lt $items.count) {
            $Items
                | Join-String -op 'Expected = ' -sep ', '-SingleQuote
                | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
                | write-warning

            $maybeModules? ?? '∅'
                | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
                | write-verbose
        }
        $whichModule =
            $maybeModules?
                | Get-Random -count 1

        if($whichModule) { return $whichModule }

        if(-not $whichModule) {
            $errMsg =
                $ModuleName | Join-String -op "Failed selecting random module! '$WhichModule'" -sep ', ' -SingleQuote
            throw $errMsg
        }
    }
}
function Dotils.Random.Command { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random command from the list of modules
    .DESCRIPTION
        (warning, depraved code, do not continue)

        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.

        Does not filter out aliases. I want them for now.
    .example
        Dotils.Random.Command | Dotils.Random.CommandExample
    .example
        Dotils.Random.Command -ModuleName 'ImportExcel', 'Pansies' -Debug
        # Debug lists all commands that were chosen from
    .example
        'ugit' | Dotils.Random.Command
    .example
        Dotils.Random.Command  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.Command
    .NOTES
        test each invoke mode
        - [ ] Dotils.Random.Command -ModuleName 'ClassExplorer', 'ugit'
        - [ ] 'ClassExplorer', 'ugit' | Dotils.Random.Command
        - [ ] Dotils.Random.Command
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [OutputType(
        'System.Management.Automation.FunctionInfo',
        'System.Management.Automation.CommandInfo',
        'System.Management.Automation.AliasInfo'
    )]
    [CmdletBinding()]
    param(
        # defaults to parameter, else to pipeline, else default value
        # todo: future abstracts accepts a list of commands or module names
        # which could be object instances
        [Alias('SourceModule')]
        [Parameter(ValueFromPipeline, Position=0)]
        [string[]]$ModuleName
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($ModuleName))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($ModuleName) {
                $Items.AddRange(@($ModuleName))
            }
        }

        if($items.count -eq 0){
            write-warning "InputNames not collected! $ModuleName"
            write-verbose 'fallback to defaults'
            $items.AddRange(@(
                'Pansies',
                'ImportExcel',
                'Dotils',
                'ExcelAnt',
                'Ninmonkey.Console',
                'PsReadLine',
                'TypeWriter',
                'ClassExplorer'
                'Ugit'

            ))
        }
        # $ModuleName ??= $ModuleName
        # $ModuleName ??= @(
        # )
        $items
            | Join-String -sep ', ' -op 'ModuleNames: ' -SingleQuote
            | Write-Verbose

        $items =
            $items | Sort-Object -Unique

        # # does not enforce loading
        # $maybeModules? = @(
        #     Get-Module -name $items
        # )
        # if($maybeModules?.count -lt $items.count) {
        #     $Items
        #         | Join-String -op 'Expected = ' -sep ', '-SingleQuote
        #         | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
        #         | write-warning

        #     $maybeModules? ?? '∅'
        #         | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
        #         | write-verbose
        # }
        $whichModule =
            $Items | Dotils.Random.Module -wa 'ignore' -ea 'ignore'
        # $whichModule =
        #     $maybeModules?
        #         | Get-Random -count 1
        $cmds = @(
            Get-Command -Module $whichModule
            # $whichModule.ExportedCommands.Keys
            # $whichModule.ExportedFunctions.Keys
            # $whichModule.ExportedAliases.Keys
            # $whichModule.ExportedCmdlets.Keys

            # $whichModule | % ExportedCommands
            )
        | Sort-object -Unique

        $cmds | Join-String -op 'FoundCommands: ' -sep ', ' -SingleQuote
              | write-debug


        $whichCmd =
            $cmds | Get-Random -Count 1

        if($whichCmd) { return $whichCmd }

#         ( $someMod ??= Dotils.Random.Module )
# $q = $someMod | Dotils.Random.Command -Verbose
        if(-not $whichCmd) {
            $errMsg =
                $ModuleName | Join-String -op "Failed selecting random Command! '$WhichModule'" -sep ', ' -SingleQuote
            throw $errMsg
        }
    }
}

function Dotils.Random.CommandExample { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random example from a list of commands
    .DESCRIPTION
        (warning, depraved code, do not continue)

        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.

        Does not filter out aliases. I want them for now.
    .example
        Dotils.Random.Command | Dotils.Random.CommandExample
    .example
        Dotils.Random.CommandExample -CommandName 'ExportExcel'
        # Debug lists all commands that were chosen from
    .example
        'ugit' | Dotils.Random.CommandExample
    .example
        Dotils.Random.CommandExample  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.CommandExample
    .NOTES
        test each invoke mode
        - [ ] Dotils.Random.CommandExample -ModuleName 'ClassExplorer', 'ugit'
        - [ ] 'ClassExplorer', 'ugit' | Dotils.Random.CommandExample
        - [ ] Dotils.Random.CommandExample
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [OutputType(
        'System.Management.Automation.FunctionInfo',
        'System.Management.Automation.CommandInfo',
        'System.Management.Automation.AliasInfo'
    )]
    [CmdletBinding()]
    param(
        # this function requires input
        # defaults to parameter, else to pipeline, else default value
        # todo: future abstracts accepts a list of commands or module names
        # which could be object instances
        [Alias('CommandName')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline, Position=0, Mandatory)]
        [object]$InputCommand
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($InputCommand))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($InputCommand) {
                $Items.AddRange(@($InputCommand))
            }
        }

        if($items.count -eq 0){
            throw "InputNames not collected! $InputCommand"

        }
        $helpObj = @(
                gcm $Items | Get-Help -Examples
            )

        write-warning 'command not finished, try: >
    Dotils.Random.Command <# -Verbose -Debug #> | Dotils.Random.CommandExample -Verbose <# -Debug #>'

        $whichExample =
            # note: Piping to Get-Random does not function the same in this context, unless explicitally wrapped in an array, or passed as a parameter
            Get-Random -Count 1 -Input @(
                $helpObj.examples.examples
            )

        return $whichExample


#         [object[]]$examples = @(
#             $items | %{
#                 $cmdName = $_
#                 (gcm $cmdName | Get-Help -Examples).examples.example
#             }
#         )

#          (gcm $Items | Get-Help -Examples).examples.example

#         return

#         $items
#             | Join-String -sep ', ' -op 'CommandNames: ' -SingleQuote
#             | Write-Verbose

#         $items =
#             $items | Sort-Object -Unique

#         $cmds = @( # -is [CommandInfo[]]
#             gcm $Items
#                 | Sort-Object -unique
#         )

#         # $examples = @(
#         #     foreach($cur in $cmds) {
#         #         Get-Help $cur -Examples | % Examples
#         #     }
#         # )

#         # Get-Help @($cmds)[0]

#         # $help = @(
#         #     Get-Help $cmds -Examples
#         # )

#         # $whichExample =
#         #     $help

#         # # does not enforce loading
#         # $maybeModules? = @(
#         #     Get-Module -name $items
#         # )
#         # if($maybeModules?.count -lt $items.count) {
#         #     $Items
#         #         | Join-String -op 'Expected = ' -sep ', '-SingleQuote
#         #         | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
#         #         | write-warning

#         #     $maybeModules? ?? '∅'
#         #         | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
#         #         | write-verbose
#         # }
#         # $whichCommand =
#         #     $Items | Dotils.Random.Module -wa 'ignore' -ea 'ignore'
#         # gcm $items | Get-Help -Examples
#         # $whichModule =
#         #     $maybeModules?
#         #         | Get-Random -count 1
#         $cmds = @(
#             Get-Command -Module $whichModule
#             # $whichModule.ExportedCommands.Keys
#             # $whichModule.ExportedFunctions.Keys
#             # $whichModule.ExportedAliases.Keys
#             # $whichModule.ExportedCmdlets.Keys

#             # $whichModule | % ExportedCommands
#             )
#         | Sort-object -Unique

#         $cmds | Join-String -op 'FoundCommands: ' -sep ', ' -SingleQuote
#               | write-debug


#         $whichCmd =
#             $cmds | Get-Random -Count 1

#         if($whichCmd) { return $whichCmd }

# #         ( $someMod ??= Dotils.Random.Module )
# # $q = $someMod | Dotils.Random.Command -Verbose
#         if(-not $whichCmd) {
#             $errMsg =
#                 $ModuleName | Join-String -op "Failed selecting random Command! '$WhichModule'" -sep ', ' -SingleQuote
#             throw $errMsg
#         }
    }
}


function Dotils.Modulebuilder.Format-SummarizeCommandAliases {
    <#
    .SYNOPSIS
        Summarize Aliases used by amodule, formatted as a nin-style alias comment
    .NOTES
    desired output to summarize gci:

    Output:
        # 'Get-ChildItem' = { 'gci', 'ls', 'dir' }
    .example
        PS> Dotils.Modulebuilder.Format-SummarizeCommandAliases 'Get-ChildItem'
            | Should -BeExactly "# 'Get-ChildItem' = { 'dir', 'gci' }"
    .example

        Dotils.Module.Format-AliasesSummary -CommandDefinition (gcm 'Label' | % Definition)
    .example
        Dotils.Modulebuilder.Format-SummarizeCommandAliases 'Get-ChildItem'


        Dotils.Module.Format-AliasesSummary 'Get-ChildItem'
            | Should -BeExactly "# 'Get-ChildItem' = { 'dir', 'gci' }"
    #>
    # [Nin.NotYetImplemented('ArgumentTransformation, or PipeScript with TypeUnions, see NoMoreTangnent for the first example')]
    [Alias('Dotils.Module.Format-AliasesSummary')]
    [OutputType('System.String')]
    param(

        # currently just the defintion string
        [Parameter()]
        [Alias('Name', 'Definition')][string]$CommandDefinition,

        # accepts [CmdletInfo], [AliasInfo], etc...
        [Parameter()]
        [System.Management.Automation.CommandInfo]
        $InputObject


    )
@'
[Nin.NotYetImplemented('ArgumentTransformation, or PipeScript with TypeUnions, see NoMoreTangnent for the first example')]


to finish next: wrap this automaticallly

        Dotils.Module.Format-AliasesSummary -CommandDefinition (gcm 'Label' | % Definition)
either [1] regular argumenttransformatation
'@ | write-warning

    if($null -ne $InputObject) {
        throw 'Finish func, accept both types automagically.'
    }

    $target = $CommandDefinition
    $aList =
        Get-Alias -Definition $CommandDefinition

    [string]$render = ''

    $render +=
        $target
            | Join-String -SingleQuote -op '# ' -os ' = '

    $render +=
        $aList
            | Sort-Object -Unique
            | Join-String -sep ', ' -SingleQuote -op '{ ' -os ' }'

    $render
}

$exportModuleMemberSplat = @{
    # future: auto generate and export
    # (sort of) most recently added to top
    Function = @(
        # 2023-07-29
        'Dotils.Render.ColorName'
        'Dotils.Format.Color'
        # 2023-07-24
        'Dotils.Format.Write-DimText' # 'Dotils.Format.Write-DimText' = { 'Dotils.Write-DimText' }
        # 2023-07-10
        'Dotils.Log.Format-WriteHorizontalRule' # 'Dotils.Log.Format-WriteHorizontalRule' = { }
        'Dotils.Log.WriteFromPipe' # 'Dotils.Log.WriteFromPipe' = { }
        'Dotils.Log.WriteNowHeader' # 'Dotils.Log.WriteNowHeader' = { }
        #
        'Dotils.Format-ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }
        'Dotils.Format-ShortString.Basic' # 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
        'Dotils.Object.QuickInfo' # 'Dotils.Object.QuickInfo' = { 'QuickInfo' }
        #
        'Dotils.SamBuild'
        'Dotils.Out.XL-AllPropOfBoth' # 'Dotils.Out.XL-AllPropOfBoth' = {}
        'Dotils.Modulebuilder.Format-SummarizeCommandAliases' # 'Dotils.Modulebuilder.Format-SummarizeCommandAliases' = { 'Dotils.Module.Format-AliasesSummary' }
        #
        'Dotils.Debug.GetTypeInfo' # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }

        'Dotils.Start-WatchForFilesModified' # 'Dotils.Start-WatchForFilesModified' = { <none> }
        'Dotils.Select-NotBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        'Dotils.Random.Module' #  Dotils.Random.Module = { <none> }
        'Dotils.Random.Command' #  Dotils.Random.Command = { <none> }
        'Dotils.Random.CommandExample' #  Dotils.Random.Command = { <none> }

        'Dotils.Debug.Find-Variable' # <none>
        'Dotils.FindExceptionSource' # <none>
        #
        # ...
        'Dotils.Debug.Find-Variable'
        'Dotils.Format-TaggedUnionString'
        'Dotils.Join.Brace'
        'Join.Pad.Item'
        # ...
        #
        'Dotils.Type.Info' # '.As.TypeInfo'
        'Dotils.DB.toDataTable' # 'Dotils.ConvertTo-DataTable


        'Dotils.Build.Find-ModuleMembers' # <none>
        'Dotils.Search-Pipescript.Nin' # <none>
        #
        'Dotils.InferCommandCategory'  # <none>
        'Dotils.Find-MyNativeCommand' # <none>
        # dups?
        'Dotils.Find-MyNativeCommandKind'  # <none> but check it
        'Dotils.Get-NativeCommand' # <none> but check it
        #
        #
        'Dotils.Find-MyWorkspace'  # Find-MyWorkspace
        'Dotils.SelectBy-Module' # 'SelectBy-Module', 'Dotils.SelectBy-Module', 'SelectBy-Module'


        #
        'Dotils.Select-ExcludeBlankProperty' #  'Select-ExcludeBlankProperty'
        # 'Dotility.CompareCompletions'
        # 'Dotility.GetCommand'
        'Dotils.CompareCompletions'
        'Dotils.GetCommand'
        'Dotils.Render.ErrorRecord.Fancy'
        'Dotils.Render.ErrorRecord'
        'Dotils.Tablify.ErrorRecord'
        'Dotils.Measure-CommandDuration'
        'Dotils.JoinString.As' # 'Join.As'
        ## some string stuff
        'Console.GetColumnCount'  # none
        'Dotils.Write.Info' # 'Write.Info'
        'Dotils.Write.Info.Fence' # 'Write.Info.Fence'
        'Dotils.String.Normalize.LineEndings' # 'String.Normalize.LineEndings'
        'Dotils.ClampIt'  # 'ClampIt'
        'Dotils.String.Visualize.Whitespace' # 'String.Visualize.Whitespace'
        'Dotils.String.Transform.AlignRight' # 'String.Transform.AlignRight'
        'Dotils.Testing.Validate.ExportedCmds' # 'MonkeyBusiness.Vaidate.ExportedCommands'
        'Dotils.Join.CmdPrefix'
        ## --
        'Dotils.Html.Table.FromHashtable' # 'Marking.Html.Table.From.Hashtable'
        ## until
        'Dotils.Stdout.CollectUntil.Match' # 'PipeUntil.Match' #
        'Dotils.Out.Grid2' # <none>
        'Dotils.Render.Callstack' # => { '.CallStack', 'Render.Stack' }
        'Dotils.Write-NancyCountOf' # => { 'CountOf', 'OutNull' }
        'Dotils.Grid' # => { 'Nancy.OutGrid', 'Grid' }
        'Dotils.PSDefaultParams.ToggleAllVerboseCommands' # => { }
        'Dotils.LogObject' # 'Dotils.LogObject' => { '㏒' }
    )
    | Sort-Object -Unique
    Alias    = @(
        # 2023-07-24
        'Dotils.Write-DimText' # 'Dotils.Format.Write-DimText' = { 'Dotils.Write-DimText' }
        #
        'Dotils.ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }
        'Dotils.ShortString.Basic'  # 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
        # 'Dotils.Format-ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }

        'QuickInfo' # 'Dotils.Object.QuickInfo' = { 'QuickInfo' }

        'Dotils.Module.Format-AliasesSummary' # 'Dotils.Modulebuilder.Format-SummarizeCommandAliases' = { 'Dotils.Module.Format-AliasesSummary' }
        #

        'Dotils.Is.Type' # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }
        'Is.Type' # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }
        '.IsType' # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }
        'IsType' # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }

        #

        'Dotils.DropBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        'Dotils.Where-NotBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        '㏒' # 'Dotils.LogObject' => { '㏒' }
        'CountOf' # 'Dotils.Write-NancyCountOf' => { CountOf, OutNull }
        'OutNull' # 'Dotils.Write-NancyCountOf' => { CountOf, OutNull }
        'Nancy.OutGrid' # 'Dotils.Grid' => { 'Nancy.OutGrid', 'Grid' }
        'Grid'          # 'Dotils.Grid' => { 'Nancy.OutGrid', 'Grid' }

        '.As.TypeInfo' # 'Dotils.Type.Info'
        'Dotils.ConvertTo-DataTable' # 'Dotils.DB.toDataTable'
        'Find-MyWorkspace'  # 'Dotils.Find-MyWorkspace'

        'SelectBy-Module' # Dotils.SelectBy-Module
        'SelectBy-Module' # Dotils.SelectBy-Module
        #
        'Select-ExcludeBlankProperty' # 'Dotils.Select-ExcludeBlankProperty'
        # '.CallStack', 'Render.Stack'
        '.CallStack'   # 'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }
        'Render.Stack' # 'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }


        'Join.As' # 'Dotils.JoinString.As'
        'CompareCompletions' # 'Dotils.CompareCompletions'
        'TimeOfSB' # 'Dotils.Measure-CommandDuration'
        'DeltaOfSBScriptBlock' # 'Dotils.Measure-CommandDuration'
        'dotils.DeltaOfSB'     # 'Dotils.Measure-CommandDuration'
        'MonkeyBusiness.Vaidate.ExportedCommands' # 'Dotils.Testing.Validate.ExportedCmds'
        ## some string stuff
        # 'Console.GetColumnCount'  #
        'Write.Info' # 'Dotils.Write.Info'
        'Write.Info.Fence' # 'Dotils.Write.Info.Fence'
        'String.Normalize.LineEndings' # 'Dotils.String.Normalize.LineEndings'
        'ClampIt'  # 'ClampIt'
        'String.Visualize.Whitespace' # 'String.Visualize.Whitespace'
        'String.Transform.AlignRight' # 'S
        ## --
        'Marking.Html.Table.From.Hashtable' # 'Dotils.Html.Table.FromHashtable'
        'Dotils.Debug.Compare-VariableScope'
        'Dotils.Debug.Get-Variable'
        'PipeUntil.Match' # Dotils.Stdout.CollectUntil.Match
    ) | Sort-Object -Unique
}
Export-ModuleMember @exportModuleMemberSplat


Hr -fg magenta

[string[]]$cmdList = @(
    $exportModuleMemberSplat.Function
    $exportModuleMemberSplat.Alias
) | Sort-Object -Unique

H1 'Validate: ByCmdList'
Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

H1 'Validate: ModuleName'
Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'
Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
# return
# Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

# hr -fg magenta

# Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'

# $stats | ft -AutoSize
H1 'Validate:IsBad: double names'
Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList | ? IsBad
# was: $stats | ?{ $_.IsAFunc -and $_.IsAnAlias }

@'
try:
    Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
'@
'dotils next:
function Dotils.Stash-NewFileBuffer {
    quickly dump files into a location to be used later, quick ideas. no naming.
}
'

# Dotils.Testing.Validate.ExportedCmds