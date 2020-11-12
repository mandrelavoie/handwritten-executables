[BITS 64]
[ORG 0x08048000]

elf_header:
    elf_identifier:
        db 0x7f, "ELF"              ; Signature                              e_ident[EI_MAG[0..3]]
        db 0x02                     ; File Class (64 bits)                   e_ident[EI_CLASS]
        db 0x01                     ; Endianness  (LSB)                      e_ident[EI_DATA]
        db 0x01                     ; Version                                e_ident[EI_VERSION]
        times 9 db 0x00             ; Padding       
    dw 0x0002                       ; Type (Executable)                      e_type
    dw 0x003e                       ; Machine (x86-64)                       e_machine
    dd 0x00000001                   ; Version                                e_version
    dq _start                       ; Entry Point                            e_entry
    dq program_header - $$          ; Program Header Offset                  e_phoff
    dq 0x0000000000000000           ; Section Header Offset                  e_shoff
    dd 0x00000000                   ; Processor-specific Flags               e_flags
    dw program_header - elf_header  ; ELF Header Size                        e_ehsize
    dw text - program_header        ; Program Header Size                    e_phentsize
    dw 0x0001                       ; Program Header Count                   e_phnum
    dw 0x0000                       ; Section Header Size                    e_shentsize
    dw 0x0000                       ; Section Header Count                   e_shnum
    dw 0x0000                       ; String Table                           e_shstrndx

program_header:
    ; [0]
    dd 0x00000001                   ; Type of Segment (Loadable)             p_type
    dd 0x00000005                   ; Segment Attributes (Read | Execute)    p_flags
    dq 0x0000000000000000           ; Offset in File                         p_offset
    dq $$                           ; Virtual Address in Memory              p_vaddr
    dq $$                           ; Physical Address                       p_paddr
    dq file_size                    ; Size of Segment in File                p_filesz
    dq file_size                    ; Size of Segment in Memory              p_memsz
    dq 0x1000                       ; Alignment of Segment                   p_align

text:
strlen:
    xor rax, rax
    mov rcx, -1
    repnz scasb
    not rcx
    dec rcx
    mov rax, rcx
    
    ret
puts:
    push rdi
    call strlen
    mov rdx, rax                ; length
    pop rsi                     ; buffer
    mov rdi, 1                  ; fd (stdout)
    mov rax, 1                  ; sys_write
    syscall

    ret
exit:
    mov rax, 60
    syscall
_start:
    mov rdi, message            ; buffer
    call puts

    mov rdi, 0                  ; error_code
    call exit

message:
db "Allo !", 0x0a, "Now with procedure calls !", 0x0a, 0x00

file_size: equ $ - $$