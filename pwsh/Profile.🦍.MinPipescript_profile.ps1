#Requires -Version 7
# stand alone scrip so that it can be ran with pwsh -File from build scripts
'NoProfile min pipescript: {0}' -f $PSCommandPath | Write-verbose

if (-not $Profile.'CurrentUserPipe🐍Profile' ) {
    $Profile | Add-member -NotePropertyName 'CurrentUser🐍Profile' -value (gi $PSCommandPath) -ea ignore -Force
}

$PipeConfig = @{
    ImportModules = @(
        'PSReadLine',
        'Pansies',
        'ugit',
        'Pipescript'
        # 'GitLogger'
    )
    ErrorHandling = @{
        AlwaysCatchImports = $false
    }
}

$Script:__pipeProfile_State = @{
    Dt_LastInvoke = [datetime]::Now
}

function __init__pipeProfile_Alias {
    # alias to always load
    [CmdletBinding()]
    param()
    $alias_Splat = @{
        ErrorAction = 'ignore'
        PassThru    = $true
    }
    @(
        Set-Alias @setAliasSplat 'Sc'        -Value Set-Content
        Set-Alias @setAliasSplat 'Gc'        -Value Get-Content
        Set-Alias @setAliasSplat 'impo'      -Value Import-Module
        Set-Alias @setAliasSplat 'Gcl'       -Value Get-ClipBoard
        Set-Alias @setAliasSplat 'Cl'        -Value Set-Clipboard
        Set-Alias @setAliasSplat 'Json'      -Value ConvertTo-Json
        Set-Alias @setAliasSplat 'Json.From' -Value ConvertFrom-Json

    ) | Join-String -op '-Nop Pipe🐍 + Aliases: ' -sep ', '
        | Write-verbose -verbose
}

function __init__pipeProfile_Fancy {
    <#
    .SYNOPSIS
        for cases that start as a pipescript session that then want to be  interactive
    #>
    [Alias('PipeSess.ImportFancy')]
    param()
    $impo_Splat = @{
        PassThru = $True
        # Force = $True
        ea = 'Continue'
    }

    @(  Import-Module @impo_Splat -name CompletionPredictor
        Import-Module @impo_Splat -name ClassExplorer
    ) | Join-String

}

function __init__pipeProfile_Keybinds {
    param()
    Set-PSReadLineKeyHandler -Chord 'Alt+Enter'   -Function InsertLineBelow
    Set-PSReadLineKeyHandler -Chord 'Shift+Enter' -Function InsertLineAbove
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r'      -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Chord 'Ctrl+a'      -Function SelectAll
    Set-PSReadLineKeyHandler -Chord 'Ctrl+z'      -Function Undo
    Set-PSReadLineKeyHandler -Chord 'Alt+a'       -Function SelectCommandArgument
    Set-PSReadLineKeyHandler -Chord 'Shift+Alt+?' -Function WhatIsKey
}
function __init__pipeProfile_Modules {
    param(
        [string[]]$ModuleNames
    )
    foreach($name in $ModuleNames) {
        try {
            Import-Module $Name -force -PassThru -ea 'stop'
        } catch {
            'Import failed for module: {0} from {1}' -f $Name, $PSCommandPath
                | Write-warning

            if ( -not  $PipeConfig.ErrorHandling.AlwaysCatchImports ) {
                throw $_
            }
        }
    }
}

