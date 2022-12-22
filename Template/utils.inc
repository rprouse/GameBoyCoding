if !def(UTILS_INC)
def UTILS_INC equ 1

include "hardware.inc"

; copy \2 into \1 through (a)
; example: copy [$FF84], 10
macro copy
  ld a, \2
  ld \1, a
endm

; increment \1 through (a)
; example: increment [$FF84]
macro increment
  ld a, \1
  inc a
  ld \1, a
endm

endc
