#Requires -Module Ninmonkey.Console
#Requires -Module Dev.Nin

# Import-Module dev.nin -Force
# Write-Warning 'WARNING: ㏒ [Ninmonkey.Profile.psm1] -> Before Importing "dev.nin"'

# Import-Module dev.nin -Force -wa continue -ea stop #continue
# Write-Warning 'WARNING: ㏒ [Ninmonkey.Profile.psm1] <- finished importing "dev.nin"'
# Write-Warning 'WARNING: finished import [dev.nin.psm1]'

$script:_state = @{}
# Set-Alias -Name 'code' -Value 'code-insiders' -Scope Global -Force -ea ignore -Description 'Overwrite like PSKoans opening the wrong app'

# __countDuplicateLoad -key '$Nin.Profile.psm1'

# wip dev,nin: todo:2022-03
# Import-Module Dev.Nin -Force #-ea stop # bad perf
# Import-Module Dev.Nin #-ea stop
[PoshCode.Pansies.RgbColor]::ColorMode = [PoshCode.Pansies.ColorMode]::Rgb24Bit

function _silentReload {
    <#
    .synopsis
        Silent force reload, unless errors
    #>
    param(
        [Parameter()]
        [string[]]$ModuleName = @('ninmonkey.console', 'dev.nin')
    )
    $ModuleName | ForEach-Object {
        Import-Module $_ -Scope Global -Force -DisableNameChecking -wa Ignore *>&1 | Out-Null
    }
    | Out-Null

    if (Test-HasNewError) {
        'Something went wrong' | write-color 'orange'

    }
}
function _nyi {
    <#
    .synopsis
        minimal function to throw nyi where needed
    #>
    param()
    Write-Error -Category NotImplemented -ea Continue -Message (@(
            'func: NYI'
            $args -join ', '
        ) | ForEach-Object tostring)
}

# @(
#     'Profile: 🏠 --> Start'
#     hr 1
# )
# | Write-Warning
function __globalStat {
    <#
    .description
        # todo:
        the idea is that I can easily tap into this global stat tracker, without manually writing code to log

        this isn't config, its more like
        - [ ] save which colors are used by write-color, the most
        - [ ] which filepaths have __doc__ strings attached to them
        - [ ] who generates the most aliases
        - [ ] metrics on cache command
    #>
    Write-Warning 'NYI'

}


# adds full filepath this file's directory
# & {
$s_optionalItem = @{
    'ErrorAction' = 'silentlycontinue'
    # 'ErrorAction' = 'ignore'
}
<#
    Handling $NinProfile_Dotfiles as a script variable that's exported has the benifit that
        - it acts like a 'global' for the user
        - dies if you call 'remove-module' in the current session
    #>
$script:NinProfile_Dotfiles = @{
    # todo: should be a commandlet response ?
    Bat                    = Get-Item @s_optionalItem "$env:Nin_Dotfiles\cli\bat\.batrc"
    RipGrep                = Get-Item @s_optionalItem "$env:Nin_Dotfiles\cli\ripgrep\.ripgreprc"
    BashProfile            = Get-Item @s_optionalItem "$env:Nin_Dotfiles\wsl\home\.bash_profile"
    WindowsTerminalPreview = "${env:LocalAppData}\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    WindowsTerminal        = "${env:LocalAppData}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    vscode                 = @{
        ExtensionDir = Get-Item "${env:UserProfile}\.vscode\extensions"
        User         = Get-Item "${env:appdata}\Code\User\settings.json"
    }
    Git                    = @{
        GlobalIgnore = Get-Item @s_optionalItem "$env:Nin_Dotfiles\git\global_ignore.gitignore"
        Config       = @(
            Get-Item @s_optionalItem '~\.gitconfig' # symlink or to dotfile?
            Get-Item @s_optionalItem "${env:Nin_Dotfiles}\git\homedir\.gitconfig"
        ) | Sort-Object -Unique FullName

        PowerBI      = @{
            # See my PowerBI module for tons of PBI paths
            'ExternalToolsConfig' = Get-Item 'C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools'
        }


    }
}
$ignoreSplat = @{
    Ea = 'Ignore'
}

if ($true) {
    # $profile | Entry point for mutating $Profile
    $PROFILE | Add-Member -ea ignore -NotePropertyName 'Ninmonkey.Profile/*' -NotePropertyValue (Get-Item $PSScriptRoot)
    $PROFILE | Add-Member -ea ignore -NotePropertyName 'Ninmonkey.Profile.psm1' -NotePropertyValue (Get-Item $PSCommandPath)
    $PROFILE | Add-Member -ea ignore -NotePropertyName 'Nin_Dotfiles' -NotePropertyValue ((Get-Item $env:Nin_Dotfiles -ea ignore) ?? $null )
    $PROFILE | Add-Member -ea ignore -NotePropertyName 'Nin_PSModules' -NotePropertyValue ((Get-Item $Env:Nin_PSModulePath -ea ignore) ?? $null )
} else {
    $dictMembers = @{
        'Ninmonkey.Profile.psm1' = Get-Item @ignoreSplat $PSSCriptRoot
        # | __doc__ 'location of Profile'
        'NinDotfiles'            = Get-Item @ignoreSplat $Env:Nin_Dotfiles
        # | __doc__ 'root of all dotfiles for the current year'
        'NinPSModules'           = Get-Item @ignoreSplat $Env:Nin_PSModulePath
        # | __doc__ 'personal module paths'
    }
    $PROFILE | Add-Member -ea ignore -NotePropertyMembers $dictMembers -PassThru -Force
}



# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
$Env:RIPGREP_CONFIG_PATH = $script:NinProfile_Dotfiles.RipGrep.FullName

# }
Export-ModuleMember -Variable 'NinProfile_Dotfiles'

# & {
$splatIgnorePass = @{
    ErrorAction = 'Ignore'
    'PassThru'  = $true
    # scope = script? global because it's export module?
}
$splatIgnoreGlobal = $splatIgnorePass += @{
    Scope = 'Global'
}

