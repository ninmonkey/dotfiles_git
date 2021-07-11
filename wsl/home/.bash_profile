#!/usr/bin/env bash
#!/bin/bash
# About: New profile from scratch for: NIN10 on 2021-07-11

# export LC_ALL="UTF8" ?
export PYTHONIOENCODING="utf-8:strict"
export BROWSER='C:/Program Files/Mozilla Firefox/firefox.exe'

# [1] Section: core default args
alias grep="grep -iP"
alias less='less --RAW-CONTROL-CHARS' # if you want to default to using colors

# [2] Section: custom variants
alias ls_date="ls -l --sort=time --time-style=+%G/%m/%d --human-readable --color=always"

# [3] Section: git
# fancy visual branch rendering rendering
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
