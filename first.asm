; Game Boy Coding Adventure - First Program
; rgbasm -Werror -Weverything -Hl -o first.o first.asm
; rgblink --dmg --tiny -o first.gb first.o
; rgbfix --title first --pad-value 0 --validate first.gb

def ROM_HEADER_ADDRESS    equ $0100
def ROM_MAIN_ADDRESS      equ $0150

section "header", rom0[ROM_HEADER_ADDRESS]
  di
  jr main

section "main", rom0[ROM_MAIN_ADDRESS]
main:
  ld a, 0
.loop
  ld [$C000], a
  inc a
  jr .loop
