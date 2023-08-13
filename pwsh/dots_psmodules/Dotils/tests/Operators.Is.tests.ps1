BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
}
Describe 'Dotils.Test-CompareSingleResult' {
    it '<Sample> expression <Kind> is  <Expected>' -TestCases @(
        #   ExpectedType = 'bool'
        # [ValidateSet('True', 'False', 'Null', 'EmptyString', $true, $False)]
        @{
            Sample = $true
            ExpressionKind = $True
            Expected = $true
        }
    ) {
        $test =
            $Sample | Dotils.Test-CompareSingleResult -ExpressionKind $Kind
        $test | Should -BeExactly $Expected

        $test | Should -BeOfType 'bool'
        # $test | Should -BeExactly $Expected

    }
}
Describe 'Dotils.Operator.TypeIs' {
    Context 'Should Not Filter, return bools for -AsTest' {
        it 'Comparing Objects <Type> is <ExpectedType>' -forEach @(
            @{
                # Sample = 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'


                Sample = 'a', 234, 3.4
                Type  = 'int'
                Expected = $false, $true, $false
                ExpectedType = 'bool'
                    # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'

                # | Dotils.Operator.TypeIs -Type 'int'
                # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int' -AsTest | SHould
            }
        ) <# -Tag 'tests wip'#>  {
            $test =
                $Sample | Dotils.Operator.TypeIs -Type 'int' -AsTest
            $test | Should -BeExactly $Expected
            $test | Should -BeOfType $ExpectedType -because 'it should return list of bools from comparisons'


            # $test | Should -BeExactly $Expected
            # $test | Should -BeOfType  $ExpectedType

            # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'
            # Dotils.Format-ShortString.Basic -Inp $Sample -maxLength
                # | Should -BeExactly $Expected
        }
    }
    Context 'Default Filters Object' {
        it '<Type> is <ExpectedType>' -forEach @(
            @{
                # Sample = 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'
                Sample = 'a', 234, 3.4
                Type  = 'int'
                Expected = '234'
                ExpectedType = 'int'
                    # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'

                # | Dotils.Operator.TypeIs -Type 'int'
            }
        ) <# -Tag 'tests wip'#>  {
            $test =
                $Sample | Dotils.Operator.TypeIs -Type 'int'

            $test | Should -BeExactly $Expected
            $test | Should -BeOfType  $ExpectedType -because 'it should be filtering inputs by type'

            # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'
            # Dotils.Format-ShortString.Basic -Inp $Sample -maxLength
                # | Should -BeExactly $Expected
        }
    }
}
