'📚 enter ==> profile ==>  C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1/d34a150d-75e4-4424-bcc2-56bfe32285ed' | Write-Warning

"enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib'
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'

    'E:\PSModulePath_2022'
    'E:\PSModulePath_base\all'
    $Env:PSModulePath
) | Join-String -sep ';'

function quickHist {
    [Alias('prof.quickHistory')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions('Default', 'Number', 'Duplicate')]
        [string]$Template
    )
    # Quick, short, without duplicates
    switch ($Template) {
        'Number' {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String -sep (hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }
        'Duplicates' {
            Get-History
            | Join-String -sep (hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }

        default {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String CommandLine -sep (hr 1)
        }
    }
}
function prof.hack.dumpExcel {
    # super quick hack, do not use
    [Alias('out-xl', 'to-xl')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TableName = 'default',

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        $Items.AddRange( $InputObject )
    }
    end {
        $items
        | Export-Excel -work 'a' -table $TableName -AutoSize -Show -Append #-Verbose -Debug
    }
}

function fix.PsModulePath {
    <#
    .SYNOPSIS
        attempt to nonrmalize PSModulePaths
    .NOTES
        $PathsToRemove requires exact match (needs to compare with no trailing slash )
    #>
    [CmdletBinding()]
    param(

    )
    # Write-Warning 'LEFT OFF... STRIP PATHS fix.PsModulePath'
    # return
    $global:__originalPSModulePath = $Env:PSModulePath
    [Collections.Generic.List[object]]$PathsToRemove = @(
        'C:\Program Files\PowerShell\Modules' # does not exist. maybe it's C:\Program Files\PowerShell\7 ?
        # maybe it's WinPS path? This exists: C:\Program Files\WindowsPowerShell\Modules'

        'C:\Program Files (x86)\Microsoft SQL Server\150\Tools\PowerShell\Modules\'
        'C:\Program Files\Intel\Wired Networking'  # says copyright intel 2013, files are modified at 2018, no longer used?
        # 'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib' # after work
        # refactor location:
        'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'
    )

    # temporarily include
    $PathsToRemove.Remove('C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github')

    $joinUL_splat = @{
        Separator    = "`n  - "
        OutputPrefix = "`n- "
        OutputSuffix = "`n"
    }

    $Env:PSModulePath = @(
        Get-Item -ea 'continue' 'E:\PSModulePath_2022' # Add Prefixpath
        $Env:PSModulePath
    ) | Join-String -sep ';'


    $Env:PSModulePath -split ';'
    | Sort-Object -Unique -Stable
    | Join-String @joinUL_splat
    | Join-String -op "PSModulePath: Initial`n"
    | Write-Verbose

    Write-Warning 'Okay, set profile var then'
    if ($true) {
        $newModulePath = $Env:PSModulePath -split ';'
        | Where-Object { $_ -notin @($PathsToRemove) }
        | Where-Object { -not [string]::IsNullOrWhiteSpace( $_ ) } # prevents errors on empty or null
        | Sort-Object -Unique -Stable
        | Join-String -sep ';'
        'New PSModulePath: = {0}' -f @($newModulePath)

        $Env:PSModulePath = $newModulePath



        $newModulePath
        | Join-String @joinUL_splat
        | Join-String -op "PSModulePath: After`n"
        | Write-Verbose


    }
    else {
        $Env:PSModulePath -split ';'
        | Where-Object { $_ -notin @($PathsToRemove) }
        | Where-Object { -not [string]::IsNullOrWhiteSpace( $_ ) } # prevents errors on empty or null
        | Sort-Object -Unique -Stable
        | Join-String @joinUL_splat
        | Join-String -op "PSModulePath: After`n"
        | Write-Verbose
    }
    #| Set-Clipboard -PassThru
    # | join.UL
    # | label 'New: PSModulePath'
    # # was not auto
    # $Env:PSModulePath = @(

    #     $Env:PSModulePath
    # ) | Join-String -sep ';'
    # $Env:PSModulePath -split ';'
    # | Where-Object { $_ -notin @($PathsToRemove) }
    # | Where-Object { -not [string]::IsNullOrWhiteSpace( $_ ) } # prevents errors on empty or null
    # | Sort-Object
    #| Set-Clipboard -PassThru
    # | join.UL
    # | label 'New: PSModulePath'
}

@(
    Set-Alias 'label' -Value Get-Date -Force -ea ignore -Description 'to prevent ever referencing exe' -PassThru
    Set-Alias 's' -Value Select-Object -PassThru
    Set-Alias 'fcc' 'ninmonkey.console\Format-ControlChar' -PassThru
) | Join-String -op 'alias loaded: (source: $PROFILE.CurrentUserAllHosts ) ' -sep ', ' -single

fix.PsModulePath -verbose
<#
Note:
    This file auto runs for both VSCode-Debugger, VSCode-Regular, and Wt
#>

Write-Warning 'not finished, wt profile still loads profile, see: <C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1>'

Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine

function eye0 {
    <#
    .SYNOPSIS
        less dependency than Ninmonkey.Console\eye is
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]$InputObject
    )
    process {
        $InputObject | ClassExplorer\Find-Member | Sort-Object Name -Unique
    }
}

