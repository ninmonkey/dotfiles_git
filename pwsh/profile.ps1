$global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module

$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.MainEntry_nin = $PSCommandPath | Get-Item
remove-module PSUtil*, PSFra*work* # keeps loading the string error on me
Import-Module 'Pansies'
# try disable ShellIntegration on menu completer, maybe more.
$Global:__VSCodeHaltCompletions = $true
$env:VSCODE_SUGGEST = 0

'trace.👩‍🚀.parse: [1] $Profile.MainEntryPoint : /pwsh/profile.ps1'
    | write-verbose -verb
    # | write-host -bg '7baa7a' -fg black
& {
    $splatAlias = @{ PassThru = $true ; ea = 'ignore'}
    Set-Alias @splatAlias -name '.short.Type' -va 'Ninmonkey.Console\Format-ShortTypeName'
    Set-Alias @splatAlias -name '.abbr.Type'  -va 'Ninmonkey.Console\Format-ShortTypeName'
    Set-Alias @splatAlias -name 'st'          -va 'Ninmonkey.Console\Format-ShortTypeName' -desc 'Abbreviate types'
    Set-Alias @splatAlias -name '.fmt.Type'   -Va 'Ninmonkey.Console\Format-ShortTypeName' -desc 'Abbreviate types'
    Set-Alias @splatAlias -name 'Yaml'        -Va 'powershell-yaml\ConvertTo-Yaml'
    Set-Alias @splatAlias -name 'Yaml.From'   -Va 'powershell-yaml\ConvertFrom-Yaml'
    Set-Alias @splatAlias -name 'copilot'     -Va 'aws-copilot-cli'
 } | Join-String -sep ', ' -op "   => aliases: "

# required or else it breaks piping 'fd | fzf --preview bat'
$PSNativeCommandArgumentPassing = [System.Management.Automation.NativeArgumentPassingStyle]::Legacy
$PSNativeCommandArgumentPassing | Join-String -f 'Setting: $PSNativeCommandArgumentPassing = {0}'
    | write-verbose

# edit: 2024-03-20
# Foreground.FromRgb('#c7af51', #c99067)

# move-to-shared
$env:PATH += ';', 'C:\Ruby32-x64\bin' -join '' # should already exis, VS Code is missing
Set-Alias 'Tree' 'PSTree\Get-PSTree' -ea 'Ignore'

$setAliasSplat = @{
    Ea = 'ignore'
    Scope       = 'global'
    Name        = 'TabExpansion2_Original'
    Value       = $ExecutionContext.InvokeCommand.GetCommand(
        'TabExpansion2', 'Function'
    )
    Description = 'Test out the vanilla completion'
}
Set-Alias @setAliasSplat

