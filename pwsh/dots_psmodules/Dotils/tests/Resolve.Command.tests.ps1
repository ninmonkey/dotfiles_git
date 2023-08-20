BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
    Import-module Ninmonkey.Console *>$Null
    hr  | write-host
}

Describe 'Dotils.Resolve.Command' {
    it 'Input <Data> resolves as <ExpectedValue>' -foreach @(
        @{
            Data = 'label'
            ExpectedValue = gcm 'Ninmonkey.Console\Write-ConsoleLabel'
        }
        @{
            Data = Gcm 'label'
            ExpectedValue = gcm 'Ninmonkey.Console\Write-ConsoleLabel'
        }
        @{
            Data = Get-Alias 'label'
            ExpectedValue = gcm 'Ninmonkey.Console\Write-ConsoleLabel'
        }
        @{
            Data = gcm 'Ninmonkey.Console\Write-ConsoleLabel' # round trip
            ExpectedValue = gcm 'Ninmonkey.Console\Write-ConsoleLabel'
        }
    ) {
        $cmd = $Data | Dotils.Resolve.Command
        $cmd | Should -Be $Expectedvalue
        $cmd | Should -BeOfType 'System.Management.Automation.CommandInfo'

            # | Should -BeOfType 'PoshCode.Pansies.RgbColor'
    }

}