function nameOfType {
    <#
    .SYNOPSIS
    .example
        $workbook | nameOfType
        # output: [OfficeOpenXml.ExcelPackage]
    #>
    param( [switch]$ToClip, [switch]$Short )
    process {
        if ($Short) {
            $render = $_.GetType().Name | Join-String -op '[' -os ']'
        }
        else {
            $render = $_.GetType().FullName | Join-String -op '[' -os ']'
        }
        if ( -not $ToClip ) { return $render }

        $render | Set-Clipboard -Append -PassThru

    }
}
function nameOfMember {
    <#
    .SYNOPSIS
    .example
        $workbook | nameOfType
        # output: [OfficeOpenXml.ExcelPackage]

        $book | nameOfMember 'package'
    .NOTES
        like [nameOfType], but that takes the target, this tests the member
    #>
    param(  [string]$Pattern = '.*', [switch]$ToClip )
    process {
        # original: ($book | Fime | ? Name -match 'book' | % DeclaringType).FullName

        $tinfo = ($_ | ClassExplorer\Find-Member | Where-Object Name -Match $Pattern
            | ForEach-Object DeclaringType)

        if ($Short) {
            $render = $tinfo.Name
            | Join-String -op '[' -os ']'
        }
        else {
            $render = $tinfo.FullName
            | Join-String -op '[' -os ']'

        }
        if ( -not $ToClip ) { return $render }
        $render | Set-Clipboard -Append -PassThru

        $render = $_

    }
}
function _macro.renderPropList {
    <#
            .NOTES
                future: include properties not found by fime, using psobjects
            #>
    param( [Parameter(Mandatory, ValueFromPipeline)]$InputObject )
    process {
        $InputObject
        | ClassExplorer\Find-Member
        | Sort-Object PropertyType -Unique
        # | Join-String {
        | ForEach-Object {
            '{0} is {1}' -f @(
                $_.Name.padLeft(20 + 2, ' ')
                $_.PropertyType ?? '[null]'
            )
        }
    }
}

