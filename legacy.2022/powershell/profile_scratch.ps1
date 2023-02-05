@'
- [see more at](file://H\env\code\lib-vscode-venv.ps1)

Examples are to illustrate

- 1] change logic based on parameters

```ps1
$x | QuoteIt
QuoteIt $x
```



logic changes depending on whether an arg is from the pipeline or param



- 2] can you change based on the pipeline state ?

for #2 do you know how it's standard for linux to have

```ps1
foo.exe --color=auto

# this outputs ansi escapes for color
foo.exe

# this does not output escapes
foo.exe | less
```
'@



function InspectI.0 {
    <#
    .SYNOPSIS
        tiny sugar examples
    #>
    param( [object]$InputObject, [switch]$PassThru )
    if( $PassThru ) {
        $inputObject.gettype().implementedinterfaces
        return
    }
    $inputObject.gettype().implementedinterfaces | ft -GroupBy {$true}
}

function InspectI.1 {
    <#
    .SYNOPSIS
        tiny sugar examples
    #>
    [cmdletBinding()]
    param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [object]$InputObject,
            [switch]$PassThru )

    process {
        if($PassThru) {
            $InputObject.GetType().ImplmentedInterfaces()
        }
    }
    end {
        if($PassThru) { return  }
        $InputObject.GetType().implementedinterfaces() | fg -GroupBy {$true}
    }
}





function QuoteIt {


}

function QuoteParam {
    <#
    .SYNOPSIS
        sugar ensure doublequoted string
    #>
    [Alias('Quote')]
    [OutputType('String')]
    param( [string]$Text)
    '"{0}"' -f @( $Text )
}

function QuotePipe {
    <#
    .SYNOPSIS
        minimum sugar supporting pipeline less clean, but supports pipes
    #>
    process {
        '"{0}"' -f @( $_ )
    }
}