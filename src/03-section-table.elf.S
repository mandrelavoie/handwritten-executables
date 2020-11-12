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
    dq section_header - $$          ; Section Header Offset                  e_shoff
    dd 0x00000000                   ; Processor-specific Flags               e_flags
    dw program_header - elf_header  ; ELF Header Size                        e_ehsize
    dw program_header_size          ; Program Header Size                    e_phentsize
    dw 0x0002                       ; Program Header Count                   e_phnum
    dw section_header_size          ; Section Header Size                    e_shentsize
    dw 0x0002                       ; Section Header Count                   e_shnum
    dw 0x0001                       ; String Table                           e_shstrndx

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
    dd 0x6474e551                   ; Type of Segment (GNU_STACK)            p_type
    dd 0x00000000                   ; Segment Attributes                     p_flags
    dq 0x0000000000000000           ; Offset in File                         p_offset
    dq 0x0000000000000000           ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq 0x0000000000000000           ; Size of Segment in File                p_filesz
    dq 0x0000000000000000           ; Size of Segment in Memory              p_memsz
    dq 0x0000000000000004           ; Alignment of Segment                   p_align

section_header:
    ; [0] (.text)
    dd strtab_text - strtab         ; Section Name                           sh_name
    dd 0x00000001                   ; Section Type (PROGBITS)                sh_type
    dq 0x0000000000000006           ; Section Attributes (Exec)              sh_flags
    dq text                         ; Virtual Address in Memory              sh_addr
    dq text - $$                    ; Offset in File                         sh_offset
    dq rodata - text                ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000010           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
section_header_size: equ $ - section_header
    ; [1] (.dynstr)
    dd strtab_dynstr - strtab       ; Section Name                           sh_name
    dd 0x00000003                   ; Section Type (STRTAB)                  sh_type
    dq 0x0000000000000002           ; Section Attributes                     sh_flags
    dq strtab                       ; Virtual Address in Memory              sh_addr
    dq strtab - $$                  ; Offset in File                         sh_offset
    dq text - strtab                ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
strtab:
    db 0x00
    strtab_text:   db ".text", 0x00
    strtab_dynstr: db ".dynstr", 0x00
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
    mov rax, 60                 ; sys_exit
    syscall
_start:
    mov rdi, message
    call puts

    mov rdi, 0
    call exit

rodata:
message:
    db "Try to open this file with `readelf --sections --wide` to see pretty section names!", 0x0a, 0x00

rodata_size: equ $ - rodata
file_size: equ $ - $$