function Sort-NewestChildItem {
    # Sort files by LastWriteTime [ -Descending ]
    [alias('sortWriteTime')]
    param([switch]$Descending)
    $sortObjectSplat = @{
        Property = 'LastWriteTime'
    }
    if ($Descending) {
        $sortObjectSplat['Descending'] = $true
    }

    $input | Sort-Object @sortObjectSplat #-Descending $Descending
}

Remove-Alias -Name 'cd' -ea ignore
Remove-Alias -Name 'cd' -Scope global -Force -ea Ignore
[object[]]$newAliasList = @(
    'sortWriteTime'

    # New-Alias @splatIgnorePass   -Name 'SetNinCfg' -Value 'nyi'                 -Description '<todo> Ninmonkey.Console\Set-NinConfiguration'
    # New-Alias @splatIgnorePass   -Name 'GetNinCfg' -Value 'nyi'                 -Description '<todo> Ninmonkey.Console\Get-NinConfiguration'
    New-Alias @splatIgnoreGlobal -Name 'Cd' -Value 'Set-NinLocation' -Description 'A modern "cd"'
    Set-Alias @splatIgnorePass -Name 'Cl' -Value 'Set-Clipboard' -Description 'aggressive: set clip'
    Set-Alias @splatIgnorePass -Name 'gcl' -Value 'Get-Clipboard' -Description 'aggressive: get clip'
    New-Alias @splatIgnorePass -Name 'CodeI' -Value 'code-insiders' -Description 'quicker cli toggling whether to use insiders or not'
    New-Alias @splatIgnorePass -Name 'CodeI' -Value 'code-insiders' -Description 'VS Code insiders version'
    New-Alias @splatIgnorePass -Name 'CtrlChar' -Value 'Format-ControlChar' -Description 'Converts ANSI escapes to safe-to-print text'
    New-Alias @splatIgnorePass -Name 'F' -Value 'PSScriptTools\Select-First' -Description 'quicker cli toggling whether to use insiders or not'
    New-Alias @splatIgnorePass -Name 'jPath' -Value 'Microsoft.PowerShell.Management\Join-Path' -Description 'Alias to the built-in'
    # New-Alias @splatIgnorePass      -Name 'jP'          -Value 'Microsoft.PowerShell.Management\Join-Path'  -Description 'Alias to the built-in'
    New-Alias @splatIgnorePass -Name 'sc' -Value 'Microsoft.PowerShell.Management\Set-Content' -Description 'Alias to the built-in'
    Set-Alias @splatIgnorePass -Name 'jStr' -Value 'Microsoft.PowerShell.Utility\Join-String' -Description 'Alias to the built-in'
    New-Alias @splatIgnorePass -Name 'Len' -Value 'Ninmonkey.Console\Measure-ObjectCount' -Description 'A quick count of objects in the pipeline'
    Set-Alias @splatIgnorePass -Name 'fzf' -Value 'Ninmonkey.Console\Out-Fzf' -Description 'nin'

    Set-Alias @splatIgnorePass -Name 'S' -Value 'Select-Object' -Description 'aggressive: to override other modules'
    New-Alias @splatIgnorePass -Name 'Wi' -Value 'Write-Information' -Description 'Write Information'
    Set-Alias @splatIgnorePass -Name 'Gpi' -Value 'ClassExplorer\Get-Parameter' -Description 'Write Information'
    New-Alias @splatIgnorePass -Name 'dict' -Value 'New-HashtableFromObject' -desc 'my pipe constructor'


    ##
    New-Alias @splatIgnorePass 'Err' -Value Dev.Nin\Test-HasNewError -Description 'makes -clear and -reset 1🤚ed'

    ## Category 'Out->'
    ## Category 'Pipe->'

    ## Category 'Dive->'
    New-Alias @splatIgnorePass -Name '%.' -Value Dev.Nin\Dive.Prop -Description 'Alias for using diving similar to chaining ForEach objects'

    ## Category 'From->'
    # New-Alias @splatIgnorePass -Name 'From->Base64' -Value _nyi  #('Ninmonkey.Console\ConvertFrom-Base64String')
    New-Alias @splatIgnorePass -Name 'From->Csv' -Value ConvertFrom-Csv
    New-Alias @splatIgnorePass -Name 'From->Decode' -Value _nyi # To/From: Unicode bytes <-> String
    New-Alias @splatIgnorePass -Name 'From->Json' -Value ConvertFrom-Json
    New-Alias @splatIgnorePass -Name 'From->LiteralPath' -Value Dev.Nin\ConvertFrom-LiteralPath
    New-Alias @splatIgnorePass -Name 'From->RelativeTs' -Value Ninmonkey.Console\ConvertTo-Timespan

    ## Category 'To->'
    New-Alias @splatIgnorePass -Name 'To->Base64' -Value Ninmonkey.Console\ConvertTo-Base64String
    New-Alias @splatIgnorePass -Name 'To->BitString' -Value Utility\ConvertTo-BitString
    New-Alias @splatIgnorePass -Name 'To->CommandName' -Value Ninmonkey.Console\Resolve-CommandName
    New-Alias @splatIgnorePass -Name 'To->Csv' -Value ConvertTo-Csv
    New-Alias @splatIgnorePass -Name 'To->Encode' -Value _nyi # To/From: Unicode bytes <-> String
    New-Alias @splatIgnorePass -Name 'To->HexString' -Value Ninmonkey.Console\ConvertTo-HexString
    New-Alias @splatIgnorePass -Name 'To->Json' -Value ConvertTo-Json
    New-Alias @splatIgnorePass -Name 'To->RelativePath' -Value Ninmonkey.Console\ConvertTo-RelativePath

    New-Alias @splatIgnorePass -Name 'impo' -Value Import-Module


    <#
    maybe:
        Dev.Nin\ConvertFrom-GistList
        Dev.Nin\ConvertFrom-LiteralPath
        Dev.Nin\ConvertTo-MarkdownTable
        Dev.Nin\ConvertTo-PwshLiteral
        Dev.Nin\Maybe-GetDatetime
        Ninmonkey.Console\Convert-Object
        Ninmonkey.Console\ConvertTo-Base64String
        Ninmonkey.Console\ConvertTo-HexString
        Ninmonkey.Console\ConvertTo-Number
        Ninmonkey.Console\ConvertTo-PropertyList
        Ninmonkey.Console\ConvertTo-RegexLiteral
        Ninmonkey.Console\ConvertTo-Timespan

    #>
    # New-Alias 'jp' -Value 'Join-Path' -Description '[Disabled because of jp.exe]. quicker for the cli'

    # guard did not catch this correctly anyway, maybe -ea disables loading? i don not want to use an -all
    #   on a profile load, for performance.
    #   the 'nicest' way could be to delay binding using a profile 'async'? or just allow it to bind without existing.
    # if (Get-Command 'PSScriptTools\Select-First' -ea ignore) {
    #     New-Alias -Name 'f ' -Value 'PSScriptTools\Select-First' -ea ignore -Description 'shorthand for Select-Object -First <x>'
    # }
)
# To external functions
$newAliasList += @(
    New-Alias @splatIgnorePass -Name 'pinfo' -Value 'PSScriptTools\Get-ParameterInfo' -Description 'anoter parameter info inspection ' -ea ignore
)

