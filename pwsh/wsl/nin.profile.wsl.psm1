# dsf((gc -raw /proc/cpuinfo) -split '\n{2}') | %{
#     "`n### Group ## `n"
#     $group = [ordered]@{}
#     $_ -split '\n' | %{
#         $k, $v = $_ -split ': ', 2
#         $group[ $k ] = $v
#     }
#     [pscustomobject]$group
# }
$Colors = @{
    Fg1 = $PSStyle.Foreground.FromRgb( 0xFF74886E )
    Fg2 = $PSStyle.Foreground.FromRgb( 0xFF618994  )
    FgGreen = '#74886e'
    DimGray = '#434344'
    FgDimFav = '#6d7588'
}

$PROFILE
    | Add-Member -ea ignore -Force -PassThru -NotePropertyMembers @{
        'Nin.Module'          = Get-Item $PSCommandPath
        'Nin.ModuleRoot'      = Get-Item $PSSCriptRoot
        'Nin.ProfileRoot'     = (Join-Path '~' 'nin/.config/powershell')
        'Nin.DotfilesNinRoot' = (Join-Path '~' 'nin')
    }
    | Out-Null

function nix.DefaultPrompt {
    <#
    .synopsis
        minimal basic prompt
    #>
    $Colors = @{
        Fg1 = $PSStyle.Foreground.FromRgb( 0xFF74886E )
        Fg2 = $PSStyle.Foreground.FromRgb( 0xFF618994 )
    }
    @(
        "`n"
        $Colors.Fg1
        "nix $($executionContext.SessionState.Path.CurrentLocation)"
        "`n"
        $Colors.fg2
        "$('>' * ($nestedPromptLevel + 1)) ";
        $PSStyle.Reset


    ) | Join-String -sep ''
}


function Module.Tips {
@'
try commands:

    $Profile.<tab>
    function Prompt { nix.DefaultPrompt }
    gcm -m nin.profile.wsl
    gcm 'nix.*'


    nix.DefaultPSReadLineKeyhandlers (if not auto)
'@
}
function nix.DefaultPSReadLineKeyhandlers {
    'invoke => nix.DefaultPSReadLineKeyhandlers' | write-verbose -verb
    Set-PSReadLineKeyHandler -Key Ctrl+Enter -Function AcceptLine
    Set-PSReadLineKeyHandler -Key Enter -Function AddLine
}
function Module.OnInit {
    Module.Tips
        | Join-String -op $Colors.FgDimFav | Write-Host

    nix.DefaultPSReadLineKeyhandlers
}

Module.OnInit

Export-ModuleMember -Func @(
    'nin.*'
    'nix.*'
    'nix*'
    '*-nin*'
) -Alias @(
    'nin.*'
    'nix.*'
    'nix*'
    '*-nin*'
) -variable @(
    'nin*'
    'nix*'
    '*nin_*'
)
