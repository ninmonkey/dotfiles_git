$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.AutoLoad_ToRefactor = $PSCommandPath | Get-Item

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

# Import-module ninmonkey.console -DisableNameChecking *>$null

@'
Quick hack to cover this for now
VERBOSE: Cannot find provider 'PowerShellGet' under the specified path.
VERBOSE: Importing package provider 'PowerShellGet'.
VERBOSE: Checking for updates for module 'PipeScript'.
'@  | Write-Debug
nin.psmodulePath.AddNamedGroup Main

function nancy.WriteInverse {
    $Input | Join-String -op $PSStyle.Reverse -os $PSStyle.Reset
}

$setAliasSplat = @{
    Name        = '.fmt.md.TableRow0'
    Value       = '_fmt_mdTableRow'
    Description = 'experiment with a new command namespace: ''.fmt'''
    ErrorAction = 'ignore'
}

Set-Alias @setAliasSplat
function _fmt_mdTableRow {
    <#
    .EXAMPLE
    PS> 'a'..'e' | _fmt_mdTableRow

        | a | b | c | d | e |

    .EXAMPLE
    PS> 'Name', 'Length', 'FullName' | _fmt_mdTableRow

        | Name | Length | FullName |
    .EXAMPLE
        (get-date).psobject.properties
        | %{
            @(
                $_.Name
                $_.Value
                ($_.Value)?.GetType() ?? "`u{2400}"

            )  | _fmt_mdTableRow
        }

    #Output:
        | DisplayHint | DateTime | Microsoft.PowerShell.Commands.DisplayHintType |
        | DateTime | Wednesday, April 5, 2023 5:55:57 PM | string |
        | Date | 04/05/2023 00:00:00 | datetime |
        | Day | 5 | int |
        | DayOfWeek | Wednesday | System.DayOfWeek |
        | DayOfYear | 95 | int |
        | Hour | 17 | int |
        | Kind | Local | System.DateTimeKind |
        | Millisecond | 258 | int |
        | Microsecond | 715 | int |
        | Nanosecond | 300 | int |
        | Minute | 55 | int |
        | Month | 4 | int |
        | Second | 57 | int |
        | Ticks | 638163141572587153 | long |
        | TimeOfDay | 17:55:57.2587153 | timespan |
        | Year | 2023 | int |
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [String[]]$InputText
    )
    begin {
        $lines = @()
    }
    process {
        foreach ($line in $InputText) {
            $LineS += $line
        }
    }
    end {

        # $lines | Join-String -sep ' | ' -op '| ' -os " |`n"
        $lines | Join-String -sep ' | ' -op '| ' -os ' |'
    }
}

function b.wrapLikeWildcard {

    <#
    .SYNOPSIS
        converts like-patterns to always wrap wildcards
    .example
        'cat', 'CAT*' | b.wrapLikeWildcard
        '*cat*', '*cat*
    #>
    process {
        @( '*', $_.ToLower(), '*') -join '' -replace '\^\*{2}', '*' -replace '\*{2}$', '*'
    }
}


function b.Text.WrapString {
    <#
    .EXAMPLE
        b.Text.WrapString ('a'..'z' -join '_') -MaxWidth 10

            a_b_c_d_e_
            f_g_h_i_j_
            k_l_m_n_o_
            p_q_r_s_t_
            u_v_w_x_y_
            z
    #>
    [Alias('Join.WrapText')]
    [CmdletBinding()]
    param(
        [Alias('Text')]
        [Parameter(Mandatory, Position = 0)]
        [string]$InputText,

        [Alias('Cols')]
        [int]$MaxWidth = 120
    )
    $regex_charCount = '(.{', $MaxWidth, '})' -join ''
    # $InputText -join "`n" -split '(.{80})' -join "`n" -replace '\n+', "`n"
    $InputText -join "`n" -split $regex_charCount -join "`n" -replace '\n+', "`n"
}