# try {
#     Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
# }
# catch {
#     Write-Verbose 'Module not Found'
# }
## FZF optional


$newAliasList | ForEach-Object { $_.DisplayName }
| str csv -Sort | Write-Color gray60
| str prefix ('Profile Aliases: ')# #orange)
# | Write-Debug # long form

# short names only
$newAliasList | ForEach-Object { $_.Name }
| str csv -Sort | Write-Color gray60
| str prefix ('Profile Aliases: ')# #orange)
| Join-String
| Write-Warning
# Wait-Debugger
# Export-ModuleMember -Variable $newAliasList

# Func: Summarize  Aliases:

$newAliasList
| Sort-Object Name, ResolvedCommand
| Join-String {
    '{0} [{1}] {2}' -f @(
        $_.Name | Write-Color 'green'
        $_.ResolvedCommand | Write-Color 'darkgreen'
        'desc' | Write-Color gray50
    )
} -sep "`n" | SplitStr Newline | str HR
| Join-String
| Write-Warning
# Wait-Debugger
# $newAliasList | Sort-Object Name | Join-String -sep ', ' -SingleQuote -op 'New Alias: '
# | New-Text -fg 'pink' | Join-String -op 'Ninmonkey.Profile: '
# | Write-Debug



function _reRollPrompt {
    # Re-randomizes the breadcrumb key names
    Reset-RandomPerSession -Name 'prompt.crumb.colorBreadEnd', 'prompt.crumb.colorBreadStart'
}

function toggleErrors {
    # todo: cleanup: move to a better location
    $__ninConfig.Prompt.NumberOfPromptErrors = if ($__ninConfig.Prompt.NumberOfPromptErrors -eq 0) {
        3
    } else {
        0
    }
}

if ($GitPromptSettings) {
    # Disable Posh-Git from including filepath, I already handle that.
    $GitPromptSettings.DefaultPromptWriteStatusFirst = $true
    $GitPromptSettings.DefaultPromptSuffix.Text = ''
    $GitPromptSettings.DefaultPromptPath.Text = ''
}
# see also:
# $GitPromptSettings.WindowTitle

function _Write-PromptGitStatus {
    <#
    .synopsis
        Wraps Posh-Git\Prompt
    .notes
        see also the values of
            $GitStatus

            plus 6+ variables named '$Git_<something>'

        docs:
            https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt#v1x---customizing-the-posh-git-prompt

    .outputs
        either $null, or a string based on git status
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    [cmdletbinding(PositionalBinding = $false)]
    param()

    try {
        if (! $GitPromptScriptBlock) {
            # write warning ?
            Write-Verbose 'Posh-Git scriptblock is missing'
            return
        }

        & $GitPromptScriptBlock
    } catch {
        Write-Error -ErrorRecord $_ Message 'failed invoking $GitPromptScriptBlock' -TargetObject $GitPromptScriptBlock
    }

    # $dir_git = Get-GitDirectory
    # [bool]$isGetRepo = $null -ne $dir_git

    # if (! $isGetRepo) {
    #     return
    # }

    # New-Text 'git' -ForegroundColor (Get-GitBranchStatusColor).ForegroundColor
}

