#--------------------------------------------------
#        Type definitions for the LRU cache
#--------------------------------------------------

type LRUCacheEntry*[K, V] = ref object
    key: K
    value: V
    size: int
    next: LRUCacheEntry[K, V]
    prev: LRUCacheEntry[K, V]

type LRUCache*[K, V] = ref object
    sets: tuple[
        maxSize: int,#Max size in bytes
        maxEntries: int#Max number of entries
    ]

    stats: tuple[
        currentBytes: int,#Current size in bytes
        currentEntries: int#Current number of entries
    ]

    entries: Table[K, LRUCacheEntry[K, V]]#Table of entries by key to allow for O(1) lookup
    first: LRUCacheEntry[K, V]#First and last entries in the LRU cache to allow for O(1) removal of the least recently used entry
    last: LRUCacheEntry[K, V]