function Reset-DotfilePath {
    $script:_dotfilePath = @{
        # BasePath = Get-Item -ea stop $PSScriptRoot | ForEach-Object tostring
        Root = @{
            Label        = 'Root'
            RelativePath = '.'
            Path         = $null #$null $PSScriptRoot | Get-Item -ea stop # nnow in a module, does this break?
        }
    }
}