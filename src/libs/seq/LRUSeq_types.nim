#--------------------------------------------------
#            Defines types for the LRU seq
#--------------------------------------------------

type LRUSeqEntry[K] = ref object
    key: K
    next: LRUSeqEntry[K]
    prev: LRUSeqEntry[K]

type LRUSeq*[K] = ref object
    maxEntries: int
    currentEntries: int = 0
    
    entries: Table[K, LRUSeqEntry[K]]#Table of entries by key to allow for arbitrary O(1) lookup and removal
    first: LRUSeqEntry[K]
    last: LRUSeqEntry[K]

#------------------------------------------------------------------
#    Types for the equivelent of LRUSeq but allocated on the stack
#------------------------------------------------------------------
type LRUSetEntry[K] = object
    prev: K
    next: K

#Define the type for the LRU set, this functions similarly to the LRUSeq but uses a fixed size allocation
type LRUSet*[K] = object
    maxEntries: int
    currentEntries: int = 0

    entries: Table[K, LRUSetEntry[K]]#Table of entries by key to allow for arbitrary O(1) lookup and removal
    first: K
    last: K
