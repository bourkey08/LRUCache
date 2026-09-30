#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                Implements the externally exposed methods for creation and manipulation of the LRU cache.
#------------------------------------------------------------------------------------------------------------------------------------------------------

## Constructor for the LRU cache object
## maxSize can be specified as a binary units string (e.g. 1MB, 1GB) or as an integer number of bytes, maxEntries is specified as an integer number of entries
proc newLRUCache*[K, V](maxSize: int|string = -1, maxEntries: int = -1): LRUCache[K, V] = 
    #Handle max size being passed as a binary units string
    when maxSize is string:
        var mSize = parseBinaryUnits(maxSize)
    else:
        var mSize = maxSize
    var mEntries = maxEntries

    #Ensure that at least one of maxSize or maxEntries is specified
    if mSize <= 0 and mEntries <= 0:
        raise newException(ValueError, "Either maxSize or maxEntries must be specified")
    if mSize <= 0:
        mSize = -1
    if mEntries <= 0:
        mEntries = -1

    result = LRUCache[K, V](
        sets: (mSize, mEntries),
        stats: (0, 0),
        entries: initTable[K, LRUCacheEntry[K, V]](),
    )

## Add a new entry to the cache evicting as necessary, if the key already exists in the cache then its value is updated
proc put*[K, V](self: LRUCache[K, V], key: K, value: V) =
    #Check if there is sufficent space in the cache for the new entry and if not free up space as nessary
    var entrySize = 0
    if self.sets.maxSize > 0:
        when compiles(value.size):
            entrySize = value.size
        else:
            raise newException(ValueError, "Value type does not have a size method, cannot use maxSize limit")

    #Ensure there is space in the cache for the new entry if not free up space as necessary
    self.freeSpace(entrySize)

    #Check if the key already exists in the cache and if so update its value and then move it to the front of the LRU list
    if self.entries.hasKey(key):
        #Calculate the change in entry size if enabled
        if self.sets.maxSize > 0:
            when compiles(value.size):
                let newSize = value.size
                let sizeChange = newSize - self.entries[key].size
                self.stats.currentBytes += sizeChange
                self.entries[key].size = newSize
            else:
                raise newException(ValueError, "Value type does not have a size method, cannot use maxSize limit")

        self.entries[key].value = value
        self.touch(key)
        return
    #Create the new entry
    var entry = LRUCacheEntry[K, V](
        key: key,
        value: value,
    )

    #Store the entry in the table and then update the prev/next pointers
    self.entries[key] = entry

    if self.stats.currentEntries > 0:
        self.entries[key].next = self.first
        self.first.prev = self.entries[key]
    else:
        self.last = self.entries[key]    
    self.first = self.entries[key]

    #Update the stats
    self.stats.currentEntries += 1    
    if self.sets.maxSize > 0:#Only update the max size if a limit is specifieds as this requires the value have a size method
        when compiles(value.size):
            entry.size = value.size
            self.stats.currentBytes += entry.size
        else:
            raise newException(ValueError, "Value type does not have a size method, cannot use maxSize limit")

## Touches a key in the cache, moving it to the front of the lru list without returning its value, does nothing if the key does not exist
proc touch*[K, V](self: LRUCache[K, V], key: K) =
    if not self.entries.hasKey(key):
        return

    var entry = self.entries[key]

    #If the entry is already the first entry then do nothing
    if entry == self.first:
        return

    #Update the prev/next pointers of the surrounding entries
    if entry.next != nil:#Has a next entry
        entry.prev.next = entry.next#Update the previous entry to skip this entry

        #If this is not the last entry then also update the next entry to skip this entry
        if self.last != entry:
            entry.next.prev = entry.prev
    else:
        entry.prev.next = nil#Clear the previous entrys next ptr
    
    #Now update this entrys pointers to place it at the start of the list
    entry.next = self.first
    entry.prev = nil
    
    #Update the first entry and the list first ptr
    if self.first != entry:
        self.first.prev = entry
        self.first = entry

## Retreives the value for the given key from the cache, does not check if it exists first
proc get*[K, V](self: LRUCache[K, V], key: K): V =
    if not self.entries.hasKey(key):
        raise newException(KeyError, "Key not found in cache")

    result = self.entries[key].value

    #Move the entry to the front of the LRU list
    self.touch(key)

## Returns true/false indicating if the key exists in the cache
proc hasKey*[K, V](self: LRUCache[K, V], key: K): bool =
    return self.entries.hasKey(key)

## Alias for hasKey, allows for key in cache syntax to be used
proc contains*[K, V](self: LRUCache[K, V], key: V): bool =
    return self.entries.hasKey(key)

## Removes an entry from the cache if it exists, does nothing if it does not exist
proc del*[K, V](self: LRUCache[K, V], key: K) =
    if not self.entries.hasKey(key):
        return

    var entry = self.entries[key]

    #Update the prev/next pointers of the surrounding entries
    #Handle the prev entry if this is not the first entry
    if entry.prev != nil:#Has a previous entry
        entry.prev.next = entry.next#Update the previous entry to skip this entry
    else:
        if entry.next != nil:#This was the first entry in the cache, update the first ptr
            self.first = entry.next
        else:
            self.first = nil#This was the only entry in the cache, clear the first ptr
            self.last = nil#This was the only entry in the cache, clear the last ptr

    #Handle the next entry if this is not the last entry
    if entry.next != nil:#Has a next entry
        entry.next.prev = entry.prev#Update the next entry to skip this entry
    else:
        self.last = entry.prev#This was the last entry in the cache, update the last ptr

    #Update the stats
    self.stats.currentEntries -= 1
    if self.sets.maxSize > 0:#Only update the max size if a limit is specified as this requires the value have a size method
        self.stats.currentBytes -= entry.size

    #Finally remove the entry from the table
    self.entries.del(key)

##Destroys the cache and frees all memory used by it
proc destroy*[K, V](self: LRUCache[K, V]) =
    #Clear the table of entries
    self.entries.clear()

    #Clear the first and last pointers
    self.first = nil
    self.last = nil

    #Reset the stats
    self.stats.currentBytes = 0
    self.stats.currentEntries = 0

