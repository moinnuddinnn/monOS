org 0x7C00
bits 16

main:
    ; Set up video mode (text mode 80x25)
    mov ax, 0x0003
    int 0x10

    ; Set up segment registers
    mov ax, 0x07C0
    mov ds, ax
    mov es, ax

    ; Print a message
    mov si, msg
    call print_string

    ; Halt the system
    hlt

print_string:
    lodsb                   ; Load byte from SI into AL
    or al, al               ; Check if zero (end of string)
    jz .done
    mov ah, 0x0E            ; BIOS teletype function
    mov bh, 0               ; Page number
    int 0x10                ; Call BIOS video service
    jmp print_string
.done:
    ret

msg db 'Hello, OS World!', 0

; Boot sector padding and signature
times 510 - ($ - $$) db 0
dw 0xAA55
