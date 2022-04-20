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
}
# ls $Env:AppData\fd -Force -Depth 3 -Name
$meta

Write-Warning "Invoke->LogCollect '$PSCommandPath'"

Write-Verbose "Invoke->LogCollect '$PSCommandPath'"

# refactor to unified build