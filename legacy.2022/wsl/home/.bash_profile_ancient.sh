#!/usr/bin/env bash
#!/bin/bash
# About: New profile from scratch for: NIN10 on 2021-07-11
alias example_="env | grep -P '(?P<match>^[\w]*=.{10})' --only-matching --color=always --line-number --byte-offset --label=stdin --with-filename"

# export LC_ALL="UTF8" ?
export PYTHONIOENCODING="utf-8:strict"
export BROWSER='C:/Program Files/Mozilla Firefox/firefox.exe'

# [1] Section: core default args
alias grep="grep -iP" # insensitive, PCRE2

# [2] Section: custom variants

# Files/ Dirs directories only
alias lsd="fd --type d"
alias lsf="fd --type f" # Show files only,
alias ls_date="ls -l --sort=time --time-style=+%G/%m/%d --human-readable --color=always"
# fancy visual branch rendering rendering
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

alias ex_ls1="ls --size -C --human-readable --group-directories-first --color=always"
alias ex_ls2="ls --size -C --human-readable --no-group --sort=time --color=always"


# output: -rwxr-xr-x 1 cppmo_000 197609 1.1K 2021/07/08  cheatsheets


#alias ls="ls -Ssh1"
#alias ls2="ls --human-readable --group-directories-first --classify --color=always --show-control-chars"
#alias ls_sort_ext="ls --sort=extension --human-readable --color=always"
#alias ls_sort_time="ls --sort=time --human-readable --color=always"
#alias ls_sort_size="ls --sort=size --human-readable --color=always"

#alias ll="ls --time-style=+%G/%m/%d"
alias la="ls --almost-all --human-readable --classify --color=always"
alias pyg="pygmentize"

ca="--color=always"
cn="--color=never"
ca="--color=auto"
# usage:
#   grep -i 'foo' $ca | less -R

# ====== [4.3] `less`
# note, instead of `lessoff`, use `\less`
# alias lessoff='less'
alias less='less --RAW-CONTROL-CHARS'
# alias lend='less -R +G' # start at bottom, redundant with hotey?

# ====== [4.4] `grep`
# alias grepi='grep -i '
# alias egrepi='egrep -i '
#alias cgrep="color_grep"
#alias grep="echo 'use ripgrep!'"
alias grep="grep --color=auto"
alias example_grep_all_options="env | grep -P '(?P<match>^[\w]*=.{10})' --only-matching --color=always --line-number --byte-offset --label=stdin --with-filename"
alias example_grep_all_options="env | grep -P '(?P<match>^[\w]*=.{10})' --only-matching --color=always --line-number --byte-offset --label=stdin --with-filename"

# ====== [4.5] misc
alias history="history | less +G"
alias histend="history_end"
alias python="winpty ipython.exe --profile=ninmonkey" # needed by some win32 terminals.
alias ipython="winpty ipython.exe --profile=ninmonkey" # needed by some win32 terminals.
alias ls_alias="alias | grep -i 'alias\s*ls\w*' --color=always"
alias ww="which_where"
alias mypynin="mypy --disallow-untyped-defs"

# lets you preview `!!` and `!-4` and `!vim` if you type `<space>`
# *before* enter, so you can view and cancel it with `<ctrl+c>`
bind Space:magic-space

# ====== [4.6] misc
# requires magic to work "well". Best off just writing a better python script, or modern  shell
#alias ca="color_always"
#alias coff="color_never"
#alias cauto="color_auto"
alias everything="/c/Program Files/Everything/Everything.exe"

# ==== [.] refactor using a bookmark system
    # or refactor into a single function, with names like "rust" that autocomplete

# not running right
# . "$(cd /C/Users/cppmo_000/Documents/2019/python)"

