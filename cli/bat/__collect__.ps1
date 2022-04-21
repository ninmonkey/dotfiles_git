$meta = @{
    WhoAmI = 'bat'
    Urls   = @(
        'https://github.com/sharkdp/bat/blob/master/README.md'
    )
}

$meta

Write-Warning "Invoke->LogCollect '$PSCommandPath'"

Write-Verbose "Invoke->LogCollect '$PSCommandPath'"

# refactor to unified build