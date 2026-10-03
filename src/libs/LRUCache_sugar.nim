#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                Implement alternative interface methods for the LRUCache
#------------------------------------------------------------------------------------------------------------------------------------------------------

#Implement alternative interface methods for allowing an interface similar to a dict/table
macro `[]`*[K, V](self: LRUCache[K, V], key: K): untyped =
    result = newStmtList()  

    result.add quote do:
        when compileOption("boundChecks"):
            if not self.entries.hasKey(key):
                raise newException(KeyError, "Key not found in cache")

        self.entries[key].value

macro `[]=`*[K, V](self: LRUCache[K, V], key: K, value: V): untyped =
    result = quote do:
        self.set(key, value)