function nin.addProp {
    [Alias('n.Prop')]
    [CmdletBinding(DefaultParameterSetName = 'addSingleProperty')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [Parameter(Position = 0)]
        [Alias('Name', 'Label')]
        [string]$PropertyName,


        [Parameter(Position = 1, Mandatory, ParameterSetName = 'addSingleProperty')]
        [object]$Value,

        # requires explicit parameter name else it gets complicated because object, hash, etc
        # could all possibly be valid, or invalid, depending on context
        [Alias('hashtable', 'Dict', 'NotePropertyMembers', 'Members')]
        [Parameter(Position = 1, Mandatory, ParameterSetName = 'addManyProperties')]
        [hashtable]$AddPropertyMembers
    )
    process {

        $splat_addMember = @{
            Force       = $true
            ErrorAction = 'ignore'
            PassThru    = $true
        }

        if ($PSBoundParameters.ContainsKey('Value') -or $PSCmdlet.ParameterSetName -eq 'addSingleProperty') {
            $splat_addMember.NotePropertyName = $PropertyName
            $splat_addMember.NotePropertyValue = $Value
        }
        else {
            $splat_addMember.NotePropertyMembers = $AddMembers

        }


        $InputObject | Add-Member @splat_addMember
    }


}
function One {
    # [Alias('First')]
    <#
    .SYNOPSIS
        sugar for: Select first 1
    #>
    # one of the rare cases where Input is useful without the dangers
    $Input | Select-Object -First 1
}

function b.fm {
    <#
    .SYNOPSIS
        Find member, sugar to show full name, and enforce wildcard
    .EXAMPLE
        Pwsh> $eis | b.fm fetch


    #>
    param( [string]$Pattern, [bool]$WithoutSmartCase )
    process {
        if (-not $WithoutSmartCase) {
            $Patter = $Pattern.ToLower()
        }
        $pattern = $pattern | b.wrapLikeWildcard
        # $pattern = @( '*', $patter.ToLower(), '*') -join '' -replace '\^\*{2}', '*'

        if ($Pattern) {
            $_ | Find-Member $Pattern | Sort-Object Name | Format-Table Name, DisplayString
        }
        else {
            $_ | Find-Member | Sort-Object Name | Format-Table Name, DisplayString
        }
    }
}


function b.getAll.Props {
    # for all, get all common props
    <#
        .SYNOPSIS
        get a distinct list of all properties of all objects piped
        .example
            gi . | b.getAll.Props
        #>
    $items = $input

    @(foreach ($x in $items) {
            $x.PSObject.Properties.Name
        }) | Sort-Object -Unique
}

New-Alias '.fmt.Html.Table' -Value 'Html.Table.Convert.FromHash' -ea ignore

function Format-Html.Table.FromHashtable {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InputHashtable
    Parameter description

    .EXAMPLE
            .fmt.html.Table

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    [Alias(
        # namespaces experiment.
        'Convert.Html.Table.FromHash',
        'Html.Table.Convert.FromHash',
        'Html.Table.FromHashtable',
        '.fmt.Html.Table'
    )]
    param(
        [Parameter(Mandatory)]
        [hashtable]$InputHashtable
    )
    $renderBody = $InputHashTable.GetEnumerator() | ForEach-Object {
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
        [switch]$TestHasAny,

        # write-information
        [Alias('ShowCount')]
        [switch]$IncludeCount
    )
    $TotalErrorCount = $global:error.count
    if ($IncludeCount) {
        'Had {0} errors before clearing' -f @(
            $TotalErrorCount
        ) | Write-Information -infa 'continue'
    }

    'Had {0} Errors' -f @(
        $TotalErrorCount
    ) | Write-Verbose

    if ($TestHasAny) {
        return ($TotalErrorCount -gt 0)
    }
    if ($TotalErrorCount) {
        return $TotalErrorCount
    }

    if ( $Clear ) { $global:error.Clear() }
    if ( $Clear ) { $error.Clear() } # depending if func is in profile or module
    return $global:error | Select-Object -First $Num | CountOf
}


