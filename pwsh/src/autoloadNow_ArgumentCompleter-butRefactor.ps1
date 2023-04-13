$global:__ninBag ??= @{}
$global:__ninBag.Profile ??= @{}
$global:__ninBag.Profile.AutoLoad_ToRefactor = $PSCommandPath | Get-Item

if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Debug; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.04 #>

# Import-module ninmonkey.console -DisableNameChecking *>$null
<#
see also:
    lazy completer: <https://github.com/Cologler/PSLazyCompletion/blob/master/PSLazyCompletion.psm1>

#>

Import-Module Pipeworks -PassThru # can register fail if the module is not yet imported? (ie: break the alias)

New-Lie -Name 'sma.CompletionRes' -TypeInfo ([System.Management.Automation.CompletionResult])
New-Lie -Name 'sma.CompletionResType' -TypeInfo ([System.Management.Automation.CompletionResultType])

$script:____zTestConn ??= Get-SQLTable -ConnectionStringOrSetting 'AzureSqlConnectionString'

. (gi -ea 'continue' (Join-path $PSScriptRoot 'indentedautomation.find-customArgCompleters.ps1'))

function .fmt.Convert.PipeworksTable.ToWord {
    <#
    .example

        [int] id
        [nvarchar] name
        [varchar] start_ip_addres
        [varchar] end_ip_address
        [datetime] create_date
        [datetime] modify_date
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $TableInput
    )
    # begin {
    #     [Collections.Generic.List[Object]]$Items = @()
    # }
    # process {
    #     $Items.AddRange( $TableInput )
    # }
    end {
        foreach ($i in 0..($TableInput.Columns.Count - 1)) {
            '[{0}] {1}' -f @(
                $TableInput.DataTypes[ $i ]
                $first.Columns[ $i ]
            )
        }
    }
}