# javascript, npm / new package manager
if(-not ($ENV:PATH -split ';' -match 'pnpm')) {
       $ENV:PATH += ';', $Env:PNPM_HOME -join ''
}
New-Alias -ea 'ignore' 'nin.MergeHash' 'Ninmonkey.Console\mergeHashtable' -PassThru
function .Assert.Clamp {
    <#
    .SYNOPSIS
        maybe monkey business?
    .NOTES
        requires parameterset to make it easy: .Assert.Clamp 4 3 100
    .link
        .Assert.Clamp
        .fmt.Clamp
        .Where.Clamp
    #>
    [CmdletBinding()]
    param(
        # converts to non terminating, silent errors
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Value,
        $MinValue,
        $MaxValue
        # [Alias('Silent')]
        # [switch]$NullOnError

    )
    process {
        if( $Value -ge $MinValue -and $Value -le $MaxValue ) {
            return
        }
        Write-Error ('Error Value {0} is out of range Min: {1}, Max: {2}' -f ($Value, $MinValue, $MaxValue))
    }
}
function .fmt.Clamp {
    <#
    .SYNOPSIS
        Clamp something with a range, with specific data type as one invoke
    .EXAMPLE
        PS> 40..300 | .fmt.Clamp 20 130 | Grid
    .EXAMPLE
        # 30.94 | .fmt.Clamp -min 20 -max 40 -Verbose
        0..40 | .fmt.Clamp.Int -MinValue 10 -MaxValue 30 -OutputFormat Int
        | Grid

            10, 10, 10, 10, 10, 10, 10, 10
            10, 10, 10, 11, 12, 13, 14, 15
            16, 17, 18, 19, 20, 21, 22, 23
            24, 25, 26, 27, 28, 29, 30, 30
            30, 30, 30, 30, 30, 30, 30, 30
            30
    .EXAMPLE
        PS> 30.999 | .fmt.Clamp -min 20 -max 40 -Verbose -As ([Int16])

        PS> 1 | .fmt.Clamp -min 10 -MaxValue 400 -Verbose -As Double
            VERBOSE: [Double], [Int32], [Double], [Int32], [Double]

        PS> 30.999 | .fmt.Clamp -min 20 -max 40 -Verbose -As ([Int16])
            VERBOSE: coerceTo type: short
            VERBOSE: [Int16], [Int32], [Int16], [Int32], [Int16]
31
10
    .link
        .Assert.Clamp
        .fmt.Clamp
        .Where.Clamp

        [Math]::MaxMagnitude
        [Math]::MinMagnitude
        [Math]::Min
        [Math]::Max
        [Math]::Clamp
    #>
    [CmdletBinding()]
    [Alias(
        '.fmt.Clamp.Int', # future: invoke name sets type constraint
        '.fmt.Clamp.Double'
    )]
    [OutputType( [int], [double] )]
    param(
        [Alias('Min')]
        [Parameter(Mandatory, Position = 0)]
        $MinValue,
        [Alias('Max')]
        [Parameter(Mandatory, Position = 1)]
        $MaxValue,

        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        [Parameter()]
        [Alias('As')]
        [ArgumentCompletions(
            'Int', 'Double', 'Auto'
        )]
        [string]$OutputFormat,

        [Alias('Silent')]
        [string]$ErrorsAsNull

    )
    begin {
        if ($MaxValue -lt $MinValue) {
            'MaxValueIsLessThanMinException: ', $MinValue, $MaxValue -join ', ' | Write-Error
            return
        }
    }
    process {
        if ($ErrorsAsNull) {
            throw 'WIP: next: auto coerce out of bounds, etc. to nulls, or nothing'
        }
        # if ($true -or $MaxValue -lt $MinValue) { throw 'MaxValueIsLessThanMinException' }
        if ( [String]::IsNullOrWhiteSpace( $OutputFormat ) ) {
            $OutputFormat = 'Auto'
        }
        foreach ($num in $InputObject) {



            switch ($OutputFormat) {
                { $_ -in @('Int', 'Double') } {
                    $coercedMin = $MinValue -as $OutputFormat
                    $coercedMax = $MaxValue -as $OutputFormat
                    $result = [Math]::Clamp( $num, $coercedMin, $coercedMax)
                    $result = $result -as $OutputFormat
                    break
                }
                'Auto' {
                    # ie: implicit
                    $coercedMin = $MinValue
                    $coercedMax = $MaxValue
                    $result = [Math]::Clamp( $num, $coercedMin, $coercedMax)
                    $result = $result # -as $OutputFormat
                    break
                }
                default {
                    # also coerce return type
                    'coerceTo type: {0}' -f @( $OutputFormat) | Write-Verbose
                    try {
                        $coercedMin = $MinValue -as $OutputFormat
                        $coercedMax = $MaxValue -as $OutputFormat
                        $result = [Math]::Clamp( $num, $coercedMin, $coercedMax)
                        $result = $result -as $OutputFormat
                    }
                    catch {
                        'CoerceTypeFailed: object -as [ {0} ]' -f $OutputFormat | Write-Warning
                        throw $_
                    }
                } #throw "UnhandledOutputFormatException: $OutputFormat"}
            }
            # $lower = [Math]::Max( $MinValue, $Num )
            # $upper = [Math]::Min( $MaxValue, $Num )
            # .fmt.Clamp.Int -MinValue $MinValue -MaxValue $MaxValue

            $result, $MinValue, $coercedMin, $MaxValue, $coercedMax #|  .GetType().Name
            | Join-String -sep ', ' -prop { Format-ShortTypeName -InputObject $_ }
            | Write-Verbose
            $result
        }
    }
}


function Where-FilterByClamp {
    <#
    .SYNOPSI
        like .fmt.Clamp , except used as a filter verb instead of formatting
    .EXAMPLE
        0, 4, 10 | .Where.Clamp 3 11 | Should -beExactly @(4, 10)
    .link
        .Assert.Clamp
        .fmt.Clamp
        .Where.Clamp
    #>
    [Alias(
        '.Where.WithinCamp',
        '.Where.Clamp', '.FilterBy.Clamp')]
    param(
        [Alias('Min')]
        [Parameter(Mandatory, Position = 0)]
        $MinValue,
        [Alias('Max')]
        [Parameter(Mandatory, Position = 1)]
        $MaxValue,

        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        [Parameter(Position = 2)]
        #[NinPropertyNameOrExpression( arg = 'stuff' )] # coerces into a value automatically
        [object]$PropertyNameOrExpression
    )

    process {
        # [Parameter()]
        # [Alias('As')]
        # [ArgumentCompletions(
        #     'Int', 'Double', 'Auto'
        # )]
        # [string]$OutputFormat

        if (-not $PSBoundParameters.ContainsKey('PropertyNameOrExpression')) {
            #none, so use no property
            $valueToTest = $InputObject
        }
        else {
            if ($PropertyNameOrExpression -is 'ScriptBlock') {
                throw 'NYI: Next coerce script block to a value, as a argumentransformation'
            }
            $valueToTest = $InputObject.Psobject.Properties[$PropertyNameOrExpression ].Value
        }
        write-warning 'verify this logic, was on a tangent.'
        $targetValue = .fmt.Clamp -min $MinValue -max $MaxValue -InputObject $InputObject
        $value = .Assert.Clamp -min $MinValue -max $MaxValue -NullOnError

        $maybeValue = $InputObject.Psobject.Properties
    }



    # [CmdletBinding()]
    # $Input | ? { }
}


