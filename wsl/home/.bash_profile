#!/usr/bin/env bash
#!/bin/bash
# About: New profile from scratch for: NIN10 on 2021-07-11

# export LC_ALL="UTF8" ?
export PYTHONIOENCODING="utf-8:strict"
# from git-bash:
export BROWSER='/c/Program Files/Mozilla Firefox/firefox.exe'

# [1] Section: default args
alias grep="grep --perl-regexp --ignore-case" # -iP # insensitive, PCRE2
alias less='less --RAW-CONTROL-CHARS' # good for --color=always
alias ls_date="ls -l --sort=time --time-style=+%G/%m/%d --human-readable --color=always"
alias lsd="fd --type d"
alias lsf="fd --type f"

# [3] Section: git
# overly-fancy visual branch rendering rendering
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# toggle prompt
export NIN_DOTFILES="/c/Users/cppmo_000/Documents/2021/dotfiles_git"
. "${NIN_DOTFILES}/wsl/home/template/prompt_color.sh"