class GhRepoListRecord {
    [string]$OwnerPair
    [string]$Owner
    [string]$Name
    [datetime]$When
    [string]$Description
    [string]$IsPublic

    GhRepoListRecord([string]$line) {
        $this.OwnerPair, $this.Description, $this.IsPublic, $this.When = $line -split '\t'
        $this.Owner, $this.Name = $this.OwnerPair -split '/'

        if ( [string]::IsNullOrEmpty($this.Description) ) {
            $this.Description = '[empty]'
        }
    }
    [string] ToString() {
        # returns as json
        return ($this | ConvertTo-Json -Depth 3 -Compress)
    }
}

$script:____gh_state ??= @{
    QueryCache    = @{}
    RepoDescCache = @{}
}
function Get-GHRepoList {
    <#
    .SYNOPSIS
        queries / returns the names of repos for a user, naive cache
    .EXAMPLE
        # cloning multiple
        🐒> $which ??= gh.repo.List sql-bi | % OwnerPair | fzf -m
        🐒> $which | %{
            $name  = $_ -replace '/', '⁞'
                & gh @('repo', 'clone', $_, $_name)
            }
        }
        # future: should-process cloning already written in nin.console ?

    #>
    [Alias('gh.repo.List')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            'dfinke', # todo: make this an argument completer with tooltip text
            'StartAutomating',
            'SeeminglyScience',
            'jborean93',
            'dotnet',
            'EvotecIT',
            'Jaykul',
            'indented-automation',
            'microsoft',
            'ninmonkey',
            'PowerShell',
            'sharkdp',
            'KevinMarquette',
            'TabularEditor',
            'JustinGrote',
            'nohwnd',
            'IISResetMe',
            'sql-bi',
            'TylerLeonhardt',
            'itsnotaboutthecell',

            'adamdriscol'
        )]
        [Parameter(Position = 0)]
        [string]$Owner = 'ninmonkey',

        # GH uses 30 normally
        [Parameter(Position = 1)]
        [int]$Limit = 99
    )
    [Collections.Generic.List[Object]]$GhArgs = @(
        'repo'
        'list'
        if ($Owner) { $Owner }
        '--source'
        '--no-archived'
        if ($Limit) {
            '--limit'
            $Limit
        }
    )


    $cache = $script:____gh_state.QueryCache


    $GHargs
    | Join-String -sep ' ' -op 'invoke => gh '
    | Write-Verbose


    if ( -not $cache.ContainsKey($Owner) ) {
        $rawResponse = gh @ghArgs
        $cache[$Owner] = $rawResponse
        'fetching...' | Write-Host
    }
    $Cache[$Owner] -split '\r?\n' | ForEach-Object {
        [GhRepoListRecord]::new( $_ )
    } | Sort-Object -Property When -Descending

}

$script:__fzfPreviewCache ??= @{}
function renderPreviewForRepoDescription {
    <#
    .SYNOPSIS
        recieves a repo name,
    .example
        renderPreviewForRepoDescription ninmonkey/pynin
        renderPreviewForRepoDescription ExcelAnt
    #>
    [Alias('gh.repo.View')]
    [CmdletBinding()]
    param( [string]$RepoName )

    $cache = $script:__fzfPreviewCache
    if ( -not $cache.ContainsKey($RepoName) ) {
        '{0} is not cached, requesting...'
        | Write-Warning

        $renderResponse = & gh @(
            'repo'
            'view'
            $RepoName
        ) # *>&1
        | bat -p

        $cache[$RepoName] = $renderResponse
    }
    return $cache[$RepoName] # $cache = gh repo view marking *>&1 |bat -p

}

# $GhArgs | join.ul
# return

# $c.2 | ForEach-Object { $_ -split '\t' | join.ul }



# $what | ForEach-Object { $_ -split '\t' | s -First 1 }
# function prof.hack.addExcel {
#     # super quick hack, do not use
#     [Alias(
#         'add-xl',
#         'to-xl.v2'
#     )]
#     [CmdletBinding()]
#     param(
#         # [Parameter()]
#         # [string]$TableName = 'default',