# always prefer dev version
# remove-module pipescript
# $Env:PSModulePath = @(
#     Get-Item -ea 'continue' -Path 'H:/data/2023/pwsh/my🍴'
#     $Env:PSModulePath
# ) | Join-String -sep ';'

# Impo Ninmonkey.Console -PassThru


function Nancy.Write.InfoStream.AsTable {
    <#
    .SYNOPSIS
        quickly Format-Table. render as text then writes to the InfoStream as infa Continue
    #>
    [Alias('Nancy.Write.InfoTable')]
    param(
        # [Alias('Fg')]
        # [string]$ColorFg,
        # [Alias('Bg')]
        # [string]$ColorBg
    )
    $Input | Format-Table -auto | Out-String -Width 1kb | Write-Information -infa 'Continue'
}




# $env:EDITOR = 'nvim'

$OutputEncoding =
    [Console]::OutputEncoding =
        [Console]::InputEncoding =
            [System.Text.UTF8Encoding]::new()


$env:LESS = '--quiet --raw-control-chars --quit-on-intr --ignore-case --prompt :' # from sci: <https://discord.com/channels/180528040881815552/575331370264428584/1112842371059687544>
$env:LESSCHARSET = 'utf-8'


$Env:PSModulePath = @(
    # temp because the full filepath is one directory too deep
    'H:\data\2023\pwsh\PsModules\CacheMeIfYouCan'
    # and then
    'H:/data/2023/pwsh/PsModules.Import'
    'H:/data/2023/pwsh/PsModules'
    'H:/data/2023/dotfiles.2023/pwsh/dots_psmodules'
    'H:/data/2023/pwsh/PsModules.dev/GitLogger'
    # 'H:/data/2023/pwsh/PsModules.dev' # really temp but required because needs parent dir

    # 'H:\data\2023\pwsh\PsModules\Ninmonkey.Console\zeroDepend_autoloader\logging.Write-NinLogRecord.ps1'
    # 'H:/data/2023/pwsh/GitLogger'
    $Env:PSModulePath
) | Join-String -sep ';'

$Env:PSModulePath -split ';'
    | Join-String -sep ', ' -op 'updated PSModulePath := [ ' -os ' ] '
    | Write-Verbose -Verb

Import-Module 'Ninmonkey.Console' -PassThru
    | Join-String { $_.Name, $_.Version -join ' = '}
    | New-Text -fg 'gray30' -bg 'gray10' | Join-String

# if($false) {
#     Import-Module H:\data\2023\pwsh\PsModules\TypeWriter\Output\TypeWriter -Force -PassThru -DisableNameChecking -wa Ignore
#     | Join-String { $_.Name, $_.Version -join ': ' } -f "{0}" -sep ', '
#     | New-Text -bg 'gray15' -fg 'gray40' | Join-String
# }

