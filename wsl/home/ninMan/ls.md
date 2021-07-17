# About:

Experimenting with a man-page abbreviation syntax.

# sketch3

```yaml
sort:   <enum>
    size (-S), time (-t), extension (-X), none (-U), version (-v)
time:   <enum>
    atime (-u), ctime (-c), creation
bools:
    --group-directories-first, --almost-all, --human-readable, --inode, --literal
tabsize: <int> # column widths
width: <int>
```
# sketch2

```yaml
sort:
    size (-S) | time (-t) | extension (-X) | none (-U) | version (-v)
time:
    atime (-u), ctime (-c), creation
format:
    across -x | commas -m | horizontal -x | long -l | single-column -1 | verbose -l | vertical -C
bools:
    --group-directories-first, --almost-all, --human-readable, --inode, --literal
tabsize: <int>
width: <int>
```
```yaml


time: <alias>
    access time (-u):
        atime, access, use;
    change time (-c):
        ctime, status;
    birth time:
        birth, creation;

```
