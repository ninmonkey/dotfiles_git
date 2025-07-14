using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Globalization
using namespace System.Text
$global:StringModule_DontInjectJoinString = $true # this matters, because Nop imports the polyfill which breaks code on Join-String:  context/reason: <https://discord.com/channels/180528040881815552/446531919644065804/1181626954185724055> or just delete the module

$PROFILE | Add-Member -NotePropertyMembers @{
    Nin_AliasesEntry          = $PSCommandPath | Gi
    Nin_InlineFormatDataEntry = $PSCommandpath | Gi
    Nin_TypeAccelEntry        = $PSCommandPath | Gi
    'CurrentUser🐍Profile'    = (Join-Path $PSScriptRoot 'Profile.🦍.MinPipescript_profile.ps1' | gi )
    KnownLogpaths             = 'H:\data\2024\pwsh\gists🦍\Big List of Locations of Known Log Files.🦍.2024.md\LogPaths.yml'
} -Force -ea Ignore

$ENV:PATH = @(
    $Env:PATH
    gi 'G:\2023-git\Aws📁\aws-copilot-cli' ) | Join-String -sep ';'

$rl = [Microsoft.PowerShell.PSConsoleReadLine]
$xl8r ??= [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

<#
query for types:
find-type -FullName *PSReadLine* | % FullName

    Microsoft.PowerShell.GetPSReadLineOption
    Microsoft.PowerShell.SetPSReadLineOption
    Microsoft.PowerShell.ChangePSReadLineKeyHandlerCommandBase
    Microsoft.PowerShell.SetPSReadLineKeyHandlerCommand
    Microsoft.PowerShell.PSReadLine.OnModuleImportAndRemove

find-type -FullName *ps*read* -Namespace Microsoft.PowerShell* | % FullName | sort -Unique

    ChangePSReadLineKeyHandlerCommandBase
    GetPSReadLineOption
    Internal.IPSConsoleReadLineMockableMethods
    PSConsoleReadLine
    PSConsoleReadLine+HistoryItem
    PSConsoleReadLineOptions
    PSReadLine.OnModuleImportAndRemove
    SetPSReadLineKeyHandlerCommand
    SetPSReadLineOption
docs: https://learn.microsoft.com/en-us/powershell/module/psreadline/?view=powershell-7.4

#>
# $xl8r::Add( 'JsonSerializer', [Text.Json.Serialization.JsonSerializerContext] )
$xl8r::add('Linq.E',       [Linq.Enumerable])
$xl8r::add('Linq_New',     [Linq.Enumerable])
$xl8r::Add('StrInfo',      [Globalization.StringInfo])
$xl8r::Add('Sb',           [Text.StringBuilder])
$xl8r::Add('StrBuild',     [Text.StringBuilder])
$xl8r::Add('EncInfo',      [Text.EncodingInfo])
$xl8r::Add('RL',           [Microsoft.PowerShell.PSConsoleReadLine])
$xl8r::Add('RL_GetOpt',    [Microsoft.PowerShell.GetPSReadLineOption])
$xl8r::Add('RL_SetOpt',    [Microsoft.PowerShell.SetPSReadLineOption])
$xl8r::Add('RL_SetHandler',[Microsoft.PowerShell.SetPSReadLineKeyHandlerCommand]) # there is no get-handler
$xl8r::Add('RL_OnImport',  [Microsoft.PowerShell.PSReadLine.OnModuleImportAndRemove]) # there is no get-handler
$xl8r::Add('LangyPrims',   [System.Management.Automation.LanguagePrimitives]) # there is no get-handler

[Sb], [RL], [RL_GetOpt], [RL_SetOpt], [RL_SetHandler], [RL_OnImport], [LangyPrims]
    | Join-string -sep ',' -op 'Setting Accelerators: { RL, RL_GetOpt, RL_SetOpt, RL_SetHandler, RL_OnImport } => { ' -os ' } '



# . 'G:\2024-git\pwsh\SeeminglyScience👨\dotfiles\Documents\PowerShell\profile.ps1'

# WhoAmI?
#   whoAmI? => $PROFILE.CurrentUserAllHosts
#   pathAbs => $Env:UserProfile\SkyDrive\Documents\PowerShell\profile.ps1

# this is the profile on C in the standard location
# it's CurrentUserAllHosts
# I redirect to dotfiles

@(
    Import-Module -PassThru 'H:/data/2023/pwsh/PsModules.👨.Import/Jaykul👨/Jaykul👨Grouping/Jaykul👨Grouping.psm1'
    # import-module -PassThru -Force 'H:\data\2023\pwsh\my🍴\ugit.🍴.beta\ugit.psm1'
    Import-Module -passThru 'H:\data\2024\pwsh\PSModules.🐒.miniLocal\n🐒.LocalHost.Serve.GitLoggerAzureFunc\nin.LocalHost.Serve.GitLogger.psd1'
    Import-Module -passThru 'H:\data\2024\pwsh\PSModules.🐒.miniLocal\n🐒.GittingGood\nin.GittingGood.psd1'
    Import-Module -PassThru 'H:\data\2024\pwsh\PSModules.🐒.miniLocal\n🐒.JsonIt.Simple\nin.JsonIt.Simple.psd1'
    Import-Module -passThru 'H:\data\2024\pwsh\Modules.devNin.🦍\Rocktil\Rocktil\Rocktil.psd1'

) | Join-String -sep ', ' -Prop ModuleName | Write-Host -fore 'darkgray'

@(
    Set-Alias -PassThru -Name 'Label' -value 'Ninmonkey.Console\Write-ConsoleLabel' -Force
    Set-Alias -PassThru -Name 's' -value 'Select-Object'
    Set-Alias -PassThru -Name 'nin.Wrap' -value 'Ninmonkey.Console\Format-WrapJaykul'
)

$Env:PSModulePath = @(
    # gi -ea 'continue' 'H:\data\2024\pwsh\Pipescript'
    gi -ea 'continue' 'H:\data\2024\pwsh\PSModules'
    gi -ea 'stop' 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules' # for:  'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Dotils.psm1'
    $Env:PSModulePath
) | Join-String -sep ([IO.Path]::PathSeparator)

$Env:PSModulePath = @(
    $Env:PSModulePath
    $toAdd = gi 'E:\PSModulePath.2023.root\Main' # assume this exists
) | Join-String -sep ([IO.Path]::PathSeparator)


## global aliases
@(
    Set-Alias -passThru 'Label' -value 'Ninmonkey.Console\Write-ConsoleLabel'
    Set-Alias -passThru -ea 'ignore' 'impo' -value 'Import-Module'
    Set-Alias -passThru -ea 'ignore' 'cl' -value  'Set-Clipboard'
    Set-Alias -passThru -ea 'ignore' 'gcl' -value 'Get-Clipboard'
    Set-Alias -passThru -ea 'ignore' 'shot' -Value 'Microsoft.PowerShell.ConsoleGuiTools\Show-ObjectTree' -Description 'View nested objects, like pester config'
    set-alias -PassThru 'Encoding' -value Dotils.To.Encoding
)
<# single / multi line line #>
    | Join-String -f "• {0}" -op "Set/Add: Alias = [ " -os " ]" -sep ' '
    | write-host -fore 'darkgray'
# | Join-String -f "• {0}" -op "Set/Add: Alias = [ " -os " ]"


# or with nin already loaded

# | Join-String -f "`n  • {0}" -op "Set/Add: Alias = [ " -os "`n]"
    # | Join.UL -Options @{
    #     ULHeader =  @( (hr 1) ; Label "New/Set" "Alias"  ) | Join-String
    #     ULFooter  = (hr 0) }

# $Profile.CurrentUserAllHosts: shared (all3): VSCode, VSCode Debug Term, and windows term (external)

# if($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

# invoke dotfile location
#   ex: H:/data/2023/dotfiles.2023/pwsh/profile.ps1
. (Get-Item -ea 'continue' (Join-Path $Env:Nin_Dotfiles 'pwsh/profile.ps1'))

# if($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
function Module.Register.ArgCompleters {
    $sb_argCompleter_AddType_AssemblyName = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $assemblyItems = @(
                Get-Assembly | sort-Object -Unique
                | ?{ $_.Name -match $wordToComplete }
            )

        $PropNames = @( 'Name', 'Version', 'Culture', 'Target', 'ContentType', 'NameFlags', 'PublicKeyToken', 'FullName', 'HashAlgorithm', 'VersionCompatibility', 'FileName', 'CodeBase', 'EntryPoint', 'DefinedTypes', 'IsCollectible', 'ManifestModule', 'ReflectionOnly', 'Location', 'ImageRuntimeVersion', 'GlobalAssemblyCache', 'HostContext', 'IsDynamic', 'ExportedTypes', 'IsFullyTrusted', 'CustomAttributes', 'EscapedCodeBase', 'Modules', 'SecurityRuleSet' )

        $ignoreBigOrSlowProps = @( 'CustomAttributes', 'ExportedTypes', 'DefinedTypes' )


        $assemblyItems | %{
            $curItem = $_
            [string] $renderTooltip = $curItem.psobject.properties | %{
                    [PSPropertyInfo] $Cur = $_
                    # $Cur = $_
                    if ( $cur.name -notin @( $PropNames ) ) { return }
                    # if ( $cur.name -notin @( $assemblyItems.Name ) ) { return }
                    if ( $cur.name -in @( $ignoreBigOrSlowProps ) ) { return }
                    $prefix = $cur.Name ?? '<null>'
                    $cur.Value ?? '' | Join-String -sep ', ' -op ($cur.Name ?? '<null>')
                    $cur.value
                        | Join-String -sep ', '
                        | Join-String -op "${prefix}: "
                } | Join-String -sep "`n"

            if( [string]::IsNullOrWhiteSpace($renderTooltip) ) {  $renderTooltip = '<invalid tooltip>' }
            [string] $RenderName = $_.Name ?? '<InvalidName>'
            $renderTooltip = $curItem | Ft -auto | out-string | Join-String -sep "`n"
            [CompletionResult]::new( $RenderName, $RenderName, 'ParameterValue', $renderTooltip )
        }
    }
    Register-ArgumentCompleter -CommandName 'Add-Type' -ParameterName 'AssemblyName' -ScriptBlock $sb_argCompleter_AddType_AssemblyName
}

