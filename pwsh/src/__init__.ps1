# $PSDefaultparameterValues['ModuleBuilder\Build-Module:verbose'] = $true # fully resolve command name never seems to workmodule scoped never seems to work
$PSDefaultParameterValues['Build-Module:verbose'] = $true
$VerbosePreference = 'silentlyContinue'

Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord

Write-Warning 'move aws completer to typewriter'
Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    <#
    .SYNOPSIS
        minimal aws autocompleter
    .link
        https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
    #>
    param($commandName, $wordToComplete, $cursorPosition)
    $env:COMP_LINE = $wordToComplete
    if ($env:COMP_LINE.Length -lt $cursorPosition) {
        $env:COMP_LINE = $env:COMP_LINE + ' '
    }
    $env:COMP_POINT = $cursorPosition
    aws_completer.exe | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
    Remove-Item Env:\COMP_LINE
    Remove-Item Env:\COMP_POINT
}



function Add-StreamingLogs {

    <#
    .SYNOPSIS
    pipe log files, add-content -passthru does not run until the end

    .DESCRIPTION

    using (get|add)-content with a piped log file can end up waiting
    until you end otherwise cancel the pipeline
    .EXAMPLE
    gi |
    .NOTES
    General notes
    .link
        https://devblogs.microsoft.com/powershell-community/mastering-the-steppable-pipeline/
    #>
    [CmdletBinding()]
    param(
        # if directly piped top
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline )]
        [string[]]$InputText,

        # else by filename
        [Parameter()]
        [string]$LogFilePath

        # [switch]$WithoutPassThru

    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()

    }
    process {
        # $if($WithoutPassThru.IsPresent) {
        #     $usingPassthru = -not $WinthoutPassThru
        #     $false
        # }
        # else {
            # $WithoutPassThru = $true
        # }
        # '=> ' | Out-Host
        foreach ($Line in $InputText) {
            if($null -eq $line) { continue }
            # $line
            # [Console]::Write('.') #
            # '.' | Out-Host
            # $Line
            # sleep -ms 100
            $Line | Add-Content 'temp:\appending.log' -PassThru
             #-PassThru: #$( -not $WithoutPassThru )

            # $Line | Add-Content './inner.log' #-PassThru
            # $Line
        }
        # steppable pipeline pipe text


        # if ($LogFilePath) {
        #     $InputText | Add-Content -Path $LogFilePath -PassThru
        # }
        # else {
        #     $InputText
        # }
    }
    end {
        'done' | Write-Host -fg green

    }
}

function pickOne {
    [CmdletBinding(positionalbinding = $false)]
    param(
        # input object[s] to select, for fzf
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject

    )
    begin {
        $BinFzf = Get-Command fzf -ea stop -CommandType application
        [Collections.Generic.List[Objedct]]$items = @()
    }
    process {
        write-warning 'wait, feature drift. one func does capture. other gets newest by type.'
        $items.AddRange($InputObject)
    }
    end {
        [Collections.Generic.List[Object]]$argsFzf = @(
            '--ansi'
            # '-m'
        )
        $query = $global:LastPick = $items
        | & $BinFzf @argsFzf

        $query | Select-Object -First 1
        #| Select-Object -First 1
    }
}

function GoClip {
    [Alias('prof.GoClippy')]
    [CmdletBinding()]
    param()
    $script:LastClip = Get-Clipboard | Get-Item -ea Stop
    Goto $script:LastClip
    'jump => {0}' -f @(
        $script:LastClip | Join-String -DoubleQuote
    )
}
function aws.abbrKeyName {
    [OutputType('System.String')]
    param(
        # strings to truncate, from the pipeline
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$KeyName,
        # max char length/count
        [int]$MaxCols = 14
    )
    process {
        if ($KeyName.Length -gt $MaxCols) {
            return $KeyName.Substring(0, $MaxCols)
        }
        return $KeyName
    }
}

