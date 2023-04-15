<#
Use Chezmoi or something better for profile management
This is a naive copy
#>
$FetchConfig = @{
    IAm        = Get-Item $PSCommandPath
    Root       = Get-Item $PSScriptRoot
    ExportRoot = Get-Item -ea stop (Join-Path $PSSCriptRoot 'profile')
}
$FetchConfig += @{
    Import = @{
        Profile = @{
            'Settings.json' = Get-Item "$Env:AppData\Code\User\settings.json"

        }
    }
    Export = @{
        Profile = @{
            'Settings.json' = Join-Path $FetchConfig.ExportRoot 'settings.json'
        }
    }
}

function Status.WroteFile {
    # process {
        # [string]$Name = $_
        # colorize red if file doesn't actually exist
        # $file

        # $Input | CountOf | ForEach-Object { $_ | Join-String -f 'wrote: <file:{0}>' } | CountOf | Join-String -sep "`n" | CountOf
        begin {
            $Color = $exists ? ($PSStyle.Foreground.Green) : ($PSStyle.Foreground.Red)
        }
    process {
        $_
        # | CountOf
        | ForEach-Object {
            $exists = Test-Path $_
            $file? = Get-Item -ea 'ignore' $_

            $ItemPathOrString = $file? ?? $_

             $ItemPathOrString
             $PathString = $Color, $ItemPathOrString, $PSStyle.Reset -join ''

            $PathSTring
            | Join-String -f 'wrote: <file:///{0}>'
        }
        | Join-String -sep "`n"

    }
    end {

    }
        # [Collections.Generic.List[Object]]$Files = @( $Input )

        # $Input | Get-Item -ea 'continue' | ForEach-Object {
        #     $_
        #     | Join-String -
        # }
        # $What = Get-Item $Input
        # $Input | CountOf | ForEach-Object { $_ | Join-String -f 'wrote: <file:{0}>' } | CountOf | Join-String -sep "`n" | CountOf
    # }
}

$copyItemSplat = @{
    Destination = $FetchConfig.Exportl.Profile
    WhatIf      = $true
    Path        = $FetchConfig.Import.Profile.'Settings.json'
}

$itemsCopied = Copy-Item @copyItemSplat -PassThru

hr
$itemsCopied
| Status.WroteFile