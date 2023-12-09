BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
}
Describe 'Dotils.Unicode.CategoryOf' {
    Context 'ParameterBinding DoesNotFail' {
        it 'as [char]' {
            { Dotils.Unicode.CategoryOf -Char ([char]'a') } | Should -Not -Throw
        }
        it 'as [int]Codepoint' {
            { Dotils.Unicode.CategoryOf -CodePoint 2400 } | Should -Not -Throw
        }
        it 'as text: [string:len1], [void]' {
            { Dotils.Unicode.CategoryOf ([string]'a')  } | Should -Not -Throw
        }
        it 'as text: [string:len2], [int]' {
            { Dotils.Unicode.CategoryOf ([string]'ab') 1  } | Should -Not -Throw -because 'in bounds'
            { Dotils.Unicode.CategoryOf ([string]'ab') 4  } | Should -Throw -Because 'OutOfBounds'
        }
        it 'as Position = 0, type = [Rune]' {
            { Dotils.Uni.Category ([Text.Rune]0x2400) } | Should -not -Throw
        }
        it 'as Position = 0, type = [string | char]' {
            { Dotils.Uni.Category 'c' } | Should -not -Throw
            { Dotils.Uni.Category ([char]'c') } | Should -not -Throw

        }
    }
    Context 'ParametersShouldFail' {
        it 'as text: [string:len2], [out-of-bounds] ' {
            { Dotils.Unicode.CategoryOf ([string]'ab') 1 } | Should -Not -Throw -because 'in bounds'
            { Dotils.Unicode.CategoryOf ([string]'ab') 4 } | Should -Throw -Because 'OutOfBounds'
        }
        it 'as text: blanks' {
            { Dotils.Uni.Category -InputText '' 0 } | Should -throw -because '[string]::empty'
            { Dotils.Uni.Category -InputText '' } | Should -throw -because '[string]::empty'
        }
    }

}
