BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
}
Describe 'Dotils.Test-IsOfType.FancyWip' {
    it 'sample as strings' {
        'red'
            | Dotils.Test-IsOfType.FancyWip -TypeNames @( 'PoshCode.Pansies.RgbColor' ) -AllowCompatibleType
            | Should -BeOfType 'PoshCode.Pansies.RgbColor'
    }
    it 'sample as instances' {
        'red'
        | Dotils.Test-IsOfType.FancyWip -TypeNames @( [PoshCode.Pansies.RgbColor] ) -AllowCompatibleType
        | Should -BeOfType ([PoshCode.Pansies.RgbColor]) -because 'manualTest'
    }
}
Describe 'Resolve.TypeInfo' -tags 'NeedsMoreT4ests' {
    it 'Returns typeInfo' -foreach @(
        @{
            Data = 12
            ExpectType = 'type'
            ExpectedValue = @( [int32] )
        }
    ) {
        $query = $Data | Resolve.TypeInfo
        $query | Should -BeExactly $ExpectedValue
        $query | Should -BeOfType 'type' -because 'Inspecting for TInfo'
    }
    <#

        'red' -is [System.ConsoleColor]
        'red' -as 'ConsoleColor' -is [ConsoleColor]
    #>
}
