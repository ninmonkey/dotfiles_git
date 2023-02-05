# full restart of main pwsh profile: 2022-11-30
# main entry for regular pwsh
@(
    Set-Alias 'label' -Value 'get-date' -Force -ea ignore -Description 'to prevent ever referencing exe' -PassThru
    Set-Alias 's' -Value 'select-object' -Force -ea ignore -Description 'Sort-Object shorthand' -PassThru
)
| Join-String -sep ', ' -SingleQuote -op 'set alias ' DisplayName
| Join-String -op "SetBy: '<${PSSCommandPath}>'`n" { $_ }


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

Import-Module ninmonkey.console -force

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


"exit  <== Profile: docs/Microsoft.PowerShell_profile.ps1/ => Pid: '${pid}'" | Write-Warning
$global:temp_old_prompt = $Function:prompt
$function:prompt = ( Get-Item 'function:prompt.spartanBeforeJaykulConfig' )