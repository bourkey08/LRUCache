#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                Implements alternative interfaces methods for the LRUSeq
#------------------------------------------------------------------------------------------------------------------------------------------------------

template incl*[K](self: LRUSeq[K], key: K): untyped =
    ## Adds a key to the seq, if it already exists it is moved to the front of the seq
    self.put(key)

template excl*[K](self: LRUSeq[K], key: K): untyped =
    ## Removes a key from the seq if it exists, does nothing if it does not exist
    self.del(key)

template contains*[K](self: LRUSeq[K], key: K): untyped =
    ## Returns true/false indicating if the key exists in the seq, allows for if key in cache: syntax to be used
    self.hasKey(key)

template `[]`*[K](self: LRUSeq[K], key: K): untyped =
    ## Returns true/false indicating if the key exists in the seq, allows for if cache[key}: syntax to be used
    self.hasKey(key)