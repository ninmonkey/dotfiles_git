### About

Quick?-ref for Fzf argument reference

- [About](#about)
- [Basic Invoke](#basic-invoke)
- [Case 1](#case-1)
  - [Summary:](#summary)
- [Case 3](#case-3)
  - [Summary:](#summary-1)
- [Case 2](#case-2)
  - [Summary](#summary-2)
- [Case 1](#case-1-1)
  - [Summary](#summary-3)

### Basic Invoke

```ps1
... | fzf -m
```

```ps1

get-process | % Name | Sort-Object -Unique 
    | fzf -m 

```

### Case 1 

#### Summary: 

- user does not see numbers
- returns the distinct id

```ps1
$names = 'bob', 'jen', 'Alice'
$names  
    | Fmt.Nl 
    | fzf -m --with-nth=2 --delimiter=': '


get-process pwsh | Fmt.Nl id | fzf -m --with-nth=2 --delimiter=': '
```
**Pipeline input**
```ps1
    get-process 'pwsh'
```
**User selects from**
```
    19916
    17584
    12068
    5584
```
**final output**
```
    3: 12068
    6: 25344
```

| What | Value | 
| ---- | ----- |
| Numbers are visible to the User? | false  | 
| Numbers are searched? | false | 
| Text is Searched? | true  | 

### Case 3

#### Summary:

- Only search text
- User sees numbers
- returns distinct id

```ps1
$names = 'bob', 'jen', 'Alice'
$Names
    | Fmt.Nl
    | fzf -m --nth=2 --delimiter=': '
```
**Pipeline input**
```
    bob
    Alice
    jen
```
**User selects from**
```
    3: Alice
    2: jen
    1: bob
```
**final output**
```
    2: jen
```

| What | Value | 
| ---- | ----- |
| Numbers are visible to the User? | true  | 
| Numbers are searched? | true  | 
| Text is Searched? | false  | 
### Case 2

#### Summary 

- only searches numbers, text is excluded
- shows defaults

```ps1
$names = 'bob', 'jen', 'Alice'
    'bob', 'jen', 'Alice'
    | Fmt.Nl
    | fzf -m --nth=1 --delimiter=': '
```

**Pipeline input**

```
    bob
    Alice
    jen
```
**User selects from**
```
    3: Alice
    2: jen
    1: bob
```
**final output**
```
    2: jen
```

| What | Value | 
| ---- | ----- |
| Numbers are visible to the User? | true  | 
| Numbers are searched? | true  | 
| Text is Searched? | false  | 

### Case 1

#### Summary 

- Base behavior, but id's aren't included in search

```ps1
$names = 'bob', 'jen', 'Alice'
$names | Fmt.Nl | fzf -m --nth=2 --delimiter=': '
```
**Pipeline input**
```
    bob
    Alice
    jen
```
**User selects from**
```
    3: Alice
    2: jen
    1: bob
```
**final output**
```
    2: jen
```

| What | Value | 
| ---- | ----- |
| Numbers are visible to the User? | true  | 
| Numbers are searched? | false  | 
| Text is Searched? | true  | 


<!-- $FzfArgs = @(
    '-m'
)

$Selection = @( 
    gci . -file
        | Select -first 10
        | Format.NumberedList -PropertyName Name
        | fzf @FzfArgs
)


 -->


```ps1


'bob', 'jen', 'Alice'

    VisibleNumbers? True
    NumbersArePartOfSearch? False

[input]
    bob'
    Alice'
    jen'

[user selects from]
    3: Alice
    2: jen
    1: bob

[output returns]
    2: jen




'bob', 'jen', 'Alice'
| Fmt.Nl | fzf -m --nth=2 --delimiter=': '

# 'bob', 'jen', 'Alice' | Fmt.Nl | fzf -m --nth=1 --delimiter=': '

```