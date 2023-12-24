using namespace System.Collections.Generic


$Colors = @{
    Fg1      = $PSStyle.Foreground.FromRgb( 0xFF74886E )
    Fg2      = $PSStyle.Foreground.FromRgb( 0xFF618994 )
    FgGreen  = $PSStyle.Foreground.FromRgb( '#74886e' )
    DimGray  = $PSStyle.Foreground.FromRgb( '#434344' )
    FgDimFav = $PSStyle.Foreground.FromRgb( '#6d7588' )
    DimRed   = $PSStyle.Foreground.FromRgb( '#af6365' )
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
    [Alias('nin.DefaultPrompt')]
    param()
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
        ($global:error.count -gt 0) ?
            ($global:Error.Count | Join-String -op $Colors.DimRed) : ''


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

function nix.Stats.GetCpuInfo {
    # Read /proc/cpuinfo, return as objects
    $Path = Get-Item '/proc/cpuinfo'
    ((Get-Content $Path -raw ) -split '\n{2}')
    | ?{ -not [string]::IsNullOrWhiteSpace( $_ ) }
    | %{
        "Group" | write-Debug
        $group = [ordered]@{
            PSTypeName = 'nin.nix.Stats.CpuInfo'
        }
        $_ -split '\n' | %{
            $_ | write-Debug
            $k, $v = $_ -split ': ', 2
            $k = $k -replace '\s+$', ''
            if( [string]::IsNullOrEmpty( $v )) {
                $v = "`u{2400}"
            }
            $group[ $k ] = $v
        }
        [pscustomobject]$group
    }
}

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

Module.OnInit
