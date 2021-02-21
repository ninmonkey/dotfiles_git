
$_dotfilePath = [ordered]@{
    # BasePath = Get-Item -ea stop $PSScriptRoot | ForEach-Object tostring
    Root = [ordered]@{
        Label        = 'Root'
        RelativePath = '.'
        FullPath     = $PSScriptRoot | Get-Item -ea stop
    }
}

function New-DotfilePathRecord {
    <#
    .synopsis
        generates a new structured record
    .notes
        future: allow caller to decide write-error stops or not
    #>
    [CmdletBinding()]
    param(
        # Description
        [Parameter(Mandatory, Position = 0)]
        [string]$Label,

        # RelativePath to Root
        [Parameter(Mandatory, Position = 1)]
        [string]$RelativePath

        # removed logic to force a path, not worth it
        # Path FullName, otherwise defaults to "Root + RelativePath"
        # [Parameter(
        #     ParameterSetName = 'ForcePath',
        #     # Mandatory,
        #     Position = 2)]
        # [object]$Fullpath
    )
    $root = Get-DotfilePath 'Root' | ForEach-Object FullPath | Get-Item -ea stop

    $maybeExistingPath = Join-Path -Path $root -ChildPath $RelativePath
    | Get-Item -ea SilentlyContinue

    if (! $maybeExistingPath) {
        $maybeExistingPath = Join-Path -Path $root -ChildPath $RelativePath
    }
    $record = [ordered]@{
        Label        = $Label
        RelativePath = $RelativePath
        FullName     = $maybeExistingPath
    }


    # if ($PSCmdlet.ParameterSetName -eq 'ForcePath') {
    #     $TargetPath = Get-Item -ea Continue $Fullpath # stop or write-error?
    #     $record['FullPath'] = $TargetPath
    # } else {
    # $TargetPath = $PSScriptRoot | Get-Item -ea Continue # stop or write-error?
    # $record['FullPath'] = $TargetPath
    # }

    $record | Format-HashTable -Title 'DotfilePathRecord' | Write-Debug
    $record
    return
    # $_dotfilePath.Add( $Label, $record )
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

    if ($RelativeTo) {
        throw "wip: Add-DotfilePath: -RelativeTo" ;
        return
    }

    # $pathRecord = [ordered]@{
    #     Label        = $Label
    #     RelativePath = $Path
    #     FullPath     = $FullPath
    # }

    $pathRecord = New-DotfilePathRecord -Label $Label -RelativePath $Path
    $pathRecord | Format-HashTable | Write-Debug


    $_dotfilePath.Add( $Label, $pathRecord )
}

function Get-DotfilePath {
    [CmdletBinding(DefaultParameterSetName = 'GetOnePath')]
    <#
    .description
        read saved values
    .notes
        returns either [hashtable] if -All
        else returns FullPath as string
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
                if (!($_dotfilePath.Contains($Label))) {
                    Write-Error "KeyNotFound: '$Label'"
                    break
                }

                # $_dotfilePath[$Label].FullPath | ForEach-Object tostring
                $_dotfilePath[$Label]
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


    h1 'Section: Powershell'
    Start-DotfileCollect
    h1 'Section: VS Code'
    h1 'Done'


}

# # function _test1 {
# Add-DotfilePath -Label 'vs-code' -Path 'vscode\.auto_export'
# # Add-DotfilePath -Label 'vs-code-snippets' -Path 'snippets' -RelativeTo 'vs-code'
# Get-DotfilePath -ListAll
# $result = Get-DotfilePath -Label 'vs-code-snippets'
# }
# _test1



