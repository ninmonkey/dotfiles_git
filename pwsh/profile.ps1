$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.MainEntry_nin = $PSCommandPath | Get-Item

$Env:PSModulePath = @(
    'H:/data/2023/pwsh/PsModules'
    # 'H:\data\2023\pwsh\PsModules\Ninmonkey.Console\zeroDepend_autoloader\logging.Write-NinLogRecord.ps1'
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

    $target = $FullLogPath | Gi -ea stop

    $FullCleanLogPath = Join-Path $Target.Directory ($target.BaseName + '.cleaned.log')
    # $FullCleanLogPath = $FullLogPath | gi | % BaseName

    # todo: make it pipe as a stream, not requiring end.
    # cleanup
    gc $FullLogPath | ?{
        $shouldKeep = $true
        $FoundIgnoreCopySource = $_ -match ('^' + [Regex]::Escape('Copying source file (/tmp/samcli/source/'))
        $FoundIgnoreCopyMeta = $_ -match ('^' + [Regex]::Escape('Copying directory metadata from source (/tmp/samcli/source/'))
        $FoundOthers = $_ -match '^(Copying source file|Copying directory metadata from source)'

        if($FoundIgnoreCopyMeta -or $FoundIgnoreCopySource) { $ShouldKeep = $false}
        if($FoundOthers) { $shouldKeep = $false}
        return $shouldKeep
     } | Add-Content -path $FullCleanLogPath

     (Get-Item $FullCleanLogPath) | Join-String -f "`n  => wrote <file:///{0}>"
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



# shared (all 3)
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>

# toggle /w env var
if ($global:__nin_enableTraceVerbosity) { $PSDefaultParameterValues['*:verbose'] = $True }
$PSDefaultParameterValues.Remove('*:verbose')

# root entry point
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/src/__init__.ps1' ))







if ($global:__nin_enableTraceVerbosity) { 'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath ) }
if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
return




if ($global:__nin_enableTraceVerbosity) { "enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning }
. (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1')
if ($global:__nin_enableTraceVerbosity) { "exit  <== Profile: docs/profile.ps1/ => Pid: '${pid}'" | Write-Warning }

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>