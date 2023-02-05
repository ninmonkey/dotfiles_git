function old_Backup-VSCode {
    <#
    .synopsis
        backup dotfiles to git
    .description
        .
    .example
        PS> Backup-VSCode
        todo: allow multiple sources.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # WhatIf
        [Parameter()][switch]$WhatIf
    )
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

        # attempt to get -Recurse to filter patterns, but it seems to ignore it.
        # instead, just hardcode subdirs
        $copied = Copy-Item @copyItemSplat -Exclude '*storage*' -PassThru


        $copied | Join-String -sep ', ' Name -op "Wrote $($copied.count) Files: "
        | New-Text -bg 'gray20' -fg 'gray70'
        | Write-Information


        "
        Source  : {0}'
        Dest    : {1}" -f @(
            $src | Format-RelativePath -BasePath "$Env:UserProfile"
            | New-Text -fg green

            $dest | Format-RelativePath -BasePath "$Env:UserProfile"
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

        # attempt to get -Recurse to filter patterns, but it seems to ignore it.
        # instead, just hardcode subdirs
        $copied = Copy-Item @copyItemSplat -Exclude '*storage*' -PassThru


        $copied | Join-String -sep ', ' Name -op "Wrote $($copied.count) Files: "
        | New-Text -bg 'gray20' -fg 'gray70'
        | Write-Information


        "
        DotfileRoot: {0}
        Source     : {1}'
        Dest       : {2}" -f @(
            $dotfileRoot | Format-RelativePath -BasePath "$env:UserProfile"
            | New-Text -fg green

            $src | Format-RelativePath -BasePath "$Env:UserProfile"
            | New-Text -fg green

            $dest | Format-RelativePath -BasePath "$Env:UserProfile"
            | New-Text -fg green
        )
    }
}