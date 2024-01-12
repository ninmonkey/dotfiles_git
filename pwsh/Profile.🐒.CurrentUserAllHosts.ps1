using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Globalization
using namespace System.Text

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
) | Join-String -sep ', ' -Prop ModuleName | Write-Host -fore 'darkgray'

Set-Alias 'Label' -value 'Ninmonkey.Console\Write-ConsoleLabel' -Force
Set-Alias 's' -value 'Select-Object'
Set-Alias 'nin.Wrap' -value 'Ninmonkey.Console\Format-WrapJaykul'

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

nin.PSModulePath.Clean -Write

Import-Module Bintils -PassThru

function F.Dock {
    <#
    .SYNOPSIS
        sugar for first name of newest docker. ( bDoc.FirstName -FirstNameOnly )
    #>
    param()
    Bintils.Docker.Containers.Ls -FirstNameOnly
}

'H:\data\2023\pwsh\sketches\update-typedata.2023.08\UpdateTypeData-PSParseHtml.AgilityPack.ps1'
    | Get-Item
    | Join-String -f "🚀 => Importing types: '{0}'"
    | Write-verbose -verb
    # | Dotils.Write-DimText | Winfo


if($false) {
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

Module.ImportInlineLiveFormatData

@'
try:
. 'G:\2024-git\pwsh\SeeminglyScience👨\dotfiles\Documents\PowerShell\profile.ps1'
or
SciImpo
'@

function SciImpo {
    . 'G:\2024-git\pwsh\SeeminglyScience👨\dotfiles\Documents\PowerShell\profile.ps1'
}
