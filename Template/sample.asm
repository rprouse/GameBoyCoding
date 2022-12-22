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

; set all 40 sprites off the screen to start
macro InitSprites
  ld c, OAM_COUNT
  ld hl, _OAMRAM + OAMA_Y
  ld de, sizeof_OAM_ATTRS
.init_oam\@
  ld [hl], 0
  add hl, de
  dec c
  jr nz, .init_oam\@
endm

;===============================================================================
section "sample", rom0

InitSample:
  LoadGraphicsDataIntoVRAM
  InitSprites

  ; Init the background palette
  copy [rBGP], %11100100

  ; Set the sprite palettes
  copy [rOBP0], %11100100
  copy [rOBP1], %00011011

  ; Place the Background on the screen
  copy [rSCX], 96
  copy [rSCY], 64

  ; Place the Window on the screen
  copy [rWX], 7
  copy [rWY], 120

  ; Turn the LCD and background on
  ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
  ld [rLCDC], a

  ; Enable the vblank interupt
  copy [rIE], IEF_VBLANK
  ei
  ret

UpdateSample:
  ; Wait for the vBlank interupt
  halt

  ; Set the first sprite
def SPRITE_0_ADDRESS equ (_OAMRAM)
  copy [SPRITE_0_ADDRESS + OAMA_X], 80
  copy [SPRITE_0_ADDRESS + OAMA_Y], 72
  copy [SPRITE_0_ADDRESS + OAMA_TILEID], 16
  copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

  ; Set the second sprite
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)
  copy [SPRITE_1_ADDRESS + OAMA_X], 136
  copy [SPRITE_1_ADDRESS + OAMA_Y], 78
  copy [SPRITE_1_ADDRESS + OAMA_TILEID], 0
  copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0 | OAMF_XFLIP


  ; Scroll the background
  ; increment [rSCX]
  ; increment [rSCY]
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
