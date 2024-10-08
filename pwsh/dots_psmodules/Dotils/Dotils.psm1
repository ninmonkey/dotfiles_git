using namespace System.Collections.Generic
using namespace System.Collections
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

$global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module

$script:CountersListForAddLabel ??= @{}
$script:Bdg_LastSelect = @()
$script:QuerySave = @{}
[list[Object]]$script:WasHistory = @( gi $PSScriptRoot )


$PROFILE | Add-Member -NotePropertyName 'Dotils' -NotePropertyValue (Get-item $PSCommandPath ) -Force -ea 'ignore'

$saGlobSplat = @{
    PassThru    = $true
    ErrorAction = 'ignore'
    Scope       = 'Global'
    # Force       = $true
}
# quick path hack, because I don't have a path for a build version, and the paths had a double Picky in the name, to fix
$env:PSModulePath = @( $env:PSModulePath ; 'H:\data\2024\pwsh\Modules.devNin.🦍\Picky' ) |Join-String -sep ';'
# future: ensure never duplicate paths in psmoduelspath, case-insensitive always


# Import-Module -force -pass 'H:\data\2024\pwsh\Modules.devNin.🦍\Picky\Picky\Picky.psd1'
Import-Module -force -pass 'Picky'
@(
    Set-Alias @saGlobSplat -name 'impo'         -Value 'Import-Module' -desc 'Import Module'
    Set-Alias @saGlobSplat -name 'st'           -Value 'Ninmonkey.Console\Format-ShortTypeName' -desc 'Abbreviate types'
    Set-Alias @saGlobSplat -name '.fmt.Type'    -Value 'Ninmonkey.Console\Format-ShortTypeName' -desc 'Abbreviate types'
    Set-Alias @saGlobSplat -name 'Yaml'         -Value 'powershell-yaml\ConvertTo-Yaml'
    Set-Alias @saGlobSplat -name 'Yaml.From'    -Value 'powershell-yaml\ConvertFrom-Yaml'
    Set-Alias @saGlobSplat -Name 'Text.TakeN'   -value 'Picky\Picky.Text.FirstN'
    # experimentijng with wierd names
)

write-warning 'super experimental bindings'
@(
    Set-Alias @saGlobSplat -Name 'Pk!Empty'     -value 'Picky\Picky.Text.Where-IsNotEmpty'
    Set-Alias @saGlobSplat -Name '?NotEmpty'     -value 'Picky\Picky.Text.Where-IsNotEmpty'
    Set-Alias @saGlobSplat -Name 'Pk?Empty'     -value 'Picky\Picky.Text.Where-IsNotEmpty'
    Set-Alias @saGlobSplat -Name 'Pk.?Empty'     -value 'Picky\Picky.Text.Where-IsNotEmpty'
    Set-Alias @saGlobSplat -Name 'Pk.?NotEmpty' -value 'Picky\Picky.Text.Where-IsNotEmpty'
    Set-Alias @saGlobSplat -Name 'Pk.?<' -value 'Picky\Picky.Text.SkipBeforeMatch'
    Set-Alias @saGlobSplat -Name 'Pk>Skip' -value 'Picky\Picky.Text.SkipBeforeMatch'
    Set-Alias @saGlobSplat -Name 'Pk<Skip' -value 'Picky\Picky.Text.SkipAfterMatch'
    Set-Alias @saGlobSplat -Name 'Pk?SkipBefore' -value 'Picky\Picky.Text.SkipBeforeMatch'
    Set-Alias @saGlobSplat -Name 'Pk?Skip<' -value 'Picky\Picky.Text.SkipBeforeMatch'
    Set-Alias @saGlobSplat -Name 'Pk.B4↪' -value 'Picky\Picky.Text.SkipBeforeMatch'
) | Ft -auto | Out-String | Write-host



write-warning 'fix: Obj | .Iter.Prop ; '
write-warning 'finish Dotils.Get-CachedExpression '

# short version if you want minimal code for a polyfill
# filter _basic.Type.Short { $_ | Join-String -f '[{0}]' -sep ', ' { $_.GetType().Name  } }
# filter _basic.Type.Long  { $_ | Join-String -f '[{0}]' -sep ', ' { $_.GetType().FullName  } }
function Dotils.Show.TypeName.Short {
    <#
    .SYNOPSIS
        Long name without the fully qualified assembly name verbocity
    #>
    [Alias('Show.ShortName')]
    param(
        # Outputs and array of strings, unless you pass Csv. defaulted to true because currently the return value of an array of strings wasn't working
        [Alias('ToString')][switch]$Csv = $True )
    $splat = @{
        FormatString = '[{0}]'
        Separator    = ', '
        Property     = { $_.GetType().Name  }
    }
    if( -not $Csv ) { $splat.Remove('Separator') }
    $input | Join-String @splat
}
function Dotils.Quick.SummarizeResolvedCommand {
    <#
    .SYNOPSIS
        quickly render module names etc, as strings
    .EXAMPLE
        > gcm *short*type* | Dotils.Quick.SummarizeResolvedCommand

            Ninmonkey.Console\shortTypeName  # Is: Alias
            Ninmonkey.Console\Format-ShortSciTypeName  # Is: Function
            Ninmonkey.Console\Format-ShortTypeName  # Is: Function
    .LINK
        Dotils.Show.TypeName.Short
    .LINK
        Dotils.Show.TypeName.Long
    #>
    $items = @( $Input )
    $items
        | sort-Object Source, CommandType, Name
        | Join-String -f "`n{0}" -p {
            $_.Source, $_.Name -join '\' | Join-String -os "  # Is: $(
                $_.CommandType )"
        }
}
function Dotils.Show.TypeName.Long {
    <#
    .SYNOPSIS
        Long name without the fully qualified assembly name verbocity
    .NOTES
        see related:

    > gcm *short*type* | Dotils.Quick.SummarizeResolvedCommand

        dotils\Dotils.Fmt.ShortType  # Is: Alias
        dotils\Fmt.ShortType  # Is: Alias
        dotils\Dotils.DbgTest.ShortType  # Is: Function
        dotils\Dotils.Format-ShortType  # Is: Function
        NameOf\NameOf.Format.ShortType  # Is: Function
        nin.ChainLinq\Fmt.ShortType  # Is: Function
        Ninmonkey.Console\renderShortTypeName  # Is: Alias
        Ninmonkey.Console\shortType  # Is: Alias
        Ninmonkey.Console\shortTypeName  # Is: Alias
        Ninmonkey.Console\Format-ShortSciTypeName  # Is: Function
        Ninmonkey.Console\Format-ShortTypeName  # Is: Function
        Ninmonkey.Console\Render-ShortTypeName  # Is: Function
    .LINK
        Dotils.Show.TypeName.Short
    .LINK
        Dotils.Show.TypeName.Long
    #>
    [Alias('Show.LongName')]
    [OutputType( [String[]] )]
    param(
        # Outputs and array of strings, unless you pass Csv. defaulted to true because currently the return value of an array of strings wasn't working
        [Alias('ToString')][switch]$Csv = $True )

    $items = @( $Input )
    $splat = @{
        FormatString = '[{0}]'
        Separator    = ', '
        Property     = { @(
            $_.GetType().Namespace -replace '^System\.(Text.RegularExpressions|Management.Automation)\.',
                '' -replace '(System\.)',
                ''
            # $_.GetType().Namespace -replace '^System\.(Text.RegularExpressions\.?|Management.Automation)',
            #     '' -replace '^(System\.?)$',
            #     ''
            $_.GetType().Name
        ) |Join-String -sep '.' }
    }
    if( -not $Csv ) { $splat.Remove('Separator') } # partially not working
    $items | Join-String @splat
}

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7.4

# function Dotils.Resolve.TypeInfo.WithDefault {
#     <#
#     .SYNOPSIS
#         try to resolve [type] info, else, always return the original string as the fallback value
#     .notes
#         resolve implies it will always return the original, not null
#     #>
#     [Alias('.Resolve.TypeInfo')]
#     [OutputType('type[]', 'string[]')]
#     param(
#         [Parameter()]
#         [Alias('InputObject')][string]$TypeName,

#         [Parameter()]
#         [object]$DefaultValue
#     )
#     process {
#         $type? = $TypeName -as 'type'
#         if( -not $type? ) {
#             return $TypeName
#         }
#         return $Type?
#     }
# }

@'
wip
Dotils.DropNamespace
Dotils.Goto.Error
Dotils.EC.GetNativeCommand
Dotils.Fd.Recent
Dotils.Git.AddRecent

- [ ] add error category completions
- [ ] add exception-name-completions
- [ ] hotkey that runs exception-name-completion, then inserts into text instead of just completing parameter for a function to find it

# new completer idea

    # normaly it stops property at depth=1,
    $serr | Join-String -Property InvocationInfo

    # but allow it for named types:
    $serr | Join-String -Property InvocationInfo.ScriptName


'@ | write-host -bg '#2e3440' -fg '#acaeb5'

# PSReadLineExtensions
function Dotils.Impo.PSReadLineExtensions {
    [CmdletBinding()]
    param()
    'loading PSReadLineExensions: from: {0}' -f  $PSCommandPath | Write-verbose
    @(
        Join-path $PSScriptRoot './PSReadLine/ParensWrapSelection.ps1' | gi -ea 'continue'
    )
    | %{
        'extension: {0}' -f $_.Name | Write-Verbose
        . $_
    }
}


function Dotils.Module.RequireLoaded {
    <#
    .synopsis
        internal func. should be cached for complexity: O(1)
    .EXAMPLE
        Dotils.Module.RequireLoaded -Name 'ugit'
        Dotils.Module.RequireLoaded -Name 'GitLogger' -UsingForce
    .EXAMPLE
        Dotils.Module.RequireLoaded -Name 'ImportExcel', 'ClassExplorer' -WithoutGlobal
    .EXAMPLE
        Dotils.Module.RequireLoaded -Name 'ImportExcel', 'ClassExplorer' -Force

    #>
    [Alias(
        'Dotils.Module.IsLoaded',
        'Dotils.Module.AssertIsLoaded'
    )]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias( 'Name')]
        [ArgumentCompletions(
            "'ugit'",
            "'PSParseHtml'",
            "'ImportExcel'",
            "'Rocker'",
            "'BurntToast'",
            "'EzOut'",
            "'GitLogger'"
        )]
        [string[]] $ModuleName,

        [Alias('Force')]
        [switch] $UsingForce,

        # because otherwise module is loaded in module's scope
        [switch] $WithoutGlobal
    )

    foreach( $curModule in $ModuleName ) { # manual enumeration because it's a sketch
        if( Get-Module $curModule ) { continue }

        $importModuleSplat = @{
            Name     = $curModule
            PassThru = $true
            Global   = -not $WithoutGlobal
            Force    = -not $UsingForce
        }

        Import-Module @importModuleSplat
            | Join-String -f '::Auto-loading required module: "{0}"' -p { $_.Name, $_.Version -join ': ' }
            | Write-Host -fg '#b3dfff' -bg '#2e3440'
    }
}
function Dotils.Module.RequireNotLoaded {
    <#
    .synopsis

    #>
    # [Alias(
    # )]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias( 'Name')]
        [ArgumentCompletions(
            "'ugit'",
            "'PSParseHtml'",
            "'ImportExcel'",
            "'Rocker'",
            "'BurntToast'",
            "'EzOut'",
            "'GitLogger'"
        )]
        [string[]] $ModuleName
    )
    write-warning 'NYI: Does not seem to affect users scope when invoke within a module context'
    foreach( $curModule in $ModuleName ) { # manual enumeration because it's a sketch
        Remove-Module "${curModule}$*" -Verbose
    }
}


function Dotils.Goto.Error {
    param(
        [Parameter(
            ParameterSetName='ByIndex', ValueFromPipeline, Position = 0 )]
        $InputError
    )
    $ie = $InputError

    $fullPath =
        $ie.InvocationInfo | Join-String -Property {
            '{0}:{1}' -f @( $_.ScriptName, $_.ScriptLineNumber  ) }

    'see also: Dotils.Goto.Kind => then errorKind'
        | write-host -bg 'orange' -fg 'gray80'

    Join-String -in $Fullpath -f "found error:`n    <{0}>`n"
        | Dotils.Write-DimText
        | Infa
}

function Dotils.Module.ForceLoad {
    <#
    .SYNOPSIS
        quickly force load a module, and nicer imported command table. default clears errors
    .NOTES
        future: - [ ] complete or import modules from <
            gci 'H:\data\2024\pwsh\PSModules.🐒.miniLocal' *.psd1 -Recurse | % name | sort
    #>
    [Alias('ReImpo','Quick.ReImpo')]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [ArgumentCompletions(
            '$Module'
        )]
        [string] $Name,

        # don't clear errors?
        [switch] $NeverClearErrors
    )

    Join-String -f ' => Importing: {0}' -Inp $Name
        | Dotils.Write-DimText
        | Infa

    if( -not $NeverClearErrors ) { $global:Error.clear() }

    (Import-Module -Scope Global $Name -PassThru -Force).ExportedCommands.Values
}

function Dotils.Format.Show.Space {
    <#
    .synopsis
        a 1 liner to quickly render spaces, visible to the user. only spaces. doesn't touch other whitespace
    #>
    process {
    $_ -replace '[ ]', "${fg:gray30}`u{2420}${fg:clear}"
} }

function Dotils.Split.String {
    <#
    .SYNOPSIS
        Equivalent to -split but on the pipeline
    .EXAMPLE
        # this is sugar for having to inline the operator on pipeline like this:
        ... | %{ $_ -split '\r?\n' } | ...
    #>
    [Alias(
        'Dotils.Split.NL',
        'Split.NL'
    )]
    [CmdletBinding()]
    param(
        [Alias('Text', 'In', 'InObj', 'Str', 'InStr', 'Content')]
        [Parameter(ValueFromPipeline)]
        [string]$InputObject,

        [Alias('Pattern')][string]$Regex = '\r?\n'
    )
    process {
        if( $MyInvocation.InvocationName.EndsWith(
            '.NL', <# Ignore? #> $true, <# cultinfo #> $null )) {
            $Regex = '\r?\n' # is currently reduntant. until more patterns are added
        }
        # $MyInvocation.InvocationName | write-verbose
        $InputObject -split $Regex
    }
}
function Dotils.Select.Error {
    [CmdletBinding()]
    param(
        [Alias('Id','Number', 'Offset')]
        [Parameter(ParameterSetName='ByIndex', Mandatory )]
        $ErrorIndex,

        # Testing weird characters in autocomplete for quirks
        [Alias(
            'Kind','Type', 'Category', 'Condition',
            'WhereIs', 'WhereMatch' )]
        [Parameter(ParameterSetName='ByKind', Mandatory )]
        [ArgumentCompletions(
            'ParserError',

            'MissingEndParenthesisInFunctionParameterList',
            'Re≔Missing␠Parameter␠List',
            'Re:MissingParameterList',
            'Re≔Missing〜␠Parameter〜List'
        )]
        [string[]]$ByKind
    )
    write-warning 'heavy wip: Dotils.Select.Error'
    $Re = [ordered]@{
        Syntax = [ordered]@{}
    }
    $Re.Syntax.MissingParamList = 'missing.*(parameter.*list)'

    @{
        Mode = $PSCmdlet.ParameterSetName
        BoundParams = $PSBoundParameters
        Index = 2
    }
        | Json -depth 2 -Compress:$false
        | Join-String -sep "`n" | write-verbose

    if($PSBoundParameters.ContainsKey('ByKind')) {
        '-ByKind is hardcoded, wip' | write-host -back 'darkblue'
    }


    function __test.ShouldKeepError {
        [CmdletBinding()]
        param(
            [Alias('InputObject', 'Error', 'Err', 'Obj', 'Object')]
            [Parameter(Mandatory, ValueFromPipeline)]
            $InputError
        )
        Join-String -in $MyInvocation.MyCommand -f 'enter => {0}'
            | Write-verbose

        $ie = $InputError

        $meta = [ordered]@{}
        $Category? = ($ie)?.CategoryInfo
        $Reason? = ($ie.CategoryInfo)?.Reason

        $meta.Category = $Category?
        $meta.Reason = $Reason?

        $meta | Json -depth 2
            | Join-String -sep "`n" -op 'meta := '
            | Write-Debug

        # always false, test case
        $false

        if( ($ie.CategoryInfo)?.ToString() -match 'ParserError' ) {
            return $true
        }
        if( ($ie.CategoryInfo)?.Category -eq 'ParserError' ) {
            return $true
        }


        if($false -and 'quick notes for others'){
            # $ie.Exception.GetType() -eq @(
            #     'ParentContainsErrorRecordException'
            #     'SystemException'
            # )
        }

        foreach($curKind in $ByKind) {
            Join-String -in $CurKind -op '__test.ShouldKeepError :: iteration => curKind: '
                | write-verbose

            $curWanted = @(
                'MissingEndParenthesisInFunctionParameterList',
                'Re≔Missing␠Parameter␠List',
                'Re:MissingParameterList',
                'Re≔Missing〜␠Parameter〜List'
            )
            if($curKind -in @($CurWanted)) {

                [bool]$test =
                    $ie.Exception.Message -match $Re.Syntax.MissingParamList

                if($Test) {
                    $true; break ; }
                else {
                    $false; continue ; }

            }
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ByIndex' {
            # $global:error[ $ErrorIndex ]
            $found = @( $global:error)[ $ErrorIndex ]
            break
        }
        'ByKind' {
            # return
            $found = @(
                $global:error | ?{
                    $tests = @(
                        __test.ShouldKeepError -InputObject $_ -Verbose -Debug
                    )
                    if( ($tests -eq $true).count -gt 0 ) {
                        return $true
                    }
                    return $false
                }
            )
            break
            # return $found
            # if( @( $ByKind ) -contains 'ParserError' ) {

            # }
            # $global:Error.GetEnumerator() | ?{
            #     $_.Exception.Message -match $Re.Syntax.MissingParamList
            # }
        }
        default {
            throw (Join-String -in $PSCmdlet.ParameterSetName -op "Unhandled ParameterSet: ")
        }
    }

    if( ($null -eq $found) -and $global:error.count -gt 0 ) {
            'No Errors were found, however {0} errors exist' -f @(
                $Global:error.count ?? 0
            ) | write-warning
    }
    return $found
}


class SavedColorPairs {
    [RgbColor]
    $FG

    [RgbColor]
    $Bg

    hidden [string]
    $Name

    hidden [string]
    $Description

    [SavedColorPairs]
        SwapColors() {
            return [SavedColorPairs]@{
                Fg = $this.BG
                Bg = $this.Fg
            }
        }

    [string]
        ToString( ) {
            return $this.Ansi('')
        }
    [string]
        DisplayString() { return $this.DisplayString('') }
    [string]
        DisplayString( [string]$Text ) {
            return $this.Ansi( $Text ?? '' )
        }

    [string]
        VerboseDisplayString( ) {
            return '{0} {1} {2} {3}' -f @(
                $This.Fg.X11ColorName
                $This.Fg.ToPsMetadata()
                $This.Bg.X11ColorName
                $This.Bg.ToPsMetadata()
            )
        }
    [string]
        Ansi () { return $this.Ansi('') }
    [string]
        Ansi( [string]$Text ) {
            return @(
                # $This.Fg ? $script:PSStyle.Foreground.FromRgb( $this.Fg ) : ''
                # $This.Bg ? $script:PSStyle.Background.FromRgb( $this.Bg ) : ''
                $This.FG
                $This.BG
                $Text ?? ''
                # $script:PSStyle.Reset
            ) -join ''
        }
}

function Dotils.Color.SavedPairs.Display {
    <#
    .example
        #
        > @( $q[3] ; $q[3].SwapColors(); )
            | Dotils.Color.SavedPairs.Display -OutputMode Bar -Delim "`n"
    .example
        > (Dotils.Color.SavedPairs.Get -Options @{ SwapPairs = $true; GenerateHighContrastComplements = $false ; GenerateComplements = $false })
            | CountOf | Dotils.Color.SavedPairs.Display
    .example
        > (Dotils.Color.SavedPairs.Get) | Dotils.Color.SavedPairs.Display -OutputMode Table
        > Dotils.Color.SavedPairs.Display -in (Dotils.Color.SavedPairs.Get) -OutputMode Table
    #>
    param(
        [Parameter(Position=0)]
        [ValidateSet('Table', 'VerboseName', 'Bar', 'Blank', '')]
        [string]$OutputMode,
        [switch]$BaseColorsOnly,

        [ArgumentCompletions(
            "(Dotils.Color.SavedPairs.Get)"
        )]
        [Parameter(ValueFromPipeline, ParameterSetName='fromPipe')]
        [SavedColorPairs[]]$InputObject,

        [string]$Delim = '    ',
        [string]$RenderText = 'foo bar blank'
    )
    begin {
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }
    end {
        # if( -not [string]::IsNullOrEmpty( $Items )) {

        #     $items = Dotils.Color.SavedPairs.Get -BaseColorsOnly:$BaseColorsOnly
        # }
        if($items.count -eq 0) { throw 'NoItems!'}
        switch($OutputMode) {
            'Table' {
                $items | %{
                    $RenderText
                        | New-Text -fg $_.FG -bg $_.FG
                    hr
                }
                break
            }
            { $_ -in @('', 'Bar', $Null) } {
                $Items | %{
                    $RenderText
                        | New-Text -fg $_.FG -bg $_.BG
                } | Join-String -sep $Delim
                break
            }
            'Blank' {
                $Items | %{
                    $RenderText
                        | New-Text -fg $_.FG -bg $_.FG
                } | Join-String -sep $Delim
                break
            }
            'VerboseName' {
                $Items | %{
                    $_.VerboseDisplayString()
                        | New-Text -fg $_.FG -bg $_.BG
                } | Join-String -sep $Delim
                break
            }
            default { throw "UnhandledOutputMode: $OutputMode"}
        }
    }
}
function Dotils.Color.SavedPairs.Get {
    # return a list of saved
    [OutputType(
        [SavedColorPairs]
    )]
    param(
        # Expects keys: GenComplements: bool, GenHighContrastComplements: bool
        [ArgumentCompletions(
            '@{ SwapPairs = $true; GenerateHighContrastComplements = $true ; GenerateComplements = $true }'
#             '@{
# GenerateHighContrastComplements = $true
# GenerateComplements = $true }',

#             '@{
# GenerateHighContrastComplements = $true
# GenerateComplements = $true
# }'
        )]
        [hashtable]$Options,
        [switch]$BaseColorsOnly
    )
    $Config = nin.MergeHash -OtherHash $Options -BaseHash @{
        GenerateComplements = $true
        SwapPairs = $True
        GenHighContrastComplements = $false
    }

    [List[SavedColorPairs]]$saved = @(
        [SavedColorPairs]@{ Fg = '#745074' ; Bg = '#7aa1b9' }
        [SavedColorPairs]@{ Fg = '#745074' ; Bg = '#2e3440' }
        [SavedColorPairs]@{ Fg = '#1f1f1f' ; Bg = '#c49168' }
        [SavedColorPairs]@{ Fg = '#c49168' ; Bg = '#1f1f1f' }
        [SavedColorPairs]@{ Fg = '#1f1f1f' ; Bg = '#d5b55d' }
        [SavedColorPairs]@{ Fg = '#d5b55d' ; Bg = '#1f1f1f' }
        [SavedColorPairs]@{ Fg = '#1f1f1f' ; Bg = '#d5b55d' }
        [SavedColorPairs]@{ Fg = '#d5b55d' ; Bg = '#1f1f1f' }
        [SavedColorPairs]@{ Fg = '#2e3440' ; Bg = '#acaeb5' }
        [SavedColorPairs]@{ Fg = '#acaeb5' ; Bg = '#2e3440' }
        [SavedColorPairs]@{ Fg = 'gray70'  ; Bg = 'gray40'  }
        [SavedColorPairs]@{ Fg = '#c49168' ; Bg = 'gray40'  }
        [SavedColorPairs]@{ Fg = 'gray40'  ; Bg = '#c49168' }
        [SavedColorPairs]@{ Fg = '#c49168' ; Bg = 'gray70'  }
        [SavedColorPairs]@{ Fg = 'gray70'  ; Bg = '#c49168' }
        [SavedColorPairs]@{ Fg = '#1f1f1f' ; Bg = 'gray40'  }
        [SavedColorPairs]@{ Fg = 'gray40'  ; Bg = '#1f1f1f' }
        [SavedColorPairs]@{ Fg = '#1f1f1f' ; Bg = 'gray70'  }
        [SavedColorPairs]@{ Fg = 'gray70'  ; Bg = '#1f1f1f' }
        [SavedColorPairs]@{ Fg = '#c586c0' ; Bg = '#ce8d70' }
        [SavedColorPairs]@{ Fg = '#ce8d70' ; Bg = '#c586c0' }
        [SavedColorPairs]@{ Fg = '#dcdcaa' ; Bg = '#ce8d70' }
        [SavedColorPairs]@{ Fg = '#ce8d70' ; Bg = '#dcdcaa' }
        [SavedColorPairs]@{ Fg = '#660e22' ; Bg = '#a90f2d' }
        [SavedColorPairs]@{ Fg = '#fefe22' ; Bg = '#a9ffdd' }
    )

    if($BaseColorsOnly) {
        return $saved
    }
    [List[object]]$finalAlignPairs = @()

    foreach($cur in $Saved) {
        $finalAlignPairs.Add( $cur )
        if($Config.SwapPairs) {
            $finalAlignPairs.AddRange( [SavedColorPairs[]]@(
                $cur.SwapColors()
            ))
        }
        if($Config.GenerateComplements) {
            $fgComple = $cur.FG.GetComplement($false, $false)
            $BgComple = $cur.BG.GetComplement($false, $false)
            $finalAlignPairs.AddRange( [SavedColorPairs[]]@(
                [SavedColorPairs]@{
                    Fg = $FgComple
                    Bg = $cur.Bg
                }
                [SavedColorPairs]@{
                    Fg = $cur.Fg
                    Bg = $BgComple
                }
                [SavedColorPairs]@{
                    Fg = $FgComple
                    Bg = $BgComple
                }
            ))
        }
        if($Config.GenerateHighContrastComplements) {
            $fgCompleHigh = $cur.FG.GetComplement($true, $false)
            $BgCompleHigh = $cur.BG.GetComplement($true, $false)
            $finalAlignPairs.AddRange( [SavedColorPairs[]]@(
                [SavedColorPairs]@{
                    Fg = $FgCompleHigh
                    Bg = $cur.Bg
                }
                [SavedColorPairs]@{
                    Fg = $cur.Fg
                    Bg = $BgCompleHigh
                }
                [SavedColorPairs]@{
                    Fg = $FgCompleHigh
                    Bg = $BgCompleHigh
                }
            ))
        }
    }
    return $finalAlignPairs
        | Sort-Object -p { $_.Fg, $_.Bg -join '_' } -unique

}


function Dotils.Quick.ColorPairs {
    <#
    .link
        Dotils.Color.SavedPairs.Display
    .link
        Dotils.Color.SavedPairs.Get
    #>
    param(
        [string]$Delim = "`n",
        [ArgumentCompletions('Table', 'VerboseName', 'Bar', 'Blank', '')]$OutputMode = 'VerboseMode'
    )
    Dotils.Color.SavedPairs.Display -OutputMode $OutputMode -Delim $Delim -in (Dotils.Color.SavedPairs.Get)
}
function Dotils.DropNamespace {
    <#
    .SYNOPSIS
        (gi .).GetType().FullName | Dotils.DropNamespace
            DirectoryInfo

        (gi .).GetType() | Dotils.DropNamespace
            DirectoryInfo

        (gi .).GetType().FullName | Dotils.DropNamespace
        (gi .).GetType() | Dotils.DropNamespace
        (gi .) | Dotils.DropNamespace
            DirectoryInfo
            DirectoryInfo
            DirectoryInfo
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Position=0)]
        $InputObject,

        [Alias('cl')]
        [switch]$Clip
    )
    # case where string is the type name
    if($InputObject -is 'string') {
        if($InputObject -as 'type' -ne $Null) {
            $Found = ($InputObject -as 'type').Name
            if($Clip) {
                return $Found |  Set-Clipboard -PassThru
            } else {
                return $found
            }
        }
        # $type? = $InputObject -as 'type'
    }

    # if( -not ($o -is 'type')) { $o.GetType().Name }
    if( -not ($InputObject -is 'type')) {
        $found = ($InputObject)?.GetType().Name
        if($Clip) {
            return $Found |  Set-Clipboard -PassThru
        } else {
            return $found
        }

    }

    $found = @( $InputObject )?.Name ??
        @( $InputObject)?.GetType().Name ??
            'unknown'
    $found | Write-debug
    if($Clip) {
        return $Found | Set-Clipboard -PassThru
    }
    return $Found
}
function Dotils.Docker.FirstId {
    <#
    .SYNOPSIS
        runs: 'docker container ls -- to grab the newest container Id -- (using Rocker)
    .LINK
        Dotils.Docker.Native.FirstId
    .link
        Dotils.Docker.FirstId
    #>
    param(
        [switch]$PassThru
    )
    Import-Module Rocker -ea 'stop'
    if( $PassThru ) {
        (docker container ls | Select -first 1)
    } else {
        (docker container ls | Select -first 1).ID
    }
}

function Dotils.Docker.Native.FirstId {
    <#
    .SYNOPSIS
        Parses the docker natived command to return the first Container ID. ( even if Rocker is imported )
    .LINK
        Dotils.Docker.Native.FirstId
    .link
        Dotils.Docker.FirstId
    #>
    $binDocker = gcm docker -CommandType Application -TotalCount 1 -ea 'stop'
    $lastId =
        (& $BinDocker @('container', 'ls') | Select -Last 1) -split '\s+' | Select -first 1
    return $LastId
}
function Dotils.Docker.Native.Start-WaitConnectLoop {
    <#
    .synopsis
        Auto reconnect to next container as it is built. Disconnects/container stops  will continue to reconnect
    .NOTES
        Hides Errors (in stdout stream)
    .EXAMPLE
        Pwsh> Dotils.Docker.Native.Start-WaitConnectLoop
    #>
    param(
        # write stdout to host, too
        [switch]$PSHost
    )

    while( $true ) {
        ($FirstId = (Dotils.Docker.Native.FirstId) )
            | Join-String -f '   reconnecting to {0} . ctrl+z/c to exit loop'
            | Write-host -fg 'salmon'

        docker exec -it $FirstId /bin/pwsh -NoL
        sleep -Milliseconds 700
    }


    # broken: while( $true ) { & { docker exec -it (Dotils.Docker.Native.FirstId) /bin/pwsh -NoL } | Write-verbose ; sleep -Milliseconds 300 ; }



    # while( $true ) {
    #     $stdout = docker exec -it (Dotils.Docker.Native.FirstId) /bin/pwsh -NoL
    #     if($PSHost) {
    #         $stdout | write-host
    #     }
    #     if( $stdout -notmatch 'no such container') {
    #         $stdout | Write-host -fore 'darkred'
    #     }
    #     sleep -milliseconds 300
    # } # loops for auto-reconnect
}
function Dotils.Docker.EnterPwshSession {
    <#
    .SYNOPSIS
        runs: 'docker exec -it (newest)' using pwsh -- (using Rocker)
    #>
    param( [string] $Id )
    '...invoking' | write-host
    import-module Rocker -ea 'stop'

    if( -not $ID ) {
        docker exec -it $(docker container ls | Select -first 1).ID /bin/pwsh -NoL
    } else {
        docker exec -it $Id /bin/pwsh -NoL
    }
}
function Dotils.Docker.Logs {
    <#
    .SYNOPSIS
        logs of newest
    #>
    param( [string] $Id )
    '...invoking' | write-host
    <#
    .SYNOPSIS
        runs: 'docker logs --details --timestamps -- to grab the container log -- (using Rocker)
    #>
    import-module Rocker -ea 'stop'
    # docker logs ( docker container ls )[0].Id --details --timestamps
    if( -not $ID ) {
        # docker logs --details --timestamps (docker container ls | Select -first 1).ID
        docker logs --details --timestamps (Dotils.Docker.Native.FirstId)
    } else {
        docker logs --details --timestamp $Id
    }
}
function Dotils.Goto-Item {
    <#
    .SYNOPSIS
        Go to the folder a file is in, or the folder if it's a directory
    #>
    [Alias('GoItem')]
    [CmdletBinding()]
    param(
        # Folder or File to navigate to. Can pipe.
        [Parameter( ValueFromPipeline )]
        $InputObject
    )
    $target = @( $InputObject ) | Select -first 1 | Get-Item
    if( -not $Target ) { return }

    if( $target.PSIscontainer ) { Pushd $Target }
    else                        { pushd $target.Directory }

    (pwd).Path | Write-host -fg 'gray60'
}

function Dotils.Invoke-NoProfilePwsh {
    <#
    .SYNOPSIS
        quickly start a new no-profile with minimal presets
    .EXAMPLE
        Dotils.Quick.NoProfilePwsh
    #>
    [Alias('Dotils.Quick.NoProfilePwsh', 'Quick.Pwsh.Nop')]
    param(
        [ArgumentCompletions(
            'Pipescript', 'ugit', 'Pansies', 'Dotils'
        )]
        [string[]]$ImportModuleNames

    )
    'starting pwsh --NoProfile...' | write-host -fore green
    pwsh -NoP -NoLogo -NoExit -Command {
        $global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module
        # get-date | write-verbose
        if( -not $ImportModuleNames ) {
            $ImportModuleNames = 'Pansies', 'Pipescript', 'ugit'
        }
        # normal defaults
        Set-PSReadLineKeyHandler -Chord 'Alt+Enter'   -Function InsertLineBelow
        Set-PSReadLineKeyHandler -Chord 'Shift+Enter' -Function InsertLineAbove
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
        Set-PSReadLineKeyHandler -Chord 'Ctrl+a' -Function SelectAll
        Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
        Set-PSReadLineKeyHandler -Chord 'Alt+a' -Function SelectCommandArgument

        $setAliasSplat = @{
            ErrorAction = 'ignore'
            PassThru    = $true
        }
        @(
            Set-Alias @setAliasSplat 'impo' -Value Import-Module
            Set-Alias @setAliasSplat 'gcl' -Value Get-ClipBoard
            Set-Alias @setAliasSplat 'cl' -Value Set-Clipboard
        ) | Join-String -op 'Set Aliases: ' -sep ', ' | Write-verbose -verbose
        # Import-Module -Name $ImportModuleNames -PassThru -Verbose # using scope issue?
        function Prompt {@( "`n"; $PSStyle.Foreground.FromRgb('#6e6e6e'); Get-Location; "`n"; '> '; $PSStyle.Reset; ) -join ''}

        @(  Import-Module 'pansies'
            Import-Module $importModulenames -pass
        # )   | Join-string -sep ', ' -prop { $_.Name, $_.Version -sep ': ' }
        )   | Join-string -sep ', '
            | Write-host -fore green
        # get-date | write-verbose
    }
}

function Dotils.CommandLookup.GroupByImplementingType {
    <#
    .SYNOPSIS
        Get a list of ImplementingTypes from [CommandInfo], optionally lookup using: InvokeCommand.GetCmdletByTypeName( [type] )
    .DESCRIPTION
        from a [SeeminglyScience discord thread](<https://discord.com/channels/180528040881815552/447475598911340559/1263899564151279658>)
        > it's a longer way of doing CommandStopper $__exceptionToThrow. The reason for the syntax is that the cmdlet isn't resolvable, it's not exported from any module. So gotta do it manually
    #>
    param(
        [hashtable] $GetCommandSplat = @{},

        # also invokes: InvokeCommand.GetCmdletByTypeName( [type] )
        [Alias('CmdletLookup', 'WithCmdletLookup')]
        [switch] $IncludeCmdletLookup

    )
    # output: [CommandInfo[]]
    $query = Get-Command @GetCommandSplat

    $found = [pscustomobject]@{
        HasType = $query | ?{ -not [string]::IsNullOrWhiteSpace( $_.ImplementingType ) }
        NoType  = $query | ?{ [string]::IsNullOrWhiteSpace( $_.ImplementingType ) }
    }
    if( -not $WithTypeLookup ) { return $found }

    # output: [CmdletInfo[]] now its only this type
    return @( $found.HasType.ForEach({
        $ExecutionContext.InvokeCommand.GetCmdletByTypeName( $_.ImplementingType )
    }) | Sort-Object )
}

function Dotils.EC.GetCommandName {
    <#
    .SYNOPSIS
    .EXAMPLE
        Pwsh 7.4.0> [1]
            🐒> Dotils.Ec.GetCommandName pwsh

            C:\Program Files\PowerShell\7\pwsh.exe
            C:\Program Files\PowerShell\7\pwsh.exe

            🐒> Dotils.Ec.GetCommandName pwsh* -Pattern
            pwshNoProfile
            C:\Program Files\PowerShell\7\pwsh.exe
            C:\Program Files\PowerShell\7-preview\preview\pwsh-preview.cmd
            C:\Program Files\PowerShell\7\pwsh.exe
    #>
    param(
        [ArgumentCompletions(
            'python*',
            'npm',
            'git',
            'ls',
            'bat',
            'fzf',
            'pwsh',
            'powershell',
            'gh'
        )]
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string]$CommandName,

        [Alias('Pattern', 'UsingPattern')]
        [switch]$IsPattern,

        [Alias('NameOnly')]
        [switch]$ShortName
    )

    $ExecutionContext.InvokeCommand.
        GetCommandName( $CommandName, $IsPattern, (-not $ShortName) )
}
function Dotils.EC.GetCommand {
    param(
        # [Alias('Pattern')]
        [string]$Name,
        # enum automatically joins as a list
        [CommandTypes]$CommandTypes = 'Application',

        [Alias('All')]
        [switch]$ListAll
    )
    if( -not $ListAll ) {
        if( [string]::IsNullOrEmpty( $Name ) ) {
            $query = $ExecutionContext.InvokeCommand.GetCommand($CommandTypes)
        }
        $query = $ExecutionContext.InvokeCommand.GetCommand($Name, $CommandTypes)
    }

}
function Dotils.EC.GetNativeCommand {
    <#
    .NOTES
        IEnumerable<CommandInfo> GetCommands(
            str: name, CommandTypes, isPattern
        [CommandInfo] GetCommand(
            str: Name, CommandTypes
        [CommandInfo] GetCommand(
            str: Name, CommandTypes, object[]: args

    #>
    param(
        # [Alias('Pattern')]
        # enum automatically joins as a list
        [string]$Name,

        [CommandTypes]$CommandTypes = 'Application',

        [Alias('AsPattern', 'Pattern')]
        [switch]$IsPattern,

        [Alias('All')]
        [switch]$ListAll
        # ,[switch]$First
    )
    if( [string]::IsNullOrEmpty($Name)) {
        # if blank or null name, wildcard is the only option that applies
        return $ExecutionContext.
            InvokeCommand.
            GetCommands('', $CommandTypes, $true )
    }
    throw 'nyi pass cat reboot'

    if( $IsPattern ) {
        # $found = $ExecutionContext.InvokeCommand.GetCommands
    }

    if( -not $ListAll ) {
        if( [string]::IsNullOrEmpty( $Name ) ) {
            $query =
                $ExecutionContext.
                    InvokeCommand.
                    GetCommand($CommandTypes)
        } else {
            $query =
                $ExecutionContext.
                    InvokeCommand.
                    GetCommand($Name, $CommandTypes)
        }
    } else {
        $query = $ExecutionContext.
            InvokeCommand.
            GetCommands( $Name, $CommandTypes, (-not $IsPattern ) )

    }
    return $query | CountOf


}
function Dotils.Fd.Recent {
    <#
    .SYNOPSIS
        easier method to invoke a few FD queries
    .LINK
        Dotils.Find-MyWorkspace
    .LINK
        Dotils.Fd.Recent
    .LINK
        Dotils.Fd.Main
    #>
    [CmdletBinding()]
    param(
        [Parameter(position=0)]
        [Alias('Recent', 'Last', 'Since')]
        [ArgumentCompletions(
            '15minutes', '5minutes', '30seconds', '4hours'
        )]
        [string]$TimeCondition,

        [Parameter(Position=1)]
        [ArgumentCompletions(
            "'.'", "'h:\data\2023'", "'h:\data\2024'",
            "'G:\2024-git'"
            )]
        [string]$PathRoot,
        [int]$MaxDepth = 5
    )

    [List[Object]]$FdArgs = @(

        '--changed-within'
        $TimeCondition
        if( -not [string]::IsNullOrWhiteSpace($MaxDepth) ) {
            '-d'
            $MaxDepth
        }
        if($root = Get-Item -ea 'silentlycontinue' $PathRoot) {
            '--search-path'
            $PathRoot # double check if it supports multiple roots
        }
    )
    $fdArgs | Join-String -sep ' ' | Dotils.Write-DimText
            | Join-string -op 'Dotils.Fd.recent: ' | write-verbose
}


function Dotils.Fd.Main {
    <#
    .SYNOPSIS
        invoke fd, sort using file object properties, then render preserving  fd's ansi color
        clean re-write at 2024-09-05
    .DESCRIPTION
        see: https://github.com/sharkdp/fd
        clean re-write at 2024-09-05
    .EXAMPLE
        # useful params:
        > Quick.Fd -Type file, dir


        > Quick.Fd -Type file, dir -SortBy LastWriteTime
        > Quick.Fd -Type file -SortBy Extension
        > Quick.Fd -Type file -SortBy Fullname

        > Quick.Fd -Verbose -CWD 'G:\2024-git' -ChangedWithin 4months -SortBy LastWriteTime

    .EXAMPLE
        # Find files adjacent to the profile
        > Quick.Fd  -Verbose -MaxDepth 1 -SearchPath ($PROFILE | Split-Path) -SortBy Extension -Type file
    .Example
        # for --relative-path using another base directory
        # include --base-directory but do not use --search-path or else it's not relative.

        > Quick.Fd -Type dir -d 2 -WorkingDirectory 'G:\2024-git\'

        # is equivalent to:
        > fd -td -d2 --base-directory (gi 'G:\2024-git')
    .EXAMPLE
        # to view command output without running
        > Quick.Fd -Verbose -WhatIf

        # or to view command as verbose
        > Quick.Fd -Verbose
    .link
        https://github.com/sharkdp/fd
    .NOTES
    default invoke of the native command
        is
            fd [OPTIONS] [pattern] [path] ...
        if --search-path is used, then
            fd [OPTIONS] --search-path <path> --search-path <path2> [<pattern>]`


    future adds:
        --format <fmt> ( rust )
        --follow
        --color=<auto | always | never>
        --max-results <int>
        -j, --threads <int>
        -1   alias for: --max-results=1

        --prune
            --exclude=<>

        --base-directory <path>
        --search-path <search-path>
        -a, --absolute-path
        -l, --list-details
        -p, --full-path
        -0, --print0
        -q, --quiet, --has-results
        --show-errors
        --strip-cwd-prefix=< auto | always | never >
        --one-file-system
        -E, --exclude <pattern>
        -S, --size <size>
            <+-><int><unit>

            units:
                'b':  bytes
                'k':  kilobytes (base ten, 10^3 = 1000 bytes)
                'm':  megabytes
                'g':  gigabytes
                't':  terabytes
                'ki': kibibytes (base two, 2^10 = 1024 bytes)
                'mi': mebibytes
                'gi': gibibytes
                'ti': tebibytes

        --changed-within <date|duration>

          Filter results based on the file modification time. Files with modification times
          greater than the argument are returned. The argument can be provided as a specific point
          in time (YYYY-MM-DD HH:MM:SS or @timestamp) or as a duration (10h, 1d, 35min). If the
          time is not specified, it defaults to 00:00:00. '--change-newer-than', '--newer', or
          '--changed-after' can be used as aliases.

            Examples:
                --changed-within 2weeks
                --change-newer-than '2018-10-27 10:00:00'
                --newer 2018-10-27
                --changed-after 1day

        --changed-before <date|dur>

            Filter results based on the file modification time. Files with modification times less
            than the argument are returned. The argument can be provided as a specific point in time
            (YYYY-MM-DD HH:MM:SS or @timestamp) or as a duration (10h, 1d, 35min).
            '--change-older-than' or '--older' can be used as aliases.

            Examples:
                --changed-before '2018-10-27 10:00:00'
                --change-older-than 2weeks
                --older 2018-10-27


  -x, --exec <cmd>...
          Execute a command for each search result in parallel (use --threads=1 for sequential
          command execution). There is no guarantee of the order commands are executed in, and the
          order should not be depended upon. All positional arguments following --exec are
          considered to be arguments to the command - not to fd. It is therefore recommended to
          place the '-x'/'--exec' option last.
          The following placeholders are substituted before the command is executed:
            '{}':   path (of the current search result)
            '{/}':  basename
            '{//}': parent directory
            '{.}':  path without file extension
            '{/.}': basename without file extension
            '{{':   literal '{' (for escaping)
            '}}':   literal '}' (for escaping)

          If no placeholder is present, an implicit "{}" at the end is assumed.

          Examples:

            - find all *.zip files and unzip them:

                fd -e zip -x unzip

            - find *.h and *.cpp files and run "clang-format -i .." for each of them:

                fd -e h -e cpp -x clang-format -i

            - Convert all *.jpg files to *.png files:

                fd -e jpg -x convert {} {.}.png

        -X, --exec-batch <cmd>...
            Execute the given command once, with all search results as arguments.
                The order of the arguments is non-deterministic, and should not be relied upon.
                One of the following placeholders is substituted before the command is executed:
                '{}':   path (of all search results)
                '{/}':  basename
                '{//}': parent directory
                '{.}':  path without file extension
                '{/.}': basename without file extension
                '{{':   literal '{' (for escaping)
                '}}':   literal '}' (for escaping)

          If no placeholder is present, an implicit "{}" at the end is assumed.

          Examples:

            - Find all test_*.py files and open them in your favorite editor:
                fd -g 'test_*.py' -X vim

            - Find all *.rs files and count the lines with "wc -l ...":
                fd -e rs -X wc -l

        --batch-size <size>
            Maximum number of arguments to pass to the command given with -X. If the number of
            results is greater than the given size, the command given with -X is run again with
            remaining arguments. A batch size of zero means there is no limit (default), but note
            that batching might still happen due to OS restrictions on the maximum length of command
            lines.






    from fd --help:

        -t, --type <filetype>
            Note that the 'executable' and 'empty' filters work differently: '--type executable' implies
            '--type file' by default. And '--type empty' searches for empty files and directories,
            unless either '--type file' or '--type directory' is specified in addition.

        -q, --quiet
            When the flag is present, the program does not print anything and will return with an
            exit code of 0 if there is at least one match. Otherwise, the exit code will be 1.
            '--has-results' can be used as an alias.

        --show-errors
            Enable the display of filesystem errors for situations such as insufficient permissions
            or dead symlinks.

        --base-directory <path>
            Change the current working directory of fd to the provided path. This means that search
            results will be shown with respect to the given base path. Note that relative paths
            which are passed to fd via the positional <path> argument or the '--search-path' option
            will also be resolved relative to this directory.

        --path-separator <separator>
            Set the path separator to use when printing file paths. The default is the OS-specific
            separator ('/' on Unix, '\' on Windows).

        --search-path <search-path>
            Provide paths to search as an alternative to the positional <path> argument. Changes the
            usage to `fd [OPTIONS] --search-path <path> --search-path <path2> [<pattern>]`

        --strip-cwd-prefix[=<when>]
            By default, relative paths are prefixed with './' when -x/--exec, -X/--exec-batch, or
            -0/--print0 are given, to reduce the risk of a path starting with '-' being treated as a
            command line option. Use this flag to change this behavior. If this flag is used without
            a value, it is equivalent to passing "always".

            Possible values:
            - auto:   Use the default behavior
            - always: Always strip the ./ at the beginning of paths
            - never:  Never strip the ./
    #>
    [Alias('Quick.Fd')]
    [CmdletBinding()]
    param(
        # List of Base directories to include in search, is: fd --search-path <path>
        # This can be relativepaths
        #
        # When paths are relative, they will use -WorkingDirectory to resolve paths
        # default is not set so that you can use relative paths of -WorkingDirectory
        [Parameter()]
            [Alias('InputObject', 'Path', 'RelativePath' )]
            [string[]] $SearchPath,

        # Current Working Directory of fd to path, is fd: --base-directory <path>
            # Change the current working directory of fd to the provided path.
            # This means that search
            #   results will be shown with respect to the given base path. Note that relative paths
            #   which are passed to fd via the positional <path> argument or the '--search-path' option
            #   will also be resolved relative to this directory.
        [Parameter()]
            [Alias('CWD', 'SetCwd', 'BaseDirectory', 'FromWorkingDirectory')]
            [string[]] $WorkingDirectory,

        # (Get-Item) property names to use for sorting
        [Parameter()]
            [ArgumentCompletions(
                'Extension', 'LastWriteTime', 'Length', 'Name',
                'FullName', 'Directory' )]
            [string] $SortBy = 'LastWriteTime',

        # Print the generated CLI command, then exit without calling native command
        [Parameter()]
            [Alias('WithoutRunning')]
            [switch] $WhatIf,

        # Default sort is Descending
        [Parameter()]
            [switch] $Ascending,

        # Do not parse as an Item or sort. emits the raw output incuding ansi color strings from 'fd'
        [Parameter()]
            [Alias('WithoutObjectConversion')]
            [switch] $PassThru,

        # is: fd --filtype < file | dir | executable | empty | symlink | socket | pipe | block-device | char-device
        [Parameter()]
            [Alias('Is', 't')]
            [ValidateSet(
                'file', 'dir', 'symlink', 'empty', 'executable', 'pipe',  'socket', "'block-device'", "'char-device'",
                'f', 'd', 's', 'p', 'b', 'c', 'x', 'e'
            )]
            [string[]] $Type,

        # pattern is a regex by default
        [Parameter()]
            [string] $Pattern,

        # arbitrary cli args to prepend
        # See 'fd --help' for valid options
        [Parameter()]
            [Alias('ArgsPrefix')]
            [string[]] $PrependArgs,

                # arbitrary cli args to append
        # See 'fd --help' for valid options
        [Parameter()]
            [Alias('ArgsSuffix')]
            [string[]] $AppendArgs,

        # DateModified is newer than < date | duration >
        # is: fd --changed-within < date | duration >
        # is: fd alias: '--change-newer-than', '--newer', '--changed-after'
        [Parameter()]
            [Alias('ChangeNewerThan', 'NewerThan')]
            [ArgumentCompletions(
               '4hours', '2weeks', '4months', '10h', '1d', '35min',
               "'2024-01-03'", "'2023-09-18 10:00:00'" )]
            [string] $ChangedWithin,

        # DateModified is older than < date | duration >
        # is: fd --changed-before < date | duration >
        # is: fd alias: '--change-older-than' or '--older' can be used as aliases.
        [Parameter()]
            [Alias('ChangeOlderThan', 'OlderThan')]
            [ArgumentCompletions(
               '4hours', '2weeks', '4months', '10h', '1d', '35min',
               "'2024-01-03'", "'2023-09-18 10:00:00'" )]
            [string] $ChangedBefore,

        # is: fd --max-depth <int>
        [Parameter()]
            [Alias('Depth', 'd')]
            [int] $MaxDepth,

        # is: fd --min-depth <int>
        [Parameter()]
            [int] $MinDepth,

        # is alias for: fd: --min-depth n --max-depth n
        [Parameter()]
            [int] $ExactDepth,

        # is: fd -I, --no-ignore
        [Parameter()]
            [switch] $NoIgnore,

        # is: fd --no-ignore-parent
        [Parameter()]
            [switch] $NoIgnoreParent,

        # show hidden. is: fd -H, --hidden
        [Parameter()]
            [switch] $Hidden,

        # case sensitive. is: fd -s, --case-sensitive
        [Parameter()]
            [switch] $CaseSensitive,

        # case insensitive. is: fd -i, --ignore-case
        [Parameter()]
            [Alias('CaseInsensitive')]
            [switch] $NotCaseSensitive,

        # glob or regex search? is: fd -g, --glob
            #  default is: fd --regex
        [Parameter()]
            [switch] $UsingGlob,

        # do not traverse into directories that match the search
        # is fd: --prune
        # to exclude specific directories, use --exclude <pattern>
            #  default is: fd --regex
        [Parameter()]
            [switch] $Prune,



        #  math pattern against fullname (verses filename) is: fd -p, --full-path
        # By default, the search pattern is only matched against the filename (or directory name).
        #     Using this flag, the pattern is matched against the full (absolute) path. Example:
        #     fd --glob -p '**/.git/config'
        [Parameter()]
            [Alias('MatchFullPath')]
            [switch] $FullPath,



        # is: fd --exclude <pattern>
        # to test:
        #    Is this always glob, or defaults regex?
        # notes:
        #   Exclude files/directories that match the given glob pattern. This overrides any other
        #   ignore logic. Multiple exclude patterns can be specified.
        [Parameter()]
            [ArgumentCompletions( "'*.pyc'", "'node_modules'")]
            [string[]] $Exclude

    )
    $binFd = Get-Command -CommandType Application 'fd' -TotalCount 1 -ea 'stop'

    [List[Object]] $binArgs = @(
        '--color=always'
        '--path-separator=/'
    )

    if( $ExactDepth ) {
        $MinDepth = $ExactDepth
        $MaxDepth = $ExactDepth
    }

    if( $PSBoundParameters.ContainsKey('PrependArgs') ) {
        $BinArgs.AddRange( $PrependArgs )
    }

    $BinArgs.AddRange(@(
        if( $PSBoundParameters.ContainsKey('MinDepth') ) { '--min-depth'; $MinDepth }
        if( $PSBoundParameters.ContainsKey('MaxDepth') ) { '--max-depth'; $MaxDepth }
        if( $UsingGlob ) { '--glob' }
        if( $FullPath ) { '--full-path' }
        if( $Prune ) { '--prune' }
        if( $NoIgnore) { '--no-ignore' }
        if( $NoIgnoreParent ) { '--no-ignore-parent' }
        if( $Hidden ) { '--hidden' }
        if( $CaseSensitive ) { '--case-sensitive' }
        if( $NotCaseSensitive ) { '--ignore-case' }
        if( $ChangedWithin ) {  '--changed-within'; $ChangedWithin }
        if( $ChangedBefore ) {   '--changed-before'; $ChangedBeforer }
    ))

    $BinArgs.AddRange(@(
        foreach($t in $Type) {
            '--type'
            $t
        }

        foreach($ex in $Exclude) {
            '--exclude'
            $ex
        }
    ))

    $binArgs.AddRange(@(
        if( $PSBoundParameters.ContainsKey('WorkingDirectory')) {
            '--base-directory'
            (Get-Item -ea 'stop' $WorkingDirectory )
        }


        if( $PSBoundParameters.ContainsKey('AppendArgs') ) {
            $BinArgs.AddRange( $AppendArgs )
        }
    ))

    # simplify invoke pattern by always passing an explicit --search-path
    # to always use:
    #   fd [OPTIONS] --search-path <path> --search-path <path2> [<pattern>]

    $BinArgs.AddRange(@(
        foreach($curPath in $SearchPath) {
            '--search-path'
            (Get-Item -ea 'stop' $curPath )
        }

        # doc: "if your pattern starts with a dash (-), make sure to pass '--' first, or it will be
        #   considered as a flag (fd -- '-foo') "

        if ($PSBoundParameters.ContainsKey('Pattern')) {
            @(
                if( $Pattern.StartsWith('-')) { '--' }
                $Pattern
            )
        }
    ))

    [string] $ArgsStr = $BinArgs | Join-String -op 'invoke => fd ' -sep ' '
    $ArgsStr | Write-Verbose

    if( $WhatIf ) {
        $PSBoundParameters | ConvertTo-Json -depth 0
            | Join-String -op "PSBoundParameters: " # -f '{0}'
            | Write-host -fg 'gray70' -bg 'gray10'
        $ArgsStr | Join-String -sep ' ' -op '    fd '
            | Write-Host -fg 'gray80' -bg 'gray20'
        return
    }

    if( $PassThru ) {
        & $binFd @BinArgs
        return
    }

    & $binFd @BinArgs
        | Sort-Object -Descending:$( -not $Ascending ) {
            # $_ | StripAnsi | Get-Item | % $SortBy
            $clean = $_ | StripAnsi
            $Item = Get-Item -ea 'ignore' $clean
            if( -not $Item ) {
                $clean
            } else {
                $clean | % $SortBy
            }
        }

    # fd -tf --color=always --base-directory ( gi -ea 'stop' $Path )
    #     | Sort-Object -Descending { $_ | StripAnsi | Get-Item | % $SortBy }
}


function Dotils.Git.AddRecent {
    param(
        [ArgumentCompletions(
            '15minutes', '5minutes', '30seconds', '4hours'
        )]
        [string]$TimeCondition
    )
    [List[Object]]$FdArgs = @(
        '--changed-within'
        $Time
    )
    fd --changed-within 15minutes
    | ?{
        # because early-exit-hotkey causes a non-filepath string to emit
        Test-Path $_ }
    | fzf -m  --expect=q
#| git add
}
# write-warning 'collect b dg .resolve.Timespan'
function Dotils.Clipboard.CopyFileListFromExplorer {
    <#
    .SYNOPSIS
        in explorer, select files, hit ctrl+c then run this command
    #>
    Add-Type -AssemblyName System.Windows.Forms
    $Found =  [System.Windows.Forms.Clipboard]::GetFileDropList() | Get-Item

    if($Found.Count -eq 0) {
        write-warning 'No files found, did you select files then ctrl+c first?'
    }
    return $found
}
function Dotils.To.Type.FromPSTypenames {
    <#
    .SYNOPSIS
        sugar to enumerate
    description
    it started as
        gci . | s -First 3 | %{ $_.pstypenames | %{ $_ -as 'type' } }
    #>
    [Alias(
        '.to.Type.FromPStypes', '.to.PSTypes' , '.to.PStypes'
    )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object[]]$InputObject
    )
    $InputObject
        | %{ $_.PSTypeNames | %{ $_ -as 'type' } }
        | Sort-Object -Unique

}
function Dotils.Format.PathToEnvVars {
    <#
    .SYNOPSIS
        converts an absolute filepath to one using standard Environment Variables
    .EXAMPLE
        > 'C:\Users\jen\Documents\2024' | Dotils.Format.PathToEnvVars
        %UserProfile%\Documents\2024
    .DESCRIPTION
        see also an older version: Dotils.to.EnvVarPath
    .notes
        future:
            - [ ] sort regex replacements by total string length, for the longest possible replacements, first.
            - [ ] to be safer, make sure paths end with '$' or '\' to prevent potential partial matches
            - [ ] fine tune replacement order, like 'CommonProgramFiles' or 'CommonProgramFilesW6432' if they are equal
    .link
        Dotils\Dotils.to.EnvVarPath
    .link
        Dotils.EnvVars.AsMarkdownTable
    #>
    [CmdletBinding()]
    [Alias('Quick.Format.PathToEnvVars')]
    param(
        # filepaths, as string
        [Alias('PSPath', 'Path', 'FullName')]
        [Parameter( ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [string] $PathName
    )
    process {
        Join-String -f 'Input Path: "{0}"' -Inp $PathName | Write-Verbose
        $accum = $_


        $accum = $accum -replace [regex]::Escape( ${Env:MSMPI_BIN} ),           '%MSMPI_BIN%'
        $accum = $accum -replace [regex]::Escape( ${Env:VS120COMNTOOLS} ),      '%VS120COMNTOOLS%'
        $accum = $accum -replace [regex]::Escape( ${Env:VS140COMNTOOLS} ),      '%VS140COMNTOOLS%'

        # for env vars using windows DOS style paths:
        if( $false ) {
            # mode: simple greedy replacement, first replace
            $accum = $accum -replace [regex]::Escape( 'C:\Users\CPPMO_~1\' ), '%UserProfile%\'
            $accum = $accum -replace [regex]::Escape( 'C:\Users\cppmo_000\' ), '%UserProfile%\'
        } else {
            # mode: expand to full, absolute value. allowing even longer env var replacements, below.
            $accum = $accum -replace [regex]::Escape( 'C:\Users\CPPMO_~1\' ), "${Env:UserProfile}\"
            $accum = $accum -replace [regex]::Escape( 'C:\Users\cppmo_000\' ), "${Env:UserProfile}\"
        }
        $accum = $accum -replace [regex]::Escape( $env:TEMP ),          (Join-path $Env:LocalAppData 'temp')
        $accum = $accum -replace [regex]::Escape( $env:TMP  ),          (Join-path $Env:LocalAppData 'temp')

        $accum = $accum -replace [regex]::Escape( ${Env:ProgramFiles(x86)} ),       '%ProgramFiles(x86)%'
        $accum = $accum -replace [regex]::Escape( ${Env:ProgramW6432} ),            '%ProgramW6432%'  # same as ProgramFiles(x86)
        $accum = $accum -replace [regex]::Escape( ${Env:CommonProgramFiles} ),      '%CommonProgramFiles%'
        $accum = $accum -replace [regex]::Escape( ${Env:CommonProgramFiles(x86)} ), '%CommonProgramFiles(x86)%'
        $accum = $accum -replace [regex]::Escape( ${Env:CommonProgramW6432} ),      '%CommonProgramW6432%'

        $accum = $accum -replace [regex]::Escape( $env:LocalAppData ),  '%LocalAppData%'
        $accum = $accum -replace [regex]::Escape( $env:AppData ),       '%AppData%'
        $accum = $accum -replace [regex]::Escape( $env:UserProfile ),   '%UserProfile%'
        $accum = $accum -replace [regex]::Escape( $env:ProgramData ),   '%ProgramData%'
        $accum = $accum -replace [regex]::Escape( $env:ALLUSERSPROFILE ),   '%ALLUSERSPROFILE%' # same as ProgramData
        $accum = $accum -replace [regex]::Escape( $env:SystemRoot ),   '%SystemRoot%'
        # $accum = $accum -replace [regex]::Escape( $env:OneDrive ),  '%OneDrive%' # skip because of appdata
        return $accum
    }
}

# old names: function Format-HumanizeFileSize # Dotils.Write-FormatHumanSize
function Dotils.EnvVars.AsMarkdownTable {
    <#
    .SYNOPSIS
        Export env vars as markdown table. quick / awkward implementation, but worked.
    .EXAMPLE
        Pwsh> Dotils.EnvVars.AsMarkdownTable -ReplaceEnvVars
    #>
    [OutputType( [string] )]
    param(
        # Default value is 'Gci Env:' filtered to include filepaths only
        [object[]] $InputObject,

        # skip replacing absolute path with env var paths?
        [Alias('PassThru')]
        [switch] $WithoutReplaceEnvVars
    )
    <# orig version:
    $InputObject | %{ $_.Key, $_.value | Join-String -sep ' | '
            | Join-String -f "| {0} |`n"  } | Join-string -sep ""
    #>
    filter _private_fmt_EnvVar_Substitute {
        <#
        .EXAMPLE
            > 'C:\Users\jen\Documents\2024' | _private_fmt_EnvVar_Substitute
            %UserProfile%\Documents\2024
        #>
        $accum = $_
        throw 'ReplaceBy: Dotils.Format.PathToEnvVars'
        # for env vars using windows DOS style paths:
        if( $false ) {
            # mode: simple greedy replacement, first replace
            $accum = $accum -replace [regex]::Escape( 'C:\Users\CPPMO_~1\' ), '%UserProfile%\'
            $accum = $accum -replace [regex]::Escape( 'C:\Users\cppmo_000\' ), '%UserProfile%\'
        } else {
            # mode: expand to full, absolute value. allowing even longer env var replacements, below.
            $accum = $accum -replace [regex]::Escape( 'C:\Users\CPPMO_~1\' ), "${Env:UserProfile}\"
            $accum = $accum -replace [regex]::Escape( 'C:\Users\cppmo_000\' ), "${Env:UserProfile}\"
        }
        $accum = $accum -replace [regex]::Escape( $env:LocalAppData ), '%LocalAppData%'
        $accum = $accum -replace [regex]::Escape( $env:AppData ), '%AppData%'
        $accum = $accum -replace [regex]::Escape( $env:UserProfile ), '%UserProfile%'
        return $accum
    }
    function _writeMarkdownRow {
        # a,b,c: renders: '| a | b | c |'
        # $_ | Join-String -sep ' | '
        #    | Join-String -f "| {0} |`n"
        return $Input
            | Join-String -sep ' | '
            # | Join-String -f "| {0} |`n"
            | Join-String -f '| {0} |'
    }
    function _writeMarkdownHeader {
        # [OutputType( [string] )]
        # param( [string[]] $HeaderNames )
        $HeaderNames = @( $Input )
        return @(
            $HeaderNames | _writeMarkdownRow
            ( '-' * $HeaderNames.count -split '').
            Where({$_}) | _writeMarkdownRow
        ) | Join-String -sep "`n"
    }
    $InputObject ??=
        gci env:
            | ?{ Test-Path $_.Value }
            | Sort-Object Value

    @(
        'Env Var', 'Path' | _writeMarkDownHeader | Join-String
        $InputObject
            | %{
                if( $WithoutReplaceEnvVars ) {
                    @(
                        $_.Key
                        $_.Value | Join-String -DoubleQuote
                    )
                        | _writeMarkdownRow
                } else {
                    @(
                        $_.Key;
                        $_.Value
                            | Dotils.Format.PathToEnvVars
                            | Join-String -DoubleQuote
                    )
                    | _writeMarkdownRow
                }
            }
            | Join-String -sep "`n" -op "`n"
    )
    | Join-String -sep ''
}
function Dotils.Select.Error.FromUGit {
    <#
    .SYNOPSIS
        filter out errors, specifically finding ugit error records based on pstypenames
    #>
    param(
        # $Error instance
        [Parameter(Mandatory, Position = 0)]
        [Alias('InputObject')]
        $ErrorObject,

        # Regex of the pstypenames to search for. ( Most permissive first)
        [Parameter(Mandatory, Position = 0)]
        [Alias('PSTypeName')]
        [ArgumentCompletions( "'git\..*\.error'", "'git\.error'", "'git\.clone\.error'" )]
        [string] $RegexFilterUgitTypeName
    )
    return $ErrorObject
        | Where-Object {
            ($_.PSTypeNames -match $RegexFilterUgitTypeName).count -gt 0
        }
}

function Dotils.Flatten.ExceptionMessage {
    <#
    .SYNOPSIS
        input is an $Error, serializes as JSON
    #>
    [OutputType( [string] )]
    param( $ErrorRecord )

    write-warning 'wip: this worked in the console, but not module'
    # $ErrorRecord ??=  $global:Error
    $select_Splat = @{
        ErrorAction = 'ignore'
        Property    = 'FullyQualifiedErrorId', 'CategoryInfo', 'Exception', 'TargetObject', 'ScriptStackTrace'
    }

    $ErrorRecord | Select-Object @select_Splat
        | ConvertTo-Json -Depth 2 -Compress -wa 'ignore'
}

function Dotils.Render.Error.AllErrorsToMarkdownPreview {
    <#
    .SYNOPSIS
        exports your $errors to a markdown file with navigation, and lots of expanded info
    .EXAMPLE
        Dotils.Render.Error.AllErrorsToMarkdownPreview
    #>
    [CmdletBinding()]
    param(
        # try $Global:error
        [ArgumentCompletions('$global:Error', '$Error')]
        # [Parameter(Mandatory)]
        $InputError,

        [ArgumentCompletions(
            "(Join-Path (gi temp:) 'render_error.md'"
        )]
        # [string] $OutputPath = ('temp:\render_error.md')
        [string] $OutputPath = (Join-Path (gi temp:) 'render_error.md'),

        [switch]$AutoOpenVsCode
    )
    $InputError ??= $Global:Error
    if( -not $PSBoundParameters.ContainsKey('InputError') ) {
        $InputError = $Global:Error
    }
    if( $InputError.count -le 0 ) {
        throw "Input Error had no records"
    }

    $OutputPath
        | Join-String -f 'Writing to: "{0}"' | Write-Verbose

    $curId = 0

<#
future:
    [string] $TableOfContents = @'
'@

example:
    - [Top](#top)
    - [Environment](#environment)
    - [ErrorNum: 0](#errornum-0)
        - [CommandLine](#commandline)
        - [StackTrace](#stacktrace)
        - [Get-Error](#get-error)
        - [Format-List force](#format-list-force)
    - [ErrorNum: 1](#errornum-1)
        - [CommandLine](#commandline-1)
        - [StackTrace](#stacktrace-1)
        - [Get-Error](#get-error-1)
        - [Format-List force](#format-list-force-1)
    - [ErrorNum: 2](#errornum-2)
        - [CommandLine](#commandline-2)
        - [StackTrace](#stacktrace-2)
        - [Get-Error](#get-error-2)
        - [Format-List force](#format-list-force-2)
#>



[string] $MainHeader = @'
## Top

## Environment

```yml
Generated at: {0}
PSVersion: {3}
Cwd: {1}
Host: {2}
Parents: {5}
Modules: {4}

## Errors
```
'@ -f @(
    # [0] Dt
    [Datetime]::Now.ToString('u')
        | Join-String -SingleQuote

    # [1] Cwd
    (Get-Location).ToString()
        | Join-String -SingleQuote

    # [2] Host
    $Host.Name

    # [3] PsVersion
    $PSVersionTable.PSVersion.ToString()

    # [4] module names, no module version
    if($true) {
        (gmo)
            | Sort-Object
            | Join-String {
                $_.Name, $_.Version | Join-String -sep ': '
            } -f "`n- '{0}'"
    } else {
        (gmo)
            | Sort-Object
            | %{
                [pscustomobject]@{
                    Name = $_.Name ;
                    Version = $_.Version.ToString();
                }
            }
            | ConvertTo-Yaml
            | Join-String -sep "`n"

    }
    # [5] Parent process name chain
    @(  (ps -ea 'ignore' -Pid $PID)
        (ps -ea 'ignore' -Pid $PID).Parent
        (ps -ea 'ignore' -Pid $PID).Parent.Parent
        (ps -ea 'ignore' -Pid $PID).Parent.Parent.Parent
        (ps -ea 'ignore' -Pid $PID).Parent.Parent.Parent.Parent
        (ps -ea 'ignore' -Pid $PID).Parent.Parent.Parent.Parent.Parent
    )
        | %{ $_ | Select ProcessName, *Id* | Json -Depth 1 -Compress }
        | Join-String -f "`n  - '{0}'"

)
[string] $MainFooter = @'

end
'@

    $fStr = @'

### ErrorNum: {0}

[Back to Top](#top)

Duration: {1}

**Error**:
```ps1
{2}
```

#### CommandLine

```ps1
{3}
```

#### StackTrace
```
{6}
```

#### Get-Error

```ps1
{4}
```

#### Format-List force

```ps1
{5}
```



'@
    $origStyle = $PSStyle.OutputRendering
    $PSStyle.OutputRendering = 'PlainText'


    $global:Error[0..1000] | %{
        $cur = $_
        [string] $renderErr = $cur
            | Get-Error | Out-String
            | Join-String -sep "`n"
            | StripAnsi

        $curHistory =
            if( -not $cur.InvocationInfo.HistoryId ) {
                $null
            } else {
                Get-History -Id $cur.InvocationInfo.HistoryId
            }

        $fstr -f @(
                # [0] err number
                ($curId++)

                # [1] duration
                ($curHistory.Duration.TotalSeconds)?.ToString('f2') ?? '<missing>'
                    | Join-String -f '{0} secs'


                # [2] Error exception as string
                ($cur.Exception)?.ToString() ?? '<none>'

                # [3] CommandLine
                $curHistory.CommandLine ?? '<missing>'

                # [4] render Get-Error
                $renderErr ?? '<none>'

                # [5] Format-list -force
                ( $cur | Format-List * -Force
                    | out-string -Width 1kb ) ?? '<none>'

                # [6] StackTrace
                ($cur.ScriptStackTrace
                    | StripAnsi ) ?? '<none>'
        )
    }
        | Join-String -op $MainHeader -os $MainFooter
        | Set-Content -Path $OutputPath

    $PSStyle.OutputRendering = $origStyle

    $OutputPath
        | Join-String -f 'Wrote "{0}"'
        | Write-Host -fg 'salmon'

    if( $AutoOpenVsCode ) {
        code -g (  gi -ea 'stop' $OutputPath)
    }
}

function Dotils.Format.HexLiteral  {
    <#
    .SYNOPSIS
        converts numerics into hex literals (strings)
    .EXAMPLE
        > 2, 9, 123, 4 | HexLiteral -Verbose -NumDigits 8 -Separator '-' -NoEnumerate
        # output: 00000002-00000009-0000007b-00000004
    .EXAMPLE
        > 2, 9, 123, 4 | HexLiteral -NumDigits 3 -Separator ' ' -NoEnumerate -Prefix '0x'
        # output: 0x002 0x009 0x07b 0x004
    .EXAMPLE
        > $nums = 3, 10kb, 99, 0x23245
        > $nums | HexLiteral
        > $nums | HexLiteral -Digits 8
        > $nums | HexLiteral -Separator ''
    #>
    [OutputTYpe( [string] )]
    [Alias('HexLiteral', 'Quick.HexLit')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
            [object[]] $InputObject,

        [ArgumentCompletions( "' '", "''", "', '" )]
        [string] $Separator = ' ',

        # the minimum number
        [Alias('Digits')]
        [int] $NumDigits = 2,

        [ArgumentCompletions("'0x'", "''")]
        [string] $Prefix = '',

        # if specified, has priority over NumDigits and Prefix. Separator is kept.
        [ArgumentCompletions(
            "'{0:x2}'", "'0x{0:x2}'",
            "'{0:X6}'"
        )]
        [string]$FormatString = "'0x{0:x2}'",

        # collect all items, piping to join-string as one object
        [switch] $NoEnumerate
    )
    begin {
        # ex: $FStr = '0x{0:x2}'
        if( $PSBoundParameters.ContainsKey('FormatString') ) {
            $FStr = $FormatString
        } else {
            $FStr = "${Prefix}", '{0:x', "${NumDigits}", '}' | Join-String
        }
        "FStr: $FStr" | Write-verbose

        [List[Object]] $Collected = @()
    }
    process {
        if( -not $NoEnumerate ) {
            return $InputObject
                | Join-String -f $FStr -sep $Separator
        }
        $Collected.AddRange(@( $InputObject ))
    }
    end {
        if( -not $NoEnumerate ) { return }
        return $Collected | Join-String -f $FStr -sep $Separator
    }
}

function Dotils.Format.HumanizeFileSize {
    <#
    .synopsis
        Convert integer bytes into a humanized abbreviated strings  ( added: 2024-07 )
    .notes
        new: 2024-07-10

        Pwsh 6.2 and 7 added additional units: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_numeric_literals?view=powershell-7.4#integer-literals>
    .example
        pwsh> Format-HumanizeFileSize 1.234kb
            1.2 KB

        pwsh> Format-HumanizeFileSize 1.234kb -Digits 5
            1.23438 KB
    .example
        pwsh> 12.45gb, .9mb, 91231451, 2 | Format-HumanizeFileSize | Join-string -sep ', '
            12.5 GB, 921.6 KB, 87.0 MB, 2.0 b
    #>

    [Alias(
        'Dotils.Write-FormatHumanSize', # this is the command name of what was renamed to 'Dotils.Write-FormatHumanSize.old'
        'Dotils.Fmt.HumanFileSize' # 'FormatFilesize' # 'Format-HumanizeFileSize'
    )]
    [OutputType( [String]) ]
    param(
        # Size in bytes. future could include [uint64]. I used [long] because pwsh 5.1 and 7 use that
        [Parameter( Mandatory, ValueFromPipeline)]
        [long[]] $SizeInBytes,

        # 0-to-number of digits after the decimal
        [Parameter()]
        [int] $Digits = 1
    )

    # example final template string:
        # '{0:n2} TB'
    process {
        $Prefix = '{0:n', $Digits, '}' -join ''
        foreach($Item in $SizeInBytes) {
            switch( $Item) {
                # outer bounds
                { $_ -lt 1kb } { "$Prefix b" -f $_ ; break}
                { $_ -ge 1pb } { "$Prefix PB" -f ($_ / 1pb) ; break}
                # rest
                { $_ -ge 1tb } { "$Prefix TB" -f ($_ / 1tb) ; break}
                { $_ -ge 1gb } { "$Prefix GB" -f ($_ / 1gb) ; break}
                { $_ -ge 1mb } { "$Prefix MB" -f ($_ / 1mb) ; break}
                { $_ -ge 1kb } { "$Prefix KB" -f ($_ / 1kb) ; break}
                default {
                    # break should be redundant, and this should too, unless there's a logic error
                    throw "ShouldNeverReachCase: $SizeInBytes"
                }
            }
        }
    }
}

function Dotils.Example.DateTime-FormatStrings {
    <#
    .SYNOPSIS
        Show Format strings and results as a quick example. Using [Datetime]::Now.ToString and [Datetime]::Now.ToUniversalTime().ToString
    #>
    [CmdletBinding()]
    param()

    $Now = [Datetime]::Now
    hr
    'Uni   ▸ u'
    $Now.ToUniversalTime().ToString('u') | Join-String -f "    {0}`n"
    'Local ▸ u'
    $Now.ToString('u') | Join-String -f "    {0}`n"

    'Uni   ▸ o'
    $Now.ToUniversalTime().ToString('o') | Join-String -f "    {0}`n"
    'Local ▸ o'

    $Now.ToString('o') | Join-String -f "    {0}`n"
    'Uni   ▸ O'
    $Now.ToUniversalTime().ToString('O') | Join-String -f "    {0}`n"
    'Local ▸ O'

    $Now.ToString('O') | Join-String -f "    {0}`n"
    'Uni   ▸ U'
    $Now.ToUniversalTime().ToString('U') | Join-String -f "    {0}`n"
    'Local ▸ U'
    $Now.ToString('U') | Join-String -f "    {0}`n"
    hr
}
function Dotils.Format.NumberedList {
    <#
    .SYNOPSIS
        Like the linux command 'nl' with property support
    .EXAMPLE
        Pwsh🐒> 'a'..'d' | Format.NumberedList

        Pwsh🐒> Get-process pwsh | Fmt.NL -PropertyName id | Join-String -sep ', '

            1: 2544, 2: 5584, 3: 12068, 4: 17584, 5: 19916, 6: 25344, 7: 25664, 8: 32328

    .EXAMPLE
        Pwsh🐒> 'a'..'d' | Format.NumberedList

            1: a
            2: b
            3: c
            4: d
    .example
        Pwsh🐒> Get-Process  pwsh | Format.NumberedList Id
            1: 11692
            2: 17584
            3: 25664

        Pwsh🐒> Get-Process  pwsh | Format.NumberedList Name
            1: pwsh
            2: pwsh
            3: pwsh

        Pwsh🐒> Get-Process  pwsh | Format.NumberedList

            1: System.Diagnostics.Process (pwsh)
            2: System.Diagnostics.Process (pwsh)
            3: System.Diagnostics.Process (pwsh)
    .EXAMPLE
        Pwsh🐒>

            'a'..'d' | Format.NumberedList
            # hr
            Get-process pwsh | Fmt.NL -PropertyName id | Join-String -sep ', '
            # hr
            Get-Process  pwsh | Fmt.NL Id

            # hr
            gci . -File | select -first 6 | Fmt.NL -PropertyName Name
            # hr
            gci . -File | select -first 6 | Fmt.NL -PropertyName Extension
            # hr

            # Silly example that outputs a numbered list of numbered strings

            Get-Process
                | Group-Object Name | Sort-Object Count
                | ?{ $_.count -gt 1 }
                | %{ @(
                    $_.Name
                    $_.Group
                        | Fmt.NL id
                        | Join-String #-sep '' -SingleQuote
                ) | Join-String -sep ' => ' } | Fmt.NL
    #>
    [OutputType('System.String')]
    [Alias('Fmt.NL'
        # , 'NL'
    )]
    param(
        [ArgumentCompletions('Name', 'FullName', 'Extension', 'Path')]
        [string]$PropertyName
    )
    $Input | Foreach-Object {
        $LineNo++

        $Value = if($PropertyName) {
            $_.$PropertyName
        } else { $_ }

        "${lineNo}: {0}" -f $Value
    }
}

function Dotils.Resolve.Ast {
    <#
    .synopsis
        using crazy parameter list, to inspect type relations verses one object param
    #>
    # nyi: future: todo: make this arg transformation
    [Alias('Resolve.Ast')]
    [CmdletBinding(DefaultParameterSetName='AsObject')]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            ParameterSetName='AsObject')]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'AsAst')]
        [Management.Automation.Language.Ast]
        $Ast,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'AsFunctionDefinitionAst')]
        [Management.Automation.Language.FunctionDefinitionAst]
        $FunctionDefinitionAst,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'AsScriptblock')]
        [Management.Automation.ScriptBlock]
        $ScriptBlock,

        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -OtherHash $Options -BaseHash @{
            JsonLogging = $false
        }
    }
    process {

        if($Config.JsonLogging) {
            $PSCmdlet.MyInvocation.BoundParameters
                | ConvertTo-Json -Depth 0 -Compress
                | Join-String -op 'Func: '
                | write-verbose -Verbose

        }

        $PSBoundParameters.Keys
            | Join-String -op 'PSBoundparameters: ' -sep ', '
            | write-verbose -Verbose
        $PSCmdlet.ParameterSetName
            | Join-String -op 'ParameterSet: '
            | write-verbose -Verbose


        switch ($PSCmdlet.ParameterSetName) {
            'AsAst' {
                write-debug '  switch => AsAst'
                return $Ast
            }
            'AsScriptblock' {
                write-debug '  switch => AsScriptBlock'
                return $ScriptBlock.Ast
            }
            'FunctionDefinitionAst' {
                write-debug '  switch => FunctionDefinitionAst'
                [Management.Automation.Language.ScriptBlockAst]$Body =
                    $InputObject.Body
                <# contains
                    Body   [ScriptBlockAst]
                    Extent [IScriptExtent]
                    Name   [string]
                    Parent [Ast]

                [body]: The body of the function. This property is never null.
                #>
                'found: {0}' -f @( $Body | Format-SHorttypename ) | write-verbose
                if($Body) {
                    return $Body
                }
                break
            }
            # 'AsCommand' { #
            #     return $InputObject.ScriptBlock.Ast
            # }
            default {
                write-debug '  switch: => default'
                if($InputObject | .Has.Prop Ast Exists -AsTest) {
                    return $InputObject.Ast
                }
                if($InputObject | .Has.Prop ScriptBlock Exists -AsTest) {
                    return $InputObject.ScriptBlock.Ast
                }
                $exception = [Exception]::new(
                    <# message: #> ('Could not resolve [Ast] from object type {0} and ParameterSet: {1}' -f @(
                        $InputObject | Format-ShortTypeName
                        $PSCmdlet.ParameterSetName
                    )), <# innerException: #> $null)
                $PSCmdlet.WriteError(
                    [System.Management.Automation.ErrorRecord]::new(
                        <# exception: #> $exception,
                        <# errorId: #> 'InputObjectTransformFailed',
                        <# errorCategory: #> ([System.Management.Automation.ErrorCategory]::InvalidType),
                        <# targetObject: #> $InputObject))

                # throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName for )"
            }

        }
    }
}


function Dotils.Help.FromType {
    <#
    .SYNOPSIS
        try to find help on the type of the object
    .notes

        needs some cleanup when generics are involved.
    see also:
        Format-ShortTypeName
    .link
        Ninmonkey.Console\Format-ShortTypeName
    #>
    [Alias('Help.FromType')]
    param(
        # print url to console instead of opening the browser
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object[]]$InputObject,

        [Alias('PStypes')][switch]$IncludePSTypenames,

        [switch]$PassThru
    )
    begin {
        # This is so can pipe any count of items from the user
        # and we won't spam him without duplicate results.
        # imagine opening 100 tabs in one go.
        [Collections.Generic.List[Object]]$items = @()
    }
    process {
        $items.AddRange(@( $InputObject ))
    }
    end {
        # try to resolve the type of an object, whether it's an object
        # a type info, or even the string of a type
        $template_url = 'https://docs.microsoft.com/en-us/dotnet/api/{0}'

        $types = @(
            $items | % GetType
            if($IncludePSTypenames) {
                write-warning 'coerce to type, or leave as strings here?'
                $Items | ?{
                    $_.PSTypeNames
                }

            }
        ) | Sort-object -unique


        $types | %{
            $cur = $InputObject
            if( $cur -is 'type') {
                $typeInfo = $cur
            } elseif ( $cur -is 'string' -and  $cur -as 'type' ) {
                $typeInfo = $cur -as 'type'
            } else {
                $typeInfo = $cur.GetType()
            }

            $render_url = $template_url -f @(
                $typeInfo.FullName
            )
            if($PassThru) {
                return $render_url
            }
            Start-Process -path $render_url
        }
    }
}

function Dotils.Query.Save {
    <#
    .SYNOPSIS
        save/load queries to a hashtable, showing metrics like length on use
    .EXAMPLE
        # comparing results of ast queries interactively
        Dotils.qs 'root_all_recurse' (
            $root.EndBlock.FindAll( {param($Ast, $b) $true}, $true)
        )
        Dotils.qs 'root_all' (
            $root.EndBlock.FindAll(    {param($Ast, $b) $true}, $false)
        )
#>
    [Alias('Dotils.qs', 'qs')]
    param(
        [string]$Name,
        [object]$Data
    )
    $state = $script:QuerySave
    $state[ $Name ] = $Data | CountOf -CountLabel $Name
}
function Dotils.Query.Load {
    <#
    .SYNOPSIS
        save/load queries to a hashtable, showing metrics like length on use
    .EXAMPLE
        # comparing results of ast queries interactively
        Dotils.qs 'root_all_recurse' (
            $root.EndBlock.FindAll( {param($Ast, $b) $true}, $true)
        )
        Dotils.qs 'root_all' (
            $root.EndBlock.FindAll( {param($Ast, $b) $true}, $false)
        )
    #>
    [Alias('Dotils.ql', 'ql')]
    param(
        # returns  the entire table
        [switch]$All,
        [string]$Name
    )
    $state = $script:QuerySave
    if($All){
        $state.keys | CountOf -CountLabel '$QuerySave keys'
        return $state
    }
    if(-not $state.Keys.Contains($Name)) { throw ('key {0} does not yet exist' -f $Name) }
    return $state[$Name] | CountOf -CountLabel $Name
}

function Dotils.Format-ShortNamespace {
    <#
    .SYNOPSIS
        shorten namespaces. optional full raw replace verses using crumb counts.
    .NOTES
        Lots of output added if you use -Debug -Verbose
        either through config, or -MinCount lets you toggle forcing non-blank ending  string

    .example
        [System.Text.Encoding] | fmt.ShortNamespace -MinCount 0
            Encoding
            # or could be blank, depending on namespace list

        [System.Text.Encoding] | fmt.ShortNamespace -MinCount 1
            Encoding

        [System.Text.Encoding] | fmt.ShortNamespace -MinCount 2
            Text.Encoding

    .EXAMPLE
        DbgTool.ModuleHasChanged -ModuleName Bintils -AutoLoad
        hr -fg orange

        [List[System.IO.FileSystemInfo]]$files = gci .
        [ast]   | Fmt.ShortType  | Label '[Ast]'
        ,$files | Fmt.ShortType  | Label 'files[]'
        $files[0] | Fmt.ShortType| Label 'files[0]'
        ,$files|Fmt.ShortType

        ( $dint = [Dictionary[int,string]]::new() ) | Fmt.ShortType
    #>
    [CmdletBinding()]
    [OutputType('String')]
    [ALias(
        'Dotils.Fmt.ShortNamespace',
        'Fmt.ShortNamespace'
    )]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Namespace')]
        $InputObjectOrType,

        # Should short namespace always include N segments?
        [ArgumentCompletions(0, 1, 2, 3)]
        [int]$MinCount,

        # [ValidateSet('FullName', 'Name', 'Generic')]
        [ArgumentCompletions(
            "@{ EnableRequireMinCrumbCount = `$true; MinSegmentCount = 1; StripNamespaces = 'System', 'System.Text' }"
        )]
        # [string]$Template = 'FullName',
        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -Other $Options -BaseHash @{
            # CoerceTypeNames = $true
            # StripNamespaces_OnFullString = $True
            EnableRequireMinCrumbCount = $false
            MinSegmentCount =  1
            StripNamespaces = @(
                'System.Management.Automation.Language'
                'System.Management.Automation'
                'System.Collections.Generic'
                'Collections.Generic'
                'System.Management'
                'System.IO'
                'System'
            ) | Sort-Object { $_.Length } -descending
        }
        if($PSBoundParameters.ContainsKey('MinCount')) {
            if( $MinCount -le 0 ) {
                $Config.EnableRequireMinCrumbCount = $false
            } else {
                $Config.EnableRequireMinCrumbCount = $true
                $Config.MinSegmentCount = $MinCount
            }
        }
        'MinSegmentCount: {0}, StripNames: {1}' -f @(
            $Config.MinSegmentCount

            $Config.StripNamespaces | Join-string -sep ', ' -single
        ) | Write-Verbose
    }
    process {
        $Obj = $InputObjectOrType
        if($null -eq $Obj) { return $Null }
        if('' -eq $Obj) { return '' }
        [string]$Namespace = ''

        if($Obj -is [Type]) {
            $namespace = $Obj.Namespace
        } elseif( $Obj -is [string] ) {
            $AsType? = $Obj -as [type]
            if($AsType? -is [type]){
                $namespace = $AsType?.Namespace
            } else {
                $namespace = $Obj
            }
        } else {
            $namespace = ($Obj)?.GetType().Namespace
        }
        if( [string]::IsNullOrWhiteSpace( $namespace )) {
            throw ("ShouldNeverReachException!, Namespace was blankable. Type: '{0}', Len: {1}" -f @(
                ($Obj)?.GetType().Name
                ($Obj).Length ?? 0
            ))
        }
        $meta = [ordered]@{
            RequireMinSegmentCount  = $Config.MinSegmentCount
            EnableRequireMinCrumbCount = $Config.EnableRequireMinCrumbCount
            OriginalName = $Namespace
            OriginalSegmentCount = ($Namespace -split '\.').count
            FinalName = ''
        }
        if([string]::IsNullOrWhiteSpace( $Namespace)) { throw "ShouldNeverReachException: Namespace evaluated to a blank"}

        $namespace.length
            | Join-String -f 'strlen: namespace: {0}'
            | Write-debug

        $NamespaceCrumbs = @($Namespace -split '\.')

        [string]$render = $Namespace
        foreach($toStrip in $Config.StripNamespaces) {
            'render := {0} [ len {1} ]' -f @(
                $render #?? ''
                $render.Length ?? 0
            )
                | Dotils.Write-DimText | Join-String -op 'iter '
                |  Write-debug

            $pattern = '^{0}$' -f $ToStrip

            'toStrip: {0}' -f @(
                $pattern
            )
            | Write-debug

            $render = $render -replace $pattern, ''
        }
        $meta.FinalName = $render

        if($render -match '\.') {
            [int]$finalSegmentCount = ($render -split '\.').count
        } else {
            [int]$finalSegmentCount  = 0
        }
        $meta.FinalSegmentCount = $finalSegmentCount


        if( $Config.EnableRequireMinCrumbCount -and (
            $finalSegmentCount -lt $Config.MinSegmentCount
        )) {
            'MinCount on, count <= MinSegmentCount' | write-debug
            # $allowdCrumbCount = [Math]::Min( $namespaceCrumbs.count, $Config.minSegmentCount )
            $render = $namespaceCrumbs | Select -last $Config.MinSegmentCount
                | Join-String -sep '.'
            # $wantedCrumbs
            $meta.FinalCrumbName = $render

            [int]$finalMinCrumbsCount = ($render -split '\.').count
            $meta.FinalCrumbsSegmentCount = $finalMinCrumbsCount

        }
        $meta
            | Json -Compress:$false -depth 2
            | Dotils.Write-DimText
            | Join-string -op 'Format-ShortNamespace: ' | write-verbose
        return $render
    }
}
function Dotils.Test-IsBlank {
    <#
    .SYNOPSIS
        quicky test whether something is null, empty string, or other blankable values

    .DESCRIPTION
        If a string contains text, but it's all invisible or all control chars, then it's considered blank.
    .EXAMPLE
        Pwsh🐒>
            Test-IsBlank '' -AsBool    # true
            Test-IsBlank "`n" -AsBool  # true
            Test-IsBlank $null -AsBool # true
            Test-IsBlank "`n3" -AsBool # false
    .EXAMPLE
        Pwsh🐒>
            $something = [pscustomobject]@{ # sample properties to test
            Name = 'bob'
                ExistingBlankProp = ''
                ExistingNullProp  = $null
            }

            Test-IsBlank $something.Name -AsBool              # false
            Test-IsBlank $something.ExistingBlankProp -AsBool # true
            Test-IsBlank $something.ExistingNullProp  -AsBool # true

            @( Test-IsBlank $something.Name
            Test-IsBlank $something.ExistingBlankProp
            Test-IsBlank $something.ExistingNullProp  ) | ft -AutoSize

        # outputs
            IsTrueNull IsEmpty IsTrueEmptyStr IsBlank     Length RawValue AsBool
            ---------- ------- -------------- -------     ------ -------- ------
                False   False          False   False           3 bob       False
                False    True           True    True  <EmptyStr>            True
                True    True          False    True       <null>            True

    #>
    param( $Obj, [switch]$AsBool )
    $filtered = $Obj -replace "`a", '' # otherwise ascii bell is not "whitespace"
    if($AsBool) {
       return [string]::IsNullOrWhiteSpace( $filtered )
    }

    $isTrueNull     = $Null -eq $Obj
    $isStr          = $Obj -is [String]
    $isTrueEmptyStr = $isStr -and ($Obj.Length -eq 0)

    $finalLength = if(-not $IsTrueNull) { $Obj.ToString().Length }
    if($isTrueEmptyStr) { $finalLength = '<EmptyStr>' }
    if($IsTrueNull)     { $finalLength = '<null>'     }

    [pscustomobject]@{
        IsTrueNull     = $isTrueNull
        IsEmpty        = [string]::IsNullOrEmpty( $Obj )
        IsTrueEmptyStr = $isTrueEmptyStr
        IsBlank        = [string]::IsNullOrWhiteSpace( $filtered )
        Length         = $finalLength
        RawValue       = $Obj
        AsBool         = [string]::IsNullOrWhiteSpace( $filtered )
    }
}
function Dotils.Format-ShortenWhitespace {
    <#
    .SYNOPSIS
    minimal shorten whitespace to a single line, and colorize whitespace (after collapsing)
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('Line', 'Text', 'String', 'Str', 'InStr', 'InText', 'InputObject')]
        [string]$InputText
    )
    process {
        $SP = '␠' | New-Text -bg 'gray50' -fg 'gray80' | Join-string -op $PSStyle.Reset
        $SP = '␠' | New-Text -bg 'gray30' -fg 'gray60' | Join-string -op $PSStyle.Reset
        $NL = '␊' | New-Text -bg 'gray20' -fg 'gray40' | Join-string -op $PSStyle.Reset
        $InputText -replace '(\r?\n)+', $NL -replace '\s+', $SP
    }
}

function Dotils.Format-ShortType {
    <#
    .SYNOPSIS
        shorten type names
    .LINK
        Dotils.Format-ShortType
    .LINK
        Dotils.Format-ShortNamespace
    .EXAMPLE
        ,[List[datetime]]::new() | Dotils.Format-ShortType

            [List`1<DateTime>]

        ,[List[datetime]]::new() | Dotils.Format-ShortType -MinNamespaceCrumbCount 99

            [Collections.Generic.List`1<DateTime>]

    .EXAMPLE
        $nested_tin =
            [Dictionary[
                [string],
                [Dictionary[int,datetime]]  ]]


        $nested_tin| Dotils.Format-ShortType -MinNamespaceCrumbCount 1
            [Generic.Dictionary`2<String, Dictionary`2<Int32, DateTime>>]

        $nested_tin| Dotils.Format-ShortType -MinNamespaceCrumbCount 3
            [System.Collections.Generic.Dictionary`2<String, Dictionary`2<Int32, DateTime>>]

    #>
    [CmdletBinding()]
    [OutputType('String')]
    [ALias(
        'Dotils.Fmt.ShortType',
        'Fmt.ShortType'
    )]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObjectOrType,

        [ValidateSet('FullName', 'Name', 'RawName', 'RawFullName')]
        [string]$Template = 'FullName',

        [Alias('MinNamespaceCount')]
        [int]$MinNamespaceCrumbCount,

        [ArgumentCompletions(
            "@{ StripNamespaces_OnFullString = `$false }",
            "@{ IncludeBrackets = `$false }"
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -Other $Options -BaseHash @{
            IncludeBrackets = $true # future: nested verses final ?
            CoerceTypeNames = $true
            MinNamespaceCount = 0
            StripNamespaces_OnFullString = $True
            StripNamespaces = @(
                'System.Management.Automation.Language'
                'System.Management.Automation'
                'Microsoft.Powershell'
                # 'Collections.Generic'
                # 'System.Management'
                'System'
            )
            <# warning, to extend:

                currently
                    Microsoft.PowerShell.PSConsoleReadLine+HistoryItem => [HistoryItem]
                instead it should be:
                    PSConsoleReadLine+HistoryItem
            #>
        }
        if($PSBoundParameters.ContainsKey('MinNamespaceCrumbCount')) {
            $Config.MinNamespaceCount = $MinNamespaceCrumbCount
        }

    }
    process {
        $Obj = $InputObjectOrType
        if($Obj -is 'string') {
            if( -not $Config.CoerceTypeNames ) {  throw "InvalidParam, Expects type or instance" }
            $tinfo = $Obj -as [type]
        }
        elseif ($Obj -is [type] ) {
            $tinfo = $Obj
        } else {
            $tinfo = $Obj.GetType()
        }
        [bool]$isGeneric = $tinfo.IsGenericType

        [string]$render = ''
        $nestedConfig = nin.MergeHash -BaseHash $Config -OtherHash @{
            IncludeBrackets = $false
        }


        switch($Template) {
            'Name' {
                # $dint.GetType() | Join-String -p {
                #     $IsaGen = $_.IsGenericType
                #     $_.Namespace
                #     $_.Name
                #     $IsaGen ? '[' : ''
                #     $_.GenericTypeArguments
                #         | Fmt.ShortType
                #         | Join-String -sep ', ' -op '<' -os '>'
                #     $IsaGen ? ']' : ''
                #     }
                #     System.Collections.Generic Dictionary`2 [ <[Int32], [String]> ]
                # $render = $tinfo | Dotils.Format-ShortType -Template 'RawName'

                # $ns = $tinfo.Namespace | Dotils.Format-ShortNamespace  -MinCount 0
                $ns = ''
                $name = $tinfo.Name
                $render =  @(
                    if ($ns.length -gt 0){
                        $ns
                    }
                    $Name
                ) -join '.'

                if($Tinfo.IsGenericType) {
                    $render +=
                        $tinfo.GenericTypeArguments
                            | Dotils.Format-ShortType -Options $nestedConfig
                            # | Fmt.ShortType -Options @{
                            #     StripNamespaces = $Config.StripNamespaces
                            #     IncludeBrackets = $false } -Template $Template
                            | Join-String -sep ', ' -op '<' -os '>'

                }
            }
            'FullName' {
                $ns = $tinfo.Namespace | Dotils.Format-ShortNamespace -MinCount $Config.MinNamespaceCount
                $name = $tinfo.Name
                $render =  @(
                    if ($ns.length -gt 0){
                        $ns
                    }
                    $Name
                ) -join '.'

                if($Tinfo.IsGenericType) {
                    $render +=
                        $tinfo.GenericTypeArguments
                            | Dotils.Format-ShortType -Options $nestedConfig
                            # | Fmt.ShortType -Options @{
                            #     StripNamespaces = $Config.StripNamespaces
                            #     IncludeBrackets = $false } -Template $Template
                            | Join-String -sep ', ' -op '<' -os '>'

                }
            }
            'RawFullName' { # doesn't mess with generics, basic full
                $render = $tinfo.Fullname # Join-String { $_.Namespace, $_.Name -join '.' } -in $Tinfo

                $ns = $tinfo.Namespace | Dotils.Format-ShortNamespace -MinCount 30
                $name = $tinfo.Name
                $render =  @(
                    if ($ns.length -gt 0){
                        $ns
                    }
                    $Name
                ) -join '.'

                if($Tinfo.IsGenericType) {
                    $render +=
                        $tinfo.GenericTypeArguments
                            | Dotils.Format-ShortType -Options $nestedConfig
                            # | Fmt.ShortType -Options @{
                            #     StripNamespaces = $Config.StripNamespaces
                            #     IncludeBrackets = $false } -Template $Template
                            | Join-String -sep ', ' -op '<' -os '>'
                }
            }
            'RawName' {
                $render = $tinfo.Name
                if($Tinfo.IsGenericType) {
                    $render +=
                        $tinfo.GenericTypeArguments
                            | Dotils.Format-ShortType -Options $nestedConfig
                            # | Fmt.ShortType -Options @{
                            #     StripNamespaces = $Config.StripNamespaces
                            #     IncludeBrackets = $false } -Template $Template
                            | Join-String -sep ', ' -op '<' -os '>'
                }
                # if( -not $IsGeneric) {
                #     $render = Join-String {$_.Name } -in $Tinfo
                # }
            }
            default { throw "Unhandled template: $Template" }
        }
        # todo: refactor, only apply to raw namespaces, not to the full, final string
        if( $Config.StripNamespaces_OnFullString ) {
            foreach($toStrip in $Config.StripNamespaces) {
                $pattern = '^{0}\.' -f $ToStrip
                'toStrip: {0}' -f $pattern | Write-debug
                $render = $render -replace $pattern, ''
            }
        }
            # $tinfo | Join-string { $_ -replace '\bSystem\.', ''}

        if( $Config.IncludeBrackets ) {
           $render = Join-String -f "[{0}]" -In $render
        }
        return $render
    }
}

function Dotils.DbgTest.ShortType {
    <#
    .EXAMPLE

        $q = dotils.dbgTest.ShortType
        $q
            | ? MinCrumbs -in (1,2)
            | ? template -eq 'name'
            | sort Object, Template, minCrumbs, render
        $q
            | ? template -in @('name')
            | ? minCrumbs -in (0..2)
            | sort { $_.render.length }

    #>
    function __test.Object {
        param(
            $TestObject
        )
        $TestObject.GetType() | Join-String -op 'for Type: ' | write-host -fg 'tan'
        foreach($tName in 'FullName', 'Name') {
            foreach($i in 0..2) {
                $render = "`u{2400}"
                try {
                    $render = $TestObject
                        | Dotils.Format-ShortType -MinNamespaceCrumbCount $i -Template $tName
                } catch {
                    $render = 'Error: {0}' -f @( $_.ToString() )
                }
                [pscustomobject]@{
                    MinCrumbs = $i
                    Template = $tName
                    Render = $Render
                    Object = $testObject
                }
            }
        }
    }
    $scary = [Dictionary[
        [string],
        [Dictionary[int,datetime]]  ]]::new()

    $scary.GetType() | Join-String -op '$scary Type: ' | write-host -fg 'tan'
    @(
        __test.Object -testObject ( ,$scary )
        __test.Object -testObject ( ,[List[IO.FileSystemInfo]]::new() )
        __test.Object -testObject ( ,[List[Object]]::new() )
    )
    | sort-Object Object, Template
}
function Dotils.Fmt-Sci {
    <#
    .NOTES
        uses Private api, expected to change
    see more:
        [ClassExplorer.Internal._Format] | fime
    .EXAMPLE
        pwsh> '', 'yes', 'no', 1, 0, $true, $false | Fmt.Sci FancyBool | Join-String -sep ', '
        x, +, +, +, x, +, x # they are colored
    .EXAMPLE
        Pwsh>   | Fmt.Sci Type
            Dictionary<int, string>

        Pwsh> [Dictionary[int,string]]  | Fmt.Sci FullType
            System.Collections.Generic.Dictionary<int, string>

        Pwsh> [Dictionary[int,string]], [List[IO.FileSystemInfo]] | Fmt.Sci Type
            Dictionary<int, string>
            List<FileSystemInfo>

        Pwsh> [List[IO.FileSystemInfo]] | Fmt.Sci TypeAndParent
            List<FileSystemInfo> : object, IList<FileSystemInfo>, ICollection<FileSystemInfo>, IEnumerable<FileSystemInfo>, IEnumerable, IList, ICollection, IReadOnlyList<FileSystemInfo>, IReadOnlyCollection<FileSystemInfo>
    .EXAMPLE
        # with colors
        Pwsh> [List[IO.FileSystemInfo]] | Fime | select -first 1 | Fmt.Sci Member
            public void Add(FileSystemInfo item);

        Pwsh> [List[IO.FileSystemInfo]] | Fime | select -first 1 | Fmt.Sci MemberName
            Void Add(System.IO.FileSystemInfo)
    #>
    [CmdletBinding(DefaultParameterSetName='FromPipe')]
    [Alias('Fmt.Sci')]
    param(
        [Parameter(Mandatory, Position = 1, ParameterSetName='FromParam')]
        [Parameter(Mandatory, Position = 0, ParameterSetName='FromPipe')]
        [ValidateSet(
            'Type', 'TypeAndParent', 'FancyBool', 'Variable', 'Color', 'DefaultValue', 'EnumString', 'Failure', 'FullType', 'Keyword', 'Member', 'MemberName', 'Namespace', 'Number', 'Operator', 'String', 'Success'
        )]
        [string]$FormatKind,

        [Parameter(Mandatory, Position = 0,      ParameterSetName='FromParam')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='FromPipe')]
        $InputObject

    )
    process {
        switch($PSCmdlet.ParameterSetName) {
            'FromParam' {
                $Target = $InputObject
            }
            'FromPipe' {
                $Target = $InputObject
            }
        }

        switch($FormatKind) {
            'Type' {
                [ClassExplorer.Internal._Format]::Type($InputObject)
                break
            }
            'TypeAndParent' {
                [ClassExplorer.Internal._Format]::TypeAndParent($InputObject)
                break
            }
            'FancyBool' {
                [ClassExplorer.Internal._Format]::FancyBool($InputObject)
                break
            }
            'Variable' {
                [ClassExplorer.Internal._Format]::Variable($InputObject)
                break
            }
            'Color' {
                [ClassExplorer.Internal._Format]::Color( $InputObject )
                break
            }
            'DefaultValue' {
                [ClassExplorer.Internal._Format]::DefaultValue( $InputObject )
                break
            }
            'EnumString' {
                [ClassExplorer.Internal._Format]::EnumString( $InputObject )
                break
            }
            'Failure' {
                [ClassExplorer.Internal._Format]::Failure( $InputObject )
                break
            }
            'FullType' {
                [ClassExplorer.Internal._Format]::FullType( $InputObject )
                break
            }
            'Keyword' {
                [ClassExplorer.Internal._Format]::Keyword( $InputObject )
                break
            }
            'Member' {
                [ClassExplorer.Internal._Format]::Member( $InputObject )
                break
            }
            'MemberName' {
                [ClassExplorer.Internal._Format]::MemberName( $InputObject )
                break
            }
            'Namespace' {
                [ClassExplorer.Internal._Format]::Namespace( $InputObject )
                break
            }
            'Number' {
                [ClassExplorer.Internal._Format]::Number( $InputObject )
                break
            }
            'Operator' {
                [ClassExplorer.Internal._Format]::Operator( $InputObject )
                break
            }
            'String' {
                [ClassExplorer.Internal._Format]::String( $InputObject )
                break
            }
            'Success' {
                [ClassExplorer.Internal._Format]::Success( $InputObject )
                break
            }
            default { throw "UnhandledFormat: $FormatKind"}
        }
    }


}


function Dotils.Fmt.Join-Hex {
    <#
    .SYNOPSIS
        just format numbers as hex
    .NOTES
        fix: [hex] => <Ninmonkey.Console\public\ConvertTo-Number.>
    .EXAMPLE
        $what = 'a🐒c'
        $bytes = [Text.Encoding]::GetEncoding('utf-16le').GetBytes( $what )

    > $bytes | j.Hex
        61 00 3d d8 12 dc 63 00

    > $bytes | j.Hex -FormatString '{0:x4}' '_'
        0061_0000_003d_00d8_0012_00dc_0063_0000
    #>
    [Alias('j.Hex', 'Fmt.Hex')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [ARgumentCompletions(
            "''", "' '" )]
        [string]$Separator = ' ',

        [ArgumentCompletions(
            "'{0:x}'",  "'{0:x2}'", "'{0:x4}'",
            "'{0:x8}'", "'{0:x16}'"
        )]
        [Alias('FStr')]
        [string]$FormatString = '{0:x2}',

        [Alias('Op')]
        [string]$OutputPrefix = '',

        [Alias('Os')]
        [string]$OutputSuffix = '',

        # expects integers, in general
        [Alias('InObj', 'Values', 'Num', 'Int')]
        [Parameter(Mandatory, ValueFromPipeline )]
        [object[]]$InputObject
    )
    begin {
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }
    end {
        $Items
            | Join-String -sep $Separator     -f $FormatString
            | Join-String -op  $OutputPrefix -os $OutputSuffix
    }
}

function Fmt.Type {
    [OutputType('String')]
    param(
        [Alias('InputObjectOrType')]
        [Parameter(Mandatory, ValueFromPipeline)]
        $Obj,
        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -Other $Options -BaseHash @{
            IncludeBrackets = $true
            CoerceTypeNames = $true
        }
    }
    process {

        if($Obj -is 'string') {
            if( -not $Config.CoerceTypeNames ) {  throw "InvalidParam, Expects type or instance" }
            $tinfo = $Obj -as [type]
        }
        elseif($Obj -is [type] ) {
            $tinfo = $Obj
        } else {
            $tinfo = $Obj.GetType()
        }
        [string]$render = $tinfo | Join-string { $_ -replace '\bSystem\.', ''}
        if( $Config.IncludeBrackets ) {
           $render = Join-String -f "[{0}]" -In $render
        }
        return $render
    }
}
$script:___lastImport ??= @{
        ByName = @{}
    }
function Dotils.Module.Test-ModuleHasChanged {
    <#
    .SYNOPSIS
        test whether import time is older than file modified
    .EXAMPLE
        # easier usage now
        Pwszh> DbgTool.ModuleHasChanged -ModuleName Bintils -AutoLoad
    .EXAMPLE
         $what = 'bintils'
        $isNewer = DbgTool.ModuleHasChanged -ModuleName $what
        $isNewer | Should -BeOfType ([System.Boolean]) # it's returning a bool
        if( $isNewer ) { Import-Module $What -Force -PassThru }

    .EXAMPLE
        Pwsh> # run this. then save the file, then run again
        if( DbgTool.ModuleHasChanged -ModuleName Bintils ) {
            import-module Bintils -Force -PassThru }
        DbgTool.ShowErrors
    .LINK
        Dotils.Module.Test-ModuleHasChanged
    .LINK
        Dotils.Module.ShowSyntaxError
    #>
    [CmdletBinding()]
    [Alias(
        'DbgTool.ModuleHasChanged',
        'Dotils.Module.Test-IsNew'
    )]
    param(
        [ArgumentCompletions('Bintils')]
        [string]$ModuleName,

        # force a run
        [switch]$Force,
        # attempt to also run the import command
        [switch]$AutoLoad
    )
    $script:___lastImport ??= @{
        ByName = @{}
    }
    $PSBoundParameters
        | Json -wa ignore -depth 1
        | Join-string -op 'PSBoundParams: ' | write-debug
    $state = $script:___lastImport
    class LastModifiedInfo {
        [string]$ModuleName
        [IO.FileInfo]$Path
        [Datetime]$PrevLoadDt = 0
        # [string]$FullName
    }
    if($Force) {  $state.ByName.Remove($ModuleName) }
    if( -not $State.ByName.ContainsKey($ModuleName)) {
        $quickPath   = (Get-Module $ModuleName | % Path )
        $quickPath ??= (Get-Module $ModuleName -ListAvailable | % Path )
        if(-not $QuickPath) { throw "Error: Couldn't resolve module $ModuleName " }

        $state.ByName.$ModuleName =
            [LastModifiedInfo]@{
                ModuleName = $ModuleName
                Path = Get-Item $quickPath
                PrevLoadDt = 0
            }
    }
    [LastModifiedInfo]$lastModifyRecord = $state.ByName.$ModuleName
    if( -not $LastModifyRecord ) { throw "ShouldNeverReachException: Invalid record"}
    $lastModifyRecord | ConvertTo-Json -wa ignore -Depth 0 | Join-String -op 'lastModifyRecord: '  | write-debug
    $newModInfo = Get-Item $lastModifyRecord.Path

    [bool]$isNewer = $newModInfo.LastWriteTime -gt $LastModifyRecord.prevLoadDt
    if(-not $isNewer) { return $false }

    $lastModifyRecord.PrevLoadDt = [Datetime]::Now
    $newModInfo.Name | Join-string -f 'Module {0} is newer' | write-host -fg '#358053'
    if( $AutoLoad ) {
        Import-Module $ModuleName -Force -passt
            | Join-String -p { $_.Name, $_.Version } -op '  Loading... '
            | Dotils.Write-DimText
            | Infa
    }
    return $true
    # if(-not($state.ByName.Contains))
    # $state.ModuleName ??= $ModuleName
    # if($State.ModuleName -ne $ModuleName) { throw "DynamicListWIP, hardcoded one module"}
    # $state.PrevLoadDt ??= 0
    # $module = Get-Item ( get-module $ModuleName | % Path )
    # $state.ModulePath ??= $ModuleName
    # [bool]$isNewer = $module.LastWriteTime -gt $state.prevLoadDt
    # if(-not $isNewer) { return $false }

    # $state.PrevLoadDt = [Datetime]::Now
    # return $true
}

filter Dotils.Format.GoEditCommand { # jump to code, works for scripts -- not binary cmdlets
    [Alias(
        'Dotils.Fmt-GoEditCommand',
        'Fmt-GoEditCommand'
    )]
    param()
    $ext = $_.ScriptBlock.Ast.Extent
    if($ext) {
        $Ext.File, $Ext.StartLineNumber -join ':'
    }
}

function Dotils.Regex.RegexEscape {
    # minimal regx escape wrapper, from pipeline or parameters
    [Alias('Dotils.ReEsc', 'RegEsc')]
    param(
        [Parameter(ValueFromPipeline)]
            [string]$Str )

    process {
        [regex]::Escape( $Str )  }
}

function Dotils.Module.DebugAndShowErrors {
    <#
    .SYNOPSIS
        sugar to first import modified modules, and then show import errors
    #>
    [Alias('DbgTool.Module.ImportAndShowError')]
    param( [string]$ModuleName, [switch]$Force  )

    Dotils.Module.Test-ModuleHasChanged -ModuleName $ModuleName -Force:$Force -AutoLoad | Out-Null
    $showSyntax = @{
        WithoutGetError        = $true
        WithoutEmoji           = $true
        WithoutPositionMessage = $true
    }

    Dotils.Module.ShowSyntaxError @showSyntax
}
function Dotils.Module.ShowSyntaxError {
    <#
    .SYNOPSIS
        Show syntax errors and the invocation path as a clickable link
    .EXAMPLE
        # easier usage now
        Pwsh> DbgTool.ModuleHasChanged -ModuleName Bintils -AutoLoad
        Pwsh> Dotils.Module.ShowSyntaxError
    .EXAMPLE
        Pwsh> # run this. then save the file, then run again
        if( DbgTool.ModuleHasChanged -ModuleName Bintils ) {
            import-module Bintils -Force -PassThru }
        DbgTool.ShowErrors
    .LINK
        Dotils.Module.Test-ModuleHasChanged
    .LINK
        Dotils.Module.ShowSyntaxError
    #>
    [Alias(
        'DbgTool.ShowErrors')]
    param(
        [switch]$WithoutGetError,
        [switch]$WithoutPositionMessage,
        [switch]$WithoutEmoji
    )
    if( $global:Error.Count -gt 0) {
        if( -not $WithoutEmoji  ) {
            'Bad  🔴' | write-host -bg 'gray30' -fg 'gray80'
        }
        if( -not $WithoutGetError ) {
            hr
            ($global:error)?[1] | Get-Error
        }
        if( -not $WithoutPositionMessage ) {
            hr
            $global:error[1].InvocationInfo.PositionMessage
        }
    } else {
        if( -not $WithoutEmoji  ) {
            'Good 🟢' | write-host -bg 'gray30' -fg 'gray80'
        }
    }
}
function Console.GetWindowWidth {
    <#
    .SYNOPSIS
        # draw a perfectly sized horizontal line
    .example
        # draw a perfectly sized horizontal line
        '-' * (Console.Width) -join ''

        -----------------------------------------
    #>
    [Alias(
        'Console.Width', 'Console.WindowWidth')]
    [OutputType('System.Int32')]
    param()
    $w = $host.ui.RawUI.WindowSize.Width
    return $w
}
function Dotils.Console.GetEncoding {
    <#
    .synopsis
        set the right defaults
    #>
    [Alias('Console.Encoding')]
    [CmdletBinding()]
    param(
        # Technically not all, but, good enough
        [Alias('List')][switch]$All
    )
    if($All) {
        [Text.Encoding]::GetEncodings()
            | sort-Object DisplayName -Descending
        return
    }
    [pscustomobject]@{
        PSTypeName              = 'Dotils.ConsoleEncoding.Summary'
        OutputEncoding          = $OutputEncoding
        Console_OutputEncoding  = [Console]::OutputEncoding # -isa [Encoding]
        Console_InputEncoding   = [Console]::InputEncoding  # -isa [Encoding]

    }
}

function Dotils.AppDomain.Assembly.GetAll {
    [System.AppDomain]::CurrentDomain
    <#
    .SYNOPSIS
    .EXAMPLE
        [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() |
            Where-Object { $_.BaseType -eq [System.Management.Automation.PSPropertyInfo] -and $_.IsPublic }
    #>
    param(
        [ValidateSet('Types','Assemblies')]
        [Parameter()]
        $GetKind = 'Assemblies'
    )
    switch($GetKind) {
        'Types' { [AppDomain]::CurrentDomain.GetAssemblies() ; break; }
        'Assemblies' { [AppDomain]::CurrentDomain.GetAssemblies().GetTypes() ; break; }
    }
    return
}

# .GroupBy

function Dotils.To.Duration {
    <#
    .SYNOPSIS

    .EXAMPLE

    .EXAMPLE

    .NOTES
    see also:
        Ninmonkey.Console\New-RelativeDate
        RelativeDt -> New-RelativeDate
        RelativeTs -> ConvertTo-Timespan
public TimeSpan(long ticks);
public TimeSpan(int hours, int minutes, int seconds);
public TimeSpan(int days, int hours, int minutes, int seconds);
public TimeSpan(int days, int hours, int minutes, int seconds, int milliseconds);
public TimeSpan(int days, int hours, int minutes, int seconds, int milliseconds, int microseconds);
    #>
    [Alias('.to.Duration', '.Duration', '.to.Timespan')]
    [CmdletBinding()]
    [OutputType('[TimeSpan]')]
    param(
        [Parameter()]$Days,

        [Parameter(Mandatory, Position=0, ParameterSetName='AsSingleString')]
        [string]$QueryString

    )
    begin {
        write-warning 'nyi; or requires confirmation; mark;'
    }
    process {
        write-warning 'nyi; or requires confirmation; mark;'
        # is null a valid ctore value?.


    }
}
function Dotils.Compare.Duplicates {
    param(
        [Parameter(Position=0)]
        [string]$PropertyName = 'Name',

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    $query =
        $InputObject
            | CountOf 'total'
            | Group $PropertyName
            | CountOf "group.${PropertyName}"

    $Unique =
        $query
            | ? Count -eq 1 | CountOf 'Uniques'
    $dupes =
        $query
            | ? Count -ne 1 | CountOf 'DuplicatesCount'

    if($PassTHru) {
        return [pscustomobject]@{
            Unique = $Unique
            Duplicates = $Dupes
        }
    }

    throw 'left off here'
    @'
        $Module = 'dotils'
        gcm -Module $Module * | CountOf 'gcm' | Group Name | CountOf 'group.Name' | ? Count -gt 1 | CountOf 'DuplicatesCount'
        hr
        gcm -Module $Module | CountOf 'gcm' | Group Name | CountOf 'group.Name' | ? Count -gt 1 | CountOf 'DuplicatesCount'
        hr
        gmo $Module | % ExportedCommands | % Keys | CountOf 'Keys' | OutNull

'@

}


function Dotils.To.Encoding {
    <#
    .SYNOPSIS
        .To.Encoding -Name 'ASCII'
    .EXAMPLE
        .to.Encoding -List

            # huge list of encodings
    .EXAMPLE
        'utf-8', 'ascii' | .to.Encoding | Join-String -sep ', ' { $_ | Format-ShortTypeName }
        [Text.UTF8Encoding+UTF8EncodingSealed], [Text.ASCIIEncoding+ASCIIEncodingSealed]
    .NOTES
    see also:
        [Int32]
        [String]
        [Text.DecoderFallback]
        [Text.EncoderFallback]
    #>
    [Alias('.to.Encoding', '.as.Encoding')]
    [CmdletBinding(DefaultParameterSetName='FromName')]
    [OutputType('System.Text.EncodingInfo[]')]
    param(
        # Name of encoding to create
        [ArgumentCompletions(
            'utf-8', 'Unicode', 'utf-16le', 'Latin1', 'ASCII', 'BigEndianUnicode', 'UTF32'
        )]
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            Position=0,
            ParameterSetName='FromName')]
        [string]$Name,

        # codepage of encoding to create
        [Parameter(
            Mandatory,
            Position=0,
            ParameterSetName='FromCodepage')]
        [int]$Codepage,

        [Parameter(
            Mandatory,
            ParameterSetName='ListAll')]
        [Alias('List')][switch]$All,

        [Parameter()]
        [Text.EncoderFallback]$EncoderFallback,

        [Parameter()]
        [Text.DecoderFallback]$DecoderFallback
    )
    process {
        # is null a valid ctore value?.
        $hasDefinedFallbacks = $PSBoundParameters.ContainsKey('EncoderFallback') -and $PSBoundParameters.ContainsKey('DecoderFallback')

        if($All) {
            return [Text.Encoding]::GetEncodings()
                | sort-Object DisplayName -Descending
        }
        # $nameOrPage = $Codepage ?? $Name # warning this will fail because neither order coerce to null
        switch($PSCmdlet.ParameterSetName){
            'FromName' { $nameOrPage = $Name }
            'FromCodepage' { $nameOrPage = $Codepage }
            default {}
        }
        if( [string]::IsNullOrWhiteSpace($nameOrPage) ) {
            throw 'Name or Codepage not defined!'
        }

        if( -not $hasDefinedFallbacks) {
            $encoding? = try {
                [Text.Encoding]::GetEncoding( $nameOrPage ) } catch {
                    write-debug $_ }
        } else {
            $encoding? = try {
                [Text.Encoding]::GetEncoding( $nameOrPage, $EncoderFallback, $DecoderFallback )
            } catch {
                write-debug $_ }
        }

        if(-not $encoding?) {
            write-error "EncodingNotFound: '$Name'"
        }
        $encoding?
    }
}
function Dotils.Console.SetEncoding {
    <#
    .synopsis
        set the right defaults
    #>
    [Alias('Console.SetEncoding')]
    [CmdletBinding()]
    param(
        # Defaults to UTF8 but *without* BOM
        [Text.Encoding]$Encoding = [Text.UTF8Encoding]::new(),
        [switch]$PassThru
    )


    $OutputEncoding,
    [Console]::OutputEncoding,
        [Console]::InputEncoding
            | Join-String -sep ', ' {
                $_ | Format-ShortTypeName
            } -op "Was: `$OutputEncoding, [Console]::OutputEncoding, [Console]::InputEncoding`n    "
            | Write-Information -infa 'continue'

    $OutputEncoding =
            [Console]::OutputEncoding =
                [Console]::InputEncoding = $Encoding

    $OutputEncoding, [Console]::OutputEncoding, [Console]::InputEncoding
            | Join-String -sep ', ' {
                $_ | Format-ShortTypeName
            } -op "Now: `$OutputEncoding, [Console]::OutputEncoding, [Console]::InputEncoding`n    "
            | Write-Information -infa 'continue'

    if($PassThru){
        Dotils.Console.GetEncoding
        return
    }
}



function Dotils.To.PSCustomObject {
    <#
    .SYNOPSIS
    .example
        get-date | .To.Dict | .To.Obj
    .EXAMPLE
        $object | __asDict
    .EXAMPLE
        $object | __asDict -DropBlankKeys | Json -c -d 0
    .EXAMPLE
        # coerces keys to strings, allowing you to serialize
        PS> @{ 10 = 3 } | .To.Obj | .to.Dict | Json -Compress
    #>
    [Alias(
        '.To.Obj'
    )]
    [CmdletBinding()]
    param(
        # any type of objec
        [Parameter(
            Mandatory, ValueFromPipeline )]
        [object[]]$InputObject,

        [Alias('PSTypeName', 'TypeName')][string]$NewTypeName

        # ,
        # # drop keys when the value is whitespace
        # [switch]$DropBlankKeys,

        # # also json for convienence
        # [switch]$AsJsonMin
    )
    process {
        foreach($inner in $inputObject) {
            # use the most common key func? or build merge a hash?
            if($PSBoundParameters.ContainsKey('NewTypeName')) {
                write-warning 'future: explicitly set type name right'
            }
            [pscustomobject]$inner

            if($false) {

            <#
            this method fails on:
            $hash = nin.MergeHash -BaseHash $inner -OtherHash @{ PSTypeName = $NewTypeName ?? 'Dotils.Obj.PSCustomObject' }

Cannot convert value "System.Collections.Hashtable" to type
"System.Management.Automation.LanguagePrimitives+InternalPSCustomObject". Error: "Cannot process
argument because the value of argument "item" is not valid. Change the value of the "item" argument
and run the operation again."
                [pscustomobject]$hash
            #>
            }

        }
    }
}
# function Dotils.Select.Some {
#     # [CmdletBinding()]
#     [Alias('Some')]
#     param(
#         [Alias('Descending')][switch]$FromEnd
#     )
#     'todo: merge as subcase of with <Dotils.Select.Some.NoMore>' | Dotils.Write-DimText | write-verbose -verb
#     if($FromEnd) {
#         @( $Input ) | Select -Last 6
#         return
#     }
#     @( $Input ) | Select -first 6

# }

function Dotils.Get-UsingStatement {
    <#
    .SYNOPSIS
        remember using statements
    .EXAMPLE
        Pwsh> Dotils.Get-UsingStatement Collections
        # output:
        using namespace Collections.Generic

        Pwsh> Dotils.Get-UsingStatement Collections -IncludeSystemNamespace
        # output:
        using namespace System.Collections.Generic

    .EXAMPLE
        Dotils.Get-UsingStatement -NoClip Linq

        # output:
        using namespace Linq
        using namespace Linq.Expressions
        using namespace Linq.Expressions.Interpreter
        using namespace Xml.Linq

    #>
    [CmdletBinding()]
    param(
        # if no params, return valid keys
        [Parameter(Position=0)]
        [validateSet(
            'sma', 'Generic', 'Collections', 'Management.Automation', 'Linq'
        )]
        [string[]]$TemplateName,
        [switch]$IncludeSystemNamespace,

        [Alias('NoClip')][switch]$NeverSetClipboard
    )
    $Config = @{
        AlwaysCopy = $true
        StripPrefix_SystemNamespace = $true
    }
    if($PSBoundParameters.ContainsKey('NeverSetClipboard')) {
        $Config.AlwaysCopy = -not $NeverSetClipboard
    }
    if($PSBoundParameters.ContainsKey('IncludeSystemNamespace')) {
        $Config.StripPrefix_SystemNamespace = -not $IncludeSystemNamespace
    }
    # $Config.StripPrefix_SystemNamespace = $true
    $PSCmdlet.MyInvocation.BoundParameters
        | ConvertTo-Json -Depth 0 -Compress
        | Join-String -op 'Get-UsingStatement: ' -sep "`n"
        | write-verbose

    [string[]]$render = @(
        switch($TemplateName) {
            'Xml' {
                'System.Xml'
            }
            'Linq' {
                'System.Linq'
                'System.Linq.Expressions'
                'System.Linq.Expressions.Interpreter'
                'System.Xml.Linq'
            }
            'Linq.Extra' {
                'Newtonsoft.Json.Linq'
                'Newtonsoft.Json.Serialization'
                'System.Linq'
                'System.Linq.Expressions'
                'System.Linq.Expressions.Interpreter'
                'System.Reactive.Linq'
                'System.Xml.Linq'
            }
            'CodeAnalysis' {
                'Microsoft.CodeAnalysis'
                'Microsoft.CodeAnalysis.CSharp'
                'Microsoft.CodeAnalysis.CSharp.Syntax'
                'Microsoft.CodeAnalysis.Diagnostics'
                'Microsoft.CodeAnalysis.Diagnostics.Telemetry'
                'Microsoft.CodeAnalysis.Emit'
                'Microsoft.CodeAnalysis.FlowAnalysis'
                'Microsoft.CodeAnalysis.Operations'
                'Microsoft.CodeAnalysis.Text'
            }
            'ImportExcel' {
                'OfficeOpenXml'
                'OfficeOpenXml.Style.XmlAccess'
            }
            { $_ -in 'Generic', 'Collections' } {
                'System.Collections.Generic'
            }
            { $_ -in @( 'sma', 'Management.Automation' ) } {
                'System.Management.Automation'
            }
            default { throw "UnhandledTemplate: $TemplateName"}
        }
    )   | sort-Object -Unique
        | Join-String -f "`nusing namespace {0}"

    # see also: https://github.com/PowerShell/PowerShell/blob/a46843de2119203dc9c8db258138450d4a847c12/src/System.Management.Automation/engine/lang/parserutils.cs#L731-L734
    if($Config.StripPrefix_SystemNamespace) {
        $render =
            [regex]::Replace( $render, '^using namespace System\.', 'using namespace ', 'multiline')
    }
    if($Config.AlwaysCopy) {
        return $render | Set-Clipboard -PassThru
    }
    $render
}
function Dotils.Select.NoMore.Template {
    <#
    .SYNOPSIS
        template of a steppable function to exit early
    .EXAMPLE
        0..100 | NoMore
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,

        [Parameter(Position = 0)]
        [uint] $First = 3
    )

    begin {
        $selectSplat = @{
            First = $First
        }
        $pipe = { Select-Object @selectSplat }.GetSteppablePipeline()
        $pipe.Begin($PSCmdlet)
    }
    process {
        $pipe.Process($InputObject)
    }
    end {
        $pipe.End()
    }
}

function Dotils.Select.Some.NoMore {
    <#
    .SYNOPSIS
        better version of 'one' and 'some' that exits early if possible, and saves the value
    .NOTES
        - [ ] future: rewrite using steppable pipeline for an earlier exit
    .EXAMPLE
        Get-Process | One    # returns 1 item
        Get-Command | Some   # returns 5 items
        Get-Process | Some 3 # returns 3 item
    .EXAMPLE
        gci .
        gci . | One
        gci . | Some 3
        get-process | one
        get-process | some
        get-process | some 3
        get-process | some -LastOne 2
    #>
    [Alias('Some', 'One')]
    param(
        # Source
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,

        # how many items? default is 5, unless you use 'one', then it's 1
        [Alias('Count', 'Limit')]
        [Parameter(Position = 0)]
        [int] $FirstN = 5,

        # first N items from the start, or end?
        [Alias('Reverse', 'FromEnd', 'End')]
        [switch]$LastOne
    )

    begin {
        [bool] $IsUsingOne = $MyInvocation.InvocationName -eq 'One'
        $selectSplat = @{}
        if( $IsUsingOne ) { $FirstN = 1 }

        if( $LastOne ) { $selectSplat.Last = $FirstN }
        else { $selectSplat.First = $FirstN }
        # $pipe = { Select-Object @selectSplat }.GetSteppablePipeline()
        # $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
        # Using .AddRange() vs .Add() , this works for paramter type [object[]] or [object]
    }
    end {
        # future: performance: use steppable
        $query = @($Items | Select @SelectSplat) # simplifes missing tes
        if($Query.Count -eq 0 ) { 'No inputs' | Write-Debug; return; }
        if($IsUsingOne) {
            $Query
            $global:One = @( $Query )
            'One := {0}' -f @(
                $Global:One | Format-ShortTypeName
            )   | Dotils.Write-DimText
                | Infa
        } else {
            $Query
            $global:Some = @( $query )
            'Some := {0}' -f @(
                $global:Some
                | CountOf | Format-ShortTypeName
            )   | Dotils.Write-DimText
                | Infa
        }
    }
}


function Dotils.Select.One.Basic.Deprecated {
    # [Alias('First')]
    <#
    .SYNOPSIS
        replaced by [Dotils.Select.Some.NoMore] ;  sugar for: Select first 1,  and storing the value
    .EXAMPLE
        Pwsh> gci . -recurse | one
        Pwsh> $one.LastWriteTime
    #>
    [Alias(
        # 'One',
        # '.Select.One'
    )]
    param(
        [switch]$LastOne
    )
    if($LastOne) {
       $query = $Input | Select -Last 1
    } else {
        $query = $Input | Select-Object -First 1
    }

    <# try 1: was not able to end gci early
    if($LastOne) {
       ( $query = @( $Input ) | Select -Last 1 )
    } else {
        ( $query = @( $Input ) | Select-Object -First 1 )
    }
    #>
    $global:One = $query
    'Saved $One {0}' -f @(
        $query | Format-ShortTypeName
    )   | Dotils.Write-DimText
        | Infa

    # one of the rare cases where Input is useful without the dangers
}

write-warning 'see: Dotils.Describe'
function Dotils.Describe {
    [Alias(
        # 'What', '.Desc',
        '.Describe'
    )]
    param(

    )
    write-warning 'nyi; or requires confirmation; mark;'
    $stuff = $Input

    @( $Stuff ) | select -first 3 | % GetType | Format-ShortTypeName | Sort -Unique
    # $trace.Events | % GetType | Group -NoElement
}

function Dotils.Test-CompareSingleResult {
    <#
    .SYNOPSIS
        future: there might be cases where bool as string doesn't coerce right, maybe leave it as an object?

    #>
            [OutputType('bool')]
            [CmdletBinding()]
            param(
                [Parameter(Mandatory, Position=0)]
                [object]$InputObject,

                [Parameter(Mandatory, Position=1)]
                [ValidateSet('True', 'False', 'Null', 'EmptyString', $true, $False <# ,$Null#> )]
                [Alias('Kind', 'ExpectedResult', 'ExpectedKind', 'ShouldBe', 'Is')]
                $ExpressionKind
                # [string]$ExpectedKind,

            )

            $compareResult =
                switch($ExpectedKind){
                    'EmptyString' {
                        $InputObject -is 'string' -and
                            [string]::Empty -eq $InputObject
                        break
                    }
                    'EmptyList' {
                        $InputObject -is [Collections.IEnumerable] -and
                        $InputObject.Count -eq 0
                        break
                    }
                    'Null' {
                        $null -eq $InputObject
                        break
                    }
                    'True' {
                        $true -eq $InputObject
                        break
                    }
                    'False' {
                        $false -eq $InputObject
                        break
                    }
                    default {
                        throw "ShouldNeverReachException: Unhandled ExpectedKind: $ExpectedKind"}
                }
            "Test-CompareSingleResult:`n  Compare: {0}, Was: {1},`n  For: {2}" -f @(
                $ExpectedKind, $compareResult, $InputObject
            ) | Write-debug
            return $compareResult
        }

write-warning 'next: do <Dotils.Test-AllResults>'
function Dotils.Test-AllResults {
<#
    .SYNOPSIS
    Evaluate the pipeline as a single true/false result
    .NOTES
        future: could condition on
        - [ ] require at least 1 or more results
        - [ ] require OneOrNone
    .EXAMPLE


    #>
    [CmdletBinding()]
    [Alias(
        '.test',
        '.Assert',
        'Assert',
        'Test-Results'
    )]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateSet('All', 'None', 'Any')]
        [string]$AmountCondition,

        [Alias('ResultKind', 'As', 'ExpectedKind')]
        [Parameter(Mandatory, Position=0)]
        [ValidateSet('True', 'False', 'Null')]
        [string]$ExpectedResult,
        # values from pipeline,
        # also output object
        # maybe conditionally based on the assert?
        [switch]$PassThru = $false,


        [Alias('QuitOnFirst')][switch]$ExitEarly = $false,

        # exceptions verses soft null errors?
        [switch]$UseStrictErrors,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]]$InputObject
    )
    begin {
        $finalSuccess = $true
        if($PSBoundParameters.ContainsKey('ExitEarly')){
            throw 'wip next. exit early saving pipeline computations.'
        }
        if($PSBoundParameters.ContainsKey('UseStrictErrors')){
            throw 'wip next. exit early saving pipeline computations.'
        }


    }
    process {
        write-error 'nyi, next. first ensure <Dotils.Test-CompareSingleResult> is correct' -ea 'continue'
        throw 'first ensure <Dotils.Test-CompareSingleResult> is correct'
        foreach($Obj in $InputObject){
            $curTest = Dotils.Test-CompareSingleResult -InputObject $Obj -ExpectedResult $ExpectedResult

            # switch($AmountCondition){
            #     'All' {
            #         $curTest = Dotils.Test-CompareSingleResult -InputObject $Obj -ExpectedResult $ExpectedResult
            #     }
            #     'None' {

            #     }
            #     'Any' {

            #     }
            # }
            # $comparisonResult = $Obj -eq $ExpectedResult
        }
#         $InputObject | %{
# $AmountCondition
# $ExpectedResult
#         }
#         switch($InputObject)

    }
    end {

    }
}

function Dotils.Operator.TypeAs {
    <#
    .SYNOPSIS
        sugar for: $Input -as $Type
    future:
        also test whether type info is a subclass
    .example
        'a', 234, 3.4
        | Dotils.Operator.TypeIs -Type 'int'
        | Json -AsArray -Compress

        # out: [234]
    .example
        'a', 234, 3.4
            | Dotils.Operator.TypeIs -Type 'int' -AsTest

        # out: [false,true,false]
    #>
    [Alias(
         # for when the keyword has to roll up
        # extra variations
        '-As',
        # 'Dotils.AsType',
        'Op.As'
        # '.As.Type',
        # '.Op.As'
    )]
    [CmdletBinding()]
    param(

        # [ArgumentCompletions(
        #     'Int', '([Int])', '[Int]',
            # '[Text.Rune[]]'
        # )]
        [Alias('TypeInfo')][Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
        $TypeObject,

        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]]$InputObject,
        # should the values be filtered, or return a bool?
        # [switch]$AsFilter = $true,
        [ValidateScript({throw 'nyi'})]
        [switch]$AsTest = $false,

        # use the full array as the coerce
        [switch]$NoEnumerate
    )
    begin {
        Write-warning @'
Left off here on this test,

10, 1.34, '123', 'fe', 'abc' | -as -TypeObject 'int'
    # InvalidOperation: You cannot call a method on a null-valued expression.
'@

        if($NoEnumerate) {
            [Collections.Generic.List[Object]]$Items = @()
            if( -not $TypeObject -is 'type' -and -not $TypeObject -is 'string' ) {
                throw ('-TypeObject must be a [type] or [string], was: {0}' -f ( $TypeObject | Format-ShortTypeName ))
            }
        }
        <#
        # // future: sugar piping to throw instead
        '-TypeObject must be a [type] or [string], was: {0}' -f ( $TypeObject | Format-ShortTypeName )
            | ThrowIt
            #>
    }
    process {
        if( $Null -eq $InputObject ) { return }
        if( [string]::IsNullOrEmpty( $InputObject) ) { return }
        if($MyInvocation.ExpectingInput ) {
            $Items.AddRange(@( $InputObject ))
        }

        # if($NoEnumerate) {
        #     $Items.AddRange(@( $InputObject ))
        #     return
        # }

    }
    end {

        if( $NoEnumerate ) {
            $tinfo_container = $items.GetType()
            $tinfo_First = @( $Items)[0]
            @{
                Container =
                    $tinfo_container | Format-ShortTypeName
                FirstElement =
                    $tinfo_first | Format-ShortTypeName
            } | Json -depth 1 | Join-String -op 'Operator.As -NoEnumerate types = ' | Write-Verbose

            'Operator.As [items[]] -as $TargetType {0}' -f $TargetType
                | write-verbose

            $Items -as $TargetType
            return

        }
        foreach($curObj in $items) {
            try {

                $curObj -as $TargetType
                '{0} -as {1}' -f @(
                    $curObj | Format-ShortTypeName
                    $TargetType
                ) | Join-String -op 'Operator.As | Conversion | ' | Write-Verbose
            } catch {
                'Operator.As : Error attempting to coerce {0} to {1}' -f @(
                    $curObj | Format-ShortTypeName
                    $TargetType
                )
                $inner = $_
                $writeException = @{
                    Message      = ('Inner failed to convert: {0}' -f $inner.ToString() )
                    ErrorId      = 'Dotils.Operator.AsType'
                    Category     = 'InvalidType'
                    TargetObject = $inner
                }
                Write-Error @writeException
            }
        }
    }
}

class DisplayAnsiText {
    <#
    .SYNOPSIS
        # collect raw ansi text in a wrapper that you can save or pass around when  debugging
    .EXAMPLE
        $oneLine =
        ($oneLine.forEach([DisplayAnsiText]).RawText() -split ';').forEach([DisplayAnsiText])
    .link
        Dotils.New-AnsiDisplayText
    #>
    [string]$SafeText
    hidden [string]$_RawText
    [int]$RawLength
    DisplayAnsiText ( [string]$RawText ) {
        $This._RawText = $RawText
        $This.SafeText = $This._RawText | Ninmonkey.Console\Format-ControlChar
        $this.RawLength = $This._RawText.Length
    }
    [string] ToString() {
        return $This.SafeText
    }
    [string] RawText () {
        return $This._RawText
    }
}

function Dotils.New-AnsiDisplayText {
    <#
    .SYNOPSIS
        # collect raw ansi text in a wrapper that you can save or pass around when  debugging
    .EXAMPLE
        $oneLine =
        ($oneLine.forEach([DisplayAnsiText]).RawText() -split ';').forEach([DisplayAnsiText])
    .EXAMPLE
        🐒> Dotils.New-AnsiDisplayText "`n`n"
        🐒> Dotils.New-AnsiDisplayText -RgbColor (gi fg:\green )
    .EXAMPLE
        🐒> $blue | Dotils.New-AnsiDisplayText -Verbose
            VERBOSE: BoundFromRgbColorParam

            SafeText             RawLength
            --------             ---------
            ␛[38;2;0;0;255m␛[39m        20

        🐒> "`e[1b foo `n`ttext" | Dotils.New-AnsiDisplayText

            SafeText        RawLength
            --------        ---------
            ␛[1b␠foo␠␊␉text        15
    #>
    [OutputType( [DisplayAnsiText] )]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNull()]
            [Alias('Content', 'InObj', 'InText')]
            [string] $RawText,

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [Alias('ForeGroundColor', 'Color')]
            [RgbColor] $RgbColor
    )
    process {
        if( $Null -eq $RawText ) { return }
        # $PSBoundParameters | Json | write-host -fg 'blue'
        # ($InputText)?.GetTYpe()
        #     | Label 'in'
        # ($RgbColor)?.GetType()
        #         | Label 'rgbcolor'

        if($PSBoundParameters.ContainsKey('RgbColor')) {
            'BoundFromRgbColorParam' | Write-verbose
            # [DisplayAnsiText] $RgbColor.ToString()
            # return [DisplayAnsiText]@{RawText =  New-Text -fg $RgbColor '' }
            [string] $render = New-Text -fg $RgbColor ''
            [DisplayAnsiText] $Render
            return
        }
        'BoundFromStringParam' | Write-Verbose
        return [DisplayAnsiText] $RawText
    }
}

function Dotils.InlineExample.Format-HorizontalRule {
    <#
    .SYNOPSIS
        Insert horizontal bars exactly fitting the console window [inline-dependency only example. easier to strip out]
    .EXAMPLE
        Hrr
    .EXAMPLE
        $Error | Join-String -Property { $_.Exception.Message } -sep (hrr)
    .EXAMPLE
        Get-History | Join-String -sep (Hrr) CommandLine -f "Pwsh> {0}"
    #>
    [Alias('InlineExample.Hrr')] # I don't actually export these, it's essentially a tag
    [OutputType('String')]
    [Alias('Hrr', 'Hr')]
    param()
    $pad = "`n" * $PadLines -join ''
    ('-' * [console]::WindowWidth) -join ''
        | Join-String -op $Pad -os $Pad
}

function Dotils.InlineExample.HShowEscape {
    <#
    .SYNOPSIS
        Replaces escape characters with their saffe-to-print runes [inline-dependency only example. easier to strip out]
    .EXAMPLE
        # super slow if you don't use split, to reduce the size of strings it enumerates
        # but it's okay for smaller text
        ($error| Get-Error | Out-String) -split '\r?\n' | HShowEscape
    #>
    [Alias('InlineExample.HShowEscape')] # I don't actually export these, it's essentially a tag
    [CmdletBinding()]
    param( [Parameter(ValueFromPipeline)][string]$InputText )
    process {
        if( $Null -eq $InputText ) { return }
        $InputText.EnumerateRunes() | %{
            ( $_.Value -ge 0 -and $_.value -le 0x1f) ?
                [Text.Rune]::New( $_.Value + 0x2400 ) :
                $_
        } | Join-String
    }
}
function Dotils.InlineExample.ShowEmojiRepeats {
    # Replaces escape characters with symbols, making them easier to see patterns of
    process {
        $_ -replace
            [Regex]::Escape('␛[32;1m'), '🐈' -replace
            [Regex]::Escape('␛[0m'),    '🦎'
    }
}

function Dotils.Join.Enum {
    <#
    .SYNOPSIS
        summarize enum, quickly render it
    .EXAMPLE
        [DisplayEntryValueType] | Dotils.Join.Enum
    #>
    [CmdletBinding()]
    param(
        [Alias('Enum', 'InObj', 'In', 'Obj')]
        [Parameter(Mandatory, ValueFromPipeline)]
        # [enum]$InputObject
        [object]$InputObject
    )
    process {
        $shortName = $InputObject | Dotils.Format-ShortType

        # [DisplayEntryValueType]|fime | Join-string -Property { $_.Name  } -sep ', ' -op 'enum [DisplayEntryValueType] = '
        $joinstringSplat = @{
            OutputPrefix = 'enum [{0}] = ' -f $shortName
            Property     = { $_.Name  }
            Separator    = ', '
        }

        $InputObject
            | Find-Member
            | ? Name -ne 'value__'
            | Join-string @joinstringSplat
    }
}


function Dotils.Spectre.Select {
    <#
    .SYNOPSIS
        wraps Spectre[multi|group|none]Select
    .EXAMPLE
        dotils.spectre.Select -InputObject (get-process | s -First 10 | sort name -Unique) -Title 'files' -MultiSelect -HeightPercent 0.3 -Property 'Name'
    .LINK
        https://spectreconsole.net/widgets/tree
    .LINK
        https://spectreconsole.net/prompts/multiselection
    .LINK
        https://pwshspectreconsole.com/reference/config/set-spectrecolors/
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('InObj', 'In', 'Obj')]
        [object[]]$InputObject,

        [switch]$MultiSelect,

        [Alias('Property', 'Name')]
        [ArgumentCompletions(
            'Name', 'FullName', 'Path', 'Source',
            "'Name'", "'FullName'", "'Path'" )]
        [string]$ChoiceLabelProperty,
        # if set, height is percent of current window (0.0 to 1.0)
        [ValidateRange(0.0, 1.0)]
        [ArgumentCompletions( 0.1, 0.5, 1.0)]
        [double]$HeightPercent,

        [string]$Title = 'Pick'
    )
    begin {
        [List[Object]]$Items = @()
        if( -not $PSCmdlet.MyInvocation.ExpectingInput) {
            $Items.AddRange(@( $InputObject))
        }
    }
    process {
        if( $PSCmdlet.MyInvocation.ExpectingInput) {
            $Items.AddRange(@( $InputObject ))
        }
    }
    end {
        $readSpectreSelectionSplat = @{
            Title               = $Title
            Choices             = $Items
            # ChoiceLabelProperty = 'Name'
            # PageSize            = [int]([console]::WindowHeight / 2)
        }
        if ($PSBoundParameters.ContainsKey('ChoiceLabelProperty')) {
            $readSpectreSelectionSplat.ChoiceLabelProperty = $ChoiceLabelProperty
        }
        if ($PSBoundParameters.ContainsKey('HeightPercent')) {
            $readSpectreSelectionSplat.PageSize = [int]([console]::WindowHeight * $HeightPercent)
        }
        if($MultiSelect) {
            $Mode = 'MultiSelect'
        } else {
            $Mode = 'SingleSelect'
        }

        switch( $Mode ) {
            # { $_ -eq 'MultiSelect' -or $MultiSelect }  {
            'MultiSelect' {
                $selected = Read-SpectreMultiSelection @readSpectreSelectionSplat
                break
            }
            'MultiSelectGrouped' {
                throw "Unhandled Switch: $Mode"
                break
            }
            default {
                $selected = Read-SpectreSelection @readSpectreSelectionSplat
            }
            # $selected = Read-SpectreMultiSelectionGrouped
        }
        return $selected
    }
}

function Dotils.Format.WildcardPattern {
    <#
    .SYNOPSIS
        handle wildcards, prevent duplicates, auto join and spaces
    .description
        parsing sugar for nicer wildcards
    .EXAMPLE
        # examples in Dotils/tests/Format.WildCardPattern.tests.ps1
        Pwsh> Join.Wild 'to csv*' -WithoutWrapOutside -SpacesToWildcard
    .example
        gcm (wildstr to csv)

        wildStr *to csv -NoWrap -Verbose
            *to*csv

        wildStr to csv
            *to*csv*
    .link
        Dotils.Format.WrapWildcards
    .link
        Dotils.Format.WildCardPattern
    #>
    [Alias(
        'Dotils.Format.Build-WildcardPattern',
        'WildStr',
        'Join.Wild'
    )]
    [CmdletBinding()]
    [OutputType('String')]
    param(
        # for example
        [Alias('InputObject')]
        [Parameter(ValueFromPipeline, ValueFromRemainingArguments)]
        [string[]]$WildcardSegments,

        # should single string spaces be considered segments?
        [Alias('PreserveWhitespace')]
        [switch]$WithoutSpacesToWildcard,


        # Normally 'foo bar*' => '*foo*bar*' but this alters endings
        # so that  'foo bar*' => 'foo*bar*'
        [Alias('NoWrap')][switch]$WithoutWrapOutside

        # [switch]$PassThru
    )
    begin {
        [Collections.Generic.List[Object]]$Segments = @()
    }
    process {
        if( $WithoutSpacesToWildcard ) {
            $Segments.AddRange(@( $WildcardSegments ))
            return
        }
        $Segments.AddRange(@(
            $WildcardSegments -split '\s+'
        ))

    }

    end {
        $segments
            | Join-String -sep ' ' -SingleQuote
            | Join-String -op 'Segments: @( ' -os ' )'
            | Write-Verbose

        # ensure no duplicates if the user already endcapped
        if($WithoutWrapOutside) {
            $joined =
                ($Segments | Join-String -sep '*') -replace '[*]{2}', '*'
        } else {
            $joined =
                ($Segments | Join-String -sep '*' -op '*' -os '*') -replace '[*]{2}', '*'

        }
        $Joined | Join-String -op 'Dotils.Format.WildcardPattern: ' | Write-verbose
        $Joined
    }
}


    # ('fred*', 'foo', 'bar', 'cat' | Join-String -sep '*' -op '*' -os '*') -replace '[*]{2}', '*'
    # original:
# ('fred*', 'foo', 'bar', 'cat' | Join-String -sep '*' -op '*' -os '*') -replace '[*]{2}', '*'

#     throw 'NYI, next'
#     'chain wild, actuall command syntax


# was
#     gcm Dotils*alias*lia

# now
#     dgcm dotils alias lia
#     chain wild'

function Dotils.Operator.TypeIs {
    <#
    .SYNOPSIS
        sugar for: $Input -is $Type
    future:
        also test whether type info is a subclass
    .example
        'a', 234, 3.4
        | Dotils.Operator.TypeIs -Type 'int'
        | Json -AsArray -Compress

        # out: [234]
    .example
        'a', 234, 3.4
            | Dotils.Operator.TypeIs -Type 'int' -AsTest

        # out: [false,true,false]
    #>
    [Alias(
        # 'Is',
        # '.Is.Type'
        'Op.Is'
    )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        $Type,

        # should the values be filtered, or return a bool?
        # [switch]$AsFilter = $true,
        [switch]$AsTest = $false
    )
    process {
        foreach($curObj in $inputObject) {
            [bool]$test = $curObj -is $Type
            if($AsTest) { $test; continue; }
            else { if($test) { $curObj }}
        }
    }
}
function Dotils.Describe.AnyType {
    param()
    process {
        $Obj = $_
        $ObjCount = $Obj.Count
        $Meta = [ordered]@{
            Description  =
                 ''
            PSTypeName =
                 'Dotils.AnyType.Description'
            RawObject =
                 $Obj
            Type =
                 $Obj | Format-ShortTypeName
            PSTypes =
                $Obj.PSTypeNames
                    | Sort-Object -Unique
                    | Format-ShortTypeName
                    | Join-String -Separator ', '

            FirstElement =
                 @( $Obj )[0] | Format-ShortTYpeName
            Count =
                 $ObjCount
            Length =
                 $Obj.Length
            IsCommand =
                $Obj -is 'Management.Automation.CommandInfo'

            IsTrueNull =
                 $null -eq $Obj
            IsBlank = [string]::IsNullOrWhiteSpace( $Obj )
            IsEmpty = [string]::IsNullOrEmpty( $Obj )
            IsTypeInfo = $Obj -is 'type'
            IsTrueString =
                 $Obj -is 'string'
        }
        if($true){
            $Meta += @{
                IsEnumerable = $Obj -is [IEnumerable]
            }
            # OrderedDictionary
        }
        if($meta.IsTrueString) {
            $meta.IsEmpty =
                $Obj.Length = 0

            $meta.IsWhitespaceOnly =
                $Obj -match '^\s*$'

            $meta.HasAnyNonWhitespace =
                $Obj -match '\S+'
            $meta.HasOnlyDigits =
                $Obj -match '^\d+$'
            $meta.HasOnlyNonDigits =
                $Obj -match '^\D+$'

            $meta.StrLen_Chars =
                $Obj.length

            $meta.StrLen_Runes =
                ($Obj.EnumerateRunes().Value).count

            $meta.ShowControlChars =
                $Obj
                | Dotils.ShortString.Basic -maxLength 80
                | Dotils.ShortString | fcc
        }
        # then, add info depending on teh type

            # IsWhitespaceOnly
        $meta.IsContainer = $Meta.Count -gt 1
        $Count = $Obj.Count

        $meta.Description =
            switch($Obj){
                { $_ -is 'type' } { 'TypeInfo' }
                { $_ -is 'hashtable' } { 'Hashtable'}
                # { $_ }
                default {
                    'Other'
                }
            }
        # $IsText =
        # return [pscustomobject]$meta
        return $meta
    }
}
function Dotils.To.Hashtable {
    <#
    .SYNOPSIS
    .example
        get-date | .To.Dict -AsJsonMin
    .EXAMPLE
        $object | __asDict
    .EXAMPLE
        $object | __asDict -DropBlankKeys | Json -c -d 0
    .EXAMPLE
        PS> @{ 10 = 3 } | Json
        # error: Keys must be strings

        # coerces keys to strings, allowing you to serialize
        PS> @{ 10 = 3 } | .To.Obj | .to.Dict | Json -Compress

        # output:
        {"10":3}
    #>
    [Alias(
        '.to.Dict',
        '.as.Dict'
    )]
    [CmdletBinding()]
    param(
        # any type of objec
        [Parameter(
            Mandatory, ValueFromPipeline )]
        [object[]]$InputObject,

        # drop keys when the value is whitespace
        [switch]$DropBlankKeys,

        # also json for convienence
        [switch]$AsJsonMin
    )
    begin {

        # "test case @{ 3 = 10 }  | .as.Dict | Json"
        # | write-debug -debug
        #     write-warning 'not working as of new code'
        function __parseFrom.Object {
            param( [object]$InputObject )
            $obj = $InputObject
            $newHash = @{}

            foreach($prop in $Obj.PSObject.Properties) {
                $newHash[ $prop.Name ] = $Prop.Value
            }

            if($DropBlankKeys) {
                foreach($key in $newHash.Keys.clone()) {
                    $isBlankValue = [string]::IsNullOrWhiteSpace( $newHash[$key] )
                    if($isBlankValue) {
                        $newHash.remove( $key )
                    }
                }
            }

            if($AsJsonMin) {
                $newHash | ConvertTo-Json -depth 1 -Compress -wa 0
                continue
            }
            return $newHash
            # }
        }
        function __parseFrom.Hashtable {
            param( [object]$InputObject )
                $obj = $InputObject
                $newHash = [hashtable]::new( $InputObject )

            if($DropBlankKeys) {
                foreach($key in $newHash.Keys.clone()) {
                    $isBlankValue = [string]::IsNullOrWhiteSpace( $newHash[$key] )
                    if($isBlankValue) {
                        $newHash.remove( $key )
                    }
                }
            }

            if($AsJsonMin) {
                $newHash | ConvertTo-Json -depth 1 -Compress -wa 0
                continue
            }
            return $newHash

        }
    }
    process {

        foreach($curObject in $inputObject) {
            $CurObject | Format-ShortTypeName| Join-String -op 'is a ' | write-debug
            if($curObject -is 'hashtable') {
                __parseFrom.Hashtable -Inp $curObject
            } else {
                __parseFrom.Object -Inp $curObject
            }
        }

    }
}

function Dotils.Goto.Kind {
    <#
    .SYNOPSIS
    .example
        $error[1] | Dotils.Goto.Kind -Name Auto
        $error[1] | .Go -Kind 'Auto'
        $error[1] | .Go -Kind 'Error.InvocationInfo'
    #>
    [CmdletBinding()]
    [Alias(
        '.Go.Kind', '.GoTo.Kind'
        # '.Go.File', '.Go.Module',
        # '.Go.ScriptBlock',
        # '.Go.Error',
        # '.Go.ScriptBlock',
        # '.Go.Code', '.Go.Ivy'
    )]
    param(
        [ArgumentCompletions(
            'Error.InvocationInfo', 'Auto'
        )]
        [Parameter(Position=0)]
        [string]$KindName = 'Auto',

        # go to some kinds
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [Alias('PassThru')][switch]$TestOnly
    )
    # $some = $global:error[0..10]
    # @( $some[0] ) | Format-ShortTypeName
    process {
        switch($KindName) {
            'Auto' {
                if( $InputObject | .Has.Prop -PropertyName 'InvocationInfo' -AsTest ) {
                    $KindName = 'Error.InvocationInfo'
                }
            }
            {$true} {
                $KindName | Join-String -op 'New KindName: ' | write-verbose
            }
            default { throw "UnhandledKindName: '$KindName'" }
        }

        switch($KindName){
            'Error.InvocationInfo' {
                [Management.Automation.InvocationInfo]$iinfo =
                    $InputObject.InvocationInfo

                $iinfo | ft -auto |oss| write-host
                '{0}:{1}' -f @(
                    $iinfo.ScriptName; $iinfo.ScriptLineNumber
                )
                write-warning 'InvocationInfo fail message when file is in memory'

            }
            'Auto' {

            }
            default { write-warning "unhandled KindName: $KindName" }
        }

        # write-error 'nyi'

        # $src = $global:error
        # $one = $global:error| s -First 1
        # $two = $global:error| s -First 1 -skip 1

        # # $global:error[0].CategoryInfo
        # $one.CategoryInfo
        #     | .Iter.Prop
        #     | Join-string -sep "`n" { $_.Name, $_.Value -join ': ' }

        # # throw 'go to inner exception position messages'
        # # $error[0].InvocationInfo.ScriptName

        # # throw 'nyi'
        # foreach($errItem in $InputObject) {
        #     $source = @( $errItem )
        #     $summary = [ordered]@{
        #         QualId = $first.FullyQualifiedErrorId
        #         Err0 =
        #             @($source)[0]| Format-ShortTypeName
        #         Err1 =
        #             @($source)[1]| Format-ShortTypeName
        #         Err2 =
        #             @($source)[2]| Format-ShortTypeName
        #     }
        #     if($TestOnly){
        #         return [pscustomobject]$summary
        #     }
        # }

    }
}


function Dotils.Bookmark.EverythingSearch {

$Bookmarks = @(

@{
    Name = 'Recent code-workspaces'
    Query = @'
ext:code-workspace;psm1;ps1;psd1;md;xlsx;js;ts;html dm:last3weeks ext:code-workspace
'@
}
@{
    Name = 'Recent Excel'
    Query = @'
ext:code-workspace;psm1;ps1;psd1;md;xlsx;js;ts;html dm:last3weeks ext:xlsx
'@
}
@{
    Name = 'bdg_compares_2023-08'
    Query = @'
ext:xlsx ( | path:ww:"G:\temp\xl\bdg_compares_2023-08\batch1" | path:ww:"G:\temp\compare.bdg") dm:last2days
'@
}
@{
    Name = 'bdg_compare2'
    Query = @'
ext:xlsx ( dm:last2hours | path:ww:"G:\temp\xl\bdg_compares_2023-08\batch1" | path:ww:"G:\temp\compare.bdg") dm:last2hours
'@
}
) | .To.Obj
return $Bookmarks

}
function Dotils.Quick.Memory {
    <#
    .synopsis
        select and aggregate Get-Process quickly
    .EXAMPLE
        Dotils.Quick.Memory -TemplateName All64 Pwsh
        Dotils.Quick.Memory Pwsh -PropertyName PeakWorkingSet64 -PassThru
    .EXAMPLE
        Dotils.Quick.Memory -ProcessName Pwsh, Code -TemplateName BasicMemory
    #>
    param(
        [ArgumentCompletions(
            'Pwsh', 'Code', 'Firefox', 'Edge', 'Explorer', 'Chrome', 'WindowsTerminal*',
            '*docker*', 'Docker', '*discord*', '*steam*', '*Everything*'
        )]
        [Alias('Name')]
        [string[]]$ProcessName,

        [Parameter()]
        [ArgumentCompletions(
            'Set',
            'Time',
            'BasicMemory',
            'AllMemory',
            'All64'
        )]
        [string[]]$TemplateName,

        [ArgumentCompletions(
        'BasePriority', 'Container', 'EnableRaisingEvents', 'ExitCode', 'ExitTime', 'Handle', 'HandleCount', 'HasExited', 'Id', 'MachineName', 'MainModule', 'MainWindowHandle', 'MainWindowTitle', 'MaxWorkingSet', 'MinWorkingSet', 'Modules', 'NonpagedSystemMemorySize', 'NonpagedSystemMemorySize64', 'PagedMemorySize', 'PagedMemorySize64', 'PagedSystemMemorySize', 'PagedSystemMemorySize64', 'PeakPagedMemorySize', 'PeakPagedMemorySize64', 'PeakVirtualMemorySize', 'PeakVirtualMemorySize64', 'PeakWorkingSet', 'PeakWorkingSet64', 'PriorityBoostEnabled', 'PriorityClass', 'PrivateMemorySize', 'PrivateMemorySize64', 'PrivilegedProcessorTime', 'ProcessName', 'ProcessorAffinity', 'Responding', 'SafeHandle', 'SessionId', 'Site', 'StandardError', 'StandardInput', 'StandardOutput', 'StartInfo', 'StartTime', 'SynchronizingObject', 'Threads', 'TotalProcessorTime', 'UserProcessorTime', 'VirtualMemorySize', 'VirtualMemorySize64', 'WorkingSet', 'WorkingSet64'
        )]
        [string[]]$PropertyName,
        [switch]$PassThru


    )
    [List[Object]]$PropList = @()
    if( $PropertyName ) {  $PropList.AddRange( @( $PropertyName ) ) }
    switch($TemplateName) {
        'Set' {
            $PropList.AddRange((
                'MaxWorkingSet', 'MinWorkingSet', 'PeakWorkingSet', 'PeakWorkingSet64', 'WorkingSet', 'WorkingSet64'
            ))
        }
        'Time' {
            $PropList.AddRange((
                'ExitTime', 'PrivilegedProcessorTime', 'StartTime', 'TotalProcessorTime', 'UserProcessorTime'
            ))
        }
        'BasicMemory' {
            $PropList.AddRange((
                'PeakPagedMemorySize64', 'PeakWorkingSet64', 'WorkingSet64'
            ))
        }
        'AllMemory' {
            write-host -bg 'gray30' 'Use picky to picky to dynamically define these groups in short code'
            'NonpagedSystemMemorySize64', 'PagedMemorySize64', 'PagedSystemMemorySize64', 'PeakPagedMemorySize64', 'PeakVirtualMemorySize64', 'PrivateMemorySize64', 'VirtualMemorySize64'

        }
        'All64' {
            $PropList.AddRange((
                'NonpagedSystemMemorySize64', 'PagedMemorySize64', 'PagedSystemMemorySize64', 'PeakPagedMemorySize64', 'PeakVirtualMemorySize64', 'PeakWorkingSet64', 'PrivateMemorySize64', 'VirtualMemorySize64', 'WorkingSet64'
            ))
        }
        default {}
    }
    $PropList = $PropList | Sort-Object -unique
    $PropList |  Join-String -sep ', ' -op 'SelectedProps: ' | Dotils.Write-DimText | Infa

    function HumanOneUnit {
        param( $InputObject, [string]$PropName, [string]$NewName )
        $HasProp = $InputObject.PSObject.PRoperties.Name.cont

        if( -not $InputObject.psobject.properties.name.contains( $PropName ) ) {
            'Missing Property {0} from object {1}' -f @(
                $PropName
                ($InputObject)?.GetType().Name ?? 'null'
            ) | write-error
        }

        $Target = $InputObject.$PropName
        $humanizedValue? = try {
            '{0:n1} (Gb??)' -f ( $target / 1gb )
        } catch {
            $_.ToString()
        }
        "adding: $PropName => $newName := $HumanizedValue" | write-verbose
        $InputObject
            | Add-Member -PassThru -Force -NotePropertyMembers @{
                    $NewName  = $humanizedValue
                }
    }

    $query =
        foreach($curProcessName in $ProcessName) {
            ps $ProcessName
        | Measure-Object -Sum -Average -Minimum -Maximum -Property $PropList
            | %{
                HumanOneUnit $_ -PropName 'Sum' 'Sum_Hu'
                HumanOneUnit $_ -PropName 'Average' 'Avg_Hu'
                HumanOneUnit $_ -PropName 'Maximum' 'Max_Hu'
                HumanOneUnit $_ -PropName 'Minimum' 'Min_Hu'

                $_ | Add-Member -PassThru -Force -NotePropertyMembers @{
                    Name  = $curProcessName
                    # Human = $MaybeHuman
                }
                return
                # $maybeHuman = try {
                #     '{0:n1} (Gb?)' -f ( $_.Sum / 1gb )
                # } catch {
                #     $_.ToString()
                # }
                # $_ | Add-Member -PassThru -Force -NotePropertyMembers @{
                #     Name  = $curProcessName
                #     # Human = $MaybeHuman
                # }
            }
        }
    if($PassThru) { return $query }

    $query
        | ft *Human*, Property, * -AutoSize
    return
    # ps $ProcessName
    #     | Measure-Object -Property PeakPagedMemorySize64, PeakWorkingSet64, WorkingSet64 -Sum
    #     | %{
    #         $_ | Add-Member -PassThru -Force -NotePropertyMembers @{
    #             SumHuman =  '{0:n1} Gb' -f ( $_.Sum / 1gb )
    #         }
    #     } | ft *Human*, Property, * -AutoSize

}
function Dotils.Quick.Pwd {
    # 2023-05-12 : touch
    <#
    .SYNOPSIS
        ShowLongNames, visual render, easier to read
    .EXAMPLE
        Pwsh> QuickPwd
    .EXAMPLE
        QuickPwd
        QuickPwd -Format Reverse
        QuickPwd Reverse -Options @{ ChunksPerLine = 8 }
        QuickPwd Default -Options @{ ChunksPerLine = 8 }

        . $PROFILE.MainEntryPoint ; hr -fg magenta 2
        QuickPwd Reverse -Options @{ ChunksPerLine = 8 }
        QuickPwd         -Options @{ ChunksPerLine = 8 ; NoHr = $true ; Reverse = $false }
        QuickPwd Default -Options @{ ChunksPerLine = 8 ; NoHr = $true ; Reverse = $true }
        QuickPwd Default -Options @{ ChunksPerLine = 8 ; NoHr = $true ; Reverse = $false }
    #>
    [Alias(
        'QuickPwd',
        '.quick.Pwd'
    )]
    param(
        [ArgumentCompletions(
            'Default',
            'Reverse'
        )]
        [Alias('Format')]
        [Parameter(Position = 0)]
        [string]$OutputFormat = 'Default',


        [ArgumentCompletions(
            '@{ ChunksPerLine = 8 }'
        )]
        [hashtable]$Options,
        [Alias('Copy', 'Cl', 'PassThru')][Parameter()][switch]$Clip
    )

    $Config = mergeHashtable -OtherHash ($Options ?? @{}) -BaseHash @{
        ChunksPerLine = 5
        # Reverse       = $true
        NoHr          = $false
    }

    $shareSize = @{
        GroupSize = ($Config)?.ChunksPerLine ?? 5
    }
    if ($Config.Reverse) {
        $shareSize.Options = mergeHashtable -BaseHash $shareSize.Options -OtherHash @{
            Reverse = $true
        }
        # .Reverse = $True
    }
    switch ($OutputFormat) {
        'Gradient' {

        }
        'Reverse' {
            if (-not $Config.NoHR) {
                Hr
            }

            $renderLongPathNamesSplat = @{
                Options = @{
                    Reverse = $True
                }
            }
            Get-Item . | RenderLongPathNames @shareSize @renderLongPathNamesSplat
            if (-not $Config.NoHR) {
                Hr
            }

        }
        'Default' {
            if (-not $Config.NoHR) {
                Hr
            }
            $renderLongPathNamesSplat = @{

            }

            Get-Item . | RenderLongPathNames @ShareSize @renderLongPathNamesSplat
            if (-not $Config.NoHR) {
                Hr
            }
        }
        default {
            throw "UnhandledFormatType: '$OutputFormat'"
        }
    }
    if ($clip) {
        Get-Location | Set-Clipboard
    }
}

function Dotils.Write-FormatHumanSize.Old {
    <#
    .SYNOPSIS
    Sugar to render size as human readable, but emit the raw numeric value ( added: <= 2023 )

    .DESCRIPTION
    Long description

    .PARAMETER SizeAsBytes
    Parameter description

    .PARAMETER Prefix
    Parameter description

    .PARAMETER PassThru
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    # [OutputType('number else string set')]
    # [Alias()]
    [CmdletBinding()]
    # [Alias('__writeSizeAsMb')]
    param(
        [Alias(
            'Bytes'
            # 'Length'
        )]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        # [int]$SizeAsBytes,
        [long]$SizeAsBytes,

        [Alias('AsAnsiColors')]
        [string]$Prefix = '',

        # returns string with ansi escapes, that would have been written to host
        [Alias('NoWriteHost', 'AsString')]
        [switch]$PassThru,
        [float]$SizeAsMb,
        [float]$SizeAsKb,

        # Compared to -NoWriteHost, this controls whether the numeric part is output or not
        [Alias('AsValue', 'EmitValue', 'ByteCount')]
        [switch]$WithValue

    )
    process {
        Quick.WarnOnce -Message 'NYI: Humanized system not fully implemented for dt.Write-FormatHumanSize' -WriteHost
        if( -not $SizeAsBytes -and
            -not $SizeAsMb -and
            -not $SizeAsKb ) {
                # wait-debugger
                throw [ArgumentException]::new('Invalid args, no size was found', 'SizeAsBytes|SizeAsMb|SizeAsKb' )
            }

        if($SizeAsMb -and -not $SizeAsBytes ) {
            $SizeAsBytes = [int]($SizeAsMb * 1mb)
        }
        if($SizeAsKb -and -not $SizeAsBytes ) {
            $SizeAsBytes = [int]($SizeAsKb * 1kb)
        }
        # :( , quick implmentation
        switch($SizeAsBytes) {
            { $SizeAsBytes -ge 1tb } {
                $unitName = 'tb'
                $unitValue = $SizeAsBytes / 1tb
            }
            { $SizeAsBytes -ge 1gb } {
                $unitName = 'gb'
                $unitValue = $SizeAsBytes / 1gb
            }
            { $SizeAsBytes -ge 1mb } {
                $unitName = 'mb'
                $unitValue = $SizeAsBytes / 1mb
            }
            { $SizeAsBytes -ge 1kb } {
                $unitName = 'kb'
                $unitValue = $SizeAsBytes / 1kb
            }
            default {
                $unitName = 'b'
                $unitValue = $SizeAsBytes / 1
            }
            # default { throw "UhandledSize: $SizeAsBytes" }
        }
        $render = Join-String -f "{0:n2} ${UnitName}" -in $UnitValue
        $unitName, $unitValue, $Render, $finalRender
            | Join-String -sep ', ' -op 'UnitName, UnitValue, Render, FinalRender []= ' -SingleQuote
            | Write-Debug

        [string] $finalRender = Join-String -op $Prefix -f "{0:n2} $unitName" -In $UnitValue -Separator ''

         # emit either numeric otherwise the rendered ansi formatted string (before wriiting to host)
        if( $WithValue ) { $SizeAsBytes }
        if( $PassThru ) { $finalRender }
        $finalRender | Write-host -fore 'gray80' -bg 'gray30'
    }
}


function Dotils.Error.GetInfo {
    <#
    .SYNOPSIS
    .LINK
        Dotils.Error.Select
    .LINK
        Dotils.Error.GetInfo
    .LINK
        .Describe.Error
    .LINK
        .Is.Error.FromParamBlockSyntax
    .LINK
        Dotils.Describe.Error
    .LINK
        Dotils.Describe.ErrorRecord
    .LINK
        Dotils.Error.GetInfo
    .LINK
        Dotils.Error.Select
    .LINK
        Dotils.Is.Error.FromParamBlock
    .LINK
        Dotils.Render.Error.CategoryInfo
    .LINK
        Dotils.Render.ErrorRecord.Fancy
    .LINK
        Dotils.Render.ErrorVars
    .LINK
        Dotils.Tablify.ErrorRecord
    #>
    # ToRefactorAttribute
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            'InvoInfo',
            'InvoInfo.Position',
            'Exception',
            'Exception.Type',
            'NoToString'
        )]
        [Alias('Kind', 'Has')][string]$FilterKind

        # [switch]$HasInvoInfo,

    )
    begin {
        'consolidate code with error select function' | write-host -back 'darkred'
    }
    process {
        # $cur = $_
        if( $MyInvocation.ExpectingInput ) { throw 'NYI' }
        $curErr = $global:error # | Select -first 5

        foreach($cur in $curErr) {
            switch($FilterKind) {
                'InvoInfo' {
                    $cur | ?{ -not [String]::IsNullOrWhiteSpace( $_.InvocationInfo ) }
                }
                'InvoInfo.Position' {
                    $cur | ?{ -not [String]::IsNullOrWhiteSpace( $_.InvocationInfo.PositionMessage ) }
                }
                'Exception' {
                    $cur | ?{ -not [String]::IsNullOrWhiteSpace( $_.Exception) }
                }
                'Exception.Type' {
                    $cur | ?{ -not [String]::IsNullOrWhiteSpace( $_.Exception.Type ) }
                }
                'NoToString' {
                    $cur | ?{
                        $maybeStr = $_.ToString() -join '' -replace '\s+'
                        $maybeStr.Count -gt 0
                     }
                }
                default { throw "UnhandledFilterKind: '$FilterKind'" }
            }

            # $one.InvocationInfo.PositionMessage

        }

        <#

        ?{ -not [string]::IsNullOrWhiteSpace( $_.Exception.Type ) }
            ParserError: Missing ')' in function parameter list.
        #>

    }

}
function Dotils.Text.Pad.Segment {
    <#
    .SYNOPSIS
        sugar. join stuff. yet another one.
    .LINK
        Dotils.Brace
    .LINK
        Dotils.JoinString.As
    .LINK
        String.Transform.AlignRight
    .link
        Dotils.Pad.Segment
    #>
    [Alias(
        '.Text.Pad.Segment','.Text.Segment'
        # 'Dotils.Pad.Segment'
    )]
    [OutputType('String')]
    param(
        [ArgumentCompletions(
            'Newline', 'Space', 'Dash', 'Bullet', 'Csv', 'UL', 'Tree', 'HR'
        )]
        [Parameter(Mandatory, Position = 0)]
        [string]$SpacingKind,
        #
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [string]$accum_text = ''
    }
    process {

        # future, make this steppable , or support pipe and non pipe right
        [string]$renderPad = switch($SpacingKind) {
            'Newline' { "`n" }
            'Space' { ' ' }
            'Dash' { ' - ' }
            'Bullet' { ' • ' }
            'Csv' { ', ' }
            'UL' { ' - '}
            'Tree' { '⊢' }
            default { $SpacingKind ?? ''  }
        }

        if($MyInvocation.ExpectingInput) {
            $accum_text =
                Join-String -op $accum_text -inp $InputObject -sep $renderPad
                return
        } else {
            return $renderPad
        }
        end {

        }
    }
}
# function tReplace

# gcm -m Dotils |  %{ $_ -replace '\Dotils\.', '' } |  Join.UL -BulletStr •

function Dotils.Quick.GetError {
    <#
    .SYNOPSIS
        .quick. show errors when in debug scope
    #>
    [Alias(
        '.quick.Error'
        # , 'QuickHistory'
    )]
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ArgumentCompletions(
            'Default'
        )]
        [string]$Template,

        [uint]$FirstN,
        [uint]$LastN
    )
    $global:error.Exception
        | group { $_.GetType() }
        | sort Count -Descending
        | ft -AutoSize | Out-String
        | write-verbose -Verbose


    $selected_errors = @( $global:error )
    if($FirstN) {
        $selected_errors = $selected_errors | Select -first $FirstN
    }
    if($LastN) {
        $selected_errors = $selected_errors | Select -Last $LastN
    }

    $Template ?? ''
        | Join-String -op 'Dotils.Quick.GetError => TemplateMode = '
        | write-verbose

    @(
        'globalCount: {0}' -f $global:error.count
        'selected: {0}' -f $selected_errors.count
    ) | Join-String -sep ',  '

    # Quick, short, without duplicates
    switch ($Template) {
        'Default' {

        }

        default {

            $all_errors
        }
    }
}

function Dotils.Quick.History {
    <#
    .SYNOPSIS
        .quick. verb is a short summary of something, often with colors or formatting, not raw objects or json
    #>
    [Alias(
        '.quick.History', 'QuickHistory')]
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
            | Join-String -sep (Hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }
        'Duplicates' {
            Get-History
            | Join-String -sep (Hr 1) {
                "{0}`n{1}" -f @(
                    $_.Id, $_.CommandLine )
            }
        }

        default {
            Get-History
            | Sort-Object -Unique -Stable CommandLine
            | Join-String CommandLine -sep (Hr 1)
        }
    }
}
function Dotils.Quick.ShowFunctionsFromModule {
    param( [string]$ModuleName )
    $cmd_list = get-module $ModuleName
    if(  $cmd_list.count -eq 0) {
        'ModuleNotYetImported' | write-host -fg 'darkred'
        return
    }
    $cmd_names = $cmd_list.ExportedCommands.Keys | Sort-Object
    @(foreach($c in $cmd_names) {
        try {
            gcm $c -Syntax -ea 'stop'
        } catch {
            '{0} ( gcm failed )' -f $C
        }
    }).Where{ $_ } -replace '\r?\n', '' | Join.UL
}
function Dotils.Format.Write-DimText {
    <#
    .SYNOPSIS
        # sugar for dim gray text,
    .EXAMPLE
        # pipes to 'less', nothing to console on close
        get-date | Dotils.Write-DimText | less

        # nothing pipes to 'less', text to console
        get-date | Dotils.Write-DimText -PSHost | less
    .EXAMPLE
        > gci -Name | Dotils.Write-DimText |  Join.UL
        > 'a'..'e' | Dotils.Write-DimText  |  Join.UL
    #>
    [OutputType('String')]
    [Alias('Dotils.Write-DimText')]
    param(
        # write host explicitly
        [switch]$PSHost
    )
    $ColorDefault = @{
        ForegroundColor = 'gray60'
        BackgroundColor = 'gray20'
    }

    if($PSHost) {
        return $Input
            | Pansies\write-host @colorDefault
    }

    return $Input
        | New-Text @colorDefault
        | % ToString
}

function Dotils.Select.Variable {
    # what kinds can be used?>
    throw 'command not done wip'
    $all_vars = @(
        Get-Variable -Scope global
        Get-Variable -scope script
        Get-Variable -scope local
    )
    <#
    expected types
        [sma.LocalVariable]
        [sma.NullVariable]
        [sma.PSCultureVariable]
        [sma.PSUICultureVariable]
        [sma.PSVariable]
        [sma.QuestionMarkVariable]

        subs;
            NullVariable : PSVariable, IHasSessionStateEntryVisibility
            PSVariable : object, IHasSessionStateEntryVisibility

    #>

    $meta = @{
        IsLocal =  ''
        IsGlobal = ''
        IsTypeX = ''
        IsAccess = '[internal|public]'
        Modifiers = '[class]'
    }
}

function Dotils.Is.DirectPath {
    <#
    .SYNOPSIS
        currently just used for Env vars, could be extended to scalars
    .NOTES
        handling multiple falsy values and negating the negation if present made the code slightly longer than expected

    it works even a UNC Pipe names
    .EXAMPLE

    gci env: | Dotils.Is.DirectPath

        Name                           Value
        ----                           -----
        ALLUSERSPROFILE                C:\ProgramData
        APPDATA                        C:\Users\cppmo_000\AppData\Roaming
        CHROME_CRASHPAD_PIPE_NAME      \\.\pipe\LOCAL\crashpad_25500_UMCQTPRWURZIJSPF
        CommonProgramFiles             C:\Program Files\Common Files
        CommonProgramFiles(x86)        C:\Program Files (x86)\Common Files
        CommonProgramW6432             C:\Program Files\Common Files
        ComSpec                        C:\WINDOWS\system32\cmd.exe
        DriverData                     C:\Windows\System32\Drivers\DriverData
        HOMEDRIVE                      C:
        HOMEPATH                       \Users\cppmo_000
        Legacy_Nin_Dotfiles            C:\Users\cppmo_000\SkyDrive\Documents\2021\dot
        Legacy_Nin_Home                C:\Users\cppmo_000\SkyDrive\Documents\2021
    #>
    [Alias('.Is.DirectPath')]
    param(
        # invert logic
        [Alias('Not')]
        [switch]$IsNotADirectory
    )
    process {
        $curItem = $_
        if( -not $PSBoundParameters.ContainsKey('IsNotADirectory') ) {
            $curItem | ?{
                $path? = $_.Value ?? $_
                Test-Path -LiteralPath $Path?
            }
            return
        }

        $curItem | ?{
            $path? = $_.Value ?? $_
            -not ( Test-Path -LiteralPath $Path? )
        }
        return

    }
}
function Dotils.Is.Not {
    <#
    .synopsis
        negate from the pipeline, sometimes cleaner in the shell than requiring parens
    .description
        why? Sometimes it's easier, in the console, where you start with this:
            $error | ? { .Is.Blank $_.Message }

        Instead of using
            $error | ? { -not ( .Is.Blank $_.Message ) }

        you can use:
            $error | ? { .Is.Blank $_.Message | .Is.Not }
    .link
        Dotils.Is.Blank
    .link
        Dotils.Is.Not
    #>
    [Alias('.Is.Not')]
    param(
        [AllowNull()]
        # [AllowEmptyString()]
        # [AllowEmptyCollection()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    process {
        if($MyInvocation.ExpectingInput) {
            foreach($item in $InputObject) {
                -not ( $item )
            }
        }

    }
    end {
        if(-not $MyInvocation.ExpectingInput) {
            foreach($item in $InputObject) {
                -not ( $item )
            }
        }
    }
}
function Dotils.Is.SubType {
    <#
    .synopsis
        Is LHS a subclass of RHS? Optionally treat the same type as true
    .DESCRIPTION


        when used in a pipeline, it filters as a where,
        when used as a function, returns boolean
    #>
    [Alias('.Is.SubType')]
    [CmdletBinding()]
    param(
        # type as a [type] or [string]
        [Parameter(Mandatory)]
        [object]$OtherType,


        # base to compare
        [ArgumentCompletions(
            "([Exception])", "([ErrorRecord])", "([Text.Encoding])" )]
        [Parameter(Mandatory, ValueFromPipeline)]
            $InputObject,

        # by default, if both sides are the same class or  LHS is a subclass, return true
        [switch]$Strict
    )
    process {
        if($InputObject -is 'type') {
            $Tinfo = $InputObject
        } elseif($InputObject -isnot 'string') {
            $Tinfo = $InputObject.GetType()
        } else { throw 'unhandled type [string]' }
        $trueSubclass = $Tinfo.IsSubClassOf( $OtherType )
        $equivalentClass = $false
        if($Strict) {
            $isGood = $trueSubclass
        } else {
            write-warning '$equivalentClass part NYI'
            $isGood = $trueSubClass -or $equivalentClass
        }
        if(-not $MyInvocation.ExpectingInput) {
            return $isGood }
        if($IsGood){
            $InputObject }
    }
}

function Dotils.Is.SubType.NYI {
    <#
    .synopsis

    .NOTES
        if pipeline, then it filters. if not, then it returns the result
    .EXAMPLE
    # basically so you can test this
        [ParseException] -is [Exception]
    .example
        [System.IO.IOException].IsSubclassOf( [System.Exception] )
        # True
    #>
    [Alias('.Is.SubType')]
    [OutputType('bool')]
    param(
        # string, or typeinfo
        [ArgumentCompletions(
            "[Exception]", "[ErrorRecord]", "[Text.Encoding]"
        )]
        [Parameter(Mandatory)]
        [object]$OtherType,


        # Type or Instance of a type
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        # if both sides are the same class, also include it
        [switch]$AllowEquals

    )
    process {
        if($InputObject -is 'type') {
            $Tinfo = $InputObject
        } elseif($InputObject -isnot 'string') {
            $Tinfo = $InputObject.GetType()
        } else { throw 'can''t handle strings yet?' }

        $isTrue = $Tinfo.IsSubClassOf( $OtherType )
        if(-not $MyInvocation.ExpectingInput) {
            return $isTrue
        }
        if($IsTrue) { return $InputObject }
    }
}


function Dotils.Help.FromType {
    <#
    .synopsis
        Opens the docs for the current type, in your default browser
    .description
       copied from:
            Ninmonkey.Console\HelpFromType.2

       It uses 'Get-Unique -OnType' so you only get 1 result for duplicated types
    .notes
        you can always fallback to the url
            https://docs.microsoft.com/en-us/dotnet/api/
    .example
          PS> [math]::Round | HelpFromType -PassThru -infa 'Continue'
    .outputs
          [string | None]
    .link
        Ninmonkey.Console\Format-TypeName
    .link
        Ninmonkey.Console\Get-ObjectTypeHelp

    #>
    [Alias(
        '.Help.FromType'
    # '?Type'
    )]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object]$InputObject,

        # Return urls, without opening them
        [Parameter()]
        [switch]$PassThru
    )

    begin {
        [Collections.Generic.List[object]]$NameList =  @()
        $TemplateUrl = 'https://docs.microsoft.com/en-us/dotnet/api/{0}'
        @'
    bug:

        https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=net-6.0


'@ | Out-Null

    }
    process {
        if ( [string]::IsNullOrWhiteSpace($InputObject) ) {
            return
        }
        # if generics cause problems, try another method

        # Management.Automation
        # if ($InputObject -is 'Management.Automation.PSMethod') {
        # todo: refactor to a ProcessTypeInfo -Passthru
        # This function just asks on that
        if ($InputObject -is 'System.Management.Automation.PSMethod') {
            'methods not completed yet' | Write-Host -fore green
            $funcName = $InputObject.Name
            <#
    example state from: [math]::round | HelpFromType
        > $InputObject.TypeNameOfValue

            System.Management.Automation.PSMethod

        > $InputObject.GeTType() | %{ $_.Namespace, $_.Name -join '.'}

            System.Management.Automation.PSMethod`1

        > $InputObject.Name

            Round

    #>
            $maybeFullNameForUrl = $InputObject.GetType().Namespace, $InputObject.Name -join '.'
            # maybe full url:
            @(
                $maybeFullNameForUrl | str prefix 'maybe url' | Write-Color yellow
                $funcName | Write-Color yellow
                $InputObject.TypeNameOfValue | Write-Color orange
                $InputObject.GeTType() | ForEach-Object { $_.Namespace, $_.Name -join '.' } | Write-Color blue
            ) | Write-Information
            $NameList.add($maybeFullNameForUrl)
            return

        }
        if ($InputObject -is 'type') {
            $NameList.Add( $InputObject.FullName )
            $NameList.Add( @(
                    $InputObject.Namespace, $InputObject.Name -join '.'
                ) )
            return
        }
        if ($InputObject -is 'string') {
            $typeInfo = $InputObject -as 'type'
            $NameList.Add( $typeInfo.FullName )
            return
        }

        $NameList.Add( $InputObject.GetType().FullName )
    }
    end {
        # '... | Get-Unique -OnType is' great if you want to limit a list to 1 per unique type
        # like 'ls . -recursse | Get-HelpFromTypeName'
        # But I'm using strings, so 'Sort -Unique' works
        $NameList
        | Sort-Object -Unique
        | ForEach-Object {
            $url = $TemplateUrl -f $_

            "Url: '$url' for '$_'" | Write-Debug

            if ($PassThru) {
                $url; return
            }
            Start-Process -path $url
        }
    }
}





function Dotils.Distinct {
    <#
    .SYNOPSIS
        get sorted, distinct list of objects
    #>
    [Alias('.Distinct')]
    param(
        [object]$Property
    )
    $splat = @{ Unique = $true }
    if($PSBoundParameters.ContainsKey('PropertyName')){
        $splat.Property = $Property
    }
    $Input | Sort-Object @splat
}
function Dotils.Is.Blank {
    <#
    .synopsis
        tests for empty values, blanks
    #>
    [Alias('.Is.Blank')]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        # Only retury true when it's a true null
        [switch]$TrueNull,

        # only return true for empty collection or empty string
        [switch]$TrueEmpty


    )
    process {
        if($TrueNull) {
            return $null -eq $InputObject
        }
        if($TrueEmpty) {
            return [string]::IsNullOrEmpty( $InputObject )
        }
        return [string]::IsNullOrWhiteSpace( $InputObject )
    }
}
function Dotils.Has.Property {
    <#
    .SYNOPSIS
    .does a property exist? is it not blank ?
    .EXAMPLE
        $error
            | .Has.Prop -PropertyName 'InvocationInfo' | %{ $_.Exception }
            | Dotils.ShortString.Basic -maxLength 120 | Join.UL
    .EXAMPLE
        $error
            | .Has.Prop -PropertyName 'InvocationInfo'
            | Join-String { $_ | Dotils.ShortString -maxLength 120 } -sep (hr 1 )
    .EXAMPLE
        $error | .Has.Prop -PropertyName 'InvocationInfo' -AsTest
    .EXAMPLE
        .EXAMPLE
        $raw_agil = ConvertFrom-HTML -Content $response.Content -Engine AgilityPack  -Raw
        $listOfNamesToHide = $raw_agil
                | Dotils.Find.Property.Basic -TestKind Long.Value -NameOnly
    .LINK
        Dotils.Has.Property
    .LINK
        Dotils.Has.Property.Regex
    #>
    [Alias('.Has.Prop')]
    [CmdletBinding()]
    param(
        [Alias('Name')][Parameter(Mandatory, Position=0)]
        [string]$PropertyName,

        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter(Position = 1)]
        [ValidateSet(
            'Exists',
            'IsNotBlank',
            'IsNull', 'IsNotNull',
            'IsBlank',
            'IsNull.AndExists',
            'IsTrue.Bool',
            'IsTrue.Null',
            'Long.Value',
            'Short.Value'
        )]
        [string]$TestKind = 'Exists',

        # returns bool instead
        [Alias('Test')][switch]$AsTest
    )
    begin {
        $Config = nin.MergeHash -OtherHash $Options -base @{
            LongTextThreshold = 120
            ShortTextThreshold = 60
        }
    }

    process {
        # $toKeep     = $false
        $exists     = $InputObject.PSObject.Properties.Name -contains $PropertyName
        $PropValue  = ($InputObject)?.$PropertyName
        $isNotBlank = -not [string]::IsNullOrWhiteSpace( $PropValue )
        $isBlank    = [string]::IsNullOrWhiteSpace( $PropValue )
        $isTrueNull = $null -eq $PropValue

        switch($TestKind){
            'Exists' {
                if($AsTest) { return $exists }
                if($exists) { return $InputObject }
            }
            'IsNotBlank' {
                if($AsTest) { return $isNotBlank }
                if($IsNotBlank) { return $InputObject }
            }
            'IsTrue.Bool' {
                $isTrueBool =
                    ($null -ne $PropValue) -and ($PropValue -is 'bool')

                if($AsTest) { return $IsTrueBool }
                if($IsTrueBool) { return $InputObject }
            }
            'IsTrue.Null' {
                $isTrueNull = $null -eq $PropValue
                if($AsTest) { return $IsTrueNull }
                if($isTrueNull) { return $InputObject }
            }
            'IsBlank' {
                if($AsTest) { return $IsBlank }
                if($IsBlank) { return $InputObject }
            }
            'IsNull' {
                if($AsTest) { return $isTrueNull }
                if($isTrueNull) { return $InputObject }
            }
            'IsNotNull' {
                if($AsTest) { return -not $isTrueNull }
                if(-not $isTrueNull) { return $InputObject }
            }
            'IsNull.AndExists' {
                if($AsTest) { return $exists -and $isTrueNull }
                if($exists -and $isTrueNull) { return $InputObject }
            }
            'Long.Value' {
                $isLong = ([string]$PropValue).length -gt $Config.LongTextThreshold
                if($AsTest) { return $isLong }
                if($isLong) { return $InputObject }
            }
            'Short.Value' {
                $isLong = ([string]$PropValue).length -lt $Config.ShortTextThreshold
                if($AsTest) { return $isLong }
                if($isLong) { return $InputObject }
            }
            default { throw "UnhandledTestKind: '$TestKind'"}
        }
    }
}
function Dotils.Has.Property.Regex {
    <#
    .LINK
        Dotils.Has.Property
    .LINK
        Dotils.Has.Property.Regex
    #>
    [Alias('.Has.Prop.Regex')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [Alias('Name')]
        [Parameter(Mandatory)]
        [string]$PropertyName,

        [switch]$AsRegex
    )
    process {
        $InputObject | ?{
            if(-not $AsRegex) {
                $_.PSObject.Properties.Name -contains $PropertyName
                return
            }
            ($_.PSObject.Properties.Name -match $PropertyName).count -gt 0
        }

    }
}

function Dotils.LastOut {
    [Alias('LastOut')]
    # append contents to time based rotate
    param(
        # if false, path is always 0, else rotates 0 to modulus
        [switch]$Rotate,
        # auto open in vs code
        [switch]$AutoOpen
    )
    $Config = @{
        Mod = 10
        LogPrependDate = $true
    }
    if($Rotate) {
        $suffix = (get-date).Second % $Config.Mod
    }
    $pathCycle = 'temp:\lastOut_{0}.txt' -f @(
        $rotate ? $suffix : '0'
    )

    Add-Content -Path $PathCycle -Value @(
        "`n"
        '### {0} ###' -f @(
            (Get-Date).ToString('o')
        )
        "`n"
    )

    Add-Content -Value @( $Input ) -Path $PathCycle

    $item = Get-Item -ea 'stop' $PathCycle
    $Item | Join-String -f "  => wrote: '{0}'"
        | Dotils.Write-DimText
        | wInfo

    if($AutoOpen) {
        code -g (gi -ea 'stop' $Item)
    }

}

function Dotils.Find.Property {
    [CmdletBinding()]
    param(
        [Alias('Name')][Parameter(Mandatory, Position=0)]
        [string]$PropertyName,

        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter(Position = 1)]
        [ValidateSet(
            'Exists',
            'IsNotBlank'
            # 'IsNull', 'IsNotNull',
            # 'IsBlank',
            # 'IsNull.AndExists',
            # 'Long.Value',
            # 'Short.Value'
        )]
        [string]$TestKind = 'Exists',

        # returns bool instead
        [Alias('Test')][switch]$AsTest
    )
    throw 'this will be the less stable version. for that, see:  [Dotils.Find.Property.Basic]'
}
Function Dotils.Find.Property.Basic {
    <#
    .SYNOPSIS
        Query for properties using filters
    .EXAMPLE
        $raw_agil = ConvertFrom-HTML -Content $response.Content -Engine AgilityPack  -Raw
        $listOfNamesToHide = $raw_agil
                | Dotils.Find.Property.Basic -TestKind Long.Value -NameOnly
    #>
    param(
        [ValidateSet(
            'Exists',
            'IsNotBlank',
            'IsNull', 'IsNotNull',
            'IsBlank',
            'IsNull.AndExists',
            'IsTrue.Bool',
            'IsTrue.Null',
            'Long.Value',
            'Short.Value'
        )]
        [string]$TestKind = 'IsNotNull',

        [switch]$NameOnly
    )
    process {
        $target = $_
        $props = $target
            | Ninmonkey.Console\Inspect-ObjectProperty
            | Dotils.Has.Property -PropertyName Value -TestKind $TestKind
            | Sort-Object Name

        if($NameOnly) {
            return $Props.Name
        }
        return $Props
            # $raw_agil | io | ?{
            #         $_ | Dotils.Has.Property -PropertyName 'Value' -TestKind 'Long.Value'
            #     }
            #     | select * -exclude 'Value'

    }

}


function Dotils.Add.IndexProp {
    <#
    .SYNOPSIS
        add an index property to each object in the chain, starting at 0
    .example
        gci ~
            | Sort-Object LastWriteTime -Descending | .Add.IndexProp
            | Sort-Object Name | ft Name, Index, LastWriteTime
    #>
    [Alias('.Add.IndexProp')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$items = @()
        $INdex = 0
    }
    process {
        $items.AddRange(@( $InputObject ))
    }
    end {
        $Items | %{
            $_
                | Add-Member -NotePropertyName 'Index' -NotePropertyValue ($Index++) -Force -PassThru -ea 'ignore'
        }
    }
}

function Dotils.Join-Str.Alias {
    <#
    .SYNOPSIS
        render aliases
    #>
    [Alias('.JoinStr.Alias')]
    param(
        [ValidateSet(
            'Shortest','Full',
            'Name,Command',
            'Name,CommandFullName'
        )]
        [string]$OutputFormat,

        # is [AliasInfo] : [CommandInfo]
        [Alias('Alias')]
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject

    )
    begin {
        # 'write-warning NYI: Left off wip' | write-warning
    }
    process {
        # $InputObject  # is [AliasInfo] : [CommandInfo]

    switch($OutputFormat){
        'Shortest' {
            $_.Name
        }
        'Full' { }
        'Name,Command' { }
        'Name,CommandFullName' { }
        default {
            throw "UnhandledFormatType: '$OutputFormat'"
        }
    }
    }
}
#     function .Join.Alias {
# }
# Set-Alias '.Short.Type' -Value Ninmonkey.Console\Format-ShortTypeName -PassThru | %{
#     $_.Name
# } |Join.UL

# }

function Dotils.Ansi {
    param(
        [Parameter(Position=0)]
        [Management.Automation.OutputRendering]$Mode,

        [switch]$Enable, [switch]$Disable, [switch]$HostOut
    )
    if( $PSBoundParameters.ContainsKey('Mode') ) {
        $PSStyle.OutputRendering = $mode
    }

    if($HostOut)  {
        $PSStyle.OutputRendering = 'Host'
    }
    if($Disable) {
        $PSStyle.OutputRendering = 'PlainText'
    }
    if($Enable) {
        $PSStyle.OutputRendering = 'ansi'
    }
}

function Dotils.Summarize.CollectionSharedProperties {
    <#
    .EXAMPLE
        $sampleItems | .Summarize.SharedProperties
        $sampleItems | .Summarize.SharedProperties  |ft
    #>
    [Alias('.Summarize.SharedProperties')]
    param(
        # assume string. maybe sb
        [ValidateNotNullOrEmpty()]
        [Parameter()]
        [ArgumentCompletions('Count', 'Name')]
        [object]$SortBy = 'Name',

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [switch]$WithValues

    )
    begin {
        write-warning 'NYI, Todo, future, next: I think it crashed in the middle of writing this.'
        [Collections.Generic.List[Object]]$items = @()
    }
    process {
       $items.AddRange(@( $InputObject ))
    }
    end {

        if(-not $WithValues) {
            $Items
                | .Iter.Prop -NameOnly
                | Group -NoElement
                | Sort-Object $SortBy
            return
        }


        $Items
            | .Iter.Prop -NameOnly
            | Group -NoElement
            | Sort-Object Name
            | %{
                # is [Microsoft.PowerShell.Commands.GroupInfoNoElement] : [Microsoft.PowerShell.Commands.GroupInfo]
                $curName = $_.Name
                # $Items
                #     | .Iter.Prop
                #     | ?{ $_.Name -eq $curName }
                #     | Join-String { $_.Value } -sep ', '
                    # | % Value
                [string]$renderValues =
                    $Items
                        | .Iter.Prop
                        | ?{ $_.Name -eq $curName } | Sort-Object Name -Unique
                        | Join-String { $_.Value } -sep ', '

                $record = [ordered]@{
                        PSTypeName = 'Dotils.Summarize.SharedProperties.WithValues'
                        Count = $cur.Count
                        Name = $cur.Name
                        Values = $renderValues
                }
                [pscustomobject]$record

            }

                    # | .Iter.Prop -NameOnly
                # | Group -NoElement
                # | Sort-Object $SortBy
                # | %{
                #     [pscustomobject]@{
                #         PSTypeName = 'Dotils.Summarize.SharedProperties.WithoutValues'
                #         Count = $cur.Count
                #         Name = $cur.Name
                #     }
                # }

            # return

            # if ($false -and 'old mode') {
            #     $Items
            #         | .Iter.Prop -NameOnly
            #         | Sort-Object $SortBy
            #         | Group -NoElement
            #         | %{
            #             [pscustomobject]@{
            #                 PSTypeName = 'Dotils.Summarize.SharedProperties.WithoutValues'
            #                 Count = $cur.Count
            #                 Name = $cur.Name
            #             }
            #         }

            #     return
            # }


        # $Items
        #     | .Iter.Prop -NameOnly
        #     | Sort-Object $SortBy
        #     | Group -NoElement
        # | %{
        #    $cur = $_

        #     # Group  # is [Collection<PSObject>]
        #     # Values # is [ArrayList]
        #     [pscustomobject]@{
        #         PSTypeName = 'Dotils.Summarize.SharedProperties.WithValues'
        #         Count = $cur.Count
        #         Name = $cur.Name
        #         Values =  @(
        #             $Items
        #             | %{
        #                 $_[ $cur.Name ]
        #             }
        #         ) | Join-String -sep ' '
        #     }
        # }
    }

    # return

    #   @( get-alias 'ls' ; gcm  '*dim*' )
    #     | .Iter.Prop -NameOnly | Sort-Object Name | Group -NoElement | %{
    #     $info = @{
    #     $_.Count
    #     }

    # @( get-alias 'ls' ; gcm  '*dim*' )
    #     | .Iter.Prop -NameOnly | Sort-Object Name | Group -NoElement


}
function Dotils.Iter.Text {
    <#
    .EXAMPLE
        # You can create some weird combinations

        Get-Date | .Iter.Text Colon | Join.UL

        - 8/6/2023 7
        - 30
        - 06 PM
    .example
        $sample = '  hi world  '
        $sample
            | .Iter.Text -IterationKind Trim
            | Join-string -SingleQuote
            | Should -BeExactly $( "'{0}'"  -f $sample.Trim() )
    .example
        'hi<world,<zed'  | .Iter.Text CustomDelim -OptionalArgument ','
            # out: 'hi<world', '<zed'

        'hi<world,<zed'  | .Iter.Text CustomDelim -OptionalArgument '<'
            # out: 'hi', 'world,', 'zed'

    #>
    [Alias('.Iter.Text')]
    param(
        [Alias('Kind')]
        [ValidateSet(
            'Char',
            'Trim',
            'Words',
            'Commas',
            'Lines',
            'Grapheme',
            'NonWhitespace',
            'Numbers',
            'RegexSplit',
            'Rune',
            'Rune',
            'Sentence',
            'Delim;',
            'Semicolon',
            'Delim:',
            'DelimCustom',
            'DelimComma',
            'Csv',
            'Delim,',
            'NonAscii',
            'ControlChars',
            'CustomDelim',
            'Colon'
        )]
        [string]$IterationKind = 'Rune',

        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        [Alias('Args', 'Value1')][Parameter()]
        $OptionalArgument
    )
    process {
        $cur = $_.ToString()
        switch($IterationKind) {
            'Rune' {
                return $cur.EnumerateRunes()
            }
            'Char' {
                return $cur.ToCharArray()
            }
            'RegexSplit' {
                return $cur -split ''
            }
            'NonAscii' {
                throw 'the split non ascii regex'
            }
            'ControlChars' {
                throw 'the split control char regex'
            }
            'Trim' {
                return $cur.trim()
            }
            'Lines' {
                return $cur -split '\r?\n'
            }
            'Sentence' {
                return $cur -split '([\.,;\n])'  #  '([\.\,;\n])'
            }
            { $_ -in @(
                'Commas', 'Csv',
                'Delim,', 'DelimComma'
            ) } {
                return $cur -split ',\s*'
            }
            { $_ -in @(
                'CustomDelim',
                'DelimCustom' ) } {
                if(-not $PSBoundParameters.ContainsKey('OptionalArgument')) {
                    throw 'Dotils.Iter.Text<proc> MissingMandatoryArgument: $OptionalArgument for [ CustomDelim | DelimCustom ]'
                }
                return $cur -split $OptionalArgument # @($OptionalArgument)[0]
            }
            { $_ -in @(
                'Delim;',
                'Semicolon') } {
                return $cur -split ';'
            }
            { $_ -in @(
                'Delim:',
                'Colon') } {
                return $cur -split ':'
            }
            'Words' {
                return $cur -split '\s+'
            }
            'Numbers' {
                return $cur -split '\D+'
            }
            'NonWhitespace' {
                return $cur -split '\s+'
            }
            'Grapheme' {
                throw 'I forget, need to  lookup the func name for graphemes'
                # return $cur.EnumerateGraphemes()
            }
            default {
                throw "UnhandledIterationKind: '$IterationKind'"
            }
        }

    }
}
function Dotils.Iter.Enumerator {
    <#
    .SYNOPSIS
        get enumerator for each object in the pipeline
    .EXAMPLE
        $dict_o = [ordered]@{ 'z' = 'first'; 'name' = 'bob' ; 'area' = 'north' }
        $hash = @{ 'z' = 'first'; 'name' = 'bob' ; 'area' = 'north' }

    # no auto-enumeration, therefore sort fails

        $dict_o
            | sort Name
        $hash
            | sort Name

    # now both sort
        $dict_o = [ordered]@{ 'z' = 'first'; 'name' = 'bob' ; 'area' = 'north' }
        $hash = @{ 'z' = 'first'; 'name' = 'bob' ; 'area' = 'north' }

        $dict_o
            | .Iter.Enumerator
            | sort Name
        $hash
            | .Iter.Enumerator
            | Sort Name

    #>
    [Alias('.Iter.Enumerator')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    process {
        $Obj = $_
        try {
            $Obj.GetEnumerator()
        } catch {
            '.Iter.Enumerator: Object failed enumeration, emitting original object! '
                | write-error -ea 'continue'
            $Obj
        }
    }
 }
write-warning 'fix: Dotils.Iter.Prop'
function Dotils.Iter.Prop {
    <#
    .SYNOPSIS
        default return is: [PSMemberInfoCollection[PSPropertyInfo]]
    .examples
        get-module Dotils | .Iter.Prop | ?{ Test-Path $_.Value  } # some errors because of: param was null or empty


    .NOTES
        - future: remember certain properties to ignore
        future: todo: ugit is throwing errors on enumeration
            for some commands, like piping to .Iter.Prop then Format-list
        it happens on

                @( gi . ; get-item C:\Users\cppmo_000\.bash_history ; )
                    | .Iter.Prop

            'ReferencedMemberName' = 'GitDirty', 'GitChanges', 'GitDiff', etc
                properties that are from ugit, but the user still sees the errors:
                    'C:\Users\cppmo_000' is not a git repository



    #>
    [CmdletBinding()]
    [OutputType(
        '[PSMemberInfoCollection[PSPropertyInfo]]',
        'String',
        # aka
        'Management.Automation.PSMemberInfoCollection[Management.Automation.PSPropertyInfo]'
    )]
    [Alias('.Iter.Prop')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # changes return type to be the property names only.
        # It can be significantly faster, depending on the type
        # combinations of gci with ugit 0.4, or active directory, etc
        # fast. skips any work, like combining
        [switch]$NameOnly,

        # skip any properties that are blankscoerce
        [switch]$DropBlankValues,

        # skip any properties that are nulls
        [switch]$DropNullValues,


        [string]$IgnoreSet = 'ugit'
    )
    process {
        if($NameOnly) {
            return $InputObject.PSObject.Properties.Name
                | Sort-Object -Unique:$false
        }
        $InputObject.PSObject.Properties
            | ?{
                $toKeep = $true
                if($DropBlankValues) {
                    $toKeep = $toKeep -and $_.Value -ne ''
                }
            }
            | Sort-Object Name -Unique:$false
    }
}

function Dotils.Iter.Keys {
    <#
    .SYNOPSIS
        sugar to implicitly enumerate hashtables or enumerable objects
    #>
    [Alias(
        '.Iter.Keys',
        '.Keys',
        '%Keys'
    )]
    param()
    process {
        $Obj = $_
        if($obj -is 'hashtable' -or ($Obj | .Has.Property -Prop 'Keys' -asTest)) {
            return $Obj.Keys
        }
        return $Obj.GetEnumerator()
    }
}
function Dotils.Cliboard.FixText {
    [CmdletBinding( SupportsShouldProcess,ConfirmImpact='low')]
    param(
        # [string]$TransformType = 'Trimp'
        [switch]$Append = $false,
        [switch]$PassThru = $True
    )
    process {
        $origValue = Get-Clipboard -Raw
        # replace with dotils funcs, quick hack
        $accum = $accum -replace '\s+', ''

        $origValue | fcc | Label 'was'
        $accum | fcc | Label 'new'
        write-warning 'nyi: error, throw this does not stop'


        if ($PSCmdlet.ShouldProcess("Write", "Clippy")) {
            $accum | Set-Clipboard -PassThru:$PassThru -Append:$Append
        }
    }
}

function Dotils.Quick.PSTypeNames {
<#
.notes
original command was
    $MyInvocation.MyCommand.ScriptBlock.Ast.EndBlock.Statements.PipelineElements | %{
    $mine = $_.PSTypenames
    $mine | Format-ShortTypeName | Join-String -sep ', '
    }

        $MyInvocation.MyCommand.ScriptBlock.Ast.EndBlock.Statements.PipelineElements | %{ $_ | % pstypenames | Join.UL} | Join-String -sep (hr 1)

#>
    [Alias('.quick.PSTypes')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject

    )
    process {
        $InputObject | %{
            $_.PSTypeNames
            $mine = $_.PSTypenames
            $render = $mine | Format-ShortTypeName | Join-String -sep ', '
            return $render
        }

    }
}


function Dotils.Join.Csv {
    # Sugar for CSv. Can't get much simpler than that
    [Alias('.Join.Csv', 'Join.Csv', 'Csv')]
    param(
        [switch]$Unique,
        [string]$Separator = ', '
    )
    if($Unique) {
        $Input | Sort-Object -Unique | Join-String -sep $Separator
        return
    }
    $Input | Join-String -sep $Separator

}
function Dotils.ConvertTo-TimeSpan {
    <#
    .DESCRIPTION
        todo: future: - [ ] make an [ArgTransformation] which uses this, but still expose this Cmdlet
    .EXAMPLE
        Measure-BasicScriptBlockExecution -ScriptBlock { get-module | outnull }
            | Ms # outputs: 9.61 ms
    #>
    [OutputType('Timespan', 'int')]
    [Alias(
        'Dotils.ConvertTo.TimeSpan',
        '.as.Timespan', '.To.TimeSpan'
    )]
    param()
    process {
        $Obj = $_

        $timespan? = if( $Obj -is 'timespan') {
            return $Obj
        } elseif ( $Obj.Time -is 'timespan') { # benchpress
            return $Obj.Time
        } elseif( $Obj.Duration -is 'timespan') {
            return $Obj.Duration
        } elseif( $Obj.Elapsed -is 'timespan') {
            return $Obj.Elapsed
        } else {
            write-warning 'No automatic timespan found, searching...'
            throw "Unexpected type: $( $Obj | Format-ShortTypeName )"
        }
        return $timespan?
    }
}

function Dotils.Regex.Match.End {
    <#
    .SYNOPSIS
        filters items from the pipeline, else, returns a boolean when not
    .notes
        could consolidate into one command as aliases
        todo: future: nyi: accept property name of object without drilling manually
            - [ ]
    ux:
        - auto attempts property '.name' even if none are specified
    .example
        gci . | .Match.End -Pattern 'r' -PropertyName name
        gci . | .Match.End -Pattern 'r'

    .example
        .to.Encoding -List
            | .Match.End ibm -PropertyName Name

        .to.Encoding -List
            | .Match.End ibm

    .LINK
        Dotils.Regex.Match.Start
    .LINK
        Dotils.Regex.Match.End
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Match.End', '.Match.Suffix')]
    param(
        # regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsRegex')]
        [Alias('Regex', 'Re')]
        [string]$Pattern,

        # literals escaped for a regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        [string]$Literal,

        # If not set, and type is not string,  tostring will end up controlling what is matched against
        [Parameter(Position=1)]
        [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        # when no property is specified, usually nicer to try the property name than tostring
        [switch]$AlwaysTryProp = $true
    )
    process {
        # refactor: shared: [9e4642a]: resolveRegexOrLiteral(..).with_escapeLiterals()
        switch($PSCmdlet.ParameterSetName){
            'AsLiteral' {
                $buildRegex = [Regex]::Escape( $Literal )
            }
            'AsRegex' {
                $buildRegex = $Pattern
            }
        }
        # refactor: shared: [9321j523: build_regex(..).with_wordBoundaries().with_escapedLiterals()
        $buildRegex = Join-String -f "({0})$" -inp $buildRegex
        # refactor: shared: [0380cfb0]: resolveProperty( $InpObj ).with_default('Name').else_throw()
        if( $AlwaysTryProp -and (-not $PSBoundParameters.ContainsKey('PropertyName'))) {
            $PropertyName = 'Name'
        }
        if($PropertyName) {
            if( .Has.Prop -Inp $InputObject $PropertyName -AsTest | .is.Not ) {
                "object has no property named $PropertyName'"  | write-error
            }
            $Target = $Inputobject.$PropertyName
        } else {
            $Target = $InputObject
        }

        # if($null -eq $Target) { return }
        if( [string]::IsNullOrEmpty( $Target ) ) { return }

        [bool]$shouldKeep = $target -match $buildRegex
        $script:matchesNin = $matches
        [ordered]@{
            Regex  = $BuildRegex
            Name   = $PropertyName ?? "`u{2400}"
            Keep   = $ShouldKeep
            Target = $Target.ToString() # perf bonus and simplifies output of fileinfo
        } | ft -auto -HideTableHeaders | out-string | write-debug
        # } | Json -Compress -depth 2 | write-debug

        if( -not $MyInvocation.ExpectingInput ) {
            return $shouldKeep
        }
        if($shouldKeep){
            $InputObject
        }
    }
}
function Dotils.Regex.Match.Start {
    <#
    .SYNOPSIS
        filters items from the pipeline, else, returns a boolean when not
    .notes
        todo: future: nyi: accept property name of object without drilling manually
            - [ ]
    .example
        gci . | .Match.Start -Pattern 'r' -PropertyName name
    .example
        'the cat, in the hat' -split '\s+' | .Match.Start '[ch]'
    .example
        $stuff = 'cat' , 'bat', 'tats'
        $stuff | .Match.Start 'c' | Csv
        $stuff | .Match.End 't' | Csv
        $stuff | .Match.End '[ts]' | Csv
        $stuff | .Match.End '[ts]' | .Match.Start 't' | Csv

        # outputs:
            cat
            cat, bat
            cat, bat, tats
            tats
    .example
        'cat', 'bat', 'bag' | .Match.Start 'b'
        '$bag','cat', 'bat', 'bag' | .Match.Start 'b.*' -Debug
        '$bag','cat', 'bat', 'bag' | .Match.Start -Literal 'b.*' -Debug
    .LINK
        Dotils.Regex.Match.Start
    .LINK
        Dotils.Regex.Match.End
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Match.Start', '.Match.Prefix')]
    param(
        # regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsRegex')]
        [Alias('Regex', 'Re')]
        [string]$Pattern,

        # literals escaped for a regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        [string]$Literal,

        # If not set, and type is not string,  tostring will end up controlling what is matched against
        [Parameter(Position=1)]
        [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        # when no property is specified, usually nicer to try the property name than tostring
        [switch]$AlwaysTryProp = $true
    )
    process {
        # refactor: shared: [9e4642a]: resolveRegexOrLiteral(..).with_escapeLiterals()
        switch($PSCmdlet.ParameterSetName){
            'AsLiteral' {
                $buildRegex = [Regex]::Escape( $Literal )
            }
            'AsRegex' {
                $buildRegex = $Pattern
            }
        }
        # refactor: shared: [9321j523: build_regex(..).with_wordBoundaries().with_escapedLiterals()
        $buildRegex = Join-String -f "^({0})" -inp $buildRegex

        # refactor: shared: [0380cfb0]: resolveProperty( $InpObj ).with_default('Name').else_throw()
        if( $AlwaysTryProp -and (-not $PSBoundParameters.ContainsKey('PropertyName'))) {
            $PropertyName = 'Name'
        }
        if($PropertyName) {
            if( .Has.Prop -Inp $InputObject $PropertyName -AsTest | .is.Not ) {
                "object has no property named $PropertyName'"  | write-error
            }
            $Target = $Inputobject.$PropertyName
        } else {
            $Target = $InputObject
        }

        # if($null -eq $Target) { return }
        if( [string]::IsNullOrEmpty( $Target ) ) { return }

        [bool]$shouldKeep = $target -match $buildRegex
        $script:matchesNin = $matches

        [ordered]@{
            Regex  = $BuildRegex
            Name   = $PropertyName ?? "`u{2400}"
            Keep   = $ShouldKeep
            Target = $Target.ToString()
        }
        | ft -auto -HideTableHeaders | out-string | write-debug
        # | Json -Compress -depth 2 | write-debug

        if( -not $MyInvocation.ExpectingInput ) {
            return $shouldKeep
        }
        if($shouldKeep){
            $InputObject
        }
    }
}
function Dotils.Regex.Split {
    <#
    .SYNOPSIS

    .notes

    .LINK
        Dotils.Regex.Split
    .LINK
        Dotils.Regex.Match.Start
    .LINK
        Dotils.Regex.Match.End
    #>
    [OutputType('String[]')]
    [CmdletBinding(
        DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Split')]
    param(
        # regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsRegex')]
        [Alias('Regex', 'Re')]
        [string]$Pattern,

        [Parameter(Mandatory, Position=0, ParameterSetName='FromTemplate')]
        [ValidateSet(
            'LineEnding', 'NL', 'NLCR',
            'SegmentCapital'
            # 'Segment.Word',
            # 'Segment.CaseChange'
                )]
        [Alias('As', 'From', 'Template')][string]$AsTemplate,


        # literals escaped for a regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        [string]$Literal,

        # If not set, and type is not string,  tostring will end up controlling what is matched against
        [Parameter(Position=1)]
        [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        # when no property is specified, usually nicer to try the property name than tostring
        [switch]$AlwaysTryProp = $true,

        # maybe dangerous, I am not sure it may not be deterministic using a simple (pattern)*
        [switch]$Greedy,

        # Extra split arg limits max results
        [Alias('Limit','Max')][int]$MaxCount
    )
    process {
        # refactor: shared: [9e4642a]: resolveRegexOrLiteral(..).with_escapeLiterals()
        switch($PSCmdlet.ParameterSetName){
            'AsLiteral' {
                $buildRegex = [Regex]::Escape( $Literal )
            }
            'AsRegex' {
                $buildRegex = $Pattern
            }
        }
        # refactor: shared: [9321j523: build_regex(..).with_wordBoundaries().with_escapedLiterals()
        $buildRegex = Join-String -f "({0})" -inp $buildRegex

        # refactor: shared: [0380cfb0]: resolveProperty( $InpObj ).with_default('Name').else_throw()
        if( $AlwaysTryProp -and (-not $PSBoundParameters.ContainsKey('PropertyName'))) {
            $PropertyName = 'Name'
        }
        if($PropertyName) {
            if( .Has.Prop -Inp $InputObject $PropertyName -AsTest | .is.Not ) {
                "object has no property named $PropertyName'"  | write-error
            }
            $Target = $Inputobject.$PropertyName
        } else {
            $Target = $InputObject
        }

        switch($PSCmdlet.ParameterSetName) {
            'FromTemplate' {
                switch($AsTemplate){
                    { 'LineEnding', 'NLCR' -contains $AsTemplate } { $buildRegex = '\r?\n' }
                    'NL'         { $buildRegex = '\n' }
                    'Csv'         { $buildRegex = ',\s*' }
                    'NLCR'       { $buildRegex = '\r?\n' }
                    'SegmentCapital' { $buildRegex = '(?x-i)(?=[A-Z])'  }
                    # 'Segment.Word' { $buildRegex = '\W+' }
                    # 'Segment.CaseChange' { $buildRegex = '.' }
                    { $true } {
                    }
                    default { "Unexpected Template: $( $AsTemplate )"}
                }
            }
            'AsRegex' {  <# no-op #> }
            default { "Unexpected ParameterSet: $( $PSCmdlet.ParameterSetName )"}
        }

        $buildRegex | Join-string -op "new '$BuildRegex' from tempate '$AsTemplate' " | write-verbose
        if($Greedy) {
            # $buildRegex = Join-String -f "({0})*" -inp $buildRegex
            $buildRegex = Join-String -f "({0})*" -inp $buildRegex # Maybe redundant?
            $buildRegex | Join-string -op "new greedy regex:, maybe redundant parens " | write-verbose
        }
        # if($null -eq $Target) { return }
        if( [string]::IsNullOrEmpty( $Target ) ) { return }

        if($MaxCount -gt 0){
            $splitArgs = @($buildRegex, $MaxCount)
        } else {
            $splitArgs = @($buildRegex)
        }

        [string[]]$result = $target -split $splitArgs
        return $result
    }
}

function Dotils.Regex.Split.Basic {
    <#
    .SYNOPSIS
        minimal argumentcompletions for templates
    .DESCRIPTION
        see 'Dotils.Regex.Split' for more, this is a minimal case example
    .link
        Dotils.Regex.Split
    #>
    [Alias('Regex.Split.Basic')]
    [CmdletBinding()]
    param(
            [Parameter(Mandatory, Position = 0)]
            [ArgumentCompletions('LineEnding', 'NL', 'Csv', 'Whitespace', 'OnlySpaces', 'Words')]
            [string]$PatternOrTemplate,

            [AllowEmptyString()]
            [AllowEmptyCollection()]
            [AllowNull()]
            [Parameter(Mandatory, ValueFromPipeline)]
            [object[]]$InputObject
    )
    process {
        $resolveRegex = switch($PatternOrTemplate) {
            { 'NL', 'LineEnding' -contains $_ } { '\r?\n' }
            'Csv' {         ',\s*' }
            'Whitespace' {  '\s+' }
            'OnlySpaces' {       '[ ]+' }
            'Words' {       '\W+' }
            default { $PatternOrTemplate }
        }
        $InputObject -split $resolveRegex
    }
}

function Dotils.Format.Join-BlockDelim {
    <#
    .SYNOPSIS
        used to join a list of numbers, making them more readable
    .example
        ( .to.Encoding -Name utf-16be ).
           GetBytes( 'hi world', 0, 4 ) | .Fmt.Join-BlockDelim
    .example
        $ency.GetBytes(
            $ency.GetString( $bytes ), 0, 10 )  | .Fmt.Join-BlockDelim
    #>
    [Alias('.Fmt.Join-BlockDelim')]
    param(
        [hashtable]$Options = @{}
    )
    $Config = nin.MergeHash -OtherHash $Options -BaseHash @{
        Text = ' '
        Prefix = ' '
        Suffix = ' '
        Fg = 'gray60'
        Bg = 'gray30'
    }
    $Input | Join-String -f '{0}' -sep (
        $Config.Text | new-text -fg $Config.Fg -bg $Config.Bg
            | Join-string -f (
                $PSStyle.Reset, ' {0} ', $PSStyle.Reset  -join ''
            )
    )
}

function Dotils.Set-Content.AsBytes {
    <#
    .SYNOPSIS
        Sugar to write raw bytes to a filepath
    .example
        Sc.AsBytes readme.md
    .example
        Sc.AsBytes readme.md | .Fmt.Join-BlockDelim

    .link
        Dotils.Get-Content.AsBytes
    .link
        Dotils.Set-Content.AsBytes
    #>
    [alias(
        'Dotils.SetContent.AsBytes',
        'Dotils.SetByteContent',
        'Sc.RawBytes', 'Sc.AsBytes'
    )]

    param(
        [Alias('Path', 'PSPath', 'Name', 'FullName')]
        [string]$InputPath
    )
    $File          = $InputPath
    [byte[]]$bytes = [byte[]]@( $Input )

    if( $bytes -isnot [byte[]] ) {
        throw "InvalidData, expects [byte[]]s as input"
    }
    $Bytes | Set-Content -AsByteStream -LiteralPath $File
    $file = Get-Item $File -ea 'stop'
    'wrote {0:n0} bytes to {1}' -f @(
        $File.Length
        $File.FullName
    ) | Dotils.Write-DimText | Infa
}
function Dotils.Get-Content.AsBytes {
    <#
    .SYNOPSIS
        Sugar to read raw bytes from a filepath
    .example
        Gc.AsBytes readme.md
    .example
        Gc.AsBytes readme.md | .Fmt.Join-BlockDelim

    .link
        Dotils.Get-Content.AsBytes
    .link
        Dotils.Set-Content.AsBytes
    #>
    [alias(
        'Dotils.GetContent.AsBytes',
        'Dotils.GetByteContent',
        'Gc.RawBytes', 'Gc.AsBytes'
    )]
    [OutputType( [System.Byte[]] )]
    param(
        [Alias('Path', 'PSPath', 'Name', 'FullName')]
        [string]$InputPath
    )
    $File = Get-Item -ea 'stop' $InputPath
    Get-Content -AsByteStream -Raw -LiteralPath $File
    'read {0:n0} bytes from {1}' -f @(
        $File.Length
        $File.FullName
    ) | Dotils.Write-DimText | Infa
}


function Dotils.Format.FullName {
    <#
    .SYNOPSIS
        sugar, expands to full name for filepaths and data types
    .example
        find-type 'color' | FullName
    .example
        PS> gci . | FullName
            c:\data\somefile -- with spacing.txt

        PS> gci . | FullName -as Path.Forward
            c:/data/somefile -- with spacing.txt

        PS> gci . | FullName -as Escaped.Md.Path
            c:/data/somefile%20--%20with spacing.txt

        PS> gci . | FullName -as Escaped.Md.Path -filePrefix
            file:///c:/data/somefile%20--%20with spacing.txt
    #>
    [Alias(
        'FullName',
        '.Format.FullName',
        '.fmt.Name'
    )]
    [CmdletBinding()]
    param(
        # Objects
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # Change output types
        [ValidateSet(
            'Path.Forward',
            'Escaped.Md.Path',
            'ShortType'
        )]
        [Alias('As')]
        [string]$OutputType,

        # append to clipboard?
        [Alias('Cl', 'ClipTo')][switch]$AsClipboard,

        # treat as type names
        [Alias('ShortType')][switch]$AsShortType,

        # adds "file:///" protocol prefix
        [Alias('FilePrefix')][switch]$UsingPrefixFileProtocol
    )
    begin {
        [Collections.Generic.List[Object]]$Items  = @()
    }
    process {
        if($InputObject -is 'type'){
            $OutputType = 'ShortType'
        }
        $prefix = if($UsingPrefixFileProtocol) { 'file:///' } else { '' }

        $render = switch($OutputType)  {
            'Escaped.md.Path' {
                ($InputObject | % tostring) -replace
                    '\\', '/' -replace
                    '\s', '%20'
                | Join-String -op $Prefix
            }
            'Path.Forward' {
                ($InputObject | % tostring) -replace '\\', '/'
                | Join-String -op $Prefix
            }
            'ShortType' {
                $InputObject | Format-ShortTypeName
                | Join-String -op $Prefix
            }
            default {
                $InputObject.FullName
                | Join-String -op $Prefix
            }
        }
        if($AsClipboard) {
            $render | Set-Clipboard -PassThru
            return
        }
        $render
    }
    end {
    }

}
function Dotils.Format.WrapWildcards {
    <#
    .synopsis
        oops, already have a similar func, but different<Format.WildCardPattern>
        wrap wildcards, but don't double-star because that isn't valid
    .example
        WrapWild 'cat bat'   => '*cat bat*'
        WrapWild '*cat bat'  => '*cat bat*'
        WrapWild 'cat*bat'   => '*cat*bat*'
        WrapWild ''          => '*'
        WrapWild $Null       => '*'
    .example
        'cat bat' , '*cat bat', 'cat*bat' , '', $Null| %{
        [pscustomobject]@{
            Str = $_
            Rend = Dotils.Format.WrapWildcards -Text $_
        }}
    .link
        Dotils.Format.WrapWildcards
    .link
        Dotils.Format.WildCardPattern
    #>
    param(
        [string]$Text,

        [Alias('LowerCase', 'ToLower')]
        [switch]$ForceLowercase,
        [object]$Culture
    )
    if( [string]::IsNullOrEmpty( $Text ) ) { return '*' }

    $Text = # abusing ternary
        -not $ForceLowerCase ?
            $Text :
                ( $Culture ?
                    $Text.ToLower( $Culture ) :
                    $Text.ToLowerInvariant() )

    $FinalText = @(
        $Text.StartsWith('*') ? '' : '*'
        $Text
        $Text.EndsWith('*') ? '' : '*' ) -join ''

    return $FinalText
}
function Dotils.QuickFindType.SharedNames {
    <#
    .synopsis
        Dotils.QuickFindType.SharedNames -PassThru -NamespacePattern 'text' -WithoutSmartCase -NamePattern 'text'
            # returned 21 items
    .example
        Dotils.QuickFindType.SharedNames -NamespacePattern 'text' -WithoutSmartCase -NamePattern 'text'
            query: Name: *text*, Fullname ␀, Namespace *text*
                => found 21 items
    .example
        Dotils.QuickFindType.SharedNames -NamespacePattern 'text' -WithoutSmartCase -NamePattern 'text'
    #>
    param(
        [ArgumentCompletions(
            'Microsoft.PowerShell*'
        )]
        # wildcard patterns. default wraps them in stars for you
        [Alias('Space', 'SpaceName')]
        [string]$NamespacePattern,
        # wildcard patterns. default wraps them in stars for you
        [Alias('FullName', 'Full')]
        [string]$FullNamePattern,
        # wildcard patterns. default wraps them in stars for you
        [Alias('Name')]
        [string]$NamePattern,

        # return before group by
        [switch]$PassThru,

        [Alias('WithoutSmartCase', 'CompareCI', 'ForceLowercase')]
        [switch]$CompareInsensitive,
        [switch]$WithoutWrappingStars
    )
    if($CompareInsensitive) {
        $FullNamePattern  = $FullNamePattern.ToLowerInvariant()
        $NamePattern      = $NamePattern.ToLowerInvariant()
        $NamespacePattern = $NamespacePattern.ToLowerInvariant()
    }

    if( -not $WithoutWrappingStars ) {
        $FullNamePattern  = Dotils.Format.WrapWildcards $FullNamePattern -LowerCase:$CompareInsensitive
        $NamePattern      = Dotils.Format.WrapWildcards $NamePattern -LowerCase:$CompareInsensitive
        $NamespacePattern = Dotils.Format.WrapWildcards $NamespacePattern -LowerCase:$CompareInsensitive
    }

    $findTypeSplat = @{}
    if( $PSBoundParameters.ContainsKey('NamePattern' ) ) {
        $FindTypeSplat.Name = $NamePattern
    }
    if( $PSBoundParameters.ContainsKey('FullNamePattern' ) ) {
        $FindTypeSplat.FullName = $FullNamePattern
    }
    if( $PSBoundParameters.ContainsKey('NamespacePattern' ) ) {
        $FindTypeSplat.Namespace = $NamespacePattern
    }
    'query: Name: {0}, Fullname {1}, Namespace {2}' -f @(
        $FindTypeSplat.Name      ?? "`u{2400}"
        $FindTypeSplat.FullName  ?? "`u{2400}"
        $FindTypeSplat.Namespace ?? "`u{2400}"
    )

    $query = Find-Type @findTypeSplat
    $query.Count | Join-String -f '     => found {0} items'
    if($PassThru) { return $Query }
    # - | Group Namespace | % Name | sort
}
function Dotils.WriteFg {
    #  Ansi color wrapper
    param( [object]$Color )
    if( [string]::IsNullOrEmpty( $Color ) ) { return }
    $PSStyle.Foreground.FromRgb( $Color )
}
function Dotils.WriteBg {
    #  Ansi color wrapper
    param( [object]$Color )
    if( [string]::IsNullOrEmpty( $Color ) ) { return }
    $PSStyle.Background.FromRgb( $Color )
}
function Dotils.WriteColor {
    #  Ansi color wrapper
    param(
        [object]$ColorFg,
        [object]$ColorBg
    )
    if( [string]::IsNullOrEmpty( $ColorFg ) -and [string]::IsNullOrEmpty( $ColorBg ) ) { return }
    @(  WriteFg $ColorFg
        WriteBg $ColorBg ) -join ''
}

# class NinColor {
#     static [NinColor] ConvertFrom_PStyle ( $FromObject ) {
#         # $PSStyle classes

#     }
#     [string] AsAnsi () {

#     }
# }
function Dotils.Ansi.NewColor {



        #>
    $PSStyle.Foreground.FromRgb('#348856')
    throw 'nyi, see also: Dotils.Format.Write-DimText, Dotils.Ansi.Write'
}

function Dotils.Ansi.Write {
    <#
    .synopsis
        color sugar
    .notes
        see more:
        @( find-type -Namespace 'PoshCode.Pansies' | fullname
            find-type -Namespace 'PoshCode.Pansies' *color* | fullname ) | Sort-Object -Unique

            [Pansies.CmyColor]
            [Pansies.CmykColor]
            [Pansies.ColorMode]
            [Pansies.Entities]
            [Pansies.Gradient]
            [Pansies.Harmony]
            [Pansies.HsbColor]
            [Pansies.HslColor]
            [Pansies.HsvColor]
            [Pansies.HunterLabColor]
            [Pansies.LabColor]
            [Pansies.LchColor]
            [Pansies.LuvColor]
            [Pansies.NativeMethods]
            [Pansies.NativeMethods+ConsoleOutputModes]
            [Pansies.RgbColor]
            [Pansies.Text]
            [Pansies.XyzColor]
            [Pansies.YxyColor]

        see more:
            RgbColor : Rgb, IColorSpace, IRgb, IEquatable<RgbColor>

        PS> find-type -FullName '*PSStyle*' | Format-ShortTypeName
        PS> find-type -FullName '*PSStyle*' | FullName

        PSStyle.ForegroundColor
        [PSStyle]
        [PSStyle+ForegroundColor]
        [PSStyle+BackgroundColor]
        [PSStyle+ProgressConfiguration]
        [PSStyle+FormattingData]
        [PSStyle+FileInfoFormatting]
        [PSStyle+FileInfoFormatting+FileExtensionDictionary]

        # function Dotils.Ansi.Write {
    #     combination of -Fg and -bg
    #>
    [Alias('.Ansi.Fg', '.Ansi.Bg')]
    [CmdletBinding()]
    param(

    )
    # based on alias, automatically knows whether to use fg or bg

    $PSCmdlet.MyInvocation.BoundParameters
        | ConvertTo-Json -Depth 0 -Compress
        | Join-String -op 'Func: '
        | write-verbose -verbose

    throw 'nyi, see also: Dotils.Format.Write-DimText, Dotils.Ansi.Write'

}

function Dotils.Regex.Match.Word {
    <#
    .SYNOPSIS
        filters items from the pipeline, else, returns a boolean when not
    .notes
        does a '\bPattern\b' match
    .example
        gci . | .Match.Start -Pattern 'r' -PropertyName name
    .example
        'the cat, in the hat' -split '\s+' | .Match.Start '[ch]'
    .example
        $stuff = 'cat' , 'bat', 'tats'
        $stuff | .Match.Start 'c' | Csv
        $stuff | .Match.End 't' | Csv
        $stuff | .Match.End '[ts]' | Csv
        $stuff | .Match.End '[ts]' | .Match.Start 't' | Csv

        # outputs:
            cat
            cat, bat
            cat, bat, tats
            tats
    .example
        'cat', 'bat', 'bag' | .Match.Start 'b'
        '$bag','cat', 'bat', 'bag' | .Match.Start 'b.*' -Debug
        '$bag','cat', 'bat', 'bag' | .Match.Start -Literal 'b.*' -Debug
    .LINK
        Dotils.Regex.Match.Start
    .LINK
        Dotils.Regex.Match.End
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Match.Word')]
    param(
        # regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsRegex')]
        [Alias('Regex', 'Re')]
        [string]$Pattern,

        # literals escaped for a regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        [string]$Literal,

        # If not set, and type is not string,  tostring will end up controlling what is matched against
        [Parameter(Position=1)]
        [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        # refactor: shared: [9e4642a]: resolveRegexOrLiteral(..).with_escapeLiterals()
        switch($PSCmdlet.ParameterSetName){
            'AsLiteral' {
                $buildRegex = [Regex]::Escape( $Literal )
            }
            'AsRegex' {
                $buildRegex = $Pattern
            }
        }
        # refactor: shared: [9321j523: build_regex(..).with_wordBoundaries().with_escapedLiterals()
        $buildRegex = Join-String -f "\b({0})\b" -inp $buildRegex

        # refactor: shared: [0380cfb0]: resolveProperty( $InpObj ).with_default('Name').else_throw()
        if( $AlwaysTryProp -and (-not $PSBoundParameters.ContainsKey('PropertyName'))) {
            $PropertyName = 'Name'
        }
        if($PropertyName) {
            if( .Has.Prop -Inp $InputObject $PropertyName -AsTest | .is.Not ) {
                "object has no property named $PropertyName'"  | write-error
            }
            $Target = $Inputobject.$PropertyName
        } else {
            $Target = $InputObject
        }

        # if($null -eq $Target) { return }
        if( [string]::IsNullOrEmpty( $Target ) ) { return }

        [bool]$shouldKeep = $target -match $buildRegex
        $script:matchesNin = $matches
        [ordered]@{
            Regex  = $BuildRegex
            Name   = $PropertyName ?? "`u{2400}"
            Keep   = $ShouldKeep
            Target = $Target.ToString()
        }
        | ft -auto -HideTableHeaders | out-string | write-debug
        # | Json -Compress -depth 2 | write-debug

        if( -not $MyInvocation.ExpectingInput ) {
            return $shouldKeep
        }
        if($shouldKeep){
            $InputObject
        }
    }
}
function Dotils.Regex.Match {
    <#
    .SYNOPSIS
        filters items from the pipeline, else, returns a boolean when not
    .notes
        does a '\bPattern\b' match
    .example
        gci . | .Match.Start -Pattern 'r' -PropertyName name
    .example
        'the cat, in the hat' -split '\s+' | .Match.Start '[ch]'
    .example
        $stuff = 'cat' , 'bat', 'tats'
        $stuff | .Match.Start 'c' | Csv
        $stuff | .Match.End 't' | Csv
        $stuff | .Match.End '[ts]' | Csv
        $stuff | .Match.End '[ts]' | .Match.Start 't' | Csv

        # outputs:
            cat
            cat, bat
            cat, bat, tats
            tats
    .example
        'cat', 'bat', 'bag' | .Match.Start 'b'
        '$bag','cat', 'bat', 'bag' | .Match.Start 'b.*' -Debug
        '$bag','cat', 'bat', 'bag' | .Match.Start -Literal 'b.*' -Debug
    .LINK
        Dotils.Regex.Match.Start
    .LINK
        Dotils.Regex.Match.End
    .LINK
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.4#regular-expressions-substitutions
    .LINK
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions?view=powershell-7.4
    .LINK
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.4#regular-expressions-substitutions
    .LINK
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/substitutions-in-regular-expressions
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Match')]
    param(
        # regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsRegex')]
        [Alias('Regex', 'Re')]
        [string]$Pattern,

        # literals escaped for a regex
        [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        [string]$Literal,

        # If not set, and type is not string,  tostring will end up controlling what is matched against
        [Parameter(Position=1)]
        [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        # if( $PSBoundParameters.ContainsKey('Literal') -and $PSBoundParameters.ContainsKey('Regex') ) {
        #     throw  'InvalidArgumentsException: Cannot use -Literal and -Regex together'
        # }
        # $Regex = $PSBoundParameters.ContainsKey('Literal') ?
        #     $Literal : $Pattern

        # wait-debugger
        # $Pattern =  $LiteralRegex ? [regex]::Escape( $Pattern ) : $Pattern
        # $buildRegex = Join-String -op '^' -inp $Pattern
        switch($PSCmdlet.ParameterSetName){
            'AsLiteral' {
                $buildRegex = [Regex]::Escape( $Literal )
            }
            'AsRegex' {
                $buildRegex = $Pattern
            }
        }
        $buildRegex = Join-String -f "({0})" -inp $buildRegex
        if($PropertyName) {
            $Target = $Inputobject.$PropertyName
        } else {
            $Target = $InputObject
        }
        # if($null -eq $Target) { return }
        if( [string]::IsNullOrEmpty( $Target ) ) { return }

        [bool]$shouldKeep = $target -match $buildRegex
        $script:matchesNin = $matches
        [ordered]@{
            Regex  = $BuildRegex
            Name   = $PropertyName ?? "`u{2400}"
            Keep   = $ShouldKeep
            Target = $Target.ToString()
        }
        | ft -auto -HideTableHeaders | out-string | write-debug
        # | Json -Compress -depth 2 | write-debug

        if( -not $MyInvocation.ExpectingInput ) {
            return $shouldKeep
        }
        if($shouldKeep){
            $InputObject
        }
    }
}
function Dotils.Error.Select {
    <#
    .notes
    Exception Properties:
        'Data', 'HelpLink', 'HResult', 'InnerException',
        'Message', 'Source', 'StackTrace', 'TargetSite'
    .LINK
        Dotils.Error.Select
    .LINK
        Dotils.Error.GetInfo

    #>
    [CmdletBinding()]
    param(
        # expect [Exception] or [ErrorRecord]
        # [Alias('InputObject')]
        # [Parameter(Mandatory, ValueFromPipeline)]
        # [object]$InputObject,
        # [Management.Automation.ErrorRecord[]]$InputObject,
        # [Management.Automation.ErrorRecord[]]$InputObject,

        [ValidateSet(
            'HasMessage',
            'IsException','IsErrorRecord',
            'HasQualifiedId', 'NotHasQualifiedId'

        )]
        [string[]]$SelectorKind,

        # categories to include
        [Management.Automation.ErrorCategory[]]$ErrorCategory,
        [switch]$PassThru
    )
    begin {
        # [Collections.Generic.List[Object]]$items = @()
    }
    process {
        if($PSBoundParameters.ContainsKey('ErrorCategory')) {
           throw 'next wip NYI'
        }
        # $items.AddRange(@($ErrorRecord))
    }
    end {
        $serr = @( $global:error )
        $choices = [ordered]@{}

        $choices.FullyQualifiedErrorId =
            @( $serr | % FullyQualifiedErrorid ) | Sort-Object -Unique

        $choices.TargetObject =
            @( $serr | % TargetObject | % ToString | Sort -Unique )

        $choices.TypeName =
            @( $serr | % GetType | .Distinct | Format-ShortTypeName )

        $choices.ErrorCategory =
            @( $serr | % GetType | .Distinct | Format-ShortTypeName )

        if($PassThru) {
            return [pscustomobject]$choices
        }

            <#
            example type:
                [CmdletInvocationException], [ErrorRecord], [ParseException]
            #>
        $serr | %{
            $curObj = $_
            if($CurObj  -isnot [Exception] -and
                $CurObj -isnot [Management.Automation.ErrorRecord]) {
                $CurObj | Format-ShortTypeName
                    | Join-String -op 'UnexpectedInput, was not [ErrorRecord | Exception]. Type = '
                    | write-warning
            }

            $keepRecord = $false
            write-warning 'NYI: Continue here'
            switch($SelectorKind) {
                { $true } {
                    $SelectorKind | Join-String -op 'Iter: SelectorKind: ' | write-debug
                }
                'IsException' {
                    if($curObj -is [Exception]) {
                        $keepRecord = $true
                    }
                }
                'IsErrorRecord' {
                    if ($curObj -is [Management.Automation.ErrorRecord]) {
                        $keepRecord = $true
                    }
                }
                'HasMessage' {
                    if( .Is.Blank $curObj.Message | .Is.Not ) {
                        $keepRecord = $True
                    }
                }
                'HasQualifiedId' {
                    if( .Is.Blank $curObj.F | .Is.Not ) {
                        $keepRecord = $True
                    }
                }
                default { "UnhandledSelectorKind: $SelectorKind"}
            }
            # negations
            switch($SelectorKind) {
                { $true } {
                    $SelectorKind | Join-String -op 'Iter: SelectorKind: ' | write-debug
                }
                'HasNoMessage' {
                    if( .Is.Blank $curObj.Message ) {
                        $keepRecord = $false
                    }
                }
                default { "UnhandledSelectorKind: $SelectorKind"}
            }
            if($KeepRecord){
                $CurObj
            }
        }

        # WasThrownFromThrowStatement
        <#
        warning, $Error.TargetObject seemed to trigger errors like
            InvalidOperation: An error occurred while enumerating through a collection:
                Collection was modified; enumeration operation may not execute..

        Verses $error | % TargetObject
            seemed okay
        #>

        return $choices
        write-warning 'filter: nyi'

    }

}
function Dotils.Render.InvocationInfo {
    [Alias('Dotils.NYI.InvocationInfo')]
    [CmdletBinding()]
    param(
        [Alias('InputObject')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $InvocationInfo,

        [switch]$PassThru
    )
    begin {

    }
    process {
        $info = [ordered]@{
            PSTypeName = 'Dotils.Render.InvocationInfo'
            Obj = $InvocationInfo
            ExpectingInput = $InvocationInfo.ExpectingInfo
        }

        if($PassThru) {
            return [pscustomobject]$info
        }
        return [pscustomobject]$info

    <#
    $error[0].InvocationInfo

        MyCommand             : Import-Module
        BoundParameters       : {}
        UnboundArguments      : {}
        ScriptLineNumber      : 1
        OffsetInLine          : 1
        HistoryId             : 1
        ScriptName            :
        Line                  : impo dotils -force -Verbose -DisableNameChecking
        PositionMessage       : At line:1 char:1
                                + impo dotils -force -Verbose -DisableNameChecking
                                + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        PSScriptRoot          :
        PSCommandPath         :
        InvocationName        : impo
        PipelineLength        : 0
        PipelinePosition      : 0
        ExpectingInput        : False
        CommandOrigin         : Internal
        DisplayScriptPosition :
#>
    }
    end {}
}

function Dotils.Render.MatchInfo {
    [CmdletBinding()]
    param(
        # [Alias('MatchInfo')]
        [Alias]
        [Parameter(Mandatory, ValueFromPipeline)]
        [Microsoft.PowerShell.Commands.MatchInfo]$InputObject,

        [ValidateSet(
            'Default',
            'Irregular'
        )]
        [Alias('Format')][string]$OutputFormat = 'Default'
    )
    process {
        $cur = $_
        write-warning 'NYI: Dotils.Render.MatchInfo'
        # @(
        #     @(
        #         $cur.Filename
        #         $cur.Path, $cur.LineNumber -join ':'
        #     ) | Write
        #     $cur.Line
        #     hr 1
        # ) | Join-String -sep ''
        switch($OutputFormat){
            'Irregular'{
                throw "nyi: check out the build in formatters"
            }
            'Default' {
                $cur
                    | Join-String {@(
                        $_.Name;
                        $_.Line;
                        hr 1

                        $_.Matches
                            | Json -depth 3 -wa 'ignore'
                            | Write-Debug

                        ) |Join-String -sep ''
                    }
                    | Dotils.Write-DimText
            }
            default { "throw: UnhandledOutputFormat: '$OutputFormat'" }
        }



    }
}

function Dotils.Regex.Wrap {
    param(
        [Alias('Kind')]
        [ValidateSet(
            'WordBoundary',
            'CaseSensitive',
            'GlobWildcard',
            'CaseInSensitive'
        )]
        [string]$OutputType = 'WordBoundary',

        [Alias('Regex', 'Pattern')][Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # not yet used, but to maintain conformity
        [Alias('Args', 'Value1')][Parameter()]
        $OptionalArgument
    )
    process {
        $pattern = $InputObject
        switch($OutputType) {
            'GlobWildcard' {
                Join-String -f "*{0}*" -inp $pattern
            }
            'WordBoundary' {
                Join-String -f "\b{0}\b" -inp $pattern
            }
            'CaseSensitive' {
                Join-String -f '(?-i){0}(?i)' -inp $Pattern
            }
            'CaseInSensitive' {
                Join-String -f '(?i){0}(?-i)' -inp $Pattern
            }
            default { Throw "NYI: not implemented: '$OutputType'" }
        }
    }
}

function Dotils.Find.NYI.Functions {
    <#
    .SYNOPSIS
        search self for any 'NYI' functions
    .notes
        future:
            - [ ] search for custom attribute types on functions, that tag as partials
            - [ ] parameters with notimplementedso don't error until used parameter attribute


    #>
    param(
        # grep for comments like 'todo', 'future'... etch
        [Alias('Grep', 'Sls')]
        [Parameter(Mandatory, Position=0, ParameterSetName = 'SearchByGrep')]
        [ValidateSet(
            'nyi', 'todo', 'future', 'next', 'first', 'grepException', 'wip',
            'astException',
            'refactor', 'collect'
            )][string]$SearchKind = 'nyi',

        [Parameter(Position=1, ParameterSetName = 'SearchByGrep')]
        [int[]]$RegexContext,

        [Parameter(Mandatory, Position=0, ParameterSetName = 'SearchByType')]
        [switch]$FindNYIExceptions = 'nyi'
    )
    $regexMap = @{
        'nyi'      = '\bnyi\b'
        'todo'     = '\btodo\b'
        'future'   = '\bfuture\b'
        'next'     = '\bnext\b'
        'refactor' = '\brefactor\b'
        'collect'  = '\bcollect\b'
        'first'    = '\bfirst\b'
        'wip'      = '\bwip\b'
        'grepException' = @(
            'NotImplementedException',
            'AmbiguousImplementationException',
            'PSNotImplementedException'
        ) | Join-String -sep '|' -f "(\b{0}\b)"
    }
    if(-not $RegexMap.ContainsKey($SearchKind)){
        throw "PatternName '$SearchKind' does not exist in `$regexMap"
    }

    $slsSplat = @{
        AllMatches = $true
        Path       = $PSCommandPath
        Pattern    = '\bnyi\b'
    }
    if($RegexContext) {
        $slsSplat.Context = $RegexContext
    }

    $slsSplat.Pattern = $regexMap[ $SearchKind ]

    Sls @slsSplat
    write-warning 'future: Search for exception types like: [NotImplementedException]
[Runtime.AmbiguousImplementationException]
[PSNotImplementedException]'
}

'do me first: Dotils.Error.Select' | write-host -back 'darkred' -fore 'white'
'do me second: Dotils.Describe.Error' | write-host -back 'darkred' -fore 'white'
function Dotils.Summarize.Module {
    <#
    .example
        get-module dotils | Dotils.SummarizeModule
    .notes
        note: It doesn't currently use module info object to build
        it just passes it to get-command fo now
    .example
        Dotils.Summarize.Module excelant Verb
        Dotils.Summarize.Module excelant CommandType
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter()]
        [ValidateSet('Verb', 'CommandType')]
        [string]$GroupBy = 'Verb'
    )
    if( $InputObject -is [PSModuleInfo] ) {
        $minfo = $InputObject
        [Management.Automation.CommandInfo[]]$cmds = Get-Command -m $minfo.name | CountOf
    }
    if(-not $minfo -and $InputObject -is 'string') {
        [Management.Automation.CommandInfo[]]$cmds = Get-Command -m $InputObject | CountOf
    }
    if(-not $Cmds) {
        throw "Error looking up module from ModuleInfo or string" }

    # $minfo = Get-Command -m $InputObject.Name -ea 0 | CountOf


    $cmd_groups = $cmds  | group $GroupBy | sort Name  -Descending

    $cmd_groups | %{
        $GroupdByName = $_.Name
        if($GroupdByName -eq ''){
            $GroupdByName = '[empty]' # '␀'
        }
        $group = $_.Group
        Dotils.Render.TextTreeLine $GroupdByName -d 0
        $group | Sort Name | %{

            $item = $_
            Dotils.Render.TextTreeLine $item.Name -d 1
        }
        # | Join-String -sep ', '
    }
}
function Dotils.Describe.ModuleInfo {
    # this returns help about something, see Summarize for a text render
    'show [sma.PSModuleInfo]'
    throw 'wip next'
}
function Dotils.Describe.Type.Mermaid {
    <#
    #>
    throw 'NYI: emit type data to mermaid using ezout/posh'
}
function Dotils.Describe.Error.Mermaid {
    <#
    #>
    throw 'NYI: emit type error record info to mermaid using ezout/posh'
}

function Dotils.Describe.Error {
    <#
    .SYNOPSIS
        Is the exception caused by one of several param block syntax errors .more general case, see other func for rendering a single error record
    .LINK
        Dotils.Describe.Error
    .LINK
        Dotils.Describe.ErrorRecord
    .EXAMPLE
        PS>
        # sample functions that produce these kinds of error:

            function foo1 { param( $x, $y, ) }
            function foo2 { param(
                $x
                $y ) }

        PS> $Error | Dotils.Is.Error.FromParamBlock | CountOf

        # cool it works
    #>
    [Alias(
        '.Describe.Error'
        # ? '.Describe.Exception',
    )]
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
        # [switch]$PassThru
        # invert logic
        # [Alias('Not')]
        # [switch]$IsNotADirectory
        # [Parameter()][switch]$
    )
    begin {
        write-warning 'finish: Describe.Error' # wip: here 2023-08-10
    }
    process {
        if($null -eq $InputObject) { return }
        if(-not($InputObject -is 'Management.Automation.ErrorRecord')) {
            $inputObject
                | Ninmonkey.Console\Format-ShortTypeName
                | Join-String -op "InputObject is not an ErrorRecord! Type = "
                | Write-error
            return
        }
        <#
    Example of Import-Module which fails, because of an inner syntax or parser error:

    Import-Module dotils -force:

    $error[0]

        Exception:
            System.IO.FileNotFoundException: The specified module 'dotils' was not loaded because no valid
                        module file was found in any module directory
            TargetObject          : dotils
            CategoryInfo          : ResourceUnavailable: (dotils:String) [Import-Module], FileNotFoundException
            FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand

    $error[1]

    $error[1] | fl * -Force

        PSMessageDetails      :
        Exception             : System.Management.Automation.ParentContainsErrorRecordException: At
                                H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\dotils\dotils.psm1:418 char:26
                                +             $InputObject.
                                +                          ~
                                Missing property name after reference operator.

                                At H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\dotils\dotils.psm1:418 char:26
                                +             $InputObject.
                                +                          ~
                                Missing '=' operator after key in hash literal.
        TargetObject          :
        CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
        FullyQualifiedErrorId : MissingPropertyName
        ErrorDetails          :
        InvocationInfo        : System.Management.Automation.InvocationInfo
        ScriptStackTrace      : at <ScriptBlock>, <No file>: line 1
        PipelineIterationInfo : {}

        #>
        function __compareErrorKind.FromParamBlockSyntax {
            param(
                [ValidateNotNull()]
                [Parameter(Mandatory, position=0)]
                [Management.Automation.ErrorRecord]$InputObject
            )
            $SourceIsParamBlock = $false
            $details = @{
                SourceIsParamBlock = $false
            }
            $details.Matches ??= [Collections.Generic.List[Object]]::new()

            [string[]]$regexCases = @(
                "Missing ')' in function parameter list"
                "Missing closing '}' in statement block or type definition."
                "Unexpected token ')' in expression or statement."
                "Unexpected token '}' in expression or statement."
            ) | %{ [regex]::Escape( $_ ) }

            foreach($case in $regexCases) {
                $case | Join-String -op 'test case: ' |  write-debug
                if( $InputObject.Exception.Message -match $case ) {
                    $SourceIsParamBlock = $true
                    $details.Matches.Add( $case )
                    break
                }
            }
            "item: SourceIsParamBlock?: Final = $SourceIsParamBlock" | write-verbose
            $details.SourceIsParamBlock = $SourceIsParamBlock
            $details
        }

        # # $InputObject.Exception
        # #     | ? Message -Match ([regex]::Escape("Missing ')' in function parameter list"))
        # if( $InputObject.Exception.Message -match ([regex]::Escape("Missing ')' in function parameter list"))) {
        #     $SourceIsParamBlock = $true
        # }

        $meta = @{
            ParamBlockSyntaxError = $true
            Description = 'default bad stuff'

        }
        # ParserError

        if($PassThru) {
            $InputObject
            | Add-Member -NotePropertyMembers @{
                Describe = $Meta.Description
            } -Force -PassThru -TypeName 'dotils.Describe.ErrorRecord' -ea 'ignore'
        }

        if($SourceIsParamBlock) {
            return $InputObject
        }
    }
    end {

    }
}
function Dotils.Uri.GetInfo {
    <#
    .EXAMPLE
        $sampleNewUrl = 'https://gitloggerfunction.azurewebsites.net/ShowGitLogger?Repository=https://github.com/ninmonkey/ExcelAnt&Metric=CommitsByLanguage&Year=2023&Month=07'
        $sampleNewUrl
    .EXAMPLE
        $info = Dotils.Uri.GetInfo $smapleNewUrl

        # check out methods
        $info.AsUri | fime
        $info.Original | Fime
    .EXAMPLE
        [Web.HttpUtility]::ParseQueryString( $asUri.PathAndQuery ) | Join-String -sep ', '
        # out:
            /ShowGitLogger?Repository, Metric, Year, Month

        [Web.HttpUtility]::ParseQueryString( $asUri.Query ) | Join-String -sep ', '
        # out:
            Repository, Metric, Year, Month
    #>
    [Alias('.Dotils.URL.GetInfo')]
    param(
        # future, maybe use object to allow as URI as raw type
        [Alias('URI', 'URL')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [switch]$ListRelatedTypes
    )
    process {
        if($ListRelatedTypes) {
            find-type *uri*
                | ?{ $_.FullName -match 'Uri' }| Group Namespace
                | ft -auto | out-string | write-host

            hr


            @(
                find-type *uri* | ?{ $_.FullName -match '\buri' }
                find-type *Uri*
                find-type *Url*
            )
                | sort -Unique { $_.Namespace, $_.Name }

            hr
            Find-type '*Uri*' | % FullName | rg -i 'ur[il]' --color=always
                | out-string | write-host


            return
        }
        $cur = $InputObject


        $cur | Format-ShortTypeName
            | Join-string -op 'InputObject is a '
            | Dotils.Write-DimText
            | winfo

        $asUri = [System.Uri]::new( $cur )
        $asParseQuery = [Web.HttpUtility]::ParseQueryString( $AsUri.Query )
        $asParsePathAndQuery = [Web.HttpUtility]::ParseQueryString( $AsUri.PathAndQuery )


        # $u1 = [Uri]$myUrl
        # ( $u2 = [Web.HttpUtility]::ParseQueryString( $u1.Query ) )

        $info = [ordered]@{
            PSTypeName = 'dotils.nin.Uri.MetaInfo'
            AsUri = $asUri
            AsParseQuery = $asParseQuery
            AsParsePathAndQuery = $asParsePathAndQuery
            RawString = [string]$cur
            Original = $InputObject
            OriginalType = $InputObject | Format-ShortTypeName
        }
        return [pscustomobject]$info
#     $u1 = [Uri]$myUrl
# ( $u2 = [HttpUtility]::ParseQueryString( $u1.Query ) )
#     [Uri], then [HttpUtility]::ParseQueryString('...')
    }
    end {
        if($ListRelatedTypes) { return }
    }
}

function Dotils.TypeData.GetFormatAndTypeData {
    <#
    .SYNOPSIS
        sugar grab both kinds

    .NOTES
        future: goal was to find the formatter for SLS to make it
        render like ripgrep instread.

        note: maybe see 'Irregualr' or 'Posh' for regex formatters
    .EXAMPLE
        impo Dotils -Force
        $slsQuery ??= Find-type '*Uri*' | % FullName | sls -Pattern 'Ur[il]' -AllMatches
        Dotils.TypeData.GetFormatAndTypeData -InputObject $slsQuery
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )
    process {
        $First = @( $InputObject )[0]
        $typeName = $first.GetType()
        $shortType = $First | Format-ShortTypeName
        $shortType | Join-String -f  'Type: {0}' | write-verbose -verbose
        # ex: $typeName = 'Microsoft.PowerShell.Commands.MatchInfo'
        $tdInfo = @( Get-TypeData -TypeName $typeName )
        $fdInfo = @( Get-FormatData -TypeName $typeName )

        $Info = [ordered]@{
            PSTypeName = 'dotils.CombinedTypeFormatInfo.Record'
            ShortType = $shortType
            TypeData = $tdInfo
            FormatData = $fdInfo
            TargetObject = $InputObject
            PSTypes = $InputObject.PSTypeNames | Join-String -sep ', '
        }

        return [pscustomobject]$Info
    }
}

function Dotils.Import.Macro {
    [Alias('Import.Macro')]
    param(
        [ArgumentCompletions('dotils', 'ugit')]$ModuleName,

        [Alias('NotSilent')][switch]$Loud
    )
    write-warning 'check in chat if global import should be using scope global or not when this is nested'

    remove-module "*${ModuleName}*"
    if(-not $Loud) {
        $impoSplat = @{
            DisableNameChecking = $true
            Force               = $true
            Name                = $ModuleName
            PassThru            = $true
            Scope               = 'Global'
            SkipEditionCheck    = $true
            WarningAction       = 'ignore'
        }

        impo @impoSplat *>&1
            | OutNull
        return
    }
    $impoSplat = @{
        DisableNameChecking = $true
        Force               = $true
        Name                = $ModuleName
        PassThru            = $true
        Scope               = 'Global'
        SkipEditionCheck    = $true
        WarningAction       = 'continue'
    }

    impo @impoSplat
        | select -exp exportedFunctions
        | % keys | jsUtil.UL
    return
}

# & $binFx @('-new-tab', 'https://www.google.com/search?q=stuff')

function Dotils.Firefox.Invoke {
    <#
    .SYNOPSIS
    .notes
        command line args at: https://wiki.mozilla.org/Firefox/CommandLineOptions
    #>
    'NYI: first implement debugger and enter using debug state args from: <https://wiki.mozilla.org/Firefox/CommandLineOptions>'
    | write-warning

    function newParam {
        param(
            [string]$Value,
            [string]$Description = '',
            [string]$ExtraInfo = '' )
        return [pscustomobject][ordered]@{
            PSTypeName = 'dotils.firefox.newParam'
            Name = $Value -replace '-', ''
            Value = $Value
            ExtraInfo = $ExtraInfo
            Description  = $Description
        }
    }
    $paramGroup = @{}
    $paramGroup.UserProfile = @(
        newParam '-allow-downgrade'
        newParam '-CreateProfile' -ExtraInfo 'profile_name'
        newParam '-CreateProfile' -ExtraInfo "profile_name profile_dir"
        newParam '-migration'
        newParam '-new-instance'
        newParam '-no-remote'
        newParam '-override' -ExtraInfo '/path/to/override.ini'
        newParam '-ProfileManager'
        newParam '-P' -ExtraInfo "profile_name"
        newParam '-profile' -ExtraInfo "profile_path"
    )
    $paramGroup.Browser = @(
        newParam '-browser'
        newParam '-foreground'
        newParam '-headless'
        newParam '-new-tab' -ExtraInfo 'URL'
        newParam '-new-window' -ExtraInfo 'URL'
        newParam '--kiosk' -ExtraInfo 'URL'
        newParam '-preferences'
        newParam '-private'
        newParam '-private-window'
        newParam '-private-window' -ExtraInfo 'URL'
        newParam '-search term'
        newParam '-setDefaultBrowser'
        newParam '-url URL'
    )
    $paramGroup.Other = @(
        newParam '-devtools'
        newParam '-inspector' -ExtraInfo 'URL'
        newParam '-jsdebugger'
        newParam '-jsconsole'
        newParam '-purgecaches'
        newParam '-start-debugger-server' -ExtraInfo 'PORT'
        newParam '-venkman'
    )
    return $paramGroup
}


function Dotils.Is.Error.FromParamBlock {
    <#
    .SYNOPSIS
        Is the exception caused by one of several param block syntax errors ?
    .EXAMPLE
        PS>
        # sample functions that produce these kinds of error:

            function foo1 { param( $x, $y, ) }
            function foo2 { param(
                $x
                $y ) }

        PS> $Error | Dotils.Is.Error.FromParamBlock | CountOf

        # cool it works
    #>
    [Alias('.Is.Error.FromParamBlockSyntax')]
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,
        [switch]$PassThru
        # invert logic
        # [Alias('Not')]
        # [switch]$IsNotADirectory
    )
    process {
        if($null -eq $InputObject) { return }
        if(-not($InputObject -is 'Management.Automation.ErrorRecord')) {
            $inputObject
                | Ninmonkey.Console\Format-ShortTypeName
                | Join-String -op "InputObject is not an ErrorRecord! Type = "
                | Write-error
            return
        }
        $SourceIsParamBlock = $false

        [string[]]$regexCases = @(
            "Missing ')' in function parameter list"
            "Missing closing '}' in statement block or type definition."
            "Unexpected token ')' in expression or statement."
            "Unexpected token '}' in expression or statement."
        ) | %{ [regex]::Escape( $_ ) }

        foreach($case in $regexCases) {
            $case | Join-String -op 'test case: ' |  write-debug
            if( $InputObject.Exception.Message -match $case ) {
                $SourceIsParamBlock = $true
                break
            }
        }
        "item: SourceIsParamBlock?: Final = $SourceIsParamBlock" | write-verbose

        # # $InputObject.Exception
        # #     | ? Message -Match ([regex]::Escape("Missing ')' in function parameter list"))
        # if( $InputObject.Exception.Message -match ([regex]::Escape("Missing ')' in function parameter list"))) {
        #     $SourceIsParamBlock = $true
        # }

        if($SourceIsParamBlock) {
            return $InputObject
        }
    }
}
write-warning 'wip func: Dotils.Is.Error.FromParamBlock'
write-warning 'wip func: Dotils.Render.FindMember'

"Next: 'Dotils.Render.FindMember', 'Dotils.Describe.ErrorRecord'"
| Write-Host -back 'darkyellow'
function Dotils.Render.FindMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()

        function __SummarizeMember_Property {
            $Input
                | Join-String -sep "`n" {@(
                    $_.PropertyType
                        | Join-String -f '[{0}]' { $_ -replace '^System\.', '' }

                    $_.Name
                        | Join-String -f '${0}'
                ) | Join-String -sep ''} #| %{ $_ -split '\n' } #| Join.ul
        }
    }
    process {
        $items.AddRange(@($InputObject))
        'nyi wip next: was here' | write-warning
    }
    end {


        $items | %{
            $_ | __SummarizeMember_Property
            # switch($_.GetType())
        }
    }

    # [System.Management.Automation.ErrorCategoryInfo]|fime  -MemberType Property
    # | __SummarizeMember_Property
}

function Dotils.Render.Error.CategoryInfo {
    <#
    .SYNOPSIS
        Converts [ErrorRecord] or [ErrorRecord.ErrorCategoryInfo] to a string ( because  .ToString() truncates info )
    .EXAMPLE
        Pwsh> $error[0].CategoryInfo | Flatten.Error.CategoryInfo

        Out-Git ⁞ reason: Exception, cat: NotSpecified
            target: [String]
            => fatal: repository 'https://github.com/PowerShell/Powerdddhell/' not found
    .EXAMPLE

        Pwsh> $error[0].CategoryInfo | Flatten.Error.CategoryInfo -OneLine

        Out-Git, Exception, NotSpecified, [String] ⁞ fatal: repository 'https://github.com/PowerShell/Powerdddhell/' not found
    #>
    param(

        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CategoryInfo', 'ErrorRecord')]
        [object] $InputObject,

        # output as one long line, no newlines
        [switch] $OneLine
    )
    process {
        [string] $Render = ''
        if( $InputObject -is [ErrorRecord]) {
            [ErrorCategoryInfo] $T = $InputObject.CategoryInfo
        } else {
            [ErrorCategoryInfo] $T = $InputObject
        }
        if( -not $OneLine ) {
            $Render = "{0} ⁞ {1}, {2}`n  {3}`n  {4}" -f @(
                $t.Activity
                'reason: ', $t.Reason -join ''
                'cat: ', $t.Category -join ''
                'target: [{0}]' -f $t.TargetType
                "=> ", $t.TargetName -join ''
            )
        } else {
            $Render = "{0}, {1}, {2}, {3} ⁞ {4}" -f @(
                $t.Activity
                $t.Reason -join ''
                $t.Category -join ''
                '[{0}]' -f $t.TargetType
                $t.TargetName -join ''
            )
        }

        return $Render
    }
}
write-warning 'wip func: Dotils.Describe.ErrorRecord'
function Dotils.Describe.ErrorRecord {
    [Alias('.Describe.ErrorRecord')]
    [CmdletBinding()]
    param(
        [Alias('ErrorRecord')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [Management.Automation.ErrorRecord]$InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Management.Automation.ErrorCategoryInfo]$CategoryInfo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Exception]$Exception,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Management.Automation.ErrorDetails]$ErrorDetails,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Management.Automation.InvocationInfo]$InvocationInfo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ScriptStackTrace,

        [Parameter(ValueFromPipelineByPropertyName)]
        [object]$TargetObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FullyQualifiedErrorId,

        # # ReadOnlyCollection<int>
        # [Parameter(ValueFromPipelineByPropertyName)]
        # [Management.Automation.InvocationInfo]$PipelineIterationInfo,
        <#
        .ctor
            CategoryInfo
            ErrorDetails
            Exception
            FullyQualifiedErrorId
            GetObjectData
            InvocationInfo
            PipelineIterationInfo
            ScriptStackTrace
            TargetObject
        #>
        [switch]$PassThru
    )
    process {
        $PSCmdlet.MyInvocation.BoundParameters
            | ConvertTo-Json -Depth 1 -Compress
            | Join-String -op 'Dotils.Describe.ErrorRecord<Process>: '
            | write-verbose

        [string]$ErrorTypeName = $InputObject | Format-TypeName
        $InputObject | Format-TypeName


        [string]$DisplayString = ''

        $DisplayString +=
            'foo'

        $DisplayString +=
            'foo'

        $meta = [ordered]@{
            PSTypeName = 'Dotils.Describe.ErrorRecord'
            ErrorTypeName = $ErrorTypeName
            DisplayString = $DisplayString
        }

        if($PassThru) {
            return [pscustomobject]$meta
        }
        return [pscustomobject]$meta
    }
}
function Dotils.Is.KindOf {
    <#
    .SYNOPSIS
        select based on types, if they match one or more of the values
    .NOTES
    types can be generate from:

        PS> Find-Type Encoding* | Join-String -p FullName -sep ', ' -f "'{0}'" | Join-String -f "@( {0} )"

        # out:

        @( 'System.Text.Encoding', 'System.Text.EncodingInfo', 'System.Text.EncodingProvider', 'System.Text.EncodingExtensions' )
    .LINK
        Dotils.Is.KindOf
    .link
        Dotils.Select-Namish
    #>
    [Alias('.Is.KindOf')]
    [CmdletBinding()]
    param(
        # A list of types, keep items if the match any values
        [ArgumentCompletions('ErrorRecord')]
        [string[]]$NameOfKind
    )
    begin {
        # prefer strings to allow dynamic inputs
        $wantedKinds = switch($NameOfKind) {
            { $_ -in @('String', 'Text') } {
                'System.String'
            }
            'Encoding' {

            }
            'Int' {
                @( 'System.Int16', 'System.Int32', 'System.Int64', 'System.Int128' )
            }
            'Directory' { 'IO.DirectoryInfo' }
            'File' { 'IO.FileInfo' }
            { $_ -in @('ErrorRecord', 'Error') } {
                'Management.Automation.ErrorRecord'
            }
            default { throw "UnhandledNameOfKind: $NameOfKind!" }

        }
    }
    process {
        throw 'NYI: Enumerate types, emit object'
        $curItem | Where-Object {
            $_ -is $wantedKind
        }
    }
}

function Dotils.Quick.BatLog {
    <#
    .SYNOPSIS
        pipe to bat with colors, no numbers, default to not paging
    .EXAMPLE
        Pwsh> GlGet.LogPath /tmp/GitLogger-Microservice.log | BatLog
    #>
    [Alias('Quick.BatLog')]
    param(
        [string] $Language = 'log',
        [switch] $Paging
    )
    if($Paging) {
        $Input | bat --paging=always --language $Language --style=header
    } else {
        $Input | bat --paging=never --language $Language --style=header
    }
}

function Dotils.to.EnvVarPath  {
    <#
    .SYNOPSIS
        Older implementation that converts paths into Environment Variable paths
    .notes
        first try: Dotils.Format.PathToEnvVars

        future: auto grab PSPath, turn into
    .EXAMPLE
        Pwsh7🐒>  $query
            | Dotils.to.EnvVarPath QuoteNL

        "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\"
        "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll"

        Pwsh7🐒>  $query
            | Dotils.to.EnvVarPath Pwsh.Block

        gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\"
        gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll"
        Pwsh7🐒>  $query
                | Dotils.to.EnvVarPath Pwsh.SingleLine

        (gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\")
        (gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll")
    .example
        PS> $paths = 'C:\Users\cppmo_000\Microsoft\Power BI Desktop Store App\CertifiedExtensions', 'C:\Users\cppmo_000\AppData\Local\Microsoft\Power BI Desktop\CertifiedExtensions'

        PS> $paths | .to.envVarPath | Set-Clipboard -PassThru

        ${Env:USERPROFILE}\Microsoft\Power BI Desktop Store App\CertifiedExtensions
        ${Env:LOCALAPPDATA}\Microsoft\Power BI Desktop\CertifiedExtensions
    .LINK
        Dotils.Format.PathToEnvVars
    #>
    [Alias('.to.envVarPath')]
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateSet(
            'QuoteNL', 'Pwsh.Block', 'Pwsh.SingleLine')]
        [string]$OutputFormat = 'QuoteNL',

        # Also save to clipboard
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        [Alias('cl', 'clip')]
        [switch]$CopyToClipboard,

        [Alias('Config', 'Kwargs')]
        [ArgumentCompletions(
            '@{ JoinSeparator = "`n" ; JoinStringFormat = ''gi "{0}"'' }'
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $potentialOptions = gci env:
            | Dotils.Is.DirectPath
            | sort-Object{ $_.Value.Length } -Descending -Unique
        $defaults = @{
            PassThru = $true
            DirectoryAsForwardSlash = $true
            JoinSeparator = ', '
            JoinStringFormat = '"{0}"'
        }
        switch($OutputFormat){
            'QuoteNL' {
                $defaults.JoinSeparator = ', '
                $defaults.JoinStringFormat = '"{0}"'
            }
            'Pwsh.Block' {
                $defaults.JoinSeparator = "`n"
                $defaults.JoinStringFormat = 'gi "{0}"'
            }
            'Pwsh.SingleLine' {
                $defaults.JoinSeparator = "; "
                $defaults.JoinStringFormat = '(gi "{0}")'
            }
             default {
                write-warning "UnhandledOutputFormat: $Switch"
                $defaults.JoinSeparator = ', '
                $defaults.JoinStringFormat = '"{0}"'
                # no-op
            }
        }
        $defaults | Json | Join-String -op '$defaults = [ ' -os "`n]" -sep "`n" | Write-debug

        $Config = nin.MergeHash -other $Options -BaseHash $defaults
        $defaults | Json | Join-String -op '$config = [ ' -os "`n]" -sep "`n" | Write-debug
    }
    process {
        # assume real for now
        $curInput = Get-Item -ea 'ignore' -LiteralPath $_
        $asStr = $curInput.FullName ?? $curInput.ToString()

        foreach($item in $potentialOptions){
            $pattern = [Regex]::escape( $item.Value )
            if($asStr -match $Pattern) {
                $prefixTemplate = '${{Env:{0}}}' -f $Item.Key
                $render = $asStr -replace $Pattern, $prefixTemplate
                @{
                    template = $prefixTemplate
                    render = $render
                    pattern = $pattern
                    asStr = $asStr
                } | Json | Join-String -sep "`n" | Write-debug


                # switch($OutputFormat){
                #     'QuoteNL' {
                #         # $render = $render
                #         # | Join-String -f '"{0}"' -Separator ', '
                #     }
                #     'Pwsh.Block' {
                #         $render = $render
                #         | Join-String -f 'gi "{0}"' -sep "`n"
                #     }

                # }

                ## assert
                #   do I actually need to use expandstring?
                $resolveItem = Get-Item -ea 'ignore' $render
                # $resolveItem.FullName -eq $curInput.Fullname
                #     | Join-String -op 'IsValidAnswer? '
                #     | write-verbose

                $joinStr_splat = @{
                    FormatString = $Config.JoinStringFormat
                    Separator = $Config.JoinStringFormat
                }

                $render = $render | Join-String @joinStr_splat

                if($CopyToClipboard) {
                    $render | Set-Clipboard -PassThru:( $Config.PassThru )
                    return
                }
                return $render
            }
        }
    }
}



function Dotils.Write-Information {
    <#
    .SYNOPSIS
        sugar for : obj | Write-information -infa 'continue'
    #>
    [Alias(
        'wInfo', 'Infa', 'Write.Infa'
    )]
    param(
        [switch]$WithoutInfaContinue
    )
    if($WithoutInfaContinue) {
        $Input | Write-Information
        return
    }
    $Input | Write-Information -infa 'continue'
}

function Dotils.Write-StringInformation {
    <#
    .SYNOPSIS
        sugar for : obj | out-String | Write-information -infa 'continue'
    #>
    [Alias(
        'Write.StringInfa',
        'Write.StrInfa'
    )]
    param(
        [switch]$WithoutInfaContinue
    )
    if($WithoutInfaContinue) {
        $Input | Out-String -w 1kb
               | Write-Information
        return
    }
    $Input | Out-String -w 1kb
           | Write-Information -infa 'Continue'
}
function Dotils.Write.Info.Fence {
    [Alias('Write.Info.Fence')]
    param()
    $content = $Input
    $content -split '\r?\n'
    | Join-String -f '    {0}'
    | Join-String -op "`nfence`n" -os "`ncloseFence`n"
}
function Dotils.String.Normalize.LineEndings {
    # replace all \r\n sequences with \n
    [Alias('String.Normalize.LineEndings')]
    param()
    process {
        $_ -replace '\r?\n', "`n"
    }
}

function Dotils.ClampIt {
    # polyfill. Pwsh Can use [Math]::Clamp directly.
    [Alias('ClampIt')]
    param ( $value, $min, $max )

    [Math]::Min(
        [Math]::Max( $value, $min ), $max )
}
function Dotils.String.Visualize.Whitespace {
    [Alias('String.Visualize.Whitespace')]
    param( [switch]$Quote)
    process {
        ( $InputObject = $_ )
        | Join-String -SingleQuote:$quote
        | New-Text -bg 'gray30' -fg 'gray80' | % tostring
    }
}
function Dotils.Debug.Find-Variable.old {
    # gives metadata to querry against
    get-variable
        | %{
            <#
                $_.Value
                    # can you do this as a coalesce? might require error record
                    | Format-ShortTypeName -ea 'ignore' || '<missing>'

            see also:
                LocalVariable
                NullVariable
                PSCultureVariable
                PSUICultureVariable
                PSVariable
                QuestionMarkVariable

            Now the normal version
            #>

# function Dotils.Format-TaggedUnionString {

    #  System.Management.Automation.PSVariable
        [pscustomobject]@{
            # PSTypeName = 'Dotils.PSVariable'
            PSTypeName = 'sma.PSVariable'
            what       = $_.Name
            value      = $_.Value
            Kind       = $_.Value.GetType().Name
            ShortName  =
                $_.Value
                | Format-ShortTypeName -ea 'ignore' #|| '<missing>' # can you do this ?
        }
    }
      #| to-xl

}

function Dotils.To.Resolved.CommandName {
    <#
    .SYNOPSIS
        lookup command name from command or alias name
    .NOTES
        improvement: support other types
            [ AliasInfo | Commandinfo | FuncInfo | String ]

        todo: argumenttransformationargument

    warning: currently doesn't grab info from commands, so

        gcm write-host -All | .to.Resolved.CommandName
            returned not only dropping, but doesn't resolved 2 modules as 1 module
                Pansies\.
                Pansies\.

    .example
    Pwsh> gcm hr | Dotils.To.Resolved.CommandName
    Pwsh> gcm hr | .to.Resolved.CommandName

        Ninmonkey.Console\Write-ConsoleHorizontalRule
    .example
        gcm Ninmonkey.Console\Write-ConsoleHorizontalRule
        | .to.Resolved.CommandName

            Ninmonkey.Console\Write-ConsoleHorizontalRule

        gcm hr
        | .to.Resolved.CommandName

            Ninmonkey.Console\Write-ConsoleHorizontalRule
    #>
    [CmdletBinding()]
    [Alias(
        '.to.Resolved.Command' )]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )
    process {
        $Target = $InputObject
        $meta = @{}
        if($Target -is 'Management.Automation.CommandInfo') {
            $meta.Source = $Target.Source
            $meta.CommandType = $Target.CommandType
            $meta.ModuleName = $Target.Module
            $meta.ModuleName = $Target.ModuleName
            $meta.ImplementingType = $Target.ImplementingType
            $meta.Version = $Target.Version

            $meta
                | Json -depth 0 -EnumsAsStrings
                | Join-String -op '[CommandInfo]' -sep "`n"
                | write-verbose

            return
        }

        Get-Command $Target
        | Join-String {
            '{0}\{1}' -f @(
                $_.Source ?? '.'
                $_.ResolvedCommandName ?? '.'
            )
        }
    }
}
class RegexHistoryItem {
    [regex]$Regex
    [object[]]$Matches
}
class Dotils_RegexHistory {
    [System.Collections.Generic.List[object]]$Records = @()

    static [object[]] AddFromGlobalMatches (){
        return @()
    }
    [string] ToString() {
        return $this.Records.Count
            | Join-String -f "Records: {0}"
    }
}

"finish 'Dotils_RegexHistory'"
| write-host -bg 'gray30' -fg 'gray80'


$script:__dotilsInnerRegexHistory ??= @()
function Dotils.Regex.History.Add {
    throw 'nyi, wip'
}


function Dotils.String.Transform {
    # Dotils.String.Transform.AlignRight
    <#
    .SYNOPSIS
        entry point for a ton of transforms
    .example
        PS> # round trip
        $url | .str.Transform -Fn Url.Encode
             | .str.Transform -Fn Url.Decode
    #>
    [Alias('.str.Transform')]
    param(
        [Alias('Fn', 'Func', 'T')]
        [Parameter(Mandatory, Position=0)]
        [ValidateSet(
            'Csv.Distinct',
            'Csv.SingleQuote',
            'Csv.DoubleQuote',
            'Join.UL',
            'Url.Decode',
            'Url.Encode',
            'Trim',
            'Strip.Whitespace',
            'FormatControlChar',
            'Join.LineEnding',
            'Split.LineEndings',
            'Normalize.LineEndings',
            'Md.Url.FromPath',
            'ToUpperInvariant', 'ToUpper', 'ToLower', 'ToLowerInvariant',
            'Console.AlignRight'
        )]
        [string[]]$TransformationNameList,

        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(ValueFromPipeline)]
        [string[]]$InputObject

    )
    # $Accum = $InputObject
    $curObj = $InputObject
    write-warning 'Still not sure how I want to abstract the enumeration, because some should process as one item, others process per single item. '
    $TransformationNameList | %{
        $TransformationName = $_
        $CurObj = switch($TransformationName){
            'Csv.Distinct' {
                $CurObj | Sort-Object -Unique | Join-String -sep ', '
                break
            }
            'Csv.DoubleQuote' {
                $CurObj | Sort-Object -Unique | Join-String -sep ', ' -DoubleQuote
                break
            }
            'Csv.SingleQuote' {
                $CurObj | Sort-Object -Unique | Join-String -sep ', ' -SingleQuote
                break
            }
            'Join.UL' {
                $CurObj | Join.UL
                break
            }
            'Url.Decode' {
                $CurObj | %{
                    $_ -replace
                    '%3A', ':' -replace
                    '%2F', '/'
                }
                break
            }
            'Url.Encode' {
                write-warning 'not complete, and not using right func, there''s a couple'
                $CurObj | %{
                    $_ -replace
                    ':', '%3A' -replace
                    '/', '%2F'
                }
                break
            }
            'Trim' {
                $CurObj | %{
                    $_.Trim() }
                break
            }
            'Strip.Whitespace' {
                $CurObj | %{
                    $_ -replace '\s+', '' }
                break
            }
            'FormatControlChar' {
                $CurObj | Ninmonkey.Console\Format-ControlChar
                break
            }
            'Join.LineEnding' {
                $CurObj -join "`n"
                break
            }
            'Split.LineEndings' {
                $CurObj | %{
                    $_ -split '\r?\n' }
                break
            }
            'Normalize.LineEndings' {
                $CurObj | Dotils.Text.NormalizeLineEnding
                break
            }
            'Md.Url.FromPath' {
                # $CurObj -replace ' ', '%20' -replace '\\', '/'
                $CurObj | %{
                    $_ -replace ' ', '%20' -replace '\\', '/' }
                break
            }
            'ToUpperInvariant' {
                $CurObj | %{
                    $_.ToString().ToUpperInvariant() }
                break
            }
            'ToUpper' {
                $CurObj | %{
                    $_.ToString().ToUpper() }
                break
            }
            'ToLower' {
                $CurObj | %{
                    $_.ToString().ToLower() }
                break
            }
            'ToLowerInvariant' {
                $CurObj | %{
                    $_.ToString().ToLowerInvariant() }
                break
            }
            'Console.AlignRight' {
                $CurObj | Dotils.String.Transform.AlignRight
                break
            }
            default {
                write-warning "unhandled transformName: $TransformationName"
            }
        }
    }
    return $CurObj

}
function Dotils.String.Transform.AlignRight {
    # replace all \r\n sequences with \n
    [Alias('String.Transform.AlignRight')]
    param(
        [switch]$ShowDebugOutput
    )
    process {

        $InputObject = $_
        $re = '^\s*(?<Content>.*?)\s*$'

        $InputObject -split '\r?\n'
        | % {
            [string]$curLine = $_

            if ($ShowDebugOutput) {
                label 'what' 'orig'
                $curLine
                | String.Visualize.Whitespace
                | Write.Info
            }

            if ($curLine -match $Re) { } else { return }
            $withoutPadding = $matches.Content ?? ''

            if ($ShowDebugOutput) {
                label 'what' 'without pad'
                $withoutPadding
                | String.Visualize.Whitespace
                | Write.Info
            }

            $width = (Console.Width) ?? 120
            $render = $withoutPadding.ToString().PadLeft( $width, ' ')
            if ($ShowDebugOutput) {
                label 'what' 'new pad'

                $render
                | String.Visualize.Whitespace
                | Write.Info
            }
            return $render
        }
    }
}

if($false) {
    $reason = 'write-warning param binding keeps breaking on import, often silently'

function Dotils.PSDefaultParams.ToggleAllVerboseCommands {
    <#
    .SYNOPSIS
        sugar to toggle PSDefaultParameterValues on and off for a lot of commands
    .DESCRIPTION
        Attempts to import the module first.
        currently only selects 'function' commands
        aliases might not be included ?

    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(position=0, Mandatory)]
        [ArgumentCompletions(
            'ImportExcel', 'Pipescript',
            'Ninmonkey.Console',
            'ExcelAnt',
            'Dotils',
            'TypeWriter',
            'ugit', 'GitLogger'
        )]  # todo: use ninmodule named completer type
        [string]$ModuleName,

        [Parameter(position=1, Mandatory)]
        [ValidateSet('Enable', 'Disable')]
        [string]$VerboseMode

        # [Alias('On')][switch]$Enable,
        # [Alias('Off')][switch]$Disable
    )


    if($Enable)  { $VerboseMode = 'Enable'  }
    if($Disable) { $VerboseMode = 'Disable' }

    import-module $ModuleName -ea 'stop'

    gcm -m $ModuleName
        | ? CommandType -eq 'function'
        | Sort-Object -Unique
        | %{
            $keyName = "{0}:Verbose" -f $_.Name
            $keyName | Join-String -f 'add/remove key: "{0}"' -sep "`n"
                    | write-verbose
            if($VerboseMode -eq 'Enable') {
                $PSDefaultParameterValues[ $keyName ] = $true
            } else {
                $PSDefaultParameterValues.
                    Remove( $keyName )
            }
        }

    $PSDefaultParameterValues.
        GetEnumerator()
        | Sort-Object Name
        | OutNull 'DefaultParams'

    }
}
function Dotils.Grid {

    <#
    .SYNOPSIS
    all the docs were in the other place

    .EXAMPLE
        0..50 | Grid -Count 10 -PadLeft 5
        0..50 | Grid -Count 10 -PadLeft 1
        0..50 | Grid -Auto -Count 3
    #>
    [Alias(
        'Grid',
        'Nancy.OutGrid'
    )]
    param(
        [int]$Count = 8,
        [int]$PadLeft,
        [switch]$Auto
    )
    $all_items = $Input
    if ($Auto) {
        $w = $host.ui.RawUI.WindowSize.Width
        $perCell = $PadLeft -gt 0 ? $PadLeft : 6
        [int]$numItems = $w / $perCell # auto floors ?
        #             $perCell = $w / ( $PadLeft ?? 6 )
        $Count = $numItems
    }

    $all_items | Ninmonkey.Console\Iter->ByCount -Count $Count | % {
        $_
        | Join-String -sep ', ' {
            if (-not $PadLeft) { return $_ }
            return $_.ToString().PadLeft( $PadLeft, ' ' )

        }
        # | Join-String -sep '' { $Template.Hex -f $_ }
        | Format-Predent -PassThru -TabWidth 4
    } | Join-String -sep ''
}


function Dotils.Stdout.CollectUntil.Match {
    #  Dotils.Stdout.CollectUntil.Match #  PipeUntil.Match
    <#
    .synopsis
    asfdsf
    .notes
    warning need naming clarification.

                wait until a pattern is found in the input stream.

                collect until : match found
                Get?Until -match $regex -then quit
                    or -then become silent pass through ?
                    out: a..f


                or
                    Collect|Capture|ProcUntil
                    param:
    future:
        -ProcessUntil RegexMatch 'gateway' # ie: Ignores, but allows rest to continue
        - allow context, so last match plus N lines
    .EXAMPLE
        ipconfig /all
        | Dotils.Stdout.CollectUntil.Match 'gate'
        | CountOf

        ipconfig /all
        | Dotils.Stdout.CollectUntil.Match 'gate' -WithoutIncludingFinalMatch
        | CountOf

    #>
    [Alias(
        # 'Dotils.Stdout.WatchUntil.Match',
        'PipeUntil.Match'
    )]
    param(
        # Should it continue to output all text while waiting?
        # like set-content -passthru
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('InputText', 'Text', 'Content')]
        [object[]]$InputObject,

        [Parameter(Mandatory, Position = 0)]
        [Alias('Regex' , 'Re')]
        [string]$Pattern,

        # allow context, so last match plus result plus +N lines before or after or both
        [int]$Context, # default to 0 or null?  = 0,


        # should the match be part of the result set?
        [switch]$WithoutIncludingFinalMatch,
        [Alias('Kwargs')][hashtable]$Options
    )
    begin {
        $HasFoundPattern = $false
        if ($Context) { throw 'NotYetImplementedException: flags like grep. -Context/-Before/-After:' }

    }
    process {
        if ($HasFoundPattern) { return }

        Foreach ($item in $InputObject) {
            if ($HasFoundPattern) { return }
            if ($Item -match $Pattern) {
                $HasFoundPattern = $true
                if ( $WithoutIncludingFinalMatch ) { return }
            }
            $Item
        }
    }
    end {

    }
}


function Dotils.Debug.Get-Variable {
    <#
    .SYNOPSIS
        Get variable, using regex patterns
    .example
        Dotils.Get-Variable '\d+' -Scopes Local
    .example
        Dotils.Get-Variable 'path' -Scopes 0..10
    .link
        Dotils.Debug.Compare-VariableScope
    .link
        Dotils.Debug.Get-Variable
    #>
    [OutputType(
        'PSVariable[]',
        'System.Management.Automation.PSVariable[]')]
    [CmdletBinding()]
    param(
        [Alias('Pattern', 'Regex')]
        [Parameter(Mandatory)]
        [string[]]$InputPattern,

        [ArgumentCompletions(
            'Global', 'Script', 'Local',
            '0', '1', '2', '3', '4', '5', '6'
        )]
        [Parameter(Mandatory)]
        [string[]]$Scopes = 'Local'
    )
    write-warning 'double check output works with debugger scope as expected, maybe embedded session is better with explicit global scope in cases'

    $whoAmI =
        $PSCmdlet.
            MyInvocation.
            MyCommand.
            Name # ( $parentCmdlet = Get-Variable 'PSCmdlet' -Scope 1 )

    [Collections.Generic.List[Object]]$results =
        @()
    '⭝ enter: Dotils.Debug.Get-Variable'
        | Join-String -op $WhoAmi
    foreach($curScope in $Scopes) {
        foreach($curRegex in $InputPattern) {

            $query = Get-Variable -Scope $curScope -Name '*'
            # experimenting with making misleading continuations
            'Num?: {0} -Scope {1} | Where: {2}' -f
                @(  $query.
                        Count, $curScope, $curRegex
                )
            | Write-Verbose

            if(-not $query) {'failed' | write-verbose  }
            # use raw for now, maybe transform later
            $results.AddRange(@( $Query ))
        }

    }
    '⭂ exit: Dotils.Debug.Get-Variable'
        | Join-String -op $WhoAmi
    return $results
}

function Dotils.Debug.Compare-VariableScope {
    <#
    .SYNOPSIS
        Compare-Object on variables by name (and value?) returns only compare-object
    .link
        Dotils.Debug.Compare-VariableScope
    .link
        Dotils.Debug.Get-Variable
    #>
    [CmdletBinding()]
    param(
        [string]$Scope1 = '0',
        [string]$Scope2 = '1'

    )
    $getVars1 = Get-Variable -scope $Scope1 -ea 'continue'
    $getVars2 = Get-Variable -scope $Scope2 -ea 'continue'

    @{
        Vars1Count = $getVars1.Count
        Vars2Count = $getVars2.Count
        Names1 =
            $getVars1.Name
                | Sort-Object -Unique
                | Join-string -sep ', ' -p {
                    $_ | New-text -fg gray80 -bg gray30
                }

        Names2 =
            $getVars2.Name
                | Sort-Object -Unique
                | Join-string -sep ', ' -p {
                    $_ | New-text -fg gray80 -bg gray30
                }

    } | ft  | out-string
            | Write-Information -ea 'continue'
        # | write-verbose -verbose
    Compare-Object ($getVars1) ($getVars2)
    return
}

function Dotils.Write-TypeOf {
     <#
    .SYNOPSIS
        Writes object type info to the information stream or host, original object is preserved
    .NOTES

    .EXAMPLE
        $res = $sb.Ast.EndBlock.Statements | OutKind
    #>
    [Alias(
        'WriteKindOf', 'OutKind')]
    [CmdletBinding()]
    param(

        # format style
        [ValidateSet(
            'Default')]
        [Parameter(Position=0)]
        $OutputMode = 'Default',

        # actual objects to inspect
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject


    )
    process {

        $InputObject
        switch($OutputMode) {
            'Default' {
                $InputObject
                    | Format-TypeName -WithBrackets
                    | Write-host -bg 'gray30' -fg 'gray80'
            }
            default { throw "UnhandledOutputMo: $switch"}
        }
    }

}
function Dotils.Write-NancyCountOf {
    <#
    .SYNOPSIS
        Count the number of items in the pipeline, ie: @( $x ).count
    .NOTES
        Any alias to this function named 'null' something
        will use '-OutNull' as a default parameter
    .EXAMPLE
        gci | CountOf # outputs files as normal *and* counts
        'a'..'e' | Null🧛  # count only
        'a'..'e' | Null🧛  # labeled
        'a'..'e' | Null🧛 -Extra  # count only /w type names
        'a'..'e' | Null🧛 -Extra -Name 'charList'  # labeled type names
    .EXAMPLE
        for unit test

            . $redot
            $stuff = 'a'..'c'
            $stuff | CountOf
            $stuff | Null🧛

            $stuff | CountOf -Label 'Count' -Extra
            $stuff | Null🧛 -Label 'Null' -Extra

    .EXAMPLE
        ,@('a'..'e' + 0..3) | CountOf -Out-Null
        @('a'..'e' + 0..3) | CountOf -Out-Null

        # outputs
        1 items
        9 items
    #>
    # [CmdletBinding()]
    # [Alias('Len', 'Len🧛‍♀️')] # warning this breaks crrent parameter sets
    [Alias(
        'CountOf', 'Len',
        # '🧛Of',
        # 'Len',
        # '-OutNull', # works, but does not generate completions
        '🧛', # puns are fun
        # 'Out-Null🧛',
        'OutNull',
        'Null🧛' # puns are fun
        , 'nin.exportMe'
    )]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        # Show type names of collection and items
        [Alias('TypeOf')]
        [switch]$Extra,

        # optionally label numbers
        [Alias('Name', 'Label')]
        [Parameter(Position = 0)]
        [string]$CountLabel,

        # Count and Consume all output. (pipes to null)
        # Equivalent to calling CountOf and then | Out-Null
        # Automatically defaults to be on when alias to 'Write-NancyCountOf'
        # has the string null in it, like 'OutNull' (the command alias, rather than this param alias does this)
        [Alias('Out-Null')]
        [switch]${OutNull},

        [ArgumentCompletions(
            '@{ LabelFormatMode = "SpaceClear" }'
        )][hashtable]$Options
    )
    begin {
        [int]$totalCount = 0
        [COllections.Generic.List[Object]]$Items = @()
        $Config = $Options
    }
    process { $Items.Add( $InputObject ) }
    end {
        $null = 0
        # wait-debugger
        if ( $OutNull -or ${OutNull}.IsPresent -or $PSCmdlet.MyInvocation.InvocationName -match 'null|(Out-?Null)') {
            # $items | Out-Null # redundant?
        }
        else {
            $items
        }

        $colorBG = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg = $PSStyle.Foreground.FromRgb('#e5701c')
        $colorFg = $PSStyle.Foreground.FromRgb('#f2962d')
        $colorBG_count = $PSStyle.Background.FromRgb('#362b1f')
        $colorFg_count = $PSStyle.Foreground.FromRgb('#f2962d')
        $colorFg_label = $PSStyle.Foreground.FromRgb('#4cc5f0')
        $colorBG_label = $PSStyle.Background.FromRgb('#376bce')
        @(

            $render_count = '{0} items' -f @(
                $items.Count
            )
            if ($CountLabel) {
                @(
                    $LabelFormatMode = 'SpaceClear'

                    switch ($Config.LabelFormatMode) {
                        'SpaceClear' {
                            $colorFg_label, $colorBG_label
                            # style 1
                            $CountLabel
                            $PSStyle.Reset
                            ' ' # space before, between, or last color?

                            $ColorFg_count
                            $ColorBg_count
                            ' '
                            $render_count
                        }
                        default {
                            $colorFg_label, $colorBG_label
                            # style 1
                            $CountLabel
                            '' # space before, between, or last color?
                            # $PSStyle.Reset
                            $PSStyle.Reset
                            $ColorFg_count
                            $ColorBg_count
                            ' '
                            $render_count

                        }
                    }
                )
                $renderLabel -join ''
            }
            else {
                $ColorFg_count
                $ColorBg_count
                ' '
                $render_count
            }

            # $PSStyle.Reset
            # $PSStyle.Foreground.FromRgb('#e5701c')
            "${fg:gray60}"
            if ($Extra) {
                ' {0} of {1}' -f @(
                    ($Items)?.GetType().Name ?? "[`u{2400}]"
                    # $Items.GetType().Name ?? ''
                    # @($Items)[0].GetType().Name ?? ''
                    @($Items)[0]?.GetType() ?? "[`u{2400}]"
                )
            }
            $PSStyle.Reset
        ) -join ''
        | Write-Information -infa 'Continue'


    }
}

function Dotils.FindExceptionSource  {
    <#
    .SYNOPSIS
    .LINK
        Dotils.JoinString.As
    .notes
        future:
        - [ ] auto bind using parameternames, so piping $error array works automatic

        see methods: $serr | fime * -Force

    .example
        PS> $error[0]       | Dotils.FindExceptionSource
        PS> $error[0..3]    | Dotils.FindExceptionSource
        PS> $error          | Dotils.FindExceptionSource
    .example
        $serr|Dotils.FindExceptionSource
        $serr|Dotils.FindExceptionSource -Kind GetError
        $serr|Dotils.FindExceptionSource -Kind InnerDebug
        $serr|Dotils.FindExceptionSource -Kind Minimal
        $serr|Dotils.FindExceptionSource -Kind Overrides
    .example
        # related:
        PS> $ErrorView | Dotils.JoinString.As Enum
        # outputs:
            [ 'CategoryView' | 'ConciseView' | 'DetailedView' | 'NormalView' ]
    .LINK
        System.Management.Automation.ErrorRecord
    #>
    [CmdletBinding()]
    param(
        # Expects an ErrorRecord or child exception
        [Alias(
            # 'Exception'
            # not sure if this will unroll the outer exception losing a layer
            # using:    ValueFromPipelineByPropertyName
        )]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $InputObject,
        # [Exception]

        [Alias('Find.As')]
        [ValidateSet(
            # 'Default',
            'GetError',
            'InnerDebug',
            'Minimal',
            'Overrides'
        )]
        [string[]]$Kind,

        [hashtable]$Options = @{}
    )
    process {
        $t = $InputObject
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            # Separator = ', '
            IncludeFirstChild = $false
        }
        $UniNull        = '[␀]' # "[`u{2400}]'"
        $UniDotDotDot   = '…' # "`u{2026}"
        $Config | Json -depth 4 -Compress
                | Join-String -f "Dotils.FindExceptionSource: Options = {0}"
                | Write-Verbose

        $InputObject    | Format-ShortTypeName | Join-String -f '$InputObject is {0}'
                        | write-debug

        if($Config.IncludeFirstChild) { throw 'NYI: IncludeFirstChild'}
        if($null -eq $t) {
            write-error 'InputObject Was Null'
            return
        }

        $meta = [ordered]@{}


        $meta.SelectStar =
            $t | Select-Object '*'

        $meta.PSObjectPropertiesAll =
            $t.PsObject.Properties

        $meta.IterProps =
            $t | io
        $meta.IterPropsNoBlank =
            $t | io -SkipMost -SkipNull -SkipBlank

        if( -not $t.Exception -or -not $Config.IncludeFirstChild ) {
            $meta.FirstChild = $UniNull
        }
        if($Config.IncludeFirstChild) {
            $meta.FirstChild =
                Dotils.FindExceptionSource -input $t.Exception
        }


        # tempTest





        # copy direct properties

        $meta.CategoryInfo =
            ($t)?.CategoryInfo ?? $UniNull

        $meta.ErrorCategoryInfo =
            ($t)?.ErrorCategoryInfo ?? $UniNull

        $meta.ErrorDetails =
            ($t)?.ErrorDetails      ?? $UniNull

        # Obj.Exception.ErrorRecord
        $meta.ErrorRecord =
            ($t)?.ErrorRecord      ?? $UniNull

        # first child
        $meta.Exception =
            ($t)?.Exception         ?? $UniNull
        $Meta.ExceptionTypeName =
            $t | Format-ShortSciTypeName

        $meta.FullyQualifiedErrorId =
            ($t)?.FullyQualifiedErrorId ?? $UniNull

        $meta.InvocationInfo =
            ($t)?.InvocationInfo         ?? $UniNull
        $meta.PipelineIterationInfo =
            ($t)?.PipelineIterationInfo         ?? $UniNull

        $meta.PSMessageDetails =
            ($t)?.PSMessageDetails ?? $UniNull

        $meta.ScriptStackTrace =
            ($t)?.ScriptStackTrace ?? $UniNull

        $meta.TargetObject =
            ($t)?.TargetObject     ?? $UniNull



        switch ($Kind) {
            'GetError'  {
                $meta.FromGetError =
                    ($t | Get-Error) ?? $UniNull
                continue
            }
            'Minimal' {
                $meta.remove('IterProps')
                $meta.remove('IterPropsNoBlank')
                # $meta.remove('ScriptStackTrace')
                return [pscustomobject]$meta
                continue
            }
            'Overrides' {
                # maybe more, see: full list
                #   $serr | fime * -Force
                $meta._serializedErrorCategoryMessageOverride =
                    ($t)?._serializedErrorCategoryMessageOverride     ?? $UniNull
                $meta._reasonOverride =
                    ($t)?._reasonOverride     ?? $UniNull
                return [pscustomobject]$meta
                continue
            }
            'InnerDebug' {

                <#
                Original was
                    $serr | Format-ShortTypeName
                    $serr.Exception | Format-ShortTypeName

                    $z.Inner_Exception =

                    if($serr.Exception.ErrorRecord) {
                        $serr.Exception.ErrorRecord | Format-ShortTypeName  } else { "<null>" }

                    $meta.Inner_Exception =
                        if($serr.Exception.ErrorRecord) {
                            $serr.Exception.ErrorRecord | Format-ShortTypeName
                        } ?? $StrNull
                    $meta.Inner_ExceptionTypeName =
                        $what ?
                        ($what | Format-ShortTypeName) :
                        'null'
                #>
                $meta.Inner_Json =
                    $t  | ConvertTo-Json -Depth 1

                $meta.Inner_PSCO =
                    $t  | ConvertTo-Json -Depth 1
                        | ConvertFrom-Json

                $what = $t
                $meta.Inner_TypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.Exception
                $meta.Inner_ExceptionTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.ErrorRecord
                $meta.Inner_ErrorRecordTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull

                $what = $t.Exception.ErrorRecord
                $meta.Inner_Exception_ErrorRecordTypeName =
                    $what ?
                    ($What | Format-ShortTypeName) :
                    $UniNull
                continue
            }
            # 'Default' {
            #     #
            #     continue
            # }
            default { throw "UnhandledJoinKind: $Kind" }
        }
        return [pscustomobject]$meta
    }
    end {}
}

function Dotils.JoinString.As {
    <#
    .SYNOPSIS
    .example
        PS> $ErrorView | Dotils.JoinString.As Enum

        # outputs:
            [ 'CategoryView' | 'ConciseView' | 'DetailedView' | 'NormalView' ]
    .example
        PS> impo importexcel -PassThru
                | Join.As -Kind 'Module'

        # outputs:
            importexcel = 7.8.4
    .example
        PS> Get-PSCallStack
            | Join.As PSCallStack.Location
            | Join.UL

        # Output

            - mainEntryPoint.ps1: line 70
            - bdg_lib.psm1: line 8
            - mainEntryPoint.ps1: line 321
            - <No file>


    #>
    [CmdletBinding()]
    param(
        [Alias('Join.As')]
        [ValidateSet(
            'Enum',
            'Module',
            'InternalScriptExtent'
        )]
        [string]$Kind,

        [hashtable]$Options = @{}
    )
    process {
        $InputObject = $_
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            Separator = ', '
        }
        switch ($Kind) {
            'Enum' {
                $InputObject
                | Find-Member | % name | Sort-Object -Unique
                | ? { $_ -ne 'value__' }
                | Join-String -sep ' | ' -op ' [ ' -os ' ] ' -SingleQuote
                break
            }
            'InternalScriptExtent' {
                # 'c:\foo\bar.ps1:134'
                # in vs code / grep format
                $InputObject.Position
                | Join-String {
                    $_.File, $_.StartLineNumber -join ':'
                }
                break
            }
            'PSCallStack.Locations' {
                # ex: usage: Get-PSCallStack | %{ $_ | Join-String { $_.Location } } | Join.UL
                $InputObject | % {
                    $_ | Join-String { $_.Location }
                }
                break
            }
            'Module' {
                $InputObject
                | Join-String { $_.Name, $_.Version -join ' = ' } -sep $Config.Separator
                break

            }
            default { throw "UnhandledJoinKind: $Kind" }
        }
    }
}

function Dotils.Join.Brace {
    <#
    .synopsis
    .example
        Get-Variable | % gettype | Format-ShortTypeName | Sort-Object -Unique | Dotils.Join.Brace
    .example
        'a', 'b', 'c' | Dotils.Join.Brace
        'a', 'b', 'c' | Join-String -DoubleQuote |  Dotils.Join.Brace
        'a', 'b', 'c' | Join-String -DoubleQuote -sep ' | ' |  Dotils.Join.Brace

        [a][b][c]
        ["a""b""c"]
        ["a" | "b" | "c"]
    #>
    # [CmdletBinding()]
    # [Alias('Join.Brace.Dotils')]
    param(
        [ValidateSet('Padding', 'Wrap', 'Thin')]
        [string]$OutputFormat = 'Padding'
    )
    $Config = @{
        Prefix = ' '
        Suffix = ' '
    }

    switch($WhichMode) {
        'Wrap' {
            # $Config = @{
            #     Prefix = ' '
            #     Suffix = ' '
            # }
            $Input | Join-String -op $Config.Prefix -os $Config.Suffix
        }
        'Padding' {
            $Input | Join-String -f "[ {0} ]" #-op ' ' -os ' '
        }
        'Thin' {
            $Input | Join-String -f "[{0}]" -op '' -os ''
        }
        default {
            $Input | Join-String -f "[{0}]" -op ' ' -os ' '
        }
    }
}
function Dotils.Text.Wrap {
<#
    .synopsis
        Suffix string, but do not merge, emit as items
    .DESCRIPTION
        alias name controls whether it's a prefix or suffix
        if alias isn't used, then wrap text on both suffix and prefix
    .example
        'a', 'b', 'c'
            | Dotils.Text.Prefix "- "

        # output:

            - a
            - b
            - c
    .EXAMPLE
        prefix command with module names
            gcm
                | %{
                    $_ | Dotils.Text.Prefix "$( $_.Source  )\" }

        # output

            Ninmonkey.Console\Ensure->Cwd
            dotils\Dotils.ConvertTo-DataTable
            dotils\Dotils.Module.Format-AliasesSummary
            dotils\Dotils.Where-NotBlankKeys
            ImportExcel\Export-ExcelSheet

    .example
        'https://developer.mozilla.org/en-US/docs/Web/API/Node/baseURI'
            | Dotils.Text.Prefix "<a href='" | Dotils.Text.Suffix "'>name</a>"

        # out:
            <a href='https://developer.mozilla.org/en-US/docs/Web/API/Node/baseURI'>name</a>
    .example
        'a', '2'
            | Dotils.Text.Wrap '_'
            | Should -BeExactly '_a_', '_2_'
    .example
        PS> Get-Variable | % Name | qr.Text.Prefix '$'

        Get-Variable | % Name | sort -Unique | qr.Text.Prefix '$'
            $?
            $$
            $args
            $base
            $bpsItems
    #>
    [Alias(
        'Dotils.Text.Prefix', 'Dotils.Text.Suffix',
        '.Text.Suffix', '.Text.Prefix' )]
    param(
        # A value of 0 LinesPadding would be a no-op
        [parameter(Mandatory, Position = 0)]
        [string]$String,

        # text to pad
        [Alias('Text')]
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$InputObject
    )
    process {
        switch -Regex ($PSCmdlet.MyInvocation.InvocationName)  {
            'Prefix' {
                "${String}${InputObject}"
                break
            }
            'Suffix' {
                "${InputObject}${String}"
                break
            }
            default {
                "${String}${InputObject}${String}"
            }
        }
    }
}

function Join.Pad.Item {
    <#
    .SYNOPSIS
       Proc Item,  like -join except the output is an array, not one string.

    #>
    switch($OutputMode){
        default {
            # surround with single space
            $Input -split '\r?\n' | %{  " <{0}> " -f $_ }
        }
    }
    return
    # or basic
    #$Input -split '\r?\n' | %{  "<{0}>" -f $_ }
        # | Join-String -f "`n<{0}>"
}

function Dotils.Start-WatchForFilesModified {
    <#
    .synopsis
        Invoke a scriptblock if files are newer than the last invoke
    .NOTES
        better solution: use events for file watcher
    .EXAMPLE
        Pwsh>
        $error.Clear(); impo Dotils -Force -Verbose -DisableNameChecking

        $sb = { 'hi world' }
        Dotils.Start-WatchForFilesModified -RootWatchDirectory 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs' -FileKinds .psm1 -Verbose -infa Continue -SleepMilliseconds 150 -ScriptBlock $sb
    .EXAMPLE
        Dotils.Start-WatchForFilesModified -RootWatchDirectory H:\data\2023\pwsh\PsModules.dev\GitLogger\docs -FileKinds .ps1 -ScriptBlock {
            $bps_Splat = @{
                BaseDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
                InputObject   = 'MyRepos2.ps.*'
            }
            bps.🐍 @bps_Splat
        } -SleepMilliseconds 1400
    .EXAMPLE
        impo Dotils -Force -Verbose -DisableNameChecking
        $dotils_watch = @{
            FileKinds          = '.psm1', '.ps1', '.psd1'
            InformationAction  = 'Continue'
            RootWatchDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
            SleepMilliseconds  = 450
            Verbose            = $true
            ScriptBlock        = {
                $bps_Splat = @{
                    BaseDirectory = 'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs'
                    InputObject   = 'MyRepos2.ps.*'
                }
                bps.🐍 @bps_Splat
            }
        }

        Dotils.Start-WatchForFilesModified @dotils_watch

    #>
    [CmdletBinding()]
    param(
        [Alias('Path')]
        [Parameter(Mandatory, Position=0)]
        [ArgumentCompletions(
            'H:\data\2023\pwsh\PsModules.dev\GitLogger\docs')]
        [string]$RootWatchDirectory,

        # not currently a regex
        [ArgumentCompletions(
            '.ps1', '.psm1', '.psd1', '.md', '.js', '.html', '.css', '.ts', '.svg', '.md'
        )]
        [Parameter(Mandatory, Position=1)]
        [string[]]$FileKinds,


        # Action to run
        [Alias('Expression', 'Action')]
        [ArgumentCompletions(
            '{
        $bps_Splat = @{
            BaseDirectory = ''H:\data\2023\pwsh\PsModules.dev\GitLogger\docs''
            InputObject   = ''MyRepos2.ps.*''
        }
        bps.🐍 @bps_Splat
    }'
    #-replace '\^M', "`n")
        )]
        [Parameter(Mandatory, Position=2)]
        [ScriptBlock]$ScriptBlock,

        # sleep milliseconds cycle until ctrl+c
        [Alias('SleepAsMs')]
        [int]$SleepMilliseconds  = 1400,

        [switch]$NotSilent
    )
    write-warning 'still NYI? '
    $script:__dotilsStartWatch ??= @{ LastInvokeTime = 0 }
    $state = $script:__dotilsStartWatch

    function __handleIteration {
        [cmdletBinding()]
        $now = [Datetime]::Now
        # $state = $script:__dotilsStartWatch

        $files = gci -LiteralPath $RootWatchDirectory -Recurse -file
            | CountOf -CountLabel 'Files'
            | ?{ $_.Extension.ToLower() -In @( $FileKinds ) }
            | CountOf -CountLabel 'FilesOfType'
            # | ?{ $_.LastWriteTime -gt $state.LastInvokeTime }
            | ?{ $_.LastWriteTime -gt $script:__dotilsStartWatch.LastInvokeTime }
            | sort-object LastWriteTIme -Descending
            | CountOf -CountLabel 'ModifiedFiles'
        $files
            | Write-Information

        if($files.count -gt 0) {
            # wait-debugger
        } else {
            'none found: ' | write-debug # write-host -back darkyellow
            return
        }
        if($Files.count -gt 0){
            $State.lastInvokeTime | Join-String -op 'most recently: ' | write-verbose -verbose

            $files
                | Join-String -sep ', ' -single -p Name -op 'Found New files! (newest): '
                | Write-Information
            'invoke-scriptblock' | write-verbose
            & $ScriptBlock
            $script:__dotilsStartWatch.LastInvokeTime = $now
            $null = 0
        } else {
            'still cached' | write-debug
        }


    }
    try {
        while($true) {
            sleep -Milliseconds $SleepMilliseconds
            'tick' |write-debug
            . __handleIteration
        }
    } catch {
        write-warning 'Dotils.Start-WatchForFilesModified: => catch'
        write-verbose 'Dotils.Start-WatchForFilesModified: => catch'
        throw
    } finally {
        write-verbose 'Dotils.Start-WatchForFilesModified: => finally'
    } clean {
        write-verbose 'Dotils.Start-WatchForFilesModified: => clean'
    }

    'Dotils.Start-WatchForFilesModified: => exit'
        | write-host -fore green

}

function Dotils.Summarize.TypeDef.Properties {
    <#
    .SYNOPSIS
        using class explorer (static type definition)
    .EXAMPLE
        Pwsh> _summarizeTypeDefProperties ([ErrorRecord])
    .EXAMPLE
        Pwsh> [ErrorRecord] | _summarizeTypeDefProperties

        ParentType  Property              Type
        ----------  --------              ----
        ErrorRecord Exception             Exception
        ErrorRecord TargetObject          Object
        ErrorRecord CategoryInfo          ErrorCategoryInfo
        ErrorRecord FullyQualifiedErrorId String
        ErrorRecord ErrorDetails          ErrorDetails
        ErrorRecord InvocationInfo        InvocationInfo
        ErrorRecord ScriptStackTrace      String
        ErrorRecord PipelineIterationInfo ReadOnlyCollection`1
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [Alias('InputObject')]
        [object] $TypeInfo
    )
    begin {
        # AssertCondition: ModuleExists:
        if( -not (gcm  -ea 'ignore' 'Find-Type' -Module ClassExplorer) ) {
            Import-Module -ea 'stop' 'ClassExplorer'
        }
    }
    process {
        if( $TypeInfo -is [type] ) {
            [Type] $Tinfo = $TypeInfo
        } else {
            [Type] $Tinfo = ($TypeInfo).GetType()
        }
        $Tinfo | Find-Member -MemberType Property | %{
            $curProp = $_
            [pscustomobject]@{
                PSTypeName = 'dotils.TypeInfo.Property.Summary'
                ParentType   = $Tinfo.Name
                Property   = $curProp.Name
                Type       = $curProp.PropertyType.Name
            }
        }
    }
}


function Dotils.Format-TaggedUnionString {
    <#
    .synopsis
        renders a tagged union of the distinct set of [Type]-Name's of the values
    .EXAMPLE
        Pwsh>

        Get-Variable | % Gettype | % Name
            | Dotils.Format-TaggedUnionString

        [ "LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable" ]
    .EXAMPLE
        gci .
            | % GetType
            | Dotils.Format-TaggedUnionString

        [ "System.IO.DirectoryInfo" | "System.IO.FileInfo" ]

    .example
        $sample = Get-Variable | % gettype | % Name | sort -Unique -Descending
        $sample | dotils.Format-TaggedUnionString -OutputFormat Default |

        # output: ["LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable"]
    .example
        $sample | Dotils.Format-TaggedUnionString -AsTypeName
            ["LocalVariable" | "NullVariable" | "PSCultureVariable" | "PSUICultureVariable" | "PSVariable" | "QuestionMarkVariable"]

        $sample | Dotils.Format-TaggedUnionString
            ["string" | "string" | "string" | "string" | "string" | "string"]

        .EXAMPLE
        [System.ConsoleColor]
            | fime | % Name | Dotils.Format-TaggedUnionString

        #  ["Black" | "Blue" | "Cyan" | "DarkBlue" | "DarkCyan" | "DarkGray" | "DarkGreen" | "DarkMagenta" | "DarkRed" | "DarkYellow" | "Gray" | "Green" | "Magenta" | "Red" | "value__" | "White" | "Yellow"]
    #>
    param(
        [switch]$AsTypeName,

        [ArgumentCompletions(
            'AsTypeName', 'AsTypeName2',
            'AsTypeName.Name.NinTils',
            'Default'
        )]
        [string]$OutputFormat
    )

    $choices = $Input | Sort-Object -Unique
    if($AsTypeName) { $OutputFormat = 'AsTypeName' }

    # throw 'cat attack this was maybe broken'
    write-warning 'cat attack this was maybe broken'

    switch($OutputFormat) {
        'AsTypeName.Name.NinTils' {
            $choices
                | Format-ShortTypeName
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        'AsTypeName.Name' {
            $choices
                | % GetType | % Name
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        'AsTypeName' {
            $choices
                | % GetType
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding

                break
        }
        default  {
            $choices
                | Join-String -sep ' | ' -Property {
                    $_ | Join-String -DoubleQuote
                }
                # aka: Join-String -op '[ ' -os ' ]']
                | Dotils.Join.Brace -OutputFormat Padding
        }

    }
        # $sample | Dotils.Format-TaggedUnionString | Dotils.Join.Brace
}
# $sample | Dotils.Format-TaggedUnionString | Dotils.Join.Brace

function Dotils.Html.Parse.New-HtmlDocument {
    <#
    .synopsis
        Quickly parse an Html doc using either CSS Selector queries or XPath queries
    .NOTES
        uses PSParseHtml
    .EXAMPLE
        $cssDoc = quick.Html.Doc -Kind Css -Url 'https://xkcd.com/'
        $cssDoc.QuerySelectorAll('img') | Ft
    .EXAMPLE
        $xDoc = quick.Html.Doc -Kind XPath -Url 'https://xkcd.com/'
        $xDoc.SelectNodes('//img') | ft
    #>
    [Alias('Quick.Html.Doc')]
    [OutputType(
        'HtmlAgilityPack.HtmlNode', # XPath from AgilityPack
        'AngleSharp.Html.Dom.HtmlHtmlElement' # Css from AngleSharp
    )]
    param(
        # Should it return a document that uses CSS Selector queries, or XPath queries?
        # Xpath returns [HtmlAgilityPack.HtmlNode]
        # Css returns   [AngleSharp.Html.Dom.HtmlHtmlElement]
        [Parameter(Mandatory, Position = 0)]
        [Alias('As')]
        [ValidateSet( 'Css', 'XPath' )]
        [string] $Kind,

        [Parameter(Position = 1)]
        [Alias('FromUrl')]
        [Uri] $Url,

        [Parameter(Position = 1)]
        [Alias('FromHtml')]
        [Uri] $Content
    )
    if( $Url -and $Content ) { throw "Unexpected combined params: -Url and -Content !" }

    $splatHtml = @{}
    if( $Url ) { $splatHtml.Url = $Url }
    if( $Content ) { $splatHtml.Content = $Content }

    if( -not ( Import-Module 'PSParseHtml' -PassThru) ) { throw "Mandatory Module missing!: 'PSParseHtml'" }

    try {
        switch( $Kind ) {
            'Css' {
                $Doc = ConvertFrom-Html @splatHtml -Engine AngleSharp
            }
            'XPath' {
                $Doc = ConvertFrom-Html @splatHtml -Engine AgilityPack
            }
            default { throw "UnhandledKind: $Kind !" }
        }
    } catch {
        "Failed to create '$Kind' for '$Url'" | Write-Warning
        throw $_
    }
    if( -not $Doc ) { throw "Document was null" }
    return $Doc
}

function Dotils.Html.Table.FromHashtable {
    <#
    .SYNOPSIS
        generate HTML table based on a hashtable
    .EXAMPLE

    $selectEnvVarKeys = 'TMP', 'TEMP', 'windir'
    $selectKeysOnlyHash = @{}
    gci env: | ?{
        $_.Name -in @($selectEnvVarKeys)
    } | %{ $selectKeysOnlyHash[$_.Name] = $_.Value}

    Dotils.Html.Table.FromHashtable -InputHashtable $selectKeysOnlyHash
#output
    <table>
    <tr><td>TMP</td><td>C:\Users\nin\AppData\Local\Temp</td></tr>
    <tr><td>TEMP</td><td>C:\Users\nin\AppData\Local\Temp</td></tr>
    <tr><td>windir</td><td>C:\WINDOWS</td></tr>
    </table>

    #>
    [OutputType('System.String')]
    [Alias('Marking.Html.Table.From.Hashtable')]
    param(
        [Parameter(Mandatory)]
        [hashtable]$InputHashtable #= @{}
    )
    $renderBody = $InputHashTable.GetEnumerator() | % {
        '<tr><td>{0}</td><td>{1}</td></tr>' -f @(
            $_.Key ?? '?'
            $_.Value ?? '?'
        )
    } | Join-String -sep "`n"
    $renderFinal = @(
        '<table>'
        $renderBody
        '</table>'
    ) | Join-String -sep "`n"
    return $renderFinal
    # '<table>'
    # '</table>'

}
function Dotils.Out.XL-AllPropOfBoth {
    [CmdletBinding()]
    param(
        $Obj1, $Obj2,
        [switch]$PassThru

    )

    if($null -eq $Obj1 -or $Null -eq $Obj2) { throw "OneOrBothAreNull!" }

    $tInfo1 = $Obj1.GetType()
    $tInfo2 = $Obj2.GetType()
    $info = [ordered]@{
        LeftName  = $Obj1.username ?? '<no name>'
        RightName = $Obj2.username ?? '<no name>'
        LeftType  = $tInfo1.FullName
        RightType = $tInfo2.FullName
    }

    $info
        | ConvertTo-Json -depth 3
        | Join-String -op 'User compare: ' | write-verbose -verbose

    $propNames = @(
        $Obj1.PsoObject.Properties.Name
        $Obj2.PsoObject.Properties.Name
    ) | Sort-Object -Unique

    $mergedKind1 = [ordered]@{}
    $mergedKind2 = [ordered]@{}
    $mergedKind1.Source = 'Left'
    $mergedKind2.Source = 'Right'

    $mergedKind1.Type = ($tInfo1)?.GetType().Name ?? "`u{2400}"
    $mergedKind2.Type = ($tInfo2)?.GetType().Name ?? "`u{2400}"
    $mergedKind1.FullTypeName = ($tInfo1)?.GetType().FullName ?? "`u{2400}"
    $mergedKind2.FullTypeName = ($tInfo2)?.GetType().FullName ?? "`u{2400}"

    foreach($name in $PropNames) {
        $mergedKind1.$Name = $Obj1.$Name
        $mergedKind2.$Name = $Obj2.$Name

        $mergedKind1.$Name ??= "`u{2400}"
        $mergedKind2.$Name ??= "`u{2400}"
    }
    Wait-Debugger

    $query = @(
        [pscustomobject]$mergedKind1
        [pscustomobject]$mergedKind2
    )
    if($PassThru) { return $query }
    $query | to-xl
}
# $JCUpdateCsvRecord.psobject.Properties.name

function Dotils.SamBuild {
    [CmdletBinding()]
    param(
        [switch]$Fast,
        [string]$LogPath = 'g:\temp\last_sam.log'
    )
    write-warning 'maybe not fuly done'
    Get-Location
        | Join-String -f 'SamBuild::FromDir: "{0}"'
        | write-host -back 'red'

    [Collections.Generic.List[Object]]$SamArgs = @(
        '--debug'
        'build', '--use-container',
        '--parallel'
        if(-not $Fast) {
            '--cached',
            '--skip-pull-image'
        }
    )
    (get-date).ToString('o')
        | Join-String -op 'SamBuild.ps1: ' -os "`n`n"
        | Add-Content $LogPath -PassThru

    $SamArgs
        | Join-String -sep ' ' -op 'Invoke Sam: => '
    & 'sam' @SamArgs
        | Add-Content $LogPath -PassThru

    $LogPath
        | Join-String -f 'SamBuild::Wrote Log: <file:///"{0}">'
        | Write-host -back 'darkyellow'
}


function Dotils.Measure-CommandDuration {
    <#
    .synopsis
        sugar to run a command and time it. low precision. just a ballpark
    #>
    [Alias(
        # 'TimeOfSb',
        'Dotils.Measure.CommandDuration',
        # 'Dotils.Measure-CommandDuration',
        'DeltaOfSBScriptBlock',
        'DeltaOfScriptBlock',
        'DeltaOfSB',
        'dotils.DeltaOfSB',
        'debug.Measure.ScriptDuration'
    )][CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [object]$Expression )

    if (-not $Expression -is 'scriptblock') {
        throw "Unhandled type: [$($Expression.GetType().Name)] !"
    }

    class DeltaOfRecord {
        [datetime]$Start
        [datetime]$End
        [object]$Result

        # [Alias('NotFailed')]
        [bool]$Success
        hidden [object]$OriginalScriptBlock

        DeltaOfRecord ( [object]$InputScriptBlock ) {
            $this.OriginalScriptBlock = $InputScriptBlock # maybe as text to be safer? smaller?
            $this.Start = [Datetime]::Now
            try {
                $this.Result = & $InputScriptBlock
                $this.Success = $true
            }
            catch {
                $this.Success = $false
                $_ | Join-String -f 'Something Failed 😢: {0}'
                | Write-Error
            }
            $this.End = [Datetime]::Now
        }
        [timespan] Delta() { return $this.End - $this.Start }

    }
    $start = Get-Date
    $result = & $Expression
    $end = Get-Date
    [pscustomobject]@{
        Result     = $result
        Start      = $start
        End        = $end
        Duration   = ($end - $start)
        DurationMs = ($end - $start).TotalMilliseconds
    }
}


function Dotils.Test-AnyTrueItems {
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
    [Alias('Test-AnyTrue')]
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


function Dotils.Tablify.ErrorRecord { # nyi: wip: finish: todo: update this to match ExcelAnt
    [CmdletBinding()]
    param (
        [Alias('ErrorRecord', 'Exception')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object]$InputObject,

        [Alias('List')]
        [switch]$ListPropertySets,
        [switch]$Fancy,

        [ArgumentCompletions(
            'ErrorRecord_AutoFindMember',
            'ErrorRecord_Basic',
            'ErrorRecord_FindMember_Basic',
            'ErrorRecord_FindMember_Static',
            'ErrorRecord_GetProperty_Auto',
            'ErrorRecord_GetProperty_Basic',
            'ErrorRecord_GetProperty_Static',
            'ExceptionRecord_Basic'
        )]
        [string[]]$PropertySets
    )
    begin {
        <#
        other info: <https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.2#psitemexception>

            $_.InvocationInfo
            $_.ScriptStackTrace
            $_.Exception
            $_.Exception.Message
            $_.Exception.InnerException
            $_.Exception.StackTrace


        #>
        if ($PSBoundParameters.ContainsKey('PropertySets')) { throw "NYI: Property sets are wip: $PSCommandPath" }
        $script:__dPropList ??= @{} # redundanly calculated
        $__propList = $script:__dPropList
        $__propList.ErrorRecord_AutoFindMember = @(
            [System.Management.Automation.ErrorRecord]
            | fime -Force
            | % Name | sort -Unique
        )
        $__propList.ErrorRecord_GetProperty_Auto = @() # todo: Psobject.Properties.Name nyi  'nyi, need to move to process or end'

        <#
        ErrorRecord_AutoFindMember
            type | Find-Member
        ErrorRecord_FindMember
            manual names from
        ErrorRecord_BasicFindMember
            type | Find-Member  - someProps
        ErrorRecord_AutoFindProperty
            psobject.properties
        ErrorRecord_BasicAutoFindProperty
            psobject.properties - someProps

        #>
        $__propList.ErrorRecord_FindMember_Static = @( # from: [ErrorRecord] | Find-Member -force
            '_activityOverride'
            '_category'
            '_categoryInfo'
            '_error'
            '_errorId'
            '_invocationInfo'
            '_isSerialized'
            '_pipelineIterationInfo'
            '_reasonOverride'
            '_scriptStackTrace'
            '_serializedErrorCategoryMessageOverride'
            '_serializedFullyQualifiedErrorId'
            '_serializeExtendedInfo'
            '_target'
            '_targetNameOverride'
            '_targetTypeOverride'
            '.ctor'
            '<>c'
            '<ErrorDetails>k__BackingField'
            '<PreserveInvocationInfoOnce>k__BackingField'
            '<ToPSObjectForRemoting>b__12_0'
            '<ToPSObjectForRemoting>b__12_1'
            '<ToPSObjectForRemoting>b__12_10'
            '<ToPSObjectForRemoting>b__12_11'
            '<ToPSObjectForRemoting>b__12_14'
            '<ToPSObjectForRemoting>b__12_15'
            '<ToPSObjectForRemoting>b__12_2'
            '<ToPSObjectForRemoting>b__12_3'
            '<ToPSObjectForRemoting>b__12_4'
            '<ToPSObjectForRemoting>b__12_5'
            '<ToPSObjectForRemoting>b__12_6'
            '<ToPSObjectForRemoting>b__12_7'
            '<ToPSObjectForRemoting>b__12_8'
            '<ToPSObjectForRemoting>b__12_9'
            'CategoryInfo'
            'ConstructFromPSObjectForRemoting'
            'ErrorDetails'
            'Exception'
            'FromPSObjectForRemoting'
            'FullyQualifiedErrorId'
            'GetInvocationTypeName'
            'GetNoteValue'
            'GetObjectData'
            'InvocationInfo'
            'IsSerialized'
            'LockScriptStackTrace'
            'NotNull'
            'PipelineIterationInfo'
            'PopulateProperties'
            'PreserveInvocationInfoOnce'
            'ScriptStackTrace'
            'SerializeExtendedInfo'
            'SetInvocationInfo'
            'SetTargetObject'
            'TargetObject'
            'ToPSObjectForRemoting'
            'ToString'
            'WrapException'
        )
        $innerConfig = @{
            IgnoreDunder = $true
            IgnoreUnder  = $true
        }
        $__propList.ErrorRecord_FindMember_Basic = @( # dynamic, yet simplified list
            @(
                $propList.ErrorRecord_AutoFindMember
                $propList.ErrorRecord_FindMember_Static
            )
            | Sort-Object -Unique
            | ? {
                if ($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
                if ($_ -match [regex]::escape('k__BackingField')) { return $false }
                if ($_ -match [regex]::escape('^.ctor')) { return $false }
                if ( $innerConfig.IgnoreUnder -and $_ -match '^_{1}') { return $false }
                if ( $innerConfig.IgnoreDunder -and $_ -match '^_{2}') { return $false }
                $true
            }
        )
        $__propList.ErrorRecord_GetProperty_Static = @(
            '_activityOverride'
            '_category'
            '_categoryInfo'
            '_error'
            '_errorId'
            '_invocationInfo'
            '_isSerialized'
            '_pipelineIterationInfo'
            '_reasonOverride'
            '_scriptStackTrace'
            '_serializedErrorCategoryMessageOverride'
            '_serializedFullyQualifiedErrorId'
            '_serializeExtendedInfo'
            '_target'
            '_targetNameOverride'
            '_targetTypeOverride'
            '<ErrorDetails>k__BackingField'
            '<PreserveInvocationInfoOnce>k__BackingField'
            'CategoryInfo'
            'ErrorDetails'
            'Exception'
            'FullyQualifiedErrorId'
            'InvocationInfo'
            'IsSerialized'
            'PipelineIterationInfo'
            'PreserveInvocationInfoOnce'
            'PSMessageDetails'
            'ScriptStackTrace'
            'SerializeExtendedInfo'
            'TargetObject'
        )
        $__propList.ErrorRecord_GetProperty_Basic = @(
            @(
                $__propList.ErrorRecord_GetProperty_Static
                $__propList.ErrorRecord_GetProperty_Auto
            ) | ? {
                if ($_ -match [regex]::escape('^<ToPSObjectForRemoting>')) { return $false }
                if ($_ -match [regex]::escape('k__BackingField')) { return $false }
                if ($_ -match [regex]::escape('^.ctor')) { return $false }
                if ( $innerConfig.IgnoreUnder -and $_ -match '^_{1}') { return $false }
                if ( $innerConfig.IgnoreDunder -and $_ -match '^_{2}') { return $false }
                $true
            }
        )

    }
    process {
        $meta = [ordered]@{}
        $IncludeFancy = $true
        $target = $InputObject
        $metaFancy = @{}

        switch ($target) {
            { $_ -is 'System.Management.Automation.ErrorRecord' } {
                Write-Verbose 'found type: [ErrorRecord]'
                $captureProps = $_ | Select-Object *

                $curPropSet = @{}
                if ($IncludeFancy) {
                    foreach ($Prop in $__propList.ErrorRecord_Basic) {
                        $curPropSet[$Prop] = ($Target.$Prop)?.ToString() ?? '<␀>'
                    }
                    $metaFancy['ErrorRecord_Basic'] = $curPropSet ?? @{}
                }
                break
            }
            { $_ -is 'System.Exception' } {
                Write-Verbose 'found type: [Exception]'
                $captureProps = $_ | select *

                $curPropSet = @{}
                if ($IncludeFancy) {
                    foreach ($Prop in $__propList.ExceptionRecord_Basic) {
                        $curPropSet[$Prop] = ($Target.$Prop)?.ToString() ?? '<␀>'
                    }
                    $metaFancy['Exception_Basic'] = $curPropSet ?? @{}
                }
                break
            }
            default {
                throw "UnhandledTypeException: $($Switch.GetType().Name)"
            }
        }
        if (-not $Fancy) {
            return $CaptureProps | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
                PSShortType    = $Target | Format-ShortTypeName
                OriginalObject = $Target
            }
            # $CaptureProps
        }
        return [pscustomobject]$metaFancy | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
            PSShortType    = $Target | Format-ShortTypeName | Join-String -op 'Fancy.'
            OriginalObject = $Target
        }
        # meta not actually used
    }
    end {
        if ($ListPropertySets) {
            return ([pscustomobject]$__propList)
        }
    }
}
function Dotils.Render.ErrorVars {
    <#
    .SYNOPSIS
    auto hide values that are empty  or null, from the above functions
    .link
        Dotils.Describe.ErrorRecord
    .link
        Dotils.Describe.Error
    .link
        Dotils.Render.Error
    .link
        Dotils.Render.ErrorRecord
    .link
        Dotils.Render.ErrorRecord.Fancy
    #>
    [CmdletBinding()]
    param()
    process {
        $t = $_
        if ( -not $t -is 'System.Management.Automation.ErrorRecord' ) {
            $t | Format-ShortTypeName
            | Join-String -f 'Expected [ErrorRecord], got {0}'
            | Write-Verbose
        }
        $target = $InputObject
        [ordered]@{
            Type = $InputObject | Format-ShortTypeName
        }
        # throw 'nyi, wip'
    }
    # a bunch of mmaybe
}
function Dotils.Render.ErrorRecord.Fancy {
    <#
    .SYNOPSIS
    .link
        Dotils.Describe.ErrorRecord
    .link
        Dotils.Describe.Error
    .link
        Dotils.Render.Error
    .link
        Dotils.Render.ErrorRecord
    .link
        Dotils.Render.ErrorRecord.Fancy
    #>
    param(
        [ArgumentCompletions(
            'OneLine',
            'UL', 'List'
        )]
        [string]$OutputFormat
    )
    begin {
        write-warning 'WIP: Dotils.Render.ErrorRecord.Fancy'
    }
    process {
        $InputObject = $_

        switch ($OutputFormat) {
            'OneLine' {
                $InputObject
                    | Dotils.Tablify.ErrorRecord -ListPropertySets
                    | % { $_.PsObject.Properties }
                    | % {
                        $_.name, $_.Value
                            | Join-String -sep ', ' -op "`n$($_.name)"
                    }
                    | Join-String -sep ( Hr 1 )

                break
            }
            { $_ -in @('UL', 'List') } {
                $InputObject
                    | Dotils.Tablify.ErrorRecord -ListPropertySets
                    | % { $_.PsObject.Properties }
                    | % {
                        $_.name, $_.Value
                            | join.UL
                    }
                    | Join-String -sep ( Hr 1)

                break
            }
            default {
                throw "Unhandled OutputFormat $OutputFormat"

            }
        }
    }
}


function Dotils.GetAt {
    <#
    .SYNOPSIS
        goto index, negative is relative the end
    .NOTES
        out of bounds returns null. no errors fired.

        try looking at 'python' slice notation
        and 'jq' json slice notation


        $x = 'a'..'e'
        $x | Nat '[-2::1]'

        $x | Nat '[::2]'
        $x | Nat '[2::4]'
        $x | Nat '[2:1:10]'

    .EXAMPLE
        0..6 | GetAt 5

    .EXAMPLE
        sugar gettting an index
        PS> @('a'..'c')[2]
        PS> 'a'..'c' | Nat 2

        PS> @('a'..'c')[-2]
        PS> 'a'..'c' | Nat -2
    #>
    [Alias('Nat', 'gnat')]
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [AllowNull()]
        [Parameter(Mandatory,ValueFromPipeline)]
        [object[]]$InputObject,

        # future: Support ranges
        [Alias('Offset')]
        [Parameter(Mandatory,position=0)]
        [int]$Index
    )
    begin {
        # negative may not be performant, but that isn't important here
        [int]$CurIndex = 0
        [Collections.Generic.List[Object]]$Items = @()
        $earlyExit = $false
    }
    process {

        $PSCmdlet.MyInvocation.BoundParameters
            | ConvertTo-Json -wa 0 -Depth 0 -Compress
            | Join-String -op 'Dotils.GetAt: '
            | write-verbose
        if($earlyExit) { return }

        # maybe faster for large collections
        if($Index -ge 0) {
            foreach($item in $InputObject) {
                if ($null -eq $Item) {
                    continue
                }
                if($index -eq $curIndex) {
                    $earlyExit = $True
                    return $item
                }
                $curIndex++
            }
            return
        }
        # so it's negative, collect
        $items.AddRange( $InputObject )
    }
    end {
        if($earlyExit) { return }
        $selected = $Items[ $Index ]
        return $selected
    }

}

function Dotils.Join.CmdPrefix {
    process {
        $_ | % {
            label '>' -Separator ' ' $_ | Write.Info
        }
    }
}

function Dotils.LogObject {
    # short minimal log
    [OutputType('String')]
    [Alias('Dotils.㏒')]
    [CmdletBinding()]
    param(
        [Alias('NoCompress')][switch]$Expand,
        [switch]$PassThru
    )
    $jsonSplat = @{
        Compress = -not $Expand
        Depth = 2
    }
    $data = $Input
    $renderJson =
        $data | ConvertTo-Json @jsonSplat

    $actualWidth = $host.ui.RawUI.WindowSize.Width
    $finalRender = @(
        '  ㏒'
        "${fg:gray60}${bg:gray15}"
        $renderJson | shortStr -Length ($actualWidth - 8 )
        $PSStyle.Reset
    ) -join ''

    if($Passthru) {
        return $finalRender # currently still truncates value, returns as string
    }
    return $finalRender
        | Write-Information -infa 'continue'
}
function Dotils.Build.Find-ModuleMembers {
    # find items to export
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [switch]$Recurse
    )

    write-warning 'slightly broke in last  patch'
    $splat = @{
        InputObject = $InputObject
        Recurse = $Recurse
    }
    $outPassThru = @{ OutputFormat = 'PassThru' }
    $outResult   = @{ OutputFormat =   'Result' }

    $astVar      = @{ AstKind = 'Variable' }
    $astFunc  = @{ AstKind = 'Function' }

    # dotils.search-Pipescript.Nin @splat -AstKind Function -OutputFormat Result | % Name | sort-object -Unique |
    # Same thing currently:
    $meta = [ordered]@{}
    # throw "${PSCommandPath}: NYI, lost pipe reference"

    $Meta.Function = @(
        dotils.search-Pipescript.Nin @splat @astFunc @outResult
            | % Name | Sort-Object -Unique
    )

    $Meta.Variable = @(
        dotils.search-Pipescript.Nin @splat @astVar @outPassThru
            | % Result  |  % tokens | % Text
    )
    $Meta.Variable_Content = @(
        dotils.search-Pipescript.Nin @splat @astVar @outPassThru
            | % Result  |  % tokens | % Content
    )
    return $meta

    if($false -and 'old') {

        $Meta.Function = @(
            dotils.search-Pipescript.Nin @splat -AstKind Function -OutputFormat Result
                | % Name | Sort-Object -Unique
        )

        $Meta.Variable = @(
            dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
                | % Result  |  % tokens | % Text
        )
        $Meta.Variable_Content = @(
            dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
                | % Result  |  % tokens | % Content
        )
    }
    # dotils.search-Pipescript.Nin @splat -AstKind Variable -OutputFormat PassThru
}

Function Dotils.Search-Pipescript.Nin {
    <#
    .synopsis
    sugar to pass fileinfo or filepath or contents, as the source to search
    .example
        dotils.search-Pipescript.Nin -Path (gcl|gi) -AstKind Function
            | % Result | % Name | sort -Unique
    .example
        $src = Get-Item 'foo\bar.psm1'
        Dotils.Search-Pipescript.Nin -Path $src -AstKind 'Function'
    .example
        Dotils.Search-Pipescript.Nin -Path 'C:\foo\utils.psm1' -AstKind 'Function'
        Dotils.Search-Pipescript.Nin -Path 'C:\foo\utils.psm1' -AstKind 'Variable'
    .example
        $content = gc -raw -Path 'C:\foo\utils.psm1'
        $sb = [scriptblock]::Create( $content )
        Dotils.Search-Pipescript.Nin -Path C:\foo\utils.psm1' -AstKind 'Variable'
    .example
        # Several output shapes defined as sugar

            $splatSearch = @{
                InputObject = $srcWrapModule
                AstKind = 'Function'
            }

            dotils.search-Pipescript.Nin @splatSearch -OutputFormat PassThru
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Result
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Tokens
            dotils.search-Pipescript.Nin @splatSearch -OutputFormat Value
    #>
    param(
        # Make paramset that allow paging or not, but positional is automatic
        [Parameter(Mandatory, Position=0)]
        [Alias('LiteralPath', 'Path')]
        [object]$InputObject,

        # This is AstKind, not defined inline, yet
        [Parameter(Mandatory, Position=1)]
        [ArgumentCompletions(
            # "'Function'", "'Variable'"
            'Function', 'Variable', 'wipAutoGenKinds'
        )][string]$AstKind,


        # this is not an AST type, it's properties on the value returned
        # by find-pipescript, drilling down
        [Parameter(Mandatory, Position=2)]
        [Alias('As')][ValidateSet(
            'PassThru', 'Result', 'Tokens', 'Value',
            'VariablePath'
        )][string]$OutputFormat = 'PassThru',

        [switch]$Recurse
    )
    function __getSBContent {
        # file info, filepath, script block, or string?
        param(
            [Parameter(Mandatory)]
            [object]$InputObject
        )
        if( Test-Path $InputObject ) { # already is path/fileinfo
            $content = gc -raw -Path (gi -ea 'stop' $InputObject)
            return $content
        }
        if($InputObject -is 'ScriptBlock') {
            $content = $InputObject
            return $content
        }
        if($InputObject -is 'String') {
            $content = [ScriptBlock]::Create( $InputObject )
            return $content
        }
        throw "Unknown coercion, UnhandledType: $($InputObject.GetType().Name)"
    }
    $content = __getSBContent -InputObject $InputObject
    $sb = [scriptblock]::Create( $content )

    # dotils.search-Pipescript.Nin -Path $srcWrapModule -AstKind Variable | % Result | % Tokens | ft


    $query = Pipescript\Search-PipeScript -InputObject $sb -AstType $AstKind -recurse $Recurse
    switch($OutputFormat) {
        'PassThru' {
            $query
            write-verbose "Using: $AstKind"
            break
        }
        'Result' {
            $query | % Result
            write-verbose "Using: $AstKind | % Result"
            break
        }
        'VariablePath' {
            $query | % Result | % VariablePath
            write-verbose "Using: $AstKind | % Result.VariablePath"
            break
        }
        'Value' {
            $query | % Result | % Value
            Write-warning 'type "value" doesn''t work? or wrong type?'
            write-verbose "Using: $AstKind | % Result.Value"
            break
        }
        'Tokens' {
            $query | % Result | % Tokens
            write-verbose "Using: $AstKind | % Result.Tokens"
            break
        }
        default { throw "UnhandledOutputFormat: '$OutputFormat'" }
    }

    # if($InputObject -is 'ScriptBlock') {
    #     $content = $InputObject
    # }
    # if( -not (Test-Path $InputObject) -and $InputObject -is 'String' ) {
    #     $content = $InputObject # if not a path, assume  content
    # }
    # $sb = [scriptblock]::Create( $content )
}


function Dotils.Completers.FindUsingBindingFlags {
    <#
    .synopsis
        Find [CustomArgumentCompleters] using property info and the context
    .DESCRIPTION
        from a [seeminglyscience] discord thread: <https://discord.com/channels/180528040881815552/447476117629304853/1216849408411308093>
    #>
    [OutputType(
        [Dictionary[String, ScriptBlock]],
        [Object]
    )]
    param(
        # return the dict only
        [switch]$PassThru
    )
    $ctx = $ExecutionContext.GetType().
            GetField('_context', 'NonPublic, Instance').
            GetValue($ExecutionContext)

    $completers = $ctx.GetType().GetProperty('CustomArgumentCompleters', [System.Reflection.BindingFlags] 'NonPublic, Instance')
    # $completers.GetValue($ctx)
    $info = [ordered]@{
        CompletersDict = $completers.GetValue($ctx)
        Ctx = $ctx
        # -is [RuntimePropertyInfo]
        CompletersPropertyInfo = $ctx.GetType().
            GetProperty(
                'CustomArgumentCompleters',
                [System.Reflection.BindingFlags] 'NonPublic, Instance'
            )

        # -is [Dictionary<string, ScriptBlock>]
    }
    if($PassThru) { return $info.CompletersDict }
    return [pscustomobject]$info
}
function Dotils.TryCompletion {
    <#
    .SYNOPSIS
        try global generic completions, cached results for speed
    .NOTES
        If passThru, you get the full [CommandCompletion]
        else drills down to the [List[CompletionResult]] for you
    .EXAMPLE
        Dotils.TryCompletion -CommandString 'trace-command -name '
    .LINK
        Dotils.TryCompletion
    .LINK
        Dotils.CompareCompletions
    #>
    [Alias('Quick.TryCompletion')]
    [OutputType( [System.Management.Automation.CompletionResult[]] )] #, ParameterSetName = '__AllParameterSets')]
    [OutputType( [System.Management.Automation.CommandCompletion], ParameterSetName = 'PassThru')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
            [Alias('Command', 'Text', 'Content')]
            [ArgumentCompletions(
                "'Trace-Command -name '"
            )]
            [string] $CommandString,

            # index to place cursor. Negative values are relative the end of string
            # if not set, defaults to the value ($CommandString.Length)
            [int]    $RelPosition,

            [Parameter(ParameterSetName='PassThru')]
            [switch] $PassThru
    )
    if( -not $PSBoundParameters.ContainsKey('RelPosition') ) {
        $finalPosition = $CommandString.Length
    } else {
        if($RelPosition -lt 0) {
            $finalPosition = $CommandString.Length + $RelPosition
        } else {
            $finalPosition = $RelPosition
        }
    }

    $keyName = "${CommandString}_${FinalPosition}"
    @{
        RelPosition = $RelPosition
        FinalPosition = $FinalPosition
        CommandStr = $CommandString
    } | Json -Depth 1 | Join-String -op 'TryCompletionParams: ' | write-verbose

    $query = CacheMe -Name $KeyName -PassThru -ScriptBlock {
        TabExpansion2 -inputScript $CommandString -cursorColumn $FinalPosition
    }
    # TabExpansion2 -inputScript ( $str = 'Trace-Command -name *' ) -cursorColumn ($str.Length - 0)
    # $query =  @( TabExpansion2 -inputScript $CommandString -cursorColumn $FinalPosition )

    if($PassThru) { return $query }
    # | % CompletionMatches
    return $Query.CompletionMatches
}


function Dotils.IsBlank {
    <#
    .synopsis
        blank or not sugar. Test whether something is null, empty string, not empty but whitespace
    .EXAMPLE
        IsBlank $FakeObject TrueNull
        IsBlank $FakeObject Empty
        IsBlank '' Empty
        IsBlank '' Whitespace
        IsBlank '' TrueNull
        IsBlank $Null TrueNull
        IsBlank "`n" Whitespace
        IsBlank "`n" Empty

        #outputs
        True, True, True, True, False, True, True, False
    #>
    [CmdletBinding()]
    param(
        [Parameter()]$Obj,

        # this parameter will auto complete
        [Parameter()]
        [ValidateSet('TrueNull', 'Empty', 'EmptyString', 'Whitespace')]
        $Mode = 'Whitespace'
    )
    switch( $Mode ) {
        'TrueNull'    { $null -eq $Obj }
        'Empty'       { [string]::IsNullOrEmpty( $Obj ) }
        'WhiteSpace'  { [string]::IsNullOrWhiteSpace( $Obj ) }
        'EmptyString' { $Obj -is [string] -and $Obj.Length -eq 0 }

        default { throw "ShouldNeverReach: Unhandled Mode: $Mode" }
    }
}

function Dotils.Db.ConnectDefault {
    param()
    Import-Module 'Dbatools'   -PassThru -ea 'stop'
    Import-Module -PassThru -ea 'stop' -Force (gi -ea 'stop' 'H:/data/2024/sql/Pwsh/MonkeyData/src/MonkeyData/MonkeyData.psm1')
    $SqlAzureConnectionString ??= Get-Secret -Name 'GitLogger.SqlAzureConnectionString' -AsPlainText
    MonkeyData.Try-AcceptLocalhostCert -ComputerName $env:COMPUTERNAME
    @(  Connect-DbaInstance -Connstring $SqlAzureConnectionString
        Connect-DbaInstance -SqlInstance 'nin8\sql2019'
    ) | Write-Verbose
    Get-DbaConnectedInstance
}
function Dotils.CompareCompletions {
    <#
    .synopsis
        capture completion texts, easier
    .description
        two ways to invoke for simplicity. if you pass a 2nd string it will take that as the position.
    .LINK
        Dotils.TryCompletion
    .LINK
        Dotils.CompareCompletions
    .EXAMPLE
        two ways to invoke for simplicity. if you pass a 2nd string it will take that as the position.

        > CompareCompletions -Prompt '[int3' -verb -ColumnOrSubstring '[in'
        > CompareCompletions -Prompt '[int3' -verb -ColumnOrSubstring 3

    #>
    [Alias('CompareCompletions')]
    [CmdletBinding()]
    param(
        # text to be completed
        [string]$Prompt,

        # offset or the substring, it will take that as the position.
        [object]$ColumnOrSubstring


        # [int]$Limit = 5
        # [switch]$Fancy,

        # [switch]$PassThru = $true
    )
    # if($ColumnOrSubstring -is 'int') {}

    # if ($false) {
    #     $Column = $ColumnOrSubString -as 'int'
    #     $Column ??= $ColumnOrSubstring.Length
    #     $Column ??= $Prompt.Length
    # # $Column++ # because it's 1-based
    #     if ($Column -le 0 -or $column -gt $Prompt.Length ) {
    #         Write-Error "out of bounds: $Column from $ColumnOrSubString, actual = $($Prompt.Length)"
    #         return
    #     }
    # }
    # $Column = [Math]::Clamp( ($Column ?? 0), 1, $Prompt.Length)
    if ($ColumnOrSubstring -is 'int') { $Col = $ColumnOrSubstring -as 'int' }
    else { $Col = $ColumnOrSubstring.Length }

    # else { $Col = $ColumnOrSubstring.Length - 1 }
    $Col | Join-String -f 'Column: {0}' | Write-Verbose

    # $query = TabExpansion2_Original -inputScript $Prompt -cursorColumn $Column
    $query = TabExpansion2 -inputScript $Prompt -cursorColumn $Col
    $results = $query.CompletionMatches

    if ($true -or $PassThru) { return $results }

    # $results | Sort CompletionText | select -First $Limit -Last $Limit
    # $results | Sort ListItemText | select -First $Limit -Last $Limit
    # $results | Sort ResultType | select -First $Limit -Last $Limit
    # $results | sort Tooltip | select -First $Limit -Last $Limit
}



function Dotils.Testing.Validate.ExportedCmds {
    <#
    .EXAMPLE
        [string[]]$cmdList = @(
            $mod.ExportedAliases.Keys
            $mod.ExportedFunctions.Keys
        ) | Sort-Object -Unique
    #>
    [Alias('MonkeyBusiness.Vaidate.ExportedCommands')]
    [CmdletBinding()]
    param(
        [string[]]$CommandName,
        [string]$ModuleName

        # # import before testing names
        # [Alias('ForceImport')]
        # [switch]$PreImport
    )
    if (-not $PSBoundParameters.ContainsKey('CommandName')) {
        # from
        if ($ModuleName -ne 'dotils') {
            Import-Module -Force -Name $ModuleName -ea 'stop' -PassThru | Write.Info
        }
        $mod = Get-Module -Name $ModuleName

        [string[]]$cmdList =
        @(  $Mod.ExportedCommands.keys
            $Mod.ExportedAliases.keys )
        | Sort-Object -Unique
    }
    else {
        [string[]]$cmdList =
        $CommandName
        | Sort-Object -Unique
    }

    $cmdList | join.UL | Join-String -op 'Commands found: ' | Write-Verbose

    $stats = $cmdList | % {
        # label '>' -Separator ' ' $_ | Write.Info
        [pscustomobject]@{
            Name      = $_
            IsAFunc   = ( $is_func = Test-Path function:\$_ )
            IsAnAlias = ( $is_alias = Test-Path alias:\$_    )
            IsBad     = $is_func -and $is_alias
        }
    }
    $stats
}


function Dotils.GetCommand {
    [Alias(
        # 'Dotility.GetCommand',
    )]
    param()

    @(
        Get-Command -Module 'dotils'
    ) | Sort-Object -Unique

    if ($true) { return } # skip older code
    $gcmSplat = @{
        ErrorAction = 'continue'
        Name        = @(
            # 'Dotility.CompareCompletions'
            # 'Dotility.GetCommand'
            'Dotils.CompareCompletions'
            'Dotils.GetCommand'
            'Dotils.Render.ErrorRecord.Fancy'
            'Dotils.Render.ErrorRecord'
            'Dotils.Tablify.ErrorRecord'
            'Dotils.Measure-CommandDuration'
            # was:
            # 'Dotils.Measure-CommandDuration'
            # 'Dotils.Tabilify.ErrorRecord'
            # 'Dotils.Render.ErrorVars'
            # 'Dotils.Render.ErrorRecord.Fancy'
        )
    }
}

# function .Str.Substr { }
function __Dotils.Format.WrapLongLine {
    # [Alias('.Format.Split-StringIntoLines')]
    param(
        [string]$InputString,
        [int]$MaxLineLength = 80
    )

    $regex = [regex]::new(".{1,$MaxLineLength}(?:\s|$)", [Text.RegularExpressions.RegexOptions]::multiline)

    $matches = $regex.Matches($InputString)

    foreach ($match in $matches) {
        $match.Value.TrimEnd()
    }
}

function Dotils.Format.WrapLongLine  {
    <#
    .SYNOPSIS
        sugar to quickly wrap max line length
    .notes
        Warning: Super Naive, Uses [char[]] not Rune enumeration
    #>
    [Alias('.Format.Wrap.LongLines')]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(ValueFromPipeline)]
        [string[]]$InputObject,

        [parameter()]
        [ArgumentCompletions(
            "(Console.Width)",
            "((Console.Width) - 20)"
        )]
        [Alias('Cols', 'Width', 'LimitWidth')]
        [int]$MaxLineLength = 80,

        [switch]$AutoSize
    )
    process {
        if($AutoSize) {
            $MaxLineLength = Console.Width
        }
        foreach($CurLine in $InputObject) {
            [string]$Text = $CurLine -join '' -replace '\r?\n', "`n"
            $charLength = $Text.Length
            $runeLength = $Text.EnumerateRunes().Value.Count

            __Dotils.Format.WrapLongLine -Inp $Text -MaxLineLength $MaxLineLength
        }
    }
}
function Dotils.Format.TextMargin {
    <#
    .synopsis
        mimic a box-model
    .EXAMPLE
        $one.InnerHtml
            | Dotils.Format.TextMargin -Top 2 -Bottom 2
    #>
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(ValueFromPipeline)]
        [string[]]$InputObject,

        # [string]$AlignmentStyle = 'center',

        [Alias('Predent', 'Left')]
        [Parameter()]$MarginLeft = 0,

        [Alias('Right')]
        [Parameter()]$MarginRight = $Null,

        [Parameter()]
        [Alias('Center', 'MarginCenter', 'Middle', 'Both', 'PadBoth')]
        $MarginBoth = $null,

        [Alias('Top')]
        [Parameter()]
        [int]$MarginTop = 0,

        [Alias('Bottom')]
        [Parameter()]$MarginBottom = 0,

        # auto alight left and right equally
        [switch]$AutoAlignSides,


        # currently in chars
        # is it optional? make length null by default?
        [parameter()]
        [ArgumentCompletions(
            "(Console.Width)",
            "((Console.Width) - 20)"
        )]
        [Alias('Cols', 'Width', 'LimitWidth')]
        [int]$MaxLineLength = $null
    )
    begin {
        [Text.StringBuilder]$strBuild = ''
    }
    process {
        $Null = $strBuild.AppendJoin( "`n", @($InputObject))
        throw  'not sure whether this function (logically) makes sense as a multi-line, wrapping line. write it expecting a single line, wrapping to fit constraints? or, separation of details, where Format-SplitLongLines is to be used?'


        # [string]$Text = $InputObject -join "`n"
        # $NL = "`n"
        # [string]$render = '...nyi...'
        if($PSBoundParameters.ContainsKey('MarginLeft')) { write-warning 'param NYI' }
        if($PSBoundParameters.ContainsKey('MarginRight')) { write-warning 'param NYI' }
    }
    end {

        if($PSBoundParameters.ContainsKey('MarginCenter')) {
            $availableColsPerLine = $MaxLineLength ?? (Console.Width)

        }


        [string]$final_linesPrefix = "`n" * $MarginTop -join ''
        [string]$final_linesSuffix = "`n" * $MarginBottom -join ''
        write-warning 'command NYI, partial WIP'
        [string]$rend = Join-String -inp $strBuild.ToString() -op $final_linesPrefix -os $final_linesSuffix
        # $final_linesPrefix, $render, $final_linesSuffix -join ''
        return $rend
        <#
        next:
            - [ ] set left and right margins
            - [ ] auto-wrap when too long
            - [ ] or align center, automatically
        #>

    }
}


#         $maxChunkLen = 40
# $chunkSize = [int]$wrapLongSrc.Length / $maxChunkLen
# $offset = 0
# while($offset -lt $wrapLongSrc.Length) {
#     $wrapLongSrc[ $offset..($offset + $chunkSize)]
#     $offset += $chunkSize
#     hr;

# $wrapLongSrc





    # }
    # not performant at all
    # $maxChunkLen = 40
    # $chunkSize = [int]$wrapLongSrc.Length / $maxChunkLen
    # $offset = 0
    # while($offset -lt $wrapLongSrc.Length) {
    #     $wrapLongSrc[ $offset..($offset + $chunkSize)]
    #     $offset += $chunkSize
    #     hr;
    # }

    # $wrapLongSrc

# }

function Dotils.Out.Grid2 {
    <#
    .SYNOPSIS
        from jaykul thread: <https://discord.com/channels/180528040881815552/446156137952182282/1112247580848554015>
    .NOTES
        from jaykul thread:
            start:  <https://discord.com/channels/180528040881815552/446156137952182282/1112247580848554015>
            end:    <https://discord.com/channels/180528040881815552/446156137952182282/1112151356644524123>
    #>
    $csv = "${fg:gray40}${bg:gray30}.${fg:clear}${bg:clear}"
    $flags = [System.Reflection.BindingFlags]60 # is: Instance, Static, Public, NonPublic
    filter tosser {
        # jaykul cli test
        $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue($MyInvocation) -join $Csv
    }
    filter generator {
        param(
            [Parameter(ValueFromPipeline)][int]$Inputobject ) 1..$Inputobject
    }
    filter outer { <# jaykul cli test #>   1..($args[0]) }
    filter inner { <# jaykul cli test #> $_ | generator | tosser }


    $input | tosser
    if ($false) {
        Hr -fg Magenta

        filter tosser { $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue($MyInvocation) -join $Csv }
        filter t2 {
            $MyInvocation.GetType().GetProperty('PipelineIterationInfo', 60).GetValue( $MyInvocation ) -join '_'
        }
        0..3 | tosser | grid
        Hr
        0..3 | t2 | grid

        Hr -fg green
    }
}
function Dotils.Select-ExcludeBlankProperty {
    <#
    .SYNOPSIS
        take an object, automatically hide any empty properties
    .EXAMPLE
        Pwsh> Get-Process | Select-ExcludeBlankProperty | fl -force *
    .EXAMPLE
        Pwsh> Get-Command  mkdir
            | Select-Object *
            | Select-ExcludeBlankProperty
            | fl * -Force
    .DESCRIPTION
        'Dotils.Select-ExcludeBlankProperty' => { 'Select-ExcludeBlankProperty' }
        propertes are removed using Select-Object -Exclude so their type changes.

        or rather it's PSTypeName changes from:
            [Diagnostics.Process] , to
            [Selected.Diagnostics.Process]
    .NOTES
        future:
            - [ ] can I preserve the original type, and apply 'hidden' attribute on those members?
        new excludes
            - [ ] ExcludeLongProperties (or truncate them visually. maybe dynamic view)

    #>
    [Alias('Select-ExcludeBlankProperty')]
    [CmdletBinding()]
    [OutputType(
        'System.Object',
        'Selected.System.Diagnostics.Process',
        'System.Management.Automation.PSCustomObject'
    )]
    param(
        [ValidateNotNullOrEmpty()]
        [Alias('Obj')][Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        $Props = $InputObject.PSObject.Properties
        [Collections.Generic.List[object]]$exclusionList = @()

        $Props
            | ForEach-Object {
                if ( [string]::IsNullOrWhiteSpace( $_.Value ) ) {
                    $exclusionList.Add( $_.Name )
                }
            }

        $exclusionList
            | Join-String -sep ', ' -SingleQuote -op '$exclusionList: '
            | Write-Verbose

        return $InputObject | Select-Object -ExcludeProperty $exclusionList
    }
}

function Dotils.Log.Format-WriteHorizontalRule {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}
function Dotils.Log.WriteFromPipe {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}
function Dotils.Log.WriteNowHeader {
   throw 'NYI, Get original: <file:///H:\data\2023\pwsh\PsModules.dev\GitLogger.StartLocalhostAzureChildProcess.ps1>'
}


function Dotils.Quick.GetType {
    <#
    .SYNOPSIS
        dump quick typenames, as text, interactively
    .EXAMPLE
        Pwsh> gcm | gt # it's distinct by default, so no spam
    #>
    [Alias( 'gt', '.quick.GetType' )]
    param(
        [hashtable]$Options
    )

    $Config = mergeHashtable -OtherHash ($Options ?? @{}) -BaseHash @{
    }

    $Input
        | Dotils.Write-StatusEveryN -DelayMS 100
        | % GetType
        | Sort-Object -Unique
        | Format-ShortTypeName
}
function Dotils.Select-NotBlankKeys {
    <#
    .SYNOPSIS
        enumerate hashtable, drop any keys that have blankable vlaues
    #>
    [Alias(
        'Dotils.DropBlankKeys',
        'Dotils.Where-NotBlankKeys',
        '.Drop.BlankKeys'
    )]
    [CmdletBinding()]
    [OutputType('Hashtable')]
    param(
        [Parameter(mandatory, Position=0, ValueFromPipeline)]
        [hashtable]$InputHashtable,

        [switch]$NoMutate
    )
    if ($NoMutate) {
        $targetHash = [hashtable]::new( $InputHashtable )
    }
    else {
        $targetHash = $InputHashtable
    }

    $toDrop =
        $targetHash.GetEnumerator()
            | Where-Object { -not [string]::IsNullOrEmpty( $_.Value ) }
            | ForEach-Object Name

    foreach ($k in $toDrop) {
        $targetHash.Remove( $k )
    }
    return $targetHash

}

function Dotils.AutoJson {
    <#
    .SYNOPSIS
        Try one of the automatic methods uses [Text.Json]
    .notes
        [System.Text.Json.JsonSerializer] has a ton of overloads
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.text.json.jsonserializer?view=net-8.0#method
    .link
        Dotils.AutoJson
    .link
        Dotils.AutoJson.FromCOnvertToCmdlet
    #>
    # [Alias('AutoJson')]
    param(
        [Alias('InObj', 'In')]
        [object] $Object,

        # Without a type, it falls back to GetType()
        [Alias('Tinfo', 'T')]
        [type] $TypeInfo
    )
    if(-not $TypeInfo ) { $TypeInfo = $Object.GetType() }
    [Text.Json.JsonSerializer]::Serialize( <# value: #> $Object, <# tinfo #> $TypeInfo )
}
function Dotils.AutoJson.FromConvertToCmdlet {
    <#
    .SYNOPSIS
        uses the Pwsh cmdlet's function rather than Text.Json
    .EXAMPLE
        Dotils.AutoJson.FromConvertToCmdlet -MaxDepth 0 -InputObject (get-item .) | jq -C
    .link
        Dotils.AutoJson
    .link
        Dotils.AutoJson.FromCOnvertToCmdlet
    .link
        [Microsoft.PowerShell.Commands.JsonObject]
    .link
        [Microsoft.PowerShell.Commands.JsonObject+ConvertToJsonContext]
    #>
    param(
        $InputObject,
        [int] $MaxDepth = 4,
        [switch] $WithoutEnumStrings,

        [Alias('Minify')]
        [Parameter()]
        [switch] $Compress
    )
    <#

    ### overloads

    public ConvertToJsonContext(
        int maxDepth, bool enumsAsStrings, bool compressOutput);

    public ConvertToJsonContext(
        int maxDepth, bool enumsAsStrings, bool compressOutput,
        StringEscapeHandling stringEscapeHandling,
        PSCmdlettargetCmdlet,
        CancellationToken cancellationToken);
    #>

    $conText = [Microsoft.PowerShell.Commands.JsonObject+ConvertToJsonContext]::new(
            <# MaxDepth #> $MaxDepth,
            <# enums as strings #> (-not $WithoutEnumStrings),
            <# compress output #> $Compress )

    return [Microsoft.PowerShell.Commands.JsonObject]::ConvertToJson( $InputObject, [ref]$conText )
}

function Dotils.List.Collect.Pipeline {
    <#
    .synopsis
        collect pipeline as a [List[Object]]

    #>
    [Alias(
        'Dotils.Rollup',
        'Dotils.CollectList',
        'List.FromPipe')]
    [Cmdletbinding()]
    [OutputType('System.Collections.Generic.List[Object]')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,


        # write info showing list count, and typenames of values
        [Alias('Stats')][switch]$ShowStats,

        # pipe to command <CountOf> for orange infa action summary
        [switch]$ShowCountOf
    )
    begin {
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject) )
    }
    end {

        $statsMessage = '   List[ {0} ] := {{ FirstChild: [{1}], .., LastChild: [{2}] }}' -f @(
            $Items.Count
            @($Items)[0 ]?.GetType().Name ?? "`u{2400}"
            @($Items)[-1]?.GetType().Name ?? "`u{2400}"
        )
        $statsMessage
            | Dotils.Write-DimText
            | write-verbose

        if($ShowStats) {
            $statsMessage #| Write-information -infa 'Continue'
                | Dotils.Write-DimText
                | Infa
        }
        if($ShowCountOf) {
            return $Items | CountOf
        }
        return $Items
    }
}



function Dotils.List.ContainsList {
    <#
    .synopsis
        For two lists, compare whether one contains the other
    .EXAMPLE
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' )
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' ) B.In.A

    .EXAMPLE
        Pwsh 7> 🐒
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' ) A.In.B
        | Join-String -sep ' '
        c d e f

        Pwsh 7> 🐒
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' ) A.NotIn.B
        | Join-String -sep ' '
        a b

        Pwsh 7> 🐒
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' ) B.In.A
        | Join-String -sep ' '
        c d e f

        Pwsh 7> 🐒
       Dot.List.Contains -ListA @('a'..'f') -ListB @( 'c'..'z' ) B.NotIn.A
        | Join-String -sep ' '
        g h i j k l m n o p q r s t u v w x y z

    #>
    [Alias(
        'Dot.List.Contains'
    )]
    param(
        [Alias('A')]
        [object[]]$ListA,
        [Alias('B', 'Other')]
        [object[]]$ListB,

        [Parameter()]
        [validateSet(
            'A.In.B',
            'A.NotIn.B',
            'B.In.A',
            'B.NotIn.A'
            # 'A ∋ B',
            # 'A ∌ B',
            # 'B ∋ A',
            # 'B ∌ A',
        )]
        [string]$Comparison = 'A.In.B'
    )
    switch($Comparison){
        'A.In.B' {
            $ListA | ?{
                $_ -in @( $ListB )
            }
        }
        'A.NotIn.B' {
            $ListA | ?{
                $_ -notin @( $ListB )
            }
        }
        'B.In.A' {
            $ListB | ?{
                $_ -in @( $ListA )
            }
        }
        'B.NotIn.A' {
            $ListB | ?{
                $_ -notin @( $ListA )
            }
        }
    }
    return
}

function Dotils.Proxy.GetError {
    <#
    .SYNOPSIS
        always pipe from debug ,
        optionally the oldest error
    #>
    [Alias('Dot.Err')]
    [CmdletBinding(DefaultParameterSetName='Newest', HelpUri='https://go.microsoft.com/fwlink/?linkid=2241804')]

    param(
        [Parameter(ParameterSetName='Error', Position=0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        ${InputObject},

        [Parameter(ParameterSetName='Newest')]
        [Alias('Last')]
        [ValidateRange(1, 2147483647)]
        [int]
        ${Newest}),

        [switch]$Oldest

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            label 'ExpectInput' $PSCmdlet.MyInvocation.ExpectingInput
                write-warning 'nyi'
            if( -not $Pscmdlet.MyInvocation.ExpectingInput ) {
                write-warning 'nyi'
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Get-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
            # $scriptCmd = { $global:Error | & $wrappedCmd @PSBoundParameters } # this breaks "query folding" I think, I think it doesn't pipe correctly
            write-warning 'validate this will pipe correctly'
            $scriptCmd = { & $wrappedCmd @PSBoundParameters } # this breaks "query folding" I think, I think it doesn't pipe correctly

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
        label 'Dot.Err' 'Summary'
        $global:error
            | Select -first 5
            | Join-string -Property CategoryInfo -sep "`n" -f "    {0}"
        hr

        $global:error
            | Select -first 5
            | Join-string -Property FullyQualifiedErrorId -sep "`n" -f "    {0}"
    }

    clean
    {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }
    <#
    HelpString
    #>

}

function Dotils.Template.ProxyCommand {
    <#
    .synopsis
        Quicky call [ProxyCommand] with specific blocks
    .EXAMPLE
        Dot.ProxyCmd ( gcm Start-process ) Create
        Dot.ProxyCmd ( Get-Help 'Start-Process' ) GetHelp

        Dot.ProxyCmd ( gcm Get-ChildItem ) GetDynamicParam
            | bat -l ps1 # colorize
    .LINK
        https://devblogs.microsoft.com/scripting/proxy-functions-spice-up-your-powershell-core-cmdlets/
    #>
    [Alias('Dot.ProxyCmd')]
    [CmdletBinding()]
    param(
        # Expected kind [CommandMetaData]
        [Parameter(Mandatory)]
        [ArgumentCompletions('(gcm join-string)')]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [Alias('Kind', 'Type', 'Name', 'Block', 'Template')]
        [ValidateSet(
            'Create',
            # 'Create.WithComment',
            # 'Create.WithDynamicParam',
            'EndBlock',
            'BeginBlock',
            'ParamBlock',
            'GetCmdletBindingAttribute',
            'GetParamBlock',
            'GetBegin',
            'GetProcess',
            'GetDynamicParam', 'DynamicParam',
            'GetEnd',
            'GetClean', 'CleanBlock',
            'GetHelpComments', 'Get-Help', 'Help'
        )]
        [string]$ProxyKind
    )
    $Config = @{
        GenerateDynamicParameters = $true
    }
    switch($ProxyKind) {
            'Create'   {
                # [ProxyCommand]::Create
                [ProxyCommand]::Create(
                    $InputObject, 'HelpString', $Config.GenerateDynamicParameters )
                break
            }
            { $_ -in @('BeginBlock', 'GetBegin') } {
                [ProxyCommand]::GetBegin( $InputObject )
                break
            }
             { $_ -in @('EndBlock', 'GetEnd') } {
                [ProxyCommand]::GetEnd(  $InputObject )
                break
            }
            { $_ -in @('CleanBlock', 'GetClean') } {
                [ProxyCommand]::GetClean( $InputObject )
                break
            }
            'GetCmdletBindingAttribute'   {
                [ProxyCommand]::GetCmdletBindingAttribute( $InputObject )
                break
            }
            { $_ -in @('GetParamBlock', 'ParamBlock' ) }   {
                [ProxyCommand]::GetParamBlock( $InputObject )
                break
            }
            'GetProcess'   {
                [ProxyCommand]::GetProcess( $InputObject )
                break
            }
            { $_ -in @('GetDynamicParam', 'DynamicParam' ) }   {
                [ProxyCommand]::GetDynamicParam( $InputObject )
                break
            }
            { $_ -in @('GetHelpComments', 'HelpComments', 'Help' ) }   {
                [ProxyCommand]::GetHelpComments( $InputObject )
                break
            }
        default {
            write-warning "UnexpectedProxyKind: $ProxyKind"
            return
        }
    }
    # [System.Management.Automation.ProxyCommand]::GetParamBlock((gcm Get-Item)) and then trim from there
}


function Dotils.Invoke-TipOfTheDay  {
    <#
    .SYNOPSIS
        grab a random example command from the docs of a random command, or maybe from json files, or, KnowMoreTangent. there even is an official PwshRandomPatchNotes command
    .DESCRIPTION
        grab a random example command from the docs of a random command, or maybe from json files, or, KnowMoreTangent. there even is an official PwshRandomPatchNotes command
    #>
    [CmdletBinding()]
    param(
        # sources
        [Parameter()]
        [string[]]$ModuleName
    )

    $ModuleName ??=
        'Pansies', 'ImportExcel', 'Dotils', 'ExcelAnt', 'Ugit', 'Ninmonkey.Console', 'PsReadLine', 'TypeWriter', 'ClassExplorer' | Sort-Object -Unique

    $ModuleName
        | Join-String -op 'ModuleSources: ' -sep ', ' -SingleQuote | write-verbose

    # '<Insert Tip from Get-Help Examples>'
    # Get-Command  mkdir
    #         | Select-Object *

    # Get-Command  mkdir
    #         | Select-Object *

    function _randomCommand {

    }

    $innerLimit = 0
    while( $true ) {
        if( ($innerLimit++) -gt 15) {
            throw "Did not find a valid example in $InnerLimit Iterations!"
        }
        "Iter = $innerLimit, continue until a non blank example is found" | write-verbose
        $getModuleSplat = @{
            Name = $ModuleName
        }

        function _rand.Module {
            param()
            Get-Module @getModuleSplat
                | Get-Random -count 1
        }
        function _rand.Command {
            param(
                [string]$whichModule
            )
            $cmds =
                Get-Command -Module $whichModule
                    | Sort-Object -unique

            $cmds
                | Get-Random -Count 1
        }
        function _rand.Example {
            param()

            [object[]]$examples =
                (gcm $whichCmd | Get-Help -Examples).examples.example
            $whichExample =
                gcm $whichCmd
                | Get-Help -Examples
                | % Examples
                | Get-Random -Count 1
        }

        $whichModule =
            _rand.Module

        $whichCmd =
           _rand.Command

        $whichModule
            | Join-String -op 'RandomModule: ' | write-verbose

        $whichCmd
            | Join-String -op 'WhichCmd: ' | write-verbose



# $q.examples.example



        if($whichExample) {
            $whichExample
            break
        }
    }

    if(-not $whichExample -or $whichExample.Count -eq 0){
        $errMsg = "ShouldNeverReachException: Failed on: Gcm $whichCmd | Get-Help -Example; Args = $WhichModule, $WhichCmd."
        throw $ErrMsg # [Exception]::new($errMsg)
    }

    # gcm -m ImportExcel

}

function Dotils.QuickPaths {
    <#
    .synopsis
        complete saved path names. future: show tooltips with FullName
    #>
    [Alias('quickPath', 'goPath')]
    [CmdletBinding()]
    param(
        # hardcoded, to impl, and tooltips
        [ArgumentCompletions(
            '2024', '2024-git', 'AppData', 'Bintils.Rebuild', 'GitLogger.AzureFunc', 'GitLogger.Docs', 'GitLogger.ReWrite', 'UserProfile', 'VsCode.User/globalStorage',
            '2023'
        )]
        [Parameter()]
        [string]$Name
    )
    $script:SavedPaths = [ordered]@{
        '2024'              = gi 'H:\data\2024\'
        '2023'              = gi 'H:\data\2023\'
        'GitLogger.AzureFunc' = gi 'H:\data\2023\pwsh\PsModules.dev\GitLogger\Azure\Function'
        'GitLogger.Docs' = gi 'H:\data\2023\my_git\GitLoggerDocs'
        'GitLogger.ReWrite'   = gi 'H:\data\2024\web\GitLoggerTypescriptReWrite-2024-03'
        '2024-git'            = gi 'G:\2024-git'
        'AppData'             = gi $Env:AppData
        'UserProfile'         = gi $Env:UserProfile
        'Bintils.Rebuild' = gi 'H:\data\2023\pwsh\PsModules\Bintils\references\rebuild-references.ps1'
        'VsCode.User/globalStorage' = gi $env:APPDATA\Code\User\globalStorage
    }
    if( $SavedPaths.Contains($Name)) { return $SavedPaths[ $Name ] }
    if(-not $Name) {
        $SavedPaths.Keys | sort-object | join.ul
    }
}

function Dotils.VsCode.ShellIntegration.Get-Info {
    <#
    .synopsis
        A command to remember where things are for shell integration VSCode settings
    #>
    param(
        [ArgumentCompletions('pwsh', 'bash', 'zsh')]
        [string]$ShellName = 'pwsh'

    )
    $FoundScript = code @('--locate-shell-integration-path', $ShellName) | Get-Item
    $FoundScript | Join-String -f 'found ShellIntegration init Script: "{0}"' | Write-Information -infa 'Continue'
    [ordered]@{
        'HelpUrl' = 'see: https://code.visualstudio.com/docs/terminal/shell-integration'
        'EnvVars' = @{
            TERM_PROGRAM = $env:TERM_PROGRAM
            VSCODE_SUGGEST = $env:VSCODE_SUGGEST
            'Global:__VSCodeHaltCompletions' = $Global:__VSCodeHaltCompletions
        }
        'ShellIntegrationScript' = $FoundScript
    }

    'try: code --locate-shell-integration-path $ShellName' | write-host -fore blue

}
function  Dotils.VsCode.PipePassthru {
    <#
    .SYNOPSIS
        Pipe STDIN to vscode, quit to pipe the editor to STDOUT
    .description
        You do *not* have to hit save. just edit and ctrl+w
    .example
        # default is stdout
        Get-Clipboard | Dotils.VsCode.PipePassthru
    .example
        # you can set an extension for optional syntax highlighting
        gci . | % Name
            | Code.Pipe Ps1
    .example
        # Set clipboard and optionally echo it as well
        ... | Code.Pipe Ps1
        ... | Code.Pipe ClipBoard
        ... | Code.Pipe PipeAndStdout

        # instead save results to the variable $OutVarVsCode
        ... | Code.Pipe OutVar

    #>
    [Alias('Dotils.Code.Pipe', 'Code.Pipe')]
    param(
        # Optionally choose a file extension for colors
        [ArgumentCompletions('Ps1', 'md', 'js', 'ts', 'json', 'csv', 'ini', 'yml', 'cs', 'xml', 'html', 'css')]
        [string]$Language,

        [ValidateSet('Stdout', 'Clipboard', 'CopyAndPipe', 'OutVar')]
        $OutputMode = 'Stdout'
    )
    $randFile = New-TemporaryFile #
    if( $Language ) {
        $RandFile = ($RandFile.FullName -replace '\.tmp$', ".${Language}")
    }
    $Stdin = @( $Input ) # forgive me for my sin
    $Stdin | Set-Content -Path $randFile
    $RandFile = Get-Item -ea 'stop' $RandFile

    & code @(
        '--wait'
        '--goto'
        $randFile )

    switch($OutputMode) {
        'CopyAndPipe' {
            Get-Content -LiteralPath $RandFile | Set-Clipboard -PassThru
        }
        'Clipboard' {
            Get-Content -LiteralPath $RandFile | Set-Clipboard -Passthru:$False
        }
        'OutVar' {
            $global:OutVarVsCode = Get-Content -LiteralPath $RandFile
            'wrote: $OutVarVsCode'
                | Dotils.Write-DimText | Infa
        }
        default {
            Get-Content -LiteralPath $RandFile
        }
    }
    $randFile | Join-String -f 'wrote: "{0}"'
        # | write-verbose -verbose
        | Dotils.Write-DimText | Infa
}

function Dotils.Encoding.FindEncoding {
    <#
    .SYNOPSIS
        searches the Name's and DisplayName's metadata
    .EXAMPLE
        Dotils.Encoding.FindEncoding cyrillic, windows
        Dotils.Encoding.FindEncoding -Name ^\D+$
        Dotils.Encoding.FindEncoding -DisplayName '\(.*(utf|iso)'

    #>
    [OutputType( [Text.EncodingInfo] )]
    param(
       # searches both -DisplayName and -Pattern
       [ArgumentCompletions( 'Windows', 'cyrillic' )]
       [string[]]$Pattern,
       # only compare these patterns against [EncodingInfo].Name
       [string[]]$Name,
       # only compare these patterns against [EncodingInfo].DisplayName
       [ArgumentCompletions("'\(.*(utf|iso)'")]
       [string[]]$DisplayName
    )
    $HasParam_Name = $PSBoundParameters.ContainsKey('Name')
    $HasParam_DisplayName = $PSBoundParameters.ContainsKey('DisplayName')
    $HasParam_Pattern = $PSBoundParameters.ContainsKey('Pattern')

    if( -not $HasParam_Name        -and
        -not $HasParam_DisplayName -and
        -not $HasParamPattern ) {
        return [Text.Encoding]::GetEncodings()
    }

    [Text.Encoding]::GetEncodings() | Where-Object {
        [Text.EncodingInfo]$current = $_
        $matches_tests = @(
            if( $HasParam_Pattern ) {
                $Pattern.ForEach({ $current.Name -match $_ })
                $Pattern.ForEach({ $current.DisplayName -match $_ })
            }
            if( $HasParam_Name ) {
                $Name.ForEach({ $current.Name -match $_ })
            }
            if( $HasParam_DisplayName ) {
                $DisplayName.ForEach({ $current.DisplayName -match $_ })
            }
        )
        return ($matches_tests.where({ [bool]$_ }).count -gt 0)
    }
}

filter Dotils.Format.Quick.RenderHashtable {
    [Alias('.Show.Dict')]
    param()
    hr
    $_.GetEnumerator().ForEach({@(
    $_.Name
            $_.Value | Fp
        ) | Join-String -f '{0,15} ' })
    hr

}
filter Dotils.Format.Quick.RenderColorPath {
    # returns string, with ansi escapes. colorizes like fd
    [Alias( 'Fmt-Path.Color', '.Show.Path')]
    param()
    $path   = $_ | Get-Item

    $Colors = @{
        Blue   = '#5ac6ec'
        Yellow = '#d7d75f'
    }

    if( $Path.PSIsContainer ) {
        return $Path.FullName | Join-String -f '{0}\'
            | New-Text -fg $Colors.Blue | Join-String
    }
    @(
        $Path.Directory | Join-String -f '{0}\'
            | New-Text -fg $Colors.Blue

        $Path.Name | New-text -fg $Colors.Yellow
    ) | Join-String -sep ''
}

function Dotils.SelectBy-Module {
    <#
    .SYNOPSIS
        Filters (command|modules) by inclusion or exclusion lists

    .EXAMPLE
        Pwsh> Get-Command  mkdir
            | Select-Object *
            | Select-ByModule
            | fl * -Force
    .DESCRIPTION
        'Dotils.Select-ByModule' => { 'Select-ByModule' }
        propertes are removed using Select-Object -Exclude so their type changes.

        or rather it's PSTypeName changes from:
            [Diagnostics.Process] , to
            [Selected.Diagnostics.Process]
    .NOTES
        future:
            - [ ] get the [command.Source] or [PSModuleInfo.Name]
        new excludes
            - [ ] ExcludeLongProperties (or truncate them visually. maybe dynamic view)

    #>
    [Alias(
        # Dotils.Select-ByModule
        # 'Dotils.Filter-ByModule',
        # 'SelectBy-ByModule',
        'Dotils.FilterBy-Module',
        'SelectBy-Module'
    )]
    [CmdletBinding()]
    [OutputType(
        'System.Object'
    )]
    param(
        # Module, commands, or script blocks
        [ValidateNotNullOrEmpty()]
        [Alias('Obj')][Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # optional filter for [CommandTypes] enum that GCM uses
        [ValidateNotNullOrEmpty()]
        [Alias('TypeIs')][Parameter()]
        [Management.Automation.CommandTypes[]]$CommandType,

        # optional filter for [CommandTypes] enum that GCM uses
        [ValidateNotNullOrEmpty()]
        [Alias('GroupName')][Parameter()]
        [ValidateSet('Mine', 'Debug', 'Fav', 'BuiltIn')]
        [string[]]$GroupKind,

        # names to keep, inverse of exclusions
        # [ArgumentCompletions()] # todo: nin [ArgumentCompletion__ModuleNames]
        # AutoCompleter on fuzzy loader uses write progress ?
        # [ArgumentCompletions()] # todo: nin [ArgumentCompletion__CommandNames]
        [ArgumentCompletions( # 2023-11-16 next: write customa rg completer attribute for finding module names
            'AngleParse',
            'AppBackgroundTask',
            'Appx',
            'AssignedAccess',
            # 'AWS.Tools.ApplicationInsights', # 'AWS.Tools.AutoScaling', # 'AWS.Tools.ChimeSDKIdentity', # 'AWS.Tools.CloudFormation', # 'AWS.Tools.CloudWatch', # 'AWS.Tools.CloudWatchLogs', # 'AWS.Tools.CodeDeploy', # 'AWS.Tools.Common', # 'AWS.Tools.ConnectParticipant', # 'AWS.Tools.DynamoDBv2', # 'AWS.Tools.EC2', # 'AWS.Tools.ECR', # 'AWS.Tools.ECS', # 'AWS.Tools.ElasticLoadBalancing', # 'AWS.Tools.ElasticLoadBalancingV2', # 'AWS.Tools.IdentityManagement', # 'AWS.Tools.IdentityStore', # 'AWS.Tools.Installer', # 'AWS.Tools.KeyManagementService', # 'AWS.Tools.Lambda', # 'AWS.Tools.Organizations', # 'AWS.Tools.Polly', # 'AWS.Tools.RDS', # 'AWS.Tools.ResourceGroups', # 'AWS.Tools.Route53', # 'AWS.Tools.S3', # 'AWS.Tools.SecretsManager', # 'AWS.Tools.SecurityToken', # 'AWS.Tools.SimpleEmail', # 'AWS.Tools.SimpleEmailV2', # 'AWS.Tools.SimpleNotificationService', # 'AWS.Tools.SimpleSystemsManagement', # 'AWS.Tools.SQS', # 'AWS.Tools.SSOAdmin', # 'AWSLambdaPSCore',
            'Az',
            'Az.*',
            'BasicModuleTemplate',
            'bdg_lib',
            'Benchpress',
            'BitLocker',
            'BitsTransfer',
            'BranchCache',
            'BuildHelpers',
            'BurntToast',
            'CimCmdlets',
            'ClassExplorer',
            'CommunityAnalyzerRules',
            'CompletionPredictor',
            'ConfigDefenderPerformance',
            'Configuration',
            'DataMashup',
            'Defender',
            'DeliveryOptimization',
            'Dev.Nin',
            'DirectAccessClientComponents',
            'Dism',
            'DnsClient',
            'Dotils',
            'DSCResourceModule',
            'EditorServicesCommandSuite',
            'Eventful',
            'EventTracingManagement',
            'examplemodule',
            'ExcelAnt',
            'EZOut',
            'EzTheme',
            'GitLogger',
            'GitLogger.ChartJs.Utils',
            'GitLoggerAwsUtils',
            'HelpOut',
            'HgsClient',
            'HgsDiagnostics',
            'Hyper-V',
            'ImpliedReflection',
            'ImportExcel',
            'Indented.ChocoPackage',
            'Indented.ScriptAnalyzerRules',
            'Indented.StubCommand',
            'IntelNetCmdlets',
            'International',
            'InvokeBuild',
            'Irregular',
            'Jake.Pwsh.AwsCli',
            'Jaykul👨Grouping',

            # 'Kds',
            # 'LanguagePackManagement',
            # 'LAPS',
            'Metadata',
            'Microsoft.PowerShell.Archive', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.Crescendo', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.LocalAccounts', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.TextUtility', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.WhatsNew', 'Microsoft.WSMan.Management',
            'mintils',
            'MMAgent',
            'ModuleBuild',
            'ModuleBuilder',
            'ModuleFast',
            'NameIT',
            'Nancy',
            'NetAdapter',
            'NetConnection',
            'NetEventPacketCapture',
            'NetLbfo',
            'NetNat',
            'NetQos',
            'NetSecurity',
            'NetSwitchTeam',
            'NetTCPIP',
            'NetworkConnectivityStatus',
            'NetworkSwitchManager',
            'NetworkTransition',
            'Ninmonkey.Console',
            'Ninmonkey.Factorio',
            'PackageManagement',
            'Pansies',
            'PcsvDevice',
            'Pester',
            'PipeScript',
            'Pipeworks',
            'PKI',
            'platyPS',
            'PnpDevice',
            'Portal.Powershell',
            'posh-git',
            'Posh-SSH',
            'powershell-yaml',
            'Powershell.Cv',
            'Powershell.Jake',
            'PowerShellAI',
            'PowerShellGet',
            'PowerShellHumanizer',
            'PowerShellNotebook',
            'PowerShellPivot',
            'PrintManagement',
            'ProcessMitigations',
            'Profiler',
            'Provisioning',
            'PSAdvantage',
            'PSCompatibilityCollector',
            'PSDevOps',
            'PSDiagnostics',
            'PSEventViewer',
            'PSMetrics',
            'PSparklines',
            'PSParseHTML',
            'PSProfiler',
            'PSReadLine',
            'PSScriptAnalyzer',
            'PSScriptTools',
            'PSStringTemplate',
            'PSTree',
            'PSWriteColor',
            'PSWriteExcel',
            'PSWriteHTML',
            'PSWriteline',
            'PSWriteOffice',
            'PSWriteWord',
            'Pwsh.PackageTemplate',
            'Revoke-Obfuscation',
            'samplerule',
            'SampleRuleWithVersion',
            'ScheduledTasks',
            'ScriptBlockDisassembler',
            'ScriptCop',
            'SecretManagement.LastPass',
            'SecureBoot',
            'ShowPSAst',
            'ShowUI',
            'SmbShare',
            'SmbWitness',
            'Splatter',
            'SQLPS',
            'SqlServer',
            'StartLayout',
            'Storage',
            'SysInternals',
            'Template.Autocomplete',
            'Terminal-Icons',
            'TerminalBlocks',
            'TestBadModule',
            'TestGoodModule',
            'Theme.PowerShell',
            'Theme.PSReadLine',
            'Theme.PSStyle',
            'ThreadJob',
            'TLS',
            'TroubleshootingPack',
            'TrustedPlatformModule',
            'UEV',
            'ugit',
            'VpnClient',
            'Wdac',
            'Whea',
            'WindowsDeveloperLicense',
            'WindowsErrorReporting',
            'WindowsSearch',
            'WindowsUpdate',
            'WindowsUpdateProvider'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('ModuleName')][Parameter()]
        [string[]]$IncludeName,

        # regex patterns to exclude
        [ValidateNotNullOrEmpty()]
        [ArgumentCompletions(
            '^Az\.'
        )]
        [Alias('ModulePattern')][Parameter()]
        [string[]]$ExcludePattern
    )
    begin {
        Write-Warning @'
left off: filter funcs or commands or aliases or moduleinfo, based on the source


to ask: how to compare vs 0 to many enum values
    this broke

    #impo Dotils -Force
        gcm -Name  'gci'  -CommandType Function
        | countOf
        | SelectBy-Module -CommandType Function, All
        | CountOf
'@

    }
    process {
        if($GroupKind) { throw 'middle of wip' }

@'

GroupKindCompleter filters Get-Module, checking for any shared root directories
        H:\data\2023\pwsh
        H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils
        # C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Modules\ugit\0.4
        C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell
        C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\mintils
'@ | Out-null


        if ($IncludeName) { throw 'in middle of wip' }
        if ($ExcludePattern) { throw 'in middle of wip' }

        $item = $InputObject
        $InputObject
        | ? { # filter: Keep unless filters are specified
            $curItem = $_
            $shouldKeep = $true
            [Management.Automation.CommandTypes]$commandType? = $curItem.CommandType

            if (-not $PSBoundParameters.ContainsKey('CommandType')) { return $true }
            if (-not $CommandType?) { return $true }

            foreach ($incName in @($IncludeName)) {
                if ($incName -eq $commandType?) { $shouldKeep = $true ; break; }
            }

            return $false
        }
        # $Props = $InputObject.PSObject.Properties
        # [Collections.Generic.List[object]]$exclusionList = @()

        # $Props | ForEach-Object {
        #     if( [string]::IsNullOrWhiteSpace( $_.Value ) ) {
        #         $exclusionList.Add( $_.Name )
        #     }
        # }

        # $exclusionList
        #     | Join-string -sep ', ' -SingleQuote -op '$exclusionList: '
        #     | write-verbose

        # return $InputObject | Select-Object -excludeProperty $exclusionList
    }
}

function Dotils.Find-MyWorkspace {
    <#
    .SYNOPSIS
        quick search of my recent files by category, similar to
            ext:code-workspace dm:last2weeks
    .NOTES
        super not performant, but more than fast enough
    .EXAMPLE
        Find-MyWorkspace
    .EXAMPLE
        Find-MyWorkspace -ChangedWithin 1year
    #>
    [Alias(
        'Find-MyWorkspace'
    )]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            '20minutes', '8hours', '1week', '3weeks', '1year')
        ][string]$ChangedWithin = '2weeks',

        [Parameter( #not using a param set temporarily since it'll rewrite sometime
            # Mandatory, ParameterSetName='QueryGroupName')]
        )][ValidateSet('All', 'Fast', 'PwshOnly', '2022')]
        [string]$QueryGroupName,

        [string[]]$BasePath
    )

    $QueryKindList = @{
        All = @(
            'H:\data\2023'
            'H:\data\2022'
            'H:\data\2023\pwsh\PsModules\KnowMoreTangent'
            'H:\data\client_bdg'
            'C:\Users\cppmo_000\SkyDrive\Documents\2022'
        )
        Fast = @(
            'H:\data\2023'
        )
        PwshOnly = @(
            'H:\data\2023\pwsh'
            'H:\data\client_bdg' # for now
            'C:\Users\cppmo_000\SkyDrive\Documents\2022\Pwsh' # for now

        )
        2022 = @(
            'H:\data\2022'
            'C:\Users\cppmo_000\SkyDrive\Documents\2022'
        )
    }

    if($PSBoundParameters.ContainsKey('QueryGroupName') -and $PSBoundParameters.ContainsKey('BasePath')) {
        throw "CannotCombineparameters: QueryGroupName with BasePath"
    }
    $DefaultGroup = 'Fast'

    if($QueryKindList -and $QueryKindList.$QueryGroupName ) {
        $explicitPaths = $QueryKindList.$QueryGroupName
    } else {
        if($BasePath) {
            $explicitPaths = @($BasePath)
        } else {
            $explicitPaths = @($QueryKindList.$DefaultGroup)
        }
    }

    # -not $PSBoundParameters.ContainsKey('QueryGroupName') {

    # if (-not $BasePath.count -gt 0) {
    #         # $BasePath = $QueryKindList[$QueryGroupName]

    #     $ExplicitPaths = @(
    #         $QueryGroupName.$DefaultGroup
    #     )
    # } else {
    #     $ExplicitPaths = $BasePath
    # }
    # if($QueryGroupName) {
    #     $explicitPaths = @( $QueryKindList.$QueryGroupName )
    # }

    # Join-String 'searching {0}' $
    $explicitPaths
        | Join-String -sep ', ' -SingleQuote -op '$ExplicitPaths: '
        | write-information -infa 'Continue'

        [Collections.Generic.List[Object]]$Files = @(
            foreach ($item in $ExplicitPaths) {
                'write-progress: InvokeFd: changed?: {0}, dir?: {1}' -f @(
                    $ChangedWithin
                    $item
                )
                | Write-Information -infa 'Continue'


                & 'fd' @(
                    '--absolute-path',
                    '--extension', 'code-workspace',
                    '--type', 'file'
                    if($ChangedWithin) {
                        '--changed-within', $ChangedWithin
                    }

                    '--base-directory',
                    (gi -ea 'stop' $item)
                )
                | Get-item
            }
        )

        $files = $Files
            | Sort-Object FullName -Unique
            | Sort-Object LastWriteTime -Descending

        $global:MyWorkspaceQuery = $files
        # $global:MyWorkspaceQuery
        '$MyWorkspaceQuery saved' | New-Text -fg gray30 -bg gray50 | Join-String | Write-Information -infa 'continue'
        return $files
            | CountOf -CountLabel "ChangedWithin: $( $ChangedWithin )"

}


function Dotils.InferCommandCategory {
    # process commands, returns group names
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        write-warning '80% wip'
    }
    process {

        # foreach($curCmd in $InputObject) {
        $InputObject | %{

            $curCmd = gcm -ea 'continue' $_
            $baseName = $curCmd.Path | Get-Item | % BaseName

            # could return multiple
            [object[]]$kinds = switch -regex ($CurCmd.Base) {
                '^([i]?py[w]?(thon)?.*)' {
                    'Python'
                }
                '^pwsh|powershell' { 'PowerShell', 'cli' }
                '^tsc?$' { 'TypeScript', 'Javascript', 'BuildTool', 'cli' }
                '^code(-insiders)?' { 'VsCode' }
                '^sql(.*)cmd'  { 'SQL', 'BuildTool'}
                {
                    $CurCmd.Path -match ('^' + [regex]::Escape('C:\Windows\system32'))
                } { 'Windows' }
                default {
                    $_  | Join-String -f 'Dotils.Find-MyNativeCommandKind: UnhandledKind: {0}'
                        | Write-error
                        return 'None'
                }
            }
            $kinds.count
                | Join-String -f 'Kinds: {0}'
                | Join-String -f "${fg:green}{0}${fg:clear}" -op $PSStyle.Reset
                | Join-String -os $($Kinds -join ', ' )
                | write-information -infa 'continue'

            $kinds.count
                | Join-String -op 'Kinds: {0}'
                | Join-String -f "{0} = $($kinds -join ', ' )"
                | Write-Verbose

            $kinds -join ', '
                | write-information

            $kinds.count
                | Join-String -op 'Kinds: {0}'
                | Join-String -f "{0} = $($kinds -join ', ' )"
                | Write-Verbose

            $kinds -join ', '
                | Write-verbose

            return ,$kinds
        }
    }
}

function Dotils.Find-MyNativeCommandCategory {
    # generates metadata on command, including GroupKind categories
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {

    }
    process {
        $addMemberSplat = @{
            PassThru    = $true
            Force       = $true
            ErrorAction = 'ignore'

        }

        foreach ($Item in $InputObject) {
            $Item | Add-Member -PassThru -Force -ea 'ignore' -NotePropertyMembers @{
                PSShortType = $Item | Format-ShortTypeName
                Group     = $Item | Dotils.InferCommandCategory
            }

        }
    }

}

function Dotils.Find-MyNativeCommand {
    write-warning
    @'
FrontEnd for finding executables by categories

reuse pattern from:
    Find-MyWorkspace
'@
    $binList = Get-Command -CommandType Application -ea 'continue'
    throw 'this will either be gcm but nicer, or it will also filter to the important modules'


}
function Dotils.Get-NativeCommand {
    <#
    .SYNOPSIS
        Returns only Applications, or executables, excluding all commands and aliases
    #>
    # [Alias('')]
    # to rewrite
    param(
        [Alias('Path', 'LiteralPath')]
        # future: customAttributes: Find-MyNativeCommand
        [ArgumentCompletions(
            '7z', '7za', '7zfm', '7zg', 'cargo-clippy', 'com.docker.cli', 'dmypy', 'dnSpy-x86', 'dnSpy', 'docker-compose-v1', 'docker-compose', 'docker-credential-desktop', 'docker-credential-ecr-login', 'docker-credential-wincred', 'docker-index', 'docker', 'dotnet-counters', 'dotnet-coverage', 'dotnet-dump', 'dotnet-gcdump', 'dotnet-ildasm', 'dotnet-lambda', 'dotnet-monitor', 'dotnet-repl', 'dotnet-stack', 'dotnet-suggest', 'dotnet-symbol', 'dotnet-trace', 'dotnet-try', 'dotnet', 'fd', 'Fiddler', 'http-server', 'http', 'httpie', 'https', 'ILSpy', 'ipython', 'ipython3', 'jupyter-run', 'jupyter', 'mpyq', 'mypy', 'powershell', 'putty', 'puttygen', 'pwsh', 'py', 'pygmentize', 'python3', 'pyw', 'Robocopy', 'Winobj', 'wt', 'xcopy'
        )]
        [Parameter(Mandatory)][string]$Name
    )
    $found = Get-Command -ea 'stop' -CommandType Application $Name | Select-Object -First 1
    if (-not $Found) { throw "Did not match command: $Name" }
    return $Found
}

function Dotils.Render.ColorName {
    <#
    .SYNOPSIS
        emits items one at a time, so you don't have to otherwise split them after, like a join-string
    .example
        '232311', 'blue', 'darkred'
            | Dotils.Render.ColorName -Foreground -Text '_'
            | Join-String

        # out: ---
        # which is:

        ␛[38;2;35;35;17m_␛[39m␛[38;2;0;0;255m_␛[39m␛[38;2;128;0;0m_␛[39m

    .example
        PS> fmt.Render.ColorName -Text 'darkyellow' -bg | fcc

            ␛[38;2;128;128;0mdarkyellow␛[39m
    .example

        PS> 'red', '#fefe9e' | fmt.Render.ColorName -fg | Join.UL
            - red
            - #fefe9e
    .example
        PS> 'red', '#fefe9e' | fmt.Render.ColorName -fg | Join-String | fcc

            ␛[48;2;255;0;0mred␛[49m␛[48;2;254;254;158m#fefe9e␛[49m
    .example
        PS> Get-Gradient -StartColor 'gray10' -end 'gray50' -Width 10
            | Dotils.Render.ColorName -bg '.'
            | Join-String

        PS> Get-Gradient -StartColor 'gray10' -end 'gray50' -Width 10
            | Dotils.Render.ColorName -bg '.'
            | Join.UL
    #>
    [OutputType('System.String', 'PoshCode.Pansies.Text')]
    [CmdletBinding()]
    # [NinDependsInfo( # this does not yet exist
    #     Modules='Pansies', Powershell='7.0.0', NativeCommands=$false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('InputObject', 'Name')][object]$ColorName,

        # text to render, if not color name
        [Alias('Content')]
        [Parameter(Position=0)]
        [Alias('Object')][string]$Text,


        [Alias('Bg')][switch]$Background,
        [Alias('Fg')][switch]$Foreground,

        # Instead, return the raw [PoshCode.Pansies.Text]
        [switch]$PassThru
    )
    begin {
        if(-not $PSCmdlet.MyInvocation.ExpectingInput) {
            $target = $ColorName
        }
    }
    process {
        if($PSCmdlet.MyInvocation.ExpectingInput) {
            $target = $ColorName
        }
        if(-not $Foreground -and  -not $Background) {
            throw 'Missing BG, FG, must be one or the other' }
        $splat = @{}
        if($Background) { $splat.bg = $ColorName }
        if($Foreground) { $splat.fg = $ColorName }
        if($ColorName) { $splat.Object = $ColorName }
        if($PSBoundParameters.ContainsKey('Text')) {
            $splat.Object = $Text
        }

        if($PassThru){
            return Pansies\New-Text @splat
        }
        return (Pansies\New-Text @splat).ToString()

    }
    end {
    }
}
function Dotils.Format.Color {
    <#
    .SYNOPSIS
        format without forcing joining strings, just emit the values one at a time
    .EXAMPLE
        '#fefff1', 'red' | Fmt.Color ByProp X11ColorName | Join-String

        # out: IvoryRed
        # ansi:[48;2;254;255;241mIvory[49m[48;2;255;0;0mRed[49m
    #>
    param(
        [AllowEmptyString()]
        [Alias('Text', 'InputObject')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputText,

        # exactly how to render the color?
        [Parameter(position=0)]
        [ValidateSet(
            'Implicit',
            'ByProp')]
        [string]$FormatMode,

        [Parameter(position=1)]
        [ValidateSet(
            'RGB', 'BGR', 'ConsoleColor',
            'XTerm256Index', 'X11ColorName',
            'Mode',
            'R', 'G', 'B'
            # 'Ordinals'
        )]
        [string]$PropName
    )
    begin {
        $str = @{
            PansiesResetAll = "${fg:clear}${bg:clear}"
            PSStyleReset = $PSStyle.Reset
        }
        throw 'nyi; or requires confirmation; mark;'
    }
    process {
        if( [string]::IsNullOrWhiteSpace($InputText)) {
            return [string]::Empty
        }



        $jStr_splat = @{
            Separator = ''
            # Object = $InputText
        }
        switch($FormatMode) {
            'Implicit' {
                $InputText | Dotils.Render.ColorName -bg
            }
            'ByProp' {
                # [PoshCode.Pansies.Text]
                $textObj = $InputText | Dotils.Render.ColorName -bg -PassThru
                # $textObj.BackgroundColor is [PoshCode.Pansies.RgbColor]
                $value? = ($textObj.BackgroundColor)?.$PropName ?? '-'
                $InputText | Dotils.Render.ColorName -bg -Text $Value?
            }
            default {
                throw "UnhandledFormatMode: $FormatMode"
            }
        }
        # $InputText | Join-String

    }
}
# function Dotils.Is.Type {
function Dotils.Debug.GetTypeInfo { # 'Dotils.Debug.GetTypeInfo' = { '.IsType', 'Dotils.Is.Type', 'Is.Type', 'IsType'  }
    <#
    .SYNOPSIS
        Quick Summary of types of an object. terribly written, testing breaking rules with  code that is still valid (ie: correct)
    .DESCRIPTION
        I give you many possible formatters, some use raw text parsing
        some return actual [type] info objects

    - future:
        - [ ] if a type does not resolve using 'as type', then attempt
            a 'find-type -fullName *name*' query to resolve it
    #>
    [Alias(
        # 'Dotils.Is.Type', 'Is.Type', '.IsType', 'IsType'
        'Dotils.Describe.Type'
    )]
    param(
        [ValidateSet(
            'Type',
            'ElemType',
            'FullName',
            'Name',
            'PSTypesRaw',
            'PSTypes',
            'PSTypesInfo',
            'PSTypesString',
            'PassThru'
            )]
        [Parameter(Position=0)][string]$Style = 'PassThru',

        [Parameter(ValueFromPipeline)][object]$InputObject,

        [switch]$PassThru
    )
    write-warning 'finish writing dotils.GetTypeInfo, including formatter that auto renders string else type info instance'
    $t = $InputObject
    if( $t -is 'type' ) {
        $tInfo = $t.GetType()
    } else {
        $tInfo = $t
    }
    write-warning 'nyi; or requires confirmation; mark;'
    $info = [pscustomobject]@{
        PSTypeName = 'Dotils.Debug.GetTypeInfo'

        Type =
            $t.
                GetType() ??
                '<missing>'

        ElemType =
            @( $t )[0].
                GetType() ??
                '<missing>'

        FullName =
            $t.
                GetType().FullName ??
                '<missing>'
        Name =
            $t.
                GetType().Name ??
                '<missing>'
        PSTypesRaw =
            $tInfo.
                PSTypeNames ??
                '<missing>'
        PSTypes = # alias to TypesInfo
            $tinfo.PSTypeNames ?? '' | %{  $_ -as 'type' }

        PSTypesInfo =
            $tinfo.PSTypeNames ?? '' | %{  $_ -as 'type' }

        PSTypesString =
            $tinfo.
                PSTypeNames
                    | Sort-Object -Unique
                    | %{ $_ -replace '\System\.', '' }
                    | Ninmonkey.Console\Format-WrapText -Style Bracket
    }
    if($PassThru -or $Style -eq 'PassThru') {
        return $info
    }

    return $info.$Style
}


function Dotils.Text.NormalizeLineEnding {
    <#
    .SYNOPSIS
        Normalize line ending without splitting and joining
    #>
    [alias('.Text.NormalizeNL')]
    param(
        [string[]]$InputObject
    )
    process {
        foreach($line in $InputObject) {
            $line -replace '\r?\n', "`n"
        }
    }
}

function Dotils.VsCode.ConvertTo.Snippet {

    [Alias('.VsCode.ConvertTo.Snippet')]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [Alias('Lines', 'Text')]
        [Parameter(
            # Mandatory,
            ValueFromPipeline, Position=0)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$Lines = @()
        write-warning 'nyi; or requires confirmation; mark;'
    }
    process {
        $lines.AddRange(@( $InputObject ))
    }
    end {
        if( -not $MyInvocation.ExpectingInput ) {
            $Source = Get-Clipboard
            'default fallback to using ClipBoard' | write-verbose -verbose
        } else {
            $Source = $lines | Join-String -sep "`n"

        }
        $Text =
            $Source | Join-String -sep "`n"
        $text =
            $text -replace '\$', '\\$'
        $test =
            $text -split '\r?\n'
                | Join-string -f "`n`"{0}`","

        $test | Join-String -f "[`n{0}],`n"
            | Join-String -sep "`n"
            | Set-Clipboard -Append

    }

}



function Dotils.Debug.Find.AstType {
    <#
    .EXAMPLE
    Pwsh> Dotils.Debug.Find.AstType -Condition Variable, Argument
        | ? IsVariable

        Name         : VariableExpressionAst
        IsExpression : True
        IsLiteral    : False
        IsArgument   : False
        IsVariable   : True
    .EXAMPLE

    Pwsh> ( $res = Mark.Find.Ast  -Condition Argument, Array ) | ft -AutoSize

        Name                              IsExpression IsLiteral IsArgument IsArray
        ----                              ------------ --------- ---------- -------
        ArrayExpressionAst                        True     False      False    True
        ArrayLiteralAst                          False      True      False    True
        AssignmentStatementAst                   False     False      False   False
        AttributeAst                             False     False      False   False
        AttributeBaseAst                         False     False      False   False
        AttributedExpressionAst                   True     False      False   False
        BaseCtorInvokeMemberExpressionAst         True     False      False   False
        BinaryExpressionAst                       True     False      False   False
        BlockStatementAst                        False     False      False   False
    #>
    param(
        [Parameter(Position=0)]
        [Alias('Is', 'Kind')]
        [ArgumentCompletions(
            # 'Expression','Member','Function','Statement'
            'Argument', 'Array', 'Assignment', 'Ast', 'Attribute', 'Attributed', 'Base', 'Binary', 'Block', 'Break',
            'Catch', 'Chain', 'Chainable', 'Clause', 'Command', 'Configuration', 'Constant', 'Constraint', 'Continue',
            'Convert', 'Ctor', 'Data', 'Definition', 'Do', 'Dynamic', 'Each', 'Element', 'Error', 'Exit', 'Expandable',
            'Expression', 'File', 'For', 'Function', 'Hashtable', 'If', 'Index', 'Invoke', 'Keyword', 'Labeled', 'Literal',
            'Loop', 'Member', 'Merging', 'Named', 'Param', 'Parameter', 'Paren', 'Pipeline', 'Property', 'Redirection',
            'Return', 'Script', 'Statement', 'String', 'Sub', 'Switch', 'Ternary', 'Throw', 'Trap', 'Try', 'Type', 'Unary',
            'Until', 'Using', 'Variable', 'While'
        )]
        [string[]]$Condition
    )
    $enableAllProperties = $true
    if($PSBoundParameters.ContainsKey('Condition')) {
        $enableAllProperties = $false
    }
    $AstKinds = @(
        find-type -Base (find-type -Namespace * -Name Ast) ) | Sort-Object fullname -Unique

    $SegKindsToTest = @(
        'Argument', 'Array', 'Assignment', 'Ast', 'Attribute', 'Attributed', 'Base', 'Binary', 'Block', 'Break',
        'Catch', 'Chain', 'Chainable', 'Clause', 'Command', 'Configuration', 'Constant', 'Constraint', 'Continue',
        'Convert', 'Ctor', 'Data', 'Definition', 'Do', 'Dynamic', 'Each', 'Element', 'Error', 'Exit', 'Expandable',
        'Expression', 'File', 'For', 'Function', 'Hashtable', 'If', 'Index', 'Invoke', 'Keyword', 'Labeled', 'Literal',
        'Loop', 'Member', 'Merging', 'Named', 'Param', 'Parameter', 'Paren', 'Pipeline', 'Property', 'Redirection',
        'Return', 'Script', 'Statement', 'String', 'Sub', 'Switch', 'Ternary', 'Throw', 'Trap', 'Try', 'Type', 'Unary',
        'Until', 'Using', 'Variable', 'While'
    )


    $AstKinds | %{
        $cur =  $_

        $compareResult = [ordered]@{
            PSTypeName = 'Dotils.FindAst.CompareResult'
            Name = $_.name
            IsExpression = $cur.Name -match 'Expression'
            IsLiteral = $cur.Name -match 'Literal'
            # IsArray = $cur.Name -match 'Array'
            # IsBinary = $cur.Name -match 'Binary'

            # IsCommand = $cur.Name -match 'Command'
            # IsParmeter = $cur.Name -match 'Parmeter'
            # IsBinary = $cur.Name -match 'Binary'
            # IsBinary = $cur.Name -match 'Binary'
            # IsBinary = $cur.Name -match 'Binary'
            # IsBinary = $cur.Name -match 'Binary'
        }
        if($enableAllProperties) {
            $SegKindsToTest | sort-object -Unique | %{
                $SegmentName = $_
                $Key = 'Is{0}' -f $SegmentName
                $compareResult.$Key = $cur.Name -match $SegmentName
            }
        } else {
            $Condition | sort-object -Unique | %{
                $SegmentName = $_
                $Key = 'Is{0}' -f $SegmentName
                $compareResult.$Key = $cur.Name -match $SegmentName
            }
        }
        # auto kinds


        [pscustomobject]$CompareResult
    }
}






function Dotils.Datetime.Now {
    [OutputType('System.DateTime')]
    [Alias(
        'Dt.Now',
        'DateTime.Now'
    )]
    param(
        [Alias('Utc')]
        [switch]$AsUtc
    )

    $now = if( $AsUtc ) {
        [Datetime]::Now.ToUniversalTime()
    } else {
        [Datetime]::Now
    }
    return $now
}
function Dotils.DatetimeOffset.Now {
    [Alias(
        'Dto.Now',
        'DateTimeOffset.Now'
    )]
    [OutputType('System.DatetimeOffset')]
    param(
        [Alias('Utc')]
        [switch]$AsUtc
    )

    $now = if( $AsUtc ) {
        [DatetimeOffset]::Now.ToUniversalTime()
    } else {
        [DatetimeOffset]::Now
    }
    return $now
}

# function Dotils.Datetime.NamedFormatStr {
#     [Alias('Date.NamedFormatStr')]
# throw: replace by: 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Completions.NamedDateFormatString.psm1'
#     param(
#         [Parameter(Mandatory, Position=0)]
#         [ArgumentCompletions(
#             'Github.Dto.Utc'
#         )]
#         [Alias('Name')]
#         [string]$DateTemplateName
#     )
#     write-warning 'Generate arg completer using standard names from a set completer'
#     <#
#     .EXAMPLE
#         Pwsh> Dotils.Datetime.NamedFormatStr Github.Dto.Utc

#             yyyy'-'MM'-'dd'T'HH':'mm':'ssZ
#     .NOTES
#     .LINK
#         https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
#     .LINK
#         https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
#     .LINK
#         https://docs.github.com/en/rest/overview/resources-in-the-rest-api?apiVersion=2022-11-28#timezones
#     #>
#     # todo: generate naems from func

#     $named = @{
#         'Github.Dto.Utc' = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
#     }

#     if( $named.ContainsKey($DateTemplateName)) {
#         return $Named[ $DateTemplateName ]
#     }
#     throw "UnknownDateTemplateName: $DateTemplateName"
# }
# function Dotils.Datetime.
function Dotils.DatetimeOffset.Parse.FromGithub {
    <#
    .NOTES
        see:
            - https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
            - [git api datetimezone format](https://docs.github.com/en/rest/overview/resources-in-the-rest-api?apiVersion=2022-11-28#timezones)
    .EXAMPLE
        Pwsh> Dto.Now -AsUtc
            | % tostring "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
            | Dotils.DatetimeOffset.Parse.FromGithub
            | % tostring 'u'

        2023-11-11 23:08:59Z
    .EXAMPLE
        $GitDtoUtcFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"

        Dto.Now -AsUtc
            | % tostring $GitDtoUtcFormat
            | Dotils.DatetimeOffset.Parse.FromGithub -Verbose


    #>
    [CmdletBinding()]
    [OutputType('System.DateTimeOffset')]
    param(
        [ArgumentCompletions('2011-01-26T19:06:43Z')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $DateTimeOffsetString,

        [string]$Culture = 'en-us'

        # [Parameter(Mandatory, ValueFromPipeline)]
        # [string[]]
        # $DateTimeString
    )
    begin {
        $Fstr = @{
            Github_Dto_Utc =
                "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        }
        $FstrDefault = $Fstr.Github_Dto_Utc
        $Cult = Get-Culture $Culture
    }
    process {

    $DateTimeOffsetString
        | %{
            $curString = $_
            'parsing: {0}, using Fstr: {1}' -f @(
                $curString, $FStrDefault
            ) | Write-Verbose

            [DatetimeOffset]::ParseExact(
                $curString, $FStrDefault, $Cult)
        }
    }
    # $dto.ToUniversalTime().ToString( $dsample )
    # [System.DateTimeOffset]::ParseExact( $gitSample, $dsample, (Get-Culture 'en-us' ))
}
function Dotils.Datetime.ShowExamples {
    <#
    .EXAMPLE
        Dotils.Datetime.ShowExamples -FormatStrings ( Try.Fstr yyyy'-'MM'-'dd'T'HH':'mm':'ssZ )

        # verbose: Using FormatStrings: 'yyyy-MM-ddTHH:mm:ssZ'

        Kind           Fstr                 Dt                   Dt_utc
        ----           ----                 --                   ------
        DateTime       yyyy-MM-ddTHH:mm:ssZ 2023-11-11T18:31:10Z 2023-11-12T00:31:10Z
        DateTimeOffset yyyy-MM-ddTHH:mm:ssZ 2023-11-11T18:31:10Z 2023-11-12T00:31:10Z
    #>
    param(
        [ArgumentCompletions(
            'o', 's', 'O', 'S', 'o', 'r', 'R', 'u', 'U',
            "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        )]
        [String[]]$FormatStrings
    )
    $dt = [datetime]::Now
    $dto = [DateTimeOffset]::Now

    if( [string]::IsNullOrWhiteSpace( $FormatStrings ) ) {
        $maybeFormats =
            'o', 's', 'O', 'S', 'o',
            "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
    } else {
        $maybeFormats = $FormatStrings
    }
    $maybeFormats =
        $maybeFormats | Sort-Object -Unique -CaseSensitive

    $maybeFormats
        | Join-String -op 'Using FormatStrings: ' -sep ', ' -single
        | Dotils.Write-DimText
        | Infa
        # | write-verbose -verbose

    $maybeFormats | %{
        $fStr = $_
        $dt? =
            try { $dt.ToString( $fStr ) }
            catch { "`u{2400}" }

        $dt_utc? =
            try { $dt.ToUniversalTime().ToString( $fStr ) }
            catch { "`u{2400}" }

         $dto? =
            try { $dto.ToString( $fStr ) }
            catch { "`u{2400}" }

        $dto_utc? =
            try { $dto.ToUniversalTime().ToString( $fStr ) }
            catch { "`u{2400}" }


        # $dt? ?? "`u{2400}"
        [pscustomobject]@{
            PSTypeName = 'dotils.Datetime.Format.Example'
            Kind   = 'DateTime'
            Fstr   = $fStr
            Dt = $dt?
            Dt_utc = $dt_utc?
        }

        [pscustomobject]@{
            PSTypeName = 'dotils.DatetimeOffset.Format.Example'
            Kind   = 'DateTimeOffset'
            Fstr   = $fStr
            Dt = $dto?
            Dt_utc = $dto_utc?
        }
    }
}

function Dotils.Trace.ParameterBinding {
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [Alias('Test', 'Expression', 'SB', 'E')]
        [scriptBlock] $ScriptBlock,

        [string] $Path = (Join-Path temp: 'ParamBinding.log'),

        [string[]] $Name = '*Name*',

        [ValidateScript({throw 'nyi'})]
        [Alias('PSHost', 'Host', 'Echo')]
        [switch] $PassThru,

        [Alias('ResetLog')]
        [switch] $ClearLog
    )
    $regex = @{}

    $regex.ParamBindLog_SingleLine = @'
(?x)
        ^
        (?<Source>.*?)
        \s
        (?<Severity>\S*)
        :\s
        (?<SomeId>\d+)
        \s:
        (?<RawMessage>
            (?<Indent>\s+)
            (?<Message>.*)
        )
        (?<Rest>.*?)
        $
'@
        $PathRaw = "${Path}.raw"
        $PathJson = "${Path}.json"
        $traceCommandSplat = @{
            Name       = '*Param*'
            FilePath   = $PathRaw
            Expression = $ScriptBlock
        }
        if($ClearLog) {
            Clear-Content -path $Path
            Clear-Content -path $PathRaw
            Clear-Content -path $PathJson
        }

        Trace-Command @traceCommandSplat

        throw 'wip'

        Get-Content -Path $PathRaw -raw
            | StripAnsi | Split.NL
            | %{
                if( $_ -match $Regex.ParamBindLog_SingleLine ) {
                    $matches.remove(0)
                    $found = [pscustomobject]$matches
                }
                $found
            }
            | Select -ea 'ignore' -Exclude @( 'RawMessage') -Property @(
                'Indent', 'Source', 'Severity', 'Message', 'SomeId'
            )
            | Json | Set-Content -path $PathJson

        [string]$lastSource = ''

        Get-Content -Path $PathRaw -raw
        | StripAnsi | Split.NL
        | %{
            if( $_ -match $Regex.ParamBindLog_SingleLine ) {
                $matches.remove(0)
                $found = [pscustomobject]$matches
            }
            $found
        }
        | Join-String -p {
            $_ | Join-String -p {@(
            $_.Source | Join.Predent -Depth 0
            $_.Severity | Join.Predent -Depth 1
            $_.Message  | Join.Predent -Depth 2 ) -join "`n" }
        }
        # } | %{ @(
        #     # was:
        #     if($LastSource -ne $_.Source) {
        #         $LastSource = $_.Source
        #         "`n${LastSource}`n"
        #     }
        #     wait-debugger
        #     $_.Severity, ' ', $_.Message -join ''
        # ) -join '' }
        | Set-Content -path $Path
        # } | Join-String -p {@(
        #     # was:
        #     if($LastSource -ne $_.Source) {
        #         $LastSource = $_.Source
        #         "`n${LastSource}`n"
        #     }
        #     $_.Severity, ' ', $_.Message -join ''
        # ) -join '' } -sep "`n" | Set-Content -path $Path



        $Path, $PathJson, $PathRaw | Get-Item| Join-String -f "`n Wrote: {0}"
            | Dotils.Write-DimText
            | Infa
}


function Dotils.Render.FilePath {
    <#
    .SYNOPSIS
        Render file's full name (if existing), if it exists, and url to edit
    .EXAMPLE
        #   you can pipe paths as text or as objects
        Pwsh> 'test.md', 'fakeFile.md' | Render.FilePath

            Exists?: + <file:///H:\data\2023\pwsh\test.md> edit
            Exists?: x <file:///fakeFile.md> edit
    .EXAMPLE
        #   you can pipe paths as text or as objects
        gci *.md | Render.FilePath

            Exists?: + <file:///H:\data\2023\foo.md>  edit
            Exists?: + <file:///H:\data\2023\bar.ps1> edit
    #>
    # [CmdletBinding()]
    [Alias(
        'Render.FilePath',
        'Fmt.FilePath'
    )]
    param(
        # [int]$LineNumber
    )
    process {
        $PathName = $_
        $exists? = test-path $PathName
        # $file = Get-Item -ea 'ignore' $PathName
        $Config = @{
            IncludeUrl = $True
        }
        $fullName = $Exists? ? (get-item $PathName) : $PathName
        $url = $FullName | Join-String -f 'vscode://file/{0}'
        $ansiUrl = $PSStyle.FormatHyperlink('edit', $url )
            | Join-String -op ' '

        'Exists?: {0} {1}{2}' -f @(
            $Exists?
                | Fmt.Sci -FormatKind FancyBool

            # ( $File ?? $PathName
            $FullName -replace ' ', '%20'
                | Join-String -f '<file:///{0}>'

            $Config.IncludeUrl ?
                $AnsiUrl : ''
        )
    }
}

function Dotils.BasicFormat.Predent {
    <#
    .synopsis
        minimalism predenting text, emits as array of strings
    .EXAMPLE
        # indent code to paste
        Get-Clipboard | f.Predent 4 | Set-Clipboard -PassThru
    .EXAMPLE
        0..3 | %{  $_ ;'a'..'c' | f.Predent 2 } | f.Predent 2
        # same as
        0..3 | %{
            $_
            'a'..'b'
            | f.Predent 2
        }   | f.Predent 2

        # Out

            0
                a
                b
            1
                a
                b
            2
                a
                b
            3
                a
                b
    #>
    [Alias(
        'f.Predent'
    )]
    [CmdletBinding()]
    [outputType('System.String[]')]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [ArgumentCompletions('2', '3', '4')]
        [Parameter(Mandatory, Position=0)]
        [uint]$Depth = 2,

        [Parameter(Position=1)]
        [ArgumentCompletions('2', '3', '4', '6', '8')]
        [uint]$CharsPerDepth = 2,

        [Parameter()]
        [ArgumentCompletions(
            "' '",
            "'  '",
            "'␠'",
            '"`t"',
            '> '
        )]
        [string]$Text = ' '
    )
    begin {
        [string]$prefix = $Text * ( $Depth * $CharsPerDepth ) -join ''
    }
    process {
        $InputObject | %{
            $_ | Join-String -f "${prefix}{0}"
        }

    }
}

function Dotils.SkipOne.Filter {
    <#
    .SYNOPSIS
        sugar for skipping one. $Obj | Select -skip 1
    #>
    [alias('Skip1')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [object[]]$InputObject

        # [Alias('Reverse', 'Last1')]
        # [switch]$FromEnd
    )
    begin {
        $isFirst = $true
    }
    process {
        if( $FromEnd) {
            throw 'NYI: skipped reverse case for simplicity'
        }
        if($IsFirst) {
            $IsFirst = $false
            return
        }
        $InputObject
    }
}

function Dotils.Network.Find-PortOwner {
    <#
    .synopsis
        Lookup process who is using a specific port
    .LINK
        Dotils.Network.Find-PortOwner
    .LINK
        Dotils.Network.Find-ReversePortLookup
    .EXAMPLE
        Pwsh> Dotils.Net.Find-PortOwner -Port @(7070..7073 + 9099 + 3000..3003 + 8080 )
    .EXAMPLE
        Pwsh> Dotils.Net.Find-PortOwner -Port 3000

            NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
            ------    -----      -----     ------      --  -- -----------
            126   807.87     755.43     137.05   12880   1 Code
    #>
    [Alias(
        'Dotils.Net.Find-PortOwner'
    )]
    param(
        [ArgumentCompletions(
            "@(7070..7073 + 9099 + 3000..3003 + 8080 )",
            7071, 7077, 9099, 909, 80, 8080
        )]
        [int[]]$Port
    )

    $found = @(
        foreach($curPort in $Port) {
            $query = Get-NetTCPConnection | ? LocalPort -Match $curPort
            if( $Query.count -le 0 ) {
                'no process found matching port {0}' -f $curPort | write-error
                continue
            }
            Get-Process -pid $query.OwningProcess
        }
    )
    $found.count | Join-String 'Found {0} records: ' | write-host -fore 'darkgreen'
    return $found
}


function Dotils.Network.Find-ReversePortLookup {
    <#
    .synopsis
        Lookup process who is using a specific port
    .EXAMPLE
        Dotils.Net.ReversePortLookup pwsh|Ft
    .EXAMPLE
        Dotils.Net.ReversePortLookup
    .LINK
        Dotils.Network.Find-PortOwner
    .LINK
        Dotils.Network.Find-ReversePortLookup
    #>
    [Alias(
        'Dotils.Net.ReversePortLookup'
    )]
    param(
        [ArgumentCompletions(
            'pwsh', 'func'
        )]
        # blank proccess name returns everything
        [string]$ProcessName,

        # passthru returns everything
        [switch]$PassThru
    )

    $myIp = (
        ipconfig
            | ?{ $_ -match 'Ipv4 Address' }
            | Select-Object -First 1) -split ' ', -2
            | select-Object -Last 1
    $myGatewayIp = (
        ipconfig
            | ?{ $_ -match 'Default Gateway' }
            | Select-Object -First 1) -split ' ', -2
            | select-Object -Last 1

    function Abbr-Address {
        param(
            [Parameter(Mandatory)]
            [Alias('IP')]
            $Address
            # [Parameter()]
            # [Alias('MyIP')]
            # $MyAddress =
         )

        $Address -replace [Regex]::escape( $myIP ),
                '🐒me' -replace [regex]::escape( '127.0.0.1'),
                '🏠' -replace 'localhost',
                '🏠' -replace [regex]::Escape( $MyGatewayIP ),
                '🚪'

    }

    Get-NetTCPConnection | %{
        $netInfo = $_
        $curPs = (ps -PID $_.OwningProcess)
        $isMatch = $CurPs.Name -match 'pwsh'
        [pscustomobject]@{
            PSTypeName = 'glau.ReversePortLookupResult'
            Name = '{0} [ {1} ]' -f @(
                $CurPs.Name
                $CurPs.Id
            ) | Join-String -sep ''

            IpLocalAbbr =
                Abbr-Address $netInfo.LocalAddress
            IpRemoteAbbr =
                Abbr-Address $netInfo.RemoteAddress

            ShortLocal= @(
                '{1}▸{0}' -f  @(
                    $netInfo.LocalPort, $netInfo.LocalAddress )
            ) | Join-String -sep ''
            ShortRemote = @(
                '{1}▸{0}' -f  @(
                    $netInfo.RemotePort, $netInfo.RemoteAddress )
            ) | Join-String -sep ''

            Summary = @(
                $curPs.Name
                Join-String -in $curPs.Id -op ' [ ' -os ' ] '
                'Local: {1}▸{0}' -f  @(
                    $netInfo.LocalPort, $netInfo.LocalAddress)
                "`n"
                'Remote: {1}▸{0}' -f  @(
                # 'Remote: [ P {0} • Addr {1} • ]' -f  @(
                    $netInfo.RemotePort, $netInfo.RemoteAddress)
                "`n"
                $netInfo.ToString()
            ) | Join-String -sep ''
            ProcessObject      = $curPs
            NetInfoObject = $netInfo
            IsMatch       =
                $PassThru -or
                    ($CurPs.Name -match $ProcessName) -or
                    ([string]::IsNullOrWhiteSpace($ProcessName))
        }
    } |  %{
        if( $PassThru ) { return $_ }
        if( [string]::IsNullOrWhiteSpace( $ProcessName ) ) { return $_ }
        if($_.IsMatch) { return $_ } else { return }
    } | Sort-Object Name

}

function Dotils.From.BaseB64String {
    <#
    .synopsis
        reads values as base64 string, and may auto-detects padding
    .example
        err -Clear && impo Dotils -Force -PassThru &&
        h1 'break'; Dotils.From.BaseB64String -Str 'ae' -Debug
        h1 'work'; Dotils.From.BaseB64String -Str 'ae==' -Debug
    #>
    [Alias('Dotils.From.StrB64')]
    [CmdletBinding()]
    param( [string]$Str, [int]$padEnd ) # , [switch]$VerboseOutput )
    write-host 'partial wip, should clean up, or exit early if the exception is invalidb64 chars' -bg 'gray30' -fg 'gray80'

    $Bytes? = $Null # ensure local scope is clean
    # $Bytes? = @( [Convert]::FromBase64String( $Str ) )
    if($PadEnd) {
        $autoPadSuffix =
            @(  $Str
                ('=' * $padEnd -join '')) -join ''

        $Bytes? = [Convert]::FromBase64String( $autoPadSuffix )
    } else {
        foreach($i in 0..4) { # only 2 padding is valid?
            $autoPad = $null
            try {
                $autoPadSuffix =
                    @(  $Str
                        ('=' * $padEnd -join '')
                    ) -join ''
                $Bytes? = [Convert]::FromBase64String( $autoPadSuffix )
                break
            } catch {
                continue
            }
        }
    }
    if($true) {
        [pscustomobject]@{
            PSTypeName = Join-String -op 'Dotils.Result.' -in $PSCmdlet.MyInvocation.MyCommand Name
            TrueNull   = $null -eq $Bytes?
            Length     = $Bytes?.Length
            Sin        = $Str
            PadEnd     = $PadEnd ?? $false
            Bytes      = $Bytes? | Join-String -f '{0:x}' -sep ' '
            BytesCount = $Bytes?.count
        } | ft -auto | out-string -Width 1kb | Join-string -sep "`n"
            | New-Text -fg 'lightgreen' -bg 'gray20'
            | Write-Debug
    }

    [ArgumentException]::ThrowIfNullOrEmpty(
        $bytes?, 'Auto padding failed for all cases. $Bytes was null.' )

    return $Bytes?
}


function Fd.Go {
   param()
   @(
      '..'
       '../..'
       fd
   ) | fzf | goto -AlwaysLsAfter
}
function Bdg.Go {
    <#
    .SYNOPSIS
        find *and* Goto code-workspacesa related to bdg, filter by time
    .example
        bdg.go 2months -BasePaths H:\data\client_bdg, H:\temp_clone\aws-lambda-pwsh\aws-lambda-powershell-runtime
    #>
    param(
        [ArgumentCompletions(
            '10weeks', '4weeks', '5days', '2hours', '90minutes', '15minutes', '90seconds'
        )]
        [string]$ChangedWithin = '2weeks',

        [Alias('FileType', 'Extension', 'Kind')]
        [ArgumentCompletions(
            'yml', 'code-workspace', 'json', 'ps1', 'psm1', 'psd1', 'xml', 'md', 'yaml', 'config',
            'rpm', 'vhd', 'vhdx', 'json', 'log'
        )]
        [Parameter()]
        [string[]]$ItemKind = @('yml', 'code-workspace'),

        [ArgumentCompletions(
          'H:\data\client_bdg',
          'H:\data\client_bdg\2023.11-bdg-s3-aws-lambda-app',
          'G:\temp\2023-12-06.dock-test',
          'H:\temp_clone\aws-lambda-pwsh\aws-lambda-powershell-runtime'
        )]
        [string[]]$BasePaths,

        # fzf -m ?
        [Alias('M')][switch]$Multi,
        [switch]$PassThru

    )

    if( -not $BasePaths ) {
        $BasePaths = @(
            # 'H:\data\client_bdg',
            'H:\data\client_bdg\2023.11-bdg-s3-aws-lambda-app'
            'H:\temp_clone\aws-lambda-pwsh\aws-lambda-powershell-runtime'
            'G:\temp\2023-12-06.dock-test'
        )
    }

    [List[Object]]$binArgs = @(
        foreach($I in $ItemKind) {
            '-e'
            $ItemKind
         }
        if($ChangedWithin) { '--changed-within'; $ChangedWithin }
        foreach($P in $BasePaths) {
            '--search-path'
            (Get-item -ea 'stop' $P)
        }
        # '--search-path'
        # (gi 'H:\temp_clone\aws-lambda-pwsh\aws-lambda-powershell-runtime')
        # '--search-path'
        # (gi 'H:\data\client_bdg')
        #'--strip-cwd-prefix'
        #'--color'
        #'always'
    )
    [List[Object]]$FzfArgs = @(
        if($Multi) { '-m' }
    )
    if( $PassThru ) {
        $script:Bdg_LastSelect = @(
            & fd @binArgs
            | fzf @fzfArgs
        )
    } else {
        $script:Bdg_LastSelect = @(
            & fd @binArgs
            | fzf @fzfArgs
        )
        $script:Bdg_LastSelect
            | goto

    }

    $binArgs | Join-String -op "`ran fzf => " | write-host -bg 'gray60' -fg 'gray30'
}
function Dotils.Git.FindRepos {
    <#
    .SYNOPSIS
        find get repos under a depth of N
    .EXAMPLE
        Dotils.Git.FindRepos -Depth 4
    #>
    [CmdletBinding()]
    [OutputType( [System.IO.DirectoryInfo] )]
    param(
        [Parameter(Position = 0)]
        [int] $Depth = 3
    )
    $Found = @(
        fd @(
            '^\.git$',
            '--type', 'directory'
            '--max-depth', $Depth
            '--hidden', '--no-ignore'
        ) | Get-Item -Force
    )

    $Found.count
        | Join-String -f 'Found {0} files'
        | write-host -fg 'gray30' -bg 'gray80'

    return $Found
 }
function Dotils.Git.Select {
    [Alias('Dotils.GitSel', '.GitSel')]
    param()
    Import-Module 'ugit'


    $global:GitSel = (git status .).Unstaged | % file | % fullname | fzf -m
    $GitSel

    # ($global:GitSel = (git status .).Unstaged | % file | % fullname | fzf -m)
    $gitSel.count | Join-string '$gitSel = selected {0} files' | write-host -fore blue -bg 'gray20'
}
function Dotils.DB.toDataTable {
<#
.synopsis
	output DataTable from an object
.example
	Get-Service | Dotils.DB.toDataTable
.example
	Get-Date    | Dotils.DB.toDataTable
.notes
    started: <https://gist.github.com/indented-automation/2dd91c24c2ef0a985ae9454bd713f7da#file-license-txt-L2>
#>
    [Alias('Dotils.ConvertTo-DataTable')]
    [OutputType('System.Data.DataTable')]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Object]$InputObject
    )

    begin {
        $dataTable = [System.Data.DataTable]::new()
    }

    process {
        if ($dataTable.Columns.Count -eq 0) {
            $null = foreach ($property in $InputObject.PSObject.Properties) {
                $dataTable.Columns.Add($property.Name, $property.TypeNameOfValue)
            }
        }

        $values = foreach ($property in $InputObject.PSObject.Properties) {
            ,$property.Value
        }
        $null = $dataTable.Rows.Add($values)
    }

    end {
        ,$dataTable
    }
}

function Dotils.Unicode.CategoryOf {
    <#
    .synopsis
        Sugar that isn't needed. the main purpose was to tune different parametersets with nice default bindings
    .EXAMPLE
        # see: <tests/Dotils.Unicode.Category.test.ps1>
    #>
    [CmdletBinding()]
    [Alias('Dotils.Uni.Category')]
    param(
        [Alias('FromInt')]
        [Parameter(Mandatory, ParameterSetName='FromInt')]
        [int]$CodePoint,

        [Alias('FromChar')]
        [Parameter(Mandatory, ParameterSetName='FromChar')]
        [char]$Char,

        # if specified,non empty str
        [Alias('FromString')]
        [Parameter(Mandatory, ParameterSetName='FromString', Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$InputText,

        [Alias('Position')]
        [Parameter(ParameterSetName='FromString', Position = 1)]
        [int]$Index,

        [Parameter(ParameterSetName='FromRune')]
        [Text.Rune]$Rune
    )
    switch($PScmdlet.ParameterSetName) {
        'FromInt' {
            return [Globalization.CharUnicodeInfo]::GetUnicodeCategory( [int]$Codepoint )
            # $Char = [char]::ConvertFromUtf32( $CodePoint )
        }
        'FromChar' {
            return [Globalization.CharUnicodeInfo]::GetUnicodeCategory( [char]$Char )
        }
        'FromRune' {
            return [Text.Rune]::GetUnicodeCategory( $Rune ) # or
            return [Globalization.CharUnicodeInfo]::GetUnicodeCategory( $Rune.Value )
        }
        'FromString' {
            $StrLen = $InputText.Length
            if($StrLen -eq 0) {
                write-error 'InvalidArgumentValueException: Requires any text'
                return
            }
            if($StrLen -eq 1) {
                return [Globalization.CharUnicodeInfo]::GetUnicodeCategory( $InputText, 0 )
            }
            # future: benchmark whether enumerate is expensive
            # StrLen is > 1 but it's still one codepoint
            [bool]$IsSingleCodepoint = $InputText.EnumerateRunes().Value.Count -eq 1
            if($IsSingleCodepoint) {
                [Text.Rune]$Rune = @( $InputText.EnumerateRunes() )[0]
                return [Text.Rune]::GetUnicodecategory(  $Rune )
            }

            # only expected remaining case is a valid index
            if($InputText.Length -gt 1) {
                if( -not $PSBoundParameters.ContainsKey('Index')) {
                    write-error 'String longer than 1 StrLen but index not specified'
                    return
                }
                return [Globalization.CharUnicodeInfo]::GetUnicodeCategory( $InputText, $Index )
            }

            throw "ShouldNeverReachException"
        }
        default {
            throw "InvalidArgumentException"
        }

    }
}

# 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
# 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }

# function Shorten {
#     <#
#     .SYNOPSIS
#         truncate string length, never throw errors
#     #>
#     [CmdletBinding()]
#     [Alias('Dotils.Text.Shorten')]
#     param(
#         # text to shorten
#         [AllowEmptyString()]
#         [AllowNull()]
#         [Alias('InputObject', 'Text')]
#         [Parameter(ValueFromPipeline)]
#         [string]$InputText,

#         [int]$MaxLength = 120
#     )
#     process {
#         if($Null -eq $InputText) { return '' }
#         if( [string]::IsNullOrEmpty( $InputText) ) { return '' }
#         $inputLen = $InputText.length
#         $maxValidCount = [Math]::Clamp(
#             <# value #> $inputLen,
#             <# min #> 0, <# max #> $MaxLength )

#         $InputText.Substring( 0, $maxValidCount )

#         <# or WinPS #>
#         if($false) {
#             $reFirst = '^(.{1,50}).*' # silly regex, grab the first 300 chars
#             $InputText -replace $reFirst, '$1'
#         }
#     }
# }
function Dotils.Culture.Get {
    <#
    .SYNOPSIS
        return culture info, later will be able to filter
    .NOTES

        When a new application thread is started, its current culture and current UI culture are defined by the current system culture, and not by the current thread culture.

        All cultures that are recognized by .NET, including neutral and specific cultures and custom cultures created by the user.

        On .NET Framework 4 and later versions and .NET Core running on Windows, it includes the culture data available from the Windows operating system. On .NET Core running on Linux and macOS, it includes culture data defined in the ICU libraries.

        AllCultures is a composite field that includes the NeutralCultures, SpecificCultures, and InstalledWin32Cultures values.

    # if not auto completed
    # 'AllCultures', 'FrameworkCultures', 'InstalledWin32Cultures', 'NeutralCultures', 'ReplacementCultures', 'SpecificCultures', 'UserCustomCulture', 'WindowsOnlyCultures'
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.culturetypes?view=net-7.0
    .LINK
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo.getcultures?view=net-7.0#system-globalization-cultureinfo-getcultures(system-globalization-culturetypes)
    .link

    #>
    [Alias('Dotils.Culture.Gci')]
    param(
        # What kinds? # <https://learn.microsoft.com/en-us/dotnet/api/system.globalization.culturetypes?view=net-7.0>
        [Parameter()]
        [Globalization.CultureTypes]
        $CultureTypes = [Globalization.CultureTypes]::AllCultures
    )

    ( $query =
        [Globalization.CultureInfo]::GetCultures( $CultureTypes ) )
}
function Dotils.Format-TextCase {

    <#
    .synopsis
        Format text case using culture's [TextInfo]
    .NOTES
        note
            Get-Culture # default
            Get-Culture '' # invariant

        curious, is this ever *not* equivalent ?
            'sdf'.ToUpper( $cult )
            $cult.TextInfo.ToUpper( 'sdf' )
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo?view=net-7.0
    .example
        $randCult = Get-Random -inp (Get-Culture -ListAvailable) -Count 1
        '13e S" DFSIJf "Ejedsfj' | Dotils.Format-TextCase Title $randCult
    #>
    [Alias('Text.Case')]
    param(
        # Which mode, Upper, TitleCase, LowerCase and invariant versions
        [ValidateSet('Title', 'Upper', 'Lower',
            'LowerInvariant', 'UpperInvariant')]
        [Parameter()]
        [string]$OutputMode,

        [Parameter()]
        [ArgumentCompletions(
            "en-us",
            "(Get-Culture 'de-de')",
            "(Get-Culture "
        )][string]$CultureName = (Get-culture).Name,

        [Alias('InputObject')]
        [AllowNull()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TextInput

    )
    begin {

        $cult = Get-Culture -Name $CultureName }
    process {
        if($null -eq $TextInput) { return }
        if( $TextInput.length -eq 0) { return }
        [string]$obj = $TextInput ?? ''

        switch($OutputMode) {
           'Title' {
                $cult.TextInfo.ToTitleCase( $obj ) }
           'Upper' {
                $cult.TextInfo.ToUpper( $obj ) }
           'Lower' {
                $cult.TextInfo.ToLower( $obj ) }
           'LowerInvariant' {
                $obj.ToLowerInvariant() }
            'UpperInvariant' {
                $obj.ToUpperInvariant() }
           default { $obj }
        }
    }
}




function Dotils.Format-ShortString.Basic {    <#
    .synopsis
        Shorten string in a way that never errors. Keep it simple
    .NOTES
        future:
            ability to write num chars relative root.
    .example
        $error  | .Has.Prop -PropertyName 'InvocationInfo'
                | Dotils.ShortString.Basic -maxLength 120
                | Join-String -sep (hr 1)
    .example
        $error
            | .Has.Prop -PropertyName 'InvocationInfo' | %{ $_.Exception }
            | Dotils.ShortString.Basic -maxLength 120 | Join.UL
    .example
        PS> 'abc', 'defg' | Dotils.ShortString.Basic -maxLength 2

        'ab', 'de'

        PS> 'a'..'e' | Dotils.ShortString.Basic -maxLength 1

        'a', 'b', 'c', 'd', 'e'

        PS> '', $Null, 'abc', 'def' | Dotils.ShortString.Basic -maxLength 1

        '␀', 'a', 'd'

    .link
        Dotils\Dotils.Format-ShortString.Basic
    .link
        Dotils\Dotils.Format-ShortString

    #>
    [Alias('Dotils.ShortString.Basic')]
    [OutputType('String')]
    [CmdletBinding()]
    param(
        # Text to format
        [Alias('Text', 'String')]
        [Parameter(Mandatory, Position=0,
            ValueFromPipeline)]
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]$InputObject,

        # future: validatescript to assert length?
        [int]$maxLength = 80
    )
    begin {
        <#
        todo: nyi: rewrite
                        Silly. I didn't realize -Process will *always* run even without a pipeline
        #>
        function __apply.SubStr {
            [outputType('String')]
            param(
                [string]$Text, [int]$maxLength
            )
            if($null -eq $Text) { return '␀' }
            if($Text.length -eq 0) { return '␀' }
            $Len = $Text.Length
            $maxOffset = $input.Length - 1 # not used
            <#
            must be updated if position is every relative a non-zero
                because it's not an offset, it's a length
            #>
            [int]$selectedCount = [math]::Clamp(
                <# value #> $maxLength,
                <# min #> 0, <# max #> $Len )

            return $Text.SubString(0, $selectedCount )
        }

    }
    process {
        if($MyInvocation.ExpectingInput ) {
            foreach($item in $InputObject) {
                __apply.SubStr -Text $item -maxLength $maxLength
            }
        }
    }
    end {
        if(-not $MyInvocation.ExpectingInput ) {
            foreach($item in $InputObject) {
                __apply.SubStr -Text $item -maxLength $maxLength
            }
        }
    }
}

function Dotils.New-HashSetString.basic {
    <#
    .SYNOPSIS
        sugar for a CaseInsensitive Set
    .EXAMPLE
        Pwsh> 'bob', 'Bob', 'fred', 'fred' | Dotils.New-HashSetString.basic
            ["","bob","fred"]
        Pwsh> Dotils.New-HashSetString.basic -inp 'bob', 'Bob', 'fred', 'fred'
            ["","bob","fred"]
    .notes

    related types:
        [StringComparer]
        [StringComparison]
    #>

    [CmdletBinding()]
    param(

        # autocomplete enum: enum: 'CurrentCulture', 'CurrentCultureIgnoreCase', 'InvariantCulture', 'InvariantCultureIgnoreCase', 'Ordinal', 'OrdinalIgnoreCase', 'value__'
        [Parameter( Position = 0)]
        [Alias('StringComparison')]
        [StringComparison]$CompareKind = 'InvariantCultureIgnoreCase',
        # is a custom func?

        [StringComparer]$Comparer,

        # [type]$TypeName = 'string'
        [Alias('Names', 'Text')]
        [Parameter(Position = 1, ValueFromPipeline)]
        [string[]]$InputObject
    )
    # if( -not $MyInvocation.ExpectingInput) {
    # }

    begin {
        write-warning 'slightly NYI, validate working'
        $InputObject ??= @('')
        $set = [Collections.Generic.HashSet[string]]::new(
            [string[]]$InputObject,
            [StringComparer]::OrdinalIgnoreCase )


        if($PSBoundParameters.ContainsKey('CompareKind') -or $PSBoundParameters.ContainsKey('Comparer')) {
            # todo, future: can I pass the autocompleting enum for the hash creation ?
            # or convert it to a [StringComparer] func??
                # wait-debugger
            throw 'partial wip next'
        }
        write-warning 'slightly NYI, validate working'
    }
    process {
        if( -not $MyInvocation.ExpectingInput ) {
            # 'not expecting' | write-host -bg 'red'
            return
        }

        foreach($Name in $InputObject) {
            $Null = $set.Add( $Name )
        }
    }
    end {
        return $set


        # throw 'Wip sketch, NYI'
        # if( -not $PSBoundParameters.ContainsKey('Names') ) {
        #     $Names = ''
        # }
        # $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, ())

        # else {
        #     $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, $Comparer)
        # }
        # $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, [StringComparer]::OrdinalIgnoreCase)
    }
}
function Dotils.New-HashSetString.fancy {
    <#
    .SYNOPSIS
        sugar for a CaseInsensitive Set

    related types:
        [StringComparer]
        [StringComparison]
    #>

    [CmdletBinding()]
    param(
        # [type]$TypeName = 'string'
        [Alias('InputObject', 'Text')]
        [Parameter(ValueFromPipeline)]
        [string[]]$Names,

        # autocomplete enum: enum: 'CurrentCulture', 'CurrentCultureIgnoreCase', 'InvariantCulture', 'InvariantCultureIgnoreCase', 'Ordinal', 'OrdinalIgnoreCase', 'value__'
        [Parameter( Position = 0)]
        [Alias('StringComparison')]
        [StringComparison]$CompareKind = 'InvariantCultureIgnoreCase',

        # is a custom func?
        [StringComparer]$Comparer
    )
    begin {
        write-warning 'slightly NYI, validate working'
    }
    process {
        throw 'Wip sketch, NYI'
        if( -not $PSBoundParameters.ContainsKey('Names') ) {
            $Names = ''
        }
        # $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, ())

        # else {
        #     $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, $Comparer)
        # }
        # $hash ??= [Collections.Generic.HashSet[string]]::new( [string[]]$names, [StringComparer]::OrdinalIgnoreCase)
    }
}
# function Dotils.Template.PipelineParametersStandardBehavior {
#     [CmdletBinding()]
#     param(
#         [Alias('InputObject')]
#         [Parameter(ValueFromPipeline)]
#         [object[]]$file
#     )
#     begin {
#         [Collections.Generic.List[Object]]$Items = @()
#     }
#     process {
#         if( $MyInvocation.ExpectingInput ) {
#             $Items.AddRange(@( $file ))
#         } else {
#             $Items = @( $file )
#         }
#     }
#     end {
#         $Items | %{ "Item: $_" }
#     }
# }

function Dotils.Template.PipelineParametersStandardBehavior {
    [CmdletBinding()]
    param(
        [Alias('InputObject')]
        [Parameter(ValueFromPipeline)]
        [object[]]$file
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        if( $MyInvocation.ExpectingInput ) {
            $Items.AddRange(@( $file ))
        } else {
            $Items = @( $file )
        }
    }
    end {
        $Items | %{ "Item: $_" }
    }
}

function Dotils.Format-ShortString {    <#
    .synopsis
        Shorten string in a way that never errors. Keep it simple
    .NOTES
        future:
            ability to write num chars relative root.
    .link
        Dotils\Dotils.Format-ShortString.Basic
    .link
        Dotils\Dotils.Format-ShortString

    #>
    [Alias('Dotils.ShortString')]
    [OutputType('String')]
    [CmdletBinding()]
    param(
        # Text to format
        [Alias('Text', 'String')]
        [Parameter(Mandatory, Position=0,
            ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$InputObject,

        # future: validatescript to assert length?
        # Null or empty
        [Alias('Number', 'Count', 'MaxChars', 'MaxCols')]
        [Parameter()]
        [int]$maxLength = 80,
        # can be negative
        [Alias('StartAt')]
        [Parameter()]
        [int]$startPosition = 0 #
    )
    write-warning "NYI: make this properly emit pipeline,
    'foo', 'bar', 'cat' | Dotils.ShortString.Basic -maxLength 2  # works
    'foo', 'bar', 'cat' | Dotils.ShortString -maxLength 2  # does not
    "
    if($null -eq $InputObject) { return '␀' }

    $Len = $InputObject.Length
    if($StartPosition -lt 0) {
        # $MaxOffset = $Input.Length
        $startAt = $input.Length + $startPosition # which is -1
    } else {
        $startAt = $startPosition
    }

    $maxOffset =
        $input.Length - 1
    $maxCount =
        $maxOffset - $startAt

    # $possibleMaxSubstrLength =
    #     $maxOffset


    <#
    must be updated if position is every relative a non-zero
        because it's not an offset, it's a length
    #>
    [int]$selectedCount = [math]::Clamp(
        <# value #> $maxLength,
        <# min #> 0, <# max #> $Len )

    [ordered]@{
        StartAt = $startAt
        StartPosition = $startPosition
        InputLen = $input.Length
        MaxOffset = $MaxOffset
        SelectedCount = $SelectedCount
        MaxCount = $MaxCount
    }
        | Json | Join-String -op 'Format-ShortString: '
        | write-debug

    return $InputObject.SubString(0, $selectedCount )

}
# 'Dotils.Object.QuickInfo' = { 'QuickInfo' }
function Dotils.Object.QuickInfo {
    [Alias('QuickInfo')]
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position=0)]
        $InputObject
    )
    $InputObject.psobject.properties | %{
        #$_.Name, $_.TypeNameOfvalue | Join-String -sep ' ⇒ '
        try {
        # or I could grab the type from Value
            $tinfoFromStr = $_.TypeNameOfValue -as 'type'
        } catch {
            $tinfoFromStr = $_.TypeNameOfValue
        }
        [pscustomobject][ordered]@{
            Name = $_.Name

            Kind =
                ($tinfoFromStr | Format-ShortSciTypeName) ??
                    $tinfoFromStr

            tInfoInstance = # auto hide
                $tInfoFromStr
      }
    }
}

function Dotils.Type.Info {
    <#
    .SYNOPSIS
    convert/coerce values into type info easier
    .example
        @( 'IPropertyCmdletProvider'
        'ICmdletProviderSupportsHelp'
        'IContentCmdletProvider' ) | .Type.Info


    .example
        'rgbcolor'  |  Dotils.Type.Info
                    | %{ $_.GetTypeInfo().FullName }
                    | Should -Be 'PoshCode.Pansies.RgbColor'
    #>
    [Alias('.As.TypeInfo')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, mandatory)]
        [object]$InputObject,

        [switch]$CompareAsLower,

        [Alias('All')][switch]$WildCard
    )
    process {
        if(-not $WildCard -and ($InputObject -match '\*')) {
            write-error 'wildcard not enabled, are you sure?'
        }
        if($CompareAsLower) {
            $InputObject = $InputObject.ToLower()
        }
        $query = Find-Type $InputObject
        if(-not $query) { write-error 'failed type' ; return }
        return $query
    }
}
function Dotils.Render.CallStack {
    <#
    .SYNOPSIS
        quickly, render PS CallStack else the current one
    .DESCRIPTION
        'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }
    .EXAMPLE
        Dotils.Render.CallStack
    .EXAMPLE
        Get-PSCallStack
            | Dotils.Render.CallStack Default
    .EXAMPLE
        # piping allows user to reverse, or even automatically trim segments for abbreviation
        Get-PSCallStack
            | ReverseIt
            | Dotils.Render.CallStack
    #>
    [Alias(
        '.CallStack', 'Render.Stack'
    )]
    [CmdletBinding()]
    param(
        # Json to make copy-paste easier
        [ValidateSet(
            'FullNameLineNumber',
            'Default', 'Line',
            'List', 'Json'
        )][string]$OutputFormat = 'Default',

        # input else current
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CallStack', 'Frames', 'Stack', 'CallStackFrame', 'Command')]
        [Management.Automation.CallStackFrame[]]$InputObject,

        [switch]$ClipIt,

        [switch]$ExtraVerbose
    )
    begin {
        # [Collections.Generic.List[Object]]$Items = @()
        [Collections.Generic.List[Management.Automation.CallStackFrame]]$Items = @()
        if ($ExtraVerbose) {
            '-begin Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }
    }
    process {
        if ($ExtraVerbose) {
            '-proc  Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }
        # if pipeline expecting input, merge list of items
    }
    end {
        if ($ExtraVerbose) {
            '-end   Cmdlet.Expect? {0}, MyInvoC.Expect?: {1}, Key?: [ -InpObj: {2}, -Frames: {3} ]' -f @(
                $PSCmdlet.MyInvocation.ExpectingInput
                $MyInvocation.ExpectingInput
                $PSBoundParameters.ContainsKey('InputObject')
                $PSBoundParameters.ContainsKey('Frames')
            ) | Write-Host -fore white -back darkblue
        }

        if ( -not $MyInvocation.ExpectingInput -or -not $items) {
            $items = Get-PSCallStack
        }

        # if(-not $PSBoundParameters.)
        [string[]]$render = ''
        switch ($OutputFormat) {
            'Default' {
                $render = $Items | Join-String -Property Command -sep ' ▸ '
            }
            'Line' {
                $render = $Items | Join-String -Property Command -sep ' Ⳇ '
            }
            'List' {
                $render = $Items | Join-String -Property Command -f "`n - {0}"
            }
            'FullNameLineNumber' {
                $items
                | Foreach-Object {
                    $cur  = $_;
                    $cur | Add-Member -PassThru -Force -ea ignore -NotePropertyMembers @{
                        FullNameWithLineNumber =
                            '{0}:{1}' -f @( $cur.ScriptName ?? ''; $cur.ScriptLineNumber ?? 0 )
                    } }
                | ft FullNameWithLineNumber
            }

            default {
                throw "UnhandledOutputFormat: $OutputFormat"
                # 'sdfds'
            }
        }
        $sbRaw = "${bg:gray80}${fg:gray30}[Sb]${bg:clear}${fg:clear}" # color tbd
        $sbRaw = '{Sb}'
        [string]$render = $render -join "`n" -replace [Regex]::Escape('<ScriptBlock>'), $sbRaw
        if ($ClipIt) {
            return $render | Set-Clipboard -PassThru
        }
        return $render

    }
}


function Dotils.Random.Module { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random module from the list of modules
    .DESCRIPTION
        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.
    .example
        Dotils.Random.Module | Dotils.Random.Command
    .example
        'pansies', 'ImportExcel', 'ugit' | Dotils.Random.Module
    .example
        Dotils.Random.Module  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.Module
    .NOTES
        test each invoke mode
        - [x] Dotils.Random.Module -ModuleName 'ClassExplorer', 'ugit'
        - [x] 'ClassExplorer', 'ugit' | Dotils.Random.Module
        - [x] Dotils.Random.Module
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [CmdletBinding()]
    param(
        # defaults to parameter, else to pipeline, else default value
        [Parameter(ValueFromPipeline, Position=0)]
        [string[]]$ModuleName
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($ModuleName))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($ModuleName) {
                $Items.AddRange(@($ModuleName))
            }
        }

        if($items.count -eq 0){
            write-warning "InputNames not collected! $ModuleName"
            write-verbose 'fallback to defaults'
            $items.AddRange(@(
                'Pansies', 'ImportExcel', 'Dotils', 'ExcelAnt', 'Ugit', 'Ninmonkey.Console', 'PsReadLine', 'TypeWriter', 'ClassExplorer'

            ))
        }
        # $ModuleName ??= $ModuleName
        # $ModuleName ??= @(
        # )
        $items
            | Join-String -sep ', ' -op 'ModuleNames: ' -SingleQuote
            | Write-Verbose

        $items =
            $items | Sort-Object -Unique

        # does not enforce loading
        $maybeModules? = @(
            Get-Module -name $items
        )
        if($maybeModules?.count -lt $items.count) {
            $Items
                | Join-String -op 'Expected = ' -sep ', '-SingleQuote
                | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
                | write-warning

            $maybeModules? ?? '∅'
                | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
                | write-verbose
        }
        $whichModule =
            $maybeModules?
                | Get-Random -count 1

        if($whichModule) { return $whichModule }

        if(-not $whichModule) {
            $errMsg =
                $ModuleName | Join-String -op "Failed selecting random module! '$WhichModule'" -sep ', ' -SingleQuote
            throw $errMsg
        }
    }
}
function Dotils.Render.TextTreeLine {
    <#
    .SYNOPSIS
        Dotils.Render.TextTreeLine 'dots_psmodules'
        Dotils.Render.TextTreeLine 'Dotils' -Depth 1
        Dotils.Render.TextTreeLine 'Dotils' -Depth 2
    .EXAMPLE
        impo dotils -PassThru -Force | Join-String -prop { $_.Version, $_.Name }
        hr
        Dotils.Render.TextTreeLine 'classExplorer'
        Dotils.Render.TextTreeLine -d 1  @(gcm -m 'ClassExplorer' | Join-String Name -sep ', ' )
    .EXAMPLE
        $cmd_groups = gcm -m ImportExcel | group verb | sort Name  -Descending
        $cmd_groups | %{
            $verb = $_.Name
            if($Verb -eq ''){
                $Verb = '[empty]' # '␀'
            }
            $group = $_.Group
            Dotils.Render.TextTreeLine $verb -d 0
            $group | Sort Name | %{
                $item = $_
                Dotils.Render.TextTreeLine $item.Name -d 1
            }
            # | Join-String -sep ', '
        }

    #>
    [Alias('.Render.TreeLine', '.Render.TreeItem')]
    param(
        [ALias('Text')][string]$Token,
        [int]$Depth = 0,
        [hashtable]$Options = @{}
    )

    $Config = nin.MergeHash -other $Options -BaseHash @{
        ColorFg1 = "${fg:Gray95}"
        ColorFg2 = "${fg:gray65}"
        ColorFgDim = "${fg:gray40}"
    }
    $Rune = @{
        Bar_UpRightDown = '├'
        Bar_UpDown = '│'
        Bar_RightLeft = '─'
    }
    $prefix_Continue =
        $Rune.Bar_UpRightDown, ($Rune.Bar_RightLeft * 2), ' ' -join ''

    $prefix_Down =
        $Rune.Bar_UpRightDown, ($Rune.Bar_RightLeft * 2), ' ' -join ''

    $prefix_spaced =
        $Rune.Bar_UpDown, (' ' * 3) -join ''

    $TextColor = if($Depth -eq 0) {
        $Config.ColorFg1
     } else {
        $Config.ColorFg2
     }

    @(
        $Config.ColorFgDim
        $prefix_spaced * $Depth -join ''
        $prefix_Continue
        $TextColor
        $Token
        "${fg:clear}"
    ) -join ''
}
function Dotils.Render.TextTreeLine.Basic {
    <#
    .SYNOPSIS
        Dotils.Format.RenderTextTree 'dots_psmodules'
        Dotils.Format.RenderTextTree 'Dotils' -Depth 1
        Dotils.Format.RenderTextTree 'Dotils' -Depth 2
    .EXAMPLE
        $cmd_groups = gcm -m ImportExcel | group verb | sort Name  -Descending
        $cmd_groups | %{
            $verb = $_.Name
            if($Verb -eq ''){
                $Verb = '[empty]' # '␀'
            }
            $group = $_.Group
            Dotils.Format.RenderTextTree.Line $verb -d 0
            $group | Sort Name | %{
                $item = $_
                Dotils.Format.RenderTextTree.Line $item.Name -d 1
            }
            # | Join-String -sep ', '
        }

    #>
    param(
        [ALias('Text')][string]$Token,
        [int]$Depth = 0
    )
    $Rune = @{
        Bar_UpRightDown = '├'
        Bar_UpDown = '│'
        Bar_RightLeft = '─'
    }
    $prefix_Continue =
        $Rune.Bar_UpRightDown, ($Rune.Bar_RightLeft * 2), ' ' -join ''

    $prefix_Down =
        $Rune.Bar_UpRightDown, ($Rune.Bar_RightLeft * 2), ' ' -join ''

    $prefix_spaced =
        $Rune.Bar_UpDown, (' ' * 3) -join ''

    @(
        $prefix_spaced * $Depth -join ''
        $prefix_Continue
        $Token ) -join ''
}

function Dotils.Render.Bool {
    <#
    .SYNOPSIS
        render something bool-like
    .example
        Pwsh>
        $sample = 'true,$true,$null,null,none,false,$false,1,0,, ,y,Yes,n,No,not' -split ','

        $sample | Render.Bool | fcc |
    .LINK
        Dotils\Fmt.Sci
    .EXAMPLE
        # current expected value
'true,$true,␀,$null,null,none,false,$false,1,0,, ,y,Yes,n,No,not' -split
     ',' | Render.Bool | Join-String -sep "`n" { $_ | fcc }
        | cl -Append

            ␛[38;2;0;95;0mtrue␛[0m
            ␛[38;2;153;153;153m$true␛[0m
            ␛[38;2;190;116;73m␛[48;2;51;51;51m␀␛[0m
            ␛[38;2;190;116;73m␛[48;2;51;51;51m$null␛[0m
            ␛[38;2;190;116;73m␛[48;2;51;51;51mnull␛[0m
            ␛[38;2;190;116;73m␛[48;2;51;51;51mnone␛[0m
            ␛[38;2;95;0;0mfalse␛[0m
            ␛[38;2;153;153;153m$false␛[0m
            ␛[38;2;0;95;0m1␛[0m
            ␛[38;2;95;0;0m0␛[0m
            ␛[38;2;153;153;153m␛[0m
            ␛[38;2;153;153;153m␠␛[0m
            ␛[38;2;0;95;0my␛[0m
            ␛[38;2;0;95;0mYes␛[0m
            ␛[38;2;95;0;0mn␛[0m
            ␛[38;2;95;0;0mNo␛[0m
            ␛[38;2;153;153;153mnot␛[0m
    #>
    [Alias('Render.Bool', '.Render.Bool')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        [string]$Text = $InputObject
        $C = @{
            FgDim   = $PSStyle.Foreground.FromRgb('#999999')
            FgBad1  = $PSStyle.Foreground.FromRgb('#5f0000')
            FgBad2  = $PSStyle.Foreground.FromRgb('#c75f48')
            FgGood4 = $PSStyle.Foreground.FromRgb('#248000')
            FgGood1 = $PSStyle.Foreground.FromRgb('#005f00')
            FgGood2 = $PSStyle.Foreground.FromRgb('#9cc1be')
            FgGood3 = $PSStyle.Foreground.FromRgb('#a4dcff')
            FgNull  = "${fg:#be7449}${bg:#333333}"
        }
        $C.FgBad = $C.FgBad2
        $C.FgGood = $C.FgGood4

        if( $InputObject -isnot 'bool' ) {
            'InputObject type {0} is not a true [bool]' -f @( $InputObject | Format-ShortTypeName )
            | Write-verbose
        }
        $fg = $C.FgDIm
        $selectedColor = switch -Regex ( $Text ) {
            # too wide as nonzero
            # '^(true|1||[^0]+)$
            '^(\$?null|␀|none)$' { $C.FgNull }
            '^(true|1|y|yes)$' { $C.FgGood ; break; }
            '^(false|0|n|no)$' { $C.FgBad  ; break; }
            default { $C.FgDim }
        }
        $selectedColor = $selectedColor -join ''
        $Text | Join-String -op $selectedColor -os $PSStyle.Reset -sep ''
    }
}
function Dotils.Render.Dom.Attributes {
    <#
    .SYNOPSIS
        render attributes, sorted to the most important ones first, then truncates if wanted
    .NOTES
        currently sorts keys based on
            - specific Attributes to the front, others to the end
            - generic LongLengthValues to the end
            - finally by alpha

        future:
        - [ ] auto-exclude some keys
    .EXAMPLE

    #>
    [Alias('Render.Dom.Attributes')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Alias('InputText','Text', 'InputElement')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter(ValueFromPipeline)]
        $InputObject,


        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Attributes')]
        $ObjectAttributes,

        [ArgumentCompletions(
            "', '",
            "' '",
            "''",
            '"`n"'
        )]
        [string]$Separator = ' '
    )
    begin {
        $c = @{
            AttrKey = "${fg:#aad3a8}"
            AttrValue = "${fg:#94c5e4}"
        }
    }
    process {
        if(-not $ObjectAttributes) {
            $ObjectAttributes = $InputObject.Attributes
        }
        if($null -eq $ObjectAttributes) {
            $errMsg = 'MissingField: Object {0} could not find .Attributes' -f @(
                $InputObject | Format-ShortTypeName )
            throw $errMsg
        }

        # [string]$Text = $InputObject
        # $InputObject
        # $sep = ' ' # { '', ', ', ", " }
        # $lone.Attributes
        $ObjectAttributes
            # custom priorities
            | Sort-Object -Descending {@(
                -not ($_.Value.Length -gt 50)
                $_.Value.Length -lt 15
                $_.Name -match 'class|id|name'
                $_.Name -match 'href|src|url'
                $_.Name -notmatch 'alt'
                $_.Name
            )}
            | Join-String -sep $Separator {
            '{0}: {1}' -f @(
                $_.Name
                    | Join-String -op $c.AttrKey -os $PSStyle.Reset
                ( $_.Value ?? '')
                    | Join-String -DoubleQuote -op $c.AttrValue -os $PSStyle.Reset
            )
        }

    }
}

function Dotils.Random.Command { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random command from the list of modules
    .DESCRIPTION
        (warning, depraved code, do not continue)

        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.

        Does not filter out aliases. I want them for now.
    .example
        Dotils.Random.Command | Dotils.Random.CommandExample
    .example
        Dotils.Random.Command -ModuleName 'ImportExcel', 'Pansies' -Debug
        # Debug lists all commands that were chosen from
    .example
        'ugit' | Dotils.Random.Command
    .example
        Dotils.Random.Command  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.Command
    .NOTES
        test each invoke mode
        - [ ] Dotils.Random.Command -ModuleName 'ClassExplorer', 'ugit'
        - [ ] 'ClassExplorer', 'ugit' | Dotils.Random.Command
        - [ ] Dotils.Random.Command
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [OutputType(
        'System.Management.Automation.FunctionInfo',
        'System.Management.Automation.CommandInfo',
        'System.Management.Automation.AliasInfo'
    )]
    [CmdletBinding()]
    param(
        # defaults to parameter, else to pipeline, else default value
        # todo: future abstracts accepts a list of commands or module names
        # which could be object instances
        [Alias('SourceModule')]
        [Parameter(ValueFromPipeline, Position=0)]
        [string[]]$ModuleName
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($ModuleName))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($ModuleName) {
                $Items.AddRange(@($ModuleName))
            }
        }

        if($items.count -eq 0){
            write-warning "InputNames not collected! $ModuleName"
            write-verbose 'fallback to defaults'
            $items.AddRange(@(
                'Pansies',
                'ImportExcel',
                'Dotils',
                'ExcelAnt',
                'Ninmonkey.Console',
                'PsReadLine',
                'TypeWriter',
                'ClassExplorer'
                'Ugit'

            ))
        }
        # $ModuleName ??= $ModuleName
        # $ModuleName ??= @(
        # )
        $items
            | Join-String -sep ', ' -op 'ModuleNames: ' -SingleQuote
            | Write-Verbose

        $items =
            $items | Sort-Object -Unique

        # # does not enforce loading
        # $maybeModules? = @(
        #     Get-Module -name $items
        # )
        # if($maybeModules?.count -lt $items.count) {
        #     $Items
        #         | Join-String -op 'Expected = ' -sep ', '-SingleQuote
        #         | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
        #         | write-warning

        #     $maybeModules? ?? '∅'
        #         | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
        #         | write-verbose
        # }
        $whichModule =
            $Items | Dotils.Random.Module -wa 'ignore' -ea 'ignore'
        # $whichModule =
        #     $maybeModules?
        #         | Get-Random -count 1
        $cmds = @(
            Get-Command -Module $whichModule
            # $whichModule.ExportedCommands.Keys
            # $whichModule.ExportedFunctions.Keys
            # $whichModule.ExportedAliases.Keys
            # $whichModule.ExportedCmdlets.Keys

            # $whichModule | % ExportedCommands
            )
        | Sort-object -Unique

        $cmds | Join-String -op 'FoundCommands: ' -sep ', ' -SingleQuote
              | write-debug


        $whichCmd =
            $cmds | Get-Random -Count 1

        if($whichCmd) { return $whichCmd }

#         ( $someMod ??= Dotils.Random.Module )
# $q = $someMod | Dotils.Random.Command -Verbose
        if(-not $whichCmd) {
            $errMsg =
                $ModuleName | Join-String -op "Failed selecting random Command! '$WhichModule'" -sep ', ' -SingleQuote
            throw $errMsg
        }
    }
}

function Dotils.Random.CommandExample { # to refactor, to allow piping
    <#
    .SYNOPSIS
        grab a random example from a list of commands
    .DESCRIPTION
        (warning, depraved code, do not continue)

        Because it doesn't enforce importing modules, it will miss commands that aren't discoverable without loading the module.

        Does not filter out aliases. I want them for now.
    .example
        Dotils.Random.Command | Dotils.Random.CommandExample
    .example
        Dotils.Random.CommandExample -CommandName 'ExportExcel'
        # Debug lists all commands that were chosen from
    .example
        'ugit' | Dotils.Random.CommandExample
    .example
        Dotils.Random.CommandExample  -ModuleName 'ImportExcel', 'ClassExplorer'
        'ImportExcel', 'ClassExplorer' | Dotils.Random.CommandExample
    .NOTES
        test each invoke mode
        - [ ] Dotils.Random.CommandExample -ModuleName 'ClassExplorer', 'ugit'
        - [ ] 'ClassExplorer', 'ugit' | Dotils.Random.CommandExample
        - [ ] Dotils.Random.CommandExample
    .link
        Dotils.Random.Module
    .link
        Dotils.Random.Command
    .link
        Dotils.Random.CommandExample

    #>
    [OutputType(
        'System.Management.Automation.FunctionInfo',
        'System.Management.Automation.CommandInfo',
        'System.Management.Automation.AliasInfo'
    )]
    [CmdletBinding()]
    param(
        # this function requires input
        # defaults to parameter, else to pipeline, else default value
        # todo: future abstracts accepts a list of commands or module names
        # which could be object instances
        [Alias('CommandName')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline, Position=0, Mandatory)]
        [object]$InputCommand
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $PSCmdlet.MyInvocation.ExpectingInput # 𝄔
            | Join-String -f '  => -begin(): Expecting Input?: {0}' | write-debug
    }
    process {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>  -proc(): Expecting Input?: {0}' | write-debug
        # $PSCmdlet.input
        if( $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items.AddRange(@($InputCommand))
        }
    }
    end {
        $PSCmdlet.MyInvocation.ExpectingInput
            | Join-String -f '  =>   -end(): Expecting Input?: {0}' | write-debug

        if( -not $PSCmdlet.MyInvocation.ExpectingInput ) {
            if($InputCommand) {
                $Items.AddRange(@($InputCommand))
            }
        }

        if($items.count -eq 0){
            throw "InputNames not collected! $InputCommand"

        }
        $helpObj = @(
                gcm $Items | Get-Help -Examples
            )

        write-warning 'command not finished, try: >
    Dotils.Random.Command <# -Verbose -Debug #> | Dotils.Random.CommandExample -Verbose <# -Debug #>'

        $whichExample =
            # note: Piping to Get-Random does not function the same in this context, unless explicitally wrapped in an array, or passed as a parameter
            Get-Random -Count 1 -Input @(
                $helpObj.examples.examples
            )

        return $whichExample


#         [object[]]$examples = @(
#             $items | %{
#                 $cmdName = $_
#                 (gcm $cmdName | Get-Help -Examples).examples.example
#             }
#         )

#          (gcm $Items | Get-Help -Examples).examples.example

#         return

#         $items
#             | Join-String -sep ', ' -op 'CommandNames: ' -SingleQuote
#             | Write-Verbose

#         $items =
#             $items | Sort-Object -Unique

#         $cmds = @( # -is [CommandInfo[]]
#             gcm $Items
#                 | Sort-Object -unique
#         )

#         # $examples = @(
#         #     foreach($cur in $cmds) {
#         #         Get-Help $cur -Examples | % Examples
#         #     }
#         # )

#         # Get-Help @($cmds)[0]

#         # $help = @(
#         #     Get-Help $cmds -Examples
#         # )

#         # $whichExample =
#         #     $help

#         # # does not enforce loading
#         # $maybeModules? = @(
#         #     Get-Module -name $items
#         # )
#         # if($maybeModules?.count -lt $items.count) {
#         #     $Items
#         #         | Join-String -op 'Expected = ' -sep ', '-SingleQuote
#         #         | Join-String -op "Some modules were not loaded, Import them first if you wish to include them: `n"
#         #         | write-warning

#         #     $maybeModules? ?? '∅'
#         #         | Join-String -op 'Found: = ' -sep ', ' -SingleQuote
#         #         | write-verbose
#         # }
#         # $whichCommand =
#         #     $Items | Dotils.Random.Module -wa 'ignore' -ea 'ignore'
#         # gcm $items | Get-Help -Examples
#         # $whichModule =
#         #     $maybeModules?
#         #         | Get-Random -count 1
#         $cmds = @(
#             Get-Command -Module $whichModule
#             # $whichModule.ExportedCommands.Keys
#             # $whichModule.ExportedFunctions.Keys
#             # $whichModule.ExportedAliases.Keys
#             # $whichModule.ExportedCmdlets.Keys

#             # $whichModule | % ExportedCommands
#             )
#         | Sort-object -Unique

#         $cmds | Join-String -op 'FoundCommands: ' -sep ', ' -SingleQuote
#               | write-debug


#         $whichCmd =
#             $cmds | Get-Random -Count 1

#         if($whichCmd) { return $whichCmd }

# #         ( $someMod ??= Dotils.Random.Module )
# # $q = $someMod | Dotils.Random.Command -Verbose
#         if(-not $whichCmd) {
#             $errMsg =
#                 $ModuleName | Join-String -op "Failed selecting random Command! '$WhichModule'" -sep ', ' -SingleQuote
#             throw $errMsg
#         }
    }
}


function Dotils.Modulebuilder.Format-SummarizeCommandAliases {
    <#
    .SYNOPSIS
        Summarize Aliases used by amodule, formatted as a nin-style alias comment
    .NOTES
    desired output to summarize gci:

    Output:
        # 'Get-ChildItem' = { 'gci', 'ls', 'dir' }
    .example
        PS> Dotils.Modulebuilder.Format-SummarizeCommandAliases 'Get-ChildItem'
            | Should -BeExactly "# 'Get-ChildItem' = { 'dir', 'gci' }"
    .example

        Dotils.Module.Format-AliasesSummary -CommandDefinition (gcm 'Label' | % Definition)
    .example
        Dotils.Modulebuilder.Format-SummarizeCommandAliases 'Get-ChildItem'


        Dotils.Module.Format-AliasesSummary 'Get-ChildItem'
            | Should -BeExactly "# 'Get-ChildItem' = { 'dir', 'gci' }"
    #>
    # [Nin.NotYetImplemented('ArgumentTransformation, or PipeScript with TypeUnions, see NoMoreTangnent for the first example')]
    [Alias('Dotils.Module.Format-AliasesSummary')]
    [OutputType('System.String')]
    param(

        # currently just the defintion string
        [Parameter()]
        [Alias('Name', 'Definition')][string]$CommandDefinition,

        # accepts [CmdletInfo], [AliasInfo], etc...
        [Parameter()]
        [System.Management.Automation.CommandInfo]
        $InputObject


    )
@'
[Nin.NotYetImplemented('ArgumentTransformation, or PipeScript with TypeUnions, see NoMoreTangnent for the first example')]


to finish next: wrap this automaticallly

        Dotils.Module.Format-AliasesSummary -CommandDefinition (gcm 'Label' | % Definition)
either [1] regular argumenttransformatation
'@ | write-warning

    if($null -ne $InputObject) {
        throw 'Finish func, accept both types automagically.'
    }
    write-warning 'nyi; or requires confirmation; mark;'
    $target = $CommandDefinition
    $aList =
        Get-Alias -Definition $CommandDefinition

    [string]$render = ''

    $render +=
        $target
            | Join-String -SingleQuote -op '# ' -os ' = '

    $render +=
        $aList
            | Sort-Object -Unique
            | Join-String -sep ', ' -SingleQuote -op '{ ' -os ' }'

    $render
}

function Dotils.md.Write.Url {
    <#
    .SYNOPSIS
        Writes a standard markdown url with escaped title characters
    .LINK
        Dotils\md.Write.Url
    .LINK
        Dotils\md.Format.EscapeFilepath
    #>
    [Alias(
        'md.Write.Url')]
    [CmdletBinding()]
    param(
        # rquired label, and url
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $Url,

        [switch]$FileUProtocolURL
    )
    process {
        $EscapedLabel = $Text -replace '\(', '\(' -replace '\)', '\)' -replace '\[', '\[' -replace '\]', '\]'

        @(
            '[{0}]' -f @( $EscapedLabel )
            '({0})' -f @(
                $Url | Dotils.md.Format.EscapeFilepath -AndForwardSlash -UsingFileProtocol:$FileUProtocolURL
            )
        ) -join ''

    }
}

function Dotils.MkDir.Now {
    <#
    .SYNOPSIS
        create subdir with today's date, and enter it. Otherwise return as a string with -passthru
    #>
    param(
        # create subdir with today's date, else return as a string with -passthru
        [switch] $PassThru
    )
   $datePath = [datetime]::Now.ToString('yyyy-MM-dd')
   if( $PassThru ) { return $datePath }
   mkdir -Path $datePath
   pushd $datePath
}

function Dotils.md.Format.EscapeFilepath {
    <#
    .DESCRIPTION
        escapes spaces in filepaths, making relative urls clickable
    .NOTES
        naming, should maybe be format, not write, to be consistent with other commands
    .LINK
        Dotils\md.Write.Url
    .LINK
        Dotils\md.Format.EscapeFilepath
    .EXAMPLE
       PS>  'c:\foo bar\fast cat.png'
       c:\foo%20bar\fast%20cat.png
    .example
    in  [0]:$what = gi '.\web.js ⁞ sketch ⁞ 2023-08 - Copy.code-workspace'
            $what | 2md.Path.escapeSpace
    out [0]: H:\data\2023\web.js\web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace

    in  [1]: $what | 2md.Path.escapeSpace -AndForwardSlash
    out [1]: H:/data/2023/web.js/web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace

    in  [1]: $what | 2md.Path.escapeSpace -AndForwardSlash -UsingFileProtocol
    out [1]: <file:///H:/data/2023/web.js/web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace>

$what | md.Path.escapeSpace | cl
H:\data\2023\web.js\web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace
Pwsh 7.3.6> [8] 🐧

$what | md.Path.escapeSpace -AndForwardSlash
H:/data/2023/web.js/web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace
Pwsh 7.3.6> [8] 🐧

$what | md.Path.escapeSpace -AndForwardSlash -UsingFileProtocol
<file:///H:/data/2023/web.js/web.js%20⁞%20sketch%20⁞%202023-08%20-%20Copy.code-workspace>
    #>
    [Alias('md.Format.EscapeFilepath')]
    param(
        [switch]$AndForwardSlash,

        # this tends to render clickable links easier, by wrapping the url in
        #      <file:///$url>

        [Alias('LocalPath')]
        [switch]$UsingFileProtocol
    )
    process {
        $accum = $_ -replace ' ', '%20'
        if ($AndForwardSlash) {
            $accum = $accum -replace '\\', '/'
        }
        if($UsingFileProtocol) {
            $accum | Join-String -f '<file:///{0}>'
            return
        }
        return $accum
    }
}

function Dotils.Err.Clear {
    <#
    .SYNOPSIS
        sugar for using $global:error.clear()
    #>
    [Alias('ec')]
    param(
        [Alias('All')][switch]$Get
    )
    if($Get) {
        return $global:error
    }
    Err -Clear # should be global
}

function Dotils.Excel.Write.Sheet.Name {
    <#
    .example
        PS> $pkg.Workbook.Worksheets    | __render.Sheet.Name
        PS> $pkg.Workbook.Worksheets[2] | __render.Sheet.Name
    .example
        confirmed working:
            $Pkg.Workbook.Worksheets[3] | __render.Sheet.Name
            $Pkg.Workbook.Worksheets    | __render.Sheet.Name
            $Pkg.Workbook               | __render.Sheet.Name
            $Pkg                        | __render.Sheet.Name

    @ warning
        colors are not visible on VSCode terminal atm, not sure if that's config of bold or something else
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    begin {
        $c_dim1 = @{
            # ForegroundColor = 'gray50'
            ForegroundColor = 'gray60'
            BackgroundColor = 'gray15'
        }
        $c_dim2 = @{
            ForegroundColor = 'gray35'
            BackgroundColor = 'gray10'
        }
        $c_dim3 = @{
            ForegroundColor = 'gray15'
            BackgroundColor = 'gray10'
        }
        $c_default = @{
            ForegroundColor = 'gray85'
        }
        $c_orange = @{
            bg = [RgbColor]::FromRgb('#362b1f')
            fg = [RgbColor]::FromRgb('#f2962d')
        }
        function __write.Single {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory, ValueFromPipeline)]
                [object]$InputObject
            )
            process {
                $cur = $_
                $cur | Format-ShortTypeName | write-debug
                $color = switch($InputObject.Hidden) {
                    ([OfficeOpenXml.eWorkSheetHidden]::VeryHidden) {
                        $c_orange
                    }
                    ([OfficeOpenXml.eWorkSheetHidden]::Hidden) {
                        $c_dim1
                    }
                    default {
                        $c_default
                    }
                }
                $name = $cur.Name
                    | New-Text @color

                $num = $Cur.
                    Index.
                    ToString().
                    PadLeft(2, ' ')
                        | New-Text @c_dim2
                $name
                    # | Join-String -op "[$Num] "
                    | Join-String -op "$Num "
                    | Join-String -os $(
                        $Cur.TabColor
                            | New-Text @c_dim3
                    )
            }
        }
    }
    process {

        if($InputObject -is 'OfficeOpenXml.ExcelWorkbook'){
            $InputObject.WorkSheets | __write.Single
        } elseif($InputObject -is 'OfficeOpenXml.ExcelPackage'){
            $InputObject.Workbook.WorkSheets | __write.Single
        } else {
            $InputObject | __write.Single
        }
    }

}

function Dotils.Select-NameIsh {
    <#
    .SYNOPSIS
        Select propert-ish categories, wildcard searching for frequent kinds
    .NOTES
        todo: expand: abstract:
        todo: fun, add more kinds
    .EXAMPLE
        gi . | NameIsh Dates -IgnoreEmpty -SortFinalResult
    .EXAMPLE
        gi . | NameIsh Names|fl
        gi . | NameIsh Names -IncludeEmptyProperties |fl
    .LINK
        Dotils.Is.KindOf
    .link
        Dotils.Select-Namish
    #>
    [Alias(
        'Select.Namish', 'NameIsh' )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, position = 0)]
        [ArgumentCompletions(
            'Dates', 'Times',
            'Names', 'Employee', 'Company', 'Locations', 'Numbers',
            'IsA', 'HasA',

            'PrimativeTypes', # string, int, date, etc...

            'Type'
        )]
        [string[]]$Kinds,

        [Parameter(Mandatory, ValueFromPipeline)]$InputObject,


        # to be appended to kinds already filtered by $Kinds.
        # useful because you may not want '*id*' as a wildcard to be too aggressive
        # todo: dynamically auto gen based on hashtable declaration
        [ArgumentCompletions(
            '*id*', '*num*', '*co*', '*emp*'
        )]
        [string[]]$ExtraKinds,

        [Alias('IncludeEmptyProperties')][Parameter()]
        [switch]$KeepEmptyProperties,

        # is there any reason to?
        [switch]$WithoutUsingUnique,

        # sugar sort on property names
        [switch]$SortFinalResult

    )
    begin {
        $PropList = @{
            Names     = '*name*', '*user*', 'email', 'mail', 'author', '*author*'
            Employee  = '*employee*', '*emp*id*', '*emp*num*'
            Dates     = '*date*', '*time*', '*last*modif*', '*last*write*'
            Type      = '*typename*', '*type*', '*Type'
            Script    = '*Declaring*', '*method*', '*Declared*'
            Generic   = '*generic*', 'IsGeneric*', '*Interface*'
            AST = '*AST', '*Extent*', '*ScriptBlock*', '*Script*'
            IsA       = 'Is*'
            HasA      = 'HasA*', 'Has*'
            Bool      = '*True*', '*False*'
            Attribute = '*attr*', '*attribute*'
            File      = '*file*', '*name*', '*extension*', '*path*', '*directory*', '*folder*'
            Path      = '*Path*', 'FullName', 'Name'
            Company   = 'co', '*company*'
            Locations = '*zip*', '*state*', '*location*', '*city*', '*address*', '*email*', 'addr', '*phone*', '*cell*'
            Numbers   = 'id', '*num*', '*identifier*', '*identity*', '*GUID*'
        }
        $TypesList = @{
            # dynamic build from command:
            # Find-Type -Base ([System.Management.Automation.Language.Ast]) | sort Name
            Ast = @(
                'ArrayExpressionAst', 'ArrayLiteralAst', 'AssignmentStatementAst', 'AttributeAst', 'AttributeBaseAst',
                'AttributedExpressionAst', 'BaseCtorInvokeMemberExpressionAst', 'BinaryExpressionAst', 'BlockStatementAst',
                'BreakStatementAst', 'CatchClauseAst', 'ChainableAst', 'CommandAst', 'CommandBaseAst', 'CommandElementAst',
                'CommandExpressionAst', 'CommandParameterAst', 'ConfigurationDefinitionAst', 'ConstantExpressionAst',
                'ContinueStatementAst', 'ConvertExpressionAst', 'DataStatementAst', 'DoUntilStatementAst', 'DoWhileStatementAst',
                'DynamicKeywordStatementAst', 'ErrorExpressionAst', 'ErrorStatementAst', 'ExitStatementAst', 'ExpandableStringExpressionAst',
                'ExpressionAst', 'FileRedirectionAst', 'ForEachStatementAst', 'ForStatementAst', 'FunctionDefinitionAst',
                'FunctionMemberAst', 'HashtableAst', 'IfStatementAst', 'IndexExpressionAst', 'InvokeMemberExpressionAst',
                'LabeledStatementAst', 'LoopStatementAst', 'MemberAst', 'MemberExpressionAst', 'MergingRedirectionAst',
                'NamedAttributeArgumentAst', 'NamedBlockAst', 'ParamBlockAst', 'ParameterAst', 'ParenExpressionAst',
                'PipelineAst', 'PipelineBaseAst', 'PipelineChainAst', 'PropertyMemberAst', 'RedirectionAst',
                'ReturnStatementAst', 'ScriptBlockAst', 'ScriptBlockExpressionAst', 'StatementAst', 'StatementBlockAst', 'StringConstantExpressionAst', 'SubExpressionAst', 'SwitchStatementAst', 'TernaryExpressionAst',
                'ThrowStatementAst', 'TrapStatementAst', 'TryStatementAst', 'TypeConstraintAst', 'TypeDefinitionAst', 'TypeExpressionAst', 'UnaryExpressionAst', 'UsingExpressionAst', 'UsingStatementAst', 'VariableExpressionAst', 'WhileStatementAst'
            )
            Primitive = @(
                'int\d+', 'int', 'string', 'double', 'float', 'bool'
            )
        }

        [Collections.Generic.List[Object]]$Names = @()

        foreach ($Key in $Kinds) {
            if ($key -notin $PropList.Keys) {
                throw "Missing Defined NameIsh Group Key Name: '$key'"
            }
            $PropNameList = $PropList.$Key
            $Names.AddRange( $PropNameList )
        }
        if ($ExtraKinds) {
            $Names.AddRange(@( $ExtraKinds ))
        }

        $Names | Join-String -sep ', ' -single -op 'AllNames: '
        | Write-Debug

        if (-not $WithoutUsingUnique) {
            $Names = $Names | Sort-Object -Unique
        }
        $Names | Join-String -sep ', ' -single -op 'IncludeNames: '
        | Write-Verbose

        if ($IgnoreEmpty) {
            Write-Warning 'IgnoreEmpty: NYI'
        }
    }
    process {
        $query_splat = @{
            Property    = $Names
            ErrorAction = 'ignore'
        }
        $query = $InputObject | Select-Object @query_splat
        if ($KeepEmptyProperties) {
            return $query
        }

        [string[]]$emptyPropNames = $query.PSObject.Properties
        | Where-Object { [string]::IsNullOrWhiteSpace( $_.Value ) }
        | ForEach-Object Name

        $emptyPropNames | Join-String -op 'empty: ' -sep ', ' -DoubleQuote | Write-Debug

        $dropEmpty_splat = @{
            ErrorAction     = 'ignore'
            ExcludeProperty = $emptyPropNames
        }
        return $query | Select-Object @dropEmpty_splat
    }
    end {
        if ($SortFinalResult) {
            'nyi: becauseSortFinalResult must occur after select-object is finished, else, cant know what properties the wildcards will add'
            | Write-Warning
        }
    }
}

function Dotils.Select-TemporalFirstObject {
    <#
    .SYNOPSIS
    this is the temporal analog to 'Out-Host -Paging', because it does not kill your results, it saves what it can
     .NOTES
        requires no scriptblock parameter

        exit strategy: as Error or?
        future:
        - [ ]
    .example
        0..10 | WriteEveryN -CountStepSize 4 | OutNull
    .example
        0..10 | %{ Sleep -ms 10 } | WriteEveryN -DelayMS 30 | OutNull
    .EXAMPLE
        $res = 0..5 | %{ sleep -ms 10 ; $_ ; } | WriteEveryN -CountStepSize 3
    .LINK
        Dotils.Write-CountOf
    #>
    # [RelatedCommandsAttributeNYI('Dotils.Select-TemporalFirstObject', 'WriteEveryN')]
    [Alias('.Select.FirstTime')]
    [CmdletBinding()]
    param(
        # pass through items
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # default 2 seconds
        [Parameter(Mandatory, Position=0)]
        [Alias('TimeMS', 'Ms', 'Delay', 'Milliseconds')]
        [int]$DelayMS = 2000,

        # [Parameter(Mandatory, Position=0, ParameterSetName = 'ByIterationCount')]
        # [Alias('IterCount')]
        # [int]$CountStepSize, # = 1000,

        [Alias('InPlace')]
        [switch]$AlwaysWriteInPlace,
        # global to write to
        [Parameter(Position=1)]
        [Alias('Var')][string]$WriteToVariableName = 'dotilsTimeoutList',

        # throw or nice quit?
        [Alias('ErrorOnTimeout')]
        [switch]$AsError,

        [hashtable]$Options
    )
    begin {
        [bool]$isRunning = $true
        [datetime]$time_commandStart = [datetime]::Now

        $Config = mergeHashtable -OtherHash ($Options ?? @{}) -BaseHash @{
            # WriteInPlace = $false
            # SummaryTableWriteInfoAtEnd = $true
            # UpdateIncludesTotalElapsed = $true
        }
        [Collections.Generic.List[Object]]$items = @()

    }
    process {
        $time_now = [datetime]::Now
        # $delta = $time_now - $time_commandStart
        # foreach($curObj in $InputObject){
        #     $items.add( $curObj ) # do I even need one? no?
        #     $curObj
        # }
        # if( $WriteToVariableName ) {
        #     # $global:$VariableName = $Items
        #     Set-Variable -Name $VariableName -value $items -Scope Global -Description 'global value from Dotils.Select-FirstTime' # do I even need one? no?
        # }
        if(-not $IsRunning) {  return  }

        foreach($curObj in $InputObject){
            $items.Add($curObj)
            $curObj
        }
        $delta = $time_now - $time_commandStart
        if($delta.TotalMilliseconds -gt $DelayMS) {
            $delta | Ms | Write-Host -back 'darkgreen'
            Set-Variable -name $WriteToVariableName -scope 'global' -value $items
            # Set-Variable -Name $VariableName -value $items -Scope Global -Description 'global value from Dotils.Select-FirstTime'
            $isRunning = $false

            $errMsg = 'CommandTookTooLongException! {{ Delay: {0}, Elapsed: {1} }}' -f @(
                $DelayMS | Ms
                $delta | Ms
            )
            if( $AsError ) {
                throw $errMsg
            } else {
                write-error $errMsg
                return
            }
        }
        # $Obj
    }
    end {
    }
}

function Dotils.Linq.CountLines {
    <#
    .SYNOPSIS
        count number of lines in file, faster than naive
    #>
    Param(
        [Alias('PSPath', 'FullName', 'Name')]
        [Parameter(Mandatory)]
        [string]$Path
    )
    [Linq.Enumerable]::Count([IO.File]::ReadLines($Path))
}

function Dotils.Write-StatusEveryN {
    <#
    .synopsis
        emit object as normal, in addition either [a] write every N iterations, or [b] write every X Milliseconds
    .NOTES
        future:
        - [ ] automatically turn into write-progress if wanted
        - [ ] console output that erases/replaces self
    .example
        0..10 | WriteEveryN -CountStepSize 4 | OutNull
    .example
        0..10 | %{ Sleep -ms 10 } | WriteEveryN -DelayMS 30 | OutNull
    .EXAMPLE
        $res = 0..5 | %{ sleep -ms 10 ; $_ ; } | WriteEveryN -CountStepSize 3
    .LINK
        Dotils.Write-CountOf
    #>
    [Alias(
        'WriteEveryN',
        'Write-Status.EveryN',
        'Write-EveryStatus',
        '.status.EveryN'
    )]
    [CmdletBinding(DefaultParameterSetName = 'ByDelayCount')]
    param(
        # pass through items
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [Parameter(Mandatory, Position=0, ParameterSetName = 'ByDelayCount')]
        [Alias('TimeMS', 'Ms', 'Delay', 'Milliseconds')]
        [int]$DelayMS = 500,

        [Parameter(Mandatory, Position=0, ParameterSetName = 'ByIterationCount')]
        [Alias('IterCount')]
        [int]$CountStepSize, # = 1000,

        [Alias('InPlace')]
        [switch]$AlwaysWriteInPlace,

        [hashtable]$Options
    )
    begin {
        [bool]$isUsingTimer = $CountStepSize -le 0
        [int]$curCount = 0
        [datetime]$time_commandStart = [datetime]::Now
        [datetime]$time_prevWrite = $time_commandStart

        $Config = mergeHashtable -OtherHash ($Options ?? @{}) -BaseHash @{
            WriteInPlace = $false
            SummaryTableWriteInfoAtEnd = $true
            UpdateIncludesTotalElapsed = $true
        }

    }
    process {
        if($Config.WriteInPlace) { throw 'nyi: write in place' }
        $Obj = $InputObject
        $curCount++
        # double check I think the time is fixed

        if( -not $isUsingTimer -and -not $Config.UpdateIncludesTotalElapsed) {
            if($curCount % $CountStepSize -eq 0) {
                Write-Host "   ...iter ${curCount}" -fg 'gray30'
            }
        } else {
            $time_now = [datetime]::Now
            $delta = $time_now - $time_prevWrite
            if($delta.TotalMilliseconds -gt $DelayMS) {
                $delta
                    | Ms | Join-String -f  "   ...{0}"
                    | Write-Host -fg 'gray30' -NoNewline

                $time_commandStart - $time_now
                    | Ms | Join-String -f  "   ...{0}"
                    | Write-Host -fg 'gray30' -NoNewline
                Write-Host ''
                $time_prevWrite = $time_now
            }
        }
        $Obj
    }
    end {
        $time_commandEnd = [datetime]::Now
        $time_delta = $time_commandEnd - $time_commandStart

        if($Config.SummaryTableWriteInfoAtEnd) {
            @{
                Start = $time_commandStart
                End = $time_commandEnd
                Duration = $time_delta
                TotalSeconds = $time_delta | Sec # future: should be a formatter not string
                TotalMilliSeconds = $time_delta | Ms # future: should be a formatter not string
            } | ft -AutoSize | Out-String | Write-Information -infa 'continue'
        }
    }
}


function Dotils.PSDefaultParameters.ToggleAllVerbose {
    <#
    .SYNOPSIS
        enables verbosity on all functions
    #>
    param( [string]$ModuleName, [switch]$EnableVerbose, [switch]$DisableAll )

    <#
    note: GCM requires a different kind of crawl that using get module, gcm does other work#>
    if($false) { # define all props, and set ot false}
        get-module jumpcloud -ListAvailable
        | % ExportedCommands
        | % GetEnumerator
        | % Key | Sort -Unique
        | % {
            $Key = '{0}:Verbose' -f $_
            # $PSDefaultParameterValues[ $Key ] = -not $global:BdgPerf.MinVerbosity
            $PSDefaultParameterValues[ $Key ] = $false
        }

    }
    # or use Gcm, which is a different list, slower IIRC

    Gcm -m $ModuleName
    | CountOf | %{
        $Key = $_.Name | Join-String -f "{0}:Verbose"
        if($EnableVerbose) {
            $PSDefaultParameterValues[ $Key ] = $EnableVerbose
        }
        if($DisableAll) {
            $PSDefaultParameterValues.Remove('ColumnChart:verbose')
        }
    }
}

function Dotils.Describe.Timespan.AsSeconds {
    <#
    .SYNOPSIS
        render units automatically using the right properties and format for user UX
    .example
        [datetime]::Now.AddMilliseconds(1234) - (get-date)
            | Ms

        #output: 1,232.97 ms
    #>
    [OutputType('String')]
    [Alias('Sec', '.Render.Sec')]
    param()
    process {
        $Obj = $_
        [string]$render = ''
        if($Obj -is 'int') {
            $render = $Obj | Join-String -f '{0:n2} sec'
        } else {
            $render = $Obj | Dotils.ConvertTo.TimeSpan
                | Join-String -f '{0:n2} sec' TotalSeconds
        }
        if($render -match '0\.00\b\s+sec') {
            write-verbose 'possible lost precision rounding from a non-zero'
        }
        return $render
            # $Obj -as [timespan] } else { $null }
    }
}

function Dotils.DebugUtil.Format.AliasSummaryLiteral {
    param(
        [Parameter(Mandatory, Position= 0 )]
        [string]$FunctionName,

        [Parameter(Mandatory, Position= 1 )]
        [string[]]$AliasNames
    )

    $suffix = Join-String -sep ', ' -single -inp $AliasNames  #| Join-String -f " = {{ {0} }}"
    $prefix = Join-String -single -inp $FunctionName
    $finalSuffix = "$prefix = { $suffix }"

    # commands
        "$prefix # $FinalSuffix"
    @(foreach($aName in $AliasNames) {
            "'$aName' # $finalSuffix"
        }) | Sort-Object -unique
}


function Dotils.Get-Item.FromClipboard {
    <#
    .SYNOPSIS
        sugar for resolving path as an object from the paste
    .EXAMPLE
        # normal usage. Goto flag saves you one step:
        Pwsh> Gcl.Gi -GotoFolder
        Pwsh> Gcl.Gi | Goto

        # or
        Pwsh> $JsonPath = Gcl.Gi
    .EXAMPLE
        Pwsh> 'C:\Users\cppmo_000\AppData\Local\Microsoft\Windows' | Set-Clipboard

        Pwsh> Gcl.Gi
        # prints: gi =: C:\Users\cppmo_000\AppData\Local\Microsoft\Windows
    .EXAMPLE
        Pwsh> # error terminates pipeline if not valid path
        Gcl.Gi | Goto

        Pwsh> # error terminates pipeline if not valid path
        Dotils.get-Item.FromClipboard | %{ Test-Path $_ }
    #>
    [Alias('Gcl.GetItem', 'Gcl.Gi')]
    [OutputType('System.IO.FileSystemInfo')]
    param(
        [Alias('AutoPushD', 'Pushd')]
        [switch]$GotoFolder
    )
    $target =  Get-Clipboard
    if( -not (Test-Path $Target)) {
        $maybe_target = $target -replace '^[''"]', '' -replace '[''"]$', ''
        if(test-Path $maybe_target) {
            $target = $maybe_target
            write-verbose 'found valid, quoted path. cleaning...'
        }
    }
    $global:gi  = $target | Get-Item -ea 'stop'
    $target | write-verbose

    # write console, but also return GI as well
    $global:gi ?? "`u{2400}"
        | Dotils.Format.Write-DimText
        | Join-String -op 'gi =: '
        | wInfo

    if(Test-Path $global:gi) {
        if($GotoFolder) {
            $global:gi  | Ninmonkey.Console\Set-NinLocation
        }
    } else {
        'path is not valid: {0}' -f @( $Global:gi ?? "`u{2400}" )
            | write-error
        return
    }
    return $global:gi
}


[Collections.Generic.HashSet[string]]$script:___warnHistoryLog ??= @() # used by: function:\Dotils.Write.WarnOnce
$script:__warnLogPath = Join-Path 'temp:' 'Dotils.WarnOnce.log' # used by: function:\Dotils.Write.WarnOnce
function Dotils.Write.WarnOnce {
    <#
    .synopsis
        writes log message first time, optionally to the console. It is a no-op the rest of the time
    .example
        # run twice, and it will only log or print messages one time (in the current session)

        > Quick.WarnOnce 'missing date calculation'
        > Quick.WarnOnce 'missing date calculation'
    .EXAMPLE
        # auto open the log in vs code, to the newest record (the bottom of the file)
        > Quick.WarnOnce -OpenLog
    .example
        # you can include extra data in the log ( as json )
        > Quick.WarnOnce 'stuff first try' -Details @{ 'species' = 'cat' }
    .example
        # -ResetHistory: this *always* writes a warning
        > Quick.WarnOnce 'missing date calculation' -ResetHistory
        > Quick.WarnOnce 'missing date calculation' -ResetHistory

    .notes
        so far performance is fast. Uses the callstack but only on the very first invoke
        future invokes are set containment test then an immediate exit
    #>
    [Alias('Quick.WarnOnce')]
    # [DocumentUsesScriptScopeNamed('__warnHistoryLog', '__warnLogPath')]
    [CmdletBinding( DefaultParameterSetName = 'UsingWarn' )]
    param(
        # what to print, saves inner dat
        [Parameter(ValueFromPipeline, Position = 0, ParameterSetName='UsingWarn', Mandatory)]
        [string]$Message,

        # optional context ata
        [Parameter( ParameterSetName = 'UsingWarn' )]
        [Alias('TargetObject')]
        [object]$Details = $Null,

        # also write to the host? otherwise it just writes to the log
        [Parameter( ParameterSetName = 'UsingWarn' )]
        [Alias('PSHost')]
        [switch]$WriteHost,

        [Parameter( ParameterSetName = 'UsingWarn' )]
        [Alias('FlushHistory', 'Force', 'Always')]
        [switch]$ResetHistory,

        # Opens log in vs code, writes nothing.
        [Parameter(ParameterSetName='OpenOnly')]
        [switch]$OpenLog
    )
    process {
        $State  = $script:___warnHistoryLog
        if( $ResetHistory ) {
            $state.Clear()
        }

        if($OpenLog) {
            $File = Get-Item -ea 'stop' $__warnLogPath
            $GotoPath = Join-String -f '{0}:99999999' -InputObject $File.FullName
            code --goto $GotoPath
            return
        }

        if( $state.Contains( $Message )) {
            'Message Already exists' | Write-debug
            return }

        [void] $State.Add( $Message )


        $StackInfo = Get-PSCallStack

        $data = @{
            PwshPid            = $PID
            PSScriptRoot       = $PSScriptRoot  ?  $PSScriptRoot.ToString() : 'null'
            PSCommandPath      = $PSCommandPath ? $PSCommandPath.ToString() : 'null'
            Message            = $Message
            FromFile           = ($StackInfo)?[0].ScriptName ?? $Null
            FromLineNumber     = ($StackInfo)?[0].ScriptLineNumber
            FromLocationString = ($StackInfo)?[0]?.GetScriptLocation()
            FromCommand        = ($StackInfo)?[0].Command
            FromFunctionName   = ($StackInfo)?[0].FunctionName
        }
        if($Details) {
            $data.Details = $Details # or target object?
        }
        if($False) { #script extent, flatten props
            $Data.FromScriptExtent = ($stacky)?[0].Position |Json -Depth 1  | Json.From
        }
        $Json      = $Data | ConvertTo-Json -Depth 2
        $PrePrefix = Join-String -f 'nin.WarnOnce {0}:' -In $pid
        $Prefix    = "${PrePrefix} {0}: " -f [DateTime]::now.ToString('yyyy-MM-dd')
        $rendJson  = $Json
            | Join-String -op $Prefix

        $rendJson
            | Add-Content -LiteralPath $script:__warnLogPath
        'wrote: {0}' -f $script:__warnLogPath
            | write-verbose

        if( $Writehost ) {
            # $RendJson  # this was too much info
            @(
                $Message
                if( $Details ) { $Json } )
            | Join-String -sep ' '
            | Write-Host -fg 'gray80' -bg 'gray30'

            # 'wrote: <file:///{0}>' -f ( $script:__warnLogPath |  Get-Item )
            #     | Write-information -infa 'continue'
        }
    }
}
function Dotils.Accumulate.Hashtables {
    <#
    .SYNOPSIS
        accumulate hashtables
    .example
        # default usage starts with a base hash, then  merges all tables from the pipeline

        @{ blue = 99 } | dtil.Accum.Hash -BaseHash @{ blue = '33' }
    .example
        # You can omit -BaseHash, and it'll accumulate off a new blank table
        @{ blue = 99 ; name = 'jen' } | dtil.Accum.Hash
    .EXAMPLE
        # no bash hash, all InputObject
        dtil.Accum.Hash -InputObject @(
            @{ red = 3 } ; @{ orange = 99 }; @{ red = 'red' } )
    .EXAMPLE
        # pipe to base
            @( @{ red = 3 } ; @{ orange = 99 }; @{ red = 'red' } )
                | dtil.Accum.Hash

            @( @{ red = 3 } ; @{ orange = 99 }; @{ red = 'red' } )
                | dtil.Accum.Hash
    #>
    [Alias(
        'Dotils.Accum.Hash', 'nin.Accum.Hash'
    )]
    param(
        # list of hashes to merge. assumes list of hashtables
        [Alias('HashList')]
        [Parameter(ValueFromPipeline, Mandatory)]
        [Object[]]$InputObject = @{},

        # base hash, if not a new one is created at the start of the pipeline
        [Alias('PrependHash', 'InputPrefix', 'Prefix', 'HeadHash')]
        [Parameter()]
        [hashtable]$BaseHash,

        # sort of like baseHash, except, merge as the final item.
        # sugar for declaring more messy pipelines
        [Alias('AppendHash', 'OutputSuffix', 'Suffix', 'Tail')]
        [Parameter()]
        [hashtable]$TailHash,
        # later: allow mutating original
        # [Alias('Mutate')][switch]$WriteToOriginal
        [ValidateScript({throw 'nyi'})]
        [switch]$WithoutOrdered,

        [ValidateScript({throw 'nyi'})]
        [switch]$SortAlpha = $false,

        # set arbitrary config using kwargs-style options.
        # for semantics, externally it is passed as '$options'
        # however, internally it's treated essentially as read-only.
        # all access uses '$Config' or '$default'
        [hashtable]$Options,


        # [System.StringComparer]
        # [System.StringComparison]
        # [System.StringComparison]
        # [StringComparer]
        [Parameter()]
        # [IComparer]
        [string]
        [ArgumentCompletions(
            # to rebuild, run: [StringComparer] | fime -MemberType Property | % Name | sort -Unique | join-string -sep ",`n" -SingleQuote
            # todo: make re-usable string comparer transformation attribute, if PSRL doesn't already do it
            'InvariantCulture',
            'InvariantCultureIgnoreCase',
            'CurrentCulture',
            'CurrentCultureIgnoreCase',
            'Ordinal',
            'OrdinalIgnoreCase'
        )]
        $ComparerType = 'CurrentCultureIgnoreCase'
            # [StringComparer]::CurrentCultureIgnoreCase
    )
    begin {
        <#
        #>
        # $testCompare = [StringComparer]::FromComparison(
        #     [StringComparison]::OrdinalIgnoreCase ) # -is [OrdinalIgnoreCaseComparer : OrdinalComparer : IComparer]


        $Defaults = @{}
        [hashtable]$Config = nin.MergeHash -OtherHash $Options -BaseHash $Defaults -ComparerKind $ComparerType # -CompareAs $ComparerType

        $mergeCount = 0
        $nestedDepthCount = 0
        $NonDistinctKeyCount = 0


        if( $null -ne $BaseHash ) {
            $NonDistinctKeyCount += $baseHash.Keys.Count
            $mergeCount++
        }
        $baseHash ??= [ordered]@{}
        $accum = $BaseHash
    }
    process {
        foreach( $hash in $InputObject ) {
            $mergeCount++
            $NonDistinctKeyCount += $hash.Keys.Count
            $accum = nin.MergeHash -BaseHash $accum -OtherHash $hash -ComparerKind $ComparerType
        }
        # foreach( $hash in $InputObject.GetEnumerator()) {
        #     $Name = $hash.key
        #     $Obj = $hash.Value

        #     $accum = nin.MergeHash -BaseHash $accum -OtherHash $Obj
        #     $mergeCount++
        # }
    }
    end {

        'final hash has {0} keys across {1} merges from {2} parsed keys ( nestedDepth: {3} )' -f @(
            $accum.keys.count
            $mergeCount
            $NonDistinctKeyCount
            $nestedDepthCount
        )
            | Dotils.Write-DimText | wInfo
        $accum
    }
}


function Dotils.Toast.InvokeAlarm {
    <#
    .NOTES
        # See types:
        > find-type '*toast*' -Base enum
    #>
    [Alias('Quick.ToastAlarm')]
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [Alias('OutputMode')]
        [ValidateSet(
            'Repeat.Loud',
            'Repeat.Silent'
        )]
        [string]$TemplateName = 'Repeat.Loud',

        [Parameter(Position=1)]
        [Alias('Cooldown', 'Secs', 'Delay', 'WaitSeconds', 'SleepSecs')]
        [ArgumentCompletions(
            30, 60, 90,
            "(60 * 7.5) <# 7.5min #>",
            "(60 * 15)",
            "(60 * 3.5)"
        )]
        [int]$SleepInSeconds = (60 * 10),

        # grab names, even if it's static-inline names without the type defintion
        [Parameter(Position=2)]
        [ArgumentCompletions(
            'Alarm', 'Alarm10', 'Alarm2', 'Alarm3', 'Alarm4', 'Alarm5', 'Alarm6', 'Alarm7', 'Alarm8', 'Alarm9', 'Call', 'Call10', 'Call2', 'Call3', 'Call4', 'Call5', 'Call6', 'Call7', 'Call8', 'Call9', 'Default', 'IM', 'Mail', 'Reminder', 'SMS'
        )]
        [string]$AlarmSound = 'Alarm'
    )
    $PSBoundParameters | Json -Compress
        | Join-String -op 'Toast.InvokeAlarm := '
        | write-verbose -Verbose


    while($true) {
        switch($TemplateName) {
            'Repeat.Loud' {
                New-BurntToastNotification -Text 'work' -Sound $AlarmSound
                get-date | Dotils.Write-DimText | Infa
                sleep -Seconds $SleepInSeconds
            }
            'Repeat.Silent' {
                New-BurntToastNotification -Text 'work' -Silent
                get-date | Dotils.Write-DimText | Infa
                sleep -Seconds $SleepInSeconds
            }
            default {
                throw "UnhandledParamset: $TemplateName"
            }
        }
    }
}


function Dotils.Jekyll.InvokeBuild {
    <#
    .SYNOPSIS
        quick build Jeykyll templates in root
    .link
        https://jekyllrb.com/docs/
    .link
        https://jekyllrb.com/docs/usage/
    .link
        https://jekyllrb.com/docs/step-by-step/10-deployment/
    .DESCRIPTION
        see .notes for more
    .example
        # First, preview the command built:
        Pwsh> Quick.Jekyll -WhatIf -Watch -LiveReload:$false -NoServe:$true -IncrementalBuild:$false -Port 3001

        # out: Invoke bundle: args := exec jekyll http://localhost --watch 3001

    .notes

        Pwsh> jekyll help

        jekyll <subcommand> [options]
        Options:
                -s, --source [DIR]  Source directory (defaults to ./)
                -d, --destination [DIR]  Destination directory (defaults to ./_site)
                    --safe         Safe mode (defaults to false)
                -p, --plugins PLUGINS_DIR1[,PLUGINS_DIR2[,...]]  Plugins directory (defaults to ./_plugins)
                    --layouts DIR  Layouts directory (defaults to ./_layouts)
                    --profile      Generate a Liquid rendering profile
                -h, --help         Show this message
                -v, --version      Print the name and version
                -t, --trace        Show the full backtrace when an error occurs

        Subcommands:
        compose
        docs
        import
        build, b              Build your site
        clean                 Clean the site (removes site output and metadata file) without building.
        doctor, hyde          Search site and print specific deprecation warnings
        help                  Show the help message, optionally for a given subcommand.
        new                   Creates a new Jekyll site scaffold in PATH
        new-theme             Creates a new Jekyll theme scaffold
        serve, server, s      Serve your site locally
    jekyll help build


    Pwsh> Jeykll help build

        Usage:

        jekyll build [options]

        Options:
                    --config CONFIG_FILE[,CONFIG_FILE2,...]  Custom configuration file
                -d, --destination DESTINATION  The current folder will be generated into DESTINATION
                -s, --source SOURCE  Custom source directory
                    --future       Publishes posts with a future date
                    --limit_posts MAX_POSTS  Limits the number of posts to parse and publish
                -w, --[no-]watch   Watch for changes and rebuild
                -b, --baseurl URL  Serve the website from the given base URL
                    --force_polling  Force watch to use polling
                    --lsi          Use LSI for improved related posts
                -D, --drafts       Render posts in the _drafts folder
                    --unpublished  Render posts that were marked as unpublished
                    --disable-disk-cache  Disable caching to disk in non-safe mode
                -q, --quiet        Silence output.
                -V, --verbose      Print verbose output.
                -I, --incremental  Enable incremental rebuild.
                    --strict_front_matter  Fail if errors are present in front matter
                -s, --source [DIR]  Source directory (defaults to ./)
                -d, --destination [DIR]  Destination directory (defaults to ./_site)
                    --safe         Safe mode (defaults to false)
                -p, --plugins PLUGINS_DIR1[,PLUGINS_DIR2[,...]]  Plugins directory (defaults to ./_plugins)
                    --layouts DIR  Layouts directory (defaults to ./_layouts)
                    --profile      Generate a Liquid rendering profile
                -h, --help         Show this message
                -v, --version      Print the name and version
                -t, --trace        Show the full backtrace when an error occurs
    #>
    [Alias('Quick.Jekyll')]
    [CmdletBinding()]
    param(

        [ValidateScript({throw 'nyi'})]
        [string] $Config,
        [ValidateScript({throw 'nyi'})]

        [string] $Destination = './_site',

        [ValidateScript({throw 'nyi'})]
        [string] $Source = './',

        [ValidateScript({throw 'nyi'})]
        [string] $LayoutsPath = './_layouts',

        [Alias('NoAutoBuildOnChanges')]
        [switch] $NoWatchForChanges, # jekyyl auto compiles on changes

        [switch] $Clean,
        [switch] $NoServe,
        [switch] $IncrementalBuild, # Enable incremental rebuild

        [switch] $LiveReload, # in

        [ArgumentCompletions(4001, 3001)]
        [int] $Port = 3001,

        [alias('WhatIf')][switch] $TestArgBuilderOnly,

        [Alias('Help')][switch] $ShowHelp,

        [switch] $FullBacktraceOnError,
        [switch] $VerboseBuild,

        [Alias('UrlRoot')]
        [ArgumentCompletions('http://localhost')]
        [string] $BaseUrl = 'http://localhost',

        [Alias('Quiet')]
        [switch] $Silent
    )
    write-verbose 'or try: "bundle exec jekyll serve <# --livereload #> --watch 4001 http://localhost --incremental"' -Verbose

    $BinBundle = get-command -Name 'bundle' -CommandType Application -TotalCount 1 -ea 'stop'

    [List[Object]] $BinArgs = @(
        'exec'
        'jekyll'
        <#
             # which is cleaner to read?
            if ( -not $NoServe ) { 'serve'}
            $NoServe ? $null : 'serve'
            $NoServe ?
                $null : 'serve'

        #>
        if( -not $NoServe ) { 'serve' }
        # -not $NoServe ? 'serve' : $null
        $LiveReload ? '--livereload' : $Null

        # if( $Watch.IsPresent -or $LiveReload.IsPresent ) { '--watch', $Port }
        # for now always
        if( -not $NoWatchForChanges ) { '--watch' }
        if( $Port ) { $Port }

        if ( $BaseUrl ) { '--baseurl', $BaseUrl}


        if( $IncrementalBuild ) { '--incremental' }
        if( $VerboseBuild ) { '--verbose' }
        if( $Silent ) { '--quiet' }

        # if( $Watch.IsPresent -or $LiveReload.IsPresent ) { '--watch', $Port }
        # 'jekyll'
        # 'serve' <# --livereload #> --watch 4001 http://localhost <# --incremental #>
        # bundle exec jekyll serve <# --livereload #> --watch 4001 http://localhost <# --incremental #>
        if( $FullBacktraceOnError ) {  '--trace' }
    )

    if( $TestArgBuilderOnly) {
        $binArgs | Join-String -op 'invoke bundle: args := ' -sep ' ' | Write-host -fg '#b2cd9b'
        return
    }
    if( $Clean ) { # // what if?
        & $binBundle @('clean')
        return
    }
    if ( $ShowHelp ) {
        & $binBundle @('jekyll help build')
        & $binBundle @('jekyll help')
        return
    }
    $binArgs | Join-String -op 'invoke bundle: args := ' -sep ' ' | Write-host -fg '#b2cd9b'
    & $BinBundle @BinArgs
}
function Dotils.Quick.Fd.FindPipescript {
    <#
    .SYNOPSIS
        find all files that are specifically pipescript
    #>
    [Alias('Quick.Fd.GetPipescript', 'Quick.Fd.IsPipescript')]
    [cmdletbinding()]
    param(
        # root path or '.'
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('BaseFolder', 'RootFolder', 'Path', 'PSPath')]
        [object] $BaseSearchPath,

        # use fd recency dates
        [ArgumentCompletions('30minutes', '2hours', '8hours', '7days', '3months', '2years')]
        [string]$ChangedWithin
    )
    if( [string]::IsNullOrWhiteSpace($Path) ) { $Path = gi '.' }
    $regex_IsPipescript = '(?i)\.ps\.[^.]+$' # force insensitive, basically find: "*.ps.*"

    [List[Object]]$FdArgs = @(
        $regex_IsPipescript
        '--search-path', $Path
        if( $ChangedWithin ) { '--changed-within', $ChangedWithin }
    )
    $FdArgs | Join-String -op 'Invoke bin Fd => ' -sep ' '  | Write-verbose
    & fd @fdArgs
}
function Dotils.Quick.EverythingSearch {
    <#
    .synopsis
        just remember a few EverythingSearch base queries
    #>
    [Alias('Quick.Es')]
    [cmdletBinding()]
    param(
        [ArgumentCompletions(
            'Template.yml' )]
        [string]$TemplateName,

        # 'nyi: [ ] parameter that runs a regex against the query string, rather than the TemplateName'
        # [ValidateScript({throw 'nyi'})]
        [string]$QueryPattern,

        # if no params, return the mapping dict. if params, return the string rather than invoking StartEverything
        [switch]$PassThru
        # [switch]$PassThru
    )
    write-warning 'todo: [ ] make autocomplete use hashtable, and preview using tooltip (and render using preview of replace "\s{3,}", "\n")'
    write-warning 'todo: [ ] add a new -QueryPattern parameter that runs a regex against the query string, rather than the TemplateName'
    write-warning 'todo: nyi: If regex matches exactly 1, then use it. after step1 which is exactly equal, because that otherwise could be a regex match if not priority'
    $Mappings = [ordered]@{

        'SpeedDial.Projects' = 'ext:code-workspace dm:last27days !Env.AppData:'
        'SpeedDial.FancyMain' = 'ext:code-workspace ext:code-workspace;pbix;pq;ps1;psm1 dm:last29days ( ( ext:code-workspace;launch.json;pbix;ps1;psm1 dm:last7weeks  !path:ww:history | ( path:ww:".vscode" !path:ww:%AppData\Code" !path:ww:"%UserProfile%\.vscode" )  | ( ext:vhd;vhdx ) | ( dm:last5minutes ext:log )      ) ( !path:"%UserProfile%\.vscode" )        '

        'Book.History.0' = 'ext:code-workspace ext:code-workspace;pbix;pq;ps1;psm1 dm:last29days ( ( ext:code-workspace;launch.json;pbix;ps1;psm1 dm:last7weeks  !path:ww:history | ( path:ww:".vscode" !path:ww:%AppData\Code" !path:ww:"%UserProfile%\.vscode" )  | ( ext:vhd;vhdx ) | ( dm:last5minutes ext:log )      ) ( !path:"%UserProfile%\.vscode" )        '
        'Last.Aws1' = 'ext:code-workspace dm:last27days !Env.AppData:'
        'Last.Aws2' = 'dm:last1months root_entry_part1.ps1 content:"Paylo-GetNewIdentity"            !path:".aws-sam"'

        'Last.Aws3' = 'dm:last1months root_entry_part1.ps1 content:"Paylo-GetNewIdentity"            !path:".aws-sam"'
        'Last.Aws4' = 'dm:last2years ext:yml ( file:ww:"template.yml" ) '

        'Last0' = 'ext:code-workspace dm:last9000minutes ( ( my_roots: ) | ( path:ww:"H:\data\client_bdg\2023.03.17-bdg" ) )'
        'Last1' = 'ext:code-workspace dm:last3weeks !Env.UserProfile:'
        'Last2' = 'ext:psm1;ps1 !Env.AppData: *aws*utils*               !path:*gitlogg*         !path:ww:.aws-sam'
        'Last3' = '( dm:last22hours ext:code-workspace;ps1;py;psm1;md; ) | ( dm:last3weeks ext:code-workspace  ( my_roots: )                ) !path:"%AppData%" !path:"%userprofile%" ext:ps1 "*entry*1*"'
        'Last4' = 'ext:code-workspace ext:code-workspace;pbix;pq;ps1;psm1 dm:last29days ( ( ext:code-workspace;launch.json;pbix;ps1;psm1 dm:last7weeks  !path:ww:history | ( path:ww:".vscode" !path:ww:%AppData\Code" !path:ww:"%UserProfile%\.vscode" )  | ( ext:vhd;vhdx ) | ( dm:last5minutes ext:log )      ) ( !path:"%UserProfile%\.vscode" )       '
        'Last5' = 'ext:code-workspace dm:last3weeks !Env.UserProfile:'
        'Last6' = 'ext:code-workspace;ps1 ( dm:last13days ) !Env.UserProfile: ( path:H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtim* )'
        'Last7' = 'ext:psm1;ps1 !Env.AppData: "*aws*utils*"               !path:"*gitlogg*"         !path:ww:".aws-sam"'

        'NewBigFilesToday' = 'dm:today ( ( dm:last3hours size:>=1mb ) |   ( folder: dc:today ) )'
        'Frequent1'   = 'ext:code-workspace ext:code-workspace;pbix;pq;ps1;psm1 dm:last29days ( ( ext:code-workspace;launch.json;pbix;ps1;psm1 dm:last7weeks  !path:ww:history | ( path:ww:".vscode" !path:ww:%AppData\Code" !path:ww:"%UserProfile%\.vscode" )  | ( ext:vhd;vhdx ) | ( dm:last5minutes ext:log )   ) ( !path:"%UserProfile%\.vscode" )   '
        'LastSeconds' = 'dm:last200seconds                                            ( !path:"%LocalAppData%\Packages\Spotify*" !path:"*windows*search*" !path:"c:\windows\prefetch" !path:ww:"c:\windows\system"    !path:ww:"%LocalAppData%" !path:ww:"%AppData%\Code" )    '

        'BAR_gui_ordermenu' = 'ext:lua ( path:h:\data\2024  | ( path:ww:"G:\2024-git\Game📁" ) ) gui_ordermenu'
        'BAR'               = '( Dirs.BeyondAllReason: ) '
        'BAR_lua_all'       = 'ext:lua  ( Dirs.BeyondAllReason: ) ' # new, simplified

        'Files_WithLongName' = 'file:regex:"^.{30}$"'

        # 'BAR_lua_all' = 'ext:lua  ( path:ww:"G:\2024-git\Game📁" | path:ww:"F:\games\Beyond-All-Reason\data" | path:ww:"H:\data\2024\games\BeyondAllReason" )'

        'Bdg_Examples' = 'ext:psm1;ps1;json;csv;md;log;js;yml "H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtime\examples" '
        'my_roots' = 'dm:last3weeks ( my_roots: ) '
        'Recent Contains Fmt-' = '( dm:last22hours ext:code-workspace;ps1;py;psm1;md; ) | ( dm:last3weeks ext:code-workspace  ( my_roots: )                ) !path:"%AppData%" !path:"%userprofile%" content:"fmt-"'
        'Bdg-Contains-StopLog' = 'ext:psm1;ps1;json;csv;md;log;js;yml "H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtime\examples" !path:".aws-sam" content:"🔴 caught"'

        'pbix'           = 'ext:pbix;pbir;pbit;tmdl  dm:last3months'
        'AwsUtils_All'   = 'ext:psm1;ps1  !Env.AppData:  "*aws*utils*"  !path:"*gitlogg*"  !path:ww:".aws-sam"'
        'Template.yml'   = 'dm:last3weeks  template.yml'
        # 'Template.yml'   = 'template ext:yaml;yml  !Env.AppData:'
        'Code-Workspace' = 'dm:last3weeks  ext:code-workspace  !Env.UserProfile:'
        'SamConfig.toml' = 'samconfig.toml !Env.AppData:'

        'BdgRoot-2023'            = 'ext:code-workspace;ps1 ( dm:last13days ) !Env.UserProfile: ( path:"H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtim*" )'
        'BdgRoot-2023-CoreConfig' = 'ext:code-workspace;ps1 ( dm:last13days ) !Env.UserProfile:   core_config*   ( path:"H:\data\client_bdg\2023.03.17-bdg\core\src\pass1\lab-lambda-runtim*" )'
    }

    write-warning 'not all paramsets are working'?
    # if( $PassThru -and -not $PSBoundParameters.ContainsKey('TemplateName')) {
    if( $passThru -and -not $HasParamQuery -and -not $HsParamTemplate ) {
        return $Mappings
    }

    $HasParamQuery    = -not [string]::IsNullOrWhiteSpace( $QueryPattern )
    $HasParamTemplate = -not [string]::IsNullOrWhiteSpace( $TemplateName )

    if( $HasParamTemplate ) {
        $ResolvedByPattern = $Mappings.keys -match $TemplateName
        $ResolvedByPattern -match $TemplateName | Join-String -op "`nPatterns -match `$TemplateName" -f "`n{0} " | Write-host -fg 'blue'
        Join-String -f 'UsedTemplatePattern on keys: {0}' $ResolvedByPattern.Count | StripAnsi | write-verbose -verb
    } elseif ( $HasParamQuery ) {
        $ResolvedByPattern = $mappings.GetEnumerator().Where({ $_.value -match $QueryPattern } )
        Join-String -f 'UsedQueryParamPattern on values: {0}' $ResolvedByPattern.Count | StripAnsi | write-verbose -verb
    } else {
        throw 'Wip,NYI, should not reach here'
    }
    if( $ResolvedByPattern.count -eq 1) {
        Join-String -f 'Single Match: {0}' -in $ResolvedByPattern |write-verbose -verbose

        if( -not $Mappings.Contains($ResolvedByPattern)) {
            $Mappings | ft -auto | out-string | StripAnsi | write-host -fg 'gray80' -bg 'gray15'
            $Mappings.Keys
            return
        } else {
            $QueryStr = $Mappings[ $TemplateName ]
            if( $PassThru ) { return $QueryStr }
        }
    }

    $QueryStr = $Mappings[ $TemplateName ]

    if( $PassThru ) { return $QueryStr }
    # if( -not [String]::IsNullOrWhiteSpace( $QueryPattern ) ) {
    #     $mappings.GetEnumerator().Where({ $_.value -match 'df' } )
    # }


    throw 'left off here, was rewriting to support more fancy stuff'

    if( -not $Mappings.Contains($TemplateName)) {
        $Mappings | ft -auto | out-string | StripAnsi | write-host -fg 'gray80' -bg 'gray15'
        $Mappings.Keys

    }


    throw 'left off here, was rewriting to support more fancy stuff'
    Start-Process (Join-String -f 'es:{0}' -In $QueryStr )
}

function Dotils.Quick.FormatScript {
    <#
    .SYNOPSIS
        sugar to format code in the console, or clipboard
    .NOTES
        future:
            - [ ] expand alias names, and correct cases
    .EXAMPLE
        # format the last console command you ran
        > Quick.Fmt.Sb
    .EXAMPLE
        # format and save to clipboard
        > (get-history -Id 140).CommandLine | Quick.Fmt.Sb -ToClipboard

    .EXAMPLE
        # From piped string
        > $rawString | Quick.Fmt.Sb

    .EXAMPLE
        # and indent 2 levels
        $rawString | Quick.Fmt.Sb -Debug -Depth 2
    .EXAMPLE
        read from clipboard
        > Quick.Fmt.Sb -FromClipboard

    #>
    [CmdletBinding()]
    [Alias('Quick.Fmt.Sb')]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$ScriptBlock,


        # Is multiplied by -PredentString, so 1 = 4 spaces, 2 = 8, etc.... Default: 0
        [ArgumentCompletions( 1, 2, 3, 4)]
        [Alias('Depth', 'Indent')]
        [int]$PredentLevel = 0,

        # How deep is one level: default is 4 spaces. Default: "    "
        [Alias('IndentString')]
        [ArgumentCompletions("'    '", "'  '")]
        [string]$PredentString = '    ',

        # currently not using parametersets, logic is in body
        [Alias('Gcl')]
        [switch]$FromClipboard,

        # write output to clipboard
        [Alias('Cl')]
        [switch]$ToClipboard
    )
    begin {
        Import-Module PSScriptAnalyzer -MinimumVersion 1.22.0 -PassThru | Write-Verbose # piping added in ~1.20 ish?
        [List[Object]]$Lines = @()

    }
    process {
        if($ScriptBlock) {
            $Lines.Add( @(
                $ScriptBlock | Join-String -sep "`n" ) )
        }
    }
    end {
        if($FromClipboard) {
            # $Content = Get-Clipboard -Raw | Join-String -sep "`n"
            $Lines.AddRange( @(
                Get-Clipboard -Raw | Join-String -sep "`n" ))
        }
        $Content = $Lines | Join-String -sep "`n"

        if( [string]::IsNullOrWhiteSpace( $Content ) ) {
            'Blank Content, using last command...' | Write-host -fg 'gray60' -bg 'gray15'
            $Content = (Get-History | Select -Last 1).CommandLine | Join-String -sep "`n"
        }

        [ArgumentException]::ThrowIfNullOrWhiteSpace( $Content, 'Content' )
        $invokeFormatterSplat = @{
            ScriptDefinition = $Content
            # Range = 10, 304
            # Settings = $config
        }

        $Render = Invoke-Formatter @invokeFormatterSplat | Join-String -sep  "`n"
        $PSBoundParameters | Json -Depth 4
            | Join-String -op 'PSBound: ' | Write-debug

        'prefixBy: "{0}" from: {{ PredentLevel: {1}, PredentString: "{2}" }}' -f @(
            $Prefix, $PredentLevel, $PredentString ) | Write-Debug


        if( $PSBoundParameters.ContainsKey('PredentLevel') ) {
            # wait-debugger
            $Prefix = $PredentString * $PredentLevel -join ''
            $Render = $Render -split '\r?\n'
                | Join-String -f "`n${Prefix}{0}" #-sep "`n"
        }
        if( [string]::IsNullOrWhiteSpace( $Render )) {
            throw 'Render was Blank!'
        }
        # ($raw2 | Dotils.Quick.FormatScript) -split '\r?\n' | Join-String -f "`n    {0}"

        if($ToClipboard) {
            $Render | Set-Clipboard -PassThru
        } else {
            $Render
        }

    }
}
function Dotils.Git.Blame.FromRegex {
    <#
    .SYNOPSIS
        find blame for regex matches
    .EXAMPLE
        Dotils.Git.Blame.FromRegex -BlameFileName $BlameFilename -Pattern 'CrossData'
    .LINK
        https://git-scm.com/docs/git-blame
    #>
    param(
        [string]$BlameFileName,

        [Parameter()]
        [Alias('Regex')]
        [string[]]$Pattern
    )
    if( -not (Test-Path $BlameFileName)) {
        throw "Invalid path given"
    }
    foreach($curPattern in $Pattern) {
        $query = Select-String -Path $BlameFileName -Pattern $Pattern
        $query.LineNumber | %{
            $curLine = $_
            git blame -L $curLine $BlameFileName
        }
    }
}


function Dotils.Git.Blame.GetLines.WIP {
    param(
       [string]$BlameFileName,
       [int]$StartLine,
       [int]$EndLine
    )
    $lineParam = @(
       $StartLine
       if( $PSBoundParameters.ContainsKey('EndLine') ) {
            '{0},{1}' -f $StartLine, $EndLine
       }
       else { $StartLine }
    )

    git blame -L $Lineparam $(
        Get-ITem -ea 'stop' $BlameFilename )
}


function Dotils.WhatIsMyIp {
    [CmdletBinding()]
    param(
        # [ValidateSet('ipify', 'B')]
        # [string]$Method
    )
    return [pscustomobject]@{
       'ipify' = irm 'https://api.ipify.org/?format=json'
       'my-ip' = irm 'https://api.my-ip.io/v2/ip.json'
    }
    # switch($Method) {
    # }

}
function Dotils.Was {
    $state = $script:WasHistory
    throw 'WIP Left off. idea is to check if path is already in list, otherwise add ((gi .))'
    # if( -not $State.Con ) { }
    $state.Find( { param($x) $x.Fullname -eq (gi .).FullName } )
    $state.Find( { param($x) $x.tostring() -eq (gi .).tostring() } )
}
function Dotils.Text.RemoveDiacritics {
    <#
    .SYNOPSIS
        Removes diacritics from text, by utilizing Cryillic encoding. Works pretty good for no effort.
    .EXAMPLE
        > Dotils.Text.RemoveDiacritics -Text 'Áçčèñţş ůşîñģ dïäçřïţïçš'
        # output:
        Accents using diacritics
    #>
    param(
        # text with accents and diacritics
        $Text,

        # Utf-8 seems to work best? Override if you want something else
        [ArgumentCompletions('Utf-8', 'Ascii')]
        $DecodeAs = 'Utf-8'
    )
    $bytes_cry = [Text.Encoding]::GetEncoding('Cyrillic').GetBytes( $Text )
    [Text.Encoding]::GetEncoding( $DecodeAs ).GetString( $bytes_cry )
}


function Dotils.DebugUtil.Format.UpdateTypedataLiteral {
    <#
    .SYNOPSIS
        random sugar, generates template for example DefaultDisplayPropertySet
        Pwsh>
            $what = $agiltypackload.SelectNodes('//a') | one
            $what = $AgilityPack.SelectNodes('//a') | Select -First 1
            $what | Dotils.DebugUtil.Format.UpdateTypedataLiteral

        # Outputs

            # For Type: [HtmlAgilityPack.HtmlNode]

            'Attributes' # -is [HtmlAgilityPack.HtmlAttributeCollection]
            'ChildNodes' # -is [HtmlAgilityPack.HtmlNodeCollection]
            'Closed' # -is [System.Boolean]
            'ClosingAttributes' # -is [HtmlAgilityPack.HtmlAttributeCollection]
            'Depth' # -is [System.Int32]
            'EndNode' # -is [HtmlAgilityPack.HtmlNode]
            'FirstChild' # -is [HtmlAgilityPack.HtmlNode]
            'HasAttributes' # -is [System.Boolean]
            'HasChildNodes' # -is [System.Boolean]
            'HasClosingAttributes' # -is [System.Boolean]
            'Id' # -is [System.String]
            'InnerHtml' # -is [System.String]
            'InnerLength' # -is [System.Int32]
            'InnerStartIndex' # -is [System.Int32]
            'InnerText' # -is [System.String]
            'LastChild' # -is [HtmlAgilityPack.HtmlNode]
            'Line' # -is [System.Int32]
            'LinePosition' # -is [System.Int32]
            'Name' # -is [System.String]
            'NextSibling' # -is [HtmlAgilityPack.HtmlNode]
            'NodeType' # -is [HtmlAgilityPack.HtmlNodeType]
            'OriginalName' # -is [System.String]
            'OuterHtml' # -is [System.String]
            'OuterLength' # -is [System.Int32]
            'OuterStartIndex' # -is [System.Int32]
            'OwnerDocument' # -is [HtmlAgilityPack.HtmlDocument]
            'ParentNode' # -is [HtmlAgilityPack.HtmlNode]
            'PreviousSibling' # -is [HtmlAgilityPack.HtmlNode]
            'StreamPosition' # -is [System.Int32]
            'XPath' # -is [System.String]
    #>
    [Alias(
        '.debug.format-UpdateTypedata.Literal',
        'literal.UpdateTypeDataProperty'
    )]
    param(
        [Parameter(Mandatory, Position= 0, ValueFromPipeline )]
        [object]$InputObject
    )
    $what
        | Format-ShortTypename | Label 'For Type' | Write.Infa

    $what
        | Find-Member -MemberType Property | Sort-Object Name
        | Join-String -f "`n{0}" {
            @(
                '{0} # -is [{1}]' -f @(
                    $_.Name | Join-String -SingleQuote
                    $_.PropertyType
                )
            )-join ' '
    }
}

function Dotils.Resolve.TypeInfo {
    <#
    .SYNOPSIS
        Get the type of an object, either, [1] it is already a typeinfo, [2] is the name of a type, [3] GetType()
    .DESCRIPTION
        Get the type of an object, either, [1] it is already a typeinfo, [2] is the name of a type, [3] GetType()
    .EXAMPLE
        'CommandInfo' | Resolve.TypeInfo
    #>
    [Alias(
        'Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo'
        # '.Resolve.TypeInfo'
        # '.to.TypeInfo'
    )]
    [OutputType('type')]
    param(
        # An object, a type info, or the name of a type
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if($InputObject -is 'type') {
            return $InputObject
        }
        if($inputObject -is 'string' -and $InputObject -as 'type') {
            return $InputObject -as 'type'
        }
        if($InputObject -is 'string') {
            return Find-type -Name $InputObject
        }
        return ($InputObject)?.GetType()
    }
}


function Dotils.Format-ModuleName {
    <#
    .SYNOPSIS
        visually summarize a module, maybe make a EzFormat
    .EXAMPLE
        Get-Module | RenderModuleName
    #>
    [Alias('Render.ModuleName')]
    param()
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


function Dotils.Test-IsOfType.FancyWip {
    <#
    .SYNOPSIS
        Is something one of a type list? sugar for filtering objects by types
    .description
        see also, the TypeInfo is subclass
        related:
            Dotils.Is.SubType

    .example
        Warning: the current behavior returns the <object> that passed the test
        this may be unexpected. maybe add another param,
            - passsThru: returns the good object, as the original type
            - not passTHru: returns the object after coercion to the new type
    .example
        @( get-item .; get-date; 34; 9.1; 'hi world', ([Text.Rune]::new(0x2400)))
    .example
            # filter kinds

            123, 24.65, '99' | .Is.Type -TypeNames 'int'
                # out: [123] # | Json -AsArray -Compress

            123, 24.65, '99' | .Is.Type -TypeNames 'int' -AllowCompatibleType
                # out: [123,24.65,"99"] # | Json -AsArray -Compress
w
    .LINK
        Dotils.Test-IsOfType
    .LINK
        Dotils.Is.SubType
    #>
    [CmdletBinding(
        # DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Is.Type', '.Is.OfType'
        )]
    param(
        <#
        .SYNOPSIS
        is a type one of types?

            Dotils.Test-IsOfType ([PoshCode.Pansies.RgbColor]) -Debug -AsTest -AllowCompatibleType -InputObject 'red'
            Dotils.Test-IsOfType ([PoshCode.Pansies.RgbColor]) -Debug -AsTest -InputObject 'red'


        #>
        # A list of types to compare against, using the -is, sort of
        [Parameter(Mandatory, Position=0, ParameterSetName='ByType')]
        [Alias('Name', 'IsType')]
        [ArgumentCompletions(
            'double', 'int', 'int32', 'int64', 'uint32', 'uint64',
            'float',
            'Datetime', 'Timespan', 'CommandTypes'
        )]
        [string[]]$TypeNames,
        [Parameter(Mandatory, Position=0, ParameterSetName='ByGroup')]
        [Alias('Category', 'Group', 'IsKind')]
        [ArgumentCompletions(
            'double', 'int', 'int32', 'int64', 'uint32', 'uint64',
            'float',
            'Datetime', 'Timespan', 'CommandTypes'
        )]
        [string[]]$TypeCategoryNames,

        # # literals escaped for a regex
        # [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        # [string]$Literal,

        # # If not set, and type is not string,  tostring will end up controlling what is matched against
        # [Parameter(Position=1)]
        # [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # if a test, return a boolean
        # if not, filter objects
        [switch]$AsTest,

        # if it fails, maybe -as type coercion will work
        [switch]$AllowCompatibleType,

        # return orignal types
        [switch]$PassThru


        # when no property is specified, usually nicer to try the property name than tostring
        # [switch]$AlwaysTryProp = $true
    )
    begin {

    }
    process {
        [bool]$ReturnAsCoercedValue = -not $PassThru
        if( $PassThru  ) { throw 'command future creep, refactor' }
        if( $PSCmdlet.ParameterSetName -eq 'ByGroup') {
            throw 'quickhack'

        }
        $lastGoodType = 'object'
        [bool]$anyMatches = $false
        [bool]$ShouldReturnBool = $AsTest
        if( [string]::IsNullOrWhiteSpace( $TypeNames ) ) {
            throw 'BadArgumentsException: -TypeNames was empty'
        }
        foreach($CurObj in $InputObject) {
            [bool]$shouldKeep? = $false

            foreach($name in $TypeNames) {
                write-debug "    Test-IsOfType: comparing CurObj is $Name"
                if($curObj -is $Name) {
                    $shouldKeep? = $true
                    $anyMatches = $true
                    break
                }
            }
            # is this redundant?
            if(-not $ShouldKeep -and $AllowCompatibleType) {
                write-debug "    -is compares failed, trying -as..."
                foreach($name in $TypeNames) {12143
                    write-debug "    Test-IsOfType: comparing CurObj is $Name"
                    if($curObj -as $Name -ne $null) {
                        $shouldKeep? = $true
                        $lastGoodType = $Name
                        $anyMatches = $true
                        break
                    }
                }
            }
            if($ShouldKeep?) {
                @(
                    'AllowCompatible? {0}' -f $AllowCompatibleType
                    'ReturnAsCoerced?: {0}' -f $ReturnAsCoercedValue
                    'LastGoodType?: {0}' -f $lastGoodType
                ) | Join-String -sep ', ' | Join-String -sep "`n" |  write-verbose
                if(-not $ReturnAsCoercedValue ) {
                    $curObj
                } else {
                    $curObj -as $LastGoodType
                }
            }
        }
        if( -not $MyInvocation.ExpectingInput ) {
            return $anyMatches
        }
    }
}

function __compare-Is.Type {
    # do I ever want to use type base name, because you can't always instantiate it
    # by default error on nulls
    <#
    .SYNOPSIS
    .DESCRIPTION
        silently allow nulls by default, to prevent parameter binding errors
    #>
    [CmdletBinding()]
    [OutputType('bool')]
    param(
        # treat left as an object or type info
        [AllowNull()]
        [Parameter(Mandatory, Position=0)]
        [Alias('Left')]
        $InputObject,

        # test if it's the type right, or has the typeinfo
        [Alias('Is')]
        [AllowNull()]
        [Alias('Right')]
        [Parameter(Mandatory, Position=1)]
        [object]$TypeName,

        # # Don't instantiate
        # [Alias('AsString')][switch]$CompareString,

        [switch]$AllowNull
    )
    $Left  = $InputObject
    $Right = $TypeName
    if(-not $AllowNull) {
        if( ($null -eq $Left) -or ($null -eq $Right) ) {
            throw 'NullArgumentException!'
        }
    }
    if($AllowNull) {
        if (($null -eq $Left) -or ($null -eq $Right)) {
            return $false
        }
    }
    if($left -eq $Right) { return $true }
    if($left -is $Right) { return $true }

    $tinfo_left  = Resolve.TypeInfo -InputObject $Left
    $tinfo_right = Resolve.TypeInfo -InputObject $Right
    Join-String -inp $Tinfo, $right -p Name -sep ', ' -op '__compare-Is.Type: =>  ' | write-debug
    if($tinfo_left -eq $tinfo_right) { return $true }
    if($tinfo_left.Name -eq $right) { return $true }
    if($tinfo_left -as $right -ne $Null) { return $true }
    return $false
}

function Dotils.File.NewPathItem {
    <#
    .synopsis
        Ensure you always get a string, but attempt to resolve a (Get-Item) instance
    .EXAMPLE
        > NewPathItem 'temp:\missing'    # out [string]: temp:\missing
        > NewPathItem $Env:LocalAppData  # out [IO.DirectoryInfo]:
    .EXAMPLE
        $Env:LocalAppData, 'temp:\', '.'  | Dotils.File.NewPathItem
    #>
    [CmdletBinding()]
    [OutputType(
        [System.IO.FileInfo], [System.IO.DirectoryInfo],
        [System.String] )]
    param(
        # Pipe or pass strings, IO.FileSystemInfo, etc...
        [Alias('InputObject')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Path
    )
    process {
        if( [string]::IsNullOrWhiteSpace( $Path ) ) {
            throw "BlankValue: Invalid -Path Parameter!"
        }
        $item = Get-Item $Path -ea 'ignore'
        $Item ?? $Path
    }
}
function Dotils.Show-Escapes {
    <#
    .SYNOPSIS
        show color control sequence escapes as safe symbols
    .EXAMPLE
        1..255 | Join-String -f "`e[38;5;{0}m{0}`e[0m" -sep ' '
            | Dotils.Show-Escapes

        # ␛[38;5;1m1␛[0m ␛[38;5;2m2␛[0m ␛[38;5;3m3␛[0m ␛[38;5;4m4␛[0m ␛[38;5;5m5␛[0m ␛[38;5;6m6␛[0m ␛[38;5 ...
    #>
    [Alias('Show-Escapes', 'ShowEscapes')]
    param()
    process {
       $_ -replace  "`e", '␛'
    }
}

function Dotils.Test.IsModulus {
    <#
    .SYNOPSIS
    .EXAMPLE
        # get even values
        1..10 | ?{ Is.Mod $_ 2 }
    .EXAMPLE
        # insert newlines to wrap text every X segments
        1..255 | %{ if( Is.Mod $_ 15 ) { "`n" } ; $_ ; } | Join-String -f '{0,4}'

        1   2   3   4   5   6   7   8   9  10  11  12  13  14
        15  16  17  18  19  20  21  22  23  24  25  26  27  28  29
        30  31  32  33  34  35  36  37  38  39  40  41  42  43  44
        45  46  47  48  49  50  51  52  53  54  55  56  57  58  59
        60  61  62  63  64  65  66  67  68  69  70  71  72  73  74
    #>
    [OutputType('Boolean')]
    [Alias('Is.Modulus', 'Is.Mod')]
    param(
        [Parameter(Mandatory, Position=0)]
        [int]$InputObject,

        [Parameter(Mandatory, Position=1)]
        [int]$Modulus
    )
    $result  = ($InputObject % $Modulus) -eq 0
    return $result
}


function Dotils.PStyle.Color.Gray {
    [Alias(
        'Dotils.Color.Gray', 'c.Gray')]
    param(
        # inte
        [Parameter(Position = 0)]
        [ValidateSet('Fg', 'Bg', 'Foreground', 'Fore', 'Background', 'Back', 'Both')]
        [string]$ColorMode = 'Fg',

        # gray on the range [0.0 - 1.0] , or, Integer on the range [0, 100]
        [Parameter(Position = 1)]
        $Ratio = 0.8
    )
    if($Ratio -is 'int') {
        $Ratio = $Ratio / 100
    }
    $g = 255 * $Ratio
    $g = [math]::Clamp( $g, 0, 255 )
    switch($ColorMode) {
        'Both' {
            $PSStyle.Foreground.FromRgb( $g, $g, $g )
            $PSStyle.Background.FromRgb( $g, $g, $g )
        }
        { $_ -in 'Fg', 'Foreground', 'Fore' } {
            $PSStyle.Foreground.FromRgb( $g, $g, $g )
        }
        { $_ -in 'Bg', 'Background', 'Back' } {
            $PSStyle.Background.FromRgb( $g, $g, $g )
        }
        default { throw "ShouldNeverReachException: UnhandledMode $ColorMode" }
    }
}

function Dotils.Colorize.BasedOnDistincCount {
    <#
    .SYNOPSIS
        super naive hack. show colors based on distinct order repeated values were used
    .DESCRIPTION
        default does grayscale from 0 to N items, gradient width is distinct count
        should improve to work more like 'Ninmonkey.Console\Format-WrapJaykul'
    .example
            Gci
            | Format-WrapJaykul -RgbColor 'red', 'blue', 'green' -Property {
        $_.Name, $_.Length -join ' = ' }
    .link
        Ninmonkey.Console\Format-WrapJaykul
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [Alias('StartColor')]
        $GradientStart = 'gray90',

        [Alias('EndColor')]
        $GradientEnd = 'gray10'
    )
    begin {
        $NextOffset = 0
        [List[Object]]$Items = @()
        $Mapping = [ordered]@{}
    }
    process {

        foreach($CurObj in $InputObject) {
            [string]$NextLower = $CurObj.ToString().ToLowerInvariant()
            if( -not $Mapping.Contains(  $NextStr ) ) {
                $Mapping[ $NextStr ] = $NextOffset
                $NextOffset++
            }

            $items.Add( [pscustomobject]@{
                Obj = $CurObj
                ColorIndex = $NextOffset
            } )
            # $Items.Add( $CurObj )
        }
    }
    end {

        $TotalItems = [Math]::max( 3, $Items.Count  )
        'GradientStart: {0}, GradientEnd: {1}, Items.Count: {2} [ TotalItems: {3} ]' -f @(
            $GradientStart, $GradientEnd, $Items.Count, $TotalItems
        ) | Write-verbose


        $Gradient = Get-Gradient $GradientStart $GradientEnd -Width $TotalItems

        $Items | %{
            $Obj = $_

            '{0} is {1}' -f @(
                $CurObj.Obj
                $Mapping[ $CurObj.ColorIndex ]
            )
            | New-text -bg $clist[ $CurObj.ColorIndex ]

        }
    }

}
function Dotils.PStyle.Color.Hex {
    <#
    .example
        gci env:\ | %{
            $c = c.Gray Fg .4
            if( $_ | .Is.DirectPath ) {
                $c = c.Gray Fg .7
            }
            $_.Name | Join-String -op ($c)
            $_.value | Join-String -op (c.Hex fg '#dbdca8')
        }
    #>
    [Alias(
        'Dotils.Color.Hex', 'c.Hex')]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('Fg', 'Bg', 'Foreground', 'Fore', 'Background', 'Back', 'Both')]
        [string]$ColorMode = 'Fg',

        [Parameter(Position = 1)]
        $ColorHex
    )
    $Regex = @{
        Is6DigitHexWithoutPrefix = '^[a-fA-F0-9]{6}$'
    }
    if($ColorHex -match $regex.Is6DigitHexWithoutPrefix ) {
        $ColorHex = "#${ColorHex}"
    }
    switch($ColorMode) {
        'Both' {
            $PSStyle.Foreground.FromRgb( $ColorHex )
            $PSStyle.Background.FromRgb( $ColorHex )
        }
        { $_ -in 'Fg', 'Foreground', 'Fore' } {
            $PSStyle.Foreground.FromRgb( $ColorHex )
        }
        { $_ -in 'Bg', 'Background', 'Back' } {
            $PSStyle.Background.FromRgb( $ColorHex )
        }
        default { throw "ShouldNeverReachException: UnhandledMode $ColorHex" }
    }
}
# [rgbcolor].FullName, 'int', (get-date) | Resolve.TypeInfo | Should -BeOfType 'type'
function Dotils.Resolve.Module {
    # I feel like this is resolve, rather than ConvertTo
    [Alias(
        'Resolve.Module' # , 'Dotils.ConvertTo-Command'
    )]
    [OutputType('System.Management.Automation.PSModuleInfo')]
    [CmdletBinding()]
    param(
        # Accepts [string], [CommandInfo], [AliasInfo], and possibly more
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [Parameter(mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByModuleInfo')]
        [Alias('Module')][System.Management.Automation.PSModuleInfo]$PSModuleInfo
    )
    process {
        $InputObject | Format-ShortTypeName | Join-String -op 'typeof: ' | write-verbose
        switch ($PSCmdlet.ParameterSetName) {
            'ByModuleInfo' {
                return $PSModuleInfo
            }
            default {
                write-verbose "DefaultHandlingFallback: For $($InputOBject | Format-ShortTypeName)"
                $InputObject
            }
        }
        # switch($InputObject) {
        #     { $_ -is 'String' } {
        #         Get-Command $_ | Dotils.Resolve.Command
        #     }
        #     { $_ -is 'Management.Automation.AliasInfo'} {
        #         $_.ResolvedCommand
        #     }
        # }
    }
}
'-next: migraine bad. Validate confirm code works "Dotils.Add-PsModulePath "' | write-host -bg 'orange'
function Dotils.Write-DictLine {
    <#
    .SYNOPSIS
        sugar to print a dict, possibly with some filters
    .NOTES
    future:
        - [ ] colorize key-value pairs
            key.fg   = gray80
            value.fg =gray40
    .EXAMPLE
        Pwsh> @{ 'cat' = 'emoji' ; z = 300 } | Dotils.Write-DictLine
        cat = emoji, z = 300

        Pwsh> Dotils.Write-DictLine -inp @{ 'cat' = 'emoji' ; z = 300 }
        cat = emoji, z = 300
    #>
    [OutputType('string')] # or nothing
    [CmdletBinding()]
    param(
        # filepath to add
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        [Alias('Prefix', 'op')][string]$OutputPrefix  = '',
        [Alias('Suffix', 'os')][string]$OutputSuffix  = '',
        [Alias('Delimiter', 'Sep')][string]$Separator = ', ',
        [hashtable]$Options = @{},
        [switch]$Sort
        # [switch]$SkipCoercion //
    )
    begin {
        $Config = nin.MergeHash -other $Options -base @{
            MaxLength = 30
        }
        write-warning 'slightly NYI, validate working'
        $finalHash = [ordered]@{}

    }
    process {
        if( $InputObject -isnot 'hashtable' -and
            $InputObject -isnot 'Collections.IDictionary' -and
            $InputObject -isnot 'Collections.ICollection' ) {
            throw 'expected hashable '
        }
        $InputObject.GetEnumerator() | %{
            [string]$key = $_.Key
            $finalHash[ $key ] = $_.Value
        }
    }
    end {
        if($Sort) {
            $finalHash.GetEnumerator()
                | Sort-Object { $_.Key }
                | %{ # todo: refactor shared
                    $isShort = $value.length -gt $Config.MaxLength
                    $value = $_.Value
                    $value = Dotils.ShortString.Basic -InputObject $value -maxLength $Config.MaxLength
                    if($isShort) {
                        $value += '...'
                    }
                    $_.Key, $value -join ' = '
                }
                | Join-String -sep $Separator -op $OutputPrefix -os $OutputSuffix
                return
        }

        $finalHash.GetEnumerator()
            | %{ # todo: refactor shared
                $isShort = $value.length -gt $Config.MaxLength
                    $value = $_.Value
                    $value = Dotils.ShortString.Basic -InputObject $value -maxLength $Config.MaxLength
                    if($isShort) {
                        $value += '...'
                    }
                    $_.Key, $value -join ' = '
            }
            | Join-String -sep $Separator -op $OutputPrefix -os $OutputSuffix
    }
}
function Dotils.Paths.FindPwshModulesToLoad {
    <#
    .SYNOPSIS
        Find pwsh modules and filter them, based on duplicates or shared root directories
    .EXAMPLE
        # [1] get module names

        Pwsh> Dotils.Paths.FindPwshModulesToLoad -AsBaseNames
            # Bintils, bintils.common, bintils.completers.AwsCli, ...
    .EXAMPLE
    # [2] get modules grouped on common root

    Pwsh> Dotils.Paths.FindPwshModulesToLoad

        ShortName           TotalItems RootDirectory                         ChildModules
        ---------           ---------- -------------                         ------------
        PsModules                   33 H:\data\2023\pwsh\PsModules           {H:\data\2023\pwsh\PsM
        PsModules.👨.Import          6 H:\data\2023\pwsh\PsModules.👨.Import {H:\data\2023\pwsh\PsM
        PsModules.dev               19 H:\data\2023\pwsh\PsModules.dev       {H:\data\2023\pwsh\PsM
        PsModules.Import            22 H:\data\2023\pwsh\PsModules.Import    {H:\data\2023\pwsh\PsM
    .EXAMPLE

    # [3] help finding accidental duplicates? or to ensure module builder cleaned up

    Pwsh> Dotils.Paths.FindPwshModulesToLoad -FindDuplicates

        GroupName                       TotalCount Dupes
        ---------                       ---------- -----
        Jsonify.psm1                             4 {H:\data\2023\pwsh\PsModules.Import\Jsonify\0.0.4\Jsonif
        Marking.psm1                             2 {H:\data\2023\pwsh\PsModules.dev\Marking\Marking\Marking
        Picky.psm1                               4 {H:\data\2023\pwsh\PsModules.Import\Picky\0.0.4\Picky.ps
        CacheMeIfYouCan.psm1                     5 {H:\data\2023\pwsh\PsModules.Import\CacheMeIfYouCan\0.0.

    #>
    param(
        # returns a distinct list of module's base names, ie: without extensions
        [Alias('Basic', 'BaseName', 'AsName', 'AsBaseName', 'Simple', 'Name')]
        [switch]$AsBaseNames,
        [switch]$FindDuplicates
    )
    $CommonRoot = Get-Item -ea 'stop' 'H:\data\2023\pwsh'

    class RecursedModule {
        [IO.DirectoryInfo]$RootDirectory
        [List[Object]]$ChildModules = @()
        [int]$TotalItems = 0
        [string]$ShortName = ''
    }
    # wait-debugger
    $query = @(
        'PsModules'
        'PsModules.👨.Import'
        'PsModules.dev'
        'PsModules.Import'
    ) | %{
        $curRoot = $_
        $resolvedRootDir = Get-Item (Join-Path $CommonRoot $curRoot)

        [List[Object]]$BinArgs = @(
            '-tf'
            '-e', 'psm1'
            '--search-path', $ResolvedRootDir
        )
        [List[Object]]$queryChildren = @( fd @binArgs  | Get-Item )

        [RecursedModule]@{
            ShortName     = $curRoot
            RootDirectory = $resolvedRootDir
            TotalItems    = $queryChildren.Count
            ChildModules  = $queryChildren
        }
    }   | Sort-Object RootDirectory, ShortName

    $Query
        | Update-TypeData -Force -DefaultDisplayPropertySet 'ShortName', 'TotalItems', 'RootDirectory', 'ChildModules'

    if( $AsBaseNames ) {
        return $query | % ChildModules | % BaseName | Sort-Object -Unique
    }
    if(-not $FindDuplicates) { return $query }

    if($FindDuplicates){
        [List[Object]]$groupByDupes = $query.ChildModules | group-object Name | Sort-Object -Descending | ? Count -gt 1

        $groupByDupes | %{
            [pscustomobject]@{
                GroupName = $_.Name
                TotalCount = ($_.Group.FullName).Count
                Dupes = $_.Group.FullName  | Get-Item | Sort-Object FullName -Unique
            }
        }
        return
    }
}
function Dotils.Paths.FindNamedEnvVarPaths {
    <#
    .SYNOPSIS
        reference to find some common env vars for system paths
    .link
        Dotils.Paths.FindNamedEnvVarPath
    .link
        Dotils.FindPackageDirs.InvokeEverythingSearch
    .link
        Dotils.Paths.FindAssembly.Tabular3
    .link
        Dotils.Paths.FindPackageDirs

    .EXAMPLE
    # output
    > Find.NamedEnvVarPaths

        EnvVar                  Current
        ------                  -------
        ALLUSERSPROFILE         C:\ProgramData
        CommonProgramFiles      C:\Program Files\Common Files
        CommonProgramFiles(x86) C:\Program Files (x86)\Common Files
        CommonProgramW6432      C:\Program Files\Common Files
        MSMPI_BENCHMARKS        C:\Program Files\Microsoft MPI\Benchmarks\
        MSMPI_BIN               C:\Program Files\Microsoft MPI\Bin\
        ProgramData             C:\ProgramData
        ProgramFiles            C:\Program Files
        ProgramFiles(x86)       C:\Program Files (x86)
        ProgramW6432            C:\Program Files
        VS120COMNTOOLS          C:\Program Files (x86)\Microsoft Visual Studio 12.
        VS140COMNTOOLS          C:\Program Files (x86)\Microsoft Visual Studio 14.
    #>


    class NamedPath {
        [string]$EnvVar
        [bool]$Exists = $false
        [object]$Current
        [string]$CurrentRaw
        [string]$Example
    }
    [List[Object]]$potentialPaths = @(
        [NamedPath]@{
            EnvVar ='ProgramW6432'
            Example = 'C:\Program Files'
        }

        [NamedPath]@{
            EnvVar ='ProgramFiles'
            Example = 'C:\Program Files'
        }

        [NamedPath]@{
            EnvVar ='ProgramFiles(x86)'
            Example = 'C:\Program Files (x86)'
        }

        [NamedPath]@{
            EnvVar ='CommonProgramFiles(x86)'
            Example = 'C:\Program Files (x86)\Common Files'
        }

        [NamedPath]@{
            EnvVar ='VS120COMNTOOLS'
            Example = 'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\'
        }

        [NamedPath]@{
            EnvVar ='VS140COMNTOOLS'
            Example = 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\'
        }

        [NamedPath]@{
            EnvVar ='CommonProgramFiles'
            Example = 'C:\Program Files\Common Files'
        }

        [NamedPath]@{
            EnvVar ='CommonProgramW6432'
            Example = 'C:\Program Files\Common Files'
        }

        [NamedPath]@{
            EnvVar ='MSMPI_BENCHMARKS'
            Example = 'C:\Program Files\Microsoft MPI\Benchmarks\'
        }

        [NamedPath]@{
            EnvVar ='MSMPI_BIN'
            Example = 'C:\Program Files\Microsoft MPI\Bin\'
        }

        [NamedPath]@{
            EnvVar ='ProgramData'
            Example = 'C:\ProgramData'
        }

        [NamedPath]@{
            EnvVar = 'ALLUSERSPROFILE'
            Example = 'C:\ProgramData'
        }
    )

    $potentialPaths | %{
        $_.CurrentRaw = [Environment]::GetEnvironmentVariable( $_.EnvVar, 'Process' )
        $_.Current =
            (Get-Content -ea 'ignore' ( Join-Path Env:\ $_.EnvVar)
                | Get-Item -Force) ?? "`u{2400}"

        $_.Exists = Test-Path -ea 'ignore' $_.Current

    } | Sort-Object EnvVar

    return $PotentialPaths
}

function Dotils.Paths.FindPackageDirs.InvokeEverythingSearch {
    <#
    .example
        > Dotils.Paths.FindPackageDirs.InvokeEverythingSearch -AutoOpen
    .example
        > Dotils.Paths.FindPackageDirs.InvokeEverythingSearch

            es:( folder:ww:GAC_MSIL ) | ( Microsoft.Data ext:dll )
    .example
        > Dotils.Paths.FindPackageDirs.InvokeEverythingSearch Multiple

            es:folder:ww:GAC_MSIL
            es:Microsoft.Data ext:dll
    .link
        Dotils.Paths.FindNamedEnvVarPath
    .link
        Dotils.FindPackageDirs.InvokeEverythingSearch
    .link
        Dotils.Paths.FindAssembly.Tabular3
    .link
        Dotils.Paths.FindPackageDirs
    #>

    param(
        [ValidateSet('Single', 'Multiple')]
        [string]$OutputMode = 'Single',

        [switch]$AutoOpen,
        [switch]$WithoutLimitRecent
    )
    $LimitRecent = -not $WithoutLimitRecent

    'note: Skipped problematic disabled path:"C:\Program Files\Tabular Editor 3" because of the double layers of quote parsing' | write-verbose -verbose

    [list[Object]]$Terms = @(
        # 'path:"C:\Program Files\Tabular Editor 3"'
        'file:"Microsoft.Mashup*"'
        'wfn:"*Mashup*.dll"'
        'wfn:"*OleDbProvider*.dll"'
        'folder:ww:GAC_MSIL'
        'Microsoft.Data ext:dll'
        'wholefilename:Microsoft.Data.SqlClient.dll' # wfn
    )
    #| %{ $_ -replace '"', "'" }
    # start-process -path $((Dotils.Paths.FindPackageDirs.InvokeEverythingSearch Single) -replace '"', '""')

    $queryList = switch($OutputMode) {
        'Multiple' {
            $Terms | %{ $_ }

        }
        default {
            $Terms | Join-string -sep ' | ' -p {
                '( {0} )' -f @( $_ )
            }
        }
    }

    [string[]]$RenderQueries = @(
        $queryList | %{
            if( -not $LimitRecent ) {
                'es:{0}' -f @( $_ )
            } else {
                'es:( {0} ) (dm:last1years)' -f @( $_ )
            }
        } | %{
            # arg. can't get it to pass double quotes to ES
            # I tried escaping doubles 3 different ways
            # need to test if it's breaking before or after passing to ES
            # its only a problem when output mode is Single and path has sapces
            $EscapeDouble = $false
            if(-not $EscapeDouble) {
                return $_
            }
            $_ = $_ -replace '"', '""'
            $_ = '"{0}"' -f $_
            return $_

        }
    )
    if($AutoOpen) {
        $renderQueries | %{
            # $rawStr = $_ -replace '"', '\"'
            Start-Process -path $_
            # Start-Process -path $rawStr
        }
    }
    return $renderQueries
}
function Dotils.Paths.FindAssembly.Tabular3 {
    <#
    .SYNOPSIS
        Find tabular3 related dll files
    .EXAMPLE
        Pwsh> Dotils.Paths.FindAssembly.Tabular3  -ShortList
            # <returns same info as files>
    .EXAMPLE
        Pwsh> Dotils.Paths.FindAssembly.Tabular3  -ListNamespaces -ShortList

            TOMWrapper
            TabularEditor3
            TabularEditor3.Licensing
            TabularEditor3.Shared
            TabularEditor3.Utils
            Dax.Metadata
            Dax.Model.Extractor
            Dax.ViewVpaExport
            Dax.Vpax
            Microsoft.AnalysisServices.Tabular
            Microsoft.AnalysisServices.Tabular.Json
            Microsoft.Data.SqlClient
            Microsoft.SqlServer.Server
            System.Data.SqlClient
            System.Diagnostics.EventLog.Messages
            System.Diagnostics.PerformanceCounter
            System.Text.Encoding.CodePages
            System.Text.Encodings.Web
            System.Text.Json
    .link
        Dotils.Paths.FindNamedEnvVarPath
    .link
        Dotils.FindPackageDirs.InvokeEverythingSearch
    .link
        Dotils.Paths.FindAssembly.Tabular3
    .link
        Dotils.Paths.FindPackageDirs
    #>
    param(
        [string]$RootDirectory = 'C:\Program Files\Tabular Editor 3',
        [switch]$ShortList,
        [switch]$ListNamespaces
    )
    [List[Object]]$binArgs = @(
        '-e', 'dll'
        '--search-path'
        (Get-item $RootDirectory)
    )

    [List[Object]]$query = @(
        & fd @binArgs | Get-Item
            | Sort-Object Name
    )

    if($ShortList) {
        $query = $query | ?{
            $_.name -match 'TOMWrapper|^Dax\.|^Cli|Tabular|Data\.SqlClient|Microsoft\.SqlServer|Diagnostics|^System\.Text|Encoding|CodePages|TabularEditor'
        }
    }
    if($ListNamespaces){
        $query.Name | %{
            $_ -replace '\.dll$', ''
        } | Sort-Object -unique
        return
    }

    return $query
}
function Dotils.Paths.FindPackageDirs {
    <#
    .SYNOPSIS
        find some assembly package directories
    .link
        Dotils.Paths.FindNamedEnvVarPath
    .link
        Dotils.FindPackageDirs.InvokeEverythingSearch
    .link
        Dotils.Paths.FindAssembly.Tabular3
    .link
        Dotils.Paths.FindPackageDirs
    #>
    $script:__cachePackageDirs ??= @{}

$docStr = @'
try command:
    start 'es:folder:ww:GAC_MSIL'
    start 'es:Microsoft.Data ext:dll'
    start 'es:path:"E:\Program Files (x86)\Power BI Desktop\bin"'
'@
    if( $script:__cachePackageDirs.Keys.count -eq 0) {
        $docStr | write-host -fg 'gray40'
        'Searching lots of files....' | write-host -fg 'salmon'
    }
    [List[Object]]$script:__cachePackageDirs.Packages ??=
        fd -td Packages --search-path ([Environment]::GetEnvironmentVariable( 'ProgramFiles(x86)'))

    $script:__cachePackageDirs.GAC_MSIL = @(
        Get-Item 'C:\Windows\Microsoft.NET\assembly\GAC_MSIL'
        Get-Item 'C:\Windows\assembly\GAC_MSIL'
    )


    'cached to $script:__cachePackageDirs' | write-host -fg 'salmon'
    return $script:__cachePackageDirs
}

function Dotils.Fetch.RecurseProperty {
    <#
    .SYNOPSIS
        find recursive properties
    .DESCRIPTION
        sugar for situations where you need to test a property by descending an unknown depth

        $p.MainWindowHandle
        $p.Parent.MainWindowHandle
        $p.Parent.Parent.MainWindowHandle ....
        $p.Parent.Parent.Parent.MainWindowHandle
    .EXAMPLE
        Pwsh> Fetch.RecurseProp -InputObject (ps -Id $PID) -DescendPropertyName Parent -AccessPropertyName Name
        Pwsh> Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowTitle
        Pwsh> Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowTitle
    .EXAMPLE

        Depth Property Value
        ----- -------- -----
            0 Parent   pwsh
            1 Parent   Code
            2 Parent   Code
            3 Parent   explorer
    .EXAMPLE
        Pwsh> Fetch.RecurseProperty -InputObject (Get-Process -Id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowHandle

        Depth Property   Value
        ----- --------   -----
            0 Parent         0
            1 Parent         0
            2 Parent   1707656
            3 Parent   1574506
    .EXAMPLE
        Pwsh> Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName 'ProcessName', 'MainWindowHandle' -OrderBy 'Depth', 'MemberName' -MaxDepth 5 -Verbose

            Depth DescendBy MemberName          Value
            ----- --------- ----------          -----
                0 Parent    MainWindowHandle        0
                0 Parent    ProcessName          pwsh
                1 Parent    MainWindowHandle        0
                1 Parent    ProcessName          Code
                2 Parent    MainWindowHandle  6685268
                2 Parent    ProcessName          Code
                3 Parent    MainWindowHandle  1574506
                3 Parent    ProcessName      explorer
    #>

    [CmdletBinding()]
    [Alias('Fetch.RecurseProp')]
    param(
        $InputObject,

        [ArgumentCompletions(
            'Parent' )]
        [string]$DescendPropertyName = 'Parent',


        [ArgumentCompletions(
            'MainWindowHandle' )]
        [string[]]$AccessPropertyNames,

        # Check out -Verbose for a warning message when max depth is exceeded
        [int]$MaxDepth,

        # default sorting tab completes
        [ArgumentCompletions(
          "'MemberName', 'Depth'",
          "'Depth', 'MemberName'"
        )]
        [string[]]$OrderBy,
        [ArgumentCompletions(
            '@{ IgnoreUndefinedMembers = $false }'
        )]
        [hashtable]$Options = @{},
        [switch]$PassThru
    )
    $Config = nin.MergeHash -OtherHash ($Options ?? @{}) -BaseHash @{
        IgnoreUndefinedMembers = $true
    }
    [uint]$depth = 0
    $target = $InputObject

    [List[Object]]$FoundItems = @()
    do {
        foreach($curAccessName in $AccessPropertyNames) {
            [bool]$propIsDefined = $Target.PSObject.Properties.Name -contains @( $curAccessName )
            $foundItems.Add([pscustomobject]@{
                PSTypeName   = 'dotils.FetchRecuresProperty.Result'
                Depth        = $Depth
                DescendBy    = $DescendPropertyName
                MemberName   = $curAccessName
                MemberExists = $propIsDefined
                Value        = $Target.$curAccessName
            })
        }

        $Depth++
        if( $PSBoundParameters.ContainsKey('MaxDepth') -and ( $Depth -gt $MaxDepth)){
            write-verbose 'early exit on max depth'
            break
        }

        $target = $Target.$DescendPropertyName
    } until ( $null -eq $target )

    if( $OrderBy ) {
        $foundItems = $foundItems | Sort-Object -Prop $OrderBy
    } else {
        $foundItems = $foundItems | Sort-Object -Prop 'DescendBy', 'Depth', 'MemberName'
    }

    if($PassThru) { return $foundItems }

    if($Config.IgnoreUndefinedMembers) {
        $foundItems = $foundItems | ?{ $_.MemberExists }
    }

    return $foundItems
}

Update-TypeData -typename 'dotils.FetchRecuresProperty.Result' -DefaultDisplayPropertySet Depth, DescendBy, MemberName, Value -Force

function Dotils.Fetch.RecurseProperty.Render {
    <#
    .synopsis
        render a Dotils.Fetch.RecurseProperty
    .EXAMPLE
        Pwsh>
        $query = Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName 'ProcessName',MainWindowHandle -OrderBy 'Depth', 'MemberName' -MaxDepth 5
        $query | ft
        $query | Render.RecurseProp
    #>
    [Alias('Render.RecurseProp')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='FromPipe')]
        [Parameter(Mandatory, Position=0, ParameterSetName='FromParam')]
        [object[]]
        $InputObject,

        [Alias('Bat')][switch]$OutBat
    )
    begin {
        [List[Object]]$items = @()
    }
    process {
        if( -not  $PSCmdlet.MyInvocation.ExpectingInput ) {
            $Items = $InputObject
        } else {
            $Items.AddRange(@( $InputObject ))
        }
    }
    end {
        $requirePad =
            $items.MemberName | % Length | Measure-Object -Maximum | % Maximum

        [string[]]$render = $items | %{
            $prefix =  '  ' * $_.Depth -join ''
            Join-String -f "${prefix}{0}" -in $_ -Property {@(
                $_.MemberName.PadLeft( $requirePad, ' ' )
                ': '
                $_.Value
            ) -join ''}
        } | Join-String -sep "`n"

        if($OutBat) {
            $pagerTitle = @(
                ($items)?[0].DescendBy
                ' => '
                $items.MemberName | Join-String -sep ', '
            ) -join ''
            [List[Object]]$BinArgs = @(
                '-l', 'yml'
                '-f'
                '--file-name', $PagerTitle
            )
            $render | bat @binArgs
            return
        }

        return $render
    }
}

filter Dotils.Convert.Resolve.Command {
    <#
    .DESCRIPTION
    experimenting with syntax. sometimes ternary with filters
    simplify super short, macros.
    this is not a style recommendation
    .EXAMPLE
        # these options all resolve to one command.
        > 'label'    | Convert.Resolve.Command
        >  gcm label | Convert.Resolve.Command
        > (gcm label).ResolvedCommand | Convert.Resolve.Command
        > (gcm label).ResolvedCommand.Name  | Convert.Resolve.Command
    #>
    [Alias('Convert.Resolve.Command' )]
    param()
    $t = $_ -is [string] ? (gcm $_) : $_
    -not $t.ResolvedCommand ? $t :
         (gcm $t.ResolvedCommand)
}

function Dotils.Fetch.RecurseProperty.Basic {
    <#
    .SYNOPSIS
        find recursive properties
    .DESCRIPTION
        sugar for situations where you need to test a property by descending an unknown depth

        $p.MainWindowHandle
        $p.Parent.MainWindowHandle
        $p.Parent.Parent.MainWindowHandle ....
        $p.Parent.Parent.Parent.MainWindowHandle
    .EXAMPLE
        Fetch.RecurseProp -InputObject (ps -Id $PID) -DescendPropertyName Parent -AccessPropertyName Name
        Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowTitle
        Fetch.RecurseProp -InputObject (ps -id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowTitle
    .EXAMPLE

        Depth Property Value
        ----- -------- -----
            0 Parent   pwsh
            1 Parent   Code
            2 Parent   Code
            3 Parent   explorer
    .EXAMPLE
        Fetch.RecurseProperty -InputObject (Get-Process -Id $PID) -DescendPropertyName Parent -AccessPropertyName MainWindowHandle

        Depth Property   Value
        ----- --------   -----
            0 Parent         0
            1 Parent         0
            2 Parent   1707656
            3 Parent   1574506
    #>
    [Alias('Fetch.RecurseProp.Basic')]
    param(
        $InputObject,

        [ArgumentCompletions(
            'Parent' )]
        [string]$DescendPropertyName = 'Parent',


        [ArgumentCompletions(
            'MainWindowHandle' )]
        [string]$AccessPropertyName,

        [int]$MaxDepth
    )
    $depth = 0
    $target = $InputObject

    do {
        [pscustomobject]@{
            Depth    = $Depth
            Property = $DescendPropertyName
            Value    = $Target.$AccessPropertyName
        }

        $Depth++
        if( $PSBoundParameters.ContainsKey('MaxDepth') -and ( $Depth -gt $MaxDepth)){
            write-verbose 'early exit on max depth'
            break
        }

        $target = $Target.$DescendPropertyName
    } until ( $null -eq $target )
}
filter Dotils.Convert.ScriptBlock.asRange {
    <#
    .SYNOPSIS
        sugar because ranges aren't convient to use in interactive mode
    .EXAMPLE
        # return positions or vscode path

        > gcm DoStuff | Convert.ScriptBlock.asRange | Join-string -sep ', '
            13, 13, 16, 14

        > gcm DoStuff | Convert.ScriptBlock.asRange -AsVsCodePath
            H:\data\2023\pwsh\notebooks\Pwsh\Other\QueryRegistryKeysWithResults.ps1:13:13

    .EXAMPLE
        # opens function in vscode at the correct line and columns:
        > code -g ( gcm DoStuff | Convert.ScriptBlock.asRange -AsVsCodePath )
    .EXAMPLE
        > . 'QueryRegistryKeysWithResults.ps1'
        > $what = gcm DoStuff
        > $where = $what.ScriptBlock.File  | gi -ea 'stop'
        > $rng   = $what | Convert.ScriptBlock.asRange
        > $pos   = $rng  | Select -First 2 | Join-String -sep ':'

        # code --goto (Join-string -f "{0}:$Pos" -in $where)
    .EXAMPLE
        > $what | Convert.ScriptBlock.asRange | Join-String -sep ', '
            13, 13, 16, 14

        > $what | Convert.ScriptBlock.asRange -AsVsCodePath
            H:\data\2023\pwsh\notebooks\Pwsh\Other\QueryRegistryKeysWithResults.ps1:13:13
    #>
    [Alias('Convert.ScriptBlock.asRange')]
    param(
        [Alias('-Goto')] # sily alias, allows --Goto like vs code uses. it does not autocomplete
        [switch]$AsVsCodePath
        # [switch]${-GoTo}
    )
    # $EaSplat = @{ ErrorAction = 'continue' } # redundant since the scriptblock file is valid
    # if( $AsVsCode ) {
    #     $EaSplat.ErrorAction = 'stop'
    # }
    [ScriptBlock]$ScriptBlock = $_ -is [ScriptBlock] ? $_ : $_.ScriptBlock
    [Ast]$Ast         = $_ -is [Ast] ? $_ : $_.ScriptBlock.Ast

    if( -not $Ast ) {
        Join-String -f 'Could not resolve ScriptBlock.Ast: Unhandled input type: "{0}"' -in $_ -Property { $_.GetType() }  | Write-error
        return }
    if( -not $ScriptBlock ) {
        Join-String -f 'Could not resolve ScriptBlock: Unhandled input type: "{0}"' -in $_ -Property { $_.GetType() }  | Write-error
        return }

    if( $AsVsCodePath ) {
        # builds path: 'foo.ps1:304:23
        return ( Get-Item -ea 'stop' $ScriptBlock.File ),
            $Ast.Extent.StartLineNumber,
            $Ast.Extent.StartColumnNumber
        | Join-String -sep ':'
    }
    # else returns 304,23,400, 10
    $Ast.Extent.StartLineNumber, $Ast.Extent.StartColumnNumber, $Ast.Extent.EndLineNumber, $Ast.extent.EndColumnNumber

}

function Dotils.Convert.Regex.FromMatchGroup {
    <#
    .synopsis
        converts resutls of [Regex]::Matches
    .description

    expected input input from [Regex]::Matches() which returns
        type: [Match] > [Text.RegularExpressions.Match]
        pstypenames: [Match], [Group], [Capture] > Text.RegularExpressions.*
    .EXAMPLE
        $found.q | Dotils.Convert.Regex.FromMatchGroup -PreserveNumberedGroups -ReturnKeyNamesOnly | Join-String -sep
        ', '
        0, FieldName, FieldValue, OuterTextFromNoQuoteRecord, ValueWithQuotesOrNot
    #>
    [Alias('Convert.Regex.MatchGroup')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$FoundRecords,
        [switch]$PreserveNumberedGroups,

        # returns every possible named capture group, that found
        # something in at least one or more collections
        [switch]$ReturnKeyNamesOnly
    )
    end {
        $LineId = 0
        $query = @(
            $FoundRecords | %{
                $LineId++
                $FieldId = 0
                $_.Groups.
                    Where({ $_.Success }).
                    Where({
                        $PreserveNumberedGroups ?
                            $true :
                            $_.Name -notmatch '^\d+$' })
                | %{
                    [pscustomobject]@{
                        LineId = $LineId
                        FieldId     = $FieldId++
                        Name    = $_.Name
                        Value   = $_.Value
                    }
                }
            }
        )
        if( $ReturnKeyNamesOnly ) {
            return $query.Name | Sort-Object -Unique
        }
        $query
    }
}

function Dotils.EventViewer.FindRecentDefenderLogs {
    <#
    .synopsis
        Search for WindowsDefender logs when there's something detected
    .EXAMPLE
        > Dotils.Events.Defender
    #>
    [Alias('Dotils.Events.Defender')]
    [OutputType('System.Diagnostics.Eventing.Reader.EventLogRecord')]
    [CmdletBinding()]
    param(
        # date param
        [int] $Days = -1,

        # don't pre-filter logs that are noise
        [switch] $PassThru
    )
    # Define the log name and time range
    $logName   = "Microsoft-Windows-Windows Defender/Operational"
    $startTime = (Get-Date).AddDays( $Days ) # 24 hours ago

    # Query the event log
    $when = $startTime.ToUniversalTime().ToString('o')
    $getWinEventSplat = @{
        LogName     = $logName
        FilterXPath = "*[System[TimeCreated[@SystemTime>='${when}']]]"
    }
    $getWinEventSplat | ConvertTo-Json -depth 9
        | Join-String -op 'EventViewer: ' | Dotils.Write-DimText -PSHost

    $query = Get-WinEvent @getWinEventSplat

    if( $PassThru ) { return $query }

    $clean_orig = $query
        | ?{
            $results = @(
                $_.Message -NotMatch ([Regex]::Escape('Endpoint Protection client is up and running in a healthy state'))
                $_.Message -match [Regex]::Escape( 'Microsoft Defender Antivirus has taken action' )
                $_.Message -match [Regex]::Escape( 'Microsoft Defender Antivirus has detected' )
                $_.Message -notmatch [Regex]::Escape( 'Endpoint Protection client health report' )
                ( $false ? $true : $_.LevelDisplayName -ne 'Information' ) # some are wanted, like take action
            )
            return ($results -eq $true).count -gt 0
        }


        $clean = $query
            | ?{
                (
                    (
                        $_.Message -NotMatch [Regex]::Escape('Endpoint Protection client is up and running in a healthy state')
                    ) -and (
                        $_.Message -notmatch [Regex]::Escape( 'Endpoint Protection client health report')
                    )
                ) -and (
                    (
                        $_.Message -match [Regex]::Escape( 'Microsoft Defender Antivirus has taken action' )
                    ) -or (
                        $_.Message -match [Regex]::Escape( 'Microsoft Defender Antivirus has detected' )
                    )
                )
                # ( $false ? $true : $_.LevelDisplayName -ne 'Information' ) # some are wanted, like take action
            }




    'Found {0} logs, filtered to {1}' -f @(
        $query.count
        $clean.count
    )   | Dotils.Write-DimText -PSHost

    return $clean
}

function Dotils.CommandInfo.ScriptMethodParams {
    <#
    .SYNOPSIS
        Quickly show params for ScriptMethods, like EzOut\Types\Name.ps1
    .EXAMPLE
        $GitLogger.hasRoute | ScriptMethodParams | ft
    .EXAMPLE
        $PSSVG.Show | ScriptMethodParams | Ft

        Attributes                                    Name
        ----------                                    ----
        {Parameter, PSObject[]}                       $Content
        {Parameter, PSObject[]}                       $Metadata
        {Parameter, Alias, PSObject[]}                $DataRow
        {Parameter, string}                           $Title
        {Parameter, Alias, int}                       $CopyCount
    #>
    [Alias(
        'Quick.ScriptMethodParams',
        'ScriptMethodParams'
    )]
    param(
        [Parameter(Mandatory, ValueFromPipeline )]
        [object] $InputObject )

    process {
        $InputObject.Script.Ast.ParamBlock.Parameters
    }
}
function Dotils.Select-VariableByType {
    <#
    .SYNOPSIS
        I forget
    .EXAMPLE
    Pwsh> # try a bunch scopes
        Dotils.Select-VariableByType -ListCategory -Scope local
        Dotils.Select-VariableByType -ListCategory -Scope global
        Dotils.Select-VariableByType -ListCategory -Scope 0
        Dotils.Select-VariableByType -ListCategory -Scope 1
        Dotils.Select-VariableByType -ListCategory -Scope 2

    # some output

     Count Name
     ----- ----
        20 System.String
        12 System.Collections.Hashtable
        10 System.Boolean
        7 System.Management.Automation.ActionPreference
        4 System.Collections.Generic.List`1[System.Object]
        4 System.Int32
        3 System.IO.DirectoryInfo
        2 System.IO.FileInfo
        # ...
    #>
    [Alias('Dotils.Find-VariableByType')]
    [CmdletBinding()]
    param(
        # if not specified, uses get-variable
        [ValidateScript({throw 'nyi'})]
        [Parameter(ParameterSetName='FromInput', ValueFromPipeline)]
        $InputObject,

        [string[]]$TypePattern,
        # get-var command doesn't support array, so will need to enmerate
        [string]$Scope,

        [switch]$ListCategory
    )

    write-warning 'superceded by: Picky\Picky.ConvertFrom.RegexCollection'

    $OptionalParams = @{}
    if($PSBoundParameters.ContainsKey('scope')){
        $OptionalParams['Scope'] = $Scope
    }

    $query = @(  Get-Variable @OptionalParams )
    if($ListCategory) {
        $grouped =
            $query
            | Group-Object { ($_.Value)?.GetType() } -NoElement
            | Sort-Object Count -Descending | select Count, Name

        $grouped
        return
    }

    $query
        | ?{
            $Target = $_.Value
            $targetType = ($Target)?.GetType()
            $shortType = $TargetType | Format-ShortTypeName
            foreach($pattern in $TypePattern) {
                if($targetType -match $pattern) { return $true }
                if($targetType -match [Regex]::Escape($Pattern)) { return $true }
                if($shortType -match $pattern) { return $true }
                if($shortType -match [Regex]::Escape($Pattern)) { return $true }
            }
        }

    # | group  { ($_.Value)?.GetType() } | sort-Object | ft -AutoSize Count, Name

}
function Dotils.Add-PsModulePath {
    <#
    .SYNOPSIS
        sanitize paths, updating psmodulepath

    .NOTES
        future: todo: make case-insensitive hashset, there's a FileInfo example somewhere.
    .EXAMPLE
        Dotils.Add-PsModulePath -PrependPath -InputPath 'H:\data\2023\pwsh\PsModules.👨.Import'

    #>
    [OutputType('string')] # or nothing
    [CmdletBinding(DefaultParameterSetName='AddAsSuffix')]
    param(
        # filepath to add
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('PSPath', 'Path')]
        [string]$InputPath,

        # error if the path doesn't yet exist?
        [Alias('Strict')][switch]$AssertPathExists = $true,

        [Parameter(ParameterSetName='AddAsPrefix', Mandatory)]
        [Alias( 'Prefix', 'AddAsPrefix')][switch]$PrependPath,

        [Parameter(ParameterSetName='AddAsSuffix')]
        [Alias('AddAsSuffix')][switch]$AppendPath,

        [Alias('WhatIf')][switch]$TestOnly,
        # return new value as string
        [switch]$PassThru
    )

    # write-error 'logic below might be slighlty wrong from pasting'
    # return
    # write-error 'left off, test func runs right'
     write-warning 'slightly NYI, validate working'

    'Dotils.Add-PsModulePath::Add => {0}' -f @( $InputPath )
        | write-verbose

    write-warning ' ==> early exit before test'
    return

    $info = [hashtable]::new( $PSBoundParameters )
    $info.GetEnumerator()
        | %{ # don't JSON render json filepaths as a bomb
            $_.Key, $_.Value -join ' = '
        }
        | Join-String -sep ', ' -op 'PSBoundParameters: '
        | write-debug


        if(-not (Test-Path $InputPath)) {
            if($AssertPathExists){
                throw "PathNotFoundException: '$InputPath'"
            }
        }
        return
        write-error "PathNotFoundException: '$InputPath'"


    # mostly redundant
    if($AssertPathExists ) {
        $Path? = gi -ea 'stop' -LiteralPath $InputPath
        throw "PathNotFoundException: '$InputPath?'"
    } else {
        $Path? = gi -ea 'ignore' -LiteralPath $InputPath
        $Path? ??= $InputPath
    }
    $Delim = [IO.Path]::PathSeparator
    $Items = @(
        $Env:PSModulePath -split $Delim -inotmatch [regex]::Escape( $InputPath )
            | ?{ $_ } # and drop blanks
    )

    $renderPaths = if($PSCmdlet.ParameterSetName -eq 'AddAsPrefix') {
        @( $Path?, $Items ) | Join-String -sep $Delim
    } else {
        @( $Items, $Path? ) | Join-String -sep $Delim
    }
    $Env:PSModulePath
        | Join-String -op "old value `$PSModulePaths => `n"
        | Write-Debug
    $renderPaths
        | Join-String -op "new value `$PSModulePaths => `n"
        | Write-Debug

    if( $TestOnly ) {
        'TestOnly: Would have set $Env:PSModulePath to: {0}' -f @( $renderPaths )
            | Write-Verbose
        return
    }
    $Env:PSModulePath = $renderPaths
    if($PassThru) {
        return $Env:PSModulePath
    }
}
function Dotils.Resolve.Command {
    <#
    .synopsis
        Resolve Command From String or Objects
    .notes
        I feel like this is resolve, rather than ConvertTo
        Or an transformation attribute
    .example
        PS> (gcm Label | Resolve.Command -Clipboard)
        # copies: "Ninmonkey.Console\Write-ConsoleLabel"
    .example
        (gcm Write-ConsoleLabel | Resolve.Command) -eq ( gcm Write-ConsoleLabel )
        # returns: True
    .example
        Get-alias | Resolve.Command | Get-Random -Count 20
            | sort Name, Source | ft -AutoSize

        CommandType Name                                    Version   Source
        ----------- ----                                    -------   ------
        Function    Copy-RelativeItemTree                   0.2.49    Ninmonkey.Console
        Function    Dotils.ConvertTo-TimeSpan               0.0       dotils
        Function    Dotils.Describe.Timespan.AsMilliseconds 0.0       dotils
        Function    Dotils.Format-Datetime                  0.0       dotils
        Function    Dotils.Format.Write-DimText             0.0       dotils
        Function    Dotils.Is.KindOf                        0.0       dotils
        Function    Dotils.LogObject                        0.0       dotils
        Cmdlet      ForEach-Object                          7.3.6.500 Microsoft.PowerShell.Core
        Function    Format-Html.Table.FromHashtable
        Cmdlet      Format-Wide                             7.0.0.0   Microsoft.PowerShell.Utility
        Function    Get-NinVerbName                         0.2.49    Ninmonkey.Console
        Function    GoClip
        Function    Goto-Module                             0.2.49    Ninmonkey.Console
    #>
    [Alias(
        'Resolve.Command' # , 'Dotils.ConvertTo-Command'
    )]
    [OutputType('System.Management.Automation.CommandInfo')]
    [CmdletBinding()]
    param(
        # Accepts [string], [CommandInfo], [AliasInfo], and possibly more
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject,

        # Will render the the source ModuleName\CommandName"
        [Alias('CopyIt', 'FullyResolvedId')][switch]$Clipboard

    )
    begin {
        [string[]]$FinalClip = ''
    }
    process {
        $InputObject | Format-ShortTypeName | Join-String -op 'typeof: ' | write-verbose
        switch($InputObject) {
            { $_ -is 'String' } {
                $resolved = Get-Command $_ | Dotils.Resolve.Command
            }
            { $_ -is 'Management.Automation.AliasInfo'} {
                $resolved = $_.ResolvedCommand
            }
            default {
                write-verbose "DefaultHandlingFallback: For $($InputOBject | Format-ShortTypeName)"
                $resolved = $_
            }
        }

        if($CLipBoard) {
            $finalClip +=
                Join-String -sep '\' -Inp @( $resolved.Namespace, $resolved.Name )
        }
        return $resolved
        <#
        props:
            .Module # -is [PSModuleInfo]
            .CommandType # -is [CommandType]

            # ... -is [string]
            Definition, ModuleName, Name, Source

        alias info:
            $InputObject| iot2

        Name                Reported                                                                                  Value
        ----                --------                                                                                  -----
        CommandType         [CommandTypes]                                                                            Alias
        Definition          [string]                                                   Ninmonkey.Console\Write-ConsoleLabel
        DisplayName         [object]                                                            Label -> Write-ConsoleLabel
        Module              [PSModuleInfo]                                                                Ninmonkey.Console
        ModuleName          [string]                                                                      Ninmonkey.Console
        Name                [string]                                                                                  Label
        Options             [ScopedItemOptions]                                                                        None
        Parameters          [Dictionary<string, ParameterMetadata>] …tor, System.Management.Automation.ParameterMetadata]…}
        ReferencedCommand   [CommandInfo]                                                                Write-ConsoleLabel
        RemotingCapability  [RemotingCapability]                                                                 PowerShell
        ResolvedCommand     [CommandInfo]                                                                Write-ConsoleLabel
        ResolvedCommandName [object]                                                                     Write-ConsoleLabel
        Source              [string]                                                                      Ninmonkey.Console
        Version             [Version]                                                                                0.2.49
        Visibility          [SessionStateEntryVisibility]                                                            Public

        [FunctionInfo]
            [ScopedItemOptions]
            [CommandTypes]
            [PSModuleInfo]

        #>

    }
    end {
        if($Clipboard) {
            $finalClip
                | ?{ -not [string]::IsNullOrWhitespace( $_ ) }
                | CountOf 'Copied...'
                | Set-Clipboard -PassTHru
                | Dotils.Write-DimText | wInfo

                # | write-information -infa 'continue'
        }
    }
}

function Dotils.Format-RenderBlankable {
    <#
    .SYNOPSIS
        surely duplicated elsewhere. renders common blankable or nullable strings as human-visible
    .EXAMPLE

    Pwsh> $Null, 'dfs', ' ' , '' | %{
            [pscustomobject]@{
                Input = $_ | fcc
                Render = Format-RenderBlankable $_
                Type = ( $_ )?.GetType().Name ?? '<null>'
                InputRaw  = $_
            }
        }

    # outputs

        Input Render     Type   InputRaw
        ----- ------     ----   --------
        ␀     ␀          <null>
        dfs   dfs        String dfs
        ␠     [Blank]    String
              [EmptyStr] String

    #>
    param(
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(Mandatory, Position=0)]
        $InputObject
    )
    $Uni = @{
        Null     = "`u{2400}"
        Space    = "`u{2420}"
        Blank    = '[Blank]'
        EmptyStr = '[EmptyStr]'
    }
    [string]$WithoutSpace = $InputObject -replace '\s+', ''
    [bool]$isBlankable    = [String]::IsNullOrWhiteSpace( $InputObject )

    if( $null -eq $InputObject ) { return $Uni.Null }
    if( $InputObject -is 'string' ) {
        if( $InputObject.Length  -eq 0) { return $Uni.EmptyStr }
        if( $WithoutSpace.Length -eq 0) { return $Uni.Blank }
    }
    if($IsBlankable) { return $Uni.Blank}

    return $InputObject #passes final value through if not changed
}

function Dotils.Test-IsOfType.Basic {
    <#
    .SYNOPSIS
        Is something one of a type list? sugar for filtering objects by types
    .description
        see also, the TypeInfo is subclass
        related:
            Dotils.Is.SubType

    .example
        Warning: the current behavior returns the <object> that passed the test
        this may be unexpected. maybe add another param,
            - passsThru: returns the good object, as the original type
            - not passTHru: returns the object after coercion to the new type
    .example
        @( get-item .; get-date; 34; 9.1; 'hi world', ([Text.Rune]::new(0x2400)))
    .example
            # filter kinds

            123, 24.65, '99' | .Is.Type -TypeNames 'int'
                # out: [123] # | Json -AsArray -Compress

            123, 24.65, '99' | .Is.Type -TypeNames 'int' -AllowCompatibleType
                # out: [123,24.65,"99"] # | Json -AsArray -Compress
w
    .LINK
        Dotils.Test-IsOfType.FancyWip
    .LINK
        Dotils.Test-IsOfType
    .LINK
        Dotils.Is.SubType
    #>
    [CmdletBinding(
        # DefaultParameterSetName = 'AsRegex'
    )]
    [Alias(
        '.Is.Type', '.Is.OfType', 'Dotils.Test-IsOfType'
        )]
    param(
        <#
        .SYNOPSIS
        is a type one of types?

            Dotils.Test-IsOfType ([PoshCode.Pansies.RgbColor]) -Debug -AsTest -AllowCompatibleType -InputObject 'red'
            Dotils.Test-IsOfType ([PoshCode.Pansies.RgbColor]) -Debug -AsTest -InputObject 'red'


        #>
        # A list of types to compare against, using the -is, sort of
        [Parameter(Mandatory, Position=0, ParameterSetName='ByType')]
        [Alias('Name', 'IsType')]
        [ArgumentCompletions(
            'double', 'int', 'int32', 'int64', 'uint32', 'uint64',
            'float',
            'Datetime', 'Timespan', 'CommandTypes'
        )]
        [string[]]$TypeNames,
        [Parameter(Mandatory, Position=0, ParameterSetName='ByGroup')]
        [Alias('Category', 'Group', 'IsKind')]
        [ArgumentCompletions(
            'double', 'int', 'int32', 'int64', 'uint32', 'uint64',
            'float',
            'Datetime', 'Timespan', 'CommandTypes'
        )]
        [string[]]$TypeCategoryNames,

        # # literals escaped for a regex
        # [Parameter(Mandatory, Position=0, ParameterSetName='AsLiteral')]
        # [string]$Literal,

        # # If not set, and type is not string,  tostring will end up controlling what is matched against
        # [Parameter(Position=1)]
        # [string]$PropertyName,

        # strings, or objects to filter on
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # if a test, return a boolean
        # if not, filter objects
        [Parameter(Mandatory, ParameterSetName='ReturnAstTest')]
        [switch]$AsTest,

        # if it fails, maybe -as type coercion will work
        [switch]$AllowCompatibleType,

        # return orignal types
        [switch]$PassThru


        # when no property is specified, usually nicer to try the property name than tostring
        # [switch]$AlwaysTryProp = $true
    )
    begin {
        # function __resolve.TypeInfo {
        #     param(
        #         $InputObject
        #     )
        #     if($InputObject -is 'type') {
        #         return $InputObject
        #     }
        #     return ($InputObject)?.GetType()
        #     $tinfo = @($InputObject.GetType()
        # }


    }
    process {
        [bool]$ReturnAsCoercedValue = -not $PassThru
        if( $PassThru  ) { throw 'command future creep, refactor' }
        if( $PSCmdlet.ParameterSetName -eq 'ByGroup') {
            throw 'quickhack'

        }
        $lastGoodType = 'object'
        [bool]$anyMatches = $false
        [bool]$ShouldReturnBool = $AsTest
        if( [string]::IsNullOrWhiteSpace( $TypeNames ) ) {
            throw 'BadArgumentsException: -TypeNames was empty'
        }
        foreach($CurObj in $InputObject) {
            [bool]$shouldKeep? = $false

            foreach($name in $TypeNames) {
                write-debug "    Test-IsOfType: comparing CurObj is $Name"
                if($curObj -is $Name) {
                    $shouldKeep? = $true
                    $anyMatches = $true
                    break
                }
            }
            # is this redundant?
            if(-not $ShouldKeep -and $AllowCompatibleType) {
                write-debug "    -is compares failed, trying -as..."
                foreach($name in $TypeNames) {
                    write-debug "    Test-IsOfType: comparing CurObj is $Name"
                    if($curObj -as $Name -ne $null) {
                        $shouldKeep? = $true
                        $lastGoodType = $Name
                        $anyMatches = $true
                        break
                    }
                }
            }
            if($ShouldKeep?) {
                @(
                    'AllowCompatible? {0}' -f $AllowCompatibleType
                    'ReturnAsCoerced?: {0}' -f $ReturnAsCoercedValue
                    'LastGoodType?: {0}' -f $lastGoodType
                ) | Join-String -sep ', ' | Join-String -sep "`n" |  write-verbose
                if(-not $ReturnAsCoercedValue ) {
                    $curObj
                } else {
                    $curObj -as $LastGoodType
                }
            }
        }
        if( -not $MyInvocation.ExpectingInput ) {
            return $anyMatches
        }
    }
}
function Dotils.Describe.Timespan.AsMilliseconds {
    <#
    .SYNOPSIS
        render units automatically using the right properties and format for user UX
    .example
        [datetime]::Now.AddMilliseconds(1234) - (get-date)
            | Ms

        #output: 1,232.97 ms
    .LINK
        Dotils.Describe.Timespan.AsMilliseconds
    .LINK
        Dotils.Describe.Timespan.AsSeconds
    .LINK
        Dotils.Format.Datetime
    #>
    [OutputType('String')]
    [Alias('Ms', '.Render.Ms')]
    param()
    process {
        $Obj = $_
        if($Obj -is 'int') {
            $Obj | Join-String -f '{0:n2} ms'
            return
        }
        $Obj | Dotils.ConvertTo.TimeSpan
        | Join-String -f '{0:n2} ms' TotalMilliseconds
        # $Obj -as [timespan] } else { $null }
} }

'finish: Dotils.Format-Datetime' | Dotils.Write-DimText | write-host
function Dotils.Format-Datetime {
    <#
    .synopsis
        suger for some datetimes
    .notes
    wip: future: autobuild this list for a dynamically updated
    .link
        Dotils.Describe.Timespan.AsMilliseconds
    .link
        Dotils.Describe.Timespan.AsSeconds
    .link
        Dotils.Format.Datetime
    #>
    [Alias('.fmt.Datetime', 'Dotils.Format.Datetime')]
    [CmdletBinding()]
    param(
        # nyi: todo: completers will show descriptions
        [Parameter()]
        [ArgumentCompletions(
            'o', 'u', 'ShortDate', 'ShortTime'
        )]
        [string]$TemplateName = 'template',

        [Parameter(mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias(
            'LastWriteTime', 'Date', 'Datetime', 'When', 'Time'
        )]
        [object]$InputObject
    )
    $ResolvedFormatString = switch( $TemplateName ) {
        'ShortDate' { 'd' }
        'ShortTime' { 't' }
        default { $PSItem }
    }
    $Config = nin.MergeHash -other $Options -base @{
        Culture = 'en-us'
    }
    $InputObject | Format-ShortTypeName | Join-String -op 'Format.Datetime => ' | write-verbose
    switch($InputObject) {
        ($_ -is 'datetime') {
            $Target = $_
        }
        ({ .Has.Prop LastWriteTime Exists -AsTest -Inp $_ }) {
            $Target = $_.LastWriteTime
        }
        { $_ -is 'string' } {
            $Target = $_ -as 'datetime'
        }
        default {
            'invalid type? {0} attempt to coerce to datetime' -f @( $_ | Format-ShortTypeName )  | write-verbose
            $target = $_ -as 'datetime'
        }
    }
    if($null -eq $Target) {
        'invalid type, could not find a datetime! {0}' -f @( $_ | Format-ShortTypeName ) | write-error
        return
    }
    $Target = if($InputObject -is 'datetime') { $InputObject } else { $InputObject.CreationTime }
}

function Dotils.Format-HexString {
    <#
    .SYNOPSIS
        converts numbers or strings to hexstrings
    .EXAMPLE
        'hi 🐒 world' | Dotils.Format-HexString
            | Join-string -sep ', '

        68, 69, 20, 1f412, 20, 77, 6f, 72, 6c, 64
    .EXAMPLE
        244, 200 | Dotils.Format-HexString|Join-string -sep ', '

    .example
        # original func:
        ($_ ?? '').EnumerateRunes().value | Join-string -sep ' ' -f "`n{0,6:x}"
    #>
    [CmdletBinding()]
    [Alias(
        '.As.HexString',
        'fmt.HexString',
        'HexString'
    )]
    param(
        [Alias('Text')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject,

        [switch]$AlignRightSwitch,
        [switch]$PadZerosSwitch,

        [ValidateScript({throw 'Formatting for command is NYI'})]
        [ValidateSet(
            'PowerShell.Literal', # ex: "`u{2400}"
            'PowerQuery.Literal', # ex: "#(00002400)"
            'WebColor' # ex: "#123123" or "#123123ff"
        )]
        [string]$OutputFormat,

        [ArgumentCompletions(
            '@{ PrefixWithHex = $true }',
            '@{ PrefixAsHexColor = $true }',
            '@{ PrefixWithU = $true }'
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -OtherHash $Options -Base @{
            FormatStr = '{0:x}'
            WriteNullSymbolWhenNull = $true
            PrefixWithU = $false
            PadZero = $PadZerosSwitch
        }
        if($AlignRight) {
            $Config.FormatStr = '{0,6:x}'
        }
        # if($Config.PrefixWithU) {
        #     $Config.FormatStr = 'U+', $Config.FormatStr -join ''
        # }

    }
    process {
        $Obj = $InputObject
        if($null -eq $Obj -and $Config.WriteNullSymbolWhenNull) {
            return "`u{2400}" # null symbol or emit nothing?
        }


        # $fStr = $Config.FormatStr # if($AlignRight) { '{0,6:x}' } else { '{0:x2}' }
        if($Obj -is 'string') {
            $values = $Obj.EnumerateRunes() | % Value
        } else {
            write-verbose 'try non-string enumeration'
            $values = $Obj
        }
        foreach($item in $values) {
            [string]$render = $Config.FormatStr -f $Item
            if($Config.PadZero) {
                $render = $render.PadLeft(6, '0')
            }
            if($Config.PrefixWithU) {
                $render = 'U+', $render -join ''
            }
            if($Config.PrefixWithHex) {
                $render = '0x', $render -join ''
            }
            if($Config.PrefixAsHexColor) {
                $render = '#', $render -join ''
                # warning: doesn't pad, but, then, that's valid css...
            }
            $render
        }


    }
}
function Dotils.PowerBI.FindRecentLog {
    <#
    .SYNOPSIS
        find logs to parse
    .example
        Dotils.PowerBI.FindRecentLog -ChangedWithin 40minutes
            | Dotils.PowerBi.Parse.LogName
    .link
        Dotils.PowerBI.FindRecentLog
    .link
        Dotils.PowerBI.CaptureLogs
    #>
    param(
        [ArgumentCompletions( '2minutes', '20minutes', '1days', '20seconds')]$ChangedWithin = '5minutes'
    )
    $Sources = @{
        LocalTracesPerformance = gi (Join-path $Env:localAppData 'Microsoft/Power BI Desktop/Traces/Performance')
    }
    # gci -path $Sources.LocalTracesPerformance -Recurse -file *.log
    pushd -StackName 'pbi.capture' -Path (gi $Sources.LocalTracesPerformance -ea 'stop')
    $found = fd -e log --changed-within $ChangedWithin | gi
    popd -StackName 'pbi.capture'

    return $Found
}

function Dotils.PowerBI.CaptureLogs {
    <#
    .SYNOPSIS
        copy / save logs for profiling
    .example
        Pwsh> Saving logs literally this easy:
        Dotils.PowerBI.CaptureLogs -ChangedWithin 2minutes
    .link
        Dotils.PowerBI.FindRecentLog
    .link
        Dotils.PowerBI.CaptureLogs
    #>
    [CmdletBinding()]
    param(
            #[ValidateNotNullOrEmpty()]
            [Parameter()]
            [string]$SearchPath,
            [string]$Other,

            [ArgumentCompletions( '2minutes', '20minutes', '1days', '20seconds')]
            [string]$ChangedWithin = '2minutes'
    )

    $destRootPath = Join-path 'H:\datasource_staging_area\2023-09-03-PowerQueryTrace' (SafeFileTimeString)
    mkdir -path $destRootPath | OutNull
    'copy files to: {0}' -f $DestRootPath | Write-verbose

    Dotils.PowerBI.FindRecentLog -ChangedWithin $ChangedWithin | Copy-Item -Destination $destRootPath -PassThru | CountOf

    $files = gci -path $destRootPath *.log
    if($files.count -eq 0) {
        $destRootPath | gi | % Fullname
        'empty dir, removing it?' | write-verbose -verbose
        rm -Path $destRootPath
    }

    'wrote: {0}' -f $destRootPath | write-host

    return
   $SearchPath = [String]::IsNullOrEmpty( $SearchPath ) ? $(Join-Path $Env:LocalAppData 'Microsoft\Power BI Desktop\Traces\Performance') : $SearchPath
   if( [string]::IsNullOrEmpty( $SearchPath) ) { throw 'MissingSearchpath' }
   pushd -StackName 'pbi.capture' -Path (gi $Searchpath -ea 'stop')
   fd -e log --changed-within $ChangedWithin | gi
   popd -StackName 'pbi.capture'
}


function Dotils.PowerBI.ParseLog {
    <#
    .SYNOPSIS
        powerquery log tracing0
    #>
    param(
        [string]$LogPath,
        [ValidateSet(
            'Microsoft.Mashup.Container.NetFX45'
        )]
        [string]$LogFormatStyle = 'Microsoft.Mashup.Container.NetFX45'
    )


    function __importLog.MashupContainerBasic-v0 {
        param(
            [Parameter(Mandatory)]
            [string]$LogPath
        )
        # example filename: 'C:\Users\cppmo_000\AppData\Local\Microsoft\Power BI Desktop\Traces\Performance\Microsoft.Mashup.Container.NetFX45.28180.2023-09-04T00-06-44-036885.log'
        # gi (Join-Path $Env:LocalAppData 'Microsoft\Power BI Desktop\Traces\Performance\Microsoft.Mashup.Container.NetFX45.28180.2023-09-04T00-06-44-036885.log')
        gc $LogPath | %{ $_ -split '\{', 2  | select -Skip 1 |Join-String -op '{' | json.from }
    }
    function __importLog.MashupContainerBasic {
        param(
            [Parameter(Mandatory)]
            [string]$LogPath
        )
        $Regex = @{}
        $Regex.LogLine0 = @'
(?xi)
            # https://regex101.com/r/ll4eGo/1
            # Ex: DataMashup.Trace Information: 24579 : {"Start":"2023-09-04T00:20:36.9651477Z", ...}
            ^
            (?<Preamble>
            (?<Prefix>.*?)
            \s
            (?<SeverityLevel>\w+)

            )
            \s:\s
            (?<Json>
                \{
                .*
                \}
            )
            (?<Rest>.*)
            $
'@
        $Regex.LogLine = @'
(?xi)
        # https://regex101.com/r/ll4eGo/1
        # https://regex101.com/r/VAAT6X/1

        # Ex: DataMashup.Trace Information: 24579 : {"Start":"2023-09-04T00:20:36.9651477Z", ...}
        ^
        (?<Preamble>
            (?<Prefix>\S+)

            \s

            (?<SeverityLevel>\S*)

            \:\s+

            (?<Number>.*)
        )
        \s:\s
        (?<Json>
            \{
            .*
            \}
        )
        # (?<Rest>.*)
        $
'@
        # example filename: 'C:\Users\cppmo_000\AppData\Local\Microsoft\Power BI Desktop\Traces\Performance\Microsoft.Mashup.Container.NetFX45.28180.2023-09-04T00-06-44-036885.log'
        # gi (Join-Path $Env:LocalAppData 'Microsoft\Power BI Desktop\Traces\Performance\Microsoft.Mashup.Container.NetFX45.28180.2023-09-04T00-06-44-036885.log')
        gc $LogPath | %{
            $curLine = $_
            if($curLine -match $Regex.LogLine) {
                $matches.remove(0)
                [pscustomobject]$matches
             } else {
                'Failed Parsing line: {0}' -f $curLine
                | write-warning
             }
        }
    }

    switch($LogFormatStyle) {
        'Microsoft.Mashup.Container.NetFX45' {
            __importLog.MashupContainerBasic -LogPath $LogPath
        }
        default { throw "UnhandledLogFormat: $Switch" }
    }

    'don''t forget to try the the SDK to view query tracing a lot easier!'
        | New-Text -fg 'orange' -bg 'gray30' | write-host

    # |ft
}
function Dotils.PowerBi.Parse.LogName {
        <#
        .synopsis
            Get log metadata from the filename itself
        .example
            Dotils.PowerBI.FindRecentLog -ChangedWithin 40minutes
                | Dotils.PowerBi.Parse.LogName
        .example
        __parse.LogName -LogPath 'C:\Users\cppmo_000\AppData\Local\Microsoft\Power BI Desktop\Traces\Performance\Microsoft.Mashup.Container.NetFX45.15012.2023-09-04T00-29-41-341141.log'

            Source      : Microsoft.Mashup.Container
            App         : NetFX45.15012
            Rest        : 2023-09-04T00-29-41-341141.log
            WhenStr     : 2023-09-04T00-29-41-341141
            DateStr     : 2023-09-04
            TimeZoneStr : T00-29-41
        .notes
            see also: [Globalization.DateTimeStyles]
        #>
        [CmdletBinding()]
        param(
            # pipe or pass log name
            [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [Alias('PSPath', 'FullName', 'Path')]
            [string]$LogPath
        )
        process {

            # $names | nat 4 | %{
            #     $App, $Version, $Date, $rest   =  $_ -split '\.', -4
            # }
            'Parsing log: {0}' -f $LogPath | write-verbose

            $sampleDate = '2023-09-04T00-29-41'
            $dateString = '2023-09-04T00-29-41'
            $formatString = 'yyyy-MM-ddTHH-mm-ss'
            try {
                $When = [DateTime]::ParseExact($dateString, $formatString, $null)
            } catch {
                write-warning 'File appears to not be the same format'
                return
            }

            $Log = Get-Item $LogPath
            $crumbs = $Log.Name -split '\.'
            $whenStr = $crumbs | select  -Skip 5 -First 1

            # [datetime]::ParseExact(  ($zzz -split '-', -2 | select -First 1) , 'yyyy-MM-ddTHH-mm-ss', $null  )
            try {
                $parsedDate = [datetime]::ParseExact(
                    ($whenStr -split '-', -2 | select -First 1),
                    'yyyy-MM-ddTHH-mm-ss', $null )
                } catch {
                    write-warning 'File appears to not be the same format'
                    return
                }

            [pscustomobject]@{
                PSTypeName = 'Dotils.Powerbi.Parsed.LogName'
                Date    = $ParsedDate
                Source  = $crumbs | Select -First 3          | Join-string -sep '.'
                App     = $crumbs | Select  -Skip 3 -first 2 | Join-string -sep '.'
                # Rest    = $crumbs | Select  -Skip 5          | Join-string -sep '.'
                Path    = (gi -ea 'ignore' $Log.FullName) ?? $Log
                DateTimeStr = $crumbs | select  -Skip 5 -First 1
                DateStr = $crumbs[5].Substring(0, 10)
                TimeZoneStr = $crumbs[5].Substring(10, 9)
            }
        }
    }
function Dotils.Start-TimerToastLoop {
    [CmdletBinding()]
    param(
        [ValidateSet(
            'TimerOnly',
            'Alarm',
            'Silent.Toast'
        )]
        [string]$OutputMode = 'TimerOnly',

        [object]$SleepSeconds,
        [object]$Text

    )
    $Sound = 'Alarm'
    $Text ??= 'Alarm'
    $SleepSeconds ??= 60 * 7.5

    $PSCmdlet.MyInvocation.BoundParameters
        | ConvertTo-Json -Depth 0 -Compress
        | Join-String -op 'Start-ToastTimerLoop: ' -sep "`n"
        | write-verbose -verbose

    if($OutputMode -eq 'TimerOnly') {
        while($true) {
            get-date;
            sleep -Seconds $SleepSeconds
        }
        return
    }
    if($OutputMode -eq 'Alarm') {
        while($true) {

            new-BurntToastNotification -Text $Text -Sound $Sound
            get-date;
            sleep -Seconds $SleepSeconds
        }
        return
    }
    if($OutputMode -eq 'Silent.Toast') {
        while($true) {
            new-BurntToastNotification -Text $Text -Silent
            get-date;
            sleep -Seconds $SleepSeconds
        }
        return
    }
    throw "UnhandledOutputMode: $OutputMode"
}



[hashtable]$script:__cachedListState ??= @{}
function Dotils.Get-CachedExpression {
    <#
    .SYNOPSIS
        super, super, naive, 0cached values optionally save to disk
    .example
        # existing keys don't require scriptblock to read

        Dotils.Get-CachedListExpression -key 'all_commands' -Sb { Get-Command | % Name }
        Dotils.Get-CachedListExpression -key 'all_commands'
    .example
        Pwsh>
        TimeOfSb -Expression {
            .Cached.SB -KeyName 'mods' -Sb {
                Get-module -ListAvailable -All | outnull } } | Ms

        Caching 3309 items
        16,352.01 ms

        Pwsh>
        TimeOfSb -Expression {
            .Cached.SB -KeyName 'mods' -Sb {
                Get-module -ListAvailable -All | outnull } } | Ms

        Caching 3309 items
        1.53 ms

        # defined values don't require SB param
        TimeOfSb -Expression { .Cached.SB -KeyName 'mods' } | Ms

        Caching 3309 items
        8.53 ms
    .EXAMPLE
         Pwsh> .Cached.SB -List

         # im'sleep'
    .example
        TimeOfSb -Expression {
            .Cached.SB -KeyName 'mods' -Sb { Get-module -ListAvailable -All | outnull }  }  | Ms

        TimeOfSb -Expression {
            .Cached.SB -KeyName 'mods' -Sb { Get-module -ListAvailable -All | outnull }  }  | Ms
    .example
        TimeofSb -exp {
            $all_commands = Dotils.Get-CachedListExpression -key 'all_commands' -ScriptBlock {
                Get-Command -all  | % Name
            }
        }| Ms
    .DESCRIPTION
        get-module dotils
    #>
    [CmdletBinding()]
    [Alias('.Cached.SB')]
    param(
        # save result to disk as JSON, enables saving the list of all modules without crawling or importing anything
        [Alias('FromDisk')][switch]$UsingDiskCache,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0, ParameterSetName='Lookup')]
        [string]$KeyName,

        # script block to execute -- if key does not exist yet
        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [Alias('Sb', 'Expression', 'E')][scriptblock]$ScriptBlock,

        # reset cache before executing
        [Alias('Force')][switch]$ClearCache,

        [Parameter(mandatory, ParameterSetName='ListOnly')]
        [switch]$List
    )

    write-warning 'This is old code, check out Che'
    if($List){
        return $script:__cachedListState.keys | sort-object
    }

    if($ClearCache) {
        '    => Get-CachedExpression: clearing cache...'
            | Dotils.Write-DimText
            | write-information -infa 'continue'

        $script:__cachedListState.clear()
    }
    $isHit =  $script:__cachedListState.containsKey( $Keyname )
    'Get-CachedExpression: CacheHit for key "{0}" is {1}' -f @( $KeyName, $isHit ) | Write-Verbose

    if( -not $IsHit -and -not $PSBoundParameters.ContainsKey('ScriptBlock')) {
        'Missing ScriptBlock for undefined keys. ( SB is optional for existing keys' | write-error
        return

    }
    if($UsingDiskCache) { throw 'nyi' }
    if($isHit) {
        '   cached {0} values' -f $script:__cachedListState[ $keyName ]
        | Dotils.Write-DimText
        | write-information -infa 'continue'

        return $script:__cachedListState[ $keyName ]
    }
    '    => Get-CachedExpression: Evaluating Expression...'
        | Dotils.Write-DimText
        | write-information -infa 'continue'

    $query = & $ScriptBlock | Sort-Object -Unique
    $script:__cachedListState[ $keyName ] = $query

    '   Caching {0} items' -f $script:__cachedListState[ $keyName ].count
        | Dotils.Write-DimText
        | write-information -infa 'continue'

    return $query
}

Function Dotils.Format-SplitByDelim {
    <#
    .example
        $rawCol = '| Name | Desc | Visible | Updated |'
        ($rawCol | Dotils.Fmt-SplitByDelim -Delim '\|') | Should -BeExactly @('Name', 'Desc', 'Visible', 'Updated')
    #>
    [Alias('Dotils.Fmt-SplitByDelim')]
    [CmdletBinding()]
    param(
        [Alias('InputText', 'InText', 'InStr')]
        [Parameter(ValueFromPipeline, Mandatory)]
        [string]$Text,

        [Parameter(Mandatory)]
        [ArgumentCompletions(
            # "'\|'", # fancy version? better than Join-String -sep which loses description on completion
            "'\|' <# Md Table Columns #>", # fancy version
            "'\t' <# Console Style Columns #>",
            "','"
        )]
        [string]$Delim,

        # warning, this is the original -split x, num.
        # it does not enforce the number of items after splitting
        [int]$MaxSplit
    )
    process {
        if( $PSBoundParameters.ContainsKey('MaxSplit')) {
            ($Text -split '\|', $MaxSplit).
                ForEach({ $_ -replace '^\s+', '' -replace '\s+$', '' }).
                Where({ $_ })

            return
        }

        ($Text -split '\|').
            ForEach({ $_ -replace '^\s+', '' -replace '\s+$', '' }).
            Where({ $_ })
   }
}

function Dotils.Markdown.SortTable {
    param(
        [Parameter()]
        [string[]]$Content
    )

    $ColumnNames = $Content[0] | Dotils.Format-SplitByDelim -Delim '\|' <# Md Table Columns #>
    Join-String 'Found columns: {0}' -sep ', ' $ColumnNames
    write-warning 'almost done wip'
}

function Dotils.Build-Gh.RepoList.AsMdTable {
    <#
    .synopsis
        build a new markdown table from the output of 'gh repo list'
    .notes
        future:
        - [ ] filter by public/private
        - [ ] generic SortMarkdownTableByColumnX that sorts any table
    .EXAMPLE
        Dotils.Build-Gh.RepoList.AsMdTable ninmonkey -Limit 24
        Dotils.Build-Gh.RepoList.AsMdTable StartAutomating
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [ArgumentCompletions('ninmonkey', 'StartAutomating', 'SeeminglyScience')]
        [string]$OwnerName,

        [int]$Limit = 300,

        [ValidateScript({throw 'nyi'})]
        [switch]$OnlyPublic,
        [ValidateScript({throw 'nyi'})]
        [switch]$OnlyPrivate,
        [ValidateScript({throw 'nyi'})]
        [Alias('Since')][string]$ChangedWithin = '1years',
        [switch]$SortByLastModified

    )

    $joinMdTable = @{
        Sep = ' | '
        Op  = '| '
        Os  = ' |' }
    $joidMdTable_Escaped = @{
        Sep      = ' | '
        Op       = '| '
        Os       = ' |'
        Property = {
            $_ -replace '\|', '\|' -replace '\\', '\\'
        }
    }

    $rows =
        ((gh repo list $ownerName --limit $Limit) -split '\r?\n').
            forEach({ $_ -split '\t', 4 | Join-String @joinMdTable -p {
                    $_ -replace '\|', '\|'
                } }
            )
            # or also
            # forEach({ $_ -split '\t', 4 | Join-String @joinMdTable })
            # or also
            # forEach({ $_ -replace '\t', ' | ' | Join-string -op '| ' -os ' |' })

    if($SortByLastModified) {
        $Rows = $rows
    }

    return @(
        'Name', 'Desc', 'Visible', 'Updated' | Join-string @joinMdTable
        '-', '-', '-', '-'                   | Join-string @joinMdTable
        $rows
    ) | Join-String -sep "`n"

    # origSort
    <#
    ($stuff -split '\r?\n').forEach({
        ( $asDate =
            ($_ -split '\|' | ?{ $_ } | Select -Last 1) -as [datetime] )})
    #>

}
function Dotils.Gh.ParseJsonFieldNames.FromHelp {
    [OutputType( [string] )]
    param(
        [string] $RawText
    )
    [string[]] $terms = @(
        ($rawText -split '\r?\n').
        ForEach({ $_.Trim() -split ',\s*' } ).
        where( {$_} )
        | Sort-object -Unique
    )
        # | Join.UL <# parse gh fields docs to names #>
    return $Terms
}
function Dotils.Gh.Gist.List.Export {
    <#
    .SYNOPSIS
        Quickly list your own gists and pipe
    #>
    param(
        [int] $Limit = 200,
        [string] $Pattern,
        [switch] $OutGridView
    )
    $query = gh repo list --limit $Limit
        | ConvertFrom-Csv -Delimiter "`t" -Header 'Name', 'Desc', 'Info', 'Updated'
        | Sort-Object { -not [string]::IsNullOrWhiteSpace( $Pattern ) -and  $_.Desc -match $Pattern } -Descending

    if( -not $GridView ) { return $Query }
    ( $Selected = $Query | Out-GridView -PassThru )
}

function Dotils.Gh.Gist.List.FromApi {
    <#
    .SYNOPSIS
        use gh api to list gists. Need to lookup paging.
    .EXAMPLE

        Dotils.Gh.Gist.List.FromApi SeeminglyScience
            | Select-Object Name, html_url, Description, '*_at', '*url*' -ea 'ignore'
    #>
    param(
        [Parameter(Position = 0)]
        [ArgumentCompletions( 'SeeminglyScience', 'trackd' )]
        [string] $UserName,

        # [int] $Limit = 200,
        [string] $Pattern,
        [switch] $OutGridView
    )

    $target = $UserName | Join-String -f '/users/{0}/gists'
    $query = gh api $target | ConvertFrom-Json -Depth 20
    return $query | Sort-Object { -not [string]::IsNullOrWhiteSpace( $Pattern ) -and $_.Description -match $Pattern }

}

function Dotils.Gh.Gist.Cmds {
    <#
    .SYNOPSIS
    .EXAMPLE
        Pwsh> dotils.Gh.Gist.Cmds Clone

            found Vs Code Splat expression Hotkey
            Cloning into 'Vs Code Splat expression Hotkey'...
            remote: Enumerating objects: 3, done.
    #>
    param(
        [ArgumentCompletions(
            'List',
            'Clone'
        )]
        [string]$CommandName,

        [switch]$ColorAlways
    )
    switch( $CommandName ) {
        'List' {
            gh gist list
            | %{
                $Segments = $_ -split '\t+'
                $header = [ordered]@{
                    PSTypeName = 'dotils.gh.gist.metadata'
                    Hash    = $Segments[0]
                    Title   = $Segments[1]
                    Files   = $Segments[2]
                    Private = $Segments[-2]
                    Date    = $Segments[-1]
                    # Ansi = $_
                    # Rest    = $Segments[2..10]
                }
                if($ColorAlways) {
                    $header.AnsiString = $_
                }
                [pscustomobject]$header
            }
        }
        'Clone' {
            goto 'H:\data\2023\my_gist'

            $gh = dotils.Gh.Gist.Cmds List
            $one = $gh[0]
            'found {0}' -f $one.Title
                | Dotils.Write-DimText
                | Write-Information -infa 'Continue'

            gh gist clone $one.Hash $one.Title

            goto $One.Title
        }
        default { throw "UnhandledCommand: $CommandName" }
    }
}

function Dotils.Basic.Prefix {
    <#
    .SYNOPSIS
        gci . | % name | s -First 2 | Prefix 'someFile'
    #>
    # Sugar to prefix text with a label
    param(
        [Parameter(Mandatory, Position=0)][string]$Prefix,
        [Parameter(ValueFromPipeline)]$InputObject
    )
    process {
        $InputObject | Join-String -op "${Prefix}`n"
    }
}

function Dotils.Discover.TokenFrequency {
    param(
        [Alias('Name')][switch]$AsNameOnly
    )
    $allWords = @(
        gcm -m dotils
        | ?{
            $_.Name -match '\.'
        }
        | %{
            $_.Name -split '\.'
        }
    )
    $grouped = $allWords | Group -NoElement | sort Count -Descending
    if($AsNameOnly) {
        $grouped | % Name | Sort-Object
        return
    } else {
        $grouped
    }
}

function Dotils.Where.MatchesOne {
    <#
    .SYNOPSIS
        Does object match 1 or more of a list of regexs
    .NOTES
        See the simplified <Dotils.Where.MatchesOne.Simple>
    .example
        gmo
            | ?AnyOne -liter 'script', 'binary' -PropertyNames ModuleType
            | ?AnyOne 'ninmonk', 'dotils' -PropertyNames Name

    .example
        gmo | ?AnyOne 'ninmonk', 'dotils' -PropertyNames Name

    .example
        gcm -m dotils |  Dotils.Where.MatchesOne -LiteralRegex 'data' | CountOf|some
        hr
        gcm -m dotils |  Dotils.Where.MatchesOne -re '(module|split)' | CountOf|some
    #>
    [Alias(
        # 'Where.One',
        # '?One',
        '?AnyMatch',
        '?AnyOne'
    )]
    [CmdletBinding()]
    param(

        # non-escaped patterns
        [Parameter(ValueFromPipeline, Position=0)]
        # [Alias('Regex')]
        [string[]]$RegexList,

        # a list of regex-escaped text as literals
        [Parameter(ValueFromPipeline, Position=1)]
        # [Alias('LiteralRegex', 'RegexLiteral')]
        [string[]]$LiteralRegexList,

        [Parameter(ValueFromPipeline, Mandatory)]
        [object]$InputObject,

        # if not set, attempts to compare against a string
        # then, if failed, default to property 'name'
        # property to match?
        [string[]]$PropertyNames
    )
    begin {
        function __.MatchesOne {
            [OutputTYpe('Bool')]
            param(
                [object]$InputObject,
                [string[]]$RegexList,
                [string[]]$LiteralRegexList
            )
            $found = $false

            return $found
        }
    }
    process {
        $found? = $false
        $curObj = $InputObject
        if( $PSBoundParameters.ContainsKey('PropertyNames') -and
            -not [string]::IsNullOrWhiteSpace( $PropertyNames ) ) {

            $found? = __.MatchesOne -InputObject $InputObject -RegexList $RegexList -LiteralRegexList $Literal
            if( $found? ) {
                return $curObj
            }
            # // else maybe auto property

            # $InputObject = $InputObject | Select-Object -Property $PropertyNames
        }
        if( [string]::IsNullOrWhiteSpace( $PropertyNames ) ) {
            $PropertyNames = 'Name'
        }

        foreach($PropName in $PropertyNames) {
            $target = $CurObj.$PropName
            foreach($pattern in $LiteralRegexList) {
                if($target -match [Regex]::Escape($pattern) ) {
                    $found? = $true
                    break
                }
            }
            foreach($pattern in $RegexList) {
                if($found?) { break }
                if($target -match $pattern ) {
                    $found? = $true
                    break
                }
            }

        }

        if($found?) {
            return $curObj
        }
        return

    }
}
function Dotils.Where.MatchesOne.Simple {
    <#
    .SYNOPSIS
    .NOTES
        See the fancy version at <Dotils.Where.MatchesOne>
    .EXAMPLE
        gcm -m dotils |  Dotils.Where.MatchesOne.Simple -LiteralRegex 'data'
    #>
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        $InputObject,

        [string[]]$LiteralRegex
    )
    process {
        $curObj = $InputObject
        $found = $false
        foreach($pattern in $LiteralRegex) {
            if($curObj -match [Regex]::Escape($pattern) ) {
                $found = $true
                break
            }
        }
        if(-not $Found) {
            return
        }

        return $curObj
    }
}
function Dotils.Discover.ExampleCommands {
    [CmdletBinding()]
    param(
        # Return scriptBlocks instead?
        [switch]$PassThru )
    # h1 'Find "operators"'
# @'
# ( $query = gcm -m ninmonkey.Console, Dotils  -All )
#     | .Match.Start -Pattern '.?(Op|As)'
#     | sort -Unique
# '@
#     | Dotils.Write-DimText | wInfo

    $query = gcm -m ninmonkey.Console, Dotils  -All
    if($query.count -eq 0){
        throw 'gcm Found no commands!'
    }
    # $query
    #     | .Match.Start -Pattern '.?(Op|As)'
    #     | sort -Unique

#     h1 'By ending suffix'
# @'
# $query
#     | .Match.End -Pattern 'json|yaml|csv|xlsx' | Sort -Unique
# '@
#     | Dotils.Write-DimText | wInfo

#         $query
#         | .Match.End -Pattern 'json|yaml|csv|xlsx' | Sort -Unique

#     h1 'Special Charactors'
# @'
# $query
#     | .Match -Literal '->'
# '@
#     | Dotils.Write-DimText | wInfo

#         $query
#         | .Match -Literal '->'

    [Collections.Generic.List[Object]]$DemoCommands = @(
        {
            param()
            $input
            | .Match.Start -Pattern '.?(Op|As)'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match.End -Pattern 'json|yaml|csv|xlsx|svg'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal 'Resolve'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal 'Convert'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal 'Test'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal 'Write'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal 'Read'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal '->'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal ' '
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal '_'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match -Literal '.'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match 'Which|Where|Filter'
            | Sort-Object -Unique
        }
        {
            param()
            $input
            | .Match 'Debug|dbg'
            | Sort-Object -Unique
        }
    )
    if($PassThru) {
        return $DemoCommands
    }

$template = @'
$query
    {0}
'@
    foreach($ScriptBlock in $DemoCommands) {

        $template -f @(
            $ScriptBlock.ToString()
        ) | Dotils.Write-DimText | WInfo

        try {
            # $Query |  & $ScriptBlock
            write-warning 'Problem here, having issues piping'
            # $Query | %{ $_ | & $ScriptBlock }
                # |
            # & $ScriptBlock @query
            $query | & $ScriptBlock
        } catch {

                $inner = $_
                $writeException = @{
                    Message      = ('Error Invoking a ScriptBlock example: Inner: {0}' -f $inner.ToString() )
                    ErrorId      = 'Dotils.Discover.CommandExample'
                    Category     = 'InvalidOperation'
                    TargetObject = $inner
                }
                Write-Error @writeException
            }
    }
    hr -fg orange
    Get-Command -Module Dotils | & $DemoCommands[4]
}
function Dotils.FixNativeCommandReference {
    <#
    .SYNOPSIS
        [re]set alias to the native command, useful when experimenting with pipescript\inherit examples
    .NOTES
        # original 1liner
        # Set-Alias 'gh' -PassThru -Value $executionContext.SessionState.InvokeCommand.GetCommand('gh', 'Application')
    .EXAMPLE
        #
        Pwsh> Dotils.FixNativeCommandReference 'gh'
    #>
    param(
        [ArgumentCompletions(
            'gh', 'git', 'jq', 'code',
            'python', 'py'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$CommandName
    )
    $nativeLookup = $executionContext.SessionState.InvokeCommand.GetCommand('gh', 'Application')
    Set-Alias $CommandName -PassThru -Value $nativeLookup -Scope 'Global'

    "FixNativeAlias: alias: '{0}' => `n  {1}" -f @(
        $CommandName
        $nativeLookup
    )
        | Dotils.Write-DimText | wInfo
}

function Dotils.Split.WordByCase {
    <#
    .EXAMPLE
        SplitWordByCase 'UsingExpressionAst' | Json

        # output: {"InputText":"UsingExpressionAst","Segments":["Using","Expression","Ast"]}
    .EXAMPLE
        Pwsh> Dotils.Split.WordByCase 'StatementBlockAstNOConsecutive' | % Segments | Json -Compress

        # Out: ["Statement","Block","Ast","NOConsecutive"]
    .EXAMPLE
        Pwsh> Dotils.Split.WordByCase 'StatementBlockAstNOConsecutive' | % SegmentsBasic | Json -Compress

        # Out: ["Statement","Block","Ast","N","O","Consecutive"]
    #>
    [Alias(
        '.Split.WordByCase'
    )]
    param(
        [string]$InputText
    )
    process {
        $Re = @{}
        $Re.Capital = '(?x-i)(?=[A-Z])'
        $Re.CapitalMultiple = '(?<![A-Z]|^)(?=[A-Z])'

        $info = [ordered]@{
            PSTypeName = 'Dotils.Split.WordByCase.Result'
            InputText  = $InputText
            Segments  =
                $InputText -csplit $Re.CapitalMultiple
            SegmentsBasic   =
                $InputText -split $Re.Capital | ?{ $_ }
            # SegmentsMultiCapital  =

        }
        [pscustomobject]$Info
    }
}

$script:binBat ??= Get-Command 'bat' -CommandType Application -TotalCount 1 -ea 'stop'

function Dotils.Colorize.Json {
    <#
    .NOTES
        original:
            '{"ParamState":{"IsPresent":true}}' | bat -l json --force-colorization --style plain | echo
    .EXAMPLE
        get-date | select * | ConvertTo-Json -Depth 3 -Compress | Json.Colorize
    #>
    [Alias('Json.Colorize')]
    param()

    [List[Object]]$BatArgs = @(
        # will use an Inline render, colors, without any headers
        '--language', 'json',
        '--force-colorization',
        '--style', 'plain'
    )

    return $Input | & $binBat @BatArgs
}

function Dotils.AddLabel {
    <#
    .SYNOPSIS
        add properties, or, names to results
    .EXAMPLE
        gci . | select Name, Length
            | AddLabel -Name 'User' -Value 'Bob'
    .EXAMPLE
        gci . | select Name, Length
            | AddLabel -Name 'test' -AsCounter -ResetCounter
    .EXAMPLE
        gci . | select Name, Length
            | AddLabel -Name 'test' -AsCounter
    #>
    [Alias('AddLabel')]
    param(
        [Parameter(Position=0)]
        [Alias('Text')]
        [ValidateNotNull()]
        [string]$Value,

        [Alias('Key')]
        [ValidateNotNull()]
        [string]$Name = 'Name',

        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        [switch]$AsCounter,
        [switch]$ResetCounter
    )
    begin {
        if($AsCounter) {
            $script:CountersListForAddLabel[ $Name ] ??= 0
            if($ResetCounter) {
                $script:CountersListForAddLabel[ $Name ] = 0
            }
        }
    }
    process {
        $members = [ordered]@{}
        if( -not $AsCounter ) {
            $members[ $Name ] = $Value
        } else {
            # $script:CountersListForAddLabel[ $Name ] ??= 0
            $members[ $Name ] = $script:CountersListForAddLabel[ $Name ]++
        }
        # $members = @{
        #     $LabelName = $Label
        # }

        $InputObject
            | Add-Member -Pass -Force -TypeName 'SillyLabel' -NotePropertyMembers $members # sorry
    }
}

function Dotils.Format-RenderBool {
    <#
    .SYNOPSIS
        hack, do not use for anything. mutates object, summarizes bools as symbols
    #>
    [Alias('Format-RenderBool')]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        $c = @{
            Red = "${fg:#8b6756}"
            Green = "${fg:#445a49}"
        }

    }
    process {
        foreach($CurObj in $InputObject) {
            $CurObj.PSObject.Properties | %{
                $CurProp = $_
                $Val = $CurProp.Value
                if($Val -is 'bool') {
                    $NewVal = switch ( $Val ) {
                        { $_ -eq $true -or $_ -match 'true|ok|\b1\b|yes' } {
                            @(
                                $c.Green
                                $Switch # $Val
                                '✔'
                            ) -join ''
                        }
                        { $null -eq $_ -or  $_ -eq $false -or $_ -match 'false|0|\no' } {
                            @(
                                $c.Red
                                $Switch # $Val
                                '✘'
                            ) -join ''
                        }
                        default {
                            $Switch # $val
                                                        # @(
                            #     $c.Red
                            #     $Switch # $Val
                            #     '✘'
                            # ) -join ''
                        }
                    }
                    # $newVal =
                    #     $Val -replace 'True', '✔' -replace 'False', '✘'

                    #     $Val -replace 'True', '✔' -replace 'False', '✘'

                    $curProp.Value = $newVal
                    #  @(
                    #     $c.Red
                    #     $newVal
                    # ) -join ''
                }
            }
            $curObj
        }
    }
}

function Dotils.ColorTest.TryPairs {
    <#
    .SYNOPSIS
        if no colors set, show a bunch of example combinations
    #>

    param(
        [Parameter()]
        $ColorA,
        [Parameter()]
        $ColorB,

        [Parameter()]
        [string]$string = 'hi world foo bar'
    )


    if(-not $ColorA -and -not $ColorB ) {
        $C = @{
            CodeBg = '#1f1f1f'
            CodeBrownFg = '#c49168'
            CodeYellowFg = '#d5b55d'
            GraySomething1 = '#2e3440'
            GraySomething2 = '#acaeb5'
            DimYellow = '#dcdcaa'
            DimOrange = '#ce8d70'
            DimPurple = '#c586c0'
        }
        Dotils.ColorTest.TryPairs $C.CodeBg $C.CodeBrownFg
        Dotils.ColorTest.TryPairs $C.CodeBg $C.CodeYellowFg
        Dotils.ColorTest.TryPairs $C.CodeBg $C.CodeYellowFg
        Dotils.ColorTest.TryPairs $C.GraySomething1 $C.GraySomething2
        hr
        Dotils.ColorTest.TryPairs 'gray70' 'gray40'
        Dotils.ColorTest.TryPairs $C.CodeBrownFg 'gray40'
        Dotils.ColorTest.TryPairs $C.CodeBrownFg 'gray70'
        Dotils.ColorTest.TryPairs $C.CodeBg 'gray40'
        Dotils.ColorTest.TryPairs $C.CodeBg 'gray70'
        Dotils.ColorTest.TryPairs $C.DimPurple $C.DimOrange
        Dotils.ColorTest.TryPairs $C.DimYellow $C.DimOrange
        return
    }

    @(

        "$ColorA, $ColorB => ",
        $string
    )
        | Join-String -sep ' '
        | Write-Host -fg $ColorA -bg $ColorB
    @(

        "$ColorB, $ColorA => ",
        $string
    )
        | Join-String -sep ' '
        | Write-Host -fg $ColorB -bg $ColorA
}

function Dotils.ColorTest.ShowNumberedVariations {
    <#
    .NOTES
        from thread: <https://discord.com/channels/180528040881815552/180528040881815552/1171228957874602096>

    #>
    $gci = gci fg:\
    h1 'as table'
    $Grouped =
        $gci| Group { $_.X11ColorName -replace '\d+', '' }

    h1 'as short'
    $Grouped
        | Sort-Object { $_.Group.Count } -Descending
        | %{@(
            $_.Name
            $_.Group | Join-String -sep ' ' -Property {
            $_.X11ColorName | New-Text -bg $_
            }
        ) | Join-String -sep ', ' }
          | Join.UL


    hr
    $Grouped =
        $gci | Group-Object -Property { @(
           $name= $_.X11ColorName
           $name -match 'red|green'
           $name -match 'gray|yellow'
        ) -join '-' }

    $Grouped
        | %{@(
            $_.Name
            $_.Group
               | Sort-Object -Property { $_.ToHsl().H }
               | Join-String -sep ' ' -Property {
                  $_.X11ColorName, $_.ToString()
                      | New-Text -bg $_ -Separator ', '
               }
        ) | Join-String -sep ' => ' }
          | Join-String -sep "`n`n`n --------- `n`n`n "




}

function Dotils.Write.NumberedList {
    <#
    .synopsis
            context was cloning the NL linux command for piping to Fzf: <https://thevaluable.dev/practical-guide-fzf-example/>
    .example
        gci ..
            | nl
            | fzf --with-nth=-2.. --delimiter=\
            # or variant
            | fzf --nth=2 --delimiter=' '
    .link
        https://thevaluable.dev/practical-guide-fzf-example/
    #>
    [Alias('Dotils.NL', 'NL')]
    param()
    $LineNo = 0
    $Input | %{
        $LineNo++
        Join-String -f "${LineNo}. {0}" -inp $_
    }
}


function Dotils.Fzf.SelectByUID {
    <#
    .SYNOPSIS
        automatically return the id of a column, without the user seeing numbers
    .DESCRIPTION
        this will


        ## If HideIdFromUser == true, then

            Pwsh> Get-process | Dotils.NL

        when the user picks from:

            [+] System.Diagnostics.Process (svchost)
            [ ] System.Diagnostics.Process (svchost)
            [+] System.Diagnostics.Process (svchost)
            [ ] System.Diagnostics.Process (System)
            [ ] System.Diagnostics.Process (SystemSettings)
            [ ] System.Diagnostics.Process (taskhostw)

        the returned value is:

            332. System.Diagnostics.Process (svchost)
            334. System.Diagnostics.Process (svchost)

        ## if -not HideFromuser

            [+] 332 System.Diagnostics.Process (svchost)
            [ ] 333 System.Diagnostics.Process (svchost)
            [+] 334 System.Diagnostics.Process (svchost)
            [ ] 335 System.Diagnostics.Process (System)
            [ ] 336 System.Diagnostics.Process (SystemSettings)
            [ ] 337 System.Diagnostics.Process (taskhostw)

        the returned value is still the same

            332. System.Diagnostics.Process (svchost)
            334. System.Diagnostics.Process (svchost)


    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        [switch]$AsObject,
        [switch]$WhatIf,
        [hashtable]$Options = @{}
    )
    begin {
        $Config = nin.MergeHash -OtherHash $Options -BaseHash @{
            HideIdFromUser = $true
            ExitKey = 'q'
            MultiSelect = $true
            Nth = '2'
            Delimiter = ' '
        }

        [List[Object]]$Items  = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }
    end {

        [List[Object]]$FzfArgs = @(
            # '--nth=2'
            '--nth={0}' | Join-string -f $Config.Nth
            if($Config.HideIdFromUser) { '--with-nth=2' }
            "--delimiter='{0}'" | Join-string -f $Config.Delimiter

# [1]
"--delimiter='{0}'" -f @( $Config.Delimiter )

# [2]
Join-string -Inp $Config.Delimiter -f "--delimiter='{0}'"

# [3]
$Config.Delimiter
    | Join-String -f "--delimiter='{0}'"

# [4]
$Config.Delimiter | Join-String -f "--delimiter='{0}'"

            # "--delimiter=' '" # is the default
            '--ansi'
            if( $Config.MultiSelect ) { '-m' }
        )
        $Selected = @( # @(
            $Items
                | Dotils.NL
                | fzf @FzfArgs # )
        )

        if($WhatIf) {
            $FzfArgs | Join-String -sep ' ' -op 'FzfArgs: '
                | Dotils.Write-DimText | Infa
            return
        }

        if( -not $AsObject ) { return $Selected }

        $Selected | %{
            $UID, $Rest =
                $_ -split '\. ', 2

            [pscustomobject]@{
                Id = $UID
                Value = $Rest
            }
        }
    }
}

function Dotils.Props.FromObject {

    [CmdletBinding()] # DefaultParameterSetName='FromPSObject')]
    [Alias(
        'Dotils.PropsOf',
        'Dot.PropOf'
    )]
    param(
        $InputObject,

        [Alias('Obj', 'AsObj', 'FromPSObject', 'Kind')]
        # [Parameter(ParameterSetName = 'FromPSObject')]
        [ValidateSet(
            'Obj', 'FromPSObject', 'Object', 'PSCO', 'Props'
        )]
        [string]$SourceKind = 'FromPSObject',

        # Final return names only, without other member info
        [Alias('AsText', 'String')]
        [switch]$NameOnly,
        [switch]$Unique
    )
    throw 'nyi, copy from: <H:\data\2023\pwsh\sketches\2023-12-13▸MiniJsonify\Mini.Jsonify.Test.psm1>'
    switch($SourceKind) {
        'FindMember' {
            throw 'nyi, copy from: <H:\data\2023\pwsh\sketches\2023-12-13▸MiniJsonify\Mini.Jsonify.Test.psm1>'

        }
        { $_ -in @( 'FromPSObject', 'PSCO', 'Object', 'Obj', 'Props' ) } {
            $query = ( $InputObject )?.PSObject.Properties
        }
        default { throw "UhandledSet: $(  $PSCmdlet.ParameterSetName ) "}
    }
    $sortObjectSplat = @{ Property = 'Name' }
    if($PSBoundParameters.ContainsKey('Unique')) { $sortObjectSplat.Unique = $Unique }

    $query = $query | Sort-Object @sortObjectSplat
    if( $NameOnly ) { return $query.Name }
    return $query
}

function Dotils.FormatQuotes-WhenContainsSpaces {
        param(
            [switch]$DoubleQuote,

            [Parameter(ValueFromRemainingArguments)]
            [string]$Text
        )
        $hasSpaces = $Text -match ' '
        $hasSingle = $Text -match "[']+"
        $hasDouble = $Text -match '["]+'

        $splat = @{}
        if($DoubleQuote) {
            $splat.DoubleQuote = $True
        } else {
            $splat.SingleQuote = $True
        }

        $hasSpaces ? (
            Join-String -in $Text @splat
        ) : $Text
}

function Dotils.QuickFmt.ShowTypes_AlignedColumns {
    <#
    .synopsis
        show a list of names, with types on the left which are right-aligned to the important text
    .example
        > Dotils.QuickFmt.AlignedColumns $Ast.EndBlock.Statements
        > Dotils.QuickFmt.AlignedColumns (gci . )
    .example
        > Dotils.QuickFmt.AlignedColumns (gci . )

        DirectoryInfo .github
        DirectoryInfo .vscode
        DirectoryInfo CacheMeIfYouCan
        DirectoryInfo Docs
        DirectoryInfo examples
        DirectoryInfo tests
            FileInfo .gitattributes
            FileInfo .gitignore
            FileInfo 🦍CacheMeIfYouCan.code-workspa
            FileInfo AstSketch.ps1
            FileInfo build.psd1
            FileInfo env.json

    .example
        > Dotils.QuickFmt.AlignedColumns ( $Ast.EndBlock.Statements )

        AssignmentStatementAst [␀]
            TypeDefinitionAst BuildItCommandNameCompleter
        FunctionDefinitionAst BuildItCmd
        FunctionDefinitionAst BuiltIt-TryImportInstalled
                PipelineAst [␀]
        FunctionDefinitionAst BuildIt-ModuleBuild
        FunctionDefinitionAst BuildIt-TryModuleBuild
        FunctionDefinitionAst BuildIt-TryImportModuleBuilder
        FunctionDefinitionAst BuildIt-TryPublish
        FunctionDefinitionAst BuildIt-TryInstallPublished
    #>
    [Alias(
        'Dotils.QuickFmt.AlignedColumns',
        'Dotils.QuickFmt.TinfoCols'
    )]
    param(
        $InputObject,
        [string]$Property = 'Name'
    )
    $max_left  = $InputObject | %{ $_.GetType().Name.Length } | measure -Maximum | % Maximum
    $max_right = $InputObject | %{ $_.$Property.Length } | measure -Maximum | % Maximum

    $InputObject | %{
        $Left  = $_.GetType().name
        $Right = $_.$Property
        $Left = $Left.padLeft( $max_left, ' ' )
        $Render = Label $Left $Right -sep ' ' -fore 'gray30'
        return $Render
    }
}
function Dotils.Ast.GetAstFromFile {
    <#
    .notes
    related:
        - https://gist.github.com/SeeminglyScience/4d0d63ab56b4f121b98652e831af7219
        - <https://github.com/SeeminglyScience/dotfiles/blob/bc31aaaec30343be4788d47b2c08b40d6763268d/Documents/PowerShell/Utility.psm1#L6026-L6027>

    see:
        https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.parser.parseinput?view=powershellsdk-7.4.0#system-management-automation-language-parser-parseinput(system-string-system-string-system-management-automation-language-token()@-system-management-automation-language-parseerror()@)
        https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.parser?view=powershellsdk-7.4.0
    #>
    [Alias('Dotils.AstFromFile')]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $FileName
    )
    if( -not (Test-Path $FileName)) {
        throw "InvalidFilepath: '$FileName'"
    }

    $Tokens = $null
    $AstErrors = $Null
    $DocRoot = [Parser]::ParseFile(
        <# fileName: #> $fileName,
        <# tokens  : #> [ref] $tokens,
        <# errors  : #> [ref] $AstErrors )

    [pscustomobject]@{
        Tokens   = $Tokens
        Errors   = $AstErrors
        Fullname = $filename | Get-Item
        Ast      = $DocRoot
    }

    if( $AstErrors.count -gt 0 ) {
        'warning, {0} Errors' -f @( $AstErrors.count )
            | write-verbose -verbose
    }
}
function Dotils.QuickGcm.ByPrefix {
    param(
        [ArgumentCompletions("'sk.*'", "'dotils.*'")]
        [string] $Pattern = 'sk.*',
        [switch] $WithoutWildcard,
        [switch] $PassThru
    )
    [bool]$isWildcard = -not $WithoutWildcard
    # $ExecutionContext.InvokeCommand.GetCommands('sk.*', 'all', $true) | fl *
    $found = $ExecutionContext.InvokeCommand.GetCommands( $Pattern, 'all', $isWildcard)
    if($PassThru) { return $found }

    $found | ft Name, CommandType, Visibility, Parameters, ParameterSets -auto
}
function Dotils.QuickParams {
    <#
    .synopsis
        Show ParameterInfo automatically and call Find-Member if it hasn't ran
    .example
        [Parser] | Dotils.QuickParams
        [Parser] | Find-Member | Dotils.QuickParams # automatic, so they are equivalent

    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline )]
        [object[]]$InputObject,
        [switch]$PassThru
    )
    process {
        $InputObject | %{
            $curObj = $_
            $cameFromFindMember = $curObj -is [Reflection.MethodInfo]
            $CameFromMember ?
                ( $CurObj | Get-Parameter) :
                ( $CurObj | Find-Member | Get-Parameter )
                # $_ | Find-Member | Get-Parameter | Ft -AutoSize
        }
    }
}

function Dotils.SaveLink {
    param(
        [string[]]$LinksInput,
        [switch]$Force
    )
    # https://github.com/SeeminglyScience/dotfiles/blob/main/Documents/PowerShell/profile.format.ps1xml
    $DestPath = gi (Join-Path 'H:/data/2023/dump.buffer.offline' 'linksBufferDump.md')

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    if( -not [string]::IsNullOrEmpty( $LinksInput )) {
        [object[]]$Links = @( $LinksInput )
    }
    if( [string]::IsNullOrEmpty( $Links )) {
        [object[]]$Links = @( Get-Clipboard )
    }

    if( [string]::IsNullOrEmpty( $Links )) {
        throw 'error: was null or empty links?'
    }
    Join-String -f 'writing: "{0}"' -inp $DestPath
        | Dotils.Write-DimText
        | Infa

    $Links
        | ?{ -not ($_ -as [System.Uri]) }
        | Join-String -sep ', '  -op 'Dotils.SaveLink :: PotentialNonUris: = [ ' -os ' ] '
        | write-warning

    $Links
        | ?{ $_ -as [System.Uri] }
        | Join-String -f "`n - {0}" -prop { $_ }
        | Add-Content -Path $DestPath -PassThru
}
# function Dotils.RenameError {
#     <#

#     #>
#     throw 'nyi: see justingrote demo that modifies the error string preserving the rest'

# }
function Dotils.CommandTemplate {
    param(
        # future: autocomplete
        [Parameter(Position = 0, Mandatory )]
        [ArgumentCompletions(
            'GitLogger.Build',
            'GitLogger.TypeTest',
            'GitLogger.EnterDocker',
            'GitLogger.WatchLog'
        )]
        [string] $TemplateName
    )

    switch( $TemplateName ) {
        'GitLogger.Build' {
@'
GlRun.RebuildTypes; GlRun.DockerBuild; # [2024-09-10] build and copy gh sample gitlogger repo (after image)
(impo -ea 'stop' 'H:\data\2024\pwsh\Modules.devNin.🦍\Rocktil\Rocktil\Rocktil.psd1' -Force -PassThru).IterCommands | Write-Verbose
$CopySource = gi -ea 'stop' ('C:\Users\cppmo_000\AppData\Local\Temp\glclone\GitLogger'.ToLower())
Rocktil.Container.CopyTo -Source $CopySource -ContainerName git-logger -DestinationPath /Repos/startautomating/gitlogger
# Start-Process -FilePath 'http://localhost:8080/Logs'
Sleep -Milliseconds 150
#GlRun.OpenUrlWhenResponding -Url 'http://localhost:8080/Logs' -WithToastNotification
hr -fg magenta
'done'
# Start -FilePath 'http://localhost:8080//Docs/docker/show-gitlogger.html'
'@

        }
        'GitLogger.TypeTest' {
@'
# 📌[Type test] minimal logic [2024-09] external test of module typebuilder logic
$Error.Clear(); remove-module gitlogger*, ugit* -ea 'ignore'
$builder = gi -ea 'stop' (Join-Path $Glpath.GitLoggerRepoRoot 'Build/GitLogger.ezout.ps1')
$module = gi -ea 'stop' (Join-path $GlPath.GitLoggerRepoRoot 'GitLogger.psd1')
. $builder
($psmod = ipmo -PassThru -Force $module )
$psmod.IterCommands|ft
if( $Error.Count -gt 0) { $Error }

hr
GItLogger.serve -Request 'http://localhost:8080/dsfds' #| Select -First 3
'@

        }
        'GitLogger.WatchLog' {
@'
GlGet.LogPath-StartTailLoopChanges -DelayMsBetweenConsoleWrites 30 # live log docker [2024-09]
'@

        }
        'GitLogger.EnterDocker' {
@'
Dotils.Docker.Native.Start-WaitConnectLoop # live docker connect [2024-08]
'@
        }
        default {
            throw "Unhandled TemplateName: '$TemplateName'"
        }
    }
}


$exportModuleMemberSplat = @{
    # future: auto generate and export
    # (sort of) most recently added to top
    Function = @(
        # 2024-02-02
        'Dotils.Format.*'

        # 2023-12-28
        'Fmt.*'
        'DbgTool.*'
        'Debug.*'
        # 2023-12-27
        'Fetch*'
        'List.*'
        # 2023-12-07
        'Fd.Go'
        # 2023-12-06
        'Dotils.Git.Select'
        'Dotils.Template.ProxyCommand'
        # 2023-12-06
        'Bdg.Go'
        # 2023-11-28
        'Dotils.Toast.InvokeAlarm' # 'Dotils.Toast.InvokeAlarm' = {  }
        # 2023-11-26
        'Dotils.BasicFormat.Predent' # 'Dotils.BasicFormat.Predent' = { 'f.Predent' }
        # 2023-11-22
        'Dotils.*'
        # 2023-11-18
        'Dotils.Goto.Error' # 'Dotils.Goto.Error' = { }
        'Dotils.DropNamespace' # 'Dotils.DropNamespace' =  { }
        'Dotils.EC.GetCommandName' # 'Dotils.EC.GetCommandName' =  { }
        'Dotils.EC.GetCommand' # 'Dotils.EC.GetNativeCommand' =  { }
        'Dotils.EC.GetNativeCommand' # 'Dotils.EC.GetNativeCommand' =  { }
        'Dotils.Fd.Recent' # 'Dotils.Fd.Recent' =  { }
        'Dotils.Git.AddRecent' # 'Dotils.Git.AddRecent' =  { }
        # 2023-11-17
        'Dotils.Clipboard.CopyFileListFromExplorer' # 'Dotils.Clipboard.CopyFileListFromExplorer' = { }
        # 2023-11-16
        'Dotils.Format.NumberedList' # 'Dotils.Format.NumberedList' = { 'Fmt.NL' }
        # 2023-11-13
        'Dotils.Linq.CountLines'
        # 2023-11-11
        # 'Dotils.Datetime.NamedFormatStr' # 'Dotils.Datetime.NamedFormatStr' = { 'Date.NamedFormatStr'  } # moved to: <H:/data/2023/dotfiles.2023/pwsh/dots_psmodules/Dotils/Completions.NamedDateFormatString.psm1>


        'Dotils.DatetimeOffset.Parse.FromGithub' # 'Dotils.DatetimeOffset.Parse.FromGithub' = { }
        'Dotils.Datetime.ShowExamples' # 'Dotils.Datetime.ShowExamples' = {  }
        'Dotils.Datetime.Now' # 'Dotils.Datetime.Now' = { 'Dt.Now', 'DateTime.Now' }
        'Dotils.DatetimeOffset.Now' # 'Dotils.DatetimeOffset.Now' = { 'Dto.Now', 'DatetimeOffset.Now' }
        # 2023-11-09
        'Dotils.Fzf.SelectByUID' # 'Dotils.Fzf.SelectByUID' = { }
        'Dotils.Colorize.BasedOnDistincCount' # 'Dotils.Colorize.BasedOnDistincCount' = { }
        'Dotils.Write.NumberedList' #  'Dotils.Write.NumberedList'  = { 'Dotils.NL', 'NL' }
        # 2023-11-08
        'Dotils.ColorTest.ShowNumberedVariations'
        # 2023-11-06
        'Dotils.Format-ModuleName' # 'Dotils.Format-ModuleName' = { 'Render.ModuleName' }
        # 2023-11-05
        'Dotils.Show-Escapes' # 'Dotils.Show-Escapes' = { 'ShowEscapes', 'Show-Escapes' }
        'Dotils.Test.IsModulus' # 'Dotils.Test.IsModulus' = { 'Is.Modulus', 'Is.Mod' }
        # 2023-11-03
        'Dotils.AddLabel' # 'Dotils.AddLabel' = { 'AddLabel' }
        'Dotils.Colorize.Json' # 'Dotils.Colorize.Json' = { 'Json.Colorize' }
        'Dotils.Format-RenderBool' # 'Dotils.Format-RenderBool'  = { 'Format-RenderBool' }

        # 2023-10-30
        'Dotils.FixNativeCommandReference'
        # 2023-10-12
        'Dotils.Select.Some.NoMore' # 'Dotils.Select.Some.NoMore' = { 'Some', 'One' }

        # 2023-10-11
        'Dotils.Culture.Get' # 'Dotils.Culture.Get' = { 'Dotils.Culture.Gci' }
        'Dotils.Format-TextCase' # 'Dotils.Format-TextCase' = { }

        # 2023-10-01
        'Dotils.Get-Item.FromClipboard' # 'Dotils.Get-Item.FromClipboard' = { 'Gcl.Gi' }
        # 2023-09-23
        'Dotils.Where.MatchesOne.Simple' # 'Dotils.Where.MatchesOne.Simple' = { '' }
        'Dotils.Where.MatchesOne' # 'Dotils.Where.MatchesOne' = { 'Where.One',  '?AnyMatch', '?AnyOne' }

        'Dotils.Format.WildcardPattern' # 'Dotils.Format.WildcardPattern' = { 'Dotils.Format.WildcardPattern' }
        'Dotils.Operator.TypeAs' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }
        'Dotils.Discover.ExampleCommands' # 'Dotils.Discover.ExampleCommands' = { 'Dotils.Discover.ExampleCommands' }
        'Dotils.Discover.TokenFrequency' # 'Dotils.Discover.TokenFrequency' = { 'Dotils.Discover.TokenFrequency' }

        # 2023-09-22
        'Dotils.Accumulate.Hashtables' # 'Dotils.Accumulate.Hashtables' = { 'Dotils.Accum.Hash', 'nin.Accum.Hash' }
        # 2023-09-11
        'Dotils.TypeData.GetFormatAndTypeData'
        'Dotils.Import.Macro'
        'Dotils.Error.GetInfo'
        'Dotils.Firefox.Invoke'
        'Dotils.Uri.GetInfo' #  'Dotils.Uri.GetInfo' = { 'Dotils.URL.GetInfo' }
        # 2023-09-08
        'Dotils.Gh.Gist.Cmds'
        # 2023-09-04
        'Dotils.Format.TextMargin'
        '__Dotils.Format.WrapLongLine'
        'Dotils.Format.WrapLongLine'
        'Dotils.DebugUtil.Format.UpdateTypedataLiteral' # 'Dotils.DebugUtil.Format.UpdateTypedataLiteral' = { '.debug.format-UpdateTypedata.Literal', 'literal.UpdateTypeDataProperty' }
        'Dotils.Render.Bool' # 'Dotils.Render.Bool' = { 'Render.Bool', '.Render.Bool' }
        'Dotils.Render.Dom.Attributes' # 'Dotils.Render.Dom.Attributes' = { 'Render.Dom.Attributes' }

        # 2023-09-03
        'Dotils.LastOut' # 'Dotils.LastOut' = { 'LastOut' }
        'Dotils.Find.Property.Basic' # 'Dotils.Find.Property.Basic' =  { }
        'Dotils.Find.Property' # 'Dotils.Find.Property' = {  }
        'Dotils.Select.Some' # 'Dotils.Select.Some' = { 'Some' }
        'Dotils.Format-HexString' # 'Dotils.Format-HexString' = { '.As.HexString', 'fmt.HexString', 'HexString' }
        'Dotils.PowerBI.CaptureLogs' # 'Dotils.PowerBI.CaptureLogs' =  { }
        'Dotils.PowerBI.FindRecentLog' # 'Dotils.PowerBI.FindRecentLog' = { }
        'Dotils.PowerBi.Parse.LogName'
        'Dotils.Powerbi.ParseLog' # Dotils.Powerbi.ParseLog = { }
        # 2023-09-02
        'Dotils.Resolve.Ast' # 'Dotils.Resolve.Ast' = { 'Resolve.Ast' }
        # 2023-08-31
        'Dotils.Select-VariableByType' # 'Dotils.Select-VariableByType' = { 'Dotils.Find-VariableByType' }(
        'Dotils.Write-DictLine'
        # 2023-08-30
        'Dotils.New-HashSetString.basic'
        'Dotils.New-HashSetString.Fancy'
        # 2023-08-28
        'Dotils.Add-PsModulePath' # 'Dotils.Add-PsModulePath' = { }

        # 2023-08-26
        'Dotils.Split.WordByCase' # 'Dotils.Split.WordByCase' = { '.Split.WordByCase' }
        'Dotils.Debug.Find.AstType' # 'Dotils.Debug.Find.AstType' = {  }

        # 2023-08-24
        'Dotils.Write-Information' # 'Dotils.Write-Information' = { 'wInfo', 'Infa', 'Write.Infa' }
        'Dotils.Write-StringInformation' # 'Dotils.Write-StringInformation' = { 'Write.StringInfa', 'Write.StrInfa' }

        'Dotils.Resolve.Module' # 'Dotils.Resolve.Module' = { 'Resolve.Module' }
        # 2023-08-21
        'Dotils.Get-CachedExpression' # 'Dotils.Get-CachedExpression' = { .Cached.Sb }
        # 2023-08-20
        'Dotils.Regex.Split.Basic' # 'Dotils.Regex.Split.Basic' = { 'Regex.Split.Basic' }
        'Dotils.Regex.Split'
        'Dotils.Start-TimerToastLoop'
        'Dotils.Get-UsingStatement' # 'Dotils.Get-UsingStatement' = { }
        'Dotils.Select-Nameish' # 'Dotils.Select-Nameish' = { 'Select.Namish', 'Nameish' }
        'Dotils.Format-Datetime' # 'Dotils.Format-Datetime' = { '.fmt.Datetime', 'Dotils.Format.Datetime' }
        'Dotils.ConvertTo-TimeSpan' # 'Dotils.ConvertTo-TimeSpan' = { '.to.Timespan', '.as.Timespan', 'Dotils.ConvertTo.Timespan' }


        # 2023-08-18
        'Dotils.PStyle.Color.Gray' # 'Dotils.PStyle.Color.Gray' = { 'Dotils.Color.Gray', 'C.Gray' }
        'Dotils.PStyle.Color.Hex' # 'Dotils.PStyle.Color.Hex' = { 'Dotils.Color.Hex', 'c.Hex' }
        '__compare-Is.Type'
        'Dotils.Resolve.Command'
        'Dotils.Compare.Duplicates'
        'Dotils.Resolve.TypeInfo'          # 'Dotils.Resolve.TypeInfo' = { Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }
        'Dotils.DebugUtil.Format.AliasSummaryLiteral'
        'Dotils.DebugUtil.Format.UpdateTypedataLiteral'
        'Dotils.Test-IsOfType.FancyWip' # 'Dotils.Test-IsOfType.FancyWip' = { }
        'Dotils.Test-IsOfType.Basic' # 'Dotils.Test-IsOfType' = { '.Is.Type', '.Is.OfType', 'Dotils.Test-IsOfType' }
        'Dotils.Select-TemporalFirstObject'         # 'Dotils.Select-TemporalFirstObject' = { '.Select.FirstTime' }
        'Dotils.Quick.GetType' # 'Dotils.Quick.GetType' = { 'gt', '.quick.GetType' }
        'Dotils.Debug.GetTypeInfo' # 'Dotils.Debug.GetTypeInfo' = { 'Dotils.Describe.Type' }'
        # 2023-08-15
        'Dotils.String.Transform' # 'Dotils.String.Transform' = { '.str.Transform' }
        'Dotils.Render.TextTreeLine' # 'Dotils.Render.TextTreeLine'  = { '.Render.TreeItem', '.Render.TreeLine' }
        'Dotils.Render.TextTreeLine.Basic'
        'Dotils.Summarize.Module'
        # 2023-08-14
        'Dotils.Write-StatusEveryN' # 'Dotils.Write-StatusEveryN' = { '.status.EveryN', 'status.EveryN', 'Write-EveryStatus','WriteEveryN'}

        # 2023-08-13
        'Dotils.Describe.Timespan.AsSeconds' # 'Dotils.Describe.Timespan.AsSeconds' = { 'Sec', 'Ms', '.Render.Sec', '.Render.Ms' }
        'Dotils.Describe.Timespan.AsMilliseconds' # 'Dotils.Describe.Timespan.AsMilliseconds' = { 'Ms', '.Render.Ms' }


        'Dotils.Test-AllResults' # 'Dotils.Test-AllResults' =  { '.test', '.Assert', 'Assert', 'Test-Results' }
        'Dotils.Test-CompareSingleResult' # 'Dotils.Test-CompareSingleResult' = { }
        'Dotils.Operator.TypeIs' # 'Dotils.Operator.TypeIs' = { 'Is', '.Is.Type', 'Op.Is' }(

        # 2023-08-11

        'Dotils.To.Type.FromPSTypenames' # 'Dotils.To.Type.FromPSTypenames' = { '.To.Type.FromPStypes', '.to.PSTypes' }
        'Dotils.Help.FromType' # 'Dotils.Help.FromType' = { 'Help.FromType', 'Help.From' }

        'Dotils.To.Duration' # 'Dotils.To.Duration' = { '.to.Duration', '.Duration', '.to.Timespan' }
        'Dotils.VsCode.ConvertTo.Snippet' # 'Dotils.VsCode.ConvertTo.Snippet' = { '.VsCode.ConvertTo.Snippet' }
        'Dotils.Describe' # 'Dotils.Describe' = { '.Describe' }

        'Dotils.Select.One' # 'Dotils.Select.One' = { '.Select.One', 'One' }
        'Dotils.Text.NormalizeLineEnding' # 'Dotils.Text.NormalizeLineEnding' = { '.Text.NormalizeNL' }

        # 2023-08-10
        'Dotils.Ansi.Write' # 'Dotils.Ansi.Write' = {  '.Ansi.Fg', '.Ansi.Bg', '.Ansi.Write' }
        'Dotils.Format.FullName' # 'Dotils.Format.FullName' = { 'FullName', '.Format.FullName', '.fmt.Name' }
        'Dotils.To.Encoding' # 'Dotils.To.Encoding' = { '.to.Encoding', '.as.Encoding' }
        'Dotils.Regex.Match' # 'Dotils.Regex.Match = { '.Match' }
        'Dotils.Console.Encoding' # 'Dotils.Console.GetEncoding' = { 'Console.Encoding' }
        'Dotils.Console.SetEncoding' # 'Dotils.Console.SetEncoding' = { 'Console.SetEncoding' }
        'Console.GetWindowWidth' # 'Console.GetWindowWidth'  = { 'Console.Width' }
        'Dotils.Help.FromType' # 'Dotils.Help.FromType' = { '.Help.FromType' }
        'Dotils.Regex.Match.Word' # Dotils.Regex.Match.Word' # = { '.Match.Word' }
        # 2023-08-09
        'Dotils.Goto.Kind' # 'Dotils.Goto.Kind' = { '.Go.Kind', '.Goto.Kind' }
        'Dotils.Has.Property' # 'Dotils.Has.Property' = { '.Has.Prop' }
        'Dotils.Has.Property.Regex' # 'Dotils.Has.Property.Regex' = { '.Has.Prop.Regex' }
        'Dotils.PSDefaultParameters.ToggleAllVerbose'
        'Dotils.Select.Variable'
        # 2023-08-08
        'Dotils.Bookmark.EverythingSearch'
        'Dotils.To.PSCustomObject' # 'Dotils.To.PSCustomObject' = { '.To.Obj', '.as.Obj' }

        # 2023-08-07
        'Dotils.Join.Csv' # 'Dotils.Join.Csv' = { '.Join.Csv', 'Join.Csv', 'Csv' }
        'Dotils.Quick.PSTypeNames' # 'Dotils.Quick.PSTypeNames' = { '.quick.PSTypes' }
        'Dotils.Regex.Match.Start' # Dotils.Regex.Match.Start = { '.Match.Start', '.Match.Prefix' }
        'Dotils.Regex.Match.End' # Dotils.Regex.Match.End = { '.Match.End', '.Match.Suffix' }
        'Dotils.Text.Pad.Segment' # 'Dotils.Text.Pad.Segment' =  { '.Text.Pad.Segment', '.Text.Segment' }'
        'Dotils.Err.Clear' # 'ec' # 'Dotils.Err.Clear' = { 'ec' }
        # 2023-08-06
        'Dotils.Ansi' # 'Dotils.Ansi' = { }
        'Dotils.Regex.Wrap' # 'Dotils.Regex.Wrap' = {  }
        'Dotils.Iter.Text' # 'Dotils.Iter.Text' = { '.Iter.Text' }
        'Dotils.Iter.Enumerator'  # 'Dotils.Iter.Enumerator' = { '.Iter.Enumerator' }
        'Dotils.Excel.Write.Sheet.Name'
        'Dotils.Summarize.CollectionSharedProperties' # 'Dotils.Summarize.CollectionSharedProperties' = { '.Summarize.SharedProperties' }
        # 2023-08-05 - wave B
        'Dotils.Is.SubType' # 'Dotils.Is.SubType' = { '.Is.SubType' }
        'Dotils.Add.IndexProp' # 'Dotils.Add.IndexProp' = { '.Add.IndexProp' }
        'Dotils.Iter.Prop' # 'Dotils.Iter.Prop' = { '.Iter.Prop' }
        'Dotils.Is.Blank' # 'Dotils.Is.Blank' = { '.Is.Blank' }
        'Dotils.Is.Not' # 'Dotils.Is.Not' = { '.Is.Not' }
        'Dotils.Render.InvocationInfo' # NYI
        'Dotils.Error.Select'
        'Dotils.Distinct'
        'Dotils.Find.NYI.Functions'
        'Dotils.Render.MatchInfo'
        # 2023-08-05 - wave A
        'Dotils.Describe.Error'
        'Dotils.Describe.ErrorRecord' # '.Describe.Error' # 'Dotils.Describe.ErrorRecord' = { '.Describe.Error' }
        'Dotils.Is.Error.FromParamBlock' # 'Dotils.Is.Error.FromParamBlock' = { '.Is.Error.FromParamBlockSyntax' }
        'Dotils.Is.KindOf' # 'Dotils.Is.KindOf' = { '.Is.KindOf' }
        'Dotils.Render.CallStack'
        'Dotils.Render.ColorName'
        'Dotils.Render.Error.CategoryInfo' # 'Dotils.Render.Error.CategoryInfo' = { }
        'Dotils.Render.ErrorVars'
        'Dotils.Render.FindMember'

        # 2023-08-04
        'Dotils.Is.DirectPath' # Dotils.Is.DirectPath = { '.Is.DirectPath' }
        'Dotils.to.EnvVarPath' # 'Dotils.to.EnvVarPath' = { '.to.envVarPath' }
        # 2023-08-03
        'Dotils.To.Hashtable' # 'Dotils.To.Hashtable' = { '.to.Dict', '.as.Dict' }
        # 2023-08-02
        'Dotils.Write-TypeOf' # 'Dotils.Write-TypeOf' = { 'WriteKindOf',  'OutKind', 'LabelKind'  }

        # 2023-07-31
        'Dotils.Quick.Pwd' # 'Dotils.Quick.Pwd' = { '.quick.Pwd', 'QuickPwd' }
        'Dotils.Quick.History' # 'Dotils.Quick.History' = { '.quick.History', 'QuickHistory' }
        # 2023-07-29
        'Dotils.Text.Wrap' # 'Dotils.Text.Wrap' = { 'Dotils.Text.Prefix', 'Dotils.Text.Suffix', '.Text.Suffix', '.Text.Prefix' }
        'Dotils.md.Write.Url' # 'Dotils.md.Write.Url' = { 'md.Write.Url' }
        'Dotils.d.Format.EscapeFilepath' # 'Dotils.md.Format.EscapeFilepath ' = 'md.Format.EscapeFilepath'
        'Dotils.GetAt' # 'Dotils.GetAt' = { 'At', 'Nat', 'gnat' }
        'Dotils.Render.ColorName'
        'Dotils.Format.Color'

        # 2023-07-24
        'Dotils.Format.Write-DimText' # 'Dotils.Format.Write-DimText' = { 'Dotils.Write-DimText' }
        # 2023-07-10
        'Dotils.Log.Format-WriteHorizontalRule' # 'Dotils.Log.Format-WriteHorizontalRule' = { }
        'Dotils.Log.WriteFromPipe' # 'Dotils.Log.WriteFromPipe' = { }
        'Dotils.Log.WriteNowHeader' # 'Dotils.Log.WriteNowHeader' = { }
        #
        'Dotils.Format-ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }
        'Dotils.Format-ShortString.Basic' # 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
        'Dotils.Object.QuickInfo' # 'Dotils.Object.QuickInfo' = { 'QuickInfo' }
        #
        'Dotils.SamBuild'
        'Dotils.Out.XL-AllPropOfBoth' # 'Dotils.Out.XL-AllPropOfBoth' = {}
        'Dotils.Modulebuilder.Format-SummarizeCommandAliases' # 'Dotils.Modulebuilder.Format-SummarizeCommandAliases' = { 'Dotils.Module.Format-AliasesSummary' }
        #


        'Dotils.Start-WatchForFilesModified' # 'Dotils.Start-WatchForFilesModified' = { <none> }
        'Dotils.Select-NotBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        'Dotils.Random.Module' #  Dotils.Random.Module = { <none> }
        'Dotils.Random.Command' #  Dotils.Random.Command = { <none> }
        'Dotils.Random.CommandExample' #  Dotils.Random.Command = { <none> }

        'Dotils.Debug.Find-Variable.old' # <none>
        'Dotils.FindExceptionSource' # <none>
        #
        # ...
        'Dotils.Debug.Find-Variable'
        'Dotils.Format-TaggedUnionString'
        'Dotils.Join.Brace'
        'Join.Pad.Item'
        # ...
        #
        'Dotils.Type.Info' # '.As.TypeInfo'
        'Dotils.DB.toDataTable' # 'Dotils.ConvertTo-DataTable


        'Dotils.Build.Find-ModuleMembers' # <none>
        'Dotils.Search-Pipescript.Nin' # <none>
        #
        'Dotils.InferCommandCategory'  # <none>
        'Dotils.Find-MyNativeCommand' # <none>
        # dups?
        'Dotils.Find-MyNativeCommandKind'  # <none> but check it
        'Dotils.Get-NativeCommand' # <none> but check it
        #
        #
        'Dotils.Find-MyWorkspace'  # Find-MyWorkspace
        'Dotils.SelectBy-Module' # 'SelectBy-Module', 'Dotils.SelectBy-Module', 'SelectBy-Module'


        #
        'Dotils.Select-ExcludeBlankProperty' #  'Select-ExcludeBlankProperty'
        # 'Dotility.CompareCompletions'
        # 'Dotility.GetCommand'
        'Dotils.CompareCompletions'
        'Dotils.GetCommand'
        'Dotils.Render.ErrorRecord.Fancy'
        'Dotils.Render.ErrorRecord'
        'Dotils.Tablify.ErrorRecord'
        'Dotils.Measure-CommandDuration'
        'Dotils.JoinString.As' # 'Join.As'
        ## some string stuff

        # 'Dotils.Write.Info' # 'Write.Info'
        'Dotils.Write.Info.Fence' # 'Write.Info.Fence'
        'Dotils.String.Normalize.LineEndings' # 'String.Normalize.LineEndings'
        'Dotils.ClampIt'  # 'ClampIt'
        'Dotils.String.Visualize.Whitespace' # 'String.Visualize.Whitespace'
        'Dotils.String.Transform.AlignRight' # 'String.Transform.AlignRight'
        'Dotils.Testing.Validate.ExportedCmds' # 'MonkeyBusiness.Vaidate.ExportedCommands'
        'Dotils.Join.CmdPrefix'
        ## --
        'Dotils.Html.Table.FromHashtable' # 'Marking.Html.Table.From.Hashtable'
        ## until
        'Dotils.Stdout.CollectUntil.Match' # 'PipeUntil.Match' #
        'Dotils.Out.Grid2' # <none>
        'Dotils.Render.Callstack' # => { '.CallStack', 'Render.Stack' }
        'Dotils.Write-NancyCountOf' # => { 'CountOf', 'OutNull' }
        'Dotils.Grid' # => { 'Nancy.OutGrid', 'Grid' }
        'Dotils.PSDefaultParams.ToggleAllVerboseCommands' # => { }
        'Dotils.LogObject' # 'Dotils.LogObject' => { '㏒' }
        'Dotils.*'
    )
    | Sort-Object -Unique
    Alias    = @(
        # 2024-09-05
        'Quick.Fd' # => 'Dotils.Fd.Main'
        # 2024-09-02
        'Quick.Html.Doc'
        # 2024-08-23
        'Quick.ScriptMethodParams' # => 'Dotils.CommandInfo.ScriptMethodParams'
        'ScriptMethodParams' #       => 'Dotils.CommandInfo.ScriptMethodParams'
        # 2024-08-01
        'HexLiteral'
        'Quick.HexLiteral'

        # 2024-07-22
        'Quick.BatLog'
        # 2024-07-05
        'GoItem'

        # 2024-05-26
        'ReImpo'
        'Quick.ReImpo'

        # 2024-05-25
        'Quick.ToastAlarm'
        'Quick.WarnOnce'
        # 2024-05-18
        'Quick.Fd.IsPipescript'
        'Quick.Pwsh.Nop'
        'Quick.Jekyll'
        # 2024-05-16
        'RegEsc'
        'Convert.Regex.MatchGroup'
        'Show.ShortName'
        'Show.LongName'
        # 2024-05-15
        'Convert.ScriptBlock.asRange'

        # 2024-05-15
        'Fmt-Path.Color'
        '.Show.Dict'
        '.Show.Path'
        # 2024-05-13
        'Quick.Es'


        # 2024-05-12
        'Quick.Fmt.Sb'
        # 2024-02-03
        'Code.Pipe'
        # 2024-02-02
        '.Fmt.Join-BlockDelim'
        '.Fmt.*'

        'Dotils.SetByteContent'     # 'Dotils.Set-Content.AsBytes' = { 'Dotils.SetContent.AsBytes', 'Dotils.SetByteContent', 'SC.RawBytes', 'SC.AsBytes' }
        'Dotils.SetContent.AsBytes' # 'Dotils.Set-Content.AsBytes' = { 'Dotils.SetContent.AsBytes', 'Dotils.SetByteContent', 'SC.RawBytes', 'SC.AsBytes' }
        'SC.AsBytes'                # 'Dotils.Set-Content.AsBytes' = { 'Dotils.SetContent.AsBytes', 'Dotils.SetByteContent', 'SC.RawBytes', 'SC.AsBytes' }
        'SC.RawBytes'               # 'Dotils.Set-Content.AsBytes' = { 'Dotils.SetContent.AsBytes', 'Dotils.SetByteContent', 'SC.RawBytes', 'SC.AsBytes' }

        'Dotils.GetByteContent'     # 'Dotils.Get-Content.AsBytes' = { 'Dotils.GetContent.AsBytes', 'Dotils.GetByteContent', 'Gc.RawBytes', 'Gc.AsBytes' }
        'Dotils.GetContent.AsBytes' # 'Dotils.Get-Content.AsBytes' = { 'Dotils.GetContent.AsBytes', 'Dotils.GetByteContent', 'Gc.RawBytes', 'Gc.AsBytes' }
        'Gc.AsBytes'                # 'Dotils.Get-Content.AsBytes' = { 'Dotils.GetContent.AsBytes', 'Dotils.GetByteContent', 'Gc.RawBytes', 'Gc.AsBytes' }
        'Gc.RawBytes'               # 'Dotils.Get-Content.AsBytes' = { 'Dotils.GetContent.AsBytes', 'Dotils.GetByteContent', 'Gc.RawBytes', 'Gc.AsBytes' }

        # 2024-01-13
        'Split.NL'
        'Fmt.FilePath'
        'Render.FilePath'

        # 2024-01-08
        'j.Hex'     # 'Dotils.Fmt.Join-Hex' = { 'j.Hex', 'Fmt.Hex' }
        'Fmt.Hex'   # 'Dotils.Fmt.Join-Hex' = { 'j.Hex', 'Fmt.Hex' }
        # 2024-01-07
        'Fmt.Sci'
        'Fmt-Sci'
        # 2023-12-28
        'Fmt.*'
        'DbgTool.*'
        'Debug.*'
        # 2023-12-27
        'Fetch*'
        'List.*'
        'Render.*'
        # 2023-12-13
        'Dot.ProxyCmd'
        'Dot.List.Contains'
        'Dot.Props'
        'Dot.*'

        # 2023-12-06
        'GitSel'
        '.Git*'
        'Dotils.*'
        # 2023-11-26
        'f.Predent' # 'Dotils.BasicFormat.Predent' = { 'f.Predent' }

        # 2023-11-16
        'Dotils.*'
        'Fmt.NL' # 'Dotils.Format.NumberedList' = { 'Fmt.NL' }

        # 2023-11-11
        'Dt.Now' # 'Dotils.Datetime.Now' = { 'Dt.Now', 'DateTime.Now' }
        'DateTime.Now' # 'Dotils.Datetime.Now' = { 'Dt.Now', 'DateTime.Now' }

        'Dto.Now' # 'Dotils.DatetimeOffset.Now' = { 'Dto.Now', 'DatetimeOffset.Now' }
        'DatetimeOffset.Now' # 'Dotils.DatetimeOffset.Now' = { 'Dto.Now', 'DatetimeOffset.Now' }
        # 'Date.NamedFormatStr' # 'Dotils.Datetime.NamedFormatStr' = { 'Date.NamedFormatStr'  } # moved to: <H:/data/2023/dotfiles.2023/pwsh/dots_psmodules/Dotils/Completions.NamedDateFormatString.psm1>


        # 2023-11-06
        'Render.ModuleName' # 'Dotils.Format-ModuleName' = { 'Render.ModuleName' }
        'Dotils.NL' #  'Dotils.Write.NumberedList'  = { 'Dotils.NL', 'NL' }
        'NL' #  'Dotils.Write.NumberedList'  = { 'Dotils.NL', 'NL' }

        # 2023-11-05
        'ShowEscapes' # 'Dotils.Show-Escapes' = { 'ShowEscapes', 'Show-Escapes' }
        'Show-Escapes' # 'Dotils.Show-Escapes' = { 'ShowEscapes', 'Show-Escapes' }

        'Is.Mod' # 'Dotils.Test.IsModulus' = { 'Is.Modulus', 'Is.Mod' }
        'Is.Modulus' # 'Dotils.Test.IsModulus' = { 'Is.Modulus', 'Is.Mod' }
        # 2023-11-03
        'AddLabel' # 'Dotils.AddLabel' = { 'AddLabel' }
        'Format-RenderBool' # 'Dotils.Format-RenderBool'  = { 'Format-RenderBool' }
        'Json.Colorize' # 'Dotils.Colorize.Json' = { 'Json.Colorize' }

        # 2023-10-12
        'Some' # 'Dotils.Select.Some.NoMore' = { 'Some', 'One' }
        'One' # 'Dotils.Select.Some.NoMore' = { 'Some', 'One' }
        # 2023-10-11
        'Text.Case'
        'Dotils.Culture.Gci' # 'Dotils.Culture.Get' = { 'Dotils.Culture.Gci' }

        # 2023-10-01
        'Gcl.Gi' # 'Dotils.Get-Item.FromClipboard' = { 'Gcl.Gi' }
        'Gcl.GetItem' # 'Dotils.Get-Item.FromClipboard' = { 'Gcl.Gi' }
        # 2023-09-23
        # 'Where.One'   # 'Dotils.Where.MatchesOne' = { 'Where.One',  '?AnyMatch', '?AnyOne' }
        '?AnyMatch'  # 'Dotils.Where.MatchesOne' = { 'Where.One',  '?AnyMatch', '?AnyOne' }
        '?AnyOne' # 'Dotils.Where.MatchesOne' = { 'Where.One',  '?AnyMatch', '?AnyOne' }

        'WildStr' # 'Dotils.Format.WildcardPattern'
        'Join.Wild' # 'Dotils.Format.WildcardPattern'
        # 'Dotils.Format.WildcardPattern' # 'Dotils.Format.WildcardPattern' = { 'Dotils.Format.WildcardPattern', 'WWi }
        # All one, disable most
        '-As' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }
        # '.As.Type' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }
        # '.Op.As' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }
        # 'Dotils.AsType' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }
        'Op.As' # 'Dotils.Operator.TypeAs' = { 'Dotils.AsType', '-As', 'Op.As', '.As.Type', '.Op.As' }

        # 2023-09-22
        'Dotils.Accum.Hash' # 'Dotils.Accumulate.Hashtables' = { 'Dotils.Accum.Hash', 'nin.Accum.Hash' }
        'nin.Accum.Hash' # 'Dotils.Accumulate.Hashtables' = { 'Dotils.Accum.Hash', 'nin.Accum.Hash' }

        # 2023-09-11
        'Import.Macro'
        'Dotils.URL.GetInfo' #  'Dotils.Uri.GetInfo' = { 'Dotils.URL.GetInfo' }

        # 2023-09-04
        '.Format.Wrap.LongLines'
        'Render.Dom.Attributes' # 'Dotils.Render.Dom.Attributes' = { 'Render.Dom.Attributes' }
        'Render.Bool' # 'Dotils.Render.Bool' = { 'Render.Bool', '.Render.Bool' }
        '.Render.Bool' # 'Dotils.Render.Bool' = { 'Render.Bool', '.Render.Bool' }
        '.debug.format-UpdateTypedata.Literal' # 'Dotils.DebugUtil.Format.UpdateTypedataLiteral' = { '.debug.format-UpdateTypedata.Literal', 'literal.UpdateTypeDataProperty' }
        'literal.UpdateTypeDataProperty' # 'Dotils.DebugUtil.Format.UpdateTypedataLiteral' = { '.debug.format-UpdateTypedata.Literal', 'literal.UpdateTypeDataProperty' }

        # 2023-09-03
        'Some'
        'LastOut' # 'Dotils.LastOut' = { 'LastOut' }
        '.As.HexString' # 'Dotils.Format-HexString' = { '.As.HexString', 'fmt.HexString', 'HexString' }
        'fmt.HexString' # 'Dotils.Format-HexString' = { '.As.HexString', 'fmt.HexString', 'HexString' }
        'HexString' # 'Dotils.Format-HexString' = { '.As.HexString', 'fmt.HexString', 'HexString' }

        # 2023-09-02
        'Resolve.Ast'  # 'Dotils.Resolve.Ast' = { 'Resolve.Ast' }
        # 2023-08-31
        'Dotils.Find-VariableByType' # 'Dotils.Select-VariableByType' = { 'Dotils.Find-VariableByType' }(
        # 2023-08-26
        '.Split.WordByCase' # 'Dotils.Split.WordByCase' = { '.Split.WordByCase' }

        # 2023-08-24
        'Infa' # 'Dotils.Write-Information' = { 'wInfo', 'Infa', 'Write.Infa' }
        'wInfo' # 'Dotils.Write-Information' = { 'wInfo', 'Infa', 'Write.Infa' }
        'Write.Infa' # 'Dotils.Write-Information' = { 'wInfo', 'Infa', 'Write.Infa' }
        'Write.StrInfa' # 'Dotils.Write-StringInformation' = { 'Write.StringInfa', 'Write.StrInfa' }
        'Write.StringInfa' # 'Dotils.Write-StringInformation' = { 'Write.StringInfa', 'Write.StrInfa' }

        'Resolve.Module' # 'Dotils.Resolve.Module' = { 'Resolve.Module' }
        # 2023-08-21
        '.Cached.Sb' # 'Dotils.Get-CachedExpression' = { .Cached.Sb }

        # 2023-08-20

        'Regex.Split.Basic' # 'Dotils.Regex.Split.Basic' = { 'Regex.Split.Basic' }
        '.Split'

        '.fmt.Datetime' # 'Dotils.Format-Datetime' = { '.fmt.Datetime', 'Dotils.Format.Datetime' }
        'Dotils.Format.Datetime' # 'Dotils.Format-Datetime' = { '.fmt.Datetime', 'Dotils.Format.Datetime' }
        'Nameish' # 'Dotils.Select-Nameish' = { 'Select.Namish', 'Nameish' }
        'Select.Namish' # 'Dotils.Select-Nameish' = { 'Select.Namish', 'Nameish' }
        'Resolve.Command' # 'Dotils.Resolve.Command' = { 'Resolve.Command' }

        # 2023-08-18
        'Dotils.Color.Hex' # 'Dotils.PStyle.Color.Hex' = { 'Dotils.Color.Hex', 'c.Hex' }
        'c.Hex' # 'Dotils.PStyle.Color.Hex' = { 'Dotils.Color.Hex', 'c.Hex' }

        'Dotils.Color.Gray' # 'Dotils.PStyle.Color.Gray' = { 'Dotils.Color.Gray', 'C.Gray' }
        'c.Gray' # 'Dotils.PStyle.Color.Gray' = { 'Dotils.Color.Gray', 'C.Gray' }
        'Resolve.TypeInfo'          # 'Dotils.Resolve.TypeInfo' = { Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }
        'Dotils.ConvertTo.TypeInfo' # 'Dotils.Resolve.TypeInfo' = { Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }

        '.Is.Type' # 'Dotils.Test-IsOfType' = { '.Is.Type', '.Is.OfType', 'Dotils.Test-IsOfType' }
        '.Is.OfType'  # 'Dotils.Test-IsOfType' = { '.Is.Type', '.Is.OfType', 'Dotils.Test-IsOfType' }
        'Dotils.Test-IsOfType' # 'Dotils.Test-IsOfType' = { '.Is.Type', '.Is.OfType', 'Dotils.Test-IsOfType' }

        '.Select.FirstTime' # 'Dotils.Select-TemporalFirstObject' = { '.Select.FirstTime' }
        'gt' # 'Dotils.Quick.GetType' = { 'gt', '.quick.GetType' }
        '.quick.GetType' # 'Dotils.Quick.GetType' = { 'gt', '.quick.GetType' }(
        'Dotils.Describe.Type' # 'Dotils.Debug.GetTypeInfo' = { 'Dotils.Describe.Type' }

        # 2023-08-15
        '.str.Transform' # 'Dotils.String.Transform' = { '.str.Transform' }
        '.Render.TreeItem' # 'Dotils.Render.TextTreeLine'  = { '.Render.TreeItem', '.Render.TreeLine' }
        '.Render.TreeLine' # 'Dotils.Render.TextTreeLine'  = { '.Render.TreeItem', '.Render.TreeLine' }

        # 2023-08-14
        'WriteEveryN'  # 'Dotils.Write-StatusEveryN' = { '.status.EveryN', 'status.EveryN', 'Write-EveryStatus','WriteEveryN'}
        '.status.EveryN'  # 'Dotils.Write-StatusEveryN' = { '.status.EveryN', 'status.EveryN', 'Write-EveryStatus','WriteEveryN'}
        'status.EveryN'  # 'Dotils.Write-StatusEveryN' = { '.status.EveryN', 'status.EveryN', 'Write-EveryStatus','WriteEveryN'}
        'Write-EveryStatus'  # 'Dotils.Write-StatusEveryN' = { '.status.EveryN', 'status.EveryN', 'Write-EveryStatus','WriteEveryN'}

        # 2023-08-13
        '.Render.Sec'   # 'Dotils.Describe.Timespan.AsSeconds' = { 'Sec', '.Render.Sec' }
        'Sec'  # 'Dotils.Describe.Timespan.AsSeconds' = { 'Sec', '.Render.Sec'}
        '.Render.Ms' # 'Dotils.Describe.Timespan.AsMilliseconds' = { 'Ms', '.Render.Ms' }
        'Ms' # 'Dotils.Describe.Timespan.AsMilliseconds' = { 'Ms', '.Render.Ms' }

        '.to.Timespan'  # 'Dotils.ConvertTo-TimeSpan' = { '.to.Timespan', '.as.Timespan', 'Dotils.ConvertTo.TimeSpan' }
        '.as.Timespan'  # 'Dotils.ConvertTo-TimeSpan' = { '.to.Timespan', '.as.Timespan', 'Dotils.ConvertTo.TimeSpan' }


        '.test' # 'Dotils.Test-AllResults' =  { '.test', '.Assert', 'Assert', 'Test-Results' }
        '.Assert' # 'Dotils.Test-AllResults' =  { '.test', '.Assert', 'Assert', 'Test-Results' }
        'Assert' # 'Dotils.Test-AllResults' =  { '.test', '.Assert', 'Assert', 'Test-Results' }
        'Test-Results' # 'Dotils.Test-AllResults' =  { '.test', '.Assert', 'Assert', 'Test-Results' }

        # 'Is' # 'Dotils.Operator.TypeIs' = { 'Is', '.Is.Type', 'Op.Is' }(
        '.Is.Type' # 'Dotils.Operator.TypeIs' = { 'Is', '.Is.Type', 'Op.Is' }(
        'Op.Is' # 'Dotils.Operator.TypeIs' = { 'Is', '.Is.Type', 'Op.Is' }(

        # 2023-08-10
        # '.Resolve.TypeInfo' # 'Dotils.Resolve.TypeInfo.WithDefault' = { '.Resolve.TypeInfo' }
        '.To.Type.FromPStypes' # 'Dotils.To.Type.FromPSTypenames' = { '.To.Type.FromPStypes', '.to.PSTypes' }
        '.To.PSTypes' # 'Dotils.To.Type.FromPSTypenames' = { '.To.Type.FromPStypes', '.to.PSTypes' }
        'Help.FromType' # 'Dotils.Help.FromType' = { 'Help.FromType', 'Help.From' }
        'Help.From' # 'Dotils.Help.FromType' = { 'Help.FromType', 'Help.From' }
        'Dotils.Text.NormalizeLineEnding' # 'Dotils.Text.NormalizeLineEnding' = { '.Text.NormalizeNL' }
        '.to.Duration'  # 'Dotils.To.Duration' = { '.to.Duration', '.Duration', '.to.Timespan' }
        '.Duration'  # 'Dotils.To.Duration' = { '.to.Duration', '.Duration', '.to.Timespan' }
        '.to.Timespan'  # 'Dotils.To.Duration' = { '.to.Duration', '.Duration', '.to.Timespan' }

        '.VsCode.ConvertTo.Snippet' # 'Dotils.VsCode.ConvertTo.Snippet' = { '.VsCode.ConvertTo.Snippet' }
        '.Describe' # 'Dotils.Describe' = { '.Describe' }
        '.Select.One' # 'Dotils.Select.One' = { '.Select.One', 'One' }
        'One' # 'Dotils.Select.One' = { '.Select.One', 'One' }




        '.Ansi.Fg' # 'Dotils.Ansi.Write' = {  '.Ansi.Fg', '.Ansi.Bg', '.Ansi.Write' }
        '.Ansi.Bg' # 'Dotils.Ansi.Write' = {  '.Ansi.Fg', '.Ansi.Bg', '.Ansi.Write' }
        '.Ansi.Write' # 'Dotils.Ansi.Write' = {  '.Ansi.Fg', '.Ansi.Bg', '.Ansi.Write' }


        'FullName' # 'Dotils.Format.FullName' = { 'FullName', '.Format.FullName', '.fmt.Name' }
        '.Format.FullName', # 'Dotils.Format.FullName' = { 'FullName', '.Format.FullName', '.fmt.Name' }
        '.fmt.Name' # 'Dotils.Format.FullName' = { 'FullName', '.Format.FullName', '.fmt.Name' }
        '.to.Encoding' # 'Dotils.To.Encoding' = { '.to.Encoding', '.as.Encoding' }
        '.as.Encoding' # 'Dotils.To.Encoding' = { '.to.Encoding', '.as.Encoding' }
        'Console.Encoding' # 'Dotils.Console.GetEncoding' = { 'Console.Encoding' }
        'Console.SetEncoding' # 'Dotils.Console.SetEncoding' = { 'Console.SetEncoding' }

        '.Help.FromType' # 'Dotils.Help.FromType' = { '.Help.FromType' }
        'Console.Width' # 'Console.GetWindowWidth'  = { 'Console.Width', 'Console.WindowWidth' }
        'Console.WindowWidth' # 'Console.GetWindowWidth'  = { 'Console.Width', 'Console.WindowWidth' }


        '.Match.Word' # Dotils.Regex.Match.Word' # = { '.Match.Word' }
        # 2023-08-08
        '.Has.Prop' # 'Dotils.Has.Property' = { '.Has.Prop' }
        '.Has.Prop.Regex' # 'Dotils.Has.Property.Regex' = { '.Has.Prop.Regex' }
        '.Goto.Kind' # 'Dotils.Goto.Kind' = { '.Go.Kind', '.Goto.Kind' }
        '.Go.Kind' # 'Dotils.Goto.Kind' = { '.Go.Kind', '.Goto.Kind' }
        '.To.Obj' # 'Dotils.To.PSCustomObject' = { '.To.Obj', '.as.Obj }
        '.as.Obj' # 'Dotils.To.PSCustomObject' = { '.To.Obj', '.as.Obj }

        # 2023-08-07

        '.Join.Csv' # 'Dotils.Join.Csv' = { '.Join.Csv', 'Join.Csv', 'Csv' }
        'Join.Csv' # 'Dotils.Join.Csv' = { '.Join.Csv', 'Join.Csv', 'Csv' }
        'Csv' # 'Dotils.Join.Csv' = { '.Join.Csv', 'Join.Csv', 'Csv' }


        '.quick.PSTypes' # 'Dotils.Quick.PSTypeNames' = { '.quick.PSTypes' }
        '.Match.Start' # Dotils.Regex.Match.Start = { '.Match.Start', '.Match.Prefix' }
        '.Match.Prefix' # Dotils.Regex.Match.Start = { '.Match.Start', '.Match.Prefix' }
        '.Match.End' # Dotils.Regex.Match.End = { '.Match.End', '.Match.Suffix' }
        '.Match' # 'Dotils.Regex.Match = { '.Match' }
        '.Match.Suffix' # Dotils.Regex.Match.End = { '.Match.End', '.Match.Suffix' }
        'ec' # 'Dotils.Err.Clear' = { 'ec' }
        '.Text.Pad.Segment' # 'Dotils.Text.Pad.Segment' =  { '.Text.Pad.Segment', '.Text.Segment' }'
        '.Text.Segment' # 'Dotils.Text.Pad.Segment' =  { '.Text.Pad.Segment', '.Text.Segment' }'
        # 2023-08-06
        '.Iter.Text' # 'Dotils.Iter.Text' = { '.Iter.Text' }
        '.Iter.Enumerator'  # 'Dotils.Iter.Enumerator' = { '.Iter.Enumerator' }
        '.Summarize.SharedProperties' # 'Dotils.Summarize.CollectionSharedProperties' = { '.Summarize.SharedProperties' }
        # 2023-08-05
        '.Is.SubType' # 'Dotils.Is.SubType' = { '.Is.SubType' }
        '.Add.IndexProp' # 'Dotils.Add.IndexProp' = { '.Add.IndexProp' }
        '.Has.Prop' # 'Dotils.Has.Prop' = { '.Has.Prop' }
        '.Is.Not' # 'Dotils.Is.Not' = { '.Is.Not' }
        '.Is.Blank' # 'Dotils.Is.Blank' = { '.Is.Blank' }
        '.Iter.Prop' # 'Dotils.Iter.Prop' = { '.Iter.Prop' }
        '.Describe.Error' # 'Dotils.Describe.ErrorRecord' = { '.Describe.Error' }
        '.Is.KindOf' # 'Dotils.Is.KindOf' = { '.Is.KindOf' }
        '.Is.Error.FromParamBlockSyntax' # 'Dotils.Is.Error.FromParamBlock' = { '.Is.Error.FromParamBlockSyntax' }
        '.Distinct'
        # 2023-08-04
        '.Is.DirectPath' # 'Dotils.Is.DirectPath' = { '.Is.DirectPath' }
        '.to.envVarPath' # 'Dotils.to.EnvVarPath' = { '.to.envVarPath' }
        # 2023-08-03
        '.to.Dict' # 'Dotils.To.Hashtable' = { '.to.Dict', '.as.Dict' }
        '.as.Dict' # 'Dotils.To.Hashtable' = { '.to.Dict', '.as.Dict' }
        # 2023-08-02
        'Dotils.Write-TypeOf' # 'Dotils.Write-TypeOf' = { 'WriteKindOf',  'OutKind', 'LabelKind'  }
        'WriteKindOf' # 'Dotils.Write-TypeOf' = { 'WriteKindOf',  'OutKind', 'LabelKind'  }
        'OutKind' # 'Dotils.Write-TypeOf' = { 'WriteKindOf',  'OutKind', 'LabelKind'  }
        'LabelKind' # 'Dotils.Write-TypeOf' = { 'WriteKindOf',  'OutKind', 'LabelKind'  }


        # 2023-07-31
        '.to.Resolved.CommandName' # Dotils.To.Resolved.CommandName = { '.to.Resolved.CommandName' }

        '.quick.History' # Dotils.Quick.History = { '.quick.History', 'QuickHistory' }
        'QuickHistory' # Dotils.Quick.History = { '.quick.History', 'QuickHistory' }

        '.quick.Pwd'  # 'Dotils.Quick.Pwd' = { '.quick.Pwd', 'QuickPwd' }
        'QuickPwd' # 'Dotils.Quick.Pwd' = { '.quick.Pwd', 'QuickPwd' }

        # 2023-07-24
        'Dotils.Text.Prefix' # 'Dotils.Text.Wrap' = { 'Dotils.Text.Prefix', 'Dotils.Text.Suffix', '.Text.Suffix', '.Text.Prefix' }
        'Dotils.Text.Suffix'  # 'Dotils.Text.Wrap' = { 'Dotils.Text.Prefix', 'Dotils.Text.Suffix', '.Text.Suffix', '.Text.Prefix' }
        '.Text.Suffix'  # 'Dotils.Text.Wrap' = { 'Dotils.Text.Prefix', 'Dotils.Text.Suffix', '.Text.Suffix', '.Text.Prefix' }
        '.Text.Prefix'  # 'Dotils.Text.Wrap' = { 'Dotils.Text.Prefix', 'Dotils.Text.Suffix', '.Text.Suffix', '.Text.Prefix' }
        'md.Write.Url' # 'Dotils.md.Write.Url' = { 'md.Write.Url' }
        'md.Format.EscapeFilepath' # 'Dotils.md.Format.EscapeFilepath ' = 'md.Format.EscapeFilepath'
        'nat'  # 'Dotils.GetAt' = { 'At', 'Nat', 'gnat' }
        'gnat' # 'Dotils.GetAt' = { 'At', 'Nat', 'gnat' }
        'Dotils.Write-DimText' # 'Dotils.Format.Write-DimText' = { 'Dotils.Write-DimText' }
        #
        'Dotils.ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }
        'Dotils.ShortString.Basic'  # 'Dotils.Format-ShortString.Basic' = { 'Dotils.ShortString.Basic' }
        # 'Dotils.Format-ShortString' # 'Dotils.Format-ShortString' = { 'Dotils.ShortString' }

        'QuickInfo' # 'Dotils.Object.QuickInfo' = { 'QuickInfo' }

        'Dotils.Module.Format-AliasesSummary' # 'Dotils.Modulebuilder.Format-SummarizeCommandAliases' = { 'Dotils.Module.Format-AliasesSummary' }
        #



        #

        'Dotils.DropBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        'Dotils.Where-NotBlankKeys' # 'Dotils.Select-NotBlankKeys' = { 'Dotils.DropBlankKeys', 'Dotils.Where-NotBlankKeys' }
        '㏒' # 'Dotils.LogObject' => { '㏒' }
        'CountOf' # 'Dotils.Write-NancyCountOf' => { CountOf, OutNull }
        'OutNull' # 'Dotils.Write-NancyCountOf' => { CountOf, OutNull }
        'Nancy.OutGrid' # 'Dotils.Grid' => { 'Nancy.OutGrid', 'Grid' }
        'Grid'          # 'Dotils.Grid' => { 'Nancy.OutGrid', 'Grid' }

        '.As.TypeInfo' # 'Dotils.Type.Info'
        'Dotils.ConvertTo-DataTable' # 'Dotils.DB.toDataTable'
        'Find-MyWorkspace'  # 'Dotils.Find-MyWorkspace'

        'SelectBy-Module' # Dotils.SelectBy-Module
        #
        'Select-ExcludeBlankProperty' # 'Dotils.Select-ExcludeBlankProperty'
        # '.CallStack', 'Render.Stack'
        '.CallStack'   # 'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }
        'Render.Stack' # 'Dotils.Render.Callstack' => { '.CallStack', 'Render.Stack' }


        'Join.As' # 'Dotils.JoinString.As'
        'CompareCompletions' # 'Dotils.CompareCompletions'
        # 'TimeOfSB' # 'Dotils.Measure-CommandDuration'
        'DeltaOfSBScriptBlock' # 'Dotils.Measure-CommandDuration'
        'dotils.DeltaOfSB'     # 'Dotils.Measure-CommandDuration'
        'MonkeyBusiness.Vaidate.ExportedCommands' # 'Dotils.Testing.Validate.ExportedCmds'
        ## some string stuff
        # 'Console.GetWindowWidth'  #
        # 'Write.Info' # 'Dotils.Write.Info'
        'Write.Info.Fence' # 'Dotils.Write.Info.Fence'
        'String.Normalize.LineEndings' # 'Dotils.String.Normalize.LineEndings'
        'ClampIt'  # 'ClampIt'
        'String.Visualize.Whitespace' # 'String.Visualize.Whitespace'
        'String.Transform.AlignRight' # 'S
        ## --
        'Marking.Html.Table.From.Hashtable' # 'Dotils.Html.Table.FromHashtable'
        'Dotils.Debug.Compare-VariableScope'
        'Dotils.Debug.Get-Variable'
        'PipeUntil.Match' # Dotils.Stdout.CollectUntil.Match
    ) | Sort-Object -Unique
    Variable = @(
        'WasHistory'
        'Bdg_LastSelect'
        'Bdg_*'

        if('export special debug vars') {
            '___lastImport'
        }
    )
}
Export-ModuleMember @exportModuleMemberSplat

Dotils.Add-PsModulePath -TestOnly -PrependPath -InputPath 'H:\data\2023\pwsh\PsModules.👨.Import'

Hr -fg magenta

[string[]]$cmdList = @(
    $exportModuleMemberSplat.Function
    $exportModuleMemberSplat.Alias
) | Sort-Object -Unique


h1 'A few aliases'
get-alias | ?{ $_.Name -match '^\.' }
gcm -m dotils | ?{ $_.Name -match 'start|text|begin' -or $_.Name -match '^\.' }


@'
try:
    Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
'@
'dotils next:
function Dotils.Stash-NewFileBuffer {
    quickly dump files into a location to be used later, quick ideas. no naming.
}
'

# Dotils.Testing.Validate.ExportedCmds

"left off '<H:\data\2023\pwsh\temp-describe-sketch.ps1>'" | write-host -back 'darkyellow'
'finish code at <file:///H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Dotils._merge_wip.ps1>' | Dotils.Write-DimText | write-warning

'finisH: "Dotils.Get-CachedExpression"' | Dotils.Write-DimText | write-host

if(-not (gcm 'dom.Render.Element.fromAgilPack' -ea 'ignore')) {
    'auto-importing dom.* from dom.utils'  | write-host -back 'darkred'
    'H:\data\2023\pwsh\sketches\2023-09▸AngleParse WebDOM\2023-09 ⁞ PSParseHtml - xpath query ⁞ iter3.ps1' | Join-String -f " => import: {0}" | write-host -back darkgreen
    # . (gi -ea 'continue' 'H:\data\2023\pwsh\sketches\2023-09▸AngleParse WebDOM\2023-09 ⁞ PSParseHtml - xpath query ⁞ iter3.ps1')

} else {

    gcm 'dom.*' | sort Name | Ft -AutoSize | out-string | write-host
}
write-host -back 'orange' 'manual importing of TypeData, move to dotils'
'toCollect: H:\data\2023\pwsh\notebooks\Pwsh\TypeData-FormatData\Intro-Truncate-EditingOuterHtml-Props\Intro-Truncate-EditingOuterHtml-Props.ps1'
'toCollect: H:\data\2023\pwsh\sketches\2023-09▸AngleParse WebDOM\2023-09 ⁞ PSParseHtml - xpath query ⁞ iter3.ps1'
        | Join-String -f " => import: {0}"
        | write-host -back darkgreen
# . (gi -ea 'continue' 'H:\data\2023\pwsh\notebooks\Pwsh\TypeData-FormatData\Intro-Truncate-EditingOuterHtml-Props\Intro-Truncate-EditingOuterHtml-Props.ps1'
# )

H1 'Validate: ByCmdList'
$skipFinalValidateCommands = $True
if($SkipFinalValidateCommands) {
    '-Skipped final "Testing.Validate.ExportedCmds"' | write-host -back 'darkyellow'
} else {
    Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

    H1 'Validate: ModuleName'
    Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'
    Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils' | ? IsBad
    # return
    # Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList

    # hr -fg magenta

    # Dotils.Testing.Validate.ExportedCmds -ModuleName 'Dotils'

    # $stats | ft -AutoSize
    H1 'Validate:IsBad: double names'
    Dotils.Testing.Validate.ExportedCmds -CommandName $CmdList | ? IsBad
    # was: $stats | ?{ $_.IsAFunc -and $_.IsAnAlias }
}

'write-warning: finish:
    H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Paths.NewTempFiles.psm1'
| write-warning

'Dotsource additional completers: NamedDates'
    | Dotils.Write-DimText
    # | Infa
    | Write-Verbose -Verbose

# These completer classes work from tbis profile I forge global scope
# it seems like
$TryPath = Join-Path $PSScriptRoot 'Completions.NamedDateFormatString.psm1'
$TryPath | Get-Item -ea 'continue' | Join-String -op 'TryPath => ' | Write-Verbose -Verbose

# $TryPath = Join-Path $PSScriptRoot 'Dotils.Fonts.psm1'
# $TryPath | Get-Item -ea 'continue' | Join-String -op 'TryPath => ' | Write-Verbose -Verbose

if($False) {
    # Sometimes need to force remove it, depending on types
    impo $dotsrc -PassThru -Verbose
        |  Remove-Module -Verbose -ea 'silentlyContinue'
}
if($true) {
    Remove-Module 'Completions.NamedDateFormatString' -ea 'ignore' #  'silentlyContinue'
}

Import-Module $TryPath -PassThru -verbose -force -Scope 'Global' | Render.ModuleName
# Import-Module (join-path $PSScriptRoot 'Dotils.New-UsingStatement.psm1') -PassThru | Render.ModuleName
$AlwaysForce = @{
    Force = $true
    PassThru = $true
}
if($AlwaysForce.Force) {
    write-warning 'all sub module dotils are set to -Force '
}
Import-Module @alwaysForce ('H:\data\2023\pwsh\notebooks\Pwsh\Objects\Picky\Picky.psm1') | Render.ModuleName
Import-Module @alwaysForce (join-path $PSScriptRoot 'Dotils.New-UsingStatement.psm1') | Render.ModuleName
Import-Module @alwaysForce (join-path $PSScriptRoot 'Dotils.Fonts.psm1') | Render.ModuleName
impo @AlwaysForce 'nin.Ast' # 'H:\data\2023\pwsh\PsModules\nin.Ast\nin.Ast\nin.Ast.psm1'

Write-verbose 'pre-removing annoying modules, to decrease the size of Get-Command''s output'
Remove-Module 'JumpCloud*'
Remove-Module 'Az.*'

# # include forks: ? 'H:\data\2023\pwsh\my🍴\ugit.🍴\Use-Git.ps1'
# if($false -and 'useRegularFork') {
#     import-module -PassThru -Force 'H:\data\2023\pwsh\my🍴\ugit.🍴\Use-Git.ps1'
#         | Render.ModuleName
# } else {
#     'use non-fork so to the beta branch'
#     # import-module -PassThru -Force 'H:\data\2023\pwsh\my🍴\ugit.🍴.beta\ugit.psm1'
#     #     | Render.ModuleName
    # import-module -PassThru -Force 'H:\data\2023\pwsh\my🍴\ugit.🍴.beta\ugit.psm1' | fl
# }

# // this does not import
# $DotSrc = gi 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Template-CompleterType-AsCompletionsType.ps1' -ea 'continue'
# . $DotSrc

Dotils.Impo.PSReadLineExtensions -verbose