Write-Warning 'finish: nin.Help.Command.OutMarkdown'
function nin.Help.Command.OutMarkdown {
    <#
    .SYNOPSIS
        export docs when help -online fails
    .notes

        future items:
            - [ ] make a command listing index page / TOC
            - [ ] markdown AST or markdown to HTML
            - [ ] make related links to html page work
            - [ ] dynamic compile using transpiler ?
    #>
    # [Alias()]
    [CmdletBinding()]
    param(
        # list of commands to generate docs for
        [Alias('ResolvedCommand', 'ReferencedCommand', 'Name')] # todo arg tranform type to CmdInfo
        [Parameter(Mandatory, Position = 0
            # , ValueFromPipeline, ValueFromPipelineByPropertyName
        )]
        [object[]]$InputObject
    )
    begin {
        "Finish Help command markdown: $PSCommandPath" | Write-Warning
        $tmpRoot = Get-Item .
        $ManCfg = @{
            Root   = Get-Item .
            Export = @{
                Root = Get-Item 'h:\temp\manpage' -ea stop
            }
        }
        function __write.markdown.fromCmdHelp {
            param(
                $Command,
                $Namespace,

                $PrintToHost
            )
            $destRoot = Join-Path $ManCfg.Export.Root | Get-Item -ea stop

            New-Item -Path $DestRoot -ItemType Directory -Force -ea ignore -Name $Namespace
            $CmdPathTemplate = '{0}/{1}-{2}.md' # Namespace/Noun-ActualCmd
            $CmdPathTemplate = '{0}/{2}.md' # Namespace/Command

            $finalPath = Join-Path $destRoot ($CmdPathTemplate -f @(
                    $Namespace
                    $Command
                ))

            $template
            | Set-Content -Path $finalPath -Force -ea 'continue' -PassThru:$printToHost

            $finalPath | Join-String -op 'Wrote: "{0}"' -sep "`n" | Join-String -sep "`n" | Write-Verbose
            $finalPath | Join-String -op 'Wrote: "{0}"' -sep "`n" | Join-String -sep "`n" | Write-Information -infa 'Continue'
        }
    }
    process {
        # gcm -m AWSPowerShellLambdaTemplate
        foreach ($cur in $InputObject) {
            $cur | Join-String 'Exporting Command: {0}' -SingleQuote -prop Name
        }
        return

        # foreach($CmdName in $InputObject) {
        # # wait-debugger
        #         $CmdName | join-string 'Exporting Command: {0}' -SingleQuote -prop Name
        #         | write-verbose
        # }
    }
    end {
        # Get-ChildItem -Path $ManCfg.Export.Root -file *md
        Get-ChildItem -Path $ManCfg.Export.Root -File
        | Sort-Object -Property ModuleName, Name
        | Join-String -format '- <file:///{0}> ' -sep "`n" -op "Wrote:`n" {
            '{0} \ {1}' -f @(
                $_.ModuleName ?? "<`u{2400}>"
                $_.Name ?? "<`u{2400}>"
            )
        }
    }

}
# $_cmds = Get-Command -m AwsLambdaPSCore
# nin.Help.Command.OutMarkdown -Debug -verbose -inputobject $_cmds
function nin.PSModulePath.Clean {
    <#
    .SYNOPSIS
        -1] remove invalid paths
        -2] remove duplicate paths, preserving sort order
        -3] remove any all-whitespace values
        -4] remove obsolete import path from 2021
    .EXAMPLE
        nin.CleanPSModulePath
    #>
    [CmdletBinding()]
    param(
        # return the new value
        [switch]$PassThru
    )

    Write-Warning "todo: ensure duplicates are removed: $PSCOmmandPath"

    $records = $Env:PSMODulePath -split ([IO.Path]::PathSeparator)
    | Where-Object { $_ } # drop false and empty strings
    | Where-Object { -not [String]::IsNullOrWhiteSpace( $_ ) } # drop blank

    $records | Join-String -op "initial: `n" -FormatString "`n- {0}" | Write-Debug
    # $records | Join-String -op "`n- " -sep "`n- " -DoubleQuote | write-verbose
    # $records | Join-String -op 'Was:' | Write-Debug

    $records = $records
    | Where-Object { $_ -notmatch ([Regex]::Escape('C:\Users\cppmo_000\SkyDrive\Documents\2021')) }

    $records | Join-String -op "initial: `n" -FormatString "`n- {0}" | Write-Debug

    $finalPath = $records | Join-String -sep ([IO.Path]::PathSeparator)

    $finalPath | Join-String -op 'finalPath = ' | Write-Verbose
    if ($PassThru) {
        return $finalPath
    }
}

