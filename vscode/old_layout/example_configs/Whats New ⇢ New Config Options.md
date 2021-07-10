- [Sect: "What's New" / New Features / Configs from patches](#sect-whats-new--new-features--configs-from-patches)
  - [[v1.55]](#v155)
    - [New Visual Config Settings](#new-visual-config-settings)
    - [Experimental Config](#experimental-config)
    - [New Debugger: Break on Read/Write of a variable](#new-debugger-break-on-readwrite-of-a-variable)
  - [[v1.53]](#v153)
  - [[v1.51]](#v151)
  - [[v1.45]](#v145)
    - [Pasting multi-line should be helped/fixed by this binding.](#pasting-multi-line-should-be-helpedfixed-by-this-binding)

# Sect: "What's New" / New Features / Configs from patches

Source: Summarized a small fraction of the full site. <https://code.visualstudio.com/updates/v1_56>


## [v1.55]


- [Terminal Profiles](https://code.visualstudio.com/updates/v1_55#_terminal-profiles)

### New Visual Config Settings

- `notebook.inactiveSelectedCellBorder`
- `notebook.diff.ignoreOutputs`
- `notebook.diff.ignoreMetadata`

![img](https://code.visualstudio.com/assets/updates/1_55/notebook-multiselect-border.gif)
![img](https://code.visualstudio.com/assets/updates/1_55/notebook-show-differences.gif)

### Experimental Config

- `notebook.experimental.useMarkdownRenderer: true`

### New Debugger: Break on Read/Write of a variable

- **Break on Value Read**: breakpoint will be hit every time a variable gets read.
- **Break on Value Change**: breakpoint will be hit every time a variable gets changed (this action was previously available).
- **Break on Value Access**: breakpoint will be hit every time a variable is read or changed.


![img](https://code.visualstudio.com/assets/updates/1_55/break-on-value.png)

```json
"terminal.integrated.profiles.windows": {
  // Add a PowerShell profile that doesn't run the profile
  "PowerShell (No Profile)": {
      // Some sources are available which auto detect complex cases
      "source": "PowerShell",
      "args": ["-NoProfile"],
      // Name the terminal "PowerShell (No Profile)" to differentiate it
      "overrideName": true
  },
  // Remove the builtin Git Bash profile
  "Git Bash": null,
  // Add a Cygwin profile
  "Cygwin": {
    "path": "C:\\cygwin64\\bin\\bash.exe",
    "args": ["--login"]
  }
}
```

## [v1.53]

  - inline urls, extension API: <https://code.visualstudio.com/updates/v1_53#_external-uri-opener>
  - <https://code.visualstudio.com/updates/v1_53#_git-new-settings>
  - "workbench.editor.wrapTabs" <https://code.visualstudio.com/updates/v1_53#_wrap-tabs>

## [v1.51]

- [Prevent accidental close](https://code.visualstudio.com/updates/v1_51#_prevent-accidental-close)
- "editor.suggest.showStatusBar": true, // https://code.visualstudio.com/updates/v1_51#_status-bar-for-suggestions
- "editor.suggest.insertMode":"insert", // https://code.visualstudio.com/updates/v1_51#_move-cursor-to-select-suggestions
- [New developer examples](https://code.visualstudio.com/updates/v1_51#_extension-authoring)
- [Resizable Suggestions]<https://code.visualstudio.com/updates/v1_51#_resizable-suggestions>

![img](https://code.visualstudio.com/assets/updates/1_51/suggest-drag.gif)

Controls whether tabs should be wrapped over multiple lines when exceeding available space or whether a scrollbar should appear instead. This value is ignored when `#workbench.editor.showTabs#` is disabled.

## [v1.45]

- [Custom Terminal Escape Sequences](https://code.visualstudio.com/docs/editor/integrated-terminal#_send-text-from-a-keybinding) and 
- [Debug Style Colors](https://code.visualstudio.com/updates/v1_45#_new-debug-theme-colors)
- `word` separators

```json
 "terminal.integrated.wordSeparators": " ()[]{}',\"`─"
 ```

### Pasting multi-line should be helped/fixed by this binding. 
 - see: <https://en.wikipedia.org/wiki/Control_character>
  
```json
{
    "key": "ctrl+v",
    "command": "workbench.action.terminal.sendSequence",
    "when": "terminalFocus && !accessibilityModeEnabled && terminalShellType == 'pwsh'",
    "args": {
        "text": "\u0016"
    }
}
```
                                     ```