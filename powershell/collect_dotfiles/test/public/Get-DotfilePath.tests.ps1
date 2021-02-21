BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-DotfilePath" -Tag 'wip' {
    BeforeAll {
        Reset-DotfilePath
        Set-DotfileRoot "$Env:UserProfile\Documents\2021\dotfiles_git"
    }

    It 'Integration test' {
        Add-DotfilePath -Label 'vscode' 'vscode/.auto_export'
        Add-DotfilePath -Label 'snippets-hardcoded' -Path 'vscode/.auto_export/snippets'
        Add-DotfilePath -Label 'snippets' -Path 'snippets' -RelativeTo 'vscode'

        Write-Warning 'next: pester test relativeto'
        # Write-Error 'error'
        throw "left off here"
        Get-DotfilePath 'root'
        Get-DotfilePath 'snippets-hardcoded'
        Get-DotfilePath 'snippets'
        if ($false) {
            here $PSScriptRoot

            Add-DotfilePath -Label 'vs-code' -Path 'vscode\.auto_export'
            Add-DotfilePath -Label 'vs-code-snippets' -Path 'snippets' -RelativeTo 'vs-code'
        }

    }
}


# # function _test1 {
# Get-DotfilePath -ListAll
# $result = Get-DotfilePath -Label 'vs-code-snippets'
# }
# _test1


