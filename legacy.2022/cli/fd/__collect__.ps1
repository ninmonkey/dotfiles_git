$meta = @{
    WhoAmI       = 'fd find'
    Urls         = @(
        'https://www.voidtools.com/support/everything/command_line_options/'
        'https://www.voidtools.com/support/everything/searching/#search_commands' # exports config
        'https://www.voidtools.com/support/everything/command_line_interface/'
        'https://www.voidtools.com/support/everything/file_lists/'
        'https://www.voidtools.com/support/everything/searching/#functions'
    )
    CollectPaths = @(
        @{
            Path = Get-Item "$Env:AppData\fd"
            # Path        = Get-Item   "$Env:AppData\bat"
        }
    )
    CollectItems = @(
        @{
            Path        = Get-Item "$Env:AppData\fd\ignore"
            Destination = $PSScriptRoot
        }
    )
}

& {
    $InformationPreference = 'continue'
    # $VerbosePreference = 'silentlyContinue'
    $meta | Format-Table -AutoSize -Wrap

    # Write-Warning "Invoke->LogCollect '$PSCommandPath'"
    # Write-Verbose "Invoke->LogCollect '$PSCommandPath'"
    @"
"Invoke->LogCollect '$PSCommandPath'"
    Context
"@
    | Write-Information


    $Meta.CollectItems | ForEach-Object {
        $item = $_
        Copy-Item $item.Path -Destination $item.Destination #-Verbose
        @"
CopyItem ->
    from: $($item.Path)
    dest: $($item.Destination)
"@ | Write-Information
    } -infa continue

}

# Get-ChildItem .
# refactor to unified build

