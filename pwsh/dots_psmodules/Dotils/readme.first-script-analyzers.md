- [ ] functions, alias
  - [ ] notcontains outer spacing that needs trim
  - [ ] or function name notcontains spaces anywhere 
- [ ] functions
  - [ ] not have multiple definitions as accidental shadow/collisions
- [ ] functions notcontains backtick continuations
- [ ] exported function, alises
  - [ ] exported from manifest but don't acutally exist
- [ ] function, symbols, alias, symbols of same name with case-sensitive differences `$FileList` `$fileList`
- [ ] Detect duplicate keys in hashtable literal
  - `$Conf = @{ A = 0; B = 1; A = 3; }`

## Test cases: 

```ps1

Type        : System.Management.Automation.ParseException
Errors      : 
    Extent  : A
    ErrorId : DuplicateKeyInHashLiteral
    Message : Duplicate keys 'A' are not allowed in hash literals.
Message     : At line:1 char:26
              + $Conf = @{ A = 0; B = 1; A = 3; }
              +                          ~
              Duplicate keys 'A' are not allowed in hash literals.
ErrorRecord : 
    Exception             : 
        Type    : System.Management.Automation.ParentContainsErrorRecordException
        Message : At line:1 char:26
                  + $Conf = @{ A = 0; B = 1; A = 3; }
                  +                          ~
                  Duplicate keys 'A' are not allowed in hash literals.
        HResult : -2146233087
    CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
    FullyQualifiedErrorId : DuplicateKeyInHashLiteral
    InvocationInfo        : 
        ScriptLineNumber : 1
        OffsetInLine     : 26
        HistoryId        : -1
        Line             : $Conf = @{ A = 0; B = 1; A = 3; }
        PositionMessage  : At line:1 char:26
                           + $Conf = @{ A = 0; B = 1; A = 3; }
                           +                          ~
        CommandOrigin    : Internal
TargetSite  : 
    Name          : Invoke
    DeclaringType : System.Management.Automation.Runspaces.PipelineBase, System.Mana
Version=7.3.6.500, Culture=neutral, PublicKeyToken=31bf3856ad364e35
    MemberType    : Method
    Module        : System.Management.Automation.dll
```