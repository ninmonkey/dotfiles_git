Import-Module -Force "$PSScriptRoot/powershell/collect_dotfiles/CollectDotfiles.psd1" # -Verbose
# now: Simply invoke module / and / or configure
h1 'collect_dotfiles.ps1'
# Set-DotfileRoot $PSScriptRoot -Verbose # or '.' ?

function Write-DotfileLog {
    <#
    .SYNOPSIS
    tiny wrapper, allows global disable of log, or just ignore write-information

    .DESCRIPTION
    Pretty print to console, does not save files

    .EXAMPLE
    PS> (Get-Date) | LogIt 'Now' -informa Continue

    .NOTES
    General notes
    #>
    [Alias('LogIt')]
    param(
        # Text to log
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string[]]$Text,

        [Parameter(Mandatory, Position = 0)]
        [string]$Label


    )

    begin {
        $allLines = [string[]]::new()
    }
    Process {
        foreach ($line in $Text ) {
            $allLines.add( $line )

        }
        end {
            $allLines
            | Join-String -sep "`n"
            | Write-ConsoleLabel $Label #-Label $Label
            | Write-Information
        }
    }
}



function _staticCopyDotfiles {
    # [hashtable]$Paths = @{}
    # $Paths.'vscode_global_settings' = 'C:\Users\cppmo_000\Documents\2021\dotfiles_git\vscode\settings_global\nin10_desktop\.autoexport\code ⇢ settings.json ┐ nin10_Desktop.json'
    'manual write-info' | Write-Information
    'LogIt write-info' | LogIt

    $pathRelativeDotfilesRoot = 'vscode\settings_global\nin10\.autoexport\code ⇢ settings.json ┐ nin10.json'


    $src_file = "$env:AppData\Code\User\settings.json"
    $dest_file = "$Env:UserProfile\Documents\2021\dotfiles_git\vscode\settings_global\nin10\.autoexport\code ⇢ settings.json ┐ nin10.json"
    $dest_fileDirectory = $dest_file | Split-Path
    $copyFile_splat = @{
        Path        = $src_file
        Destination = $dest_file
        # Path        = "$env:AppData\Code\User\settings.json"
        # Destination_file = 'C:\Users\cppmo_000\Documents\2021\dotfiles_git\vscode\settings_global\nin10\.autoexport\code ⇢ settings.json ┐ nin10.json'
    }

    if (!(Test-Path $copyFile_splat.Destination)) {
        $newItemSplat = @{
            Path     = $dest_fileDirectory
            ItemType = 'Directory'
        }
        Write-Warning 'debugger was getting stuck, verify it'
        $x = 3
        New-Item @newItemSplat #-Confirm -Verbose
    }
    $newItemSplat | Format-HashTable -FormatMode 'SingleLine'
    | LogIt
    $newItemSplat | Format-HashTable
    | Write-Information

    Copy-Item @copyFile_splat # -Confirm -Force -Verbose
}
Write-Warning 'temp hardcoded test to use manual path only'
Write-Warning ' refactor profile from:
    "C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell"
'



if ($false) {
    throw 'double check before run'
    Reset-DotfilePath
    Set-DotfileRoot '.'

    h1 'config'

    Add-DotfilePath 'vscode-snippets' 'vscode/.auto_export/snippets'

    h1 'ListAll'
    Get-DotfilePath -ListAll
}