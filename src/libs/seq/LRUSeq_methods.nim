#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                            Implements the base methods for interfacting with the LRUSeq
#------------------------------------------------------------------------------------------------------------------------------------------------------

proc touch*[K](self: LRUSeq[K], key: K) {.inline.} =
    ## Moves a key to the front of the seq, if it does not exist an error is raised
    when compileOption("boundChecks"):
        if not self.entries.hasKey(key):
            raise newException(KeyError, "Key does not exist in LRUSeq, cannot touch")

    var entry = self.entries[key]

    #If the entry is already at the front there is nothing to do
    if self.first == entry:
        return

    #Unlink the entry from its current position
    if self.last == entry:
        self.last = entry.prev
        entry.prev.next = nil

    else:
        entry.prev.next = entry.next
        entry.next.prev = entry.prev

    #Link the entry in at the front
    entry.prev = nil
    entry.next = self.first
    self.first.prev = entry
    self.first = entry

proc add*[K](self: LRUSeq[K], key: K) {.inline.} =
    ## Adds a key to the seq, if it already exists it is moved to the front of the seq
    ## Raises an error if the seq is full and the key does not already exist in the seq
    if self.entries.hasKey(key):
        var entry = self.entries[key]

        #If the entry is already at the front then do nothing
        if self.first == entry:
            return

        #Otherwise move the entry to the front of the seq
        if self.last == entry:
            self.last = entry.prev
            entry.prev.next = nil

        else:
            entry.prev.next = entry.next
            entry.next.prev = entry.prev

        self.first.prev = entry
        self.first = entry
    
    else:
        if self.currentEntries >= self.maxEntries:
            raise newException(ValueError, "LRUSeq is full, cannot add new key")

        #Create a new entry for the key
        var entry = LRUSeqEntry[K](
            key: key
        )

        #Add the entry to the entries table
        self.entries[key] = entry

        #Update the first/last pointers
        if self.currentEntries > 0:
            self.entries[key].next = self.first
            self.first.prev = self.entries[key]
        else:
            self.last = self.entries[key]
        self.first = self.entries[key]

        self.currentEntries += 1

proc put*[K](self: LRUSeq[K], key: K): tuple[removed: bool, val: K] {.inline.} =
    ## Adds a key to the seq, if it already exists it is moved to the front of the seq
    ## If the seq is full and the key does not already exist in the seq then the least recently used key is removed from the seq and returned
    if self.entries.hasKey(key):
        self.touch(key)
        return (removed: false, val: default(K))

    else:
        #If the seq is full evict the least recently used key to make room for the new key
        if self.currentEntries >= self.maxEntries:
            result = (removed: true, val: self.last.key)
            self.del(self.last.key)

        self.add(key)

proc del*[K](self: LRUSeq[K], key: K) {.inline.} =
    ## Removes a key from the seq if it exists, does nothing if it does not exist
    if not self.entries.hasKey(key):
        return
    
    #If this is the last entry handle this specially as its a simple case
    if self.currentEntries == 1:
        self.first = nil
        self.last = nil
        self.entries.del(key)
        self.currentEntries -= 1
        return
    
    else:
        var entry = self.entries[key]

        #Update the prev/next pointers of the surrounding entries
        if self.first == entry:
            self.first = entry.next
            entry.next.prev = nil            

        elif self.last == entry:#Cant also be the first entry as that is already handled above
            self.last = entry.prev
            entry.prev.next = nil

        else:
            entry.prev.next = entry.next
            entry.next.prev = entry.prev

        #Remove the entry from the entries table
        self.entries.del(key)
        self.currentEntries -= 1

proc hasKey*[K](self: LRUSeq[K], key: K): bool {.inline.} =
    ## Returns true/false indicating if the key exists in the seq
    return self.entries.hasKey(key)

proc clear*[K](self: LRUSeq[K]) =
    self.entries.clear()
    self.currentEntries = 0