function completer.ValidCompletions.For.SelectSql.TableName {
    <#
    .SYNOPSIS
    enumerate valid table names for Select-Sql

    .DESCRIPTION
    valid table names
    .notes
        naming, verbose but completes fast, Like

        input:
            *.for.*sql<tab>
        completionResult
            completer.ValidCompletions.For.SelectSql.TableName

    .EXAMPLE
        PS> Get-SQLTable -ConnectionStringOrSetting (Get-SecureSetting -Name <tab> -Decrypted -ValueOnly)
    .EXAMPLE
    Ps> completer.ValidCompletions.For.SelectSql.TableName
    name1
    name2
    ...
    name9

    .NOTES
    General notes
    #>
    [Alias('completer.ValidCompletions.For.SelectSql.TableName.Pipeworks')]
    param(
        [switch]$AsText
    )
    Import-Module Pipeworks -PassThru | Out-Null
    # Pipeworks\Get-SecureSetting | ForEach-Object Name | Sort-Object -Unique

    # basic
    if ($AsText) {
        return (Pipeworks\Get-SQLTable).TableName | Sort-Object -Unique
    }
    <#
       To customize your own custom options, pass a hashtable to CompleteInput, e.g.
         return [System.Management.Automation.CommandCompletion]::CompleteInput($inputScript, $cursorColumn,
             @{ RelativeFilePaths=$false }
    #>



    Pipeworks\Get-SQLTable | ForEach-Object {
        $curTable = $_
        $completionText = $completionText | Join-String -op 'comple: '
        # $listItemText = 'lit' | Join-String -op 'Lit: '
        # $toolTip = $completionText | Join-String -op 'tip: '


        $listItemText = '[{0}].[{1}]' -f @(
            $_.TableSchema
            $_.TableName
        )

        $Tooltip = @(
            '[{0}].[{1}]' -f @(
                $_.TableSchema
                $_.TableName
            )
        )

        $render = ($_.Columns -join ', ')
        $truncMax = [Math]::Min( $render.Length, 80 )
        $renderTrunc = $render.substring(0, $truncMax )
        # $renderTrunc
        @{ truncMax = $TruncMax; RenderTrunc = $renderTrunc ; Render = $Render }
        | Write-Debug
        # | out-null


        $shortName = $curTable.TableName

        return [System.Management.Automation.CompletionResult]::new(
                <# completionText: #> $ShortName,  #$completionText,
                <# listItemText: #> $ShortName,
                <# resultType: #> ([System.Management.Automation.CompletionResultType]::ParameterValue),
                <# toolTip: #> $ShortName )

        # if ($false) {
        #     $Tooltip += '> ', $renderTrunc -join ''
        #     return [System.Management.Automation.CompletionResult]::new(
        #         <# completionText: #> $curTable.TableName ?? $_,
        #         <# listItemText: #> $curTable.TableName ?? $_,
        #         <# resultType: #> ([System.Management.Automation.CompletionResultType]::ParameterValue),
        #         <# toolTip: #> $curTable.TableName )

        # }
        # if ($true) {
        #     return [System.Management.Automation.CompletionResult]::new(
        #         <# completionText: #> 'a',  #$completionText,
        #         <# listItemText: #> 'b',
        #         <# resultType: #> ([System.Management.Automation.CompletionResultType]::ParameterValue),
        #         <# toolTip: #> 'c' )
        # }
    }

}

function .fmt.convert.LikeToRegex {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$LikeExpression
    )

    $accum = $LikeExpression -replace '\*', '.*'
    return $accum
}


$SB_completer_PipeWorks_SelectSqlTableName = {

    <#
     .SYNOPSIS
     attach completer Completer Suggests key names for Get-SecureSetting

     .DESCRIPTION
     Long description

    .EXAMPLE
    PS> Get-SQLTable -ConnectionStringOrSetting (Get-SecureSetting -Name <tab> -Decrypted -ValueOnly)
    .link
        completer.ValidCompletions.For.SelectSql.TableName

}
 #>
    param(
        $commandName, # 'Get-SecureSetting'
        $parameterName, # 'Name'
        $wordToComplete, # ''
        $commandAst, # { .. }
        $fakeBoundParameters # @{}
    )

    <#
    Next,Step, actually filter on input
        currently *always* returns all

        ex input:
            sql -FromTable *git*demo*
        meaning this recieves
            *git*demo*
    #>
    Import-Module Pipeworks -PassThru -ea ignore | Out-Null # good or bad to ensure import? perf concerns?



    completer.ValidCompletions.For.SelectSql.TableName
    # | Where-Object {
    #     if (-not $WordToComplete) { return $true } # else blanks skip this function
    #     # try regex matching instgead of like
    #     $regex = .fmt.convert.LikeToRegex -LikeExpression $wordToComplete
    #     return ($_ -match $regex)
    # }
    | Where-Object {
        if (-not $WordToComplete) { return $true } # else blanks skip this function
        return $true
        # try regex matching instgead of like
        # $regex = .fmt.convert.LikeToRegex -LikeExpression $wordToComplete
        # return ($_ -match $regex)
    }
    # | ?{ $_ -match 'pssvg' }
    | ForEach-Object {
        $curItem = $_
        return $curITem


        <#
        Expected values
            $_, $commandName = 'Select-Sql'
                current completion from parent
            $parameterName = 'FromTable'
            $wordToComplete = '*git*demo*' or blank
            $fakeBoundParameters = @{}
            $commandAst = type [CommandAst]
                tostring = 'Select-SQL -FromTable'


    also check out
        $PSCmdlet.MyInvocation.MyCommand.ScriptBlock


    $PSCmdlet.MyInvocation.BoundParameters
            Key          Value
            ---          -----
            inputScript  sql -FromTable *toa
            cursorColumn 19
            options


    #>
        # $completionText = $curItem.TableName
        # $listItemText = $curItem.TableName, '_list' -join ''
        # $toolTip = $curItem.TableName, '_tip' -join ''
        # next: tool,tip shows column names
        # [System.Management.Automation.CompletionResult]::new(
        #     <# completionText: #> $completionText,
        #     <# listItemText: #> $listItemText,
        #     <# resultType: #> ([System.Management.Automation.CompletionResultType]::ParameterValue),
        #     <# toolTip: #> $toolTip )
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
    ParameterName = 'FromTable'
    ScriptBlock   = $SB_completer_PipeWorks_SelectSqlTableName
}
'registerCompleter: {0} -{1}' -f @(
    $registerArgumentCompleterSplat.CommandName
    $registerArgumentCompleterSplat.ParameterName
)
| Join-String -op $cFg -os $PSStyle.Reset
| Write-Information -infa 'continue'

Register-ArgumentCompleter @registerArgumentCompleterSplat

$registerArgumentCompleterSplat = @{
    CommandName   = 'Get-SqlTable'
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
    CommandName   = 'Get-SecureSetting'
    ParameterName = 'Name'
    ScriptBlock   = $SB_completer_PipeWorks_SecureSetting
}

'registerCompleter: {0} -{1}' -f @(
    $registerArgumentCompleterSplat.CommandName
    $registerArgumentCompleterSplat.ParameterName
)
| Join-String -op $cFg -os $PSStyle.Reset
| Write-Information -infa 'continue'

Register-ArgumentCompleter @registerArgumentCompleterSplat








if ($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Debug; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.04 #>