function nin.PSModulePath.Add {
    [CmdletBinding()]
    param(
        [ArgumentCompletions('E:\PSModulePath.2023.root')]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$LiteralPath,
        [switch]$RequireExist,

        # prefix rather than add to end?
        [Alias('ToFront')]
        [switch]$AddToFront
        # [string[]]$GroupName
    )

    $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
    | Join-String -op 'start: ' | Write-Debug

    Write-Warning 'todo: ensure duplicates are removed'

    foreach ($curPath in $LiteralPath) {
        $Item = $curPath
        if ($RequireExists) {
            $Item = Get-Item -ea stop $curPath
        }
        $records = $Env:PSModulePath -split ([IO.Path]::PathSeparator)
        if ($records -contains $Item) { continue }

        Join-String -inp $Item -FormatString 'Adding Path: <{0}>' | Write-Verbose

        if ($AddToFront) {
            $Env:PSModulePath = @(
                $Item
                $Env:PSModulePath
            ) | Join-String -sep ([IO.Path]::PathSeparator)
        }
        else {
            $Env:PSModulePath = @(
                $Env:PSModulePath
                $Item
            ) | Join-String -sep ([IO.Path]::PathSeparator)
        }

        # Join-String -inp $Item 'adding: "{0}" to $PSModulePath'

    }
    $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
    | Join-String -op 'end  : ' | Write-Debug
}
function nin.PSModulePath.AddNamedGroup {
    <#
    .synopsis
        either add a group of custom PSModulePaths by GrupName else full name
    .example
        nin.PSModulePath.AddNamedGroup -GroupName AWS, JumpCloud   -verbose -debug4
    .example

    .example
        nin.PSModulePath.Clean
        nin.PSModulePath.AddNamedGroup -GroupName AWS, JumpCloud   -verbose -debug
        nin.PSModulePath.Add -verbose -debug -RequireExist -LiteralPath @(
            'E:\PSModulePath.2023.root\Main'
            'H:\data\2023\pwsh\PsModules\ExcelAnt\Output'
        )
    #>
    [CmdletBinding(DefaultParameterSetName = 'GroupName')]
    param(
        [ArgumentCompletions('AWS', 'Disabled', 'JumpCloud', 'Main')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'GroupName')]
        [string[]]$GroupName,

        [Alias('PSPath', 'Path', 'Name')]
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName)]
        $LiteralPath
    )
    $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
    | Join-String -op 'Was:' | Write-Debug

    switch ( $PSCmdlet.ParameterSetName ) {
        'GroupName' {
            foreach ($item in $GroupName) {
                $mappedGroupPath = Join-Path 'E:\PSModulePath.2023.root' $Item
                nin.PSModulePath.Add -LiteralPath $mappedGroupPath -RequireExist -verbose -debug
            }
            continue
        }

        'LiteralPath' {
            nin.PSModulePath.Add -LiteralPath $LiteralPath -RequireExist -verbose -debug
            continue
        }
        default { throw "UnhandledSwitch ParameterSetItem: $Switch" }
    }
}

nin.PSModulePath.Clean
# nin.PSModulePath.AddNamed -GroupName AWS, JumpCloud   -verbose -debug
nin.PSModulePath.Add -verbose -debug -RequireExist -LiteralPath @(
    'E:\PSModulePath.2023.root\Main'
    'H:\data\2023\pwsh\PsModules\ExcelAnt\Output'
    'H:/data/2023/pwsh/PsModules'
)

