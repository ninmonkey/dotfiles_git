# was: <file:///H:\data\2023\dotfiles.2023\legacy.2022\vscode\New-DotfilesCodeConfigToc.ps1>
$AutoRunExamples = $false
function New-DotfilesCodeConfigToc {
    <#
    .synopsis
        print a table of contents for the file 'settings.json' from vs code
    .description
        .
    .notes
        future:
            - **make markdown**
                - that links to the separate settings.json
                 **line numbers** in github as a regular .md url

            - auto sort by Path, Line inside the function), by collecting a list
            - UseProfile: Auto suggest 'code' and 'code-insers' paths
    .example
        PS>
            New-DotfilesCodeConfigToc -list
            | select -First 1
            | New-DotfilesCodeConfigToc
    .example
        PS>
            New-DotfilesCodeConfigToc -list -InformationAction Continue -Verbose -Debug
            | Out-Fzf
            | New-DotfilesCodeConfigToc

    .example
        PS> $FinalResults = Get-Item -ea stop "$Env:AppData\Code\User\settings.json"
            | New-DotfilesCodeConfigToc
            $FinalResults | sort LineNumber | ft LineNumber, Type, Title

                LineNumber Type    Title
                ---------- ----    -----
                 0 Sect    About
                 1 Sect    Config Settings to Experiment with
                 2 Sect    Testing new icons:
                 3 Sect    "What's New" / New Features / Configs from patches:
                 4 Sect    Config Settings to Experiment with
                 5 Sect    Truly Experimental
                 6 SubSect Notebooks: ⇢ .ipynb, Jupyter, nteract..
                 7 SubSect Editor ⇢ Tabs, Pins, Icons, Decorations
                 8 Sect    Real Config Starts Here
                 9 Sect    Suggestions, Intellisence, Autocomplete, Completers
                10 Sect    Clipboard: Copy Paste
                11 Sect    Git, Github
                12 Sect    Log Levels
                13 Sect    Language Config
                14 Sect    semantic highlighting
                15 Sect    Extension Specific Config: "ms-vscode.powershell-preview"
                16 Sect    File Type Overrides
                17 Sect    Terminal Config

    .notes
    .link
        ConvertTo-DotfileCodeConfigMarkdown
    #>
    [CmdletBinding()]
    param (
        # Filename else adjacent
        [Parameter(ValueFromPipelineByPropertyName = 'PSPath',
            ParameterSetName = 'MultipleFiles')]
        [Alias('Path', 'PSPath')]
        [string]$ConfigPath,

        # List/Search/ (sort of Passthru). Return only item filepaths/item objects
        [Parameter()]
        [switch]$List,

        # use your default profile[s]
        [Parameter()]
        [switch]$UseProfile

        # Include Source Filepath for multiple files?
        <#
        [Parameter()]
        [switch]$IncludeFilepath
        #>
    )
    begin {
        $DefaultPath = Join-Path $PSScriptRoot 'settings_global\nin10_desktop'
        # if not specified either way, then default to on, only for multi files
        <#
        if ($PSCmdlet.ParameterSetName -eq 'MultipleFiles') {
            $IncludeFilepath = $IncludeFilepath ?? $true
        }
        #>
        function _findConfig {
            param(
                [Parameter()]
                [string]$BasePath
            )
            process {
                Get-ChildItem -Path $BasePath -Recurse '*code*settings*json'
            }
        }

        if ($UseProfile) {
            $ConfigPath = Get-Item -ea stop "$Env:AppData\Code\User\settings.json"
        }
        $splatJoinCsv = @{
            'Separator' = ', '
            SingleQuote = $True
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'MultipleFiles') {
            $IncludeFilepath = $IncludeFilepath ?? $true
        }
        if ($List) {
            _findConfig -BasePath $DefaultPath
            return
        }

        function _getPathOrNone {
            <#
            .synopsis
                basic logic to try paths
            .outputs
                TypedUnion( $false | [System.IO.FileSystemInfo] )

            #>
            param()
            $ConfigPath | Join-String @splatJoinCsv
            | Label 'try full config path'
            | Write-Verbose
            $SourcePath = $ConfigPath | Get-Item -ea Continue

            $DefaultPath, $ConfigPath | Join-String @splatJoinCsv
            | Label 'try auto-prefix path'
            | Write-Verbose
            if (!($SourcePath)) {
                $SourcePath = Join-Path $DefaultPath $ConfigPath | Get-Item -ea Continue
            }

            if (!($SourcePath)) {
                Write-Warning "Filepath not resolved: '$ConfigPath'`n  or '$DefaultPath/$ConfigPath'"
                $false
                return
            }
            $SourcePath
        }


        $Filepath = _getPathOrNone
        if (!($Filepath)) {
            _findConfig -BasePath $DefaultPath #| ForEach-Object fullName
            return
        }


        if ($Filepath.count -gt 1) {
            # piped paths don't throw this warning
            $Filepath | Join-String @splatJoinCsv
            | Label 'multiple files found'
            | Write-Warning
        }

        $Regex = @{
            'SectionHeader' = @'
(?x)
        ^\s*
        (?<Depth>\#{2,})
        \s*


        # a few options:
        # 1] minimal, works pretty good
            (?<Type>[^:]*):

        # 2] works with non-hardcoded namesany non-
            # (?<Type>(SubSect|Sect|[\w\s]+)):

        # 3] little more robust. needed if type names can have spaces before the ':'
            # (?<Type>(SubSect|Sect|[\w\s]+)):

        \s*
        (?<Title>.*)$
'@
        }
        # '\s*###*\s*(SubSect|Sect):\s*(?P<Title>.*$)' -- "$src"

        # $Regex.SectionHeader = 's*(?<Depth>###*)\s*'

        ( Get-Content $Filepath ) -split '\r?\n'
        | ForEach-Object -Begin { $lineNum = 0; $matchNumber = 0 } -Process {
            $lineNum++ # editors are using base-1
            if ($_ -match $Regex['SectionHeader']) {
                $hash = [ordered]@{
                    LineNumber  = $lineNum
                    MatchNumber = $matchNumber++
                    Depth       = $Matches.Depth.length
                    DepthStr    = $Matches.Depth
                    Title       = $Matches.Title
                    Type        = $Matches.Type
                }
                if ($true -or $IncludeFilepath) {
                    $hash.Add('Path', $Filepath)
                }

                [pscustomobject]$hash
            }
        } | Sort-Object LineNumber # just to be explicit

    }
    end {}
}