function renderObjProps {
    # summarize visually
    <#
    .notes
        alternate render

            $pkgTest | fime
            | sort -Unique Name
            | sort PropertyType
            >> | ft Name, MemberType, PropertyType, DeclaringType

            Name              MemberType PropertyType                                      DeclaringType
            ----              ---------- ------------                                      -------------
            Compatibility       Property OfficeOpenXml.Compatibility.CompatibilitySettings OfficeOpenXml.ExcelPackage
            Compression         Property OfficeOpenXml.CompressionLevel                    OfficeOpenXml.ExcelPackage
            Encryption          Property OfficeOpenXml.ExcelEncryption                     OfficeOpenXml.ExcelPackage
            Workbook            Property OfficeOpenXml.ExcelWorkbook                       OfficeOpenXml.ExcelPackage
            Package             Property OfficeOpenXml.Packaging.ZipPackage                OfficeOpenXml.ExcelPackage
            DoAdjustDrawings    Property System.Boolean                                    OfficeOpenXml.ExcelPackage
            File                Property System.IO.FileInfo                                OfficeOpenXml.ExcelPackage
            Stream              Property System.IO.Stream                                  OfficeOpenXml.ExcelPackage
            .ctor            Constructor                                                   OfficeOpenXml.ExcelPackage
            Dispose               Method                                                   OfficeOpenXml.ExcelPackage
            GetAsByteArray        Method                                                   OfficeOpenXml.ExcelPackage
            Load                  Method                                                   OfficeOpenXml.ExcelPackage
            MaxColumns             Field                                                   OfficeOpenXml.ExcelPackage
            MaxRows                Field                                                   OfficeOpenXml.ExcelPackage
            Save                  Method                                                   OfficeOpenXml.ExcelPackage
            SaveAs                Method                                                   OfficeOpenXml.ExcelPackage

    initial sketch:

        gi . |  ClassExplorer\Find-Member
                | sort PropertyType -Unique
                # | Join-String {
                | % {
                    '{0} is {1}' -f @(
                        $_.Name.padLeft(20+2, ' ')
                        $_.PropertyType ?? '[null]'
                    )
                }
    #>
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter()]
        [string[]]$Properties = @('*')

    )
    begin {

    }
    process {


        $restOfContent = 'stuff'

        # doesn't work on classes, enumerated that way?
        # [string[]]$selProps = ($InputObject| Select-Object -prop $Properties -ea ignore).psobject.properties.name | Sort -unique
        [string[]]$selProps = $InputObject.psobject.properties.Name
        | Sort-Object -Unique

        # @(
        #         $book.Workbook | nameOfType
        #         $book | nameOfMember 'workbook'
        #         $restOfContent
        #     )
        $renderProps = $selProps | ForEach-Object {
            $curProp = $_
            $value = $InputObject.$curProp
            '    ', $_ -join ''
        }
        $renderProps3 = _macro._renderPropList -InputObject $InputObject
        $renderProps2 = $InputObject | ClassExplorer\Find-Member
        | Sort-Object PropertyType -Unique
        # | Join-Striang {
        | ForEach-Object {
            '{0} is {1}' -f @(
                $_.Name
                $_.PropertyType ?? '[null]'
            )
        }


        $rest = $renderProps3

        '
        Obj is a: {0}
            has:
        {1}
        ' -f @(
            $InputObject | nameOfType
            $rest
        )
    }
    end {}
}

function Err {
    <#
    .SYNOPSIS
        Useful sugar when debugging inside a module Sugar for quickly using errors in the console.  2023-01-01
    .DESCRIPTION
        For different contexts, $error.count can return 0 values even though
        there are errors. Explicitly referencing global:errors will work
        for regular mode, or module breakpoints.

        Useful when debugging inside a module Sugar for quickly using errors in the console.  2023-01-01
    .EXAMPLE
        err -TotalCount
            1
        err -TestHasAny
            $true

        err -Num 4
            errors[0..3]

        err -clear
            resets even global errors.
    #>
    [Alias('prof.Err')]
    param(
        [int]$Num = 10,
        [switch]$Clear,
        [Alias('Count')]
        [switch]$TotalCount,

        [Alias('HasAny')]
        [switch]$TestHasAny
    )
    if ($TestHasAny) {
        return ($global:error.count -gt 0)
    }
    if ($TotalErrorCount) {
        return $global:error.count
    }

    if ( $Clear) { $global:error.Clear() }
    if ($num -le $global:error.count ) {
        "Number of Errors: $($global:error.count)" | Write-Verbose
    }
    return $global:error | Select-Object -First $Num
}



function inspectRunes.prof {
    <#
    .synopsis
        minimal sugar to see codepoints
    .EXAMPLE
        $Str1 = '🐒'
        $str1 |  inspectRunes
    #>
    param(

        [switch]$WithRawCtrlChar
    )
    process {
        $_.EnumerateRunes() | ForEach-Object {
            $isCtrlChar = $_.Value -ge 0 -and $_.Value -le 0x1f

            $rune = $isCtrlChar ? [Text.Rune]::New($_.Value + 0x2400) : $_

            '0x{0:x} = "{1}"' -f @(
                $_.Value
                $Rune
                # $_ = $isCtrlChar ? [Text.Rune]::new($_ + )xx
            ) }

        # or simpler
        #     $_.EnumerateRunes() | Join-String -sep "`n" {
        #         '0x{0:x} = {1}' -f @(
        #             $_.Value
        #             $_ | fcc
        #          )
        #    }

    }
}

function inspectRunes.prof3 {
    <#
    .synopsis
        minimal sugar to see codepoints
    .EXAMPLE
        $Str1 = '🐒'
        $str1 |  inspectRunes.prof
    #>
    param(
        # default will replace control chars to text. ie: You can pipe it safely
        [switch]$PassThru
    )
    process {
        $_.EnumerateRunes() | ForEach-Object {
            $isCtrlChar = $_.Value -ge 0 -and $_.Value -le 0x1f
            $Render = $isCtrlChar ? [Text.Rune]::New($_.Value + 0x2400) : $_
            # $Render

            [PSCustomObject]@{
                Codepoint = '{0:x}' -f @( $_.Value )
                Render    = $Render.ToString()
                # Rune = $_
            }
        }
    }
}