#         # [Parameter(Mandatory, ValueFromPipeline)]
#         # [object[]]$InputObject

#         # [switch]$ClearSheet,
#         # #final call, show
#         [switch]$Show,
#     )
#     begin {
#         # [Collections.Generic.List[Object]]$Items = @()
#     }
#     process {
#         # $Items.AddRange( $InputObject )
#     }
#     end {
#         # $items
#         # # | Export-Excel -work $TableName -table "${TableName_t}" -AutoSize -Show  -TableStyle Light2 #-Verbose -Debug
#     }
# }
function prof.hack.dumpExcel {
    # super quick hack, do not use
    [Alias('to-xl', 'to-xl.v1')]
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
        | Export-Excel -work $TableName -table "${TableName_t}" -AutoSize -Show -TableStyle Light2 #-Verbose -Debug
    }
}

function quickHist {
    [Alias('prof.quickHistory')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions('Default', 'Number', 'Duplicate')]
        [string]$Template
    )
    # Quick, short, without duplicates
    switch ($Template) {
        'Number' {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String -sep (Hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }
        'Duplicates' {
            Get-History
            | Join-String -sep (Hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }

        default {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String CommandLine -sep (Hr 1)
        }
    }
}

function prof.renderEvent {
    <#
    .EXAMPLE
    PS> Get-event | prof.renderEvent

    ChangeType FullPath             Name
    ---------- --------             ----
    Changed g:\temp\xl\other.png other.png

    ComputerName     :
    RunspaceId       : 061c6c83-4651-48a0-8716-e557e04b1670
    EventIdentifier  : 5
    Sender           : System.IO.FileSystemWatcher
    SourceEventArgs  : System.IO.FileSystemEventArgs
    SourceArgs       : {System.IO.FileSystemWatcher, other.png}
    SourceIdentifier : b3288091-6a90-4d98-9f5f-324a74ee139b
    TimeGenerated    : 2/25/2023 4:34:57 PM
    MessageData      :

    #>
    param()
    process {
        $_ | Format-List
        $_.SourceEventArgs | Format-Table -auto
    }
}

# usage: Get-event | prof.renderEvent

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

if ($false) {
    $script:__warnCache ??= @{}
    [Collections.Generic.List[Object]]$script:__warnInfoDetails = @()

    function warnOnce {
        # warn once withing spam
        [CmdletBinding(defaultparametersetname = 'Warn')]
        param(
            [Parameter(Mandatory, Position = 0, ParameterSetName = 'Warn')]
            [string]$Message,

            # If message is long, use a key instead of the full body
            [string]$KeyName = $Null,

            # instead of writing
            [Alias('GetHistory')]
            [Parameter(ParameterSetName = 'GetHistory', Mandatory)]
            [switch]$PassThru ,

            [Parameter(ParameterSetName = 'Warn')]
            [hashtable]$Options
        )
        if ($PassThru) {
            return $script:__warnInfoDetails
        }
        # if(-not $script:__warnCache ) {
        #     $state = $script:__warnCache = @{}
        # }
        $Config = $Options ?? @{
            UsingToast = $true
        }
        $state = $script:__warnCache
        $key = $KeyName ?? $Message
        if ($state.ContainsKey( $key )) {
            return
        }
        Write-Warning $Message
        if ($Config.UsingToast) {
            b.ToastIt -Title 'warnOnce' -Text $Message
        }
        $state[$key] = $true

        $meta = [pscustomobject]@{
            PSTypeName       = 'singleWarn.InvocationInfoDetails.nin'
            Message          = $Message
            KeyName          = $KeyName ?? $Message
            Line             = $MyInvocation.Line
            ScriptLineNumber = $MyInvocation.ScriptLineNumber
            ScriptName       = $MyInvocation.ScriptName
            PSCommandPath    = $MyInvocation.PSCommandPath
            When             = Get-Date
        }
        $script:__warnInfoDetails.Add( $meta )
        # not actually used just a quick hack to use set
    }
}

