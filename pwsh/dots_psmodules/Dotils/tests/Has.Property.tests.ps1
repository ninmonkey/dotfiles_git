BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru
    #  | write-host
    # hr  | write-host
}

Describe 'Dotils.Has.Property' -tag NeedsMoreTests {
    beforeAll {
        $TestObj = [pscustomobject]@{
            Name = 'Jen'
            Id = $null
            Last = [string]::Empty
        }
    }
    it '-AsTest and props' {
        $TestObj | Dotils.Has.Property -AsTest -name 'Id' -TestKind IsNull | should -be $true
        $TestObj | Dotils.Has.Property -AsTest -name 'Id' -TestKind IsBlank | should -be $true
        $TestObj | Dotils.Has.Property -AsTest -name 'Id' -TestKind IsNotNull | should -be $false
        $TestObj | Dotils.Has.Property -AsTest -name 'Id' -TestKind IsNull.AndExists | Should -be $True
        $TestObj | Dotils.Has.Property -AsTest -name 'FakePropName' -TestKind IsNull.AndExists | Should -be $false
        $TestObj | Dotils.Has.Property -AsTest -name 'FakePropName' -TestKind IsNull | Should -be $true
        $TestObj | Dotils.Has.Property -AsTest -name 'FakePropName' -TestKind IsBlank | Should -be $true
    }
    it 'Test alias props' {
        New-Alias 'zxyabcdef' -value 'hi world' -Description 'testing for blank props'
        get-alias | Dotils.Has.Property -name 'Description' -TestKind IsNotBlank
            | ft Name, *desc* | out-host
        remove-alias 'zxyabcdef'
    }
    it '<Enum> runs' -foreach @(
        @{ TestKind = 'Exists' }
        @{ TestKind = 'IsNotBlank' }
        @{ TestKind = 'IsNull' }
        @{ TestKind = 'IsBlank' }
        @{ TestKind = 'IsNull.AndExists' }
    ) {
        { Get-Date | Dotils.Has.Property -name 'Year' -TestKind $TestKind } | should -not -Throw
    }
}