function old_gErr {
    [int]$Limit,
    [switch]$Tac

    err -Limit $Limit -Tac:$Tac | Get-Error
}

function ToastIt.2 {
    <#
    .synopsis
        wraps BurntToast with defaults and a simpler api
    .NOTES
        -Verbose will show XML generated
        -Title appears to be first line of Xml
        -Text seems to be an additional 4 lines
        -for text> 4+ items, it truncates it in the window
        -but -join "`n" on newline, and it preserves text.
    .EXAMPLE
        toastIt -Title 'title' -Text (0..9)
            > only shows 0..3
    #>
    # mini sugar using defaults
    [Alias('ToastIt')] # if on, then this is the default version
    param(
        # this coerces to n-number of lines
        [parameter(Mandatory)]
        [string[]]$Text,

        # this is the big bolded section
        [string]$Title,

        # [string]$Sound #
        [switch]$NotSilent
    )
    $textList = @(
        if ($title) { $title }
        $Text | Join-String -sep "`n"
    )
    $textList = @(
        $title
        $Text | Join-String -sep "`n"
    )



    $splatIt = @{
        # The parameter requires at least 0 value(s) and no more than 3
        Text    = $TextList
        Silent  = $true
        Verbose = $true
        # Debug   = $true
        # AppLogo = @(
        #     Get-Item -ea 'silentlyContinue' 'C:\Users\cppmo_000\SkyDrive\Documents\2019_art\avatars'
        #     Get-Item -ea silentlyContinue 'C:\Users\cppmo_000\SkyDrive\Documents\2018\art\avatar.png'
        # )[0]
        AppLogo = @(
            Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2018\art\avatar.png'
            Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2019_art\avatars\head banner conspiracy.avatar.png'
        )[0]
    }
    if (-not $splatIt.AppLogo) {
        "Path did not exist, ignoring param -AppLogo. Path: '$($splatIt.AppLogo)'"
        | Write-Warning
        $splatIt.Remove('AppLogo')
    }
    if ($NotSilent) { $SplatIt.Silent = $False }
    New-BurntToastNotification @splatIt
}
function ToastIt.1 {
    <#
    .synopsis
        wraps BurntToast with defaults and a simpler api
    .NOTES
        -Verbose will show XML generated
        -Title appears to be first line of Xml
        -Text seems to be an additional 4 lines
        -for text> 4+ items, it truncates it in the window
        -but -join "`n" on newline, and it preserves text.
    .EXAMPLE
        toastIt -Title 'title' -Text (0..9)
            > only shows 0..3
    #>
    # mini sugar using defaults
    # [Alias('ToastIt')] # if on, then this is the default version
    param(
        # this coerces to n-number of lines
        [parameter(Mandatory)]
        [string[]]$Text,

        # this is the big bolded section
        [string]$Title,

        # [string]$Sound #
        [switch]$NotSilent
    )
    $textList = @(
        if ($title) { $title }
        $Text | Join-String -sep "`n"
    )
    $textList = @(
        $title
        $Text | Join-String -sep "`n"
    )



    $splatIt = @{
        # The parameter requires at least 0 value(s) and no more than 3
        Text    = $TextList
        Silent  = $true
        Verbose = $true
        # Debug   = $true
        # AppLogo = @(
        #     Get-Item -ea 'silentlyContinue' 'C:\Users\cppmo_000\SkyDrive\Documents\2019_art\avatars'
        #     Get-Item -ea silentlyContinue 'C:\Users\cppmo_000\SkyDrive\Documents\2018\art\avatar.png'
        # )[0]
        AppLogo = @(
            Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2018\art\avatar.png'
            Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2019_art\avatars\head banner conspiracy.avatar.png'
        )[0]
    }
    if (-not $splatIt.AppLogo) {
        "Path did not exist, ignoring param -AppLogo. Path: '$($splatIt.AppLogo)'"
        | Write-Warning
        $splatIt.Remove('AppLogo')
    }
    if ($NotSilent) { $SplatIt.Silent = $False }
    New-BurntToastNotification @splatIt
}
function ToastIt.0 {
    # mini sugar using defaults
    # [Alias('ToastIt')]
    param(
        [parameter(Mandatory)]
        [string[]]$Text,

        [string]$Title,

        # [string]$Sound #
        [switch]$NotSilent
    )
    $textList = @(
        if ($title) { $title }
        $Text | Join-String -sep "`n"
    )

    $splatIt = @{
        # The parameter requires at least 0 value(s) and no more than 3
        Text   = $TextList
        Silent = $true
    }
    if ($NotSilent) { $SplatIt.Silent = $False }
    New-BurntToastNotification @splatIt
}