$PROFILE | Add-Member -NotePropertyName 'MainEntryPoint' -NotePropertyValue (Get-Item $PSCommandPath) -Force -PassThru -ea Ignore
$PROFILE | Add-Member -NotePropertyName 'MainEntryPoint.UsingNamespaces' -NotePropertyValue (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1') -Force -PassThru -ea Ignore
$PROFILE | Add-Member -NotePropertyName 'MainEntryPoint.__init__' -NotePropertyValue (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1') -Force -PassThru -ea Ignore
$__dotfilesRepoRoot = 'H:/data/2023/dotfiles.2023'
$PROFILE | Add-Member -force -ea ignore -PassThru -NotePropertyMembers @{
    VSCode = @{
        Local = [ordered]@{
            Settings_Json =
                Join-Path $Env:AppData 'Code/User/settings.json' # ex: C:\Users\cppmo_000\AppData\Roaming\Code\User\settings.json
            Keybindings_Json =
                gi (Join-Path $Env:AppData 'Code/User/keybindings.json')
            Tasks_Json =
                gi (Join-Path $Env:AppData 'Code/User/tasks.json')
            Snippets_Root =
                gi (Join-Path $Env:AppData 'Code/User/snippets' )
            Snippets_All =
                gci -recurse (gi (Join-Path $Env:AppData 'Code/User/snippets' ))
                    | Sort-Object Fullname
        }
        DotfilesRepo = [ordered]@{
            Settings_Json =
                Join-Path $__dotfilesRepoRoot 'vscode/profiles/desktop-main/settings.json'
            Keybindings_Json =
                Join-Path $__dotfilesRepoRoot 'vscode/profiles/desktop-main/keybindings.json'
            Tasks_Json =
                Join-Path $__dotfilesRepoRoot 'vscode/profiles/desktop-main/tasks.json'
            Snippets_Root =
                Join-Path $__dotfilesRepoRoot 'vscode/profiles/desktop-main/snippets'
            Snippets_all =
                gci -recurse (gi (Join-Path $__dotfilesRepoRoot 'vscode/profiles/desktop-main/snippets'))
                | Sort-Object Fullname

        }
    }
}

function VsCode.Dotfiles.CopyToRepo {
    <#
    .SYNOPSIS
        Copy (some) files to the dotfiles repo

    #>
    param()

    @(  # I think you need to use passthru to see the write-progress
        # Can I chain it to also use CountOf ?
        ## [1]
        $SourcePath = $PROFILE.VSCode.Local.Settings_Json
        $DestPath   = $PROFILE.VSCode.DotfilesRepo.Settings_Json

        @( 'from: {0}' -f ( $SourcePath )
            'to:   {0}' -f ( $DestPath ) )
            | Join-String -sep "`n" | Dotils.Write-DimText | Infa

        Get-Item -ea 'stop' $SourcePath
            | Copy-Item -Destination $DestPath -PassThru

        ## [2]
        $SourcePath = $PROFILE.VSCode.Local.Keybindings_Json
        $DestPath   = $PROFILE.VSCode.DotfilesRepo.Keybindings_Json

        @( 'from: {0}' -f ( $SourcePath )
            'to:   {0}' -f ( $DestPath ) )
            | Join-String -sep "`n" | Dotils.Write-DimText | Infa

        Get-Item -ea 'stop' $SourcePath
            | Copy-Item -Destination $DestPath -PassThru

        ## [3]
        $SourcePath = $PROFILE.VSCode.Local.Tasks_Json
        $DestPath   = $PROFILE.VSCode.DotfilesRepo.Tasks_Json

        @( 'from: {0}' -f ( $SourcePath )
            'to:   {0}' -f ( $DestPath ) )
            | Join-String -sep "`n" | Dotils.Write-DimText | Infa

        Get-Item -ea 'stop' $SourcePath
            | Copy-Item -Destination $DestPath -PassThru

    ) | CountOf

    'snippets: nyi' | write-warning

    # pushd $DestPath.Directory
    # pwd
    $PROFILE.VSCode.DotfilesRepo.Settings_Json | Goto -AlwaysLsAfter

    # git log -n 2
    # git log -n 3 --oneline --color=always | Join.UL
    git log -n 3 --oneline | new-text -fg '#b5bcd1' | Join-String -sep ' '
    # 'staged, commit message?'
    # fd --changed-within 15minutes -tf
}
$VerbosePreference = 'continue'

[Collections.Generic.List[Object]]$__all_PSModulePaths = $ENV:PSmodulePath -split ';'
| Sort-Object -Unique

$global:__ninBag.Profile.PSModulePath = [Ordered]@{
    All                  = $__all_PSModulePaths
    WarningSome          = 'OfTheQueries aren''t showing the full values'
    VirtualEnvs          = @(
        $__all_PSModulePaths | Where-Object FullName -Match '^e:\\PSModulePath'
    )
    SkyDrive             = @( $__all_PSModulePaths | Where-Object FullName -Match 'SkyDrive' )
    UserProfile_Children = @(
        $__all_PSModulePaths
        | Where-Object { $_.FullName -match ([regex]::Escape( $Env:UserProfile)) }
    )
    Not_MyVirtualEnv     = $__all_PSModulePaths
    | Where-Object FullName -NotMatch 'SkyDrive'
    | Where-Object Fullname -NotMatch '^e:\\PSModulePath'

    VSCode_Children      = @(
        $__all_PSModulePaths
        | Where-Object FullName -Match 'vscode|ms-vscode'
    )
    ProgFiles_Children   = @(
        $__all_PSModulePaths
        | Where-Object FullName -Match 'program\s+files'
    )
    Windows_Children     = @(
        $__all_PSModulePaths
        | Where-Object FullName -Match 'windows|system32'
    )
}
$PROFILE | Add-Member -NotePropertyMembers @{
    Nin = $global:__ninBag.Profile.PSModulePath
} -Force -PassThru #-ea Ignore
# $PROFILE | Add-Member -NotePropertyMembers $global:__ninBag.Profile.PSModulePath -force  -passthru #-ea Ignore

function __aws.sam.InvokeAndPipeLog {
    # cleanup: delete or go to bintils
    param(
        [string]$LogBase = 'g:\temp',
        [string]$LogName = 'aws_raw.log',
        [switch]$WithoutStdout,
        [switch]$NeverOpenLog,

        [switch]$NeverTruncateLog
    )
    $FullLogPath = Join-Path $LogBase $LogName
    if (-not(Test-Path $FullLogPath) -and -not $NeverTruncateLog) {
        New-Item $LogBase -Name $LogName -ItemType file -Force -ea ignore
    }
    (Get-Item $FullLogPath) | Join-String -f "`n  => wrote <file:///{0}>"

    if (-not $NeverOpenLog) {
        code -g (Get-Item $FullLogPath)
    }
    & sam build --debug --parallel --use-container --cached --skip-pull-image --profile BDG *>&1
        | StripAnsi # Pwsh7.3 pipes color from STDERROR
        | ForEach-Object {
            $addContentSplat = @{
                PassThru = -not $WithoutStdout
                Path     = $FullLogPath
            }
            $_ | Add-Content @addContentSplat
        }

    (Get-Item $FullLogPath) | Join-String -f "`n  => wrote <file:///{0}>"

    New-BurntToastNotification -Text 'SAM Build Complete', "$FullLogPath"

    $target = $FullLogPath | Get-Item -ea stop

    $FullCleanLogPath = Join-Path $Target.Directory ($target.BaseName + '.cleaned.log')
    # $FullCleanLogPath = $FullLogPath | gi | % BaseName

    # todo: make it pipe as a stream, not requiring end.
    # cleanup
    Get-Content $FullLogPath | Where-Object {
        $shouldKeep = $true
        $FoundIgnoreCopySource = $_ -match ('^' + [Regex]::Escape('Copying source file (/tmp/samcli/source/'))
        $FoundIgnoreCopyMeta = $_ -match ('^' + [Regex]::Escape('Copying directory metadata from source (/tmp/samcli/source/'))
        $FoundOthers = $_ -match '^(Copying source file|Copying directory metadata from source)'

        if ($FoundIgnoreCopyMeta -or $FoundIgnoreCopySource) { $ShouldKeep = $false }
        if ($FoundOthers) { $shouldKeep = $false }
        return $shouldKeep
    } | Add-Content -Path $FullCleanLogPath

     (Get-Item $FullCleanLogPath) | Join-String -f "`n  => wrote <file:///{0}>"
}


function nin.GroupByLinqChunk {
    <#
    .SYNOPSIS
        original was:
            [string[]] $crumbs = (gi .).FullName -split '\\'
            [System.Linq.Enumerable]::Chunk($crumbs, 5) | json
    #>
    # cleanup: delete or go to ninmonkey/notebooks/pwsh
    throw 'not finished, see "RenderLongPathNames"'
    $fullName = Get-Item .
    [string[]] $source = 'hey', 'world', (0..100 -join '_')
    [string[]] $crumbs = (Get-Item .).FullName -split '\\'
    [System.Linq.Enumerable]::Chunk($crumbs, 5)
    | ForEach-Object {
        $StrUnitSep = '␟'
        $_ | Join-String -sep (" ${fg:gray30}${StrUnitSEp}${fg:clear} ")
    }
}

function nin.RenderUnicodeRange {
    <#
    .EXAMPLE
        Pwsh> nin.RenderUnicodeRange -InputRunes @(0x2400..0x2410)
        Pwsh> nin.RenderUnicodeRange -InputRunes (0x2400..0x2410 -as [Text.Rune[]])
    .NOTES
        # cleanup: delete or go to ninmonkey/notebooks/pwsh
    #>
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [System.Text.Rune[]]$InputRunes,
        [int]$ColumnCount
    )
    begin {
        $Columns ??= 8
        [Collections.Generic.List[System.Text.Rune]]$Runes = @()
    }
    process {
        $Runes.AddRange($InputRunes )
    }
    end {
        $minCellsPerRecord = ' 0xffff00 => __ '.Length

        $w = $host.ui.RawUI.WindowSize.Width
        # $t = @( $w / $minCellsPerRecord)
        $groupSize = $ColumnCount ?? [int]($w / $minCellsPerRecord)
        $groupSize = [Math]::Max(1, $GroupSize)

        # $chars = '-' * $w -join ''

        # $padding = "`n" * $ExtraLines

        # $output = @(
        #     $padding, $chars, $padding
        # ) -join ''

        [Linq.Enumerable]::Chunk($Runes, $groupSize)
        | ForEach-Object {
            $_ | Join-String {
                '{0:x} => {1}' -f @(  $_.Value, $_ )
                | Join-String -op "${fg:gray30}${bg:gray60}" -os $PSStyle.Reset
            } -sep (" ${fg:gray30} ")
        }
        $Runes.Count | Join-String -f 'total runes: {0}' | Write-Information -Infa 'Continue'


    }
}
# $fullName = gi .
# [Text.Rune[]]$rune = 0x2500..0x259f + 0x4dc0..0x4dff + 0xfe20..0xfe2f
# [Linq.Enumerable]::Chunk($rune, 7)
# | %{
#    $_ | Join-String {
#       '{0:x} => {1}' -f @(  $_.Value, $_ )
#       | Join-String -op "${fg:gray30}${bg:gray60}" -os $PSStyle.Reset
#       } -sep (" ${fg:gray30} ")
# }
#| %{
#  $_ | Join-String -sep ' ' -FormatString '{0:x2}'
#  }  | Join-String -sep "`n" -f '[{0}]'

function RenderModuleName {
    <#
    .SYNOPSIS
        visually summarize a module, maybe make a EzFormat
    .EXAMPLE
        Get-Module | RenderModuleName
        # cleanup: delete or go to ninmonkey/notebooks/pwsh
    #>
    $Input
    | Join-String {
        $cDim = "${fg:gray30}${bg:gray40}"
        $cBold = "${fg:gray80}${bg:gray20}"
        $cDef =   $PSStyle.Reset # or "${fg:clear}${bg:clear}"

        "${cBold}{0} = {1}${cDef}`n`t${cDim}{2}${cDef}`n" -f @(
            $_.Name
            $_.Version
            $_.Path
        )
    } | Join-String -os $PSStyle.Reset
}

function Dotils.Render.Callstack.Basic {
    param(
        #by param to simplify piping
        [Parameter(Mandatory,Position=0)]
        [object[]]$InputObject
    )
    function _render.Frame {
        param(
            [Alias('Frame')]
            [Parameter(Mandatory,Position=0)]
            $InputObject
        )
        $InputObject | Join-String -sep "`n" {
            "`n"
            $_.Command
            "`n    "
            $_.Location
        }
    }

    $InputObject | ForEach-Object {
        _render.Frame $_
    }
    # Get-PSCallStack | Join-string -sep "`n" {
    #     "`n"
    #     $_.Command, "`n    ", $_.Location
    # }
}
function RenderLongPathNames {
    <#
    .SYNOPSIS
        display a long path, broken into chunks for extra readability
    .EXAMPLE
    Pwsh>
    $env:LOCALAPPDATA | RenderLongPathNames -GroupSize 1
            C:
            Users
            cppmo_000
            AppData
            Local
    .EXAMPLE
    Pwsh> 'a'..'e' -join '\' | RenderLongPathNames

        a ␟ b ␟ c ␟ d ␟ e

    .EXAMPLE
    Pwsh>
    gi . | renderLongPathNames -GroupSize 4

        H: ␟ data ␟ foo ␟ 2023.03.12
        core ␟ src ␟ pass1 ␟ lab-lambda-runtime
        examples ␟ demo-runtime-layer-function ␟ .aws-sam
    .EXAMPLE
    Pwsh>
    gi . | % FullName

        H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtime\examples\demo-runtime-layer-fu
        nction\.aws-sam
    .example
        # using kwargs
        Pwsh> RenderLongPathNames -InputObject (gi .) -Options @{ ChunksPerLine = 4 }

    .example
        Pwsh> RenderLongPathNames -InputObject (gi .) -GroupSize 5

            H: ␟ data ␟ client_bdg ␟ 2023.03.17-bdg
            core ␟ src ␟ pass1 ␟ lab-lambda-runtime
            examples ␟ demo-runtime-layer-function ␟ .aws-sam
    .example
        # others

        gi . | RenderLongPathNames -GroupSize 3 -Options @{ Reverse = $true }

    #>
    [Alias(
        '.Render.PathNames',
        '.fmt.Path.LongNames',
        'fmt.Path.LongNames'
    )]
    [CmdletBinding()]
    param(
        [Alias('Path', 'PSPath', 'FullName')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$InputObject,

        [int]$GroupSize = 5,
        [ArgumentCompletions(
            '@{ Reverse = $true }',
            '@{ ChunksPerLine = 5 }'
        )]
        [hashtable]$Options
    )
    begin {
        [Collections.Generic.List[Object]]$items = @()
        $Config = mergeHashtable -OtherHash ($Options ?? @{}) -BaseHash @{
            ChunksPerLine = $GroupSize ?? 5
            Reverse       = $false
        }
        $StrUni = @{
            GroupSep  = '␝'
            RecordSep = '␞'
            UnitSep   = '␟'
            WordSep   = '⸱'
        }
    }
    process {
        $Items.AddRange(@($InputObject))
    }
    # $all_segments = (Get-Item $InputObject | ForEach-Object FullName ) -split '\\'
    # $n = $Config.ChunksPerLine

    # $all_segments
    # | Select-Object -First $n | Join-String -sep '/'


    # $all_segments # remaning
    # | Select-Object -Skip $n | Join-String -sep '/' -op '    '


    # $fullName = Get-Item .
    # [string[]] $source = 'hey', 'world', (0..100 -join '_')
    end {


        $items
        | ForEach-Object {
            # $curItem = Get-Item $_ # -ea 'stop'
            $curItem = $_ # -ea 'stop'
            if ($null -eq $curItem) { return }

            $PathOrString = Get-Item $CurItem -ea 'ignore' | ForEach-Object Fullname
            $PathOrString ??= $CurItem



            [Collections.Generic.List[Object]]$all_segments = @( $PathOrString -split '\\' )
            if ($Config.Reverse) {
                $all_segments.Reverse()
            }
            # [string[]] $all_segments = (Get-Item $curItem).FullName -split '\\'
            [System.Linq.Enumerable]::Chunk(
                $all_segments, $Config.ChunksPerLine
            )
            | ForEach-Object {

                $unitSepSplat = @{
                    Separator = ' {0}{1}{2} ' -f @(
                        "${fg:gray30}"
                        $StrUni.UnitSep
                        "${fg:clear}"
                    )
                }

                $_ | Join-String @unitSepSplat
            }
        }
    }

}


## refactor, move to Nancy 2023-05-15
function RenderHashtablePaths {
    <#
    .SYNOPSIS
    render semantic paths from a hashtable, like Format-List without extra bloat

    .DESCRIPTION
    colors emphasize key names and MSB of filepaths, dim the LSB

    .EXAMPLE
    .Render.Hash.Semantic.PathNames -InputHash @{
        Home = gi ~
        Temp = gi temp:\
        SelfCommand = gi $PSCommandPath
    } 'SemanticPath'

    $SomePaths = @{
        Home         = Get-Item ~
        AppData      = Get-Item $Env:AppData
        LocalAppData = Get-Item $Env:LocalAppData
        UserProfile  = Get-Item $Env:UserProfile
    }
    .Render.Hash.Semantic.PathNames -InputObject $SomePaths -OutputMode SemanticPath -SortByKey Value
    .Render.Hash.Semantic.PathNames -InputObject $SomePaths -OutputMode SemanticPath


    .NOTES
    General notes
    #>
    [Alias('.Render.Hash.Semantic.PathNames')]
    [CmdletBinding()]
    param(
        [Alias('Hash', 'InputHash')]
        [Parameter(Position = 0, Mandatory)]
        [hashtable]$InputObject,

        [Parameter(Position = 1)]
        [ArgumentCompletions(
            'Default',
            'SemanticPath'
        )]
        [string]$OutputMode = 'SemanticPath',

        # sort not 100% working as expected maybe need to clone dict?
        [Alias('Sort')]
        [Parameter(Position = 2)]
        [ValidateSet('Key', 'Value')]
        [string]$SortByKey
    )
    if ($SortByKey) {
        $sortSplat = @{
            InputHash = $InputObject
            SortBy    = $SortByKey
        }
        $InputObject = Ninmonkey.Console\Sort-Hashtable @sortSplat
        Write-Warning 'sort not working in all cases, maybe using implicit case casensitive?'
    }

    Hr -fg orange
    Label 'OutputMode' $OutputMode
    switch ( $OutputMode ) {
        'Default' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                "{0}`n{1}" -f @(
                    $_.Key
                    $_.Value
                ) }
        }
        'SemanticPath' {
            $C = @{}
            $C.Fg_Dim = "${fg:gray30}"
            $C.Fg_Dim = "${fg:gray15}"
            $C.Fg = "${fg:gray65}"
            $C.Fg_Em = "${fg:gray85}"
            $C.Fg_Max = "${fg:gray100}"
            $C.Fg_Min = "${fg:gray0}"
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                $segs = $_.Value -split '\\'
                $render_pathColor = @(
                    $body = $segs | Select-Object -SkipLast 2
                    | Join-String -sep '/'

                    $tail = $segs | Select-Object -Last 2
                    | Join-String -sep '/'

                    $C.Fg_Dim
                    $Body
                    $C.Fg_Em
                    '/'
                    $Tail
                    $PSStyle.Reset
                ) | Join-String

                $render_key = @(
                    $C.Fg_Max
                    $_.Key
                    $PSStyle.Reset
                ) | Join-String

                # '{0}{1}' -f @(
                "{0}`n{1}" -f @(
                    $render_key
                    $render_pathColor) }
        }
        'Default2' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                '{0} : {1}' -f @(
                    $_.Key
                    $_.Value ) }
        }
        default {
            throw "UnhandledMode: $OutputMode"
        }

    }
    Hr
}

