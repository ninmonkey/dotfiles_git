"enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning

$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib'
    $Env:PSModulePath
) | Join-String -sep ';'
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
    [string[]]$PathsToRemove = @(
        'C:\Program Files\PowerShell\Modules' # does not exist. maybe it's C:\Program Files\PowerShell\7 ?
        # maybe it's WinPS path? This exists: C:\Program Files\WindowsPowerShell\Modules'

        'C:\Program Files (x86)\Microsoft SQL Server\150\Tools\PowerShell\Modules\'
        'C:\Program Files\Intel\Wired Networking'  # says copyright intel 2013, files are modified at 2018, no longer used?
        # 'C:\Users\cppmo_000\SkyDrive\Documents\2022\client_BDG\self\bdg_lib' # after work
        # refactor location:
        'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github'
    )

    $joinUL_splat = @{
        Separator    = "`n  - "
        OutputPrefix = "`n- "
        OutputSuffix = "`n"
    }



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
    param( [int]$Num = 10, [switch]$Clear  )
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

"Running extra typedata, source: <$PSCOmmandpath>"
try {
    $updateTypeDataSplat = @{
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'Render'
    }
    Update-TypeData @updateTypeDataSplat -Force -Value {
        # coerce control chars to safe symbols
        $isCtrlChar = $this.Value -ge 0 -and $this.Value -le 0x1f
        if (-not $isCtrlChar) {
            return $this.ToString()
        }
        $Rune = $isCtrlChar ? [Text.Rune]::New($this.Value + 0x2400 ) : $this
        return $Rune.ToString()
    }
    $updateTypeDataSplat = @{
        TypeName   = 'System.Text.Rune'
        MemberType = 'ScriptProperty'
        MemberName = 'Hex'
    }
    Update-TypeData @updateTypeDataSplat -Force -Value {
        '0x{0:x}' -f @($This.Value)
    }
}
catch {
    Write-Error "ThrownError while updating typedata. $_"
}



