import ../nes

# ToDo:
#   State of Cartridge and Mapper is missing, a bit ugly to add
#   Save slot selection
#   Save to file
#   Battery save

const nStates = 10

type SaveState* = ref object
  states: array[nStates, NESObj]
  pos*: int
  stored: int
  stateExists: array[nStates, bool]

proc newSaveState*: SaveState =
  new result
  result.stateExists[0] = false
  result

proc empty*(r: SaveState): bool =
  r.stateExists[r.pos] != true

proc load*(r: var SaveState): NESObj = # This may be slow and need a popInto()
  if r.stateExists[r.pos] == true:
    copyMem(addr result, addr r.states[r.pos], sizeof(result))

proc save*(r: var SaveState, c: var NESObj) =
  copyMem(addr r.states[r.pos], addr c, sizeof(c))
  r.stateExists[r.pos] = true
