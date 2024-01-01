describe 'foo' {
    Context 'template test for <Template>' -ForEach @(
            @{ Template = 'FullName' }
            @{ Template = 'Name' }
    ) {
        It 'Format <Template> Expected: <Expected> from <In>' -ForEach @(
            @{
                In = 'A'
                Expected = 'ex a'
            }
            @{
                In = 'B'
                Expected = 'ex B'
            }
            # $dint  | Dotils.Format-ShortType -Template Name -MinNamespaceCrumbCount 2
        ) {
            $true | Should -be $True

        }
    }
}
