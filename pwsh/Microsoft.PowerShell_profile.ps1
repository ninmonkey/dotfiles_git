# non-debug
"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: CurrentUserCurrentHost" | write-warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath);  <# 2023.02 #>

$PSDefaultParameterValues['*:verbose'] = $True

# full restart of main pwsh profile: 2023-02-01

@(
    Set-Alias 'label' -Value 'get-date' -Force -ea ignore -Description 'to prevent ever referencing exe' -PassThru
    Set-Alias 's' -Value 'select-object' -Force -ea ignore -Description 'Sort-Object shorthand' -PassThru
)
| Join-String -sep ', ' -SingleQuote -op 'set alias ' DisplayName
| Join-String -op "SetBy: '<${PSSCommandPath}>'`n" { $_ }


# disable for now, because shell integration breaks it
# & {
# $hasFunc = (Get-PSReadLineKeyHandler -Bound -Unbound | ForEach-Object Function ) -contains 'ShowCommandHelp'
# if ($hasFunc) {
# Set-PSReadLineKeyHandler -Key 'f11' -Function
Set-PSReadLineKeyHandler -Key 'f12' -Function ShowCommandHelp
# }
# }

@'
prev profile:

    ## cur $PROFILE (in code):
    $PROFILE.CurrentUserCurrentHost (in code)
        C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1

    ## cur $PROFILE (in wt):
    $Profile.CurrentUserAllHosts
    C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\profile.ps1

    $Profile.CurrentUserCurrentHost
    C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

    $profile.'Ninmonkey.Profile/*'
    <C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Ninmonkey.Profile>

    <C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1>

    $PROFILE.CurrentUserCurrentHost
    C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1

    $Profile.Nin_Dotfiles
    C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git

    Ninmonkey.Profile
        C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Ninmonkey.Profile\Ninmonkey.Profile.psm1
'@

Write-Warning 'next: new PSModulePath'
'disabled,see {0}`n=> {1}' -f @(
    'H:/data/2021/pwsh_myDocs'
    | Join-String -DoubleQuote
    $PSCommandPath
    | Join-String -DoubleQuote
) | Write-Host -ForegroundColor blue
Write-Warning 'not finished, wt profile still loads profile, see: <C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1>'

"enter ==> Profile: docs/Microsoft.PowerShell_profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning
# $PSDefaultParameterValues['Import-Module:Verbose'] = $true
$PSDefaultParameterValues['Update-Module:Verbose'] = $true
$PSDefaultParameterValues['Install-Module:Verbose'] = $true

