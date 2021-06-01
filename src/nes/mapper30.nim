# ToDo:
#   1-screen mirroring
#   1-screen mirroring

import types
import bitops

type Mapper30* = ref object of Mapper
  cartridge: Cartridge
  prgBanks, prgBank1, prgBank2: int
  chr: array[0x2000*4, uint8]
  chrBank: int

proc step(m: Mapper) =
  discard

proc idx(m: Mapper, adr: uint16): uint8 =
  var m = Mapper30(m)
  case adr
  of 0x0000..0x1FFF: result = m.cartridge.chr[adr.int]
  of 0x6000..0x7FFF: result = m.cartridge.sram[adr.int - 0x6000]
  of 0x8000..0xBFFF: result = m.cartridge.prg[m.prgBank1*0x4000 + int(adr - 0x8000)]
  of 0xC000..0xFFFF: result = m.cartridge.prg[m.prgBank2*0x4000 + int(adr - 0xC000)]
  else: raise newException(ValueError, "unhandled mapper30 read at: " & $adr)

proc idxSet(m: Mapper, adr: uint16, val: uint8) =
  var m = Mapper30(m)
  case adr
  of 0x0000..0x1FFF:
    m.cartridge.chr[adr.int] = val
    m.chr[m.chrBank*0x2000+adr.int] = val
  of 0x6000..0x7FFF: m.cartridge.sram[adr.int - 0x6000] = val
  of 0x8000..0xFFFF:
    
    var v = val.int
    v.bitslice(0 .. 4)
    v = v mod m.prgBanks
    m.prgBank1 = v
    
    v = val.int
    v.bitslice(5 .. 6)
    v = v mod 4
    m.chrBank = v
    for i in 0..0x1FFF:
      m.cartridge.chr[i] = m.chr[0x2000 * v + i]
    
  else: raise newException(ValueError, "unhandled mapper30 write at: " & $adr)

proc newMapper30*(cartridge: Cartridge): Mapper30 =
  result = Mapper30(
    cartridge: cartridge,
    prgBanks: cartridge.prg.len div 0x4000,
    prgBank1: 0,
    prgBank2: cartridge.prg.len div 0x4000 - 1,
    chrBank: 0,
    step: step,
    idx: idx,
    idxSet: idxSet
  )
  for i in 0..0x2000*4-1:
    result.chr[i]=0


