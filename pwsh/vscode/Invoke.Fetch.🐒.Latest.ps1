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
            # 'Settings.json' = Join-Path $FetchConfig.ExportRoot # 'settings.json'
            'Settings.json' = $FetchConfig.ExportRoot # 'settings.json'
        }
    }
}

class FileWriteStatus {
    [bool]$Exists
    [bool]$IsAFolder
    [int]$Length
    [string]$BaseName
    [string]$FullName
    [object]$ItemInfo

    [string] FullName() {
        throw 'not actually used anywhere yet'
        return $This.ItemInfo.FullName
    }

    [string] ToStringFancy() {
        return 'wip: colors, formatting, etc...'
    }
    [string] ToString() {
        # implicit default?
        return @(
            $This.ItemInfo | Join-String -DoubleQuote
        )

    }
    [string] FormatAsTerminalIcon() {
        return 'wip: terminal icon formatter'
    }
}
function __runTest.Status.WroteFile {
    # show examples

    'asdf' | Status.WroteFile?
    hr
    'asdf' | Status.WroteFile? -IncludeFolders
    hr
    (gi . ), 'asdf' | Status.WroteFile?
    hr
    (gi . ), 'asdf' | Status.WroteFile? -IncludeFolders
    hr -fg magenta
    gi . | Status.WroteFile -Verbose
}
function Status.WroteFile {
    <#
    .SYNOPSIS
    Display filepath to user, with minimal input (opinionated formatter)

    .DESCRIPTION
    written sleep deprived, with ocd, terrible implementation, just rewrite
    Shows path info
        - full path, base name, or relative path, ?
        - colors based on type, file, folder, (or terminal-icons formatter)
        - colors based on file  exitsts or not
        - -passThru returns object with path and file existance or not state
        - finally, output using the object type, but a special formatter when needed raw text

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [Alias('Status.WroteFile?')]
    [CmdletBinding()]
    param(
        [Alias('PSPath', 'FullName', 'Path')]
        [Parameter(Mandatory, valuefrompipeline)]
        $InputObject,

        [switch]$IncludeFolders
    )
    # process {
    # [string]$Name = $_
    # colorize red if file doesn't actually exist
    # $file

    # $Input | CountOf | ForEach-Object { $_ | Join-String -f 'wrote: <file:{0}>' } | CountOf | Join-String -sep "`n" | CountOf
    begin {

    }
    process {


        # $_
        # # | CountOf
        # | Where-Object {
        # }
        # $files | ForEach-Object { $file? = Get-Item $_ -ea ignore; $IsFolder = $file?.PSIsContainer ; $IsFolder
        # }
        # | ForEach-Object {
        $FileItem? = Get-Item -ea 'ignore' $InputObject
        [bool]$Exists? = Test-Path $InputObject

        [bool]$IsFolder? = $fileItem?.PSIsContainer ?? $false
        $Color = $Exists? ? $PSStyle.Foreground.Green : $PSStyle.Foreground.Red
        $Color = $IsFolder? ? $PSStyle.foreground.Yellow : $Color
        $itemOrString = $file? ?? $InputObject
        if (-not $Exists?) {
            'Expected path, does not exist: {0}' -f $InputObject
            | Write-Error
        }
        if ($IsFolder?) {

            # example of string vs not
            if (-not $IncludeFolders) {
                'skipping directory: {0}' -f @( $InputObject) | Write-Verbose
                # moves 'most-significant-bit', the operand, to the front
                $_ | Join-String -f 'skipping Directory {0}' | Write-Verbose
                return
            }
        }

        #  $itemOrString
        $PathString = (
            $PSStyle.Reverse,
            $Color,
            $itemOrString,
            $PSStyle.ReverseOff,
            $PSStyle.Reset
        ) -join ''

        $PathString
        | Join-String -f 'wrote: <file:///{0}>' -os $PSStyle.Reset
        # }
        # | Join-String -sep "`n"

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
    Destination = $FetchConfig.Export.Profile
    # WhatIf      = $true
    Path        = $FetchConfig.Import.Profile.'Settings.json'
}

$itemsCopied = Copy-Item @copyItemSplat -PassThru # not recurse here
& { ($itemsCopied | % Length) / 1mb | % tostring 'n2' | join-string -f 'wrote: {0} mb' }

hr
# Hr
# $itemsCopied
# | Status.WroteFile
# hr

# . $SomeSource
# gci .. | Status.WroteFile? -IncludeFolders

<#

function BadStatus.WroteFile {
    # this is crazy bad
    param(
        [switch]$IgnoreFolders
    )
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
        | Where-Object {
        }
        $files | ForEach-Object { $file? = Get-Item $_ -ea ignore; $IsFolder = $file?.PSIsContainer ; $IsFolder
        }
        | ForEach-Object {
            [bool]$Exists? = Test-Path $_
            $FileItem? = Get-Item -ea 'ignore' $_
            [bool]$IsFolder? = $fileItem?.PSIsContainer
            $itemOrString = $file? ?? $_
            #  $itemOrString
            $PathString = $Color, $itemOrString, $PSStyle.Reset -join ''

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
#>