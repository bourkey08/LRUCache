#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                            Implements a LRU cache in nim
#------------------------------------------------------------------------------------------------------------------------------------------------------

when not defined(doc):
    import std/[tables, strutils, math, macros]

include "./libs/LRUCache_utils.nim"
include "./LRUCache_types.nim"
include "./libs/LRUCache_helpers.nim"
include "./libs/LRUCache_methods.nim"
include "./libs/seq/LRUSeq.nim"
