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
    dw program_header_size          ; Program Header Size                    e_phentsize
    dw 0x0002                       ; Program Header Count                   e_phnum
    dw 0x0000                       ; Section Header Size                    e_shentsize
    dw 0x0000                       ; Section Header Count                   e_shnum
    dw 0x0000                       ; String Table                           e_shstrndx

program_header:
    ; [0] (Code Segment)
    dd 0x00000001                   ; Type of Segment (Loadable)             p_type
    dd 0x00000005                   ; Segment Attributes (Read | Execute)    p_flags
    dq 0x0000000000000000           ; Offset in File                         p_offset
    dq $$                           ; Virtual Address in Memory              p_vaddr
    dq $$                           ; Physical Address                       p_paddr
    dq file_size                    ; Size of Segment in File                p_filesz
    dq file_size                    ; Size of Segment in Memory              p_memsz
    dq 0x0000000000001000           ; Alignment of Segment                   p_align
program_header_size: equ $ - program_header
    ; [1] (Stack Segment)
    dd 0x6474e551                   ; Type of Segment (GNU_STACK)                           p_type
    dd 0x00000000                   ; Segment Attributes (doesn't matter with GNU_STACK)    p_flags
    dq 0x0000000000000000           ; Offset in File                                       p_offset
    dq 0x0000000000000000           ; Virtual Address in Memory                            p_vaddr
    dq 0x0000000000000000           ; Physical Address                                     p_paddr
    dq 0x0000000000000000           ; Size of Segment in File                              p_filesz
    dq 0x0000000000000000           ; Size of Segment in Memory                            p_memsz
    dq 0x0000000000000004           ; Alignment of Segment                                 p_align

text:
memcpy:
    xor rcx, rcx
    loop:
        mov al, byte [rsi + rcx]
        mov byte [rdi + rcx], al
        inc rcx
        cmp rcx, rdx
        jne loop
    ret
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
    mov rax, 60                 ; sys_exit
    syscall
forbidden_proc:
    nop
    ret
forbidden_proc_size: equ $ - forbidden_proc
_start:
    ; Let's try to push code somewhere on the stack.
    mov rdi, [rsp + 0x50]
    mov rsi, forbidden_proc
    mov rdx, forbidden_proc_size
    call memcpy

    mov rdi, about_to_segfault
    call puts

    ; Execute the code on the stack. If the stack is non-executable, it should segfault here.
    call [rsp]

    mov rdi, should_not_get_here
    call puts

    mov rdi, 0
    call exit

about_to_segfault:
db "I'm about to segfault...", 0x0a, 0x00
should_not_get_here:
db "Execution should not get to this point.", 0x0a, 0x00

file_size: equ $ - $$