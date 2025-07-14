using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Globalization
using namespace System.Text
using namespace Microsoft.PowerShell
# $global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module

# function Prompt {
#     # non-pansies prompt, overwritten below.
#     param()
#     return @(
#         "`n"
#         (Get-Location)
#         "`nWinPS5> "
#     ) -join ''
# }

if( $PSVersionTable.PSVersion.Major -lt 7 ) {
    'Current file expected to only run for WinPowershell, not Pwsh! Source = <file:///{0}> ( Continue for now )' -f $PSCommandPath
        | Write-Warning

}

$PROFILE | Add-Member -NotePropertyMembers @{
    Nin_PS5_Profile           = gi $PSCommandPath
    Nin_Dotfiles              = Get-Item $PSCommandPath | Split-path
    Nin_Profile_TypeAccelDefininitions      = $PSCommandPath | Gi
    # # 'CurrentUser🐍Profile'  = (Join-Path $PSScriptRoot 'Profile.🦍.MinPipescript_profile.ps1' | gi )
    # KnownLogpaths             = 'H:\data\2024\pwsh\gists🦍\Big List of Locations of Known Log Files.🦍.2024.md\LogPaths.yml'
} -Force -ea Ignore

if( $PSVersionTable.PSEdition -eq 'Core' ) {
    'Reached WinPS5 import, unexpectedly from pwsh. from: "{0}" ' -f $PSCommandPath |
        write-warning
    return
}

$WinPS5Config = @{
    Enable_AwsCli = $true # load aws cli environment
    AlwaysImportModules = @(
        # 'pansies' # already always
        'ugit'
    )
    StartingDirectory = 'H:\data\2024\pwsh\sketch'
}

$ColorWinPs = @{
    DimGray_Fg = 'Gray50'
    DimGray_Bg = 'Gray30'
    DimTan_Fg  = 'tan'
}
$ColorSplat_DimGray = @{
    Fg = $ColorWinPs.DimGray_Fg
    Bg = $ColorWinPs.DimGray_Bg
}
$ColorSplat_DimOrange = @{
    Fg = $colorWinPS.DimTan_Fg
    Bg = $ColorWinPs.DimGray_Bg
}
$ColorSplat_DimRed = @{
    Fg = '#b99f09' # '#c98f57'
}
Import-Module 'Pansies' -ea 'continue'

if( $WInPs5Config.Enable_AwsCli ) {
    $ENV:PATH = @(
        $Env:PATH
        gi 'G:\2023-git\Aws📁\aws-copilot-cli'
    ) -join ';'

}
$e  = [char]0x1b
$rl = [Microsoft.PowerShell.PSConsoleReadLine]
if( $null -eq $script:xl8r ) {
    $script:xl8r = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
}
# # $xl8r::Add( 'JsonSerializer', [Text.Json.Serialization.JsonSerializerContext] )
$xl8r::Add('Rgb', [PoshCode.Pansies.ColorSpaces.Rgb] )
$xl8r::add('LinqE',       [Linq.Enumerable])
$xl8r::Add('Sb',           [Text.StringBuilder])
$xl8r::Add('EncInfo',      [Text.EncodingInfo])
$xl8r::Add('RL',           [Microsoft.PowerShell.PSConsoleReadLine])
$xl8r::Add('RL_GetOpt',    [Microsoft.PowerShell.GetPSReadLineOption])
$xl8r::Add('RL_SetOpt',    [Microsoft.PowerShell.SetPSReadLineOption])
$xl8r::Add('RL_SetHandler',[Microsoft.PowerShell.SetPSReadLineKeyHandlerCommand]) # there is no get-handler
$xl8r::Add('LangyPrims',   [System.Management.Automation.LanguagePrimitives]) # there is no get-handler

# [Sb], [RL], [RL_GetOpt], [RL_SetOpt], [RL_SetHandler], [RL_OnImport], [LangyPrims]
#     | Join-string -sep ',' -op 'Setting Accelerators: { RL, RL_GetOpt, RL_SetOpt, RL_SetHandler, RL_OnImport } => { ' -os ' } '

(Import-module $WinPS5Config.AlwaysImportModules -PassThru |
    %{ $_.Name, $_.Version -join ': ' }) -join ', ' |
    Write-Host @ColorSplat_DimOrange

# warning: Don't use -Desc with -Function in WinPS5, else throws
Set-PSReadLineKeyHandler -Chord 'Tab' -Function MenuComplete
# Ideal, but breaks cursor locations:
#   Set-PSReadLineOption -ContinuationPrompt (New-Text '  ' -bg 'gray15')
# Works enough:
Set-PSReadLineOption -ContinuationPrompt '  '
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineKeyHandler -Chord 'Ctrl+@' -Function 'MenuComplete'
Set-PSReadLineKeyHandler -Chord 'Ctrl+Spacebar' -Function 'MenuComplete'

