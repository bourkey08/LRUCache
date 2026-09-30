#------------------------------------------------------------------------------------------------------------------------------------------------------
#        Implements a simple LRU key tracker for tracking keys and the order they should be evicted from an external cache or other data structure
#------------------------------------------------------------------------------------------------------------------------------------------------------

include "./LRUSeq_types.nim"
include "./LRUSeq_methods.nim"
include "./LRUSeq_sugar.nim"
include "./LRUSet.nim"
include "./LRUSet_sugar.nim"

#Create an LRUSeq with the specified max number of entries, if maxEntries is less than 1 then an exception is raised
proc newLRUSeq*[K](maxEntries: int): LRUSeq[K] =
    if maxEntries < 1:
        raise newException(ValueError, "maxEntries must be greater than 0")

    result = LRUSeq[K](
        maxEntries: maxEntries,
        entries: initTable[K, LRUSeqEntry[K]](maxEntries)
    )