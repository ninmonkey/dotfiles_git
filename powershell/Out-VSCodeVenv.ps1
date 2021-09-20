write-warning "run --->>>> '$PSCommandPath'"
# $OneDrive_VSCode
# & $OneDrive_VSCode @('-r', '-g', 'telemetryCache.otc')
# & $OneDrive_VSCode @('-r', '-g', 'telemetryCache.otc')
function Out-VsCodeVenv {
    <#
    .synopsis
        quick hack to work around one drive bug 
    .example
        🐒> $profile | code-venv
    .example
        🐒> $profile | code-venv -WhatIf

            vscode_venv: "J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe"
            vscode_args: '-r' '-g' 'C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1'
            J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe
    #>
    [Alias('code-venv')]
    [cmdletbinding(PositionalBinding = $false, DefaultParameterSetName = 'OpenFile')]
    param(
        # which venv
        [Alias('VEnv')]
        [Parameter()]
        [ValidateSet('J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe')]
        [string]$VirtualEnv = 'J:\vscode_port\VSCode-win32-x64-1.57.1\Code.exe',

        # File
        [Alias('Path', 'PSPath')]
        [Parameter(
            ParameterSetName = 'OpenFile',
            Mandatory,
            Position = 0, ValueFromPipelineByPropertyName = 'PSPath', ValueFromPipeline
        )]
        [string]$TargetPath,

        # WhatIf
        [Parameter()][switch]$WhatIf,

        # args to vs code instead
        [Parameter(Mandatory, ParameterSetName = 'ExplicitArgs')]
        [string[]]$ArgsRest
        # # Args to code
        # [Parameter(AttributeValues)]
        # [ParameterType]
        # $ParameterName]
    )
    begin {
        $Regex = @{
            FilepathWithPosition = '(:\d+){1,}$'
        }
        $bin_vscode = gi -ea stop $VirtualEnv
    }

    end {
        [object[]]$code_args = @()

        function _handleOpenFile {
            # because: if '-r' is used on a directory, you lose the current session
            if ($targetPath) {
                # quick hack, just always drop the goto 
                if ($TargetPath -match $Regex.FilepathWithPosition) {
                    @(
                        'NYI: dropping positions on file uris'
                        $targetPath | Join-String -DoubleQuote -op '  '
                        $targetPath -replace $Regex.FilepathWithPosition, '' | Join-String -DoubleQuote -op '  '
                    ) | Join-String -sep "`n" | Write-warning
                    $targetPath = $targetPath -replace $Regex.FilepathWithPosition, ''
                }
                $Fullpath = gi -ea stop $targetPath                
                $isAFolder = Test-IsDirectory $Fullpath

                if ($isAFolder) {
                    $code_args += @(
                        '-n'
                        '-g'
                    )
                }
                else {
                    $code_args += @(
                        '-r'
                        '-g'
                        $Fullpath
                    )
                }
            }
            
            if ($WhatIf) {
                
                Write-Information "IsDir? $IsAFolder"
                $VirtualEnv | Join-string -op 'vscode_venv: ' -DoubleQuote | Write-TExtColor 'hotpink3'
                $code_args  | join-string -op  'vscode_args: ' -sep ' ' -SingleQuote  | Write-TExtColor 'hotpink3'
                $VirtualEnv
                return
            }
            Write-Information "IsDir? $IsAFolder" | Write-Information
            $VirtualEnv | Join-string -op 'vscode_venv: ' -DoubleQuote  | Write-TExtColor 'hotpink3' |  write-information
            $code_args | join-string -op  'vscode_args: ' -sep ' ' -SingleQuote  | Write-TExtColor 'hotpink3' |  write-information
            
            & $bin_vscode @code_args
        }

        function _handleExplicitArgs {            
            write-error -ea stop -Category NotImplemented -Message 'Args nyi'
        }
        
        switch ($PSCmdlet.ParameterSetName) {
            'ExplicitArgs' {
                _handleExplicitArgs
            }
            default {
                _handleOpenFile

            }
        }

    }
}