Module.Register.ArgCompleters

nin.PSModulePath.Clean -Write

# other type extensions
if( $true ) {


    Update-TypeData -TypeName 'System.Management.Automation.PSModuleInfo' -MemberName 'IterCommands' -MemberType ScriptProperty -Value {
        # Sugar to run:  (gmo)[0].ExportedCommands.Values
        [Management.Automation.PSModuleInfo] $cur = $this
        return $cur.ExportedCommands.Values
    } -Force
}


if($false) {
    'H:\data\2023\pwsh\sketches\update-typedata.2023.08\UpdateTypeData-PSParseHtml.AgilityPack.ps1'
        | Get-Item
        | Join-String -f "🚀 => Importing types: '{0}'"
        | Write-verbose -verb
        # | Dotils.Write-DimText | Winfo
    'AgilityPack Types Skipped, from file: "{0}"' -f $PSCommandPath
        | write-host -back 'darkyellow'
    'AgilityPack Types importing...' | write-host -back 'darkyellow'
    . (gi -ea 'continue' 'H:\data\2023\pwsh\sketches\update-typedata.2023.08\UpdateTypeData-PSParseHtml.AgilityPack.ps1' )
}

if($true) {
    @(
        'file:<///H:\data\2023\web.js\web.js%20-%20sketch%202023-09\pwsh\FindFiles.ps1>'
        'file:<///H:\data\2023\web.js\web.js - sketch 2023-09\pwsh\FindFiles.ps1>'
    ) | write-host -back 'darkyellow'

    gi 'H:\data\2023\web.js\web.js - sketch 2023-09\pwsh\FindFiles.ps1'
        | % FullName
        | Join-string -f "`n  <file:///{0}>" -Property { $_ -replace ' ', '%20' }
}


