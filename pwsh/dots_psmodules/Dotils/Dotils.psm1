function Console.GetColumnCount {
    [OutputType('System.Int32')]
    param()
    $w = $host.ui.RawUI.WindowSize.Width
    return $w
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
        | Join-string -SingleQuote:$quote
        | new-text -bg 'gray30' -fg 'gray80' | % tostring
    }
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
            | %{
                [string]$curLine = $_

                if($ShowDebugOutput) {
                    label 'what' 'orig'
                    $curLine
                    | String.Visualize.Whitespace
                    | Write.Info
                }

                if($curLine -match $Re) { } else { return }
                $withoutPadding = $matches.Content ?? ''

                if($ShowDebugOutput) {
                    label 'what' 'without pad'
                    $withoutPadding
                    | String.Visualize.Whitespace
                    | Write.Info
                }

                $width  = (Console.GetColumnCount) ?? 120
                $render = $withoutPadding.ToString().PadLeft( $width, ' ')
                if($ShowDebugOutput) {
                    label 'what' 'new pad'

                    $render
                    | String.Visualize.Whitespace
                    | Write.Info
                }
                return $render
            }
    }
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

        -ProcessUntil RegexMatch 'gateway' # ie: Ignores, but allows rest to continue

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

        [Alias('Kwargs')][hashtable]$Options
    )
    begin {
        $HasFoundPattern = $false

    }
    process {
        if ($HasFoundPattern) { return }

        Foreach ($item in $InputObject) {
            if ($HasFoundPattern) { return }
            if ($Item -match $Pattern) {
                $HasFoundPattern = $true
                return
            }
            $Item
        }
    }
    end {

    }
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
        switch($Kind) {
            'Enum' {
                $InputObject
                    | Find-Member |  % name | sort-object -Unique
                    | ?{ $_ -ne 'value__' }
                    | Join-string -sep ' | ' -op ' [ ' -os ' ] '  -SingleQuote
                break
            }
            'InternalScriptExtent' { # 'c:\foo\bar.ps1:134'
                # in vs code / grep format
                $InputObject.Position
                    | Join-string {
                        $_.File, $_.StartLineNumber -join ':'
                    }
                break
            }
            'PSCallStack.Locations' {
                # ex: usage: Get-PSCallStack | %{ $_ | Join-String { $_.Location } } | Join.UL
                $InputObject | %{
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
        $renderBody = $InputHashTable.GetEnumerator() | %{
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


function Measure-Dotils.CommandDuration {
    <#
    .synopsis
        sugar to run a command and time it. low precision. just a ballpark
    #>
    [Alias(
        'TimeOfSb',
        'Measure-Dotils.CommandDuration',
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
            } catch {
                $this.Success = $false
                $_  | Join-String -f 'Something Failed 😢: {0}'
                    | write-error
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
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
        if($PSBoundParameters.ContainsKey('PropertySets')) { throw "NYI: Property sets are wip: $PSCommandPath"}
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
                IgnoreUnder = $true
            }
         $__propList.ErrorRecord_FindMember_Basic = @( # dynamic, yet simplified list
            @(
                $propList.ErrorRecord_AutoFindMember
                $propList.ErrorRecord_FindMember_Static
             )
             | sort-object -unique
             | ?{
                if($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
                if($_ -match [regex]::escape('k__BackingField'))          { return $false }
                if($_ -match [regex]::escape('^.ctor'))                   { return $false }
                if( $innerConfig.IgnoreUnder -and $_ -match '^_{1}')      { return $false }
                if( $innerConfig.IgnoreDunder -and $_ -match '^_{2}')     { return $false }
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
             ) | ?{
               if($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
               if($_ -match [regex]::escape('k__BackingField')) { return $false }
               if($_ -match [regex]::escape('^.ctor')) { return $false }
               if( $innerConfig.IgnoreUnder -and $_ -match '^_{1}') { return $false }
               if( $innerConfig.IgnoreDunder -and $_ -match '^_{2}') { return $false }
               $true
            }
         )

    }
    process {
        $meta = [ordered]@{}
        $IncludeFancy = $true
        $target = $InputObject
        $metaFancy = @{}

        switch($target) {
            {  $_ -is 'System.Management.Automation.ErrorRecord' } {
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
            {  $_ -is 'System.Exception' } {
                write-verbose 'found type: [Exception]'
                $captureProps = $_ | Select *

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
        if(-not $Fancy) {
            return $CaptureProps | Add-Member -passThru -force -ea 'ignore' -NotePropertyMembers @{
                PSShortType = $Target | Format-ShortTypeName
                OriginalObject = $Target
            }
            # $CaptureProps
        }
        return [pscustomobject]$metaFancy | Add-Member -passThru -force -ea 'ignore' -NotePropertyMembers @{
                PSShortType = $Target | Format-ShortTypeName | Join-String -op 'Fancy.'
                OriginalObject = $Target
            }
        # meta not actually used
    }
    end {
        if($ListPropertySets) {
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

        switch($OutputFormat) {
            'OneLine' {
                $InputObject
                    | Dotils.Tablify.ErrorRecord -ListPropertySets
                    | %{ $_.PsObject.Properties }
                    | %{
                        $_.name
                        $_.Value | Join-String -sep ', ' -op "`n$($_.name)"
                    }
                    | Join-String -sep ( hr 1 )
                break
            }
            { $_ -in @('UL', 'List') } {
                $InputObject
                    | Dotils.Tablify.ErrorRecord -ListPropertySets
                    | %{ $_.PsObject.Properties }
                    | %{
                        $_.name
                        $_.Value | Join.UL
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
    $_ | %{
        label '>' -Separator ' ' $_ | Write.Info
    }
    }
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
    if($ColumnOrSubstring -is 'int') { $Col = $ColumnOrSubstring -as 'int' }
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
    if(-not $PSBoundParameters.ContainsKey('CommandName')) {
        # from
        if($ModuleName -ne 'dotils') {
            Import-Module -force -Name $ModuleName -ea 'stop' -PassThru | Write.Info
        }
        $mod = Get-Module -Name $ModuleName

        [string[]]$cmdList =
            @(  $Mod.ExportedCommands.keys
                $Mod.ExportedAliases.keys )
            | Sort-object -Unique
    } else {
        [string[]]$cmdList =
            $CommandName
            | Sort-object -Unique
    }

    $cmdList | Join.UL | Join-String -op "Commands found: " | write-verbose

    $stats = $cmdList | %{
        # label '>' -Separator ' ' $_ | Write.Info
        [pscustomobject]@{
            Name = $_
            IsAFunc   = ( $is_func  = test-path function:\$_ )
            IsAnAlias = ( $is_alias = test-path alias:\$_    )
            IsBad = $is_func -and $is_alias
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

    if($true) {  return } # skip older code
    $gcmSplat = @{
        ErrorAction = 'continue'
        Name = @(
            # 'Dotility.CompareCompletions'
            # 'Dotility.GetCommand'
            'Dotils.CompareCompletions'
            'Dotils.GetCommand'
            'Dotils.Render.ErrorRecord.Fancy'
            'Dotils.Render.ErrorRecord'
            'Dotils.Tablify.ErrorRecord'
            'Measure-Dotils.CommandDuration'
            # was:
            # 'Measure-Dotils.CommandDuration'
            # 'Dotils.Tabilify.ErrorRecord'
            # 'Dotils.Render.ErrorVars'
            # 'Dotils.Render.ErrorRecord.Fancy'
        )
    }
}


$exportModuleMemberSplat = @{
    # future: auto generate and export
    Function = @(
        # 'Dotility.CompareCompletions'
        # 'Dotility.GetCommand'
        'Dotils.CompareCompletions'
        'Dotils.GetCommand'
        'Dotils.Render.ErrorRecord.Fancy'
        'Dotils.Render.ErrorRecord'
        'Dotils.Tablify.ErrorRecord'
        'Measure-Dotils.CommandDuration'
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
    )
    | Sort-Object -Unique
    Alias    = @(
        'Join.As' # 'Dotils.JoinString.As'
        'CompareCompletions' # 'Dotils.CompareCompletions'
        'TimeOfSB' # 'Measure-Dotils.CommandDuration'
        'DeltaOfSBScriptBlock' # 'Measure-Dotils.CommandDuration'
        'dotils.DeltaOfSB'     # 'Measure-Dotils.CommandDuration'
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


        'PipeUntil.Match' # Dotils.Stdout.CollectUntil.Match
    ) | Sort-Object -Unique
}
Export-ModuleMember @exportModuleMemberSplat


hr -fg magenta

[string[]]$cmdList = @(
    $exportModuleMemberSplat.Function
    $exportModuleMemberSplat.Alias
) | sort-object -unique

h1 'Validate: ByCmdList'
Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

h1 'Validate: ModuleName'
Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'
Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
# return
# Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

# hr -fg magenta

# Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'

# $stats | ft -AutoSize
h1 'Validate:IsBad: double names'
Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList | ? IsBad
# was: $stats | ?{ $_.IsAFunc -and $_.IsAnAlias }

@'
try:
    Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
'@

# Dotils.Testing.Validate.ExportedCmds