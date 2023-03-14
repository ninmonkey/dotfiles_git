$meta = @{
    WhoAmI       = 'everythingSearch'
    Urls         = @(
        'https://www.voidtools.com/support/everything/command_line_options/'
        'https://www.voidtools.com/support/everything/searching/#search_commands' # exports config
        'https://www.voidtools.com/support/everything/command_line_interface/'
        'https://www.voidtools.com/support/everything/file_lists/'
        'https://www.voidtools.com/support/everything/searching/#functions'
    )
    CollectPaths = @(
        @{
            Description = 'run ? /config_save <filename>'
            # Path        = Get-Item   "$Env:AppData\bat"
        }
    )
}
# ls $Env:AppData\fd -Force -Depth 3 -Name
$meta

Write-Warning "Invoke->LogCollect '$PSCommandPath'"

Write-Verbose "Invoke->LogCollect '$PSCommandPath'"

# refactor to unified build

