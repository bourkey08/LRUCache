#------------------------------------------------------------------------------------------------------------------------------------------------------
#                            Implements helper functions used by the LRU cache implementation that are not exposed publicly
#------------------------------------------------------------------------------------------------------------------------------------------------------

#Returns true/false indicating if there is space in the cache for a new entry of a given size
func hasFreeSpace[K, V](self: LRUCache[K, V], size: int = 0): bool =
    #Only apply the size check if its enabled 
    if self.sets.maxSize > 0:
        if self.stats.currentBytes + size > self.sets.maxSize:
            return false
    
    if self.sets.maxEntries > 0:
        if self.stats.currentEntries >= self.sets.maxEntries:
            return false

    return true 

#Called to free up enough space in the cache to add a new entry of a given size
func freeSpace[K, V](self: LRUCache[K, V], size: int = 0) =
    while not self.hasFreeSpace(size):
        #Remove the last entry in the cache
        if self.last != nil:
            self.del(self.last.key)
        else:
            raise newException(ValueError, "Cache is full and cannot free up space for new entry")