function old_Err {
    # [Err.v3]
    # sugar when in debug mode
    <#
    todo: param set that that will use

        err 0           : index paramset $error[0]
        err -num 3      : first 3     $error | select -first 3
        err 2:4         : $errors[2..4]

    #>
    [OutputType('[object[]]')]
    # [Alias('gErr')] # or Grr
    [CmdletBinding()]
    param( [switch]$Clear,
        [Alias('At')][int]$Index,
        [Alias('Number')] # 'count' and 'clear' are too close for tying
        [int]$Limit,

        # select count still grabs the newest, this just prints newest at bottom
        [Alias('tac')][switch]$Reverse
        # [Alias('gerr')][switch]$ToGetError
    )

    if ($Clear) { $global:error.Clear() }

    if ($Index) {
        $global:error | At $Index
        return
        # | select -Index $INdex
    }
    if ($Limit) {
        if ($Reverse) {
            $global:error | Select-Object -First $Limit | Out-ReversePipeline
        }
        else {
            $global:error | Select-Object -First $Limit
        }
        return
    }

    if ($Reverse) {
        $global:error | Out-ReversePipeline
    }
    else {
        $global:error
    }
    return

    # return $global:error
}

if ($true -and 'wierd stuff') {
    function Invoke-PesterJob {
        [CmdletBinding(DefaultParameterSetName = 'LegacyOutputXml')]
        param(
            [Parameter(Position = 0)]
            [Alias('Path', 'relative_path')]
            [System.Object[]]
            ${Script},

            [Parameter(Position = 1)]
            [Alias('Name')]
            [string[]]
            ${TestName},

            [Parameter(Position = 2)]
            [switch]
            ${EnableExit},

            [Parameter(ParameterSetName = 'LegacyOutputXml', Position = 3)]
            [string]
            ${OutputXml},

            [Parameter(Position = 4)]
            [Alias('Tags')]
            [string[]]
            ${Tag},

            [string[]]
            ${ExcludeTag},

            [switch]
            ${PassThru},

            [System.Object[]]
            ${CodeCoverage},

            [switch]
            ${Strict},

            [Parameter(ParameterSetName = 'NewOutputSet', Mandatory = $true)]
            [string]
            ${OutputFile},

            [Parameter(ParameterSetName = 'NewOutputSet', Mandatory = $true)]
            [ValidateSet('LegacyNUnitXml', 'NUnitXml')]
            [string]
            ${OutputFormat},

            [switch]
            ${Quiet}
        )

        $params = $PSBoundParameters

        Start-Job -ScriptBlock { Set-Location $using:pwd; Invoke-Pester @using:params } |
            Receive-Job -Wait -AutoRemoveJob
    }
    Set-Alias ipj Invoke-PesterJob
}

[Console]::OutputEncoding | Join-String -op 'Console::OutputEncoding '
"exit  <== Profile: docs/profile.ps1/ => Pid: '${pid}'" | Write-Warning
'📚 exit ==> Profile: ==>   C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1/a4968549-e087-446a-852f-c027cadc78e9' | Write-Warning