function _Write-PromptIsAdminStatus {
    <#
    .synopsis
        basic bright red, make it hard to forget you're admin
    .description
        1. big red

        wt already sets tab titlen
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    param()
    "`n"
    if (!(Test-UserIsAdmin)) {
        return
    }
    New-Text -bg red -fg white 'Admin      '
    "`n"
}
function _Write-PromptPathToBreadCrumbs {
    <#
    .synopsis
        write current directory as crumbs
    .notes
        future:

        -[ ] add $Config = @Options  - param
        -[ ] abbrevate mode

            in:
                C:\\Users\\cppmo_000\\Documents\\2021\\Powershell\\My_Gist\\FinalDirectory
            out:
                # A
                $EnvUserProfile⋯Docs⋯2021⋯Powe⋯My_Gist⋯FinalDirectory

                # B
                U⋯c⋯D⋯2⋯P⋯My_Gi⋯FinalDirectory


    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # FormatMode
        [ValidateSet('Default', 'LimitSegmentCount')]
        [Parameter(Position = 0)]
        [string]$FormatMode = 'LimitSegmentCount'
    )

    # try {
    $FinalOutputString = switch ($FormatMode) {
        # 'a' {
        #     'Ps> '
        #     break
        # }
        'Reverse' {
            'Todo> '
            # todo: like 'default' but reverse, so brightest path is left
            return
        }
        'LimitSegmentCount' {
            # size is currently disabled being used
            $maxSize = ($__ninConfig.Prompt.BreadCrumb)?.MaxCrumbCount ?? 3 # __doc__: default is 3. Negative means no limit
            $crumbJoinText = ($__ninConfig.Prompt.BreadCrumb)?.CrumbJoinText ?? ' ' # __doc__: default is ' ' . Join String.
            $crumbJoinReverse = ($__ninConfig.Prompt.BreadCrumb)?.CrumbJoinReverse ?? $true # __doc__: default is $false ' right to left
            # todo: config: after config wrapper, also setup these:
            # 'gray40'

            $gradientStart = ($__ninConfig.Prompt.BreadCrumb)?.ColorStart
            $gradientStart ??= Get-RandomPerSession -Name 'prompt.crumb.colorBreadStart' { Get-ChildItem fg: }
            $gradientEnd = ($__ninConfig.Prompt.BreadCrumb)?.ColorEnd
            $gradientEnd ??= Get-RandomPerSession -Name 'prompt.crumb.colorBreadEnd' { Get-ChildItem fg: }

            $crumbs = (Get-Location | ForEach-Object Path) -split '\\'
            $numCrumbs = $crumbs.count
            $getGradientSplat = @{
                StartColor = $gradientStart
                EndColor   = $gradientEnd
                Width      = [math]::Clamp( $numCrumbs, 3, [int]::MaxValue )
            }
            # if ($true) {
            #     $colorsFg = Get-ChildItem fg:
            #     $getGradientSplat.StartColor = $colorsFg | Get-Random -Count 1
            #     $getGradientSplat.EndColor = $colorsFg | Get-Random -Count 1
            # }

            $gradient = Get-Gradient @getGradientSplat
            $finalSegments = $crumbs | ForEach-Object -Begin { $i = 0 } {
                $curLine = $_
                if ($i -ge $numCrumbs) {
                    Write-Error "OutofBoundException:`$i '$i' >= `$numCrumbs!"
                }
                New-Text -Object $curLine -ForegroundColor $gradient[$i]
                $i++
            }
            if ($crumbJoinReverse) {
                # $finalSegments.reverse() | Out-null
                $FinalSegments | Out-ReversePipeline
                | Join-String -sep $crumbJoinText
            } else {
                $finalSegments
                | Join-String -sep $crumbJoinText
            }

            # no removal for now, just show all segments
            return
        }

        default {
            "`ndefault> "
        }

    }

    $FinalOutputString | Join-String -sep ''
    # } catch {
    #     $PSCmdlet.WriteError( $_ )
    # }
}
$script:__temp ??= @{} #??= @{}
$script:__temp.IncludeDebugPrompt ??= $true

# retire:
# if (!  $script:__ninConfig.Prompt.SegmentChildCountFormat ) {
#     'Bad bad bad ' | Write-Warning
# }
if ($script:__ninConfig.Prompt) {
    $script:__ninConfig.Prompt.SegmentChildCountFormat ??= 'Icons' # ??= should have worked, unless config doesn't exist
    $script:__ninConfig.Prompt.SegmentExtensionType ??= $true
}
function _Write-SegmentExtensionType {
    <#
    .synopsis
        Summarizes extension types in path
    .notes
        future:
            - [ ] color heatmap based on distribution
            - [ ] color heatmap based on fuzzy last modified
            - [ ] sort order based on lastmodified
            - [ ] sort order based on distribution count
        #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'Personal Profiles may break rules')]
    [cmdletbinding()]
    param(
        # [Parameter(Position = 0)]
        # [ValidateSet('Icons', 'Simple')]
        # [string]$FormatMode

    )
    process {
        $splat_FileType = @{
            MaxDepth = 0
        }

        Completion->FileExtensionType @splat_FileType | Sort-Object -Unique
        | ForEach-Object { $_ -replace '^\.', '' }
        | str str ' ' | Write-Color -fg gray35
    }
    # 🗄, 📃, 📄
    # $Rune = @{
    #     Directory = '📁'
    #     File      = '📄'
    # }
    # $numFiles = Get-ChildItem . -File | len
    # $numDirs = Get-ChildItem . -Directory | len
    # switch ($FormatMode) {
    #     'Icons' {
    #     }
    #     default {
    #     }
    # }
}
function _Write-SegmentChildCount {
    <#
    .synopsis
        write current directory as crumbs
    .notes
        future:
        #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'Personal Profiles may break rules')]
    [cmdletbinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('Icons', 'Simple')]
        [string]$FormatMode

    )
    # 🗄, 📃, 📄
    $Rune = @{
        Directory = '📁'
        File      = '📄'
    }
    $numFiles = Get-ChildItem . -File | Len
    $numDirs = Get-ChildItem . -Directory | Len
    switch ($FormatMode) {
        'Icons' {

            @(
                ' '
                $rune.Directory
                ' '
                "${numFiles}"
                ' '
                $RUne.File
                ' '
                "${numDirs}"
            ) -join '' | Write-Color -fg 'gray50'
        }
        Default {
            @(
                ' d: '
                "${numFiles}"
                ' f: '
                "${numDirs}"
            ) -join '' | Write-Color -fg 'gray50'

        }
    }
}
function _Write-PromptDynamicCrumbs {
    <#
    .synopsis
        write current directory as crumbs
    .notes
        future:
        #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'Personal Profiles may break rules')]
    [cmdletbinding()]
    param(

    )
    begin {
        # paths to try
        $TestPaths = @(
            'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell'
            '~'
            'C:\Users\cppmo_000\SkyDrive\Documents'
            'G:\2021-github-downloads\'
            "$Env:AppData"
            "${env:LocalAppData}"
            'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Splat.nin'
        )
        $PathMapping = @(
            @{
                Label = 'Pwsh'
                Root  = 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell'
            }
            @{
                Label = 'Docs'
                Root  = 'C:\Users\cppmo_000\SkyDrive\Documents'
            }
            @{
                Label      = 'gitDownloads' # todo: darken color
                LabelColor = @(
                    'git' | Write-Color gray80
                    "${fg:clear}"
                    'Downloads'
                ) -join ''
                Root       = 'G:\2021-github-downloads\'
            }
        ) | Sort-Object { $_.Value.Length }


    }

    process {
        $Selected = $PathMapping | Where-Object {
            $curMapping = $_
            # $curFull = [regex]::escape( (gi . | % FullName))
            $curFull = Get-Item . | ForEach-Object FUllName
            Write-Warning 'left off here'

            # $compareFull = [regex]::escape( $curMapping.Root )

            # if ($curFull -match $compareFull) {
            #     $true; return;
            # }
            # return;

        } | Sort-Object { $_.Value.Length } -Descending | Select-Object -First 1


        Get-Item . | To->RelativePath -BasePath ~\SkyDrive -ea ignore
        | Label 'full-rel'
        Get-Item . | To->RelativePath -BasePath ~\SkyDrive -ea ignore
        # | ShortenString -50 -FromEnd
        | Label 'short'
    }
}

