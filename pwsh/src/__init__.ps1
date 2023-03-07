# $PSDefaultparameterValues['ModuleBuilder\Build-Module:verbose'] = $true # fully resolve command name never seems to workmodule scoped never seems to work
$PSDefaultParameterValues['Build-Module:verbose'] = $true
# $VerbosePreference = 'silentlyContinue'

# include some dev psmodule paths
$Env:PSModulePath = @(
    $Env:PSModulePath
    'H:\data\2023\pwsh\PsModules\ExcelAnt\Output'
) -join ';'

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
$PSStyle.OutputRendering = [Management.Automation.OutputRendering]::Ansi # wip dev,nin: todo:2022-03 # Keep colors when piping Pwsh in 7.2

[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()

'Encoding: [Console Input/Output: {0}, {1}, $OutputEncoding: {2}]' -f @(
    # alternate:  @( [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding ) -replace 'System.Text', ''
    @(  [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding | ForEach-Object WebName )
) | Write-Verbose -Verbose

$base = Get-Item $PSScriptRoot
. (Get-Item -ea 'continue' (Join-Path $Base 'Build-ProfileCustomMembers.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'Invoke-MinimalInit.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'autoloadNow_butRefactor.ps1'))

Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine

$script:xlr8r = [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
function Remove-Lie {
    <#
    .SYNOPSIS
        sdf
    .EXAMPLE
        $xlr8r::Remove( )
    #>
    param(
        # type kind. later remove ky key sintead.
        [Parameter(Mandatory, Position = 0)]$TypeInfo
    )

    # $script:xlr8r ??= [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
    $script:xlr8r::Remove($TypeInfo)
    'Removed Lie: {0}. Remaining Lies: {1}' -f @(
        $Name
        $script:xlr8r.Keys.count
    )| Write-Information -infa 'continue'
}
function New-Lie {
    <#
    .SYNOPSIS
        TypeInfo lies, type accellerator , lies.
    .EXAMPLE
        $xlr8r::Add( 'Lie', ([System.Collections.Generic.List`1]) )
    #>
    param(
        #New alias
        [Parameter(Mandatory, Position = 0)]$Name,
        # TypeInfo instance
        [Parameter(Mandatory, Position = 1)]$TypeInfo
    )

    # throw ('Lie alreads exists! {0} => {1}' -f @(
    #         $Name
    #         ($Name -as 'type')
    #     ))

    write-warning '80% implemented, to fininsh.'

    '{0} isType: {1}, asType: {2}' -f @(
        $TypeInfo
        $TypeInfo -is 'type'
        $TypeInfo -as 'type'
    ) | Write-Information -infa 'continue'

    # $script:xlr8r ??= [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
    $script:xlr8r::Add($Name, $TypeInfo)
    'New Lie: {0} => {1}' -f @(
        $Name
        $TypeInfo
    ) | Write-Information -infa 'continue'
}

$xlr8r::Add( 'Lie', ([System.Collections.Generic.IList`1]) )
# New-Lie -name 'Lie' -TypeInfo [System.Collections.Generic.iList`1]
# New-Lie -name 'Lie' -TypeInfo [System.Collections.Generic.List`1]


Import-Module 'Pansies'
[PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'

function nin.findNewestItem {
    #if I rewrite it to steppable, maybe can stream items with colors?
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,
        [switch]$PassThru,

        [Alias('ext')]
        [ArgumentCompletions('log', 'xlsx')]
        [string]$ItemType
    )
    process {
        if ($tempType) { throw 'NYI' }
        # $files = @(
        @(
            & 'fd' @(
                # '-e', 'log',
                '-e', 'xlsx'
                '--changed-within', '35minutes', '--search-path', ( $Path )
            ) | ForEach-Object {
                $_ | Write-Information -infa 'continue'
                $_
            }
        )
        | Get-Item
        | Sort-Object LastWriteTIme -des
        | Select-Object -First 1
        | Invoke-Item

    }
}

# important, the other syntax for UTF8 defaults to UTF8+BOM which
# breaks piping, like piping returning from FZF contains a BOM
# which actually causes a full exception when it's piped to Get-Item
#
# test:  Is the default Ctor the non-bom one?


function enumerateSupportedEventNames {
    <#
    .SYNOPSIS
        get events from the objects metadata
    .example
        Ps7>
        Get-Process | enumerateSupportedEventNames -asText
        hr
        $fileWatcher = [System.IO.FileSystemWatcher]::new()
        $fileWatcher | enumerateSupportedEventNames -asText

    # output

    ----------------------------------------------------
        PossibleEvents from a [System.Diagnostics.Process]:
        • 'Disposed'
        • 'ErrorDataReceived'
        • 'Exited'
        • 'OutputDataReceived'
    ----------------------------------------------------
        PossibleEvents from a [System.IO.FileSystemWatcher]:
        • 'Changed'
        • 'Created'
        • 'Deleted'
        • 'Disposed'
        • 'Error'
        • 'Renamed'

    #>
    [Alias('prof.iterEvents')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, position = 0)]
        [object]$InputObject,
        # pretty print
        [switch]$AsText
    )
    end {
        $originalObject = $InputObject
        $origTypeName = $originalObject.GetType().FullName
        [Collections.Generic.List[Object]]$eventNames = $originalObject | Sort-Object { $_.GetType().FullName } -Unique
        | Get-Member -MemberType Event | ForEach-Object Name | Sort-Object -Unique
        if (-not $AsText) {
            return $eventNames
        }
        $eventNames
        | Join-String -op "PossibleEvents from a [$(  $origTypeName )]: `n  • " -sep "`n  • " -SingleQuote
    }
}

<#
super aggresssive functions  #>
function Gs {
    <#
    .SYNOPSIS
        Git status (sugar)
    #>
    git status
}
function Gl {
    <#
    .SYNOPSIS
        Git Log (sugar)
    #>
    # [Alias('glog')] ?
    git log
}

function CountIt {
    <#
    .SYNOPSIS
        Count the number of items in the pipeline, ie: @( $x ).count
    .EXAMPLE
        ,@('a'..'e' + 0..3) | CountIt -Out-Null
        @('a'..'e' + 0..3) | CountIt -Out-Null

        # outputs
        1 items
        9 items
    #>
    # [CmdletBinding()]
    # [Alias('Len', 'Len🧛‍♀️')] # warning this breaks crrent parameter sets
    param(
        [switch]$Extra,

        # Also consume output (pipe to null)
        [switch]${Out-Null}
    )
    begin {
        [int]$totalCount = 0
        [COllections.Generic.List[Object]]$Items = @()
    }
    process { $Items.Add( $_ ) }
    end {
        if( ${out-Null}.IsPresent) {
            $items | out-null # redundant?
        } else {
            $items
        }
        $colorBG = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg = $PSStyle.Foreground.FromRgb('#e5701c')
        $colorFg = $PSStyle.Foreground.FromRgb('#f2962d')
        @(
            $ColorFg
            $ColorBg
            '{0} items' -f @(
                $items.Count
            )
            $PSStyle.Reset
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
New-Alias 'Len🧛' -value CountIt
New-Alias 'Len' -value CountIt
function fAll {
    <#
    .SYNOPSIS
        sugar for " | * fl -force" to view extra properties
    .EXAMPLE
        Ps> $this | Fall
    .EXAMPLE
        Ps> $global:error | select -first 3 | Fall

     #>
    process {
        $_ | Format-List * -Force
    }
}

function prof.Html.Table.FromHash {
    <#
    .SYNOPSIS
        render html table
    .example
        $selectEnvVarKeys = 'TMP', 'TEMP', 'windir'
        $selectKeysOnlyHash = @{}
        ls env: | ?{
            $_.Name -in @($selectEnvVarKeys)
        } | %{ $selectKeysOnlyHash[$_.Name] = $_.Value}

        prof.Html.Table.FromHash $SelectKeysOnlyHash

        #>
    param(
        [ValidateNotNullOrEmpty()]
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

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

