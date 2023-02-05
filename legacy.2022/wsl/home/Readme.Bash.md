# Old stuff

Ancient settings in: %USERPROFILE%\2021\dotfiles_ancient

# old refs

- https://devhints.io/bash
- https://unix.stackexchange.com/a/390600/19339
- https://kvz.io/blog/2013/11/21/bash-best-practices/
- https://linuxconfig.org/bash-scripting-tutorial-for-beginners

# To create `Examples.raw_ansi`

```bash
export $DEST="/c/Users/cppmo_000/Documents/2021/dotfiles_git/wsl/home/Examples.raw_ansi"
alias sep="echo -e '\n\n# Header ------- \n\n'>>$DEST"

# decent sample dir
cd /g/2021-github-downloads/PowerShell/PowerShell/PowerShell

# usage
sep; ls_date>>$DEST
```