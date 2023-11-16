function Dotils.GetCommand.ListImported {
    <#
    .notes
        # original
        gcm -ListImported
                | % Source | sort -Unique
                | Join-String -sep ', ' { '[ a: {0}, ]' -f $_ }
    #>
    Join-String -op 'already loaded sources: [ ' -os ' ] ' -f @(
        gcm -ListImported
            | % Source | sort -Unique
            | Join-String -sep ', ' Source

    )
}

Export-ModuleMember -Function @('Dotils.GetCommand.ListImported') -Alias @() -Variable @()
