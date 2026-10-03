#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                Implements alternative interfaces methods for the LRUSet
#------------------------------------------------------------------------------------------------------------------------------------------------------

template incl*[K](self: var LRUSet[K], key: K): untyped =
    ## Adds a key to the set, if it already exists it is moved to the front of the set
    self.put(key)

template excl*[K](self: var LRUSet[K], key: K): untyped =
    ## Removes a key from the set if it exists, does nothing if it does not exist
    self.del(key)

template contains*[K](self: LRUSet[K], key: K): untyped =
    ## Returns true/false indicating if the key exists in the set, allows for if key in cache: syntax to be used
    self.hasKey(key)

template `[]`*[K](self: LRUSet[K], key: K): untyped =
    ## Returns true/false indicating if the key exists in the set, allows for if cache[key]: syntax to be used
    self.hasKey(key)
