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

rsset _RAM

; Set if the current interupt is VBLANK
WRAM_IS_VBLANK        rb 1

; Input struct
WRAM_PAD_INPUT        rb sizeof_PAD_INPUT

; Background scrolling
WRAM_BG_SCX           rb 1
WRAM_BG_SCY           rb 1

; Window control
WRAM_WIN_ENABLE_FLAG  rb 1

WRAM_END              rb 0

def WRAM_USAGE        equ (WRAM_END - _RAM)
println "WRAM usage: {d:WRAM_USAGE} bytes"
assert WRAM_USAGE <= $2000, "WRAM space exceeded"

;===============================================================================
section "sample", rom0

InitSample:
  ; Init the WRAM state
  InitPadInput WRAM_PAD_INPUT
  copy [WRAM_WIN_ENABLE_FLAG], LCDCF_WINON
  copy [WRAM_BG_SCX], 96
  copy [WRAM_BG_SCY], 64
  copy [WRAM_IS_VBLANK], 0

  LoadGraphicsDataIntoVRAM
  InitSprites

  ; Init the background palette
  copy [rBGP], %11100100

  ; Set the sprite palettes
  copy [rOBP0], %11100100
  copy [rOBP1], %00011011

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
  ld hl, WRAM_IS_VBLANK
  xor a
  .wait_vblank
    halt                  ; Wait for an interupt
    cp a, [hl]            ; Was the interupt VBLANK?
    jr z, .wait_vblank
    ld [hl], a            ; Reset WRAM_IS_VBLANK

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

  ; Set the background position
  copy [rSCX], [WRAM_BG_SCX]
  copy [rSCY], [WRAM_BG_SCY]

  ; Toggle the windown on/off
  ldh a, [rLCDC]
  and a, ~LCDCF_WINON
  ld hl, WRAM_WIN_ENABLE_FLAG
  or a, [hl]
  ldh [rLCDC], a

  ; We are getting all the VBlank critical code done as early as possible
  ; then move on to the game logic code

  ;=========================
  ; Check input
  ;=========================
  UpdatePadInput WRAM_PAD_INPUT

  ; dpad check
  TestPadInput_HeldAll WRAM_PAD_INPUT, PADF_LEFT
  jr nz, .left_checked
    ld hl, WRAM_BG_SCX
    dec [hl]
  .left_checked

  TestPadInput_HeldAll WRAM_PAD_INPUT, PADF_RIGHT
  jr nz, .right_checked
    ld hl, WRAM_BG_SCX
    inc [hl]
  .right_checked

  TestPadInput_HeldAll WRAM_PAD_INPUT, PADF_DOWN
  jr nz, .down_checked
    ld hl, WRAM_BG_SCY
    inc [hl]
  .down_checked

  TestPadInput_HeldAll WRAM_PAD_INPUT, PADF_UP
  jr nz, .up_checked
    ld hl, WRAM_BG_SCY
    dec [hl]
  .up_checked

  ; Window toggle
  TestPadInput_Pressed WRAM_PAD_INPUT, PADF_A
  jr nz, .window_toggle_done
    ld a, [WRAM_WIN_ENABLE_FLAG]
    cpl
    and a, LCDCF_WINON
    ld [WRAM_WIN_ENABLE_FLAG], a
  .window_toggle_done

  ret

export InitSample, UpdateSample

;===============================================================================
section "vblank_interupt", rom0[$0040]
  push af
  ld a, 1
  ld [WRAM_IS_VBLANK], a
  pop af
  reti

;===============================================================================
section "graphic_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "tileset.chr"
incbin "background.tlm"
incbin "window.tlm"
