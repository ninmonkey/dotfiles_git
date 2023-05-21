Describe '.fmt.Clamp' {
    It '<Sample> is <Expected>' -ForEach @(
        @{
            Sample   = 20
            Min      = 10
            Max      = 30
            Expected = 20
        }
        @{
            Sample   = 4
            Min      = 4.5
            Max      = 30
            Expected = 4.5
        }
    ) {
        $res = $Sample | .fmt.Clamp -MinValue $Min -max $Max
        $res | Should -BeExactly $Expected
        # $res | Should -BeOfType $Expected.GetType()
    }
    It 'Manual' {
        { 34.1 | .fmt.Clamp -min 20 -max 10 } | Should -Throw -Because 'out of bounds'

        3.14 | .fmt.Clamp -MinValue 1.9 -MaxValue 5.9 -As Int | Should -Be 3
        3.14 | .fmt.Clamp -MinValue 1.9 -MaxValue 5.9 -As Int | Should -BeOfType 'int'
    }

}

# 30.94 | .fmt.Clamp -min 20 -max 40 -As 'Auto' -Verbose
# 30.94 | .fmt.Clamp -min 20 -max 40 -As 'Int' -Verbose
# 30.94 | .fmt.Clamp -min 20 -max 40 -Verbose