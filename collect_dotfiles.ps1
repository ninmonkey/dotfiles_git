$_dotfilePath = [ordered]@{
    # BasePath = Get-Item -ea stop $PSScriptRoot | ForEach-Object tostring
    Root = [ordered]@{
        Label        = 'Root'
        RelativePath = '.'
        FullPath     = $PSScriptRoot | Get-Item -ea stop
    }
}

function New-DotfilePathRecord {
    [CmdletBinding(DefaultParameterSetName = 'ForcePath')]
    param(
        # Description
        [Parameter(Mandatory, Position = 0)]
        [string]$Label,

        # RelativePath to Root
        [Parameter(Mandatory, Position = 1)]
        [string]$RelativePath,

        # Path FullName, otherwise defaults to "Root + RelativePath"
        [Parameter(
            ParameterSetName = 'ForcePath',
            Mandatory,
            Position = 2)]
        [object]$Fullpath
    )

    $record = [ordered]@{
        Label        = $Label
        RelativePath = $RelativePath
    }

    if ($PSCmdlet.ParameterSetName -eq 'ForcePath') {
        $TargetPath = Get-Item -ea Stop $Fullpath # stop or write-error?
        $record['FullPath'] = $TargetPath
    } else {
        $TargetPath = $PSScriptRoot | Get-Item -ea Stop # stop or write-error?
        $record['FullPath'] = $TargetPath
    }

    $record | Format-HashTable -Title 'DotfilePathRecord' | Write-Debug
    $_dotfilePath.Add( $Label, $record )
}

function Add-DotfilePath {
    <#
    .synopsis
        add new path, only if it does not exist
    .description
        non-existing paths should be non-f atal, at least on the current item name
    .notes
        seems crossplatform to pass a path containing '\' or '/' because of Join-path

            PS> Join-path $i.FullName 'cat/goat/bar'
            # ㏒: C:\foo\cat\goat\bar
    #>
    param(
        # Label or Id or Key
        [Parameter(Mandatory, Position = 0)]
        [string]$Label,
        # Label Directory Name
        [Parameter(Mandatory, Position = 1)]
        [string]$Path,

        # optionaly define paths relative an existing path, without "fullname spam"
        [Parameter()]
        [string]$RelativeTo
    )

    # $FullPath = Join-Path $_dotfilePath.BasePath $Path
    # $Item = Get-Item -ea continue $Path # continue or stop?

    if ($RelativeTo) { throw "wip" ; return }

    # $pathRecord = [ordered]@{
    #     Label        = $Label
    #     RelativePath = $Path
    #     FullPath     = $FullPath
    # }

    $pathRecord | Format-HashTable | Write-Debug
    $_dotfilePath.Add( $Label, $Path )
}

$DebugPreference = 'Continue'



function Get-DotfilePath {
    [CmdletBinding(DefaultParameterSetName = 'GetOnePath')]
    <#
    .description
        read saved values
    #>
    param(
        # Label or Id or Key
        [Parameter(
            Mandatory, Position = 0,
            ParameterSetName = 'GetOnePath')]
        [string]$Label,
        # [Parameter(
        #     Mandatory, ValueFromPipeline,
        #     ParameterSetName = 'GetOnePathPipeline')]

        # Label or Id or Key
        [Alias('All')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAll')]
        [switch]$ListAll


        # # Label Directory Name
        # [Parameter(Mandatory, Position = 1)]
        # [string]$Path
    )

    # future: allow labels from pipeline

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'GetOnePath' {
                break
            }
            # 'GetOnePathPipeline' {
            #     break
            # }
            { $ListAll -or 'ListAll' } {
                $_dotfilePath
                break
            }

            default { throw "Unhandled Parameterset: $($PSCmdlet.ParameterSetName)" }
        }

    }

    # $FullPath = Join-Path $_dotfilePath.BasePath $Path
    # $Item = Get-Item -ea continue $Path # continue or stop?

    # $_dotfilePath.Add( $Label, $Path )
}

function Start-DotfileCollect {
    <#
    .synopsis
        super rough sketch of automated dotfiles backing up script
    .description
        .
    .example

    .notes
        .
    #>
    param (

    )
    begin {}
    process {}
    end {}
}

# function _test1 {
Add-DotfilePath -Label 'vs-code' -Path 'vscode\.auto_export'
# Add-DotfilePath -Label 'vs-code-snippets' -Path 'snippets' -RelativeTo 'vs-code'
Get-DotfilePath -ListAll
$result = Get-DotfilePath -Label 'vs-code-snippets'
# }
# _test1




h1 'Section: Powershell'
Start-DotfileCollect
h1 'Section: VS Code'
h1 'Done'



$DebugPreference = 'SilentlyContinue'