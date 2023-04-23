2023-04-02

## 0x1 Rule: Never alias command with the same name

### Working Case

```ps1
# is okay
function ShouldHide {  '🐈' }
ShouldHide

function ShouldHide { 
   [CmdletBinding()]
   param()
   '🐈'
}

# is okay
ShouldHide
```

### Failed case

```ps1
function ShouldHide { 
   [Alias('ShouldHide')]
   [CmdletBinding()]
   param()
   '🐈'
}

ShouldHide

### failed reference

ShouldHide: 
Line |
   8 |  ShouldHide
     |  ~~~~~~~~~~
     | The term 'ShouldHide' is not recognized as a name of a cmdlet, function, script file, or executable program. 
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```