function __init__pipeProfile_EntryPoint {
    param()
    __init__pipeProfile_Modules
    __init__pipeProfile_Alias
    __init__pipeProfile_Keybinds

}
function Dotils.Invoke-NoProfilePwsh {
    <#
    .SYNOPSIS
        quickly start a new no-profile with minimal presets
    .EXAMPLE
        Dotils.Quick.NoProfilePwsh
    #>
    [Alias('Dotils.Quick.NoProfilePwsh', 'Quick.Pwsh.Nop')]
    param(
        [ArgumentCompletions(
            'Pipescript', 'ugit', 'Pansies', 'Dotils'
        )]
        [string[]]$ImportModuleNames

    )
    'starting pwsh --NoProfile...' | write-host -fore green
    pwsh -NoP -NoLogo -NoExit -Command {
        $global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module
        # get-date | write-verbose
        if( -not $ImportModuleNames ) {
            $ImportModuleNames = 'Pansies', 'Pipescript', 'ugit'
        }
        # normal defaults
        Set-PSReadLineKeyHandler -Chord 'Alt+Enter'   -Function InsertLineBelow
        Set-PSReadLineKeyHandler -Chord 'Shift+Enter' -Function InsertLineAbove
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
        Set-PSReadLineKeyHandler -Chord 'Ctrl+a' -Function SelectAll
        Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
        Set-PSReadLineKeyHandler -Chord 'Alt+a' -Function SelectCommandArgument


        # Import-Module -Name $ImportModuleNames -PassThru -Verbose # using scope issue?
    }
}
function __init__pipeProfile_Prompt.1Liner {@( "`n"; $PSStyle.Foreground.FromRgb('#6e6e6e'); Get-Location; "`n"; '> '; $PSStyle.Reset; ) -join ''}
function Prompt {
    # minimal prompt mainly for pipescript evaluations
    param()
    $now   = [Datetime]::Now
    $delta = $now - $script:__pipeProfile_State.Dt_LastInvoke
    $script:__pipeProfile_State.Dt_LastInvoke = $Now
    @(
        "`n"
        if( $global:error.count -gt 0 ) {
            $PSStyle.Foreground.FromRgb('#6e3344')
            $global:error.count
        }
        "`n"
        $PSStyle.Foreground.FromRgb('#6e6e6e')
        (get-date).ToShortTimeString()
        ': '
        $PSStyle.Foreground.FromRgb('#9e9e9e')
        Join-String -f '{0:n0} ms' -In $delta -Property TotalMilliseconds
        ', or '
        Join-String -f '{0:n2} min ' -In $delta -Property TotalMinutes
        "`n"
        Get-Location
        "`n"
        'Pipe🐍> '
        $PSStyle.Reset
    ) -join ''}

# @(  Import-Module 'pansies'
#     Import-Module $importModulenames -pass
# # )   | Join-string -sep ', ' -prop { $_.Name, $_.Version -sep ': ' }
# )   | Join-string -sep ', '
#     | Write-host -fore green
# get-date | write-verbose


# if( -not ( gcm -CommandType 'alias' 'Gcl.Gi' -ea 'ignore')) {
#     # this might cause slowdown, skip it
#     # polyfill
#     function __polyfill_pipeProfile_GetClipboardItemInfo {
#         <#
#         .SYNOPSIS
#             sugar for resolving path as an object from the paste
#         .EXAMPLE
#             # normal usage. Goto flag saves you one step:
#             Pwsh> $file = Gcl.Gi
#             Pwsh> Pushd $File.Directory
#             # Also saves last value to $gi

#         .EXAMPLE
#             Pwsh> 'C:\Users\cppmo_000\AppData\Local\Microsoft\Windows' | Set-Clipboard
#             Pwsh> Gcl.Gi
#             # prints: gi =: C:\Users\cppmo_000\AppData\Local\Microsoft\Windows
#         .EXAMPLE
#             Pwsh> # error terminates pipeline if not valid path
#             Gcl.Gi | Goto

#             Pwsh> # error terminates pipeline if not valid path
#             __polyfill_pipeProfile_GetClipboardItemInfo | %{ Test-Path $_ }
#         #>
#         [Alias('__pipeProfile.Gcl.GetItem', 'Gcl.Gi')]
#         [OutputType('System.IO.FileSystemInfo')]
#         param(
#             [Alias('AutoPushD', 'Pushd')]
#             [switch]$GotoFolder
#         )
#         $target =  Get-Clipboard
#         if( -not (Test-Path $Target)) {
#             $maybe_target = $target -replace '^[''"]', '' -replace '[''"]$', ''
#             if(test-Path $maybe_target) {
#                 $target = $maybe_target
#                 write-verbose 'found valid, quoted path. cleaning...'
#             }
#         }
#         $global:gi  = $target | Get-Item -ea 'stop'
#         $target | write-verbose

#         # write console, but also return GI as well
#         $global:gi ?? "`u{2400}"
#             # | Dotils.Format.Write-DimText
#             | Join-String -op 'gi =: '
#             # | wInfo

#         if(Test-Path $global:gi) {
#             if($GotoFolder) {
#                 $global:gi  | Ninmonkey.Console\Set-NinLocation
#             }
#         } else {
#             'path is not valid: {0}' -f @( $Global:gi ?? "`u{2400}" )
#                 | write-error
#             return
#         }
#         return $global:gi
#     }
# }
