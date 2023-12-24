# 2023-12-24
$modPath?   = Get-Item '/home/nin/.config/powershell/nin.profile.wsl.psm1'
$modPath? ??= Join-Path '~/nin/.config/powershell' 'nin.profile.wsl.psm1'
$modPath? ??= Join-Path $PSScriptRoot 'nin.profile.wsl.psm1'
@(
    if( $mod = Get-Item $ModPath? ) {
        'Loading nin.profile.wsl.psm1...'
        Import-Module $mod -force -PassThru | Join-String -P { $_.Name, $_.Version -join ': '}
    } else {
        'Could not find nin.profile.wsl.psm1...'  | write-error
    }
) | Join-String -op $PSStyle.Foreground.FromRgb( '#6d7588' ) # '#434344'


function prompt_basic_nomodule {
    # minimal, but decent with colors and prompt at fixed location
    @(
    $Colors = @{
        Fg1 = $PSStyle.Foreground.FromRgb( 0xFF74886E )
        Fg2 = $PSStyle.Foreground.FromRgb(  0xFF618994  )
    }
    "`n"
    $Colors.Fg1
    "nix $($executionContext.SessionState.Path.CurrentLocation)"
    "`n"
    $Colors.fg2
    "$('>' * ($nestedPromptLevel + 1)) ";
    $PSStyle.Reset
) | Join-String }
