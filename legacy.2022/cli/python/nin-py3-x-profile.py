from pathlib import Path
from json import dumps, loads
here: Path = Path('.')

print(
    'See links',
    'https://rich.readthedocs.io/en/latest/introduction.html#rich-in-the-repl',
    'f-string grammar https://docs.python.org/3/reference/lexical_analysis.html#formatted-string-literals',
    sep='\n'
)

# see more
print('profile: init -> nin-3-x.py <non-ipython-dotfile> [ $nin_dotfiles/cli/python ] ')
# py3-x
# from pathlib import Path
# import datetime as dt


print(
    'Loaded',
    'rich?'
    'pathlib => Path', 'datetime => dt',
    'json => dumps, loads',
    sep='\n'
)


from requests import request

try:
    # now non-standards
    from rich import pretty, inspect
    from rich.panel import Panel
    pretty.install()
#     ["rich and pretty", True]
    from rich import print as rprint

    if "DoNotShadow":
        from rich import print

except:
    print('rich: module failed to load.')



print("Todo: make ctrl+w / ctrl+a work")

print("[italic red]Hello[/italic red] World!", locals())
rprint("[italic red]Hello[/italic red] World!", locals())