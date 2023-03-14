$meta = @{
    Urls         = @(
        'https://github.com/junegunn/fzf#preview-window'
        'https://github.com/junegunn/fzf#executing-external-programs' # env vars etc
    )
    CollectPaths = @(
        @{
            Description = '...'
            # Path        = Get-Item   "$Env:AppData\bat"
        }
    )
    Notes        = @'

# preview mode with bat

    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'

        first N lines for speed

'@
}
# ls $Env:AppData\fd -Force -Depth 3 -Name
$meta

Write-Warning "Invoke->LogCollect '$PSCommandPath'"

Write-Verbose "Invoke->LogCollect '$PSCommandPath'"

# refactor to unified build