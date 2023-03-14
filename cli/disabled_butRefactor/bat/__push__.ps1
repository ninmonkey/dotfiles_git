$eaIgnore = @{
    ErrorAction = 'Ignore' #'silentlyContinue'
}
$maybeFile = Invoke-NativeCommand 'bat' -args @('--config-file')

Write-Warning 'this is a sketch, not a real file'

if (! (Test-Path $MaybeFile )) {
    '<nyi>Prompt user -> Generate Template using "bat --generate-config-file'

}

& {
    Write-Warning "'$PSCommandPath' : this whole Env Var blcok is untested, and should use wrappers for consistant state tests"
    $SetEnvVars = $true
    if ($SetEnvVars) {
        $ENV:BAT_CONFIG_PATH = Get-Item @eaIgnore (Join-Path $PSSCriptRoot '.batrc')

    }
    if (! (Test-Path $Env:BAT_CONFIG_PATH)) {
        $maybeRelative = Get-Item $Env:Nin_Dotfiles\cli\bat\.batrc @eaIgnore
        if ($maybeRelative) {
            $Env:BAT_CONFIG_PATH = $MaybeRelativePath
        }
    }
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

    )
    CollectPaths = @(
        Path = Get-Item "$env:AppData\bat" @eaIgnore
        Path =Invoke-NativeCommand @eaIgnore 'bat' @('--config-dir') | Get-Item @eaIgnore


    )

}