# ====== [4.7] `cd` fav directories
alias cddocs="cd ~/Documents"
alias cd2019="cd ~/Documents/2019"
alias cdpy="cd ~/Documents/2019/python"
alias cdjsPoC="cd ~/Documents/2019/JavaScript/PoC/"
alias cdrust="cd ~/Documents/2019/rust"
alias cdnin="cd ~/Documents/2019/ninmonkeys.com"
alias cdwriting="cd ~/Documents/2019/writing"
alias cdexcel="cd ~/Documents/2019/Excel"
alias cdpowerbi="cd ~/Documents/2019/Power BI"
alias cddownloads="cd ~/Downloads"
alias cdpybin="cd ~/Documents/2019/python/pybin_PoC"
alias cdbash="cd ~/Documents/2019/BASH\ and\ Shell\ Commands/bash-PoC"
alias cdselfgit="cd ~/Documents/2019/db_self_git"

# dsfoijdsf
# dsfdsd
# something like:
# alias npm="winpty node.cmd"

## tip: pattern on less
# `foo --help | less pattern=arg`

# ==== [4.8] function aliasing
alias web="launch_browser"
#if [ $NIN_USING_WINDOWS = true ]; then
#    alias man="windows_display_manpage"
    # alias manw="display_manpage --web"
#    alias man="less --help | grep -iE '\b*\-{1,2}[\a-]*' --color=always"
#fi
# alias google="wip: searches google"alias pydoc="python -c 'import unicodedata as ud; help(ud)' | less"
alias example_pydoc="python -c 'import unicodedata as ud; help(ud)' | less"


echo 'Make opt-module for aliases to winpty to fix msys bug on win32'

echo '[] term: MOTD : word of the day'
echo '[] term: MOTD : PRAW quote'
echo '[] stats processed since yesterday ie process list ech'
echo 'ipy: export_table_to_excel() and print_table()'
# grep --help | grep -iP 'NUM' --color=always | less --pattern=NUM

echo 'to fix "not-tty" error, use: winpty -Xallow-non-tty python --help | less'

alias ttyfix="winpty -Xallow-non-tty "


echo 'do locale UTF8, etc ENV VARs'
# hard-coded-ip: alias rpi2='winpty ssh pi@192.168.50.106'
# self-exposed-name
alias rpiwinpty="winpty ssh pi@raspberrypi.local"
alias rpi="ssh pi@raspberrypi.local"

#alias winptycolorizemypy="winpty -Xallow-non-tty python colorize_mypy.py"
alias ninmypy="cat colorize_backup.sample.log | winpty -Xallow-non-tty python colorize_mypy.py"
PS1="\n${NIN_MONKEY}@\[\e[32m\]\h \[\e[35m\]\w \n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10 \[\e[35m\]\W>\n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10 \[\e[35m\]${C_BLUE}\W>\n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10 \[\e[35m\]${C_RED}\W>\n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10 \[\e[35m\]${C_BLUE}\W>\n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10 \[\e[35m\]\W>\n\$ ${C_CLEAR}"
PS1="\n\n\n|${C_ORANGE}|${NIN_MONKEY} @\[\e[32m\] w10 | ${C_PURPLE}\W||${C_BLUE}\n\$ ${C_CLEAR}"
PS1="\n\n\n\w\n${C_ORANGE}${NIN_MONKEY} @\[\e[32m\] w10: ${C_PURPLE}\W${C_BLUE}\n\$ ${C_CLEAR}"
PS1="\n\n\n${C_ORANGE}nin@\[\e[32m\] w10: ${C_PURPLE}\W${C_BLUE}\n\$ ${C_CLEAR}"
alias bash="winpty bash"

alias test_enc="python -c \"import sys; print(f'encodings:\n  stdout: {sys.stdout.encoding}\n  stdin:  {sys.stdin.encoding}\n  stderr: {sys.stdout.encoding}')\""

PS1_MINIMAL="\n\033[32m\]nin8\033[0m\]\n$ "
PS1=$PS1_MINIMAL
echo 'PS1 set to minimal'

test_enc

export TERM_OLD="$TERM"
export TERM="xterm-256color"
alias grep='grep --color=always'
