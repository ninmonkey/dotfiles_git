"run --->>>> '$PSCommandPath'" | Write-Color 'gray80' -bg 'gray30'
| Write-Warning

# TestCase [1] this single-quote multi line string colors wrong
# even though the scope is 'singlequote'
Write-Debug 'checklist:
    - [ ] and from pipeline
    - [ ] --verbose'

if ($experimentToExport) {
    $experimentToExport.function += @(
        'Invoke-VSCodeVenv'
    )
    $experimentToExport.alias += @(
        # 'Code', 'CodeI'
        'Code-vEnv', 'CodeI-vEnv',
        'Out-CodevEnv', 'Out-CodeIvEnv',
        'Ivy'
    )
}

if ($ResumeSession) {
    Write-Color -t 'ResumeSession' $Color.FgBold | Write-Information
} else {
    ## Test case [2] : members
    Write-Color -t 'LoadItem: ' $Color.H1 | Write-Information
    Write-Color -t $Target $Color.FgBold2 | Write-Information
}
# hr
$metaInfo = @{
    ## Test case [3] : members
    # some don't colorize ParameterSetName
    ParameterSet = $PSCmdlet.ParameterSetName
    BoundParams = $PSBoundParameters


    $script:__venv = @{
        # ForceMode = 'insiders' # $null | 'code' | 'insiders'
        ForceMode = 'code' # default code, because of alias ivy   <$null | 'code' | 'insiders'>
        Color = @{
            Fg = '#66CCFF'
            FgBold = 'green'
            FgBold2 = 'yellow'
            FgDim = 'gray60'
            FgDim2 = 'gray40'
            H1 = 'orange'
        }
    }

    $varName = "${hi} world $($PSCommandPath | Format-List *)"
    @{
        KeyName    = 'const'
        'KeyName2' = 1.34 * 3
        'Key3'     = $x
    }
}
    function __findVSCodeBinaryPath {
        <#
    .synopsis
        internal. Find versions of vscode
    .outputs
        [IO.FileInfo]
    #>
        $fdArgs = @(
            # '-d', 5
            '--max-depth', '5'
            # '-e', 'cmd',
            '--extension', 'cmd'
            'code' # regex
            'j:\'  # root path
            '--color=never'
        )

        $binFd = Get-NativeCommand fd
        [object[]]$results = & $BinFd @fdArgs

        $results | Get-Item | Sort-Object LastWriteTime -desc
    }

    function Invoke-VSCodeVenv {
        <#
    .synopsis
        quick hack to work around one drive bug
    .description
        .
    .notes
        . - next:
            - [ ] argument transformation attribute:
                supports [Path] or [VsCodeFilePath]
            - [ ] disable shouldprocess when files <= 3
            - [ ] disable shouldprocess when using folder + add?
                or what is the case that causes a window to get replaced with a new workspace?

        todo
        - [ ] validate folders always default to new, and files default to re-use
        - [ ] optionally collect full profile, would that make re-using require less confirmations?

        POC
            - [ ] code-venv -ResumeSession
            - [ ] '-reuse -g <filename>'
            - [ ] '-r -a <path>'
            - [ ] '-n -a <path>'
    .link
        New-VSCodeFilepath
    .link
        VsCodeFilePath
    .link
        Convert-VsCodeFilepathFromErrorRecord
    .link
        ConvertFrom-ScriptExtent
    .example
        🐒> gi .\normalize.css | Code-vEnv
    .example
        🐒> $profile | code-venv
    .example
        🐒> $profile | code-venv -WhatIf


            vscode_venv: "J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe"
            vscode_args: '-r' '-g' 'C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1'
            J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe

    # [Alias('Code-vEnv', 'Out-CodeVEnv', 'Out-VSCodeEnv')]
    #>
        [outputtype([string])]
        [Alias(
            # 'Code', 'CodeI',
            'Code-vEnv', 'CodeI-vEnv',
            'Out-CodevEnv', 'Out-CodeIvEnv',
            'Ivy' # pronounced from the 'i venv'
        )]
        [cmdletbinding(
            PositionalBinding = $false,
            DefaultParameterSetName = 'OpenItem',
            # DefaultParameterSetName = 'ResumeSession',
            SupportsShouldProcess, ConfirmImpact = 'High'
        )]
        param()
        'fooasdf'
        'sadf
        dsfssdsf
    dsf'
        # which venv
        # [Alias('VEnv')]

        # this single-quote multi line string colors wrong
        # even though the scope is 'singlequote'
        Write-Debug 'checklist:
    - [ ] and from pipeline
    - [ ] --verbose'

        $metaInfo | Format-Table | Out-String | Write-Debug
        $metaInfo | Format-Dict | Out-String | Write-Debug

    }
