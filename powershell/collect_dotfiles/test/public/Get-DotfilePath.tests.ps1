BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-DotfilePath" -Tag 'wip' {
    BeforeAll {
        Set-DotfileRoot "$Env:UserProfile\Documents\2021\dotfiles_git\powershell"
    }

    It 'Integration test' {
        Write-Warning 'future: test should use Pester temp drive'
        if ($false) {
            here $PSScriptRoot

            Add-DotfilePath -Label 'vs-code' 'dsf'
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


