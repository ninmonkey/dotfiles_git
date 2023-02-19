$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.AutoLoad_ToRefactor = $PSCommandPath | gi

if($global:__nin_enableTraceVerbosity) {  "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

# Import-module ninmonkey.console -DisableNameChecking *>$null

function xL.Window.CloseAll {
    # close all open excel windows
    # synopsis closes all excel windows allowing them to save, without triggering the save prompt or safety mode
    $Ps = Get-Process *Excel* -ea ignore
    if($PS) {
        $ps.CloseMainWindow()
    }
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

        if( [string]::IsNullOrEmpty($this.Description) ) {
            $this.Description = '[empty]'
        }
    }
    [string] ToString() {
        # returns as json
        return ($this | ConvertTo-Json -Depth 3 -Compress)
    }
}

$script:____gh_state ??= @{
    QueryCache = @{}
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
        if($Limit) {
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
        'fetching...' | write-host
    }
    $Cache[$Owner] -split '\r?\n' | %{
        [GhRepoListRecord]::new( $_ )
    } | sort -Property When -Descending

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
    if( -not $cache.ContainsKey($RepoName) ) {
        '{0} is not cached, requesting...'
        | write-warning

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
        | Export-Excel -work $TableName -table "${TableName_t}" -AutoSize -Show  -TableStyle Light2 #-Verbose -Debug
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
            | Join-String -sep (hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }
        'Duplicates' {
            Get-History
            | Join-String -sep (hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }

        default {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String CommandLine -sep (hr 1)
        }
    }
}

if($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