Write-Warning 'maybe imports'
nin.PSModulePath.Add -verbose -debug -RequireExist -LiteralPath @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib'
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'
)
# 'E:\PSModulePath_base\all'
# 'E:\PSModulePath_2022'

#$Env:PSModulePath -join ([IO.Path]::PathSeparator), (gi 'E:\PSModulePath.2023.root\JumpCloud')
# nin.AddPSModulePath Main -Verbose -Debug
# nin.Ass

# # include some dev psmodule paths
# $Env:PSModulePath = @(
#     $Env:PSModulePath
#     'E:\PSModulePath.2023.root\Main'
#     'H:\data\2023\pwsh\PsModules\ExcelAnt\Output'
# ) -join ([IO.Path]::PathSeparator)

function Help.Example {
    <#
    .SYNOPSIS
        sugar for getting help, future: unify as one command
    .EXAMPLE
        gcm get-help | Help.Param showwindow, role
    #>
    $Input | Get-Help -exam
}
function Help.Online {
    <#
    .SYNOPSIS
        sugar for getting help, future: unify as one command
    .EXAMPLE
        gcm get-help | Help.Param showwindow, role
    #>
    $Obj = $Input
    try {
        $Query = Get-Command $Obj | Get-Help -Online -ea stop
        if ($Query) { return $query }
    }
    catch {
        $uri = Get-Command $Obj | ForEach-Object Module | ForEach-Object ProjectUri
        Write-Information " ↳ url: $Uri"
        if ($uri) { Start-Process '$uri' }

    }
}
function Help.Param {
    <#
    .EXAMPLE
        gcm get-help | Help.Param showwindow, role
    #>
    param( [string[]]$ParamPatterns )
    $Input | Get-Help -Param $ParamPatterns
    # foreach($x in $Input) { Get-Help -param $_ }
}

function Write-NancyCountOf {
    <#
    .SYNOPSIS
        Count the number of items in the pipeline, ie: @( $x ).count
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
        [switch]${Out-Null}
    )
    begin {
        [int]$totalCount = 0
        [COllections.Generic.List[Object]]$Items = @()
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
                    $colorFg_label, $colorBG_label
                    $CountLabel
                    # $PSStyle.Reset
                    $ColorFg_count
                    $ColorBg_count
                    $render_count
                ) -join ''
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

function aws.Gci.Templates {
    <#
    .SYNOPSIS
        quickly dump clickable filepaths to yaml, etc.
    .NOTES
        future: write urls shorter than the full filepath
        that would make screen space so, so much cleaner
        using url escapes (or even psstyle?)
    #>
    param(
        [string]$Path = '.',
        [switch]$Relative,
        [object[]]$ExtraArgs,
        [string[]]$Extensions = 'yml'
    )
    $fdArgs = @(
        $Extensions | ForEach-Object {
            '-e', $_
        }
        '--search-path'
        if (-not $Relative) { '--absolute-path' }
        '--search-path', (Get-Item $Path -ea stop)
        if ($ExtraArgs) { $ExtraArgs }
        '--color=always'
    )
    $fdArgs | Join-String -sep ' ' -op 'fd ' | Write-Information -infa 'continue'

    & 'fd' @fdArgs
}

function GoCl {
    <#
    .SYNOPSIS
    [profile] If it's an item, go to it from the clipboard
    #>
    $script:__lastGo = Get-Clipboard | Get-Item -ea stop
    Goto $script:__lastGo
    'jumped to {0}' -f @(
        $script:__lastGo | Write-Information -infa 'continue'
    )
    | Write-Information
}

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
    ) | Write-Information -infa 'continue'
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

    Write-Warning '80% implemented, to fininsh.'

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

function prof.Io2 {
    <#
    .EXAMPLE
        $now = get-date
        $d = (get-date) - $now
        $d | io | ft Name, Value, *
    #>
    param( $d )
    $d | io | Format-Table Name, Value, *
}




if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

