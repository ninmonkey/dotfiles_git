function Dotils.Fonts.ListImported {
    <#
    .notes
        # original
        gcm -ListImported
                | % Source | sort -Unique
                | Join-String -sep ', ' { '[ a: {0}, ]' -f $_ }
    #>
    Join-String -op 'Dotils.Fonts.psm1 => [ ' -os ' ] ' -sep ', ' -in @(
        gcm -ListImported 'Dotils.*font*'
            | % Source
            | Sort-Object -Unique
            | %{
                $_ | Join-String -single ', ' Source
            }
    )
}

Export-ModuleMember -Function @(
    # 'Dotils.GetCommand.ListImported'
    # 'Dotils.GetCommand.ListImported'
    'Dotils.Fonts.*'
) -Alias @(
    'Dotils.Fonts.*'
) -Variable @(
    'Dotils.Fonts.*'
)
