[BITS 64]

%include "src/99-common.inc"

elf_header:
    elf_identifier:
        db 0x7f, "ELF"              ; Signature                              e_ident[EI_MAG[0..3]]
        db 0x02                     ; File Class (64 bits)                   e_ident[EI_CLASS]
        db 0x01                     ; Endianness  (LSB)                      e_ident[EI_DATA]
        db 0x01                     ; Version                                e_ident[EI_VERSION]
        times 9 db 0x00             ; Padding       
    dw 0x0003                       ; Type (Shared library)                  e_type
    dw 0x003e                       ; Machine (x86-64)                       e_machine
    dd 0x00000001                   ; Version                                e_version
    dq say_hello                    ; Entry Point                            e_entry
    dq program_headers              ; Program Header Offset                  e_phoff
    dq section_headers              ; Section Header Offset                  e_shoff
    dd 0x00000000                   ; Processor-specific Flags               e_flags
    dw 0x0040                       ; ELF Header Size                        e_ehsize
    dw 0x0038                       ; Program Header Size                    e_phentsize
    dw 0x0007                       ; Program Header Count                   e_phnum
    dw 0x0040                       ; Section Header Size                    e_shentsize
    dw 0x0008                       ; Section Header Count                   e_shnum
    dw 0x0002                       ; String Table                           e_shstrndx

program_headers:
    ;ph  [type]         [permissions]  [offset]         [virtual addr]      [size]                              [alignment]
    ph   PT_PHDR,       PF_R,          program_headers, program_headers,    section_headers - program_headers,  0x8        ; [0] (Headers Segment)
    ph   PT_LOAD,       PF_R,          0,               0,                  headers_end,                        0x1000     ; [1] (Headers Segment)
    ph   PT_LOAD,       PF_R | PF_X,   text,            text,               text_end - text,                    0x1000     ; [2] (Code segment)
    ph   PT_LOAD,       PF_R | PF_W,   dynamic,         dynamic,            eof - dynamic,                      0x1000     ; [4] (Loadable Dynamic Segment)
    ph   PT_DYNAMIC,    PF_R | PF_W,   dynamic,         dynamic,            eof - dynamic,                      0x8        ; [5] (Dynamic Segment)
    ph   PT_GNU_RELRO,  PF_R,          dynamic,         dynamic,            eof - dynamic,                      0x1        ; [6] (Reloc Segment)
    ph   PT_GNU_STACK,  0,             0,               0,                  0,                                  0x8        ; [7] (Stack Segment)
section_headers:
    ;sh [name]              [type]         [flags]                 [virtual addr]  [offset]   [size]                  [link] [info]  [alignment]  [size of entry]
    sh   0,                 SHT_NULL,      0,                      0,              0,         0,                      0,     0,      0,           0              ; [0] (.null)
    sh   shstrtab_text,     SHT_PROGBITS,  SHF_ALLOC | SHF_EXEC,   text,           text,      text_size,              0,     0,      0x10,        0              ; [1] (.text)
    sh   shstrtab_shstrtab, SHT_STRTAB,    0,                      shstrtab,       shstrtab,  rodata - shstrtab,      0,     0,      0x1,         0              ; [2] (.shstrtab)
    sh   shstrtab_rodata,   SHT_PROGBITS,  0,                      rodata,         rodata,    dynstr - rodata,        0,     0,      0x1,         0              ; [3] (.rodata)
    sh   shstrtab_dynstr,   SHT_STRTAB,    SHF_ALLOC,              dynstr,         dynstr,    dynsym - dynstr,        0,     0,      0x1,         0              ; [4] (.dynstr)
    sh   shstrtab_dynsym,   SHT_DYNSYM,    SHF_ALLOC,              dynsym,         dynsym,    symtab - dynsym,        0x4,   0x1,    0x8,         0x18           ; [5] (.dynsym)
    sh   shstrtab_symtab,   SHT_SYMTAB,    0,                      symtab,         symtab,    headers_end - symtab,   0x4,   0x4,    0x8,         0x18           ; [6] (.symtab)
    sh   shstrtab_dynamic,  SHT_DYNAMIC,   SHF_ALLOC | SHF_WRITE,  dynamic,        dynamic,   eof - dynamic,          0x4,   0,      0x8,         0x10           ; [7] (.dynamic)