function _Write-ErrorSummaryPrompt {
    <#
    .synopsis
        can't access global scope?
        todo: need to refactor, it's a mess now.
        summarize errors briefly, for screenshots / interactive animation
    .notes
        first: - [ ] make format error thingy print more lines
        future: - [ ] make error reset if previous prompt was >x time. don't even
        need to require the error's times.
    .example
        PS> _Write-ErrorSummaryPrompt
    .example
        PS> _Write-ErrorSummaryPrompt -AlwaysShow -Options @{'FormatMode' = 'medcolor'}

    .example
        PS> # how to pass Customized colors
        _Write-ErrorSummaryPrompt -Options @{Colors = @{ 'ErrorPale'='cyan' }; }
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    param(
        # print, even when newcount is false
        [Parameter()]
        [switch]$AlwaysShow,


        # extra options
        [Parameter()][hashtable]$Options
    )

    begin {
        [hashtable]$colors = @{
            ErrorDim    = [PoshCode.Pansies.RgbColor]'#8B0000' # darkred'
            ErrorBright = [PoshCode.Pansies.RgbColor]'#FF82AB'
            ErrorPale   = [PoshCode.Pansies.RgbColor]'#CD5C5C'
            Error       = [PoshCode.Pansies.RgbColor]'#CD3700'
            FgVeryDim   = [PoshCode.Pansies.RgbColor]'gray40'
            FgDim3      = [PoshCode.Pansies.RgbColor]'gray20'
            FgDim2      = [PoshCode.Pansies.RgbColor]'gray40'
            FgDim       = [PoshCode.Pansies.RgbColor]'gray60'
            Fg          = [PoshCode.Pansies.RgbColor]'gray80'
            FgBright    = [PoshCode.Pansies.RgbColor]'gray90'
            FgBright2   = [PoshCode.Pansies.RgbColor]'gray100'
            DimGlow     = @{bg = 'gray15'; fg = 'gray30' }
        }
        #"'⇩▼▽🠯'"

        $Colors = Join-Hashtable $Colors ($Options.Colors ?? @{})
        [hashtable]$Config = @{
            'ErrResetOnFirstPrompt' = $false # future:mode make a time-delayed one in the future
            'PrintRecentError'      = $true
            'AlwaysShowPrompt'      = $AlwaysShow.IsPresent -and $alwaysShow
            'FormatMode'            = 'CleanColor'
            # 'AlwaysShow'            = ${Options}?.AlwaysShow ?? $AlwaysShow
        }

        @(
            Hr
            $Config | Format-Dict
            Hr

            $Config = Join-Hashtable $Config ($Options ?? @{})
            $Config | format-dict
            Hr
        ) | Write-Information
        $c = $colors
    }
    end {
        # or quit early skipping render?
        if (! (Dev.Nin\Test-HasNewError)) {
            if (! $AlwaysShowPrompt ) {
                return
            }
        }
        # $FormatMode = 'SimpleColor'
        # $FormatMode = 'MedColor'
        # $FormatMode = 'CleanColor'
        $errStat = Dev.Nin\Test-HasNewError -PassThru

        if ($Config.PrintRecentError) {
            Dev.Nin\showErr -Recent
            # br 3

        }
        # $Config.FormatMode = 'SimpleColor', 'MedColor'

        switch ($Config.FormatMode) {
            'SimpleColor' {
                @(
                    $cStatus = if ($errStat.DeltaCount -ne 0) {
                        [rgbcolor]'red'
                    } else {
                        [rgbcolor]'green'
                    }
                    'e [' | Write-Color $c.Fg
                    'errΔ [' | Write-Color $c.Fg
                    '{0}' -f @(
                        $errStat.DeltaCount | Write-Color $cStatus
                    )
                    ']' | Write-Color $c.Fg
                    ' of ['
                    '{0}' -f @(
                        $errStat.CurCount | Write-Color $cStatus
                    )
                    ']'

                ) | Join-String

                break
            }
            'MedColor' {
                # 'e[0] of [y]'
                @(
                    'e[{0}]' -f @(
                        ($errStat.CurCount | Write-Color $c.ErrorPale)
                    )
                    'e '
                    '[{0}]' -f @(
                        ($errStat.DeltaCount | Write-Color $c.FgDim)
                    )
                    ' new'
                ) | Join-String

                # $errStat.
                break
            }
            'CleanColor' {
                # 'e[0] of [y]'
                @(
                    '{0}' -f @(
                        ($errStat.DeltaCount | Write-Color $c.ErrorPale)
                    )
                    ' of ' | Write-Color $c.FgDim
                    '{0}' -f @(
                        ($errStat.CurCount | Write-Color $c.FgDim2)
                    )
                ) | Join-String -sep ''

                # $errStat.
                break

            }
            default {
                if ($errStat.DeltaCount -eq 0) {

                } else {
                    '{0} new' -f @( $errStat.DeltaCount)
                }
                break
            }
        }

        if ($Config.ErrResetOnFirstPrompt) {
            Dev.Nin\Test-HasNewError -Reset
        }

        return
        # if ($false) {
        #     $template = @(
        #         'Viewing: '
        #         '[{0}]' -f @(
        #             if ($Count) {
        #                 [math]::Min( $Count, $global:error.Count )
        #             } else {
        #                 'All'
        #             }

        #         )
        #         | Write-Color green

        #         ' of '
        #         '[{0}] ' -f @(
        #             $global:Error.count ?? 0
        #         )
        #         | Write-Color darkgreen
        #         ' errors'
        #     ) -join ''

        # }





        # Dev.Nin\Test-DidErrorOccur -Limit 3

        # $script:__temp.LastErrorCount ??= $error.count
        # $newErrorCount = $error.count - $script:__temp.LastErrorCount
        # $script:__temp.LastErrorCount = $error.count


        # @(
        #     "New Error Count: $NewErrorCount."
        # ) | Join-String -sep "`n"

        # $template
        # $lastCount = $error.count
        #1 / 0
        # ($error.count) - $lastCount


        # $error[0].Message
        # $error[1].Exception.Message
    }
}
function _Write-PromptDetectParent_iter0 {
    <#
    .synopsis
        verbose prompt to test term detection
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    param()
    $chunk = @()
    $template = "TermName: {0}`nIsVsCode: {1}`nIsPSIT: {2}"
    $chunk += $template -f @(
        $__ninConfig.Terminal.CurrentTerminal
        ($__ninConfig.Terminal.IsVSCode) ? 'Y' : 'N'
        ($__ninConfig.Terminal.IsVSCodeAddon_Terminal) ? 'Y' : 'N'
    ) | Join-String
    $chunk | Join-String -os "`n"
}
function _Write-PromptForBugReport {
    <#
    .synopsis
        verbose prompt to test term detection
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    param()
    [object[]]$chunk = @()

    $venv_info = Code-vEnv -PassThru -infa Ignore
    $codeBin = Get-Command $venv_info.CodeBinPath -ea Continue
    [bool]$isPwshDebugTerm = $__ninConfig.Terminal.IsVSCodeAddon_Terminal

    $chunk += @(
        # if ($__ninConfig.Terminal.IsVSCode) {
        #     'VsCode'
        # }

        # & $codeBin @('--version') | Join-String -sep ', ' -op "$codeBin.Name"
    )
    $chunk += _Write-ErrorSummaryPrompt -AlwaysShow
    $chunk += @(
        "`n"
        'is PSIT? ' #| Write-Color 'gray60'
        if ($isPwshDebugTerm) {
            'yes' | Write-Color green
        } else {
            'no ' | Write-Color darkred
        }
        ' '


        $query_addonVersion = & $codeBin @('--list-extensions', '--show-versions')
        | Where-Object { $_ -match 'ms-vscode.powershell-preview' }
        | ForEach-Object {
            $_ -split '@'
            | str csv -sep ' '
        }
        $query_addonVersion
    ) | Join-String

    if ($__ninConfig.Terminal.IsVSCode) {
        $chunk += @(
            "`n"
            & $codeBin @('--version')
            | Join-String -sep ', ' -op "${fg:purple}$($codeBin.Name): ${fg:cyan}"
        )
    }
    $chunk += @(
        "`n"
        'Pwsh {0}' -f @($PSVersionTable.PSVersion.ToString())
        '> '
    )

    $chunk | Join-String -os "`n"


}

