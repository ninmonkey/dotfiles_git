# [1.a] ANSI: Colors. Variables named for semantics, actual color is anything.
C_BLUE='\[\e[34m\]'
C_GREEN='\[\e[32m\]'
C_ORANGE='\[\e[33m\]'
C_RED='\[\e[31m\]'
C_TEAL='\[\e[36m\]'
C_PURPLE='\[\e[35m\]'
C_BOLD_BLUE='\[\e[1;34m\]'

# [1.b] named aliases
C_BAD="$C_RED"
C_GOOD="$C_GREEN"

# [1.c] special codes
C_RESET='\[\e[0m\]'
C_CLEAR="$C_RESET"
PROMPT_USERNAME="🐒" #

# About: tiny. 2 line for a constant cursor location
# Output:
#
#   jb@ nin8 PowerShell
#   $ <cursor>
#
PS1="\n${C_ORANGE}${PROMPT_USERNAME}@ \[\e[32m\]\h ${C_PURPLE}\W${C_BLUE}\n\$ ${C_CLEAR}"

# About: 'tiny' with full path
# Output:
#
#
#   jb@ nin8 ~/Documents/2021/PowerShell
#   $ <cursor>
#
PS1="\n${C_ORANGE}${PROMPT_USERNAME}@ \[\e[32m\]\h \[\e[35m\]\w \n\$ ${C_CLEAR}"

# About: Extra vertical padding for your eyes. full path
#   emphasized current dir
#
# Output:
#
#   ~/Documents/2021/PowerShell
#   jb @ nin8: PowerShell
#   $ <cursor>

PS1="\n\n\n\w\n${C_ORANGE}${PROMPT_USERNAME} @\[\e[32m\] w10: ${C_PURPLE}\W${C_BLUE}\n\$ ${C_CLEAR}"