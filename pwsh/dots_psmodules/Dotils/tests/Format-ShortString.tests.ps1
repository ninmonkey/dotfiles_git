BeforeAll {
    Import-Module 'Dotils' -force -passthru  | write-host
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}
AfterAll {
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}
Describe 'Dotils.Format-ShortString.Basic' {
    it '"<sample>" at <' -forEach @(
        @{
            Sample = '123456'
            MaxLength = 1000
            Expected = '123456'
        }
        @{
            Sample = '123456'
            MaxLength = 4
            Expected = '1234'
        }
    ) -Tag 'tests wip/nyc' {
        Dotils.Format-ShortString.Basic -Inp $Sample -maxLength $MaxLength
            | Should -BeExactly $Expected
    }
}
Describe 'Misc' {
    it 'Format.AliasSummaryLiteral' -skip  -tag 'ExpectToBreak' -Foreach @(
        @{
            Expect = @(
                "'Dotils.Resolve.TypeInfo' # 'Dotils.Resolve.TypeInfo' = { 'Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }"
                "'Dotils.ConvertTo.TypeInfo' # 'Dotils.Resolve.TypeInfo' = { 'Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }"
                "'Resolve.TypeInfo' # 'Dotils.Resolve.TypeInfo' = { 'Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo' }"
            )
            FunctionName = 'Dotils.Resolve.TypeInfo'
            AliasNames = @(  'Resolve.TypeInfo', 'Dotils.ConvertTo.TypeInfo'  )
        }

    ) {
        Dotils.DebugUtil.Format.AliasSummaryLiteral -FunctionName $FunctionName -AliasNames $AliasNames
        | Should -BeLike $Expect -because 'ManualTest,ExpectWhitespaceToFail'

    }
}
Describe 'Dotils.Format-ShortString' {
    it '"<sample>" at <' -forEach @(
        @{
            Sample = '123456'
            StartPos = 0
            MaxLen = 3
            Expected = '123'
        }
        @{
            Sample = '123456'
            StartPos = 1
            MaxLen = 3
            Expected = '234'
        }
        @{
            Sample = '123456'
            StartPos = -1
            # MaxLen = 3
            Expected = '6'
        }
        @{
            Sample = '123456'
            StartPos = -4
            Expected = '3456'
        }
        @{
            <#
                $at = -4
                $sample.Substring( ($sample.Length + $at) )

                > 3456
            #>
            Sample = '123456'
            StartPos = -4
            MaxLen = 2
            Expected = '3456'
        }
        @{
            <#
                $at = -4
                $sample.Substring( ($sample.Length + $at), 2 )

                > 34
            #>
            Sample = '123456'
            StartPos = -4
            MaxLen = 2
            Expected = '34'
        }
        <#
        $at = -4
        $sample.Substring( ($sample.Length + $at) )
            3456


        #>

    ) -Tag 'tests wip/nyc' {
        write-warning 'func <Dotils.Format-ShortString> is NYI. partial sketch'
        Dotils.Format-ShortString -Inp $Sample -maxLength -StartPosition $StartPos
            | Should -BeExactly $Expected
    }
}
