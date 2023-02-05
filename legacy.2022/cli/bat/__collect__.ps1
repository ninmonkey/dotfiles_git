$eaIgnore = @{
    ErrorAction = 'Ignore' #'silentlyContinue'
}
$meta = @{
    WhoAmI       = 'bat'
    Urls         = @(
        'https://github.com/sharkdp/bat/blob/master/README.md'
        'https://github.com/sharkdp/bat'
    )
    Help         = @'


bat --generate-config-file
bat --config-dir
bat --config-file
BAT_CONFIG_PATH = "/path/to/bat.conf"

    help: -h , --help

    good default

        ... | bat -fpl <language>

Note: By default, if the pager is set to less (and no command-line options are specified), bat will pass the following command line options to the pager: -R/--RAW-CONTROL-CHARS, -F/--quit-if-one-screen

 - env var docs:
    - https://github.com/sharkdp/bat#customization
    - new themes and filetype associations <https://github.com/sharkdp/bat#adding-new-themes>

- https://github.com/sharkdp/bat/blob/master/README.md
- bat-extras
    - for examples: <https://github.com/eth-p/bat-extras/tree/master/doc>
    - <https://github.com/eth-p/bat-extras/blob/master/src/batman.sh>


'@
    EnvVars      = @(
        @{
            Key      = 'BAT_STYLE'
            Help     = ''
            Urls     = @( 'https://github.com/sharkdp/bat/blob/master/README.md#output-style' )
            Examples = @(
                '--style=numbers,changes'
            )
        }
    )
    CollectItems = @(

        Path =Invoke-NativeCommand @eaIgnore 'bat' @('--config-dir') | Get-Item @eaIgnore
        Destination = gi (Join-Path $PSSCriptRoot '.batrc')

    )
    CollectPaths = @(
        Path = Get-Item "$env:AppData\bat" @eaIgnore
        Path =Invoke-NativeCommand @eaIgnore 'bat' @('--config-dir') | Get-Item @eaIgnore


    )

}

$meta

Write-Warning "Invoke->LogCollect '$PSCommandPath'"

Write-Verbose "Invoke->LogCollect '$PSCommandPath'"

return
# refactor to unified build

# $meta = @{
#     WhoAmI       = 'fd find'
#     Urls         = @(
#         'https://www.voidtools.com/support/everything/command_line_options/'
#         'https://www.voidtools.com/support/everything/searching/#search_commands' # exports config
#         'https://www.voidtools.com/support/everything/command_line_interface/'
#         'https://www.voidtools.com/support/everything/file_lists/'
#         'https://www.voidtools.com/support/everything/searching/#functions'
#     )
#     CollectPaths = @(
#         @{
#             Path = Get-Item "$Env:AppData\fd"
#             # Path        = Get-Item   "$Env:AppData\bat"
#         }
#     )
# # }

# & {
#     $InformationPreference = 'continue'
#     # $VerbosePreference = 'silentlyContinue'
#     $meta | Format-Table -AutoSize -Wrap

#     # Write-Warning "Invoke->LogCollect '$PSCommandPath'"
#     # Write-Verbose "Invoke->LogCollect '$PSCommandPath'"
#     @"
# "Invoke->LogCollect '$PSCommandPath'"
#     Context
# "@
#     | Write-Information


#     $Meta.CollectItems | ForEach-Object {
#         $item = $_
#         Copy-Item $item.Path -Destination $item.Destination #-Verbose
#         @"
# CopyItem ->
#     from: $($item.Path)
#     dest: $($item.Destination)
# "@ | Write-Information
#     } -infa continue

# }

# # Get-ChildItem .
# # refactor to unified build

