print(
    'See links',
    'https://rich.readthedocs.io/en/latest/introduction.html#rich-in-the-repl',
    'f-string grammar https://docs.python.org/3/reference/lexical_analysis.html#formatted-string-literals',
    sep='\n'
)

print('profile: init -> nin-3-x.py <non-ipython-dotfile> [ $nin_dotfiles/cli/python ] ')
# py3-x
# from pathlib import Path
# import datetime as dt
# from json import dumps, loads

# here: Path = Path('.')

print(
    'Loaded',
    'rich?'
    'pathlib => Path', 'datetime => dt',
    'json => dumps, loads',
    sep='\n'
)

try:
    # now non-standards
    from rich import pretty
    pretty.install()
#     ["rich and pretty", True]
    print( dir(pretty))
except:
    print('rich: module failed to load.')