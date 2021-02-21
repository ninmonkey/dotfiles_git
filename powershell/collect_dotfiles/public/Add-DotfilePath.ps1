
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

    if ($RelativeTo) {
        throw "wip: Add-DotfilePath: -RelativeTo" ;
        return
    }

    $pathRecord = New-DotfilePathRecord -Label $Label -RelativePath $Path
    $pathRecord | Format-HashTable | Write-Debug

    if ($_dotfilePath.ContainsKey($Label)) {
        Write-Error "KeyAlreadyExists: '$Label'"
        return
    }

    $_dotfilePath.Add( $Label, $pathRecord )
}
