BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
}
Describe 'Dotils.Format-HexString' {
    it 'NYI' {
        Set-ItResult -Pending -because 'align param needs change to support more than 2 formats, sample output here'
        <#

        for comparison:
            '{0,-6:x}' -f  253 | join-string -SingleQuote
            'fd    '

            '{0,6:x}' -f  253 | join-string -SingleQuote
            '    fd'

             '{0:x}' -f  253 | join-string -SingleQuote| cl
            'fd'
        #>
    }
    it 'NYI tests' {
        {
        'hi 🐒 world' | Dotils.Format-HexString
            | Join-string -sep ', '  -SingleQuote | cl -Append
        # out: '68', '69', '20', '1f412', '20', '77', '6f', '72', '6c', '64'

        'hi 🐒 world' | Dotils.Format-HexString -Options @{ PrefixWithHex = $true }
            | Join-string -sep ', '  -SingleQuote
        # out: '0x68', '0x69', '0x20', '0x1f412', '0x20', '0x77', '0x6f', '0x72', '0x6c', '0x64'
        'hi 🐒 world' | Dotils.Format-HexString -Options @{ PrefixWithHex = $true } -PadZerosSwitch
            | Join-string -sep ', '  -SingleQuote
        # out:  '0x000068', '0x000069', '0x000020', '0x01f412', '0x000020', '0x000077', '0x00006f', '0x000072', '0x00006c', '0x000064'

        # more

        'hi 🐒 world' | Dotils.Format-HexString
            | Join-string -sep ', '  -SingleQuote

        'hi 🐒 world' | Dotils.Format-HexString -Options @{ PrefixWithHex = $true }
            | Join-string -sep ', '  -SingleQuote

        'hi 🐒 world' | Dotils.Format-HexString -Options @{ PrefixWithHex = $true } -PadZerosSwitch
            | Join-string -sep ', '  -SingleQuote
        }| OutNull
    }
    it -Pending '"<Sample>" is <Expected>' -forEach @(
        @{
            Sample = 200
            Expected = 'c8'
        }
        @{
            Sample = '🦎'
            Expected = '1f98e'
        }
        @{
            Sample = 255
            AlignRightSwitch = $false
            PadZerosSwitch = $True
            Options =  @{ PrefixWithU = $true }
            Expected = 'U+0000ff'
        }
        @{
            Sample = 255
            AlignRightSwitch = $false
            PadZerosSwitch = $True
            Options =  @{ PrefixWithU = $false }
            Expected = '0000ff'
        }
        @{
            Sample = 255
            AlignRightSwitch = $false
            PadZerosSwitch = $false
            Options =  @{ PrefixWithU = $false }
            Expected = 'ff'
        }
        @{
            Sample = 255
            AlignRightSwitch = $true
            PadZerosSwitch = $false
            Options =  @{ PrefixWithU = $false }
            Expected = '0000ff'
        }
        @{
            Sample = 200
            AlignRightSwitch = $true
            Expected = '    c8'

        }
    ) -Tag 'StringCompare' {
        $splat_format = @{
            AlignRightSwitch = $AlignRightSwitch ?? $false
            PadZerosSwitch = $PadZerosSwitch ?? $false
        }
        if($Options) {
            $splat_format.Options = $Options
        }

        $Sample
        | Dotils.Format-HexString @splat_format
        | Should -be $Expected
        # Dotils.Format-ShortString.Basic -Inp $Sample -maxLength
            # | Should -BeExactly $Expected
    }
}