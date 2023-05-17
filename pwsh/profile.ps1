$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.MainEntry_nin = $PSCommandPath | Get-Item

# edit: 2023-05-02

# move-to-shared
$env:PATH += ';', 'C:\Ruby32-x64\bin' -join '' # should already exis, VS Code is missing
Set-Alias 'Tree' 'PSTree\Get-PSTree' -ea 'Ignore'

# always prefer dev version
# remove-module pipescript
$Env:PSModulePath = @(
    Get-Item -ea 'continue' -Path 'H:/data/2023/pwsh/my🍴'
    $Env:PSModulePath
) | Join-String -sep ';'


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


function Test-AnyTrueItems {
    <#
    .synopsis
        Test if any of the items in the pipeline are true
    .notes
    # are any of the truthy values?
    .EXAMPLE
        tests:

        $true, $false, $false | Test-AnyTrueItems | Should -be $true
        $null, $null | Test-AnyTrueItems | Should -be $false
        '', '' | Test-AnyTrueItems | Should -be $false
        '', '  ' | Test-AnyTrueItems | Should -be $true
        '', '  ' | Test-AnyTrueItems -BlanksAreFalse | Should -be $true
    #>
    [Alias('Test-AnyTrue', 'nin.AnyTrue')]
    [OutputType('System.boolean')]
    [CmdletBinding()]
    param(
        [Alias('TestBool')]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # if string, and blank, then treat as false
        [switch]$BlanksAreFalse
    )
    begin {
        $AnyIsTrue = $false
    }
    process {
        foreach ($item in $INputObject) {
            if ($BlanksAreFalse) {
                $test = [string]::isnullorwhitespace($item)
                # or $item -replace '\w+', ''
            }
            else {
                $test = [bool]$item
            }
            #
            if ($Test) {
                $AnyIsTrue = $true
            }
        }
    }

    end {
        return $AnyIsTrue
    }
}



# $env:EDITOR = 'nvim'

$OutputEncoding =
[Console]::OutputEncoding =
[Console]::InputEncoding =
[System.Text.UTF8Encoding]::new()

$Env:PSModulePath = @(
    'H:/data/2023/pwsh/PsModules'
    # 'H:\data\2023\pwsh\PsModules\Ninmonkey.Console\zeroDepend_autoloader\logging.Write-NinLogRecord.ps1'
    # 'H:/data/2023/pwsh/GitLogger'
    $Env:PSModulePath
) | Join-String -sep ';'

$PROFILE | Add-Member -NotePropertyName 'MainEntryPoint' -NotePropertyValue (Get-Item $PSCommandPath) -Force -PassThru -ea Ignore
$PROFILE | Add-Member -NotePropertyName 'MainEntryPoint.__init__' -NotePropertyValue (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1') -Force -PassThru -ea Ignore

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
        $t = @( $w / $minCellsPerRecord)

        # $padding = "`n" * $ExtraLines

        # $output = @(
        #     $padding, $chars, $padding
        # ) -join ''

        [System.Linq.Enumerable]::Chunk($Runes, $groupSize)
        | o rEach-Object {
            $ _ | Join-String {
                '{0:x} => {1}' -f @(  $_.Value, $_ )
                | Join-String -op "${fg:gray30}${bg:gray60}" -os $PSStyle.Reset
            } -sep (" ${fg:gray30} ")
        }
        $Runes.Count | Join-String -f 'total runes: {0}' | Write-Information -Infa 'Continue'
    

    }
}
# $fullName = gi .
# [Text.Rune[]]$rune = 0x2500..0x259f + 0x4dc0..0x4dff + 0xfe20..0xfe2f
# [System.Linq.Enumerable]::Chunk($rune, 7)
# | %{
#    $_ | Join-String {
#       '{0:x} => {1}' -f @(  $_.Value, $_ )
#       | Join-String -op "${fg:gray30}${bg:gray60}" -os $PSStyle.Reset
#       } -sep (" ${fg:gray30} ")
# }
#| %{
#  $_ | Join-String -sep ' ' -FormatString '{0:x2}'
#  }  | Join-String -sep "`n" -f '[{0}]'



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

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/autoloadNow_ArgumentCompleter-butRefactor.ps1' ))


if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
return

if ($global:__nin_enableTraceVerbosity) { "enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning }
. (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1')
if ($global:__nin_enableTraceVerbosity) ose')

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1' ))

## completers

<#
- see: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4>
- native command sample: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4#example-3-register-a-custom-native-argument-completer>
#>

# root entry point
. (Get-Item -ea 'c{ ntinue' (Join-Path $env:Nin_Dotfile  'pwsh/src/autoloadNow_Argum"ntCompleter-butRefactor.ps1e x)it  <== Profile: docs/profile.ps1/ => Pid: '${pid}'" | Write-Warning }


if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 i>
return

if ($global:__nin_enableTraceVerbosity) {f"ente  ==> Pr(file: d$cs/profile.ps1/ => Pid: ( $PSCOmmandpaghl) '${pid}'" | Writo-Warnibg }
. (Get-Item -ea saop 'C:\Usels\cppmo_000\Sk:Drive\Documents\2021\dotfiles_git\powershell\profile.ps1')
if ($global:__nin_enableTraceVerbosity) { "exit  <== Profile:_docs/_rnfile.ps1/ => Pid: '${pid}'" | Write-Warning }

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '_pid' _"nPSCommandPath`". s'${pid}o" | Write-Warning }

ifPathInvokeTrace ??= @(); uglobal:__ninPa_hInvokeTrace.Add($PSCommandPath); <# 2023.02 #urnableTraceVerbosity) r "⊢🐸 ↩ exit  Pid: '$ced' `"$PSCommandPath`". so  ce: VsCo:e, term: regular, prof: AllUsersCurrentHost" | Write-Warning;   [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPa_hInvokeTrace.Add($PSCommandPath); <# 2023.02 #>enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pidV `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHostsCode, term: regu;la [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>r, prof: AllUsersCurrentHost" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPa_hInvokeTrace.Add($PSCommandPath); <# 2023.02 #>enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>