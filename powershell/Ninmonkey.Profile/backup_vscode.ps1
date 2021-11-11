#Requires -Version 7
#Requires -Module Ninmonkey.Console
#Requires -Module Pansies

function Backup-VSCode {
    <#
    .synopsis
        backup dotfiles to git
    .description
        .
    .example
        PS> Backup-VSCode
    .example
        PS> Backup-VSCode -infa Continue -Options @{'FileListFormat' = 'ul' }
        Backup-VSCode -infa Continue -Options @{'FileListFormat' = 'csv' }
        
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # profile data dir root to import
        [Parameter(Position = 0)]
        [string]$SourcePath,

        # root to export to
        [Parameter(Position = 0)]
        [string]$DestPath,

        # WhatIf
        [Parameter()][switch]$WhatIf,

        # Test, like whatif, without built in messages (ie: readability)
        [Parameter()][switch]$TestOnly,

        # extra options, kwargs
        [Parameter()][hashtable]$Options
    )
    begin {
        # [hashtable]$ColorType = Join-Hashtable $ColorType ($Options.ColorType ?? @{})       
        [hashtable]$Config = @{
            FileListFormat = 'ul' # 'csv' # 'csv' # 
            # AlignKeyValuePairs = $true
            # Title              = 'Default'
            # DisplayTypeName    = $true
        }
        $Config = Join-Hashtable $Config ($Options ?? @{})        
        $ColorStyle = @{
            'dim'        = @{
                Fg = 'gray70'
                Bg = 'gray20'
            }
            'boldOrange' = @{
                Fg = 'gray70'
                Bg = 'gray20'
            }
        }
    }
    process {
        <#
        This example copies the contents of the C:\Logfiles directory into the existing C:\Drawings directory. The Logfiles directory isn't copied.

            If the Logfiles directory contains files in subdirectories, those subdirectories are copied with their file trees intact. By default, the Container parameter is set to True, which preserves the directory structure.
            PowerShell

            Copy-Item -Path "C:\Logfiles\*" -Destination "C:\Drawings" -Recurse

        #>
        New-Text -fg yellow "`n`nBacking up VS Code ---------------------------`n" | Write-Host

        # $dest = Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\vscode\User\nin10\Code'
        $dotfileRoot = Get-Item -ea stop "$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git\vscode\User\nin10"
        $dotfileRoot | to->RelativePath -BasePath $env:Nin_Dotfiles
        | prefix '$dotfileRoot = '
        | wi        

        function _processOneProfile {

            ## =========== code
            # $src = Get-Item "$Env:AppData\Code\User\*"
            $src = "$Env:AppData\Code\User\*" # star is important based on how command works
            $dest = "$dotfileRoot\code"
            $copyItemSplat = @{
                # WhatIf      = $true
                Path        = $src
                Destination = $dest
                # Verbose     = $true
                Recurse     = $true
                Force       = $true # for hidden files
            }
            if ($WhatIf) {
                $copyItemSplat['WhatIf'] = $true
            }

            if (! $TestOnly ) {
                # attempt to get -Recurse to filter patterns, but it seems to ignore it.
                # instead, just hardcode subdirs
                $copied = Copy-Item @copyItemSplat -Exclude '*storage*' -PassThru

                # 1 / 0
                $newTextSplat = $ColorStyle.dim
                

                $copied | Join-String -sep ', ' Name -op "Wrote $($copied.count) Files: "
                | New-Text @newTextSplat
                | Write-Information


                h1 'here' | wi 
                $copied
                | To->RelativePath $dotfileRoot
                | str $Config.FileListFormat -Sort -Unique
                | ForEach-Object {
                    $splat = $ColorStyle.dim
                    $_ | Write-Color @splat
                }                
                | Str prefix "Wrote $($copied.count) Files: "
                | wi 
            }
            @(
                $copyItemSplat | format-dict
                $meta = @{
                    Source = $src
                    Dest   = $DestPath
                }
                $Config | format-dict
                $ColorStyle | format-dict
            ) | wi


            "
        Dotfiles: {0}
        Source  : {1}'
        Dest    : {2}" -f @(
                $dotfileRoot | Ninmonkey.Console\Format-RelativePath -BasePath "$Env:UserProfile"
                | New-Text -fg green


                $src | Ninmonkey.Console\Format-RelativePath -LiteralPath -BasePath "$Env:UserProfile"
                | New-Text -fg green

                $dest | Ninmonkey.Console\Format-RelativePath -BasePath "$env:Nin_Dotfiles"
                | New-Text -fg green
            )

            ## =========== code
            $src = "$Env:AppData\Code - Insiders\User\*"
            $dest = "$dotfileRoot\Code - Insiders"
            $copyItemSplat = @{
                # WhatIf      = $true
                Path        = $src
                Destination = $dest
                # Verbose     = $true
                Recurse     = $true
                Force       = $true # for hidden files
            }
            if ($WhatIf) {
                $copyItemSplat['WhatIf'] = $true
            }

            if (! $TestOnly ) {
                # attempt to get -Recurse to filter patterns, but it seems to ignore it.
                # instead, just hardcode subdirs
                $copied = Copy-Item @copyItemSplat -Exclude '*storage*' -PassThru


                $copied | Join-String -sep ', ' Name -op "Wrote $($copied.count) Files: "
                | New-Text -bg 'gray20' -fg 'gray70'
                | Write-Information
            }


            "
        Dotfiile: {0}
        Source  : {1}'
        Dest    : {2}" -f @(
                $dotfileRoot | Ninmonkey.Console\Format-RelativePath -BasePath "$Env:UserProfile"
                | New-Text -fg green


                $src | Ninmonkey.Console\Format-RelativePath -LiteralPath -BasePath "$Env:UserProfile"
                | New-Text -fg green

                $dest | Ninmonkey.Console\Format-RelativePath -BasePath "$env:Nin_Dotfiles"
                | New-Text -fg green
            )
        
        }
    
        _processOneProfile
    }
}



