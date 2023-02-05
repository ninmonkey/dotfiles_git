@{
    Severity     = @(
        'Error'
        'Warning'
    )
    ExcludeRules = @(
        # 'PSDSC*'
        # 'PSUseDeclaredVarsMoreThanAssignments'
        # 'PSUseShouldProcessForStateChangingFunctions'
    )

    <#
        try: https://github.com/indented-automation/Indented.ScriptAnalyzerRules/blob/c8a90433e6f9036c6cf8082d2b74676adc660b55/Indented.ScriptAnalyzerRules/public/rules/AvoidOutOfScopeVariables.ps1
    #>
    Rules        = @{
        PSAvoidTrailingWhitespace  = @{
            Enable = $false # else VSCode Linter spam
        }
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize     = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $false
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing         = @{
            Enable = $true
        }
    }
}
