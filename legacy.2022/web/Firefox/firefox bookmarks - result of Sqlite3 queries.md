- [Example (from docs)](#example-from-docs)
- [Buffer](#buffer)
  - [Most Visited](#most-visited)
- [Current config](#current-config)
  - [main](#main)
  - [still todo:](#still-todo)
  - [All bookmarts tagged `todo_2021-03`, sorted by most recently created](#all-bookmarts-tagged-todo_2021-03-sorted-by-most-recently-created)
  - [try tag search:](#try-tag-search)
    - [iter1](#iter1)
    - [ITER2](#iter2)
    - [ITER3](#iter3)
- [Arg docs:](#arg-docs)
  - [`queryType` = `<int>`](#querytype--int)
  - [`type` = `<int>`](#type--int)
  - [`sort` = `<int>`](#sort--int)
  - [`parent` = `<string>`](#parent--string)

bookmark is sql query

place:folder=BOOKMARKS_MENU&folder=UNFILED_BOOKMARKS&folder=TOOLBAR&queryType=1&sort=12&maxResults=10&excludeQueries=1


## docs:

archived on wayback:
- <https://web.archive.org/web/20190929202307/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_query_URIs>
- <https://web.archive.org/web/20190929203327/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places>
- <https://web.archive.org/web/20191004145824/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Querying>
- <https://web.archive.org/web/20191004045704/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Using_the_Places_history_service>
- <https://web.archive.org/web/20200621121524/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_Developer_Guide>
- <https://web.archive.org/web/20190930123750/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Using_the_Places_keywords_API>
- <https://web.archive.org/web/20191009102559/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Retrieving_part_of_the_bookmarks_tree>

- <https://web.archive.org/web/20190929202307/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_query_URIs>
- <https://web.archive.org/web/20190929203327/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places>
- <https://web.archive.org/web/20190930123750/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Using_the_Places_keywords_API>
- <https://web.archive.org/web/20191004045704/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Using_the_Places_history_service>
- <https://web.archive.org/web/20191004145824/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Querying>
- <https://web.archive.org/web/20191004172423/https://developer.mozilla.org/en-US/docs/Mozilla/Displaying_Place_information_using_views>
- <https://web.archive.org/web/20191006174624/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_utilities_for_JavaScript>
- <https://web.archive.org/web/20191007005101/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Manipulating_bookmarks_using_Places>
- <https://web.archive.org/web/20191008024821/https://developer.mozilla.org/en-US/docs/Mozilla/Displaying_Place_information_using_views>
- <https://web.archive.org/web/20191009102559/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Retrieving_part_of_the_bookmarks_tree>
- <https://web.archive.org/web/20200621121524/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/Places_Developer_Guide>
- <https://web.archive.org/web/20210121193337/https://developer.mozilla.org/en-US/docs/Mozilla/Tech/Places/places.sqlite_Database_Troubleshooting>

# Example (from docs)

```js
place:folder=BOOKMARKS_MENU&
folder=UNFILED_BOOKMARKS&
folder=TOOLBAR&
queryType=1&
sort=12&
maxResults=10&
excludeQueries=1

place:folder=BOOKMARKS_MENU&
folder=UNFILED_BOOKMARKS&
folder=TOOLBAR&
queryType=1&
sort=12&
maxResults=10&
excludeQueries=1
```
# Buffer

## Most Visited

```js
place:queryType=0&sort=8&maxResults=30
```

# Current config

## main

```yml
name:  for → Dad
query: place:sort=12&tag=for dad&maxResults=30&excludeQueries=1
sortby: most recently added
```

## still todo:

- [ ] display last `n` pages `visited`
- [ ] display last `n` pages `bookmarked`
- [ ] display last `n` pages `bookmarked` tagged as `power bi` or `DAX`
- [ ] display last `n` pages `visted` specifically on domain (`reddit.com` or `stackoverflow.com`)
- [ ] display tagged as `todo_2021-03` **OR** `todo_2021_04`


## All bookmarts tagged `todo_2021-03`, sorted by most recently created
```
place:
sort=12&
tag=todo_2021-03&
maxResults=30&
excludeQueries=1
```

## try tag search:

### iter1
```js
place:folder=BOOKMARKS_MENU&
folder=UNFILED_BOOKMARKS&
folder=TOOLBAR&
queryType=1&
sort=12&
tag=todo_2021-03&
maxResults=30&
excludeQueries=1

place:folder=BOOKMARKS_MENU&folder=UNFILED_BOOKMARKS&folder=TOOLBAR&queryType=1&sort=12&tag=todo_2021-03&maxResults=30&excludeQueries=1
```
### ITER2

- sort12: most recently added
- queryType=
```js
place:folder=BOOKMARKS_MENU&
folder=UNFILED_BOOKMARKS&
folder=TOOLBAR&
sort=12&
tag=todo_2021-03&
maxResults=30&
excludeQueries=1
```
### ITER3

**Currently returns identical results as `ITER2`**

- try no hard coded folders, just tags?
- sort12: most recently added
- queryType=

```js
place:
sort=12&
tag=todo_2021-03&
maxResults=30&
excludeQueries=1
```

# Arg docs:

## `queryType` = `<int>`

```md
queryType 	unsigned short 	The type of search to use when querying the database. This attribute is only honored by query nodes. It's ignored for simple folder queries.

0
    History
1
    Bookmarks
```

## `type` = `<int>`

```md
e 	unsigned short 	The type of results to return.

0
    Results as URI ("URI" results, one for each URI visited in the range).
1
    Results as visit ("visit" results, with one for each time a page was visited
    this will often give you multiple results for one URI).
2
    Results as full visits (like "visit", but returns all attributes for each result)
3
    Results as date query (returns results for given date range)
4
    Results as site query (returns last visit for each url in the given host)
5
    Results as date+site query (returns list of hosts visited in the given period)
6
    Results as tag query (returns list of bookmarks with the given tag)
7
    Results as tag container (returns bookmarks with given tag; for same uri uses last modified. folder=tag_folder_id must be present in the query
```

## `sort` = `<int>`

```md
sort 	unsigned short 	The sort order to use for the results.

0
    Natural bookmark order
1
    Sort by title, A-Z
2
    Sort by title, Z-A
3
    Sort by visit date, most recent last
4
    Sort by visit date, most recent first
5
    Sort by uri, A-Z
6
    Sort by uri, Z-A
7
    Sort by visit count, ascending
8
    Sort by visit count, descending
9
    Sort by keyword, A-Z
10
    Sort by keyword, Z-A
11
    Sort by date added, most recent last
12
    Sort by date added, most recent first
13
    Sort by last modified date, most recent last
14
    Sort by last modified date, most recent first
17
    Sort by tags, ascending
18
    Sort by tags, descending
19
    Sort by annotation, ascending
20
    Sort by annotation, descending
```

## `parent` = `<string>`

```md
parent 	string
The GUID of the parent folder to query. This may be one of the following (note: there should be 12 characters in the GUID):

root________
    The root of the places tree - i.e. all the stored bookmarks.
menu________
    The Bookmarks menu.
toolbar_____
    The bookmarks toolbar.
mobile______
    The mobile bookmarks folder.
unfiled_____
    The unfiled bookmarks folder.
```