"Running extra typedata, source: <$PSCOmmandpath>"
try {
    # $stringToUtf8Method = @{
    #     # ex: 'sdfds'.'.toUtf8'()
    #     TypeName   = 'System.String'
    #     MemberName = '.toUtf8'  # bad name on purpose
    #     MemberType = 'ScriptMethod'
    #     # Value      = { Write-Output ([System.Text.Encoding]::UTF8.GetBytes($this)) -NoEnumerate }
    #     Value      = { [System.Text.Encoding]::UTF8.GetBytes($this) }
    #     Force      = $true
    # }
    # Update-TypeData @stringToUtf8Method



    # $updateTypeDataSplat = @{
    #     TypeName   = 'System.String'
    #     # MemberName = 'toUtf8'
    #     # MemberName = '>utf8'  # bad names on purposea
    #     MemberName = '.Utf8'  # bad names on purpose
    #     MemberType = 'ScriptProperty'
    #     # Value =  { @([System.Text.Encoding]::UTF8.GetBytes($this)) }
    # }
    # Update-TypeData @updateTypeDataSplat -Force
    $updateTypeDataSplat = @{
        TypeName   = 'System.String'
        MemberName = 'LengthUnicode'  # bad name on purpose
        MemberType = 'ScriptProperty'
        Value      = { @($this.EnumerateRunes()).count }
    }
    Update-TypeData @updateTypeDataSplat -Force

    $updateTypeDataSplat = @{
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'Render'
        Value = {
            # coerce control chars to safe symbols
            [bool]$isCtrlChar = $this.Value -ge 0 -and $this.Value -le 0x1f
            $Rune = $isCtrlChar ? [Text.Rune]::New($this.Value + 0x2400 ) : $this
            return $Rune.ToString() # Should I be explicitly calling?
        }
    }
    Update-TypeData @updateTypeDataSplat -Force
    $updateTypeDataSplat = @{
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'Hex'
        Value      = {
            '0x{0:x}' -f @($This.Value)
        }
    }
    Update-TypeData @updateTypeDataSplat -Force

    $updateTypeDataSplat = @{
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'isCtrlChar'
        Value      = {
            $This.ToString() -match '\p{C}'
        }
    }
    Update-TypeData @updateTypeDataSplat -Force
    $updateTypeDataSplat = @{
        <#
        .example
            @('asfs '.EnumerateRunes()).Is | ft
        .example
            @('a s▸·⇢⁞ ┐⇽▂fs '.EnumerateRunes()) | Select Rune, Render -ExpandProperty Is | ft
            Ps7┐ @('a s▸·⇢⁞ ┐⇽▂fs '.EnumerateRunes()) | Select Rune, Render -ExpandProperty Is | ft

                Ascii CtrlChar Letter More Numeric Punctuation Separator Symbol Rune Render
                ----- -------- ------ ---- ------- ----------- --------- ------ ---- ------
                False    False   True ...    False       False     False  False      a
                False    False  False ...    False       False      True  False
                False    False   True ...    False       False     False  False      s
                False    False  False ...    False       False     False   True      ▸
                False    False  False ...    False       False     False  False      ·
                False    False  False ...    False       False     False   True      ⇢
                False    False  False ...    False       False     False  False      ⁞
                False    False  False ...    False       False      True  False
                False    False  False ...    False       False     False   True      ┐
                False    False  False ...    False       False     False   True      ⇽
                False    False  False ...    False       False     False   True      ▂
                False    False   True ...    False       False     False  False      f
                False    False   True ...    False       False     False  False      s
                False    False  False ...    False       False      True  False
        #>
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'Is'
        Value      = {
            $rune = $this
            # $str = $_
            [pscustomobject]@{
                PSTypeName  = 'Rune.IsA.unicodeClassesRecord.proto'
                Ascii       = $Rune.Value -le 0x1f
                CtrlChar    = $rune -match '\p{C}'
                Letter      = $rune -match '\p{L}'
                More        = '...' # https://www.regular-expressions.info/unicode.html
                Numeric     = $Rune -match '\p{N}'
                Punctuation = $Rune.Value -match '\p{P}'
                Separator   = $Rune -match '\p{Z}' # '\p{Separator}'
                Symbol      = $Rune -match '\p{S}' # \p{Symbol}
            }

        }
    }
    Update-TypeData @updateTypeDataSplat -Force

    $updateTypeDataSplat = @{
        TypeName                  = 'System.Text.Rune'
        DefaultDisplayPropertySet = 'Render', 'Hex', 'IsAscii', 'IsCtrlChar', 'Utf16SequenceLength', 'Utf8SequenceLength', 'Value'
    }

    Update-TypeData @updateTypeDataSplat -Force
}
catch {
    Write-Error "ThrownError while updating typedata. $_"
}

