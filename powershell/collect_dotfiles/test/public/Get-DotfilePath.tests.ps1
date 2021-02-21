BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-DotfilePath" -Tag 'wip' {
    It 'Integration test' {
        Add-DotfilePath -Label 'vs-code'

    }
}


# # function _test1 {
# Add-DotfilePath -Label 'vs-code' -Path 'vscode\.auto_export'
# # Add-DotfilePath -Label 'vs-code-snippets' -Path 'snippets' -RelativeTo 'vs-code'
# Get-DotfilePath -ListAll
# $result = Get-DotfilePath -Label 'vs-code-snippets'
# }
# _test1


