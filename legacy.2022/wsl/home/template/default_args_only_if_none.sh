# About:
#   if no args are used, run: "ls --color=always"
#   otherwise only use user-specified args
#
# Motivation:
#   default arg aliases can add problems because they are a static
#   replacement, evaluated once. some combinations can break things
#   like [1]: flag 'x' can't be defined while 'y' is
#   or [2]: when argument order: 'x' must occur after 'y'
#   This gives you defaults, without messing up composition

#!/usr/bin/env bash
# minimal "~/.bash_profile" config for waiaas
ls()
{
   if
     (( $# )) # True if at least one argument present
   then
     command ls "$@"
   else
     command ls --color=always
   fi
}

#!/usr/bin/env bash
# minimal "~/.bash_profile" config for waiaas
fd()
{
   if
     (( $# )) # True if at least one argument present
   then
     command fd "$@"
   else
     command fd --max-depth 3
   fi
}