function Module.ImportInlineLiveFormatData {
    param()
    'live-loading ez formatters for some types. edit function: Module.ImportInlineLiveFormatData , in:
    code -g $profile.CurrentUserAllHosts' | write-warning

     Write-FormatView -TypeName ([System.Text.RegularExpressions.Match]) -Property @(
            'Groups', 'Success', 'Name', 'Captures', 'Index', 'Length', 'Value', "ValueSpan", 'Hex' #,  'Ctrl'
            ) -VirtualProperty @{
                'Hex' = { ($_.Value)?.EnumerateRunes().value | j.Hex }
                'Ctrl' = {
                    $_.Value | Fcc
                }
            } -AutoSize | Out-FormatData | Push-FormatData

    Write-FormatView -TypeName ([Text.Rune]) -Property @(
        'Render'
        'Hex'
        'Dec'
        #    'Name', 'PropertyType', 'Attributes', 'PropertyAttributes', 'InitialValue', 'ShortPath', 'ShortExtent'
        'Utf16',
        'Utf8'

        # to remove a bunch, or move to type data
        'Numeric' # 'GetNumericValue'
        'Cat' # 'GetUnicodeCategory'
        # 'Cat' #  'Category'
        'Ctrl'  # 'IsControl'
        # 'IsDigit'
        # 'IsLetter'
            # 'IsLetterOrDigit'
            # 'IsLower'
            # 'IsNumber'
            # 'IsPunctuation'
        # 'IsSeparator'
        # 'Symbol'
        #     # 'IsUpper'
        # 'IsWhiteSpace'
        'Enc8'
        'Enc16'
        'Enc16Be'
        'Upper'
        'Lower'
    )  -AliasProperty @{
        'Cat' = 'GetUnicodeCategory'
        'Dec'    = 'Value'
        'Utf16'  = 'Utf16SequenceLength'
        'Utf8'   = 'Utf8SequenceLength'
        'Text'   = 'Render'
        'Lower'  = 'ToLowerInvariant'
        'Upper'  = 'ToUpperInvariant'
        # 'Ctrl'   = 'IsControl'
        'Symbol' = 'IsSymbol'
    } -AlignProperty @{
        'Enc8' = 'right'
        'Enc16' = 'right'
        'Enc16Be' = 'right'
        'Rune' = 'right'
        'Hex'  = 'right'
    } -VirtualProperty @{
        Enc8 = {
            [Text.Encoding]::GetEncoding('utf-8').GetBytes( $_ )
                | Join-string -f '{0:x2}' -sep ' ' }
        Enc16 = {
                [Text.Encoding]::GetEncoding('utf-16le').GetBytes( $_ )
                | Join-string -f '{0:x2}' -sep ' ' }
        Enc16Be = {
                [Text.Encoding]::GetEncoding('utf-16be').GetBytes( $_ )
                | Join-string -f '{0:x2}' -sep ' ' }
        Cat = { # Category
            [Text.Rune]::GetUnicodeCategory( $_.Value )
        }
        Hex = {
            Join-String -f '{0:x}' -sep ' ' -In $_.Value
        }
        Render             = { $_ | Format-ControlChar }
        Numeric            = { [Text.Rune]::GetNumericValue( $_ ) } # was: 'GetNumericValue'
        GetUnicodeCategory = { [Text.Rune]::GetUnicodeCategory( $_ ) }
        Ctrl               = { [Text.Rune]::IsControl( $_ ) } <# was: 'IsControl' #>
        IsDigit            = { [Text.Rune]::IsDigit( $_ ) }
        IsLetter           = { [Text.Rune]::IsLetter( $_ ) }
        IsLetterOrDigit    = { [Text.Rune]::IsLetterOrDigit( $_ ) }
        IsLower            = { [Text.Rune]::IsLower( $_ ) }
        IsNumber           = { [Text.Rune]::IsNumber( $_ ) }
        IsPunctuation      = { [Text.Rune]::IsPunctuation( $_ ) }
        IsSeparator        = { [Text.Rune]::IsSeparator( $_ ) }
        IsSymbol           = { [Text.Rune]::IsSymbol( $_ ) }
        IsUpper            = { [Text.Rune]::IsUpper( $_ ) }
        IsWhiteSpace       = { [Text.Rune]::IsWhiteSpace( $_ ) }
        'Lower'            = # ToLowerInvariant =
                { [Text.Rune]::ToLowerInvariant( $_ ) }
        'Upper' = # ToUpperInvariant
                { [Text.Rune]::ToUpperInvariant( $_ ) }
        # ToLower            = { [Text.Rune]::ToLower( $_ ) }
        # ToUpper            = { [Text.Rune]::ToUpper( $_ ) }

    # SExtent = { $_.Extent.Text | Dotils.Format-ShortenWhitespace }
    # SParent = { $_.Parent.Name }
    # SPath = {
    #     $Line = $_.Extent.StartLineNumber
    #     $_.Extent.File | Get-Item
    #         | Join-String -p Name -f "{0}:${Line}" }
    }  -AutoSize
    | Out-FormatData | Push-FormatData

}

