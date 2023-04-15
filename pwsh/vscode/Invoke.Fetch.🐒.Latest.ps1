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
            'Snippets' = Get-Item "$Env:AppData\Code\User\Snippets"

        }
    }
    Export = @{
        Profile = @{
            # 'Settings.json' = Join-Path $FetchConfig.ExportRoot # 'settings.json'
            'Settings.json' = $FetchConfig.ExportRoot # 'settings.json'
            'Snippets' = $FetchConfig.ExportRoot  # 'settings.json'
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

    [object]$From # source
    [object]$To # destination

    [string] FullName() {
        throw 'not actually used anywhere yet'
        return $This.ItemInfo.FullName
    }

    # it will nt let me declare FileInfo? inline as the name
    [object] FileInfo () {
        return $this.ItemInfo ?? $null
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
    Hr
    'asdf' | Status.WroteFile? -IncludeFolders
    Hr
    (Get-Item . ), 'asdf' | Status.WroteFile?
    Hr
    (Get-Item . ), 'asdf' | Status.WroteFile? -IncludeFolders
    Hr -fg magenta
    Get-Item . | Status.WroteFile -Verbose
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
        PS> gci . | Status.WroteFile?

            wrote: <file:///H:\data\2023\dotfiles.2023\pwsh\vscode\Invoke.Fetch.🐒.Latest.ps1>

    .EXAMPLE
        PS> gci . | CountOf | Status.WroteFile? -IncludeFolders

            to: <file:///H:\data\2023\dotfiles.2023\pwsh\vscode\editorServicesScripts>
            to: <file:///H:\data\2023\dotfiles.2023\pwsh\vscode\profile>
            to: <file:///H:\data\2023\dotfiles.2023\pwsh\vscode\Invoke.Fetch.🐒.Latest.ps1>
            3 items

    .NOTES
    General notes
    #>
    [Alias('Status.WroteFile?')]
    [CmdletBinding()]
    param(
        [Alias('PSPath', 'FullName', 'Path')]
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [switch]$IncludeFolders,
        [switch]$PassThru
    )
    # process {
    # [string]$Name = $_
    # colorize red if file doesn't actually exist
    # $file

    # $Input | CountOf | ForEach-Object { $_ | Join-String -f 'wrote: <file:{0}>' } | CountOf | Join-String -sep "`n" | CountOf
    begin {

    }
    process {

        if ($PassTHru) {
            Write-Warning '$PassThru NYI, will change to output as write-information otherwise object info on out stream'
        }
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
        $itemOrString = $FileItem? ?? $InputObject
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
        $PathString = @(
            # $PSStyle.Reverse
            $Color ?? ''
            $itemOrString ?? '<missing>'
            # $PSStyle.ReverseOff
            $PSStyle.Reset
        ) -join ''

        # wait-debugger

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



# $result = Copy-Item $copyItemSplat.Path.FullName $copyItemSplat.Destination -Verbose -PassThru #  -WhatIf
if ($true) {
    $copyItemSplat = @{
        # WhatIf      = $true
        Path        = $FetchConfig.Import.Profile.'Settings.json'

        # dynamically instead
        # Destination = Join-Path ($FetchConfig.Export.Profile.'Settings.json'.FullName) 'settings.json'
        Destination = (
            Join-Path (
                $FetchConfig.Export.Profile.'Settings.json'.FullName) (
                'settings.json')
        )
        PassThru    = $True
        Verbose     = $True
    }
    Hr
    $result = Copy-Item @copyItemSplat
    $itemsCopied = Copy-Item @copyItemSplat -PassThru # not recurse here

    $itemsCopied | CountOf | Status.WroteFile?

    & { ($itemsCopied | ForEach-Object Length) / 1mb | ForEach-Object tostring 'n2' | Join-String -f 'copied files: {0:n2} mb' }
    Hr

    $copyItemSplat = @{
        # WhatIf      = $true
        Path        = $FetchConfig.Import.Profile.'Settings.json'

        # dynamically instead
        # Destination = Join-Path ($FetchConfig.Export.Profile.'Settings.json'.FullName) 'settings.json'
        Destination = (
            Join-Path (
                $FetchConfig.Export.Profile.'Settings.json'.FullName) (
                'settings.json')
        )
        PassThru    = $True
        Verbose     = $True
    }



    Get-ChildItem 'C:\Users\cppmo_000\AppData\Roaming\Code\User\snippets'

}
if ($false) {


    $itemsCopied = Copy-Item @copyItemSplat -PassThru # not recurse here
    | CountOf
    | Status.WroteFile?


    & { ($itemsCopied | ForEach-Object Length) / 1mb | ForEach-Object tostring 'n2' | Join-String -f 'wrote: {0} mb' }

    Hr
}
