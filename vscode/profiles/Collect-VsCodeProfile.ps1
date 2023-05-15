$Config = @{
    AppRoot      = Get-Item $PSScriptRoot
    Profile_Root = Join-Path $Env:AppData 'Code/User' | Get-Item -ea 'stop'
}
$Config += @{
    Export_DotfilesRoot = Join-Path $Config.AppRoot 'desktop-main'
    Profile_SubProfiles = Join-Path $Config.Profile_Root 'profiles'
}
function RenderInternalScriptExtent {
    [Alias(
        '.Render.InternalScriptExtent'
        # '.Render.smal.InternalScriptExtent',
    )]
    [OutputType('System.String'
        # 'AnsiEscapeString'
    )]
    # some metadata attribute: ansi color output is optional
    [CmdletBinding()]
    param(
        [Alias('Position')]
        [Parameter(
            Mandatory, ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        # supports [IScriptExtent], is a pInternalScriptExtent]
        # [System.Management.Automation.Language.InternalScriptExtent]$InputObject
        # [System.Management.Automation.Language.ScriptExtent]
        [object]$InputObject
    )

    if ($InputObject -is [System.Management.Automation.Language.IScriptExtent]) {
        $Target = $InputObject
    }
    elseif ( $InputObject.Position -is [System.Management.Automation.Language.IScriptExtent]) {
        $Target = $InputObject.Position
    }
    else {
        throw "Unhandled type: $($InputObject.GetType().Name)"
    }
    # $ScriptExtent
    # 'from:'
    # $info.FuncionName
    $msg = @(
        @(
            $InputObject.StartScriptLineNumber
            '..'
            $InputObject.EndScriptLineNumber
        ) | Join-String -op "${fg:gray60}" -os $PSStyle.Reset
        $LogMessage
    ) -join ' '

    $msg | Write-Host -fg 'yellow'
    $null = 0
}

function write.TraceLocation {
    <#
    .SYNOPSIS
        writes info, by inspecting call stack frame
    .NOTES
        for details see:
            $s.InvocationInfo [sma.InvocationInfo]
            $s.Position [InternalScriptExtent]
    #>
    # [Alias('write.Trace.Enter')]
    # todo: To be refactored as: '.Render.CallStackFrame
    # [Alias('.Render.CallStackFrame')]
    [CmdletBinding()]
    param(
        # optional
        [Alias('Prefix')]
        [Parameter(Mandatory, position = 0)]
        [ArgumentCompletions(
            "'Enter'", "'Exit'"
        )]
        [string]$Mode,

        [Alias('Message', 'Text')]
        [Parameter(Position = 1)][string]$LogMessage,

        [switch]$Detailed
    )

    switch ($Mode) {
        'Enter' { $prefix = '::enter:' }
        'Exit' { $prefix = '::exit :' }
        default { }
    }
    $callStack = Get-PSCallStack
    $targetFrame = $callStack[1]
    $info = @{}

    $info.DocsString = @'
make sure to try nested types
    $s.Position => extent?

    [IScriptPosition]
        $s.Position.StartScriptPosition
    [IScriptPosition]
        $s.Position.EndScriptPosition
'@

    # ex: Collect-VsCodeProfile.ps1: line 42
    $info.shortNameAndLineNumber = $targetFrame.GetScriptLocation()

    # ex: __collect.VsCode.Config
    $info.FuncionName = $targetFrame.Command
    # ex: args, input, MyInvocation, PSBoundParameters, PSCommandPath, PSScriptRoot
    $info.frameVariableNames = $targetFrame.GetFrameVariables().Keys
    | Sort-Object -Unique | Join-String -sep ', '

    # ex: H:\data\2023\dotfiles.2023\vscode\profiles\Collect-VsCodeProfile.ps1
    $info.fullName = $targetFrame.Position.StartScriptPosition.File

    # current line only
    # ex: "     write.TraceLocation 'Enter'"
    $info.StartScriptLineString = $targetFrame.Position.StartScriptPosition.Line
    # ex: 42
    $info.StartScriptLineNumber = $targetFrame.Position.StartScriptPosition.LineNumber
    $info.EndScriptLineNumber = $targetFrame.Position.EndScriptPosition.LineNumber

    # ex: entire script contents
    $info.ScriptContentsString = $targetFrame.Position.StartScriptPosition.GetFullScript()


    $info.frameCommand = $targetFrame.Command


    # System.Management.Automation.Language.InternalScriptExtent


    $info.RenderFrameVariableSummary = $targetFrame.GetFrameVariables().Values
    # | Select-Object Name, Value
    | Join-String {
        "{0}`n   is {1}`n   value is {2}" -f @(
            $_.Name
            $_.Value.GetType() | Format-ShortTypeName
            $_.value
        ) } -sep "`n"

    # $info.GetEnumerator() | ForEach-Object {
    #     Hr -fg magenta
    #     $_.key
    #     $_.value
    # }

    RenderInternalScriptExtent $targetFrame

    if ( -not $Detailed) {

        $Message = @(
            $Prefix
            'location:'
            $info.FuncionName
            'from:'
            @(
                $info.StartScriptLineNumber
                '..'
                $info.EndScriptLineNumber
            ) | Join-String -op "${fg:gray60}" -os $PSStyle.Reset
            $LogMessage
        ) -join ' '
        $Message | Write-Host -fg 'blue'
        return
    }

    $Message = @(
        $Prefix
        'location:'
        $LogMessage
        $info.RenderFrameVariableSummary
    ) -join ' '
    Write-Warning 'no template for detailed yet '
    $Message | Write-Host -fg 'blue'

}
# $Config | Format-Table -auto -Wrap
# $Config | Format-List
# return
function __collect.VsCode.Config {
    write.TraceLocation 'Enter'
    '::enter: __collect.VsCode.Config' | Write-Host -fg green
    $P = @{
        Profile_SubProfiles = Join-Path $Config.Profile_Root 'profiles'
    }
    '::exit : __collect.VsCode.Config' | Write-Host -fg green
    write.TraceLocation 'Exit'
}

function __dotfiles.RenderHashtable {
    param(
        [Alias('Hash', 'InputHash')]
        [Parameter(Position = 0, Mandatory)]
        [hashtable]$InputObject,

        [Parameter(Position = 1, Mandatory)]
        [ArgumentCompletions(
            'Default',
            'SemanticPath'
        )]
        [string]$OutputMode,

        [Alias('Sort')]
        [Parameter(Position = 2)]
        [ValidateSet('Key', 'Value')]
        [string]$SortByKey
    )
    if ($SortByKey) {
        $sortSplat = @{
            InputHash = $InputObject
            SortBy    = $SortByKey
        }
        $InputObject = Ninmonkey.Console\Sort-Hashtable @sortSplat
        Write-Warning 'sort not working in all cases, maybe using implicit case casensitive?'
    }

    Hr -fg orange
    label 'OutputMode' $OutputMode
    switch ( $OutputMode ) {
        'Default' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                "{0}`n{1}" -f @(
                    $_.Key
                    $_.Value
                ) }
        }
        'SemanticPath' {
            $C = @{}
            $C.Fg_Dim = "${fg:gray30}"
            $C.Fg_Dim = "${fg:gray15}"
            $C.Fg = "${fg:gray65}"
            $C.Fg_Em = "${fg:gray85}"
            $C.Fg_Max = "${fg:gray100}"
            $C.Fg_Min = "${fg:gray0}"
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                $segs = $_.Value -split '\\'
                $render_pathColor = @(
                    $body = $segs | Select-Object -SkipLast 2
                    | Join-String -sep '/'

                    $tail = $segs | Select-Object -Last 2
                    | Join-String -sep '/'

                    $C.Fg_Dim
                    $Body
                    $C.Fg_Em
                    '/'
                    $Tail
                    $PSStyle.Reset
                ) | Join-String

                $render_key = @(
                    $C.Fg_Max
                    $_.Key
                    $PSStyle.Reset
                ) | Join-String

                # '{0}{1}' -f @(
                "{0}`n{1}" -f @(
                    $render_key
                    $render_pathColor) }
        }
        'Default2' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                '{0} : {1}' -f @(
                    $_.Key
                    $_.Value ) }
        }
        default {
            throw "UnhandledMode: $OutputMode"
        }

    }
    Hr
}

__dotfiles.RenderHashtable -InputObject $Config -OutputMode SemanticPath -SortByKey Key
__collect.VsCode.Config