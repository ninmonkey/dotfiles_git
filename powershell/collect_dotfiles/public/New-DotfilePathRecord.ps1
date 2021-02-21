
function New-DotfilePathRecord {
    <#
    .synopsis
        generates a new structured record
    .notes
        future: allow caller to decide write-error stops or not
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
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
    $record = @{
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