### [2024-11] updated PS5 enter commands

'Enter: multi, ctrl+enter: submit, ctrl+alt+enter: line before' | Write-Verbose -verb
Set-PSReadLineKeyHandler -Key enter -Function InsertLineBelow
Set-PSReadLineKeyHandler -Key ctrl+enter -Function AcceptLine
Set-PSReadLineKeyHandler -Key ctrl+alt+enter -Function InsertLineAbove


Set-PSReadLineOption -CompletionQueryItems 128

# ## global aliases
@(
    # Set-Alias -passThru 'Label' -value 'Ninmonkey.Console\Write-ConsoleLabel'
    Set-Alias -passThru -ea 'ignore' 'impo' -value 'Import-Module'
    Set-Alias -passThru -ea 'ignore' 'cl' -value  'Set-Clipboard'
    Set-Alias -passThru -ea 'ignore' 'gcl' -value 'Get-Clipboard'
    # Set-Alias -passThru -ea 'ignore' 'shot' -Value 'Microsoft.PowerShell.ConsoleGuiTools\Show-ObjectTree' -Description 'View nested objects, like pester config'
    # Set-Alias -PassThru 'Encoding' -value Dotils.To.Encoding
).forEach({
   "`n - {0}" -f $_.DisplayName
}) -join '' | New-Text @ColorSplat_DimOrange | % ToString

function Prompt {
    # WinPS5 version, with pansies loaded
    param()

    [string] $Render = @(
        Hr
        "`n"
        if($false) {  // not working
            if ( $global:Error.Count -gt 0 ) {
                'Err: {0} ' -f $Global:Error.Count |
                    New-Text @ColorSplat_DimRed | % tostring
                "`n"
            }
        }
        '' | New-Text @ColorSplat_DimGray | % tostring
        (Get-Location | New-Text @ColorSplat_DimGray | % tostring)
        '' | New-Text @ColorSplat_DimOrange | % tostring
        "`nWinPS5${fg:clear}${bg:clear}>"
    ) -join ''
    return $render
}

# if( -not (gcm 'Gcl.Gi' -ea ignore)) {
    function Gcl.Gi {
        <#
        .SYNOPSIS
            returns null if item is not valid, and sets $Global:Gi to the result
        .EXAMPLE
            WinPS> Gi . | Gcl.GI
            WinPS> $LogPath = Get-ClipBoard | Gcl.Gi
        #>
        param(
            [Parameter(ValueFromPipeline)]
            $InputObject
        )
        process {
            if( [String]::IsNullOrWhiteSpace( $InputObject ) ) {
                $InputObject = @( Get-Clipboard )
                'Falling back to clipboard: "{0}"' -f $InputObject |
                    Write-Host @ColorSplat_DimGray
            }

            $rawName = @( $InputObject | Select-Object -first 1 )
            $Name = Get-Item -ea 'continue' $rawName

            if( -not $Name  ) {
                'NoMatch for Get-Item "{0}"' -f $RawName |
                    Write-Host @ColorSplat_DimGray
                return
            }

            if( $Name  ) {
                $Global:Gi = $Name
                'SetMatch: $Gi = "{0}"' -f $Name.FullName |
                    Write-Host @ColorSplat_DimOrange
                return $Name
            }
        }
    }
# }
# if( -not (gcm 'Err' -ea ignore)) {
    function Err {
        <#
        .SYNOPSIS
            Get/Show/Export errors
        .EXAMPLE
            WinPS> Gi . | Gcl.GI
            WinPS> $LogPath = Get-ClipBoard | Gcl.Gi
        #>
        [Alias('WinPS5.Hr')]
        param( [switch]$Clear )
        if( $Clear ) { $Error.Clear() ; return }

        @(
            "Errors: "
            $global:Error.count |
                New-Text @ColorSplat_DimRed | % ToString

            $error.ForEach( { "`n  > {0}" -f $_.tostring() }
                ) -join '' |
                    New-Text @ColorSplat_DimOrange | % ToString
        ) -join ''
    }
# }
function Hr {
    <#
    .SYNOPSIS
        Horizontal rule, exact width of screen
    .EXAMPLE
        WinPs> hr
        WinPs> Hr -Before 3
        WinPs> hr 0 0
    #>
    [Alias('WinPS5.Hr')]
    param(
        [int] $Before = 1,  [int] $After = 1
    )
    $w = $host.ui.RawUI.WindowSize.Width
    $chars = '-' * $w -join ''
    $padding = "`n" * 2

    [string] $rend = @(
        "`n" * $Before # $padding
        $chars
        "`n" * $After # $padding
    ) -join '' |
        New-Text -fg 'gray30'

    return $rend
}

Pushd $WinPS5Config.StartingDirectory
