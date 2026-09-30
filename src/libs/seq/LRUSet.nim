#------------------------------------------------------------------------------------------------------------------------------------------------------
#                Implements a LRU key tracker that uses a fixed size allocation to avoid frequent memory allocations and deallocations
#                        Functionally identical to the LRUSeq but entries are linked by key rather than by ref so it can live on the stack
#------------------------------------------------------------------------------------------------------------------------------------------------------

#Create an LRUSet with the specified max number of entries, if maxEntries is less than 1 then an exception is raised
proc newLRUSet*[K](maxEntries: int): LRUSet[K] =
    if maxEntries < 1:
        raise newException(ValueError, "maxEntries must be greater than 0")

    result = LRUSet[K](
        maxEntries: maxEntries,
        entries: initTable[K, LRUSetEntry[K]](maxEntries)
    )

proc touch*[K](self: var LRUSet[K], key: K) {.inline.} =
    ## Moves a key to the front of the set, if it does not exist an error is raised
    if not self.entries.hasKey(key):
        raise newException(KeyError, "Key does not exist in LRUSet, cannot touch")

    #If the entry is already at the front there is nothing to do
    if self.first == key:
        return

    #Take a copy of the links as the table slot is modified below
    let entry = self.entries[key]

    #Unlink the entry from its current position
    if self.last == key:
        self.last = entry.prev

    else:
        self.entries[entry.prev].next = entry.next
        self.entries[entry.next].prev = entry.prev

    #Link the entry in at the front, the prev of the first entry is never read so it is left as is
    self.entries[key].next = self.first
    self.entries[self.first].prev = key
    self.first = key

proc add*[K](self: var LRUSet[K], key: K) {.inline.} =
    ## Adds a key to the set, if it already exists it is moved to the front of the set
    ## Raises an error if the set is full and the key does not already exist in the set
    if self.entries.hasKey(key):
        self.touch(key)
        return

    if self.currentEntries >= self.maxEntries:
        raise newException(ValueError, "LRUSet is full, cannot add new key")

    #Create a new entry for the key
    var entry = LRUSetEntry[K]()

    #Update the first/last pointers
    if self.currentEntries > 0:
        entry.next = self.first
        self.entries[self.first].prev = key
    else:
        self.last = key

    #Add the entry to the entries table
    self.entries[key] = entry
    self.first = key

    self.currentEntries += 1

proc del*[K](self: var LRUSet[K], key: K) {.inline.} =
    ## Removes a key from the set if it exists, does nothing if it does not exist
    if not self.entries.hasKey(key):
        return

    #If this is the last entry handle this specially as its a simple case
    if self.currentEntries == 1:
        self.first = default(K)
        self.last = default(K)
        self.entries.del(key)
        self.currentEntries -= 1
        return

    else:
        let entry = self.entries[key]

        #Update the prev/next pointers of the surrounding entries
        if self.first == key:
            self.first = entry.next

        elif self.last == key:#Cant also be the first entry as that is already handled above
            self.last = entry.prev

        else:
            self.entries[entry.prev].next = entry.next
            self.entries[entry.next].prev = entry.prev

        #Remove the entry from the entries table
        self.entries.del(key)
        self.currentEntries -= 1

proc put*[K](self: var LRUSet[K], key: K): tuple[removed: bool, val: K] {.inline.} =
    ## Adds a key to the set, if it already exists it is moved to the front of the set
    ## If the set is full and the key does not already exist in the set then the least recently used key is removed from the set and returned
    if self.entries.hasKey(key):
        self.touch(key)
        return (removed: false, val: default(K))

    else:
        #If the set is full evict the least recently used key to make room for the new key
        if self.currentEntries >= self.maxEntries:
            #Copy the key out first as del updates self.last while it runs
            let evicted = self.last
            result = (removed: true, val: evicted)
            self.del(evicted)

        self.add(key)

proc hasKey*[K](self: LRUSet[K], key: K): bool {.inline.} =
    ## Returns true/false indicating if the key exists in the set
    return self.entries.hasKey(key)

proc clear*[K](self: var LRUSet[K]) =
    self.entries.clear()
    self.first = default(K)
    self.last = default(K)
    self.currentEntries = 0
