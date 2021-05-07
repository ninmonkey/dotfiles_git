function New-DotfilesCodeConfigToc {
    <#
    .synopsis
        print a table of contents for the file 'settings.json' from vs code
    .description
        .
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
    .notes
        .
    #>
    [CmdletBinding()]
    param (
        # Filename else adjacent
        [Parameter(ValueFromPipelineByPropertyName = 'PSPath')]
        [Alias('Path', 'PSPath')]
        [string]$ConfigPath,

        # List/Search/ (sort of Passthru). Return only item filepaths/item objects
        [Parameter()]
        [switch]$List
    )
    begin {
        $DefaultPath = Join-Path $PSScriptRoot 'settings_global\nin10_desktop'
        function _findConfig {
            param(
                [Parameter()]
                [string]$BasePath
            )
            process {
                Get-ChildItem -Path $BasePath -Recurse '*code*settings*json'
            }
        }

        $splatJoinCsv = @{
            'Separator' = ', '
            SingleQuote = $True
        }
    }
    process {
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
        Join-String

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
            'SectionHeader_iter1' = @'
(?x)
        ^\s*(?<Depth>\#{2,})\s*(?<Type>(Sect|SubSect|\w+)):\s*(?<Title>)$
'@
            'SectionHeader'       = @'
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
        | ForEach-Object -Begin { $lineNum = 0 } -Process {
            if ($_ -match $Regex['SectionHeader']) {
                [pscustomobject]@{
                    Depth      = $Matches.Depth
                    Title      = $Matches.Title
                    Type       = $Matches.Title
                    LineNumber = $lineNum++
                }
            }
        }

    }
    end {}
}

New-DotfilesCodeConfigToc -Verbose -Debug -list
| Select-Object -First 1
| New-DotfilesCodeConfigToc -Verbose -InformationAction Continue -Debug