shstrtab:
    db 0x00
    shstrtab_text:      db ".text",     0x00
    shstrtab_shstrtab:  db ".shstrtab", 0x00
    shstrtab_rodata:    db ".rodata",   0x00
    shstrtab_dynstr:    db ".dynstr",   0x00
    shstrtab_dynsym:    db ".dynsym",   0x00
    shstrtab_symtab:    db ".symtab",   0x00
    shstrtab_dynamic:   db ".dynamic",  0x00
rodata:
    message:
        db "Hello from shared library!", 0x0a, 0x00
dynstr:
    db 0x00
    dynstr_say_hello: db "say_hello",            0x00
    dynstr_so_name:   db "07-shared-library.so", 0x00
    dynstr_not_sure:  db "shared-library",       0x00
    dynstr_message:   db "message",              0x00
    dynstr_dynamic:   db "__DYNAMIC",            0x00
dynsym:
    ; [0] First one needs to be all zeroes, apparently.
    times 0x18 db 0
    ; [1] The "say_hello" function
    dd dynstr_say_hello - dynstr    ; Index of name in dynstr                st_name
    db 0x12                         ; Symbol Info                            st_info
    db 0x00                         ; Symbol Visibility                      st_other
    dw 0x0001                       ; Related Section                        st_shndx
    dq say_hello - $$               ; Symbol Value                           st_value
    dq say_hello_size               ; Symbol Size                            st_size
symtab:
    ; [0] First one needs to be all zeroes, apparently.
    times 0x18 db 0
    ; [1] The fuck is that needed?
    dd dynstr_not_sure - dynstr     ; Index of name in dynstr                st_name
    db 0x04                         ; Symbol Info                            st_info
    db 0x00                         ; Symbol Visibility                      st_other
    dw 0xfff1                       ; Related Section                        st_shndx
    dq 0x0000000000000000           ; Symbol Value                           st_value
    dq 0x0000000000000000           ; Symbol Size                            st_size
    ; [2] The fuck is that needed?
    dd dynstr_message - dynstr      ; Index of name in dynstr                st_name
    db 0x01                         ; Symbol Info                            st_info
    db 0x00                         ; Symbol Visibility                      st_other
    dw 0x0003                       ; Related Section                        st_shndx
    dq message                      ; Symbol Value                           st_value
    dq dynstr - message             ; Symbol Size                            st_size
    ; [3] The fuck is that needed?
    dd dynstr_dynamic - dynstr      ; Index of name in dynstr                st_name
    db 0x00                         ; Symbol Info                            st_info
    db 0x02                         ; Symbol Visibility                      st_other
    dw 0x0007                       ; Related Section                        st_shndx
    dq dynamic                      ; Symbol Value                           st_value
    dq 0x0000000000000000           ; Symbol Size                            st_size
    ; [4] The "say_hello" function
    dd dynstr_say_hello - dynstr    ; Index of name in dynstr                st_name
    db 0x12                         ; Symbol Info                            st_info
    db 0x00                         ; Symbol Visibility                      st_other
    dw 0x0001                       ; Related Section                        st_shndx
    dq say_hello - $$               ; Symbol Value                           st_value
    dq say_hello_size               ; Symbol Size                            st_size
headers_end:

times 0x1000 - ($ - $$) db 0x00

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
say_hello:
    mov rdi, message
    call puts

    ret
say_hello_size: equ $ - say_hello
text_size: equ $ - text
text_end:

times 0x2000 - ($ - $$) db 0x00

dynamic:
    ; [0] Name of shared object
    dq DT_SONAME                ; d_tag
    dq dynstr_so_name - dynstr  ; d_ptr
    ; [1] Address of symbol table
    dq DT_SYMTAB                ; d_tag
    dq dynsym                   ; d_val
    ; [2] Size of one symbol table entry
    dq DT_SYMENT                ; d_tag
    dq 0x0000000000000018       ; d_val
    ; [3] Address of string table
    dq DT_STRTAB                ; d_tag
    dq dynstr                   ; d_ptr
    ; [4] Size of string table
    dq DT_STRSZ                 ; d_tag
    dq dynsym - dynstr          ; d_ptr
    ; [-1] Must be last
    dq DT_NULL                  ; d_tag
    dq 0x0000000000000000       ; d_val

eof: