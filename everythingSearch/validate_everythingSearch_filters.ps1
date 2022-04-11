class BestPracticeRule {
    [int]$Id
    [string]$Name
    [string]$Description
    [ScriptBlock]$Script
}

class RuleParseResult {
    [bool]$Success
    [string]$Message
    [hashtable]$Detail
}

[BestPracticeRule[]]$BestPracticeRules = @(
    [BestPracticeRule]@{
        'Id'          = 1
        'Name'        = 'Missing outer enclosing parenthesis'
        'Description' = 'A Better practice is to enclose expressions in outer parenthesis -- this makes composing multiple filters more reliable, otherwise And and Or expressions will unexpectedly evaluate incorrectly'
        'Script'      = {
            param($CurConfig, $AllConfig)
            $startsWithParen = $CurConfig.Search -match '^\s*\('
            $endsWithParen = $CurConfig.Search -match '\)\s*$'

            return [RuleParseResult]@{
                Success = $startsWithParen -and $endsWithParen
                Detail  = @{
                    StartsWithParen = $startsWithParen
                    EndsWithParen   = $endsWithParen
                }
            }
        }
    }
    [BestPracticeRule]@{
        'Id'          = 2
        'Name'        = 'ColonInMacroNames'
        'Description' = 'Colon after macro names are implicitly added'
        'Script'      = {
            param($CurConfig, $AllConfig)
            return [RuleParseResult]@{
                Success = $true
                Detail  = @{
                    NYI = 'NotYetImplemented'
                }
            }

        }
    }
    [BestPracticeRule]@{
        'Id'          = 3
        'Name'        = 'DuplicateMacroName'
        'Description' = 'Redefining the same macro has unexpected behavior'
        'Script'      = {
            param($CurConfig, $AllConfig)
            return [RuleParseResult]@{
                Success = $true
                Detail  = @{
                    NYI = 'NotYetImplemented'
                }
            }
        }
    }
)

class BestPracticeRuleViolation {
    [BestPracticeRule]$RuleDefinition
    [object]$ConfigViolated
}

$AppConf = @{ Root = Get-Item $PSScriptRoot }
$AppConf += @{
    Import_CsvPath = Get-Item -ea stop (Join-Path $AppConf.Root 'everything - nin10 ┐ filters.csv')
}

$Config = Get-Content (Get-Item $AppConf.Import_CsvPath ) | ConvertFrom-Csv

function es_FindDuplicateMacro {
    param($Config)
    $groups = $config | Where-Object { -not [string]::IsNullOrEmpty($_.Macro) } | Group-Object Macro | Where-Object Count -GT 1
    $groups | ForEach-Object {
        $_.group | Select-Object macro, Name, Search

    }
}

es_FindDuplicateMacro $Config

$violations = [list[BestPracticeRuleViolation]]::new()

function _testSingleConfigEntry {
    [cmdletbinding()]
    param(
        # input
        [object]$TargetConfig,

        # which rules are enabled
        [BestPracticeRule[]]$BestPracticeRules
    )

    $resultSummary = @{
        TargetConfig    = $TargetConfig
        RuleViolations  = [RuleParseResult[]]::new()
        RuleParseResult = [RuleParseResult[]]::new()
    }

    Write-Debug "Testing: '$TargetConfig'"
    foreach ($rule in $BestPracticeRules) {
        'Rule: {0}' -f @(
            $rule.Name
        )
        | Write-Debug

        [RuleParseResult]$result = & $rule.Script -CurConfig $TargetConfig -AllConfig $Config
        Write-Debug "Success? $($result.Success)"
        $resultSummary['RuleParseResult'].add( $result )
        if (! $result.Success ) {
            $resultSummary['RuleViolations'].add( $result )
        }
    }


}


_testSingleConfigEntry -TargetConfig $config[4] -debug -BestPracticeRules $BestPracticeRules
