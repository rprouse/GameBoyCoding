include "utils.inc"

def TILES_COUNT					        equ (384)
def BYTES_PER_TILE				      equ (16)
def TILES_BYTE_SIZE				      equ (TILES_COUNT * BYTES_PER_TILE)
def TILEMAP_BYTE_SIZE			      equ (1024)
def GRAPHICS_DATA_SIZE			    equ (TILES_BYTE_SIZE + TILEMAP_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END	  equ ($8000)
def GRAPHICS_DATA_ADDRESS_START	equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
  ld de, GRAPHICS_DATA_ADDRESS_START
  ld hl, _VRAM8000
.load_tile\@
  ld a, [de]
  inc de
  ld [hli], a
  ld a, d
  cp a, high(GRAPHICS_DATA_ADDRESS_END)
  jr nz, .load_tile\@
endm

;===============================================================================
section "sample", rom0

InitSample:
  LoadGraphicsDataIntoVRAM

  ; Turn the LCD on
  ld a, LCDCF_ON
  ld [rLCDC], a
  ret

UpdateSample:
  ret

export InitSample, UpdateSample

;===============================================================================
section "graphic_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "tileset.chr"
incbin "background.tlm"
