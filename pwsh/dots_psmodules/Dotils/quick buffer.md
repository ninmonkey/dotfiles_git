# quick buffer
get-module dotils | .Iter.Prop | ?{ Test-Path $_.Value  }
get-module dotils | .Iter.Prop -DropBlankValues | ?{ Test-Path $_.Value  }
get as tiem span as seconds in  nin.posh
fuinc describe: module
validator: ensure commands and aliases actually resolve
    ask: gcm does not work when ther''s 2+ sharing a name

first:
pipe command ( using Operator.Is.tests.ps1)
    .All.True
    .Any.True
    .None.True


tab completer like `gcm`
    but only my commands

    describe shows alias to command mampping
Dotils.SelectBy-Module
grep command, checks my commits for any functions or alias
Dotils.Find-MyWorkspace
SessionStateEntryVisibility, CommandType, Name, Definition, DisplayName, ModuleName, Module, ReferencedCommand, ResolvedCommand, ResolveCommandName, Source, Version, Visiblity

new verb, drop, which implies filtering
.Drop.NullValues
.Drop.BlankKeys

cool idea: turn Get-Help, into markdown clickable pages