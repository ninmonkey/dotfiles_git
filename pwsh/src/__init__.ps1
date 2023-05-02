# $PSDefaultparameterValues['ModuleBuilder\Build-Module:verbose'] = $true # fully resolve command name never seems to workmodule scoped never seems to work

$PSDefaultParameterValues['Build-Module:verbose'] = $true
$VerbosePreference = 'silentlyContinue'

<#
custom attributes, more detailed info
    - [reflection and custom attributes](https://learn.microsoft.com/en-us/dotnet/framework/reflection-and-codedom/accessing-custom-attributes)
    - [parameter info](https://learn.microsoft.com/en-us/dotnet/api/system.reflection.parameterinfo?view=net-7.0)
    - [attr tut](https://powershell.one/powershell-internals/attributes/custom-attributes)
    - more...
        - [CSharp Advanced Attributes](https://learn.microsoft.com/en-us/dotnet/csharp/advanced-topics/reflection-and-attributes/creating-custom-attributes)
#>

Set-Alias -Name 'Json.From' -value 'ConvertFrom-Json'

Import-Module pansies
[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()

'Encoding: [Console Input/Output: {0}, {1}, $OutputEncoding: {2}]' -f @(
    # alternate:  @( [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding ) -replace 'System.Text', ''
    @(  [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding | ForEach-Object WebName )
) | Write-Verbose -Verbose

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord

Import-Module 'ugit'


# ## temp include, to move gitlogger to psmodulepath instead
# if ('quick hack, move gitlogger to path PSModules instead') {
#     $wherePath = 'H:\data\2023\pwsh'
#     $env:PSModulePath += ';{0}' -f $wherePath
#     $env:PSModulePath | Join-String -sep "`n" | Write-Debug

#     $Env:PSModulePath = @(
#         $env:PSModulePath -split ';' -notmatch ([regex]::Escape($wherePath))
#         $wherePath
#     ) | Join-String -sep ';'

#     $env:PSModulePath | Join-String -sep "`n" | Write-Debug
# }

function Export.PipeScript {
    [alias(
        'prof.Build.Pipescript',
        'bps.prof'
    )]
    param(
        [ArgumentCompletions(
            '*-*.ps',
            '*-*.ps.*',
            '*.ps.md',
            'subPath/*.ps.*',
            'subPath/*-*.ps.ps1',
            '*-*.ps.ps1'
        )]
        [Parameter(Position = 0)]
        [String[]]$InputPath,
        [switch]$All
    )
    #
    # Import-Module pipescript -MaximumVersion 0.2.2 -Scope Global -PassThru
    Import-Module pipescript -Scope Global -PassThru
    if ($All) {
        Export-Pipescript
        return
    }

    # $pattern = '*.ps.md'
    $pattern = '*.ps.*'
    Export-Pipescript -InputPath $pattern
}

# function Export.Pipe {
#     throw 'deprecated'
#     Import-Module pipescript -MaximumVersion 0.2.2 -Scope Global -PassThru
#     $pattern = '*.ps.md'
#     Export-Pipescript -InputPath $pattern
# }

'finish: nin.Help.Command.OutMarkdown: dotfiles/src/__init__.ps1'
function nin.Help.Command.OutMarkdown {
    <#
    .SYNOPSIS
        export docs when help -online fails
    .notes
        2023-04-04
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
function Code.File.Get.End {
    # jump to  bottom of file, using number outside limits
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            'G:\temp\aws_raw.log'
        )]
        [Parameter(Mandatory, position = 0)]
        [string]$PathName
    )
    $TargetFile = Get-Item -ea stop $PathName
    $renderPath = '{0}:{1}' -f @( Get-Item -ea stop $TargetFile ; 99999999; )
    & code @('--goto', $renderPath )
}

## todo: Write-Warning 'move aws completer to typewriter'
Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    <#
    .SYNOPSIS
        minimal aws autocompleter: to TYPEWRITER
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


function Join.Lines {

    # [Text.StringBuilder]::new(@(
    #     $Input
    # ))
    $Input | Join-String -sep "`n"
}


function Get-PipeNames.Prof {
    <#
    .SYNOPSIS
    list top level pipes

    .DESCRIPTION
    find top level, named pipes

    .EXAMPLE

        Pwsh> Pipes.List

    .NOTES
    A regular user will get permission errors on a lot of them, or fail on 'Get-Item' for other reasons
    try -silent
    #>
    [OutputType(
        '[System.String[]]', '[FileSystemInfo[]]'
    )]
    [Alias(
        'Pipes.List',
        'IO.Pipe.List'
    )]
    [cmdletbinding()]
    param(
        [switch]$AsObject, [switch]$Silent
    )
    if ($PassThru) {
        $getItemSplat = @{
            ErrorAction = $Silent ? 'ignore' : 'continue'
        }

        return [System.IO.Directory]::GetFiles('\\.\pipe\')
        | Get-Item @getItemSplat
    }
    return [System.IO.Directory]::GetFiles('\\.\pipe\')
}

$setAliasSplat = @{
    Name        = '.fmt.md.TableRow'
    Value       = 'join.Md.TableRow'
    Description = 'experiment with a new command namespace: ''.fmt'''
    ErrorAction = 'ignore'
}

Set-Alias @setAliasSplat

function join.Md.TableRow {
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
    # forgive my $input usage. use '_fmt_mdTableRow' instead.
    $input | Join-String -sep ' | ' -op '| ' -os ' |' { $_ ? $_ : "`u{2400}" }
}

function Write-GHRepoSummary {
    <#
    .SYNOPSIS
        summarzie GH repos, and export the newest as a markdown table
    .EXAMPLE
        Write-GHRepoSummary 'Microsoft'
    .EXAMPLE
        Write-GHRepoSummary 'ninmonkey'

    #>
    param(
        [string]$Owner
    )@(
        'name', 'desc', 'visible', 'date' | join.Md.TableRow
        '.', '.', '.', '.' | Join.Md.TableRow
        & gh repo list $Owner
        | Select-Object -First 5
        | ForEach-Object {
            $_ -split '\t' | join.Md.TableRow
        } | Join-String -sep "`n"
    ) | Join-String -sep "`n"
}


function nin.Tablify.FromText__iter0 {
    <#
    .SYNOPSIS
    takes text from the pipeline, usually a native command

    .DESCRIPTION
    Converts Output from Native Commands. Many are easy to parse columns, because they use \t delimiters

            <<to replace with future 'ConvertTo-MdTableFromStdout_toCleanup' >>

    .EXAMPLE
    An example

    .NOTES
    - [ ] currently first line is header. argument could skip that.

    # todo: steppable ?
    - [ ] Future: Support input as Objects, table from properties
    - [ ] Future: Support input as hashtables, table from key value pairs
    - [ ] check out how pipescript defines how its objects serialize, secifically to markdown files
    #>
    [Alias(
        # 'xl.Format.MdTableFromStdoutConsole',
        # 'nin.Tablify.FromText',
        'prof.nin.Tablify.FromText'
        # 'xl.Tablify.Md.FromStdout'
    )]
    [CmdletBinding(DefaultParameterSetName = 'FromPipeline')]
    param(
        # raw text piped in
        # use? [AllowNull()]
        # [AllowEmptyCollection()]
        # [AllowEmptyString()]

        [Alias('InputObject')]
        [Parameter(Mandatory, ValueFromPipeline, parameterSetName = 'FromPipeline')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'FromParam')]
        [string[]]$InputText,

        [switch]$NoHeader
    )
    begin {
        if ($NoHeader) { throw 'nyi: insert blank header, so the first record doesn''t become the header' }
        # todo: steppable ?
        [Text.StringBuilder]$StrBuild = [String]::Empty
        [Collections.Generic.List[Object]]$Lines = @()

    }
    process {
        $Lines.AddRange( @( $InputObject ))
        # [void]$StrBuild.AppendJoin($InputText, "`n")
    }
    end {

        # gh run list
        $Lines
        | ForEach-Object {
            $segments = $_ -split '\t'
            $colCount = $segments.count
            $segments | Join-String -op '| ' -os ' |' -sep ' | '
            if ($IsFirst) {
                $IsFirst = $false
                @('-' * $colCount -join '' -split '') # column row
                | Join-String -sep ' | '
            }

        } | Join-String -sep "`n"

    }
}

# 'did not import ?: {0}' -f $PSCommandPath
# | Write-Warning


# broke.nin.MdTable ( gh repo list ) # gh run list | ForEach-Object {
#     $segments = $_ -split '\t'
#     $colCount = $segments.count
#     $segments | Join-String -op '| ' -os ' |' -sep ' | '
#     if ($IsFirst) {
#         $IsFirst = $false
#         @('-' * $colCount -join '' -split '') # column row
#         | Join-String -sep ' | '
#     }

# } | Join-String -sep "`n"
function old.Get-LoadedModuleVersions {
    <#
    .SYNOPSIS
        quick dump both versions
    .EXAMPLE
        get-module | ? name -match 'pipe|git|logger'
    .description
    was
    Import-Module PipeScript, PipeWorks, HelpOut -PassThru
    | Join-String -p { '{0} = {1}' -f @( $_.Name ; $_.Version; )} -sep ', '
    #>
    [Alias('nin.PSModule.GetExactVersions')]
    [CmdletBinding()]
    param(
        [Alias('Modules')]
        [Parameter(valuefrompipeline, position = 0)]
        $InputObject
    )

    throw 'deprecated, see ExcelAnt\Format-ExcelAntExactModuleVersions.ps1'

    # if($InputObject) {
    #    $query = $InputObject | Sort-object Name
    # } else {
    #     $query = Get-Module | Sort-Object Name
    # }

    # $query
    # | Join-String -p { '{0} = {1}' -f @( $_.Name ; $_.Version; ) } -sep ",`n" -single
    # # | Join-String -p { '{0} = {1}' -f @( $_.Name ; $_.Version; ) } -sep ', ' -single

    # # $goal = 'import-module PipeScript -RequiredVersion 0.3.4'
    # # Get-Module
    # # | Sort-Object Name
    # hr

    # $query
    # | Join-String -p {
    #     'Import-Module {0} -RequiredVersion = {1}' -f @(
    #         $_.Name | Join-String -single
    #         $_.Version | Join-String -single
    #     )
    # } -sep "`n"
    # Import-Module -RequiredVersion 'sd' -Name 'sdf'
}
function prof.Get-LinuxManPage {
    <#
    .SYNOPSIS
    invokes 'man' pages from linux through WSL

    .DESCRIPTION
    if your env vars are set right
    WSL pipes ansi colors to pwsh
    which then pages it with bat or less

    it's just like the in person invoke

    .EXAMPLE
        man grep
    .EXAMPLE
        # ex: wsl --exec man uname
    .NOTES
        uses the native command 'wsl'

    #>
    [CmdletBinding()]
    [Alias('man', 'Help.Linux')]
    param(
        [ArgumentCompletions(
            'fd', 'rg', 'cat', 'ls', 'man', 'less', 'bat', 'vim', 'gvim'
        )]
        [Alias('Name', 'BaseName')]
        [Parameter(Mandatory)]
        [string[]]$Command,

        # all remaining query terms, passed as is if wanted
        [Alias('ArgsList', 'QueryRest')]
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromRemainingArguments
        )]
        [object[]]$Query,

        [switch]$WhatIf
    )

    # pipeline nyi
    $Command
    | Join-String -f '=> man "{0}"'
    | Write-Information -infa 'Continue'

    $query ?? ''
    | Join-String -f '=> query: "{0}"'
    | Write-Information -infa 'Continue'

    if ($WhatIf) { return }

    # ex: wsl --exec man uname
    & 'wsl' @(
        '--exec'
        'man'
        $Command
    )
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
            if ($null -eq $line) { continue }
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
        Write-Warning 'wait, feature drift. one func does capture. other gets newest by type.'
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
nin.PSModulePath.Add -verbose -debug:$false -RequireExist -LiteralPath @(
    'E:/PSModulePath.2023.root\Main'
    'H:/data/2023/pwsh/PsModules/ExcelAnt/Output'
    'H:/data/2023/pwsh/PsModules/TypeWriter/Build'
    'H:/data/2023/pwsh/PsModules'
)


nin.PSModulePath.Add -verbose -debug:$false -RequireExist -LiteralPath @(
    'C:/Users/cppmo_000/SkyDrive/Documents/2022/client_BDG/self/bdg_lib'
    'C:/Users/cppmo_000/SkyDrive/Documents/2021/powershell/My_Github'
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
    [Alias('Ho')]
    param()
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
function Collect.Distinct {
    <#
    .SYNOPSIS

    .DESCRIPTION
    Long description

    .EXAMPLE

        get-aduser *
        | CollectUnique CompanyName
        | Join-string -sep ', '

        where **all** values are output without filter
        but only distinct records are saved.

    .NOTES
    General notes
    #>
    throw 'nyi'
}
function Help.Param {
    <#
    .SYNOPSIS
        directly wrap 'Get-Help -Parameter [names[]]'
    .EXAMPLE
        gcm get-help | Help.Param showwindow, role
    .example
        # compare with
            gcm help | get-help -Parameter shoWwindow
            gcm get-help | get-help -Parameter shoWwindow

        # json info is simple
            gcm help | One | to->Json -Depth 3

    types:
        gcm 'gcm' | get-help -Parameter *
            [PSCustomObject] as [MamlCommandHelpInfo#parameter]

    .NOTES
    future:
    - [ ] no errors. if no parameters, show all
    - [ ] throttle by unique values

    notes:

        MamlCommandHelpInfo#parameter
    #>
    param(
        [string[]]$ParamPatterns,


        # Behavior changes like when using
        #   'Get-Help' verses 'Help'
        # ie: it should page better
        [switch]$UsingDefaultPager
    )
    if ($UsingDefaultPager ) {
        $Input | help $ParamPatterns
        return

    }

    $Input | Get-Help -Param $ParamPatterns
    # foreach($x in $Input) { Get-Help -param $_ }
}

function Regex.SplitOn {
    <#
    .SYNOPSIS
        making -split easier to use in the pipeline
    #>
    [CmdletBinding()]
   param(
     [ArgumentCompletions("'\r?\n'")]
     [Parameter(Mandatory, position=0)]$SplitRegex,

     [Parameter(ValueFromPipeline)][string]$InputObject
   )
   process { $InputObject -split $SplitRegex }
}
function Regex.ReplaceOn {
    <#
    .SYNOPSIS
        making -replace easier to use in the pipeline
    .NOTES
        ensure proper support with script block syntax
    .EXAMPLE
        'afds' | Regex.ReplaceOn -Regex 'fd' -ReplaceWith { "${fg:#70788b}", $_, "${fg:clear}" -join "" }
    #>
    [CmdletBinding()]
   param(
     [ArgumentCompletions("'\r?\n'")]
     [Parameter(Mandatory, position=0)]$Regex,

     [ArgumentCompletions(
        "'\r?\n'",
        # '{ "${fg:red}", $_, "${fg:clear}" -join "" }',
        '{ "${fg:#70788b}", $_, "${fg:clear}" -join "" }',
        '{ @( $PSStyle.Foreground.FromRgb(''aeae23''); $_; $PSStyle.Reset ) | Join-String -sep '''' }'
     )]
     [Parameter(Mandatory, position=0)]$ReplaceWith,

     [Parameter(ValueFromPipeline)][string]$InputObject
   )
   begin {

   }
   process {
      $InputObject -replace $Regex, $ReplaceWith
    }
}
function Regex.JoinOn {
    <#
    .SYNOPSIS
        making -Join easier to use in the pipeline

    #>
    [CmdletBinding()]
   param(

    [Alias('-Sep')]
     [ArgumentCompletions(
        '"`n"',
        "','",
        "' | '",
        '"`n - "',
        '( hr 1 )'
        )]
     [Parameter(Mandatory, position=0)]$JoinText,

     [Parameter(ValueFromPipeline)][string]$InputObject
   )
   begin {

   }
   process {
      $InputObject -join $JoinText

    }
}

function Select-NameIsh {
    <#
    .SYNOPSIS
        Select propert-ish categories, wildcard searching for frequent kinds
    .EXAMPLE
        gi . | NameIsh Dates -IgnoreEmpty -SortFinalResult
    .EXAMPLE
        gi . | NameIsh Names|fl
        gi . | NameIsh Names -IncludeEmptyProperties |fl
    #>
    [Alias('NameIsh')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, position = 0)]
        [ArgumentCompletions(
            'Dates', 'Times',
            'Names', 'Employee', 'Company', 'Locations', 'Numbers',
            'IsA', 'HasA',
            'Type'
        )]
        [string[]]$Kinds,

        [Parameter(Mandatory, ValueFromPipeline)]$InputObject,


        # to be appended to kinds already filtered by $Kinds.
        # useful because you may not want '*id*' as a wildcard to be too aggressive
        # todo: dynamically auto gen based on hashtable declaration
        [ArgumentCompletions(
            '*id*', '*num*', '*co*', '*emp*'
        )]
        [string[]]$ExtraKinds,

        [Alias('IncludeEmptyProperties')][Parameter()]
        [switch]$KeepEmptyProperties,

        # is there any reason to?
        [switch]$WithoutUsingUnique,

        # sugar sort on property names
        [switch]$SortFinalResult

    )
    begin {
        $PropList = @{
            Names     = '*name*', '*user*', 'email', 'mail', 'author', '*author*'
            Employee  = '*employee*', '*emp*id*', '*emp*num*'
            Dates     = '*date*', '*time*', '*last*modif*', '*last*write*'
            Type      = '*typename*', '*type*', '*Type'
            Script    = '*Declaring*', '*method*', '*Declared*'
            Generic   = '*generic*', 'IsGeneric*', '*Interface*'
            IsA       = 'Is*'
            HasA      = 'HasA*', 'Has*'
            Bool      = '*True*', '*False*'
            Attribute = '*attr*', '*attribute*'
            File = '*file*', '*name*', '*extension*', '*path*', '*directory*', '*folder*'
            Path      = '*Path*', 'FullName', 'Name'
            Company   = 'co', '*company*'
            Locations = '*zip*', '*state*', '*location*', '*city*', '*address*', '*email*', 'addr', '*phone*', '*cell*'
            Numbers   = 'id', '*num*', '*identifier*', '*identity*', '*GUID*'
        }

        [Collections.Generic.List[Object]]$Names = @()

        foreach ($Key in $Kinds) {
            if ($key -notin $PropList.Keys) {
                throw "Missing Defined NameIsh Group Key Name: '$key'"
            }
            $PropNameList = $PropList.$Key
            $Names.AddRange( $PropNameList )
        }
        if ($ExtraKinds) {
            $Names.AddRange(@( $ExtraKinds ))
        }

        $Names | Join-String -sep ', ' -single -op 'AllNames: '
        | Write-Debug

        if (-not $WithoutUsingUnique) {
            $Names = $Names | Sort-Object -Unique
        }
        $Names | Join-String -sep ', ' -single -op 'IncludeNames: '
        | Write-Verbose

        if ($IgnoreEmpty) {
            Write-Warning 'IgnoreEmpty: NYI'
        }
    }
    process {
        $query_splat = @{
            Property    = $Names
            ErrorAction = 'ignore'
        }
        $query = $InputObject | Select-Object @query_splat
        if ($KeepEmptyProperties) {
            return $query
        }

        [string[]]$emptyPropNames = $query.PSObject.Properties
            | Where-Object { [string]::IsNullOrWhiteSpace( $_.Value ) }
            | ForEach-Object Name

        $emptyPropNames | Join-String -op 'empty: ' -sep ', ' -DoubleQuote  | write-debug

        $dropEmpty_splat = @{
            ErrorAction     = 'ignore'
            ExcludeProperty = $emptyPropNames
        }
        return $query | Select-Object @dropEmpty_splat
    }
    end {
        if ($SortFinalResult) {
            'nyi: becauseSortFinalResult must occur after select-object is finished, else, cant know what properties the wildcards will add'
            | Write-Warning
        }
    }
}

function Write-NancyCountOf {
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



$base = Get-Item $PSScriptRoot
. (Get-Item -ea 'continue' (Join-Path $Base 'Build-ProfileCustomMembers.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'Invoke-MinimalInit.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'autoloadNow_butRefactor.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'autoload_forDeveloperTools.ps1'))

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
    'AFAIK api doesn''t expose ability to remove?'
    throw 'does not remove, is internally cached, jborean''s patch might have fixed that, or at least shows whether it''s a new type'
    # $script:xlr8r ??= [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
    $script:xlr8r::Remove($TypeInfo)
    'Removed Lie: {0}. Remaining Lies: {1}' -f @(
        $Name
        $script:xlr8r.Keys.count
    ) | Write-Information -infa 'continue'
}


function __normalize.HexString {
    <#
    .SYNOPSIS
    normalize hexstrings to always include a hash prefix

    .EXAMPLE
    PS>
    '#345', '###324', '123'
        | __normalize.HexString
        | Should -beExactly @('#345', '#324', '#123' )
    .NOTES
        currently doesn't care how many digits, or which characters are involved
        future:

    validateMustMatchOneRegex:
        '#?[\da-fA-F]{6}',
        '#?[\da-fA-F]{8}'
        '#?[\da-fA-F]{2,3}' # css allows:


    #>
    param(
        [Alias('Text', 'Hex', 'HexColor')]
        [Parameter(Mandatory, Position = 0)]
        [string]$InputHexString
    )
    process {
        $InputHexString -replace '^#+', '' | Join-String -op '#'
    }
}


function __saveColor__renderColorName {
    [Alias('.fmt.color.renderHexName')]
    [CmdletBinding()]
    param(
        [Parameter()]
        $Name = 'noName',

        [Parameter(Mandatory)]
        $HexColor
    )
    $cleanStr = $HexColor -replace '^#', ''
    if ($cleanStr.Length -notin @(6, 8)) {
        throw "Unexpected color, expects 6/8 digits: '$HexColor'"
    }
    $HexStr = '#{0}' -f @(
        $cleanStr
    )

    $renderColorPair = @{
        OutputPrefix = $PSStyle.Foreground.FromRgb($HexStr)
        OutputSuffix = $PSStyle.Reset
    }

    '{0} = #{1}' -f @(
        $Name
        $HexColor
    ) | Join-String @renderColorPair
    # | Write-Information -infa 'continue'
}
function GetColor {
    <#
    .EXAMPLE
        # Renders color values
        PS> GetColor -ListAll

            blue = ##234991
            blue.dim = #3c77d3
            green.dim = #73b254
            dark.teal = #2a5153
            Name = ##73b254
            5 items
    .EXAMPLE
        # as exportable json
        PS> GetColor -Json

        {   "blue":      "#234991",
            "blue.dim":  "3c77d3",
            "green.dim": "73b254",
            "dark.teal": "2a5153",
            "Name":      "#73b254" }
    #>
    [CmdletBinding(DefaultParameterSetName = 'GetColor')]
    param(
        # autocomplete known colors
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0 , parameterSetName = 'GetColor')]
        [string]$ColorLabel,

        [Parameter(Mandatory, parameterSetName = 'ListOnly')]
        [switch]$ListAll,
        [switch]$Loose,

        [Parameter(parameterSetName = 'JsonOnly')]
        [switch]$Json
    )


    $script:__newColorState ??= @{}
    $state = $script:__newColorState

    switch ($PSCmdlet.ParameterSetName) {
        'JsonOnly' {
            if ($Json) {
                return $State | ConvertTo-Json -Depth 2
            }
        }
        'ListOnly' {
            $state.Keys | Join-String -sep ', '
            | Join-String -op ($state.keys.count | Join-String -f 'Colors: {0} = ')
            | Write-Verbose

            $state.GetEnumerator()
            | CountOf 6>&1 # optional
            | ForEach-Object {
                '{0} => {1}' -f @(
                    $_.key
                    $_.Value
                )
            } | Join-String -sep "`n" | Write-Verbose

            $state.GEtEnumerator()
            | CountOf
            | ForEach-Object {
                __saveColor__renderColorName -Name $_.key -HexColor $_.Value
            }
            return
        }
        default { }
    }
    if ($State.ContainsKey($ColorLabel)) {
        return $state[$ColorLabel]
    }
    else {
        if (-not $Loose) {
            # else soft error, try partial match, if  match is exactly one then use it.
            throw ('Color not found! Expected: {0}' -f @(
                    $state.keys -join ', '
                ))
        }
        # 'loose'
        $key? = $State.Keys -match $ColorLabel | Select-Object -First 1
        if ($Key?) {
            return $state[ $Key? ]
        }

    }
    throw 'Failed to find loose color keys'

}

function __validate.HexString {
    <#
    .SYNOPSIS
        assert a string is as close to a valid hex str with variations
    .EXAMPLE
    PS>
        '2141j14', '222323', '#12341234', '#12345'
            | __validate.HexString
            | Should -BeExactly @($false, $true, $true, $false)
    #>
    [Alias(
        '__assert.valid.HexString',
        'HexString.ParseExact'
    )]
    [CmdletBinding()]
    param(
        [Alias('HexString')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $InputText
    )
    begin {
        $Config = @{
            AllowedLengths = 6, 8 # 2, 3
            AlwaysAssert   = $false
        }
        if ($PSCmdlet.MyInvocation.MyCommand.Name -match 'assert') {
            $Config.AlwaysAssert = $True
        }
    }
    process {



        $Raw = $InputText
        $WithoutHash = $Raw -replace '#', ''
        $Regex = @{
            AllowedWord   = '^#?[\d+a-fA-F]+$'
            AllowedDigits = '^[\d+a-fA-F]+$'
        }
        $ValidLength = $WithoutHash.Length -in @(6, 8)
        $cases = @(
            $ValidLength
            $Raw -match $Regex.AllowedWord
            $WithoutHash -match $Regex.AllowedDigits
            $WithoutHash -match $Regex.AllowedWord
        )
        $anyFalse = (@($cases) -eq $false).count -gt 0

        if ($Config.AlwaysAssert) {
            throw ('AssertIsValidHexString: Failed! "{0}"' -f @(
                    $InputText
                ))
        }
        return -not $AnyFalse
    }
}

function SaveColor {
    <#
    .SYNOPSIS
    Named color aliases, persists across sessions

    .EXAMPLE
    PS> SaveColor -Name 'orange.dark3' -HexColor '352b1e'
    PS> SaveColor -Name 'blue.dim' '3c77d3'

    .NOTES
    Default file location:

        Join-Path $Env:Nin_Dotfiles 'store/saved_colors.json'


    related, see also:
        __saveColor__renderColorName
        __normalize.HexString
        SaveColor
        GetColor
        ImportColor
    #>
    [Alias('NewColor')]
    [CmdletBinding()]
    param(
        [Alias('Color', 'ColorName', 'Label')]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0)]
        [string]$HexColor,

        [switch]$Strict

    )
    $Config = @{
        AlwaysSaveOnAssign = $false
    }
    $script:__newColorState ??= @{}
    $state = $script:__newColorState

    $cleanStr = $HexColor -replace '^#+', '#' # just one
    $cleanStr = $HexColor -replace '^#+', '#' # or none
    $cleanStr = __normalize.HexString -HexColor $HexColor
    $cleanDigits = $cleanStr -replace '#+', ''
    if ($cleanDigits.Length -notin @(6, 8)) {
        # Wait-Debugger
        Write-Error "Unexpected color, expects 6/8 digits: '$HexColor'"
        return
    }
    $HexStr = '{0}' -f @(
        $cleanDigits
    )
    if ($State.ContainsKey($Name)) {
        if ($State[$Name] -ne $HexStr) {
            #no change, no error
            __saveColor__renderColorName -Name $Name -HexColor $HexColor
            | Join-String -op 'Different Color AlreadyExists!'
            | Write-Verbose
            # | Write-Verbose -Verbose
            if ($Strict) {
                # or the inverse, using force?
                throw 'Different color already exists'
            }
        }
        else {
            __saveColor__renderColorName -Name $Name -HexColor $HexColor
            | Join-String -op 'Same Color Already Saved. '
            | Write-Verbose #-Verbose
        }
    }

    $state[ $Name  ] = $HexStr

    __saveColor__renderColorName -Name $Name -HexColor $HexColor
    | Join-String -op 'Saved '
    | Write-Information #-infa 'Continue'

    # 'save colors'
    if ($Config.AlwaysSaveOnAssign) {
        GetColor -Json
        | ConvertFrom-Json -AsHashtable
        | Ninmonkey.Console\Sort-Hashtable -SortBy Key
        | ConvertTo-Json -Depth 2
        | Set-Content -Path (Join-Path $Env:Nin_Dotfiles 'store' 'saved_colors.json')
    }


    # 'saved: {0} = {1}' -f @(
    #     $Name
    #     $HexColor
    # ) | Join-String -op $PSStyle.Foreground.FromRgb($HexStr) -os $PSStyle.Reset
    # | Write-Information -infa 'continue'
}

@(
    SaveColor -Name 'blue' '#234991'
    SaveColor -Name 'blue.dim' '#3c77d3'
    SaveColor -Name 'blue.gray' '#2e3440'
    SaveColor -Name 'green.dim' '#73b254'
    SaveColor -Name 'green.desaturated' '#b7cea1'
    SaveColor -Name 'teal.bright' '#3d7679'
    SaveColor -Name 'teal.bright2' '#63c0c5'
    SaveColor -Name 'teal' '#2a5153'
    SaveColor -Name 'teal.dark' '#2a5153'
    SaveColor -Name 'green' '#73b254'
    SaveColor -Name 'orange.dark3' -HexColor '#352b1e'
    SaveColor -Name 'tan' -HexColor '#816949'
    SaveColor -Name 'tan.dark2' -HexColor '#4d3f2c'
    SaveColor -Name 'tan.dark3' -HexColor '#352b1e'
) | Out-Null

<#
generate a bunch of grays
#>
# & {
#     # generate defaults
#     0..100
#     | Where-Object { $_ % 5 -eq 0 }
#     | ForEach-Object {
#         $percent = $_
#         $Key = 'Gray.{0}' -f @( $percent )

#         $mod = $percent / 100
#         $component = 255 * $Mod -as 'int' | ForEach-Object tostring 'x'
#         $renderHex = '#{0}{0}{0}' -f @( $Component )
#     }


# }
& { #function __generate.Colors.Gray {
    param(
        [ValidateRange(0, 99)]
        [int]$min = 0,

        [ValidateRange(1, 100)]
        [int]$max = 100,

        [ValidateRange(1, 99)]
        [int]$StepSize = 5
    )
    $min..$Max # 0..100
    | Where-Object { $_ % $StepSize -eq 0 }
    | ForEach-Object {
        $percent = $_
        $Key = 'Gray.{0:d2}' -f @( $percent )

        $mod = $percent / 100
        $component = 255 * $Mod -as 'int' | ForEach-Object tostring 'x2'
        $renderHex = '#{0}{0}{0}' -f @( $Component )
        '{0} => {1} ' -f @( $key, $renderHex )
        SaveColor -Name $Key -HexColor $RenderHex
        | Out-Null
    }
} *>&1 | Out-Null


# SaveColor -Name 'blue' '234991'
# SaveColor -Name 'blue.dim' '3c77d3'
# SaveColor -Name 'green.dim' '73b254'
# SaveColor -Name 'dark.teal' '2a5153'
# SaveColor -Name 'green' '73b254'



function ImportColor {
    <#
    .SYNOPSIS
        bulk load man colors
    #>
    [CmdletBinding()]
    param(

        [switch]$ClearCurrent,
        [switch]$ListAll
    )
    $script:__newColorState ??= @{}
    $state = $script:__newColorState

    $Path
    | Join-String -f 'ImportingFrom: {0}'
    | Write-Verbose

    if ($ClearCurrent) {
        $state.clear()
    }

    $Path = Join-Path $Env:Nin_Dotfiles 'store' 'saved_colors.json'
    $jsonConfig? = Get-Item -ea 'ignore' $Path
    if (-not $jsonConfig?) {
        throw ($Path | Join-String -f 'No saved colors at {0}!')
    }

    # $json = Get-Content -Path $JsonConfig?
    # $json | ConvertFrom-Json
    # | ForEach-Object {
    #     SaveColor -Name $_.Name -HexColor $_.HexColor
    # }
    Get-Content -Path $jsonConfig? | ConvertFrom-Json -AsHashtable | ForEach-Object GetEnumerator | ForEach-Object {
        SaveColor -Name $_.key -HexColor $_.Value
    }

    $colorsHash = Get-Content -Path $jsonConfig? | ConvertFrom-Json -AsHashtable
    $state = $colorsHash

    if ($ListAll) {
        GetColor -ListAll
    }
    $state.keys.count | Join-String -f 'Imported {0} colors' | Write-Information -infa 'continue'
}

[Collections.Generic.List[Object]]$script:__xlr8rLog ??= @()

function New-Lie {
    <#
    .SYNOPSIS
        TypeInfo lies, type accelerator , lies.
    .EXAMPLE
        Get-Lie
    .EXAMPLE
        Get-Lie | Sort-Object TypeName
        | fw -Column 1 TypeName
    .NOTES

    .LINK
        New-Lie
    .LINK
        Get-Lie
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

    class LieRecord {
        [string]$Name
        [string]$ShortType
        [string]$Namespace
        hidden [string]$TypeName
        hidden [object]$TypeInfo # instance of type info.
        # can a resolved type ever fail in this usage?

        LieRecord (
            [string]$Name,
            # [string]$TypeName,
            [object]$TypeInfo
        ) {
            $this.Name = $Name
            $this.ShortType = $TypeInfo.Name
            $this.TypeInfo = $TypeInfo
            $this.TypeName = $TypeInfo.ToString()
            $this.Namespace = $TypeInfo -split '\.' | Select-Object -SkipLast 1 | Join-String -sep '.'
        }
    }

    '{0} isType: {1}, asType: {2}' -f @(
        $TypeInfo
        $TypeInfo -is 'type'
        $TypeInfo -as 'type'
        # ) | Write-Information #-infa 'continue'
    ) | Write-Verbose #-infa 'continue'

    # $script:xlr8r ??= [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
    $script:xlr8r::Add($Name, $TypeInfo)

    # $isNew = ($script:__xlr8rLog | Where-Object { $_.Name -match $Name }).count -gt 0
    # if ($IsNew) {
    if (-not ($script:__xlr8rLog.Name -contains $Name)) {
        $script:__xlr8rLog.Add(
            [LieRecord]::New(
                ($Name),
                ($TypeInfo)
                # ($TypeInfo -as 'type')
            )
        )
    }

    'New Lie: {0} => {1}' -f @(
        $Name
        $TypeInfo
    ) | Write-Information #-infa 'continue'
}


function Get-Lie {
    <#
    .SYNOPSIS
        List already created lies -- TypeInfo lies, type accelerator , lies.
    .EXAMPLE
        Get-Lie
    .EXAMPLE
        Get-Lie
            | ft Name, TypeInfo -GroupBy Namespace
    .EXAMPLE
        Get-Lie
            | Sort-Object Name, Namespace, TypeInfo
            | ft Name, TypeInfo, Namespace

        Get-Lie
            | Sort-Object Name, Namespace
            | ft Name, Namespace
    .description
        show lies. (or, at least the user's lies).
    .LINK
        New-Lie
    .LINK
        Get-Lie
    #>
    param()
    $script:__xlr8rLog | Sort-Object TypeName, Name
}


# $xlr8r::Add( 'Lie', ([System.Collections.Generic.IList`1]) )
# New-Lie -name 'Lie' -TypeInfo [System.Collections.Generic.iList`1]
# New-Lie -name 'Lie' -TypeInfo [System.Collections.Generic.List`1]

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
function Out-PipescriptDefault {
    <#
    .synopsis
        experimental default formatting operator when used within a pipescript
    .LINK
       bPs.Items
    .LINK
       Out-PipescriptDefault
    #>
    [Alias('Ft.🐍', 'Format-Table.🐍', 'Out-Default.🐍')]
    param()
    [PSCustomObject]@{
        Table = @( $Input )
    }
}


[Collections.Generic.List[Object]][ValidateNotNull()]$global:bpsItems ??= @()
function bPs.Items {
    <#
    .synopsis
        minimal wrapper that invokes Export-Pipescript with
    .description
        To View some of the calculated parameters, use these parameters:
            -TestOnly
            -Verbose
            -Infa 'Continue'

        (Actually it defaults to -Infa 'Continue')
    .notes
        see also: <file:///H:/data/2023/dotfiles.2023/pwsh/vscode/editorServicesScripts/ExportPipescript.ps1>
    .notes
        warning, *.ps.* implicitly includes invoking *.ps.psd1 files, crashing as of v1.9.9.4
    .example
        PS> bPs.Items '*.ps.*' -RelativeToRoot '.'
    .example
        PS> bPs.Items '*.ps.md' '.' -WhatIf -Verbose -infa Continue
    .example
        PS> bPs.Items '*.ps.*' -WhatIf -Verbose -infa Continue
    .example
        PS> bPs.Items '*.ps.*' -RelativeToRoot '.' -WhatIf
    .example
        PS> bPs.Items '*/*.ps.html' -RelativeToRoot 'H:/data/2023/pwsh/GitLogger/docs'
    .link
        H:/data/2023/dotfiles.2023/pwsh/vscode/editorServicesScripts/ExportPipescript.ps1
    .LINK
       bPs.Items
    .LINK
       Out-PipescriptDefault
    #>
    [Alias(
        'bps.Items.Profile',
        'bPs.🐍',
        'bPs🐍Ss',
        'ssSs🐍'
    )]
    [CmdletBinding()]
    param(
        # base pattern, assumes '*.ps.*' as a wide default. '*' if you want global default
        # future: allow an array
        [Alias('Pattern')]
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions(
            "'*/*.ps.*'",
            "'*.ps.*'",
            "'*.ps.html'",
            "'*.ps.md'",
            "'*.ps.ps1'",
            "'*'"
        )]
        [string[]]$InputObject = '*.ps.*',

        # export pattern is relative a specific root dir, if not the current one
        [Alias('RelativeToRoot')]
        [Parameter(Mandatory, Position = 1)]
        [ArgumentCompletions(
            "'.'",
            "'./docs'",
            'H:/data/2023/pwsh/GitLogger/docs',
            'H:/data/2023/pwsh/GitLogger'
        )]
        [string]$BaseDirectory = '.',

        # show pattern[s], don't invoke
        [Alias('TestOnly')]
        [switch]$WhatIf,

        [Alias('PassThru' )]
        [switch]$List

        # [hashtable]$Options
    )
    Write-Warning 'add -Cached' # ignores files when the compiled modified time is newer than the source file name
    $Config = @{
        ErrorWhenMissingBase = $true
        bPsItems_AppendOnly  = $false
        AlwaysRecurse        = $true
    }

    [Collections.Generic.List[Object]]$global:bpsItems ??= @()



    # Export-Pipescript -InputPath '*.ps.*'

    if ($null -eq $global:BpsItems) {
        # should never not exist, unless global scope is different when dotsourcing vs module scoping?
        [Collections.Generic.List[Object]]$BpsItems = @()
    }
    if (-not ($Config.bPsItems_AppendOnly) -and $global:BpsItems.count -gt 0) {
        $global:BpsItems.Clear()
    }

    $InputObject | ForEach-Object {
        $CurInputObject = $_
        if (-not(Test-Path $BaseDirectory)) {
            'BaseDirectory does not exist: "{0}"' -f @( $BaseDirectory)
            | Write-Warning
        }
        if ($Config.ErrorWhenMissingBase) {
            $ResolvedRootDir = Get-Item -ea 'stop' $BaseDirectory
        }
        else {
            $ResolvedRootDir = Get-Item -ea 'continue' $BaseDirectory
        }

        $jstr_prefixedArrowRedLines = @{
            Separator    = "`n"
            OutputSuffix = $PSStyle.Reset
            FormatString = '  > {0}'
            OutputPrefix = $PSStyle.Foreground.FromRgb('#933136')
        }

        # $fileGlob = $InputObject ? (Join-Path '*' $InputObject) : $InputObject

        # $resolva
        # if (Test-Path $BaseDirectory) {
        #     $resolvedPath = Join-Path (gi -ea stop $BaseDirectory ) '*/*.ps.*'
        # }

        # Join-Path (gi . ) '*/*.ps.*'
        $ResolvedInput = $CurInputObject ?? '*.ps.*'
        $ResolvedFullPattern = Join-Path $ResolvedRootDir $ResolvedInput


        @(
            'nin::ExportPipeScript:'
            '  BaseDirectory    : {0}' -f @( $BaseDirectory ?? '␀')
            '  ResolvedRootDir  : {0}' -f @( $ResolvedRootDir ?? '␀')
            '  CurInputObject   : {0}' -f @( $CurInputObject ?? '␀')
            '  ResolvedInput    : {0}' -f @( $ResolvedInput ?? '␀')
            '  ResolvedFullPat. : {0}' -f @( $ResolvedFullpattern ?? '␀')
            '  Get-Item "."     : {0}' -f @( Get-Item . )
        )
        | Join-String @jstr_prefixedArrowRedLines
        | Write-Verbose

        @(
            # '  BaseDirectory    : {0}' -f @( $BaseDirectory ?? '␀')
            '  ResolvedRootDir  : {0}' -f @( $ResolvedRootDir ?? '␀')
            '  ResolvedInput    : {0}' -f @( $ResolvedInput ?? '␀')
            '  ResolvedFullPat. : {0}' -f @( $ResolvedFullpattern ?? '␀')
            '  Get-Item "."     : {0}' -f @( Get-Item . )
        )
        | Join-String @jstr_prefixedArrowRedLines
        | Join-String -op "`nnin::ExportPipeScript:`n"
        | Write-Information -infa 'continue'
        # | write-information #-infa continue



        # @(
        #     'nin::ExportPipeScript'
        #     '  BaseDirectory    : {0}' -f @( $BaseDirectory ?? '␀')
        #     # '  ResolvedRootDir  : {0}' -f @( $ResolvedRootDir ?? '␀')
        #     # '  CurInputObject      : {0}' -f @( $CurInputObject ?? '␀')
        #     # '  ResolvedInput    : {0}' -f @( $ResolvedInput ?? '␀')
        #     '  ResolvedFullPat. : {0}' -f @( $ResolvedFullpattern ?? '␀')
        #     '  Get-Item '.'     : {0}' -f @( Get-Item . )
        # )
        # | Join-String @jstr_prefixedArrowRedLines
        # | Join-String -f '=> Bps: -InpObj {0}' -sep "`n"
        # | Join-String -sep "`n"
        # | Write-Information -infa 'Continue'
        # wait-debugger
        if ($WhatIf) { return }

        # maybe enumerate instead and add
        $global:BpsItems.AddRange(@(
                @(
                    Export-Pipescript -InputPath $ResolvedFullpattern
                    | Get-Item
                    | Sort-Object Fullname -Unique
                    # | CountOf '$bPsItems = ' # chunk len
                )
                #
                # below is nice if BpsItems was adding 1 elem at a time. rather than replaced
                # | CountOf -Label 'Items'
                # | Sort-Object FullName -Unique
                # | CountOf -Label 'Distinct'
            ))

    }

    $global:bpsItems
    | Get-Item
    | Sort-Object -Unique FullName
    | CountOf
    | Join-String FullName -f '   <file:///{0}>' -sep "`n" -op "wrote:`n"
    | Write-Verbose

    if ($List) { return $global:BpsItems }
    # if ($BaseDirectory) {
    #     $FullRootPattern = Join-Path $BaseDirectory '*/*'
    #     Join-Path (Get-Item . ) '*/*.ps.*'
    # }

    <# orig script:
    $FullPathPattern = '...'
    $FullpathPattern | Join-String -f '=> Bps: {0}'
    | Write-Information -infa 'Continue'

    @( Export-Pipescript -InputPath 'H:\data\2023\pwsh\GitLogger\docs\*\*.ps.html' ) | CountOf | Sort-Object FullName -Unique | CountOf
    $global:bpsItems | Join-String FullName -f "`n - <file:///{0}>" | CountOf
    #>

}

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

function glam.Bps.🐍.All {
    # gitlogger, macro: BuildPipescript
    # counts are wrong but I don't care for now
    [Collections.Generic.List[Object]]$all_items = @()
    $all_items.AddRange(@(
            Bps.🐍 -InputObject '*.ps.html' -RelativeToRoot 'H:/data/2023/pwsh/GitLogger/docs' -List

        ))
    $all_items.AddRange(@(
            Bps.🐍 -InputObject '*.ps.html', '*.ps.*' -RelativeToRoot 'H:/data/2023/pwsh/GitLogger/Azure' -List
        ))

    $all_items = $all_items | Sort-Object -Unique FullName

    $all_items
    | Sort-Object -Unique FullName
    | CountOf
    | Format-Table -auto

    Toast -Silent -Text 'Glam.BuildPipescript', $(
        'finished {0} items = {1}' -f @(
            $all_items.count
            $all_items.Name | Join-String -sep ', '
        )
    )
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



@(
    $pcolor = '#{0}' -f @(GetColor -ColorLabel 'teal.bright')
    New-Lie -Name 'List' -TypeInfo ([System.Collections.Generic.List`1]) 6>&1
    New-Lie 'Rune' -TypeInfo ([Text.Rune]) 6>&1
    New-Lie -Name 'color.Rgb' -TypeInfo ([PoshCode.Pansies.RgbColor]) 6>&1
    New-Lie -Name 'color.Lab' -TypeInfo ([PoshCode.Pansies.HunterLabColor]) 6>&1
    New-Lie -Name color.space.Lab -TypeInfo ([PoshCode.Pansies.ColorSpaces.HunterLab]) 6>&1

    # New-Lie -Name text.Utf8 -TypeInfo ([System.Text.UTF8Encoding])   6>&1
    # New-Lie -Name text.Utf8 -TypeInfo ([System.Text.UTF8Encoding])   6>&1
    # New-Lie -Name 'encode.Info' -TypeInfo ([System.Text.EncodingInfo]) 6>&1
    # New-Lie -Name 'text.Encoding' -TypeInfo ([System.Text.Encoding]) 6>&1
)
| Join-String -op $PSStyle.Foreground.FromRgb('#' + (GetColor teal.bright)) -os $PSStyle.Reset -sep "`n"
# | Join-String -op $PSStyle.Foreground.FromRgb('#515c6b') -os $PSStyle.Reset