# Module.ImportInlineLiveFormatData # dont' auto load currently
function Impo.FormatData {
    Module.ImportInlineLiveFormatData
}

@'
try:
Impo.[SciDotfiles | RunSelect | FormatData ]
'@ | write-host -fg '#bda0a0'

function _render-FileName.ForPSRun {
    # might still have to be global, or user-global?
    param()
    process {
        $Obj = $_
        Join-String -Inp @(
            $obj.name
            "`n"
            if($obj.Length -gt 1) {
                '[ {0:n2} kb ]' -f ($obj.length / 1kb)
                    | Join-String -op 'Size: '
            }
            "`n"
            Join-String -in $Obj -Property LastWriteTime -FormatString 'Modified: {0:yyyy| MMMM dd}'
            "`n"
            Join-String -in $Obj -Property CreationTime  -FormatString 'Created:  {0:yyyy| MMMM dd}'
            "`n"

            # Join-String -op 'LastWrite: ' -inp (gi . ).LastWriteTime.ToString('yyyy| MMMM dd')

            # (gi .) | Join-String -Property LastWriteTime -FormatString '{0:yyyy| MMMM dd}'

            "`n"

        ) -sep ""
    }
}

function Invoke.NinPSRun {
    <#
    .synopsis
        quick wrapper of PowerShellRun\Invoke-PSRunSelector that uses custom formatting for tooltips
    .NOTES
        future: use Async to enable longer previews, like BAT by invoking Invoke-PSRunSelectorCustom
    .LINK
        Impo.RunSelect
    .LINK
        PowerShellRun\Invoke-PSRunSelector
    .LINK
        PowerShellRun\Invoke-PSRunSelectorCustom
    .link
        https://github.com/mdgrs-mei/PowerShellRun?tab=readme-ov-file#invoke-psrunselector
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Object[]]$InputObject,

        [ValidateScript({throw 'nyi'})]
        [Parameter()][string] $NameProperty,

        [ValidateScript({throw 'nyi'})]
        [Parameter()][string] $DescriptionProperty,

        [ValidateScript({throw 'nyi'})]
        [Parameter()][string] $PreviewProperty
    )
    begin {
        [List[Object]]$Items = @()
    }
    process {
        $Items.AddRange(@( $InputObject ))
    }
    end {
        $invokePSRunSelectorSplat = @{
            MultiSelection      = $true
            # NameProperty        = 'name'
            # DescriptionProperty = 'desc'
            # PreviewProperty     = 'preview'
            Expression          = {
                @{
                    Name = $_.Name
                    Preview = $_ | _render-FileName.ForPSRun
                }
            }
        }
        $items | Invoke-PSRunSelector @invokePSRunSelectorSplat
    }
}
function Impo.Winget.Completer {
    [CmdletBinding()]
    param()
    if( $global:_________tempWingetDefined ) { return }
    $global:_________tempWingetDefined = $true
    'Init Completer: Winget' | New-Text -fg 'gray40' -bg 'gray15' | Write-Information
     Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
}