function ConvertTo-DotfileCodeConfigMarkdown {
    <#
    .synopsis
        generate similar to markdown automatic Table of contents
    .link
        New-DotfilesCodeConfigToc
    .example
        PS> New-DotfilesCodeConfigToc -UseProfile | ConvertTo-DotfileCodeConfigMarkdown

            - [About] 4
            - [Config Settings to Experiment with] 17
            - [Testing new icons:] 29
            - ["What's New" / New Features / Configs from patches:] 88
            - [Config Settings to Experiment with] 107
            - [Truly Experimental] 153
            - [Notebooks: ⇢ .ipynb, Jupyter, nteract, ...] 159
            - [Editor ⇢ Tabs, Pins, Icons, Decorations] 174
            - [Real Config Starts Here] 222
            - [Suggestions, Intellisence, Autocomplete, Completers] 227
            - [Clipboard: Copy Paste] 239
            - [Git, Github] 247
            - [Log Levels] 262
            - [Language Config] 269
            - [semantic highlighting] 313
            - [Extension Specific Config: "ms-vscode.powershell-preview"] 356
            - [File Type Overrides] 376
            - [Terminal Config] 442
    #>
    param(
        # List of results from 'New-DotfilesCodeConfigToc
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Record
    )
    process {
        $Record | ForEach-Object {
            $item = $_
            $adjustedDepthLevel = ($item.Depth / 3) - 1
            $prefix = '  ' * $adjustedDepthLevel
            @(
                $prefix
                '- '
                '['
                $item.Title
                ']'
                ' '
                $item.LineNumber

            ) -join ''
        }
    }
}
h1 'Example0: Use default path '
$results = New-DotfilesCodeConfigToc -UseProfile
$results | Format-Table

h1 'Example0: with ConvertTo-Markdown'
$results | ConvertTo-DotfileCodeConfigMarkdown

if ($AutoRunExamples) {
    if ($True) {
        h1 'Example0: Use default path '
        $results = New-DotfilesCodeConfigToc -UseProfile
        $results | Format-Table
    }
    if ($True) {
        Hr
        h1 'Example1: Autofind all files in the default path using -List then pipe to command again'
        $autoMaticResults = New-DotfilesCodeConfigToc -list
        | Sort-Object -Property LastWriteTIme
        | Select-Object -First 3
        | New-DotfilesCodeConfigToc -Verbose -InformationAction Continue -Debug
        | Sort-Object -Property 'Path', 'LineNumber'
        $autoMaticResults | Format-Table

        $autoMaticResults
        | Group-Object Path | Sort-Object Count -Desc | Join-String -sep "`n" { $_.Count, $_.Name -join ': ' }
        | Label "`nsummary" -sep "`n"
        | Write-Verbose
    }
    if ($True) {
        Hr
        h1 'Example2: Explicit Path'
        $FinalResults = Get-Item -ea stop "$Env:AppData\Code\User\settings.json"
        | New-DotfilesCodeConfigToc -Verbose -Debug -InformationAction Continue
        | Sort-Object -Property 'Path', 'LineNumber'
        $FinalResults | Format-Table
    }
    if ($True) {
        Hr
        h1 'Example3: Select using Fzf'
        $fzfResults = New-DotfilesCodeConfigToc -List
        | Out-Fzf -MultiSelect -PromptText 'Select Config File[s]'
        | Get-Item
        | New-DotfilesCodeConfigToc
        $fzfResults | Format-Table
    }
}
<# from examples:

Ex:
Ex:
    $FinalResults = Get-Item -ea stop "$Env:AppData\Code\User\settings.json"
    | New-DotfilesCodeConfigToc
    $FinalResults | Sort-Object LineNumber | Format-Table LineNumber, Type, Title

Ex:

    $FinalResults = Get-Item -ea stop "$Env:AppData\Code\User\settings.json"
    | New-DotfilesCodeConfigToc -Verbose -Debug -InformationAction Continue
    $FinalResults | Format-Table
#>
