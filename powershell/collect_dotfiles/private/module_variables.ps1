
$_dotfilePath = [ordered]@{
    # BasePath = Get-Item -ea stop $PSScriptRoot | ForEach-Object tostring
    Root = [ordered]@{
        Label        = 'Root'
        RelativePath = '.'
        FullPath     = $null #$null $PSScriptRoot | Get-Item -ea stop # nnow in a module, does this break?
    }
}