Impo.Winget.Completer -Infa Continue

function Impo.RunSelect {
    <#
    .SYNOPSIS
        Load run selector, as an opt-in, because it takes a minute to load
    .link
        https://github.com/mdgrs-mei/PowerShellRun?tab=readme-ov-file#invoke-psrunselector
    .LINk
        file:///H:/data/2024/pwsh/sketch/2024-03-04-PowerShellRun/PowerShellRun-Test1.ps1
    #>
    [Alias('Impo.PSRunSelector')]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompletions(
            'All', 'Executable', 'Application', 'Favorite', 'Function', 'Utility'
        )]
        [string[]]$Category = 'All'
    )
    Import-Module -scope global 'PowerShellRun'


    if($Category -eq 'All') {
        Write-host 'Warning: -All is slow on first load' -fg '#bda0a0'
    }
    Write-host 'Set ctrl+j => Invoke-PSR' -fg '#bda0a0'
    Enable-PSRunEntry -Category $Category

    $SelOpts = [PowerShellRun.SelectorOption]::new()
    $selOpts.QuitWithBackspaceOnEmptyQuery = $true
    Set-PSRunDefaultSelectorOption $SelOpts


    Write-host 'to debug: Set-PSRunPSReadLineKeyHandler isn''t binding over ctrl+j' -fg 'orange'
    # Set-PSRunPSReadLineKeyHandler -Chord 'Ctrl+j'
    # see: https://github.com/mdgrs-mei/PowerShellRun?tab=readme-ov-file#key-bindings
    @(  Set-Alias -ea 'ignore' -PassThru 'IRun' -Value PowerShellRun\Invoke-PSRun
        Set-Alias -ea 'ignore' -PassThru 'IRun.Sel' -Value PowerShellRun\Invoke-PSRunSelector
        Set-Alias -ea 'ignore' -PassThru 'IRun.Custom' -Value PowerShellRun\Invoke-PSRunSelectorCustom
    ) | Join-String -sep ', ' -Property DisplayName
}
function Impo.SciDotifiles {
    <#
    .SYNOPSIS
        load SeeminglyScience Profile, on-demand
    #>
    [CmdletBinding()]
    [Alias('Impo.Sci')]
    param()
    Join-String -f 'Importing File: "{0}"' 'G:/2024-git/pwsh/SeeminglyScience👨/dotfiles/Documents/PowerShell/profile.ps1'
        | Write-Verbose

    . (Get-Item -ea 'continue' 'G:/2024-git/pwsh/SeeminglyScience👨/dotfiles/Documents/PowerShell/profile.ps1')
}