function Find.PreviewChain {
    <#
    .synopsis
        search for file to select, then bat it. experimenting with [List] parameters
    .notes
        todo next:
            -  [ ] make FZF not go full screen, or at least when less then N number of item exist
    #>
    [Alias('prof.Find.PreviewChain')]
    param(
        [Parameter()]
        [Collections.Generic.List[Object]]$ArgsFd = @(),

        [Parameter()]
        [Collections.Generic.List[object]]$ArgsFzf = @(),

        [Parameter()]
        [Collections.Generic.List[object]]$ArgsBat = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [switch]$ShowFolders, # do I ever want to, no, because of bat?

        [switch]$WhatIf
    )

    # [Collections.Generic.List[object]]$argsFd.AddRange(
    $argsFd.AddRange(
        @(
            '--color', 'always' # is valid
            # @( '--color=always' ) # is also valid
            '--type', 'file'
        )
    )
    $argsFzf.AddRange(
        # @( '--color=always' )
        @( '--ansi' )
    )
    $argsBat.AddRange(
        @( '--color=always' )
    )

    if ($WhatIf) {
        hr
        $ArgsFd | Join-String -sep ' ' -op "`nFd => " -os "`n"
        $ArgsFzf | Join-String -sep ' ' -op "`nFzf => " -os "`n"
        $ArgsBat | Join-String -sep ' ' -op "`nBat => " -os "`n"
        hr
        return
    }
    if ($Options.StripAnsi) {
        # original        fd | fzf | gi | %{ bat (gi -ea stop $_ ) }
        # $PSStyle.OutputRendering =
        fd @argsFd
        | fzf @argsFzf
        | StripAnsi
        | Get-Item
        | ForEach-Object { & 'bat' @argsBat (Get-Item -ea stop $_ ) }
        return
    }

    fd @argsFd
    | fzf @argsFzf
    | Get-Item
    | ForEach-Object { & 'bat' @argsBat (Get-Item -ea stop $_ ) }

    # normal
}

# Set-Location 'g:\temp\01'
# test.x -whatif
# test.x

