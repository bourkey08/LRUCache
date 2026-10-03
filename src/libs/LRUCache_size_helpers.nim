#------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                        Implements size methods for base types
#------------------------------------------------------------------------------------------------------------------------------------------------------

func size(self: string|seq[byte]|seq[char]): int {.inline.} = 
    result = sizeof(self) + self.len

func size(self: SomeInteger|SomeFloat): int {.inline.} =
        result = sizeof(self)

func size(self: openArray[byte|char]): int {.inline.} =
    result = sizeof(self) + self.len

func size(self: openArray[uint8|int8]): int {.inline.} =
    result = sizeof(self) + self.len

func size(self: openArray[uint16|int16]): int {.inline.} =
    result = sizeof(self) + self.len * 2

func size(self: openArray[uint32|int32|float32]): int {.inline.} =
    result = sizeof(self) + self.len * 4

func size(self: openArray[uint64|int64|float64]): int {.inline.} =
    result = sizeof(self) + self.len * 8

func size(self: openArray[int|float|uint]): int {.inline.} =
    result = sizeof(self) + self.len * sizeof(int)