function nin.Text.CompareHowMuchCommon {
    <#
    .SYNOPSIS
        highlight the difference in two strings. pass in any order

    .EXAMPLE
        $info = nin.Text.HowMuchCommonCompare -A 'abc' -B 'abcde' -PassThru
    .EXAMPLE
        # highlights folder with it's parent folder
        $info = nin.Text.CompareHowMuchCommon -A (gi .) -B (gi ..) -PassThru
        $info.MatchInfo

    .EXAMPLE
        nin.Text.HowMuchCommonCompare -A 'abc' -B 'abcde'
    .EXAMPLE
        $something | nin.Text.HowMuchCommonCompare -A 'abc'
    .EXAMPLE

    .notes
        original  command:
            (gi . ).FullName |sls -Pattern ([regex]::Escape($exp.FullName))
    #>
    [Alias('nin.Text.HowMuchCommonCompare')]
    [CmdletBinding()]
    param(
        [Alias('ObjectA')]
        # detects size, doesn't actually matter which order A and B are passed
        [Parameter(Position = 0, Mandatory)]
        [string]$A,

        [Alias('ObjectB')]
        # todo: future: allow pipeline for sugar
        # [Parameter(Position=1, Mandatory)]
        [Parameter(Position = 1, ValueFromPipeline)]
        [string]$b,
        [switch]$PassThru
    )
    $meta = [Ordered]@{}

    if ($A.Length -lt $b.Length) {
        $Short = $A; $Long = $B
    }
    else {
        $Short = $B; $Long = $A
    }
    $matchInfoResult = $Long | Select-String -Pattern ([Regex]::Escape($Short))
    $meta += @{
        A         = $A
        B         = $B
        ALen      = $A.Length ?? 0
        BLen      = $B.Length ?? 0
        MatchInfo = $matchInfoResult
    }
    # $InformationPreference = 'continue'
    if ($PassThru) {
        $meta.MatchInfo.Matches | Format-Table -auto | Out-String
        | Write-Information # -infa 'Continue'
        return [pscustomobject]$meta
    }
    else {
        $meta.MatchInfo.Matches | Format-Table -auto | Out-String
        | Write-Information # -infa 'Continue'
        return [pscustomobject]$matchInfoResult #| Write-Information -infa 'continue'
    }
}