function prof.findModule {
    param(
        # if not mandatory, better default?
        [Parameter(Mandatory)]
        [ArgumentCompletions(
            'StartAutomating',
            'Default',
            'All'
        )]$GroupName #= 'StartAutomating'
    )
    function __cachedListAvailableModules {
        $script:__profbigGetModAvailable ??= Get-Module -ListAvailable
    }
    [Collections.Generic.List[object]]$query_modules = @(
        switch ($CategoryName) {
            'StartAutomating' {
                __cachedListAvailableModules # Get-Module -ListAvailable
                | Where-Object { $_.CompanyName -match 'Start-Automating' -or $_.Copyright -match 'Start-Automating' }
                # | ForEach-Object Name | Sort-Object -Unique { $_.Name, $_.Source } Name
            }
            'Nin' {
                __cachedListAvailableModules # Get-Module -ListAvailable
                | Where-Object { $_.CompanyName -match 'Start-Automating' -or $_.Copyright -match 'Start-Automating' }

            }
            'Default' {
                Get-Module
            }
            'All' {

            }
            default { throw "UnhandledCategory: ${_}" }
        }
    )

    $query_modules = $query_modules
    | Sort-Object -Property Name -Unique

    $query_modules
    return



    # example:
    #    the super slow command is (get-module -ListAvailable)
    #    You are testing out filters on a command, while writing
    #    Like Is the PK of {Name,Module} correct? results are instantly available

    # refining a query, sorting is super cheap. listing is not.
    # sidebar: This is the **walrus** operator from python (or other languages)
    ($script:__profbigGetModAvailable ??= Get-Module -ListAvailable)
    | Where-Object { $_.CompanyName -match 'Start-Automating' -or $_.Copyright -match 'Start-Automating' }
    | Sort-Object -Unique Name
    | Format-Table *copy*, *name*
    #|fl *copy*, *name*

    #| % Name | sort -Unique

}
function prof.fastGcm {
    <#
    .SYNOPSIS
        sugar to sort, filter certain things, specific modules, etc.
    .description
        sugar for when you quickly want to find a running in cli

            Ps> gcm *bat* | sort CommandType, Module, Name  | ft -group Module |  rg 'bat|$' -i
    .EXAMPLE
        PS> prof.fastGcm -Verbose -Debug -Module ninmonkey.Console, functional
    #>
    [CmdletBinding()]
    param(
        # this is filtering, which is **not** the regex used to highlight
        # this filters results
        [Alias('RegexName', 'CommandNameRegex')] # which of the names is better?
        [Parameter(ParameterSetName = 'usingWildcard')] # verses regex
        [string]$CommandNameFilter,


        [Alias('Name')]
        [Parameter(ParameterSetName = 'usingWildcard')] # verses regex
        [string]$WildcardCommandName,

        [Alias('Module')]
        [Parameter()]
        [ArgumentCompletions(
            'CimCmdlets',
            'ClassExplorer',
            'functional',
            'Metadata',
            'Microsoft.PowerShell.Management',
            'Microsoft.PowerShell.Security',
            'Microsoft.PowerShell.Utility',
            'Microsoft.WSMan.Management',
            'ninmonkey.Console',
            'pansies',
            'Pester',
            'PSReadLine'
        )]
        [string[]]$ModuleName,


        [Alias('Hi')]
        [Parameter()]
        [string]$Highlight,


        [Parameter()]
        [string[]]$SortByProp = @('Module', 'Source', 'Name'), # @('CommandType', 'Module', 'Name'),
        [switch]$PassThru
    )
    Write-Warning 'structure in args, but logic isn''t really implemented'

    if ($RegexCommandName) {
        throw '📚 NYI ==> filter by regex instead of wildcards ==>  C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1/737e970b-11d5-4470-b2ac-b15b36c240e0' | Write-Warning
    }

    $getCommandSplat = @{
        # Name = $WildcardCommandName
    }
    # Name = '*{0}*' -f @( $WildcardCommandName )



    if ($ModuleName) {
        $getCommandSplat.Module = $ModuleName
    }

    $sortObjectSplat = @{
        Property = $SortByProp
    }

    $formatTableSplat = @{
        GroupBy = 'Module'
    }
    $ripGrepRegex = '({0})|$' -f $Highlight
    $RipGrepRegex | Join-String -op "ripGrepRegex: `n" -DoubleQuote | Write-Verbose
    [Collections.Generic.List[object]]$ripGrepArgs = @(
        '-i'
        '--color', 'always'
        # '--pretty' # equiv to: --color always --heading --line-number'
    )

    $ripGrepArgs | Join-String -sep ' ' -op 'RipGrep args => '
    | Write-Verbose

    $getCommandSplat | Format-Table | oss | Join-String -op 'Splat: Gcm  =: ' | Write-Verbose
    $sortObjectSplat | Format-Table | oss | Join-String -op 'Splat: Sort =: ' | Write-Verbose
    $formatTableSplat | Format-Table | oss | Join-String -op 'Splat: Format-Table =: ' | Write-Verbose
    if ($Highlight -and $PassThru) { throw "Can't use PassThru when regex highlight" }
    if ($Highlight) {
        Get-Command @getCommandSplat
        | Where-Object {
            if (-not $CommandNameFilter) {
                return $true
            }
            $_.Name -match $CommandNameFilter
        }
        | Sort-Object @sortObjectSplat
        | Format-Table @formatTableSplat
        | rg @ripGrepArgs

        return
    }


    if ($PassThru) {
        Get-Command @getCommandSplat
        | Where-Object { return $true } | Sort-Object @sortObjectSplat
        return
    }
    Get-Command @getCommandSplat
    | Where-Object { return $true } | Sort-Object @sortObjectSplat
    | Format-Table @formatTableSplat
}


function prof.previewChain {
    <#
    .synopsis
        simplified version. search for file to select, then bat it.
    #>
    param(
        [Collections.Generic.List[Object]]$ArgsFd,
        [Collections.Generic.List[object]]$ArgsFzf,
        [hashtable]$Options = @{},
        [switch]$WhatIf
    )

    [Collections.Generic.List[object]]
    $argsFd.AddRange(  [object[]]@( '--color', 'always' ))
    if ($WhatIf) { return }
    # original        fd | fzf | gi | %{ bat (gi -ea stop $_ ) }
    fd @argsFd
    | fzf @argsFzf
    | Get-Item
    | ForEach-Object { & 'bat' @argsBat (Get-Item -ea stop $_ ) }
}
# prof.previewChain -WhatIf

'📚 exit <== profile <==  C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1/d34a150d-75e4-4424-bcc2-56bfe32285ed' | Write-Warning

'📚 sub-dotsource ==> git find non-commit repos proto ==>  C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1/3ec3aa30-9cdb-4a54-87c3-ae92b1242c1e' | Write-Warning

. (Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2022\Pwsh\prototype\git - find unchangedrepo\git - find non-commit repos.ps1')

$PSDefaultParameterValues.Remove('*:verbose')
$PROFILE | Add-Member -NotePropertyName 'currentUserAllHosts_nin' -NotePropertyValue (Get-Item $PSCOmmandpath) -Force -ea 'ignore' -PassThru | Out-Null
. G:\temp\ai\prompt.minimal.ps1

