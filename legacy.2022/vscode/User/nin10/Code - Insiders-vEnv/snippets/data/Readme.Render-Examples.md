- [Examples from using the VS Code snippets](#examples-from-using-the-vs-code-snippets)
  - [Pester Foreach](#pester-foreach)
  - [Pester Template](#pester-template)
- [PowerShell](#powershell)
  - [Function ⇢ Collect All from the Pipeline 🐒](#function--collect-all-from-the-pipeline-)


# Examples from using the VS Code snippets

## Pester Foreach

```ps1
It '"<Name>" Returns "<expected>"' -ForEach @(
    @{ Name = 'ls' ; Expected = 'Get-ChildItem' }
) {
    . $__PesterFunctionName $Name | Should -Be $Expected
}
```

When ran:

```ps1
. $__PesterFunctionName $Name | Should -Be $Expected is actually calling
```

Is actually calling

```ps1
Resolve-CommandName $Name | Should -Be $Expected
```

## Pester Template
```ps1
#requires -modules @{ModuleName='Pester';RequiredVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
    BeforeAll {
        . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
    }
    It 'Runs without error' {
        . $__PesterFunctionName 'arg'
    }
}
```

# PowerShell

## Function ⇢ Collect All from the Pipeline 🐒

```ps1
function Get-Foo {
    <#
    .synopsis
        Stuff
    .description
       .
    .example
          .
    .outputs
          [string | None]
    
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )
    
    begin {
        $NameList = [list[string]]::new()
    }
    process {
        $Name | ForEach-Object {
            $NameList.Add( $_ )
        }
    }
    end {
        $NameList
    }
}
```