# shared (all 3)
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

# toggle /w env var
if ($global:__nin_enableTraceVerbosity) { $PSDefaultParameterValues['*:verbose'] = $True }
$PSDefaultParameterValues.Remove('*:verbose')

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1' ))

## completers

<#
- see: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4>
- native command sample: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4#example-3-register-a-custom-native-argument-completer>
#>



if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


















return





if ($global:__nin_enableTraceVerbosity) { "enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning }
. (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1')
if ($global:__nin_enableTraceVerbosity) {}

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1' ))

## completers

<#
- see: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4>
- native command sample: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4#example-3-register-a-custom-native-argument-completer>
#>
import-module pansies
'cleanup: <file:///{0}>' -f @(
    Join-Path $env:Nin_Dotfiles 'pwsh/src/autoloadNow_ArgumntCompleter-butRefactor.ps1'
) | write-host -bg '#587458' -fg 'black'

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/autoloadNow_ArgumntCompleter-butRefactor.ps1') )
# it  <== Profile: docs/profile.ps1/ => Pid: '${pid}'" | Write-Warning

function Find-ConsoleKeybinding {
    <#
    .NOTES
    see:
        - help: about_ANSI_Terminals
        - Set-PSReadlineKeyhandler
        - [Microsoft.PowerShell.SetPSReadLineKeyHandlerCommand] | fime
        #>
    [Alias('FindKeybind')]
    param(
        [ArgumentCompletions(
            "'search|history'", "'\+'",
            "'^vi'", 'line', 'move', 'yank', 'space', 'enter', 'Ctrl|Shift|Alt'
        )]
        [string]$Regex )
    Get-PSReadLineKeyHandler -Bound -Unbound | Where-Object {
        $_.Function -Match $regex -or
        $_.Description -match $regex -or
        $_.Key -match $regex
    }
}
New-Alias 'Write-Host.Original' -value 'Microsoft.Powershell.Utility\write-host' -Description 'sugar to not un-import modules to test the raw basic one' -ea 'ignore'

nin.PSModulePath.Add -LiteralPath 'H:/data/2023/pwsh/PsModules/TypeWriter/Output' -AddToFront
nin.PSModulePath.Add -LiteralPath 'H:/data/2023/pwsh/my🍴'
nin.PSModulePath.Clean -Write

@(
    Import-Module nin.Ast -pass
    Import-Module CompletionPredictor -PassThru
)
# $Env:PSModulePath = nin.PSModulePath.Clean -Write -PassThru

# H:\data\2023\pwsh\PsModules\TypeWriter\Output\TypeWriter
# write-verbose 'Temp: manual import of type writer path'

# if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }
# if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 i>
# return
