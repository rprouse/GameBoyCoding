if !def(UTILS_INC)
def UTILS_INC equ 1

include "hardware.inc"

;===============================================================================

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

;===============================================================================
; D-Pad and Buttons
;===============================================================================

; struct to hold the pad input (dpad + buttons)
rsreset
PAD_INPUT_CURRENT   rb 1
sizeof_PAD_INPUT    rb 0

; init a pad input struct at address \1
; expected to be used only once at initialization
; example: InitPadInput _RAM + 16
macro InitPadInput
  ld a, $FF
  ld [\1 + PAD_INPUT_CURRENT], a
endm

; read the keypad input into a pad input struct at address \1
; expected to be used only once in the main loop
; example: UpdatePadInput _HRAM + 4
macro UpdatePadInput
  ; Read the d-pad
  ld a, P1F_GET_DPAD
  ldh [rP1], a
  ldh a, [rP1]
  ldh a, [rP1]

  ; Put the d-pad input in the high nibble of (b)
  swap a
  and a, $F0
  ld b, a

  ; Read the buttons
  ld a, P1F_GET_BTN
  ldh [rP1], a
  ldh a, [rP1]
  ldh a, [rP1]
  ldh a, [rP1]
  ldh a, [rP1]
  ldh a, [rP1]
  ldh a, [rP1]

  ; Merge the buttons' input with the high nibble of (b)
  and a, $0F
  or a, b

  ; Store the current input
  ld [\1 + PAD_INPUT_CURRENT], a

  ; Disable input polling
  ld a, P1F_GET_NONE
  ldh [rP1], a
endm

; Raise the zero flag if all keys in \2 are held in the pad input struct \1
; example: TestPadInput_HeldAll _RAM + 4, PADF_LEFT | PADF_DOWN
macro TestPadInput_HeldAll
  ld a, [\1 + PAD_INPUT_CURRENT]
  and a, \2
endm

endc