function _Write-Predent {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Personal Profiles may break rules')]
    param(
        # Number of newlines
        [Parameter(Position = 0)]
        [int]$NewlineCount = 2,
        # Include extra Horizontal line
        [Parameter()][switch]$IncludeHorizontalLine
    )
    @(
        # write-indent
        "`n" * $NewlineCount -join ''
        if ($IncludeHorizontalLine) {
            New-Text -fg 'gray30' '___________' # extra pre-dent
        }
    ) | Join-String
}

function Write-NinProfilePrompt {
    <#
    .synopsis
        A dynamic prompt, that function:\prompt can always point to
    .description
        Not profiled for performance at all

        Does this excessively use the pipeline, and Join-Ytring when it's not necessary?
            Yes. To allow future experiments to be easier
            Performance cost here doesn't matter.$
    .example
        PS>
    .notes
        .
    #>
    [cmdletbinding(PositionalBinding = $false)]
    param (
    )

    if ($null -eq (Get-Module dev.nin -ea ignore)) {
        @(
            "`nMissingModule: Dev.Nin`n"
            Get-Location
            "`nsafe>"
        ) -join ''

        #required fallback if required dev.nin module didn't load
    }
    if ( ( $__ninConfig.Prompt) -and
        ($__ninConfig.Prompt.ForceSafeMode) ) {

        @(
            Get-Location
            "`nsafe>"
        ) -join ''
        return
    }

    if ($null -eq $__ninConfig.Prompt.ForceSafeMode) {

        '🚧> $null -eq SafeMode'
        | Write-Host
    }

    $__ninConfig.Prompt.NumberOfPromptErrors ??= 2
    $configErrorLinesLimit = $__ninConfig.Prompt.NumberOfPromptErrors ?? 2
    # $__ninConfig.Prompt.Profile = 'spartan'
    # try {
    # was
    # $script:__ninConfig.Prompt.NumberOfPromptErrors ??= 2
    # $configErrorLinesLimit = $script:__ninConfig.Prompt.NumberOfPromptErrors ?? 2
    # $script:__ninConfig.Prompt.Profile = 'spartan'

    # do not use extra newlines on missing segments

    switch ($__ninConfig.Prompt.Profile) {
        'dim' {
            # __doc__: dim, simple prompt. shows full path
            @(
                _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2

                "${fg:gray40}"
                Get-Location

                "`n $($Error.Count) "

                'PS> '
                "$($PSStyle.Reset)"


            ) | Join-String

        }
        'currentSpartan' {
            @( # [1] save 2022-04-30 - spartan prompt
                "`n"
                @("${fg:30}" ; Get-Location; ) -join ''

                $ec = $error.count
                $ec -gt 0 ? $ec : ''


                "${fg:30}PS> "

            ) -join "${fg:clear}`n"
        }
        'errorSummary' {
            @(
                "`n"
                # err?
                # hr
                _Write-ErrorSummaryPrompt
                "`n🐒> "
            ) | Join-String
            break
        }
        'debugPrompt' {
            # __doc__: Clearly shows whether you're in the PSIT or not, older version of 'bugReport', or same but with less info
            @(
                _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
                _Write-PromptDetectParent_iter0
                # "`n"
                '🐛> '
            ) | Join-String
            break
        }
        'bugReport' {
            # __doc__: Clearly shows whether you're in the PSIT or not
            @(
                _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
                _Write-PromptForBugReport
                # "`n"
                '🐛> '
            ) | Join-String
            break
        }

        'oneLine' {
            # __doc__: Minimum possible prompt, just a "nin> "
            @(
                '🐒> '
            ) | Join-String
            break
        }
        'twoLine' {
            # __doc__: Like 'oneLine' with an extra line of padding
            @(
                "`n"
                '🐒> '
            ) | Join-String
            break
        }
        'spartan' {
            # __doc__: simple prompt, but more logic than 'oneline|twoLine'
            @(
                _Write-Predent -IncludeHorizontalLine:$false -NewlineCount 2
                _Write-ErrorSummaryPrompt -AlwaysShow:$false
                "`n🐒> "
            ) | Join-String
            break
        }

        'previousDefault' {
            $segments = @(
                $splatPredent = @{
                    NewlineCount          = ($__ninConfig.Prompt)?.PredentLineCount ?? 2
                    IncludeHorizontalLine = ($__ninConfig.Prompt)?.IncludePredentHorizontalLine ?? $false
                }
                <#
                    $EnablePromptDetectError = $false
                    if ($EnablePromptDetectError) {
                        function _Write-PromptDetectError {
                            if ($global:Error.count -gt 0 -and $configErrorLinesLimit -gt 0) {
                                Dev.Nin\Test-DidErrorOccur -Limit $configErrorLinesLimit
                                "`n"
                            }
                        }
                        _Write-PromptDetectError
                    }
                    #>

                _Write-Predent @splatPredent
                # _Write-Predent -NewlineCount 2 -IncludeHorizontalLine:$false
                _Write-PromptIsAdminStatus
                if ($__ninConfig.Prompt.IncludeGitStatus) {
                    _Write-PromptGitStatus # todo: better git status line
                    "`n"
                }
                _Write-ErrorSummaryPrompt -AlwaysShow:$false
                # if ($false -and $__ninConfig.Prompt.IncludeDynamicCrumbs) {
                #     "`n"
                #     _Write-PromptDynamicCrumbs #-FormatMode 'Segmentsdfdsf'
                # }
                "`n"
                _Write-PromptPathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'

                $splatdimGlow = @{bg = 'gray15'; fg = 'gray30' }
                # "default:nin⚙" | write-color @splatdimGlow | join-str -op "`n"
                'default:nin⚙' | Write-Color @splatdimGlow | Join-String -op "`n"

                "`n🐒> "
            )
            $segments | Join-String
        }

        default {
            # 'new default'
            # todo:
            #   - [ ] fade out filepath if you haven't moved recently
            #   - [ ] mode to only show filepath delta, not the full page
            #       until asked using 'pwd'

            # __doc__: 'main' prompt with breadcrumbs
            # logic
            # this almost works, but, it fails if the prompt is too fast
            # maybe I can get last error time, by saving only if -recent count changed since last
            $dbg ??= [ordered]@{}

            # $whenLastError = Get-History | Where-Object ExecutionStatus -Match 'failed' # does not toggle with errors
            # | ForEach-Object EndExecutionTime | Sort-Object -Descending | Select-Object -First 1

            #longest among both options

            if ($true) {
                # messing with automatic calls to 'Err -Reset'
                $whenLastCommand = Get-History -Count 1 | s * | ForEach-Object EndExecutionTime
                $whenLastError, $whenLastCommand | Where-Object { $null -ne $_ } # was breaking import ?NotBlank | Write-Debug
                $now = Get-Date

                $LastCommandSecs = if ($whenLastCommand) {
                ($now - $whenLastCommand) | ForEach-Object TotalSeconds
                }
                # $LastErrorSecs = ($now - $whenLastError) | ForEach-Object TotalSeconds
                # $lastErrorSecs =
                # $lastCommandSecs, $lastErrorSecs | Write-Debug

                $longestDeltaSecs = [math]::max(
                    ($LastErrorSecs ?? 0), ($LastCommandSecs ?? 0 )
                )
                if ($longestDeltaSecs -gt 4.0) {
                    "`nReset Errors!: Err -Reset`n" | Write-Color 'orange'
                }
                $dbg += @{
                    'lastError'        = $whenLastError
                    'LastCommand'      = $whenLastCommand
                    'Now'              = $now
                    'LastCommandSecs'  = $LastCommandSecs
                    'LastErrorSecs'    = $LastErrorSecs
                    'longestDeltaSecs' = $LastErrorSecs
                    'Delta >= 4'       = $longestDeltaSecs -gt 4.0
                }
            }
            $dbg | Format-Default | Out-String | Write-Debug

            $segments = @(
                $splatPredent = @{
                    NewlineCount          = ($__ninConfig.Prompt)?.PredentLineCount ?? 2
                    IncludeHorizontalLine = ($__ninConfig.Prompt)?.IncludePredentHorizontalLine ?? $false
                }
                <#
                    $EnablePromptDetectError = $false
                    if ($EnablePromptDetectError) {
                        function _Write-PromptDetectError {
                            if ($global:Error.count -gt 0 -and $configErrorLinesLimit -gt 0) {
                                Dev.Nin\Test-DidErrorOccur -Limit $configErrorLinesLimit
                                "`n"
                            }
                        }
                        _Write-PromptDetectError
                    }
                    #>










                _Write-Predent @splatPredent
                # _Write-Predent -NewlineCount 2 -IncludeHorizontalLine:$false
                _Write-PromptIsAdminStatus
                if ($__ninConfig.Prompt.IncludeGitStatus) {
                    _Write-PromptGitStatus # todo: better git status line
                    "`n"
                }

                $splatWriteError = @{
                    # AlwaysShow = $true
                    Options = @{
                        'FormatMode'       = 'cleanColor'
                        'PrintRecentError' = $false
                    }
                }

                _Write-ErrorSummaryPrompt @splatWriteError
                # _Write-ErrorSummaryPrompt -AlwaysShow:$false

                # if ($false -and $__ninConfig.Prompt.IncludeDynamicCrumbs) {
                #     "`n"
                #     _Write-PromptDynamicCrumbs #-FormatMode 'Segmentsdfdsf'
                # }

                $false ? "`n" : ''

                # if ($false) {
                #     "`n"
                # } else {
                #     ' '
                # }
                function _writeCleanerPath_iter0 {
                    $prefix = $Env:USERPROFILE -replace '\\', '/'
                    $relPath = $pwd.ToString() -replace (ReLit $Env:USERPROFILE), '' -replace '\\', '/'
                    $render = @(
                        "${fg:gray30}"
                        $Prefix
                        "${fg:gray70}"
                        $Relpath
                        # ${fg:gray30}${prefix}"
                    ) | Join-String
                }
                function _writeCleanerPath_iter1 {
                    # as 1 line
                    $splatdimGlow = @{bg = 'gray15'; fg = 'gray30' }
                    $prefix = (ReLit "${Env:UserProfile}\SkyDrive\Documents\2021" )
                    $shortP = ($pwd) -replace $prefix, '/docs' -replace '\\', '/'
                    $finalShortPath = ($shortP)
                    $finalShortPath
                    | Write-Color @splatdimGlow
                }
                function _writeCleanerPath_iter2 {
                    # as 2 lines
                    $splatdimGlow = @{bg = 'gray15'; fg = 'gray30' }
                    $prefix = (ReLit "${Env:UserProfile}\SkyDrive\Documents\2021" )
                    $shortP = ($pwd) -replace $prefix, '/docs' -replace '\\', '/'
                    $finalShortPath = ($shortP)
                    $finalShortPath
                    | Write-Color @splatdimGlow
                }
                function _writeCleanerPath_iter3 {
                    # as 2 lines
                    $splatdimGlow = @{bg = 'gray15'; fg = 'gray30' }
                    $splatGlow = @{  fg = 'gray70' }
                    $prefix = (ReLit "${Env:UserProfile}\SkyDrive\Documents\2021" )
                    $shortP = ($pwd) -replace $prefix, '/docs' -replace '\\', '/'
                    $finalShortBasePath = $shortP -split '/' | Select-Object -SkipLast 2 | Join-String -sep '/'
                    $finalActivePath = $shortP -split '/' | Select-Object -Last 2 | Join-String -sep '/'

                    @(
                        $finalShortBasePath | Write-Color @splatdimGlow
                        $finalActivePath | Write-Color @splatGlow
                    ) -join '/' #| Join-String -sep "`n"
                }
                # _Write-PromptPathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'
                # _Write-PromptPathToBreadCrumbs #-FormatMode 'Segmentsdfdsf'
                @(
                    ' '
                    _writeCleanerPath_iter3
                    # _writeCleanerPath_iter2
                    # _writeCleanerPath_iter1
                    # _writeCleanerPath_iter0

                ) -join '' # "`n`n"

                # ($__ninConfig.Prompt)?.

                function _otherSegmentsTodo {
                    # quick hack to show what to add
                    @(
                        'lastwritetime'
                        'fileExtSummary'
                        'filenameSummary (see new LS formats)'
                        'easy way to change segment ordering'
                    ) | Out-Null
                }

                # _otherSegmentsTodo


                $ChildCountFormat = ($__ninConfig.Prompt)?.SegmentChildCountFormat ?? 'Icons'
                if ($ChildCountFormat) {
                    _Write-SegmentChildCount -FormatMode $ChildCountFormat
                }

                $splatdimGlow = @{bg = 'gray15'; fg = 'gray30' }
                # "default:nin⚙" | write-color @splatdimGlow | join-str -op "`n"
                # 'default:nin⚙' | write-color @splatdimGlow | Join-String -op "`n"

                "`n🐒> "
            ) | Join-String
            $segments | Join-String
        }
    }

}
# } catch {
# $PSCmdlet.WriteError( $_ )
# }
# }

Export-ModuleMember -Function Write-NinProfilePrompt
# if debug mode
if ($true) {
    Export-ModuleMember -Function @(
        '_Write-PromptDynamicCrumbs'
        'toggleErrors'
        '_Write-PromptIsAdminStatus'
        '_Write-PromptPathToBreadCrumbs'
        '_Write-PromptGitStatus'
        '_Write-PromptDetectParent_iter0'
        '_Write-ErrorSummaryPrompt'
        '_Write-PromptForBugReport'
    )
}

$src = Join-Path $PSScriptRoot 'backup_vscode.ps1'
if (Test-Path $src) {
    . $src
    Export-ModuleMember -Function 'Backup-VSCode'
}
# if ( $false -and $OneDrive.Enable_MyDocsBugMapping) {
#     'Skipping Backup-VSCode' | Write-Host -ForegroundColor 'green'
#     | Join-String -op 'OneDriveBugFix: ' | Write-Warning
# } else {
#     'temp toggle backup is off'
#     # Backup-VSCode
# }
# # & {

if ($false) {
    # testing air-quote
    Hr -fg orange
    _Write-ErrorSummaryPrompt -AlwaysShow -Options @{'FormatMode' = 'cleanColor' }
    Hr -fg magenta
    _Write-ErrorSummaryPrompt -AlwaysShow -Options @{'FormatMode' = 'medColor' }
    Hr
    _Write-ErrorSummaryPrompt -AlwaysShow
    Hr -fg orange
}
# @(
#     'Profile: 🏠 <-- End'
#     hr 1
# ) | Warn🛑
# 'Profile Aliases: ' | Write-TExtColor orange
# | Join-String -op 'Profile Aliases: ' | Write-Warning
# }

# Get-ChildItem fg: | Where-Object { $_.X11ColorName -match 'alm|moun' } | Sort-Object Rgb | ForEach-Object { New-Text $_.x11ColorName -fg $_ } | Join-String -sep ' . '
# | Write-Host
