include "utils.inc"

def TILES_COUNT					        equ (384)
def BYTES_PER_TILE				      equ (16)
def TILES_BYTE_SIZE				      equ (TILES_COUNT * BYTES_PER_TILE)
def TILEMAPS_COUNT              equ (2)
def BYTES_PER_TILEMAP           equ (1024)
def TILEMAPS_BYTE_SIZE			    equ (TILEMAPS_COUNT*BYTES_PER_TILEMAP)
def GRAPHICS_DATA_SIZE			    equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
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
  ; Init the palette
  ld a, %11100100
  ld [rBGP], a

  LoadGraphicsDataIntoVRAM

  ; Place the Background on the screen
  ld a, 96
  ld [rSCX], a
  ld a, 64
  ld [rSCY], a

  ; Place the Window on the screen
  ld a, 7
  ld [rWX], a
  ld a, 120
  ld [rWY], a

  ; Turn the LCD and background on
  ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
  ld [rLCDC], a

  ; Enable the vblank interupt
  ld a, IEF_VBLANK
  ld [rIE], a
  ei
  ret

UpdateSample:
  ; Wait for the vBlank interupt
  halt

  ; Scroll the background
  ; ld a, [rSCX]
  ; inc a
  ; ld [rSCX], a
  ; ld a, [rSCY]
  ; inc a
  ; ld [rSCY], a
  ret

export InitSample, UpdateSample

;===============================================================================
section "vblank_interupt", rom0[$0040]
  reti

;===============================================================================
section "graphic_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "tileset.chr"
incbin "background.tlm"
incbin "window.tlm"
