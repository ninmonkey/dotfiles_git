
$_dotfilePath = @{
    # BasePath = Get-Item -ea stop $PSScriptRoot | ForEach-Object tostring
    Root = @{
        Label        = 'Root'
        RelativePath = '.'
        FullPath     = $null #$null $PSScriptRoot | Get-Item -ea stop # nnow in a module, does this break?
    }
}
