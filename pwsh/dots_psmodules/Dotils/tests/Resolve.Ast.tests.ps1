BeforeAll {
    Import-Module -ea 'stop' 'Dotils' -force -passthru  | write-host
    hr  | write-host
}

Describe 'Dotils.Resolve.Ast' {

    # it 'false' {
    #     $false | Should -be $false
    # }
    # it 'sample as strings' -skip {
    #     'red'
    #         | Dotils.Test-IsOfType.FancyWip -TypeNames @( 'PoshCode.Pansies.RgbColor' ) -AllowCompatibleType
    #         | Should -BeOfType 'PoshCode.Pansies.RgbColor'
    # }
    # it 'sample as instances' -skip {
    #     'red'
    #     | Dotils.Test-IsOfType.FancyWip -TypeNames @( [PoshCode.Pansies.RgbColor] ) -AllowCompatibleType
    #     | Should -BeOfType ([PoshCode.Pansies.RgbColor]) -because 'manualTest'
    # }
    it '<sample> was <Expected>' -foreach @(
        @{
            Sample = Get-Command 'prompt'
            ExpectedType = (Get-Command 'prompt').ScriptBlock.Ast.GetType()
        }
    ) {
        { $Sample | Dotils.Resolve.Ast }
            | Should -not -throw

        $Sample | Dotils.Resolve.Ast
            | SHould -BeOfType $ExpectedType

    }
}
# Describe 'Resolve.TypeInfo' -tags 'NeedsMoreT4ests' -skip {
#     it 'Returns typeInfo' -foreach @(
#         @{
#             Data = 12
#             ExpectType = 'type'
#             ExpectedValue = @( [int32] )
#         }
#     ) {
#         $query = $Data | Resolve.TypeInfo
#         $query | Should -BeExactly $ExpectedValue
#         $query | Should -BeOfType 'type' -because 'Inspecting for TInfo'
#     }
#     <#

#         'red' -is [System.ConsoleColor]
#         'red' -as 'ConsoleColor' -is [ConsoleColor]
#         __compare-Is.Type $Null -TypeName 'IO.DirectoryInfo' -Debug
#     #>
# }
# Describe '__compare-Is.Type' -Skip {
#     it 'null with -AllowNull should not throw' {
#         { __compare-Is.Type $Null -TypeName 'IO.DirectoryInfo' -AllowNull:$true }
#             | Should -not -Throw
#     }
#     it 'null should throw' {
#         { __compare-Is.Type $Null -TypeName 'IO.DirectoryInfo' -AllowNull:$false }
#             | Should -Throw
#     }
#     it ' Allow Nulls: <Left> is <Right>' -foreach @(

#         @{
#             Left = $null
#             Right = 'IO.DirectoryInfo'
#             ExpectedValue = $false
#             AllowNull = $true
#         }
#     ) {
#         __compare-Is.Type $Null -TypeName 'IO.DirectoryInfo' -Debug
#         $test = __compare-Is.Type -InputObject $Left -TypeName $Right -AllowNull
#         $test | Should -BeOfType 'bool'
#         $test | Should -BeExactly $ExpectedValue

#     }
#     it ' <Left> is <Right>' -foreach @(
#         @{
#             Left = (gi .).GetType()
#             Right = 'IO.DirectoryInfo'
#             ExpectedValue = $True
#         }
#     ) {
#         $test = __compare-Is.Type -InputObject $Left -TypeName $Right
#         $test | Should -BeOfType 'bool'
#         $test | Should -BeExactly $ExpectedValue
#     }
#     it -pending ' <Left> is <Right> is <ExpectedValue>' -foreach @(
#         @{
#             Left = 2
#             Right = 'int'
#             ExpectedValue = $true
#             # CompareString = $True
#         }
#         @{
#             Left = 2
#             Right = 'int'
#             ExpectedValue = $false
#             # CompareString = $false
#         }
#         @{
#             Left = 2.2
#             Right = 'int'
#             ExpectedValue = $false
#             # CompareString = $false
#         }
#     ) {
#         $query = dotils\__compare-Is.Type -InputObject $Left -TypeName $Right # -CompareString:$CompareString
#         $query | Should -BeOfType 'bool' -because 'logical test'
#         $query | Should -Be $ExpectedValue
#     }
#     <#

#         'red' -is [System.ConsoleColor]
#         'red' -as 'ConsoleColor' -is [ConsoleColor]
#     #>
# }