function demo.AsyncSelectString {
    [Alias('IRun.Grep')]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Regex,

        [ArgumentCompletions("'*.cs'", "'*.ps1'")]
        [string]$Kind = '*.*'
    )

    if( 'PowerShellRun.SelectorOption' -as 'type' -eq $null ) {
        'AutoImporting module when first invoked...' | write-host -fg 'orange'
        Impo.RunSelect -Category All
    }
    # $word = 'function'

    $option = [PowerShellRun.SelectorOption]::new()
    $option.Prompt = "Searching for word '{0}'> " -f $regex

    $matches = Get-ChildItem -filter $Kind -Path $Path -Recurse | Select-String $regex
    $result = $matches | ForEach-Object {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.UserData = $_
        $entry.Name = $_.Filename
        $entry.Description = $_.Path
        $entry.PreviewAsyncScript = {
            param($match)
            & bat --color=always --highlight-line $match.LineNumber $match.Path
        }
        $entry.PreviewAsyncScriptArgumentList = $_
        $entry.PreviewInitialVerticalScroll = $_.LineNumber
        $entry
    } | Invoke-PSRunSelectorCustom -Option $option

    if ($result.KeyCombination -eq 'Enter') {
        code $result.FocusedEntry.UserData.Path
    }
}

# Add path for 7zip's cli '7z'
$env:Path = $env:Path, ';H:\Apps.WinGet\7zip' -join ''

'2025-01:: this is Old dotfiles, merge with surface' | Write-Host -fg 'gray60' -bg 'gray20'
'2025-07-14::this is Old dotfiles.psm1, merge with surface. 🦍' | Write-Warning
