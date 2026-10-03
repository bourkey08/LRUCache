#------------------------------------------------------------------------------------------------------------------------------------------------------
#                            Implements helper functions used by the LRU cache implementation that are not exposed publicly
#------------------------------------------------------------------------------------------------------------------------------------------------------

#As the functions below need the same delete logic as the del proc but cannot call it if the del proc is inlined the delete logic is seperated out into a macro
macro deleteMethodLogic[K, V](self: LRUCache[K, V], key: K): untyped = 
    result = quote do:
        if not `self`.entries.hasKey(`key`):
            return

        var entry = `self`.entries[`key`]

        #Update the prev/next pointers of the surrounding entries
        #Handle the prev entry if this is not the first entry
        if entry.prev != nil:#Has a previous entry
            entry.prev.next = entry.next#Update the previous entry to skip this entry
        else:
            if entry.next != nil:#This was the first entry in the cache, update the first ptr
                `self`.first = entry.next
            else:
                `self`.first = nil#This was the only entry in the cache, clear the first ptr
                `self`.last = nil#This was the only entry in the cache, clear the last ptr

        #Handle the next entry if this is not the last entry
        if entry.next != nil:#Has a next entry
            entry.next.prev = entry.prev#Update the next entry to skip this entry
        else:
            `self`.last = entry.prev#This was the last entry in the cache, update the last ptr

        #Update the stats
        `self`.stats.currentEntries -= 1
        if `self`.sets.maxSize > 0:#Only update the max size if a limit is specified as this requires the value have a size method
            `self`.stats.currentBytes -= entry.size

        #Finally remove the entry from the table
        `self`.entries.del(`key`)

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
            self.deleteMethodLogic(self.last.key)
        else:
            raise newException(ValueError, "Cache is full and cannot free up space for new entry")