# this is very important, the other syntax for UTF8 defaults to UTF8+BOM which
# breaks piping, like piping returning from FZF contains a BOM
# which actually causes a full exception when it's piped to Get-Item
[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()
Import-Module pansies
[PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'
$PSStyle.OutputRendering = 'ansi'

[Console]::OutputEncoding | Join-String -op 'Console::OutputEncoding '

<#
section: always bound (wt, + code, + code-debugf )#>
#>


<#

    section:prompts

#>
function __safe_globalPrompt {
    @(
        @(
            "`n`n"

            #(get-location) -replace (ReLit Join-Path $Env:UserProfile 'SkyDrive/Documents'), '//doc' -split '\\' | select -last 4 | Join-String -sep '/'
            $accum = (Get-Location) -split '\\' | Select-Object -Last 4 | Join-String -sep '/'
            #$accum -replace '(SkyDrive/Documents)', "${fg:gray40}`$1${fg:clear}"
            # preserve name: $accum -replace '(SkyDrive/Documents)', "${fg:gray40}`$1${fg:gray60}"
            $accum -replace '(SkyDrive/Documents)', "${fg:gray40}docs:${fg:gray60}"
            | New-Text -fg gray40
            if ($global:Error.count -gt 0) {
                "`n"
                "${fg:red}Errors${fg:Clear}: $($global:Error.count)"
            }

            "`n🐒 >"
        ) -join ''
    )
}

Import-Module ninmonkey.console -Force

function prompt.spartanBeforeJaykulConfig {
    @(
        # Join-String -op "SetBy: '<${PSSCommandPath}>'`n" { $_ }
        "`n"
        if ($Global:Error.Count -gt 0 ) {
            # auto-hiding errors: future show error's delta
            $global:error.count | Join-String -os ' '
            | Ninmonkey.Console\Write-ConsoleColorZd -Color 'c98f76'
        }
        (Get-ChildItem . -Force ).count | Join-String -os ' '
        (Get-Location) -split '\\' | Select-Object -Last 3 | Join-String -sep '/'
        | Ninmonkey.Console\Write-ConsoleColorZd -Color '88c0d0'
        "`n"
        (Get-Location) -split '\\' | Select-Object -Last 5 | Join-String -sep '/'
        | Ninmonkey.Console\Write-ConsoleColorZd -Color '618994'
        $MaybePrefixes = @(
            # "Pwsh7>▸·⇢⁞ ┐⇽▂  "
            'Pwsh7>▸·⇢⁞ ┐⇽▂  '
            'Ps7⁞'
            'Ps7┐⇽'
            'Ps7⇽ psd'
            'Ps7⁞'
            'Ps7⇽ ls'
            'Ps7┐ '
        )

        # "Pwsh7> "

        # "`n"
        # (Get-Location).path | Get-Item | ForEach-Object BaseName
        "`n"
        'Ps7┐ ' | Write-ConsoleColorZd -Color a3be8c


        # (get-location) -split '\\' | select -Last 3 | Join-string -sep '/' | Write-ConsoleColorZd -Color '88c0d0'
    ) | Join-String -sep ''
}

function prof.prompt.forScreenshot {
    # function prompt {
    @( # save: potential prompt for posting code'

        $PSVersionTable.PSVersion.ToString()
        | Join-String -op (' ' * 15 -join '' ) {

            @(
                $PSStyle.Foreground.FromRgb(68, 68, 68)
                'sdf'
            ) -join '' }

            (Get-Location).tostring() -split '\\'
        | Select-Object -Last 4
        | Join-String -sep ' -> '

        "`n"
        '{0}' -f @(
            ''
        ) #-join ''
    ) | Join-String -sep ''
    # }
}
'📚 <<todo: move to dotfiles >> ==> 🤖 ==>  C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1/1876d08c-7ac3-4caa-a084-efdb208f1884' | Write-Warning

"exit  <== Profile: docs/Microsoft.PowerShell_profile.ps1/ => Pid: '${pid}'" | Write-Warning
$global:temp_old_prompt = $Function:prompt
$function:prompt = ( Get-Item 'function:prompt.spartanBeforeJaykulConfig' )


function prof.switchPromptStyle {
    param(
        [ArgumentCompletions('BeforeJaykul', 'ForScreens')]
        [string]$Name,

        [switch]$PopRevertOld
    )
    if ($PopRevertOld) {
        return
    }

    $global:temp_old_tier2_prompt = $global:Function:prompt

    switch ($Name) {
        'BeforeJaykul' {
            # duplicate, to be replace later anyway, so don't worry about it
            $nextStyle = 'prompt.spartanBeforeJaykulConfig'
            $func? = ( Get-Item "function:$NextStyle" )

            if ( $Func? ) {
                $global:function:prompt = $Func?
            }
            else {
                'Something failed using: "{0}" . {1}' -f @(
                    $NextStyle
                    $func?
                )
                | Write-Error # -ea 'stop'
                break
            }
        }
        'ForScreens' {
            $nextStyle = 'prof.prompt.forScreenshot'
            $global:function:prompt = ( Get-Item "function:$NextStyle" )

            if ( $Func? ) {
                $global:function:prompt = $Func?
            }
            else {
                'Something failed using: "{0}" . {1}' -f @(
                    $NextStyle
                    $func?
                )
                | Write-Error # -ea 'stop'
                break
            }
        }
        default {
            throw "Unhandled type: '$Name'"
        }
    }
}

'📚🐱‍🐉 enter ==> other ==>  C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1/b1e69efa-48c1-43aa-87ef-1eb0d9f05600' | Write-Warning
'profile is importing: <file:///H:\data\2022\Pwsh\buffer\misc-others\maybe new BatPreview wrapper - 2023-01 - iter4.ps1>'
| Write-Warning
if ($true) {
    Write-Warning '🐱‍🐉Config: BatIter4: disable loading'
}
else {

    . (Get-Item -ea 'continue' ('H:\data\2022\Pwsh\buffer\misc-others\maybe new BatPreview wrapper - 2023-01 - iter4.ps1'))
}

$PSDefaultParameterValues.remove('*:verbose')

"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: CurrentUserCurrentHost" | write-warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath);  <# 2023.02 #>