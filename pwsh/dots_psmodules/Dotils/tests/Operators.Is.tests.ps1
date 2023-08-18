BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
}
Describe 'sdfds' -tags 'NeedsMoreT4ests' {
    it '<Sample> is <Expected>' -foreach @(
        @{
            Sample = 'a', 234, 3.4
            Expected = 'a', 234, 3.4
        }
    ) {
        $test =
            $Sample | Dotils.Operator.TypeIs -Type 'int'
        $test | Should -BeExactly $Expected
        $test | Should -BeOfType 'bool'

        # 'a', 234, 3.4 | Dotils.Operator.TypeIs -Type 'int'
        # Dotils.Format-ShortString.Basic -Inp $Sample -maxLength
            # | Should -BeExactly $Expected
    {
        __compare-Is.Type $Obj -is $TypeName
    }
}
Describe 'Dotils.Test-IsOfType' -Tags @(
    'NeedsMoreTests'
) {
    it '-AsTest <Sample> returns <Expect>' -foreach @(
        @{
            Sample = 1245, 3.56
            TypeNames = 'int'
            Expect = $false
            IsCompatible  = $false
         }
        @{
            Sample = 1245
            TypeNames = 'int'
            Expect = $true
            IsCompatible  = $false
         }
        @{
            Sample = 1245
            TypeNames = 'int'
            Expect = $true
            IsCompatible  = $false
         }
    ) {
        'this version should only return true/false as a final summary'
        $Result = $Sample | Dotils.Test-IsOfType -TypeNames $TypeNames -IsCompatible:$IsCompatible
        $result | Should -Be $Expect
        $result | Should -BeOfType $TypeName
    }
    it '<stuff>' -foreach @(
        @{
            Sample = @(
                [Text.Rune]::new(0x2400),
                'a', 2.34, 234 )
            Expect = @(
                [Text.Rune]::new( 0x2400 ), 'a', 234 )
                # | Dotils.Test-IsOfType int, string, Text.
            TypeNames = 'int', 'string', 'Text.Rune'
        }
    ) {
        $Sample | Dotils.Test-IsOfType -TypeNames $TypeNames
        | Should -BeExactly $Expected

    }
    #'red' -as ([PoshCode.Pansies.RgbColor])
        # ([Text.Rune]::new(0x2400)), 'a', 2.34, 234 | Dotils.Test-IsOfType
        # |  Should -BeExactly @( [Text.Rune]::new( 0x2400 ), 'a', 234 )
}
Describe 'Dotils.Test-CompareSingleResult' {
    it 'Manual 1' {
        $true, $false, 'cat'
            | Dotils.Test-AllResults All True
            | Should -be $false
    }
    it 'Manual 2' {
        $test = $true, $false, 'cat'
        $test | Dotils.Test-AllResults Any True
            | Should -be $true
        $test | Should -BeOfType 'bool'
    }
    it 'Manual 3' {
        $test = $false, $false, ''
        $test | Dotils.Test-AllResults All False
            | Should -be $false -because 'ensure that empty str is not false implicitly with one config'
        $test | Should -BeOfType 'bool'
    }
    Context 'Strict: Null is not False' {
        it 'Strict <Strict> As <As> is <Expected>' -forEach @(
            @{
                Sample = @()
                AmountCondition = 'All'
                As = 'null'
                Strict = $true
                Expected = $false
            }
            @{
                Sample = @()
                AmountCondition = 'All'
                As = 'null'
                Strict = $false
                Expected = $true
            }
        ) {
            $test =
            $Sample
                | Dotils.Test-AllResults -AmountCondition $AmountCondition -As $As -Strict $Strict
                | Should -be $finalExpected

            $test | Should -BeOfType 'bool'

        }
    }
    it '<AmountCondition> As <As> is <Expected>' -pending -forEach @(
        @{
            Sample = $false, $false, $true
            AmountCondition = 'All'
            As = 'false'
            Expected = $false
        }
        @{
            Sample = $false, $false, $true
            AmountCondition = 'Any'
            As = 'false'
            Expected = $true
        }
        @{
            Sample = $false, $false, $true
            AmountCondition = 'None'
            As = 'false'
            Expected = $false
        }
        @{
            Sample = $true
            AmountCondition = 'All'
            As = 'true'
            Expected = $true
        }
        @{
            Sample = $true, $true
            AmountCondition = 'All'
            As = 'true'
            Expected = $true
        }
        @{
            Sample = $false
            AmountCondition = 'All'
            As = 'false'
            Expected = $true
        }
        @{
            Sample = $false, $false
            AmountCondition = 'All'
            As = 'false'
            Expected = $true
        }
        @{
            Sample = $false, ' ', $false
            AmountCondition = 'All'
            As = 'false'
            Expected = $false
        }
        @{
            Sample = $true, $false, $true
            AmountCondition = 'All'
            As = 'false'
            Expected = $false
        }
        @{
            Sample = $true, $false, $true
            AmountCondition = 'Any'
            As = 'false'
            Expected = $true
        }
        @{
            Sample = $true, $false, $true
            AmountCondition = 'None'
            As = 'false'
            Expected = $false
        }
        @{
            Sample = $null
            AmountCondition = 'All'
            As = 'true'
            Expected = $false
        }
        @{
            Sample = $null
            AmountCondition = 'Any'
            As = 'true'
            Expected = $false
        }
        @{
            Sample = $null
            AmountCondition = 'Any'
            As = 'null'
            Expected = $true
        }
        @{
            Sample = '', 'foo', $null
            AmountCondition = 'Any'
            As = 'null'
            Expected = $true
        }
        @{
            Sample = $Null, $Null
            AmountCondition = 'Any'
            As = 'null'
            Expected = $true
        }
        @{
            Sample = $Null, $Null
            AmountCondition = 'All'
            As = 'null'
            Expected = $true
        }


    ) {
        $test =
            $Sample
            | Dotils.Test-AllResults -AmountCondition $AmountCondition -As $As
            | Should -be $finalExpected

        $test | Should -BeOfType 'bool'
    }
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
