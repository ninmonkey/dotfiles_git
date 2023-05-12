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

Set-Alias -Name 'Json.From' -Value 'ConvertFrom-Json'

Remove-Module Pipeworks -ea 'ignore' # because it overrides pansies|write-host
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
        [Parameter(Mandatory, position = 0)]$SplitRegex,

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
        [Parameter(Mandatory, position = 0)]$Regex,

        [ArgumentCompletions(
            "'\r?\n'",
            # '{ "${fg:red}", $_, "${fg:clear}" -join "" }',
            '{ "${fg:#70788b}", $_, "${fg:clear}" -join "" }',
            '{ @( $PSStyle.Foreground.FromRgb(''aeae23''); $_; $PSStyle.Reset ) | Join-String -sep '''' }'
        )]
        [Parameter(Mandatory, position = 0)]$ReplaceWith,

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
        [Parameter(Mandatory, position = 0)]$JoinText,

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
            File      = '*file*', '*name*', '*extension*', '*path*', '*directory*', '*folder*'
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

        $emptyPropNames | Join-String -op 'empty: ' -sep ', ' -DoubleQuote | Write-Debug

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

function NewestItem {
    <#
    .SYNOPSIS
    Filter on stuff, using NameIsh to decide what properties to filter on

    .DESCRIPTION
    next:
        - check properties for [datetime] of any name

    .EXAMPLE
        Pwsh> gci | NewestItem
    .EXAMPLE
        Pwsh> gci | NewestItem

        # more than 1?

        gci | NewestItem Directory -TopN 3
        gci | NewestItem File -TopN 3
    .EXAMPLE
        # WhereItem is short for NewestItem -All
        gci . | WhereItem File
        gci . | NewestItem File -All
    .EXAMPLE
        Pwsh> gci | NewestItem

        # more than 1?

        gci | NewestItem Directory
        gci | NewestItem File

    .NOTES
    General notes
    #>
    [Alias('WhereItem')]
    # [OutputType('PSObject')]
    param(
        [ArgumentCompletions(
            'File',
            'Directory', 'Dir',
            'Color',
            'Length',
            'Command',
            'Code',
            'Log'
        )]
        [Parameter(position = 0)]
        [string]$ItemKind,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # Defaults to First1, you can set a count, or even return all
        # maybe lastN / OldestItem as an alias with auto invert behavior
        [Alias('TopN', 'First')]
        [int]$FirstN = 1,

        # after filtering, reverse the results
        [switch]$Reverse,

        # collect/show all
        # applies filtering, but returns all matches
        [Alias('All')]
        [switch]$PassThru



    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }


    # $splat = @{}
    # if( $PSBoundParameters.ContainsKey('File') ) {
    #     $splat.File = $File
    # }
    # if( $PSBoundParameters.ContainsKey('Folder') ) {
    #     $splat.File = $File
    # }
    # warning:
    end {


        $items.count | Join-String -f 'total items: {0}'
        | New-Text -fg 'gray40' | ForEach-Object tostring | Write-Information

        [Collections.Generic.List[object]]$filtered = $items
        | Where-Object {
            $curItem = $_
            switch ($ItemKind) {
                'Application' {
                    # not the fasted but it's flexible on the inputs
                    $bin = @(  Get-Command $curItem -ea ignore -CommandType Application )
                    $bin.count -gt 0
                    continue
                }
                'Image' {
                    $curItem.Extension -match '\.(png|gif|jpe?g|mp4)$'
                }
                'File' {
                    return $curItem -is 'System.IO.FileInfo'
                }
                { $_ -in @('Directory', 'Dir') } {
                    return $curItem -is 'System.IO.DirectoryInfo'
                }
                'Code' {
                    $curItem.Extension -match '\.(ps1|psm1|psd1|ts|js|py)$'
                }
                'Log' {
                    $curItem.Extension -match '\.(log|xml)$'
                }
                default {
                    # ex: Size would use Length Descending property
                    throw "UnhandledItemKindException: '$ItemKind'"
                }
            }
        }


        switch ($ItemKind) {
            'File' {
                $sortByProp = 'LastWriteTime'
            }
            { $_ -in @('Directory', 'Dir') } {
                $sortByProp = 'LastWriteTime'
            }
            'Code' {
                $sortByProp = 'LastWriteTime'
                $curItem.Extension -match '\.(ps1|psm1|psd1|ts|js|py)$'
            }
            'Log' {
                $sortByProp = 'LastWriteTime'
                $curItem.Extension -match '\.(log|xml)$'
            }
            default {
                # ex: Size would use Length Descending property
                throw "UnhandledItemKindException: '$ItemKind'"
            }
        }

        [Collections.Generic.List[object]]$sorted = @(
            $filtered | Sort-Object -prop $Property
        )
        if ($Reverse) {
            # is there a reason to use this over
            # inverting the -descending param?
            # possibly if it is to be extended.
            $sorted.Reverse()
        }

        $endcapLargest = $filtered | Select-Object -First 1
        $endcapSmallest = $filtered | Select-Object -Last 1
        # $endcapLargest.LastWriteTime ?? "`u{2400}"
        # $endcapSmallest.LastWriteTime ?? "`u{2400}"

        '{0}..{1}' -f @(
            (  $endcapLargest)?.$Property ?? '␀'
            ( $endcapSmallest)?.$Property ?? '␀'
        )

        $colorBG = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg = $PSStyle.Foreground.FromRgb('#e5701c')
        $colorFg = $PSStyle.Foreground.FromRgb('#f2962d')
        # $colorBG_count = $PSStyle.Background.FromRgb('#362b1f')
        # $colorFg_count = $PSStyle.Foreground.FromRgb('#f2962d')
        $colorFg_label = $PSStyle.Foreground.FromRgb('#4cc5f0')
        $colorBG_label = $PSStyle.Background.FromRgb('#376bce')

        $endcapLargest.LastWriteTime, $endcapLargest.LastWriteTime
        | Join-String -op "${bg:gray30}${fg:gray50}"
        | Join-String -sep '..' -op '{ ' -os ' }'
        | Join-String -os $PSStyle.Reset


        $color_gray = "${fg:gray60}"
        $reset = $PSStyle.Reset
        $color_main = @(
            $PSStyle.Foreground.FromRgb('#4cc5f0')
            $PSStyle.Background.('#376bce')
        ) -join '' # validate whether this still works with NO_COLOR
        # or if multi stage string building doesn't work
        $render = @(
            $color_gray
            '{ '
            $reset
            $color_main
            $endcapLargest
            $reset
            $color_gray
            '…'
            $color_main
            $endcapSmallest
            $reset
            $color_gray
            ' }'
        )
        | Join-String -os $reset

        $render
        | Write-Information -infa 'Continue'

        if ($PSCmdlet.MyInvocation.InvocationName -match 'Where.*Item') {
            $PassThru = $true
        }


        if ($PassThru) {
            return $sorted
        }

        $sortSplat = @{}
        if ($FirstN) {
            $sortSplat.Top = $FirstN
        }



        return $sorted
        | Sort-Object -Prop $SortByProp -Descending @sortSplat
        | CountOf
    }

}

function NewestItem.Basic {
    <#
    .SYNOPSIS
    Filter on stuff, using NameIsh to decide what properties to filter on

    .DESCRIPTION
    next:
        - check properties for [datetime] of any name

    .EXAMPLE
        Pwsh> gci | NewestItem

    .NOTES
    General notes
    #>
    [OutputType('System.IO.FileSystemInfo')]
    param(
        [ArgumentCompletions(
            'File',
            'Directory', 'Dir',
            'Color',
            'Length'
        )]
        [Parameter(position = 0)]
        [string]$ItemKind,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }


    # $splat = @{}
    # if( $PSBoundParameters.ContainsKey('File') ) {
    #     $splat.File = $File
    # }
    # if( $PSBoundParameters.ContainsKey('Folder') ) {
    #     $splat.File = $File
    # }
    # warning:
    end {
        $items.count | Join-String -f 'total items: {0}'
        | New-Text -fg 'gray40' | ForEach-Object tostring | Write-Information

        $items
        | Where-Object {
            $curItem = $_
            switch ($ItemKind) {
                'File' {
                    return $curItem -is 'System.IO.FileInfo'
                }
                { $_ -in @('Directory', 'Dir') } {
                    return $curItem -is 'System.IO.DirectoryInfo'
                }
                default {
                    # ex: Size would use Length Descending property
                    throw "UnhandledItemKindException: '$ItemKind'"
                }
            }
        }
        | Sort-Object LastWriteTime -Descending -Top 1
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

        see also:
            <file:///H:\data\2023\pwsh\sketches\2023-04\transpileIfNew\Invoke-Pipescript.TranspileIfNew.ps1>
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
            'H:/data/2023/pwsh/PsModules/GitLogger/docs',
            'H:/data/2023/pwsh/PsModules/GitLogger/Azure',
            'H:/data/2023/pwsh/PsModules/GitLogger/Aws',
            'H:/data/2023/pwsh/PsModules/GitLogger/Commands',
            'H:/data/2023/pwsh/PsModules/GitLogger'
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

[Collections.Generic.List[Object]]$global:Last_WhereFilterByChoice = @()

function nin.Where-FilterByGroupChoice {
    <#
    .SYNOPSIS
        Dynamically filter using fzf filtering groups based on property name
    .NOTES

    .EXAMPLE
        Get-Command *json* | nin.Where-FilterByGroupChoice 'Source'
        Get-Command *json* | nin.Where-FilterByGroupChoice
    .EXAMPLE
        gcm *pipe* | nin.Where-FilterByGroupChoice 'Source' -Verbose -InformationAction 'continue'
    #>
    [Alias(
        'fzf.Group',
        # 'nin.Where-FilterByGroup',
        '?🐒.Group', # testing which is cleaner to autocomplete
        '?nin.Group'
    )]
    [CmdletBinding()]
    param(

        # Prop name to query on. currently they both use the same param
        # If not set, prompts for which property to search
        [Alias('Name', 'ScriptBlock')]
        [Parameter(Position = 0)]
        [object]$GroupOnSBOrName,

        # keep re-running until final match is exit
        [switch]$RepeatLast,
        # object stream
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        $binFzf = Get-Command 'fzf' -ea 'Stop' -CommandType Application | Select-Object -First 1
        [Collections.Generic.List[Object]]$Items = @()
        # did user specify group by?
        # if not, prompt


        # if ($GroupOnSBOrName -isnot 'string') {
        # }
        # elseif ($GroupOnSBOrName -is 'scriptblock') {
        #     $GroupByPropertyName = $GroupOnSBOrName
        #     throw 'NYI: Group on Script block'
        # }
        # else {
        #     $GroupByPropertyName = $GroupOnSBOrName
        # }
    }
    process {
        $items.AddRange(@( $InputObject ))
    }
    end {
        $InformationPreference = 'continue'
        # $FzfTitle = 'choose items to filter $OrigCommand: Gcm "*pipe*"'
        $OrigQuery = $Items # alias semantics

        if ($OrigQuery.Count -le 0) {
            throw 'InputObject had 0 items'
        }

        [Collections.Generic.List[Object]]$fzfArgs = @(
            '--layout=reverse'
            # '-m'
            '--ansi'
        )
        #

        # Is the arg a string, scriptblock, or nothing
        # auto-prompt for property name if not set
        switch ( $GroupOnSBOrName ) {
            { $_ -is 'scriptblock' } {
                throw 'NYI: ScriptBlockParam'
            }

            { [string]::IsNullOrWhiteSpace( $_ ) } {
                [string]$GroupByPropertyName = @(
                    @($OrigQuery)[0].PSObject.Properties.Name
                )
                | Sort-Object -Unique
                | & $binFzf @fzfArgs
            }

            { $_ -is 'string' } {
                [string]$GroupByPropertyName = $GroupOnSBOrName
            }
            default {
                throw 'UnhandledCase: nin.Where-FilterByGroupChoice'
            }

        }

        $fzfArgs.Clear()
        $fzfArgs.AddRange(@(
                '--layout=reverse'
                '-m'
                '--ansi'
            ))

        $SelectedGroupChoices = $OrigQuery
        | Group-Object $GroupByPropertyName -NoElement
        | ForEach-Object Name | Sort-Object -Unique
        | Where-Object { $_ <# ignore null or blanks #> }

        # $selectedChoices =
        if ($SelectedGroupChoices.count -le 0) {
            throw 'No Filters Selected!'
        }


        $What = @( $SelectedGroupChoices | & $binFzf @fzfArgs )

        ( $global:Last_WhereFilterByChoice = @(
            $OrigQuery
            | Where-Object {
                @( $What ) -contains $_.$GroupByPropertyName
                # @($What ) -contains $_.$GroupOnSBOrName #-in #$what
            }
        ) ) # streaming and ensure non-null list

        $what | Join-String -sep ', ' -SingleQuote -op 'GroupOnChoices: ' | Write-Verbose
        'found: {0} items. $global:Last_WhereFilterByChoice' -f @(
            $global:Last_WhereFilterByChoice.count ?? 0
        ) | New-Text -bg gray30 -fg gray65 | Write-Information

        if ($RepeatLast) {
            throw "NYI: while totalFound is exactly 0, repeat prompting for new property name and then filter again  ${PSCOmmandPath}"
        }

    }
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

function WhereInScope? {
    [Alias('AmInScope?')]
    [CmdletBinding()]
    <#
    .SYNOPSIS
     see if value is set and types going up the scope

    .DESCRIPTION
    same

    todo: ensure it executes in the right execution context of the juser

    .EXAMPLE
        AmInScope? WhereInScope?
    .EXAMPLE
        $valOf = get-variable -scope 0 -Name 'MyInvocation'
            [System.Management.Automation.LocalVariable]
    .EXAMPLE
    to test agains

            . $PROFILE.'MainEntryPoint.__init__'
            WhereInScope? -Name 'path' |  ft -AutoSize
            hr
            $cat  = 'out'
            function innerCat {
                $cat
                $cat = 42
                $cat
                WhereInScope? -Name 'cat' |ft
            }
            innerCat
            $cat
    .NOTES
    General notes
    #>
    param(
        [alias('Name')][string]$VariableName,
        [int]$MaxDepth = 4
    )

    class WhereInScopeResult {
        [int]$Depth
        [string]$Name
        [object]$Value
        [bool]$Exists

        # hidden [System.Management.Automation.PSVariableAttributeCollection[]]$Attributes
        [object]$TypeOf
        [string]$ModuleName
        [string]$Description
        # [object]$ReportedType
        hidden [Nullable[System.Management.Automation.ScopedItemOptions]]$ScopedItemOptions
        [System.Management.Automation.PSModuleInfo]$ModuleInfo
        [Nullable[System.Management.Automation.SessionStateEntryVisibility]]$Visibility
        hidden [object[]]$Attributes # PSES says: [Collection[Attribute]] $Attributes
        # [hashtable]$Extra

        WhereInScopeResult ( [string]$VariableName, [int]$Depth ) {
            try {
                $this.Exists = (Get-Variable -ea 'ignore' -Scope $Depth) -contains $VariableName
            }
            catch {
                $this.Exists = $false
            }

            $this.Depth = $Depth
            $this.Name = $VariableName
            if ($this.Exists ) {
                $val? = Get-Variable -ea 'ignore' -Name $VariableName -Scope $Depth
            }
            else {
                $val? = $null
            }

            $this.Value = $val? ?? $null

            # $this.Value = $val?
            $this.TypeOf = ($val?)?.GetType() ?? $null

            # "Cannot convert null to type
            #  | "System.Management.Automation.ScopedItemOptions
            $this.ScopedItemOptions = ($val?)?.Options ?? $null

            $this.Attributes = $val?.Attributes
            $this.Description = $val?.Description
            $this.ModuleInfo = $val?.Module
            $this.ModuleName = $val?.ModuleName
            $this.Visibility = $val?.Visibility
            # $this.ReportedType = $val?.
            # $this.Extra = @{ ... }
        }
        [bool] Exists() {
            # techincally existing values set to null
            return $this.Exists # custom scriptproperty or exformat for types
        }
    }

    # Exists = (get-variable -scope $depth -ea ignore) -contains 'Path'
    # while($true) {
    #     $depth = 0
    #     $value? = Get-Variable -ea 'ignore' -name $Name -scope $Depth
    #     [pscustomobject]@{
    #         Scope = $Depth
    #         Name = $VariableName
    #         Value = $value? ?? $null
    #         # sma
    #         ScopedItemOptions = $value?.ScopedItemOptions


    #     }
    # }
    # <#
    # > $valOf = get-variable -scope 0 -Name 'MyInvocation'
    # System.Management.Automation.LocalVariable

    #>
    'class: [WhereInScopeResult]: Not fully done, validate values are being assigned when not null: {0}' -f @(
        $PSCommandPath
    ) | Write-Warning
    0..$MaxDepth | ForEach-Object {
        $curDepth = $_
        [WhereInScopeResult]::new( $VariableName, $curDepth )
        # Get-Variable -Scope $Depth -Name $VariableName -ea 'ignore'
    }
    # sort ?
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

function DeleteOldModule.MoveToNormalPath {
    <#
    .SYNOPSIS
        I had some modules in the non-global path, but you can't update them easily, moving some back to main.
    #>
    ($what = Get-ChildItem 'E:\PSModulePath.2023.root\Main' | ForEach-Object Name | fzf -m )
    | Join-String -sep ', ' -SingleQuote

    try {
        foreach ($mod in $what) {
            Get-ChildItem 'E:\PSModulePath.2023.root\Main'
            #$Mod = 'Profiler'
            Remove-Item (Join-Path 'E:\PSModulePath.2023.root\Main' $mod ) -Recurse -Force

            Install-Module $mod -AllowClobber -Force
            Get-Module $mod -ListAvailable
        }
    }
    catch {
        '😡 Oh no, something bad: {0}' -f @( $_ )
    }
    $what | Join-String -op 'Did not ttry -AllowPrerelease. Expected Installs: ... ' -sep ', ' -SingleQuote
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

'Move to nAsty, nAncy, Marking, etc...{0}' -f @(
    $PSCommandPath
) | Write-Host -fg 'orange'



if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

