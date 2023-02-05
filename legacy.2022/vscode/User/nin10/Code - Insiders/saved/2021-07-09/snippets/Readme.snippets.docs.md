- [Scope: Global, Multi-language, or disabled](#scope-global-multi-language-or-disabled)
  - [Personal Scopes](#personal-scopes)
- [Tutorials, Docs, Cheatsheets](#tutorials-docs-cheatsheets)
  - [Docs](#docs)
  - [Reference](#reference)

# Scope: Global, Multi-language, or disabled

 | Scope           | .                                             |
 | --------------- | --------------------------------------------- |
 | global:         | Either empty or undeclared                    |
 | multi-language: | `"scope": "json,jsonc"`                       |
 | Disabled:       | `"scope":"off"` ( any unused or invalid name) |

 ## Personal Scopes

 | Scope                   | .                                             |
 | ----------------------- | --------------------------------------------- |
 | `template` or `example` | These are not used themselves, but are examples for new snippets. |
 | `wip`                   | May not be finished                           |


# Keybinding a specific snippet

- <https://code.visualstudio.com/docs/editor/userdefinedsnippets#_assign-keybindings-to-snippets> 
- <https://code.visualstudio.com/docs/editor/userdefinedsnippets#_snippet-syntax>
- <https://code.visualstudio.com/api/language-extensions/snippet-guide#using-textmate-snippets>

## Using an inline snippet

```json
{
  "key": "cmd+k 1",
  "command": "editor.action.insertSnippet",
  "when": "editorTextFocus",
  "args": {
    "snippet": "console.log($1)$0"
  }
}
```

## Keybind to a snippet definition

```json
{
  "key": "cmd+k 1",
  "command": "editor.action.insertSnippet",
  "when": "editorTextFocus",
  "args": {
    "langId": "csharp", // lang filename
    "name": "myFavSnippet"
  }
}
```

# Textmate Grammar

[TextMate Grammar](https://macromates.com/manual/en/snippets)

## Chars Escaped by `\`

- `\` escapes `$`, `}`, `\` 
- inside `choice`, it escapes `,` and `|`

## Grammar EBNF

```
any         ::= tabstop | placeholder | choice | variable | text
tabstop     ::= '$' int
                | '${' int '}'
                | '${' int  transform '}'
placeholder ::= '${' int ':' any '}'
choice      ::= '${' int '|' text (',' text)* '|}'
variable    ::= '$' var | '${' var '}'
                | '${' var ':' any '}'
                | '${' var transform '}'
transform   ::= '/' regex '/' (format | text)+ '/' options
format      ::= '$' int | '${' int '}'
                | '${' int ':' '/upcase' | '/downcase' | '/capitalize' | '/camelcase' | '/pascalcase' '}'
                | '${' int ':+' if '}'
                | '${' int ':?' if ':' else '}'
                | '${' int ':-' else '}' | '${' int ':' else '}'
regex       ::= JavaScript Regular Expression value (ctor-string)
options     ::= JavaScript Regular Expression option (ctor-options)
var         ::= [_a-zA-Z] [_a-zA-Z0-9]*
int         ::= [0-9]+
text        ::= .*
```


# Tutorials, Docs, Cheatsheets

## Docs

docs:
    https://code.visualstudio.com/docs/editor/userdefinedsnippets

regex transform:
    https://code.visualstudio.com/docs/editor/userdefinedsnippets#_transform-examples

extension snippets tutorial:
    https://code.visualstudio.com/api/language-extensions/snippet-guide

## Reference

vscode variables:
    https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variables
