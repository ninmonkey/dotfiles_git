BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
    hr  | write-host
}

Describe 'Format.WildCardPattern' {
    it 'Spaces Convert to Wildcards' -ForEach @() {
        Dotils.Format.WildcardPattern 'foo bar*' #-SpacesToWildcard
    }
    Context 'WithoutWrapOutside' {
         it 'Wrap? <WrapOutside> Spaces? <WithoutSpacesToWildcard> :  <Sample> was <Expected>' -ForEach @(
            @{
                Sample = 'foo', 'bar'
                Expected = '*foo*bar*'
                WithoutSpacesToWildcard = $True
                WithoutWrapOutside = $false
            }
            @{
                Sample = 'foo', 'bar cat'
                Expected = 'foo*bar*cat'
                WithoutSpacesToWildcard = $false
                WithoutWrapOutside = $true
            }
            @{
                Sample = '*to json'
                Expected = '*to*json'
                WithoutSpacesToWildcard = $false
                WithoutWrapOutside = $true
            }
         ) {
            Dotils.Format.WildcardPattern $Sample -WithoutSpacesToWildcard:$WithoutSpacesToWildcard -WithoutWrapOutside:$WithoutWrapOutside
            | should -BeExactly $Expected

         }
    }
    Context 'Using SpacesAsWildcards' {
        it '<Sample> was <Expected>' -ForEach @(
            @{
                Sample = 'foo', 'bar'
                Expected = '*foo*bar*'
            }
            @{
                Sample = '*foo', 'bar*'
                Expected = '*foo*bar*'
            }
            @{
                Sample = '*foo  bar*'
                Expected = '*foo*bar*'
            }
            @{
                Sample = '*foo', 'bar cat*'
                Expected = '*foo*bar*cat*'
            }
             @{
                Sample = '*foo', 'bar cat*'
                Expected = '*foo*bar*cat*'
            }

            #     # otils.Format.WildcardPattern '*foo', 'bar cat*'|cl -App
            # *foo*bar cat*


        ) {
            Dotils.Format.WildcardPattern $Sample # -WithoutSpacesToWildcard:$false
            | should -BeExactly $Expected
        }

    }
    Context 'SpacesAsWildcards is False' {
        it '<Sample> was <Expected>' -ForEach @(
            @{
                Sample = 'foo', 'bar'
                Expected = '*foo*bar*'
            }
            @{
                Sample = '*foo', 'bar cat*'
                Expected = '*foo*bar cat*'
            }
            @{
                Sample = '*foo', 'bar*'
                Expected = '*foo*bar*'
            }

        ) {
            Dotils.Format.WildcardPattern $Sample -WithoutSpacesToWildcard:$True
            | should -BeExactly $Expected
        }
    }
    # it 'sample as strings' {
    #     'red'
    #         | Dotils.Test-IsOfType.FancyWip -TypeNames @( 'PoshCode.Pansies.RgbColor' ) -AllowCompatibleType
    #         | Should -BeOfType 'PoshCode.Pansies.RgbColor'
    # }
    # it 'sample as instances' {
    #     'red'
    #     | Dotils.Test-IsOfType.FancyWip -TypeNames @( [PoshCode.Pansies.RgbColor] ) -AllowCompatibleType
    #     | Should -BeOfType ([PoshCode.Pansies.RgbColor]) -because 'manualTest'
    # }
}