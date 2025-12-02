; boot.asm - minimal x86 BIOS bootloader
; Assembled with: nasm -f bin boot.asm -o boot.bin

bits 16                ; we are in 16-bit real mode
org 0x7C00             ; BIOS loads us at physical address 0x7C00

start:
    ; -------------------------------
    ; Basic setup: segments + stack
    ; -------------------------------
    cli                ; disable interrupts while we set up
    xor ax, ax
    mov ds, ax         ; data segment = 0
    mov es, ax         ; extra segment = 0
    mov ss, ax         ; stack segment = 0
    mov sp, 0x7C00     ; stack pointer (grow down from 0x7C00)

    ; -------------------------------
    ; Print a message using BIOS
    ; -------------------------------
    mov si, msg        ; DS:SI points to our string

.print_loop:
    lodsb              ; AL = [DS:SI], SI++
    test al, al        ; is AL == 0?
    jz .done           ; if zero, end of string

    mov ah, 0x0E       ; BIOS teletype function
    mov bh, 0x00       ; page number
    mov bl, 0x07       ; text attribute (light grey on black)
    int 0x10           ; call BIOS

    jmp .print_loop

.done:
    ; Halt the CPU in an infinite loop
.hang:
    hlt
    jmp .hang

; -------------------------------
; Data
; -------------------------------
msg db "Hello from my bootloader!", 0

; -------------------------------
; Boot sector padding & signature
; -------------------------------
times 510 - ($ - $$) db 0   ; pad with zeros up to 510 bytes
dw 0xAA55                   ; boot signature

