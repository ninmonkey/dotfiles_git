$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.AutoLoad_ToRefactor = $PSCommandPath | Get-Item

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Debug; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.04 #>

# Import-module ninmonkey.console -DisableNameChecking *>$null



function completer.ValidCompletions.For.SelectSql.TableName {
    [Alias('completer.ValidCompletions.For.SelectSql.TableName.Pipeworks')]
    param()
    Import-Module Pipeworks
    Pipeworks\Get-SecureSetting | ForEach-Object Name | Sort-Object -Unique
}


$SB_completer_PipeWorks_SelectSqlTableName = {

    <#
     .SYNOPSIS
     Completer Suggests key names for Get-SecureSetting

     .DESCRIPTION
     Long description

     .EXAMPLE
     Ps>

}
 #>
    param(
        $commandName, # 'Get-SecureSetting'
        $parameterName, # 'Name'
        $wordToComplete, # ''
        $commandAst, # { .. }
        $fakeBoundParameters # @{}
    )

    completer.ValidCompletions.For.Pipeworks.SecureSetting | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Register-ArgumentCompleter -CommandName Get-SQLTable -ParameterName ConnectionStringOrSetting -ScriptBlock $NewSB
# Register-ArgumentCompleter -CommandName Pipeworks\Get-SecureSetting -ParameterName Name -ScriptBlock $NewSB -Verbose
$cFg = $PSStyle.Foreground.FromRgb('#c7af51')
$cFg = $PSStyle.Foreground.FromRgb('#c99067')

$cBg = $PSStyle.Background.FromRgb('#c7af51')
$cBg = $PSStyle.Background.FromRgb('#c99067')

# $cFg = $Cfg, $cbg -join ''

$registerArgumentCompleterSplat = @{
    CommandName   = 'Select-Sql'
    ParameterName = 'TableName'
    ScriptBlock   = $SB_completer_PipeWorks_SelectSqlTableName
}
'registerCompleter: {0} -{1}' -f @(
    $registerArgumentCompleterSplat.CommandName
    $registerArgumentCompleterSplat.ParameterName
)
| Join-String -op $cFg -os $PSStyle.Reset
| Write-Information -infa 'continue'

Register-ArgumentCompleter @registerArgumentCompleterSplat




function completer.ValidCompletions.For.SecureSetting {
    [Alias('Completer.ValidCompletions.For.Pipeworks.SecureSetting')]
    param()
    Import-Module Pipeworks
    Pipeworks\Get-SecureSetting | ForEach-Object Name | Sort-Object -Unique
}

$SB_completer_PipeWorks_SecureSetting = {

    <#
     .SYNOPSIS
     Completer Suggests key names for Get-SecureSetting

     .DESCRIPTION
     Long description

     .EXAMPLE
     Ps>

}
 #>
    param(
        $commandName, # 'Get-SecureSetting'
        $parameterName, # 'Name'
        $wordToComplete, # ''
        $commandAst, # { .. }
        $fakeBoundParameters # @{}
    )

    completer.ValidCompletions.For.Pipeworks.SecureSetting | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Register-ArgumentCompleter -CommandName Get-SQLTable -ParameterName ConnectionStringOrSetting -ScriptBlock $NewSB
# Register-ArgumentCompleter -CommandName Pipeworks\Get-SecureSetting -ParameterName Name -ScriptBlock $NewSB -Verbose
$registerArgumentCompleterSplat = @{
    CommandName = 'Get-SecureSetting'
    ParameterName = 'Name'
    ScriptBlock = $SB_completer_PipeWorks_SecureSetting
}

'registerCompleter: {0} -{1}' -f @(
    $registerArgumentCompleterSplat.CommandName
    $registerArgumentCompleterSplat.ParameterName
)
| Join-String -op $cFg -os $PSStyle.Reset
| Write-Information -infa 'continue'

Register-ArgumentCompleter @registerArgumentCompleterSplat








if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Debug; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.04 #>


