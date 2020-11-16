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
    dq program_headers - $$          ; Program Header Offset                  e_phoff
    dq section_headers - $$          ; Section Header Offset                  e_shoff
    dd 0x00000000                   ; Processor-specific Flags               e_flags
    dw 0x0040                       ; ELF Header Size                        e_ehsize
    dw 0x0038                       ; Program Header Size                    e_phentsize
    dw 0x0008                       ; Program Header Count                   e_phnum
    dw 0x0040                       ; Section Header Size                    e_shentsize
    dw 0x0007                       ; Section Header Count                   e_shnum
    dw 0x0002                       ; String Table                           e_shstrndx

program_headers:
    ;ph  [type]         [permissions]  [offset]         [virtual addr]      [size]                  [alignment]
    ph   PT_PHDR,       PF_R,          program_headers, program_headers,    text - program_headers, 0x8        ; [0] (Headers Segment)
    ph   PT_LOAD,       PF_R,          0,               0,                  text - $$,              0x1000     ; [1] (Headers Segment)
    ph   PT_LOAD,       PF_R | PF_X,   text,            text,               rodata - text,          0x1000     ; [2] (Code segment)
    ph   PT_LOAD,       PF_R,          rodata,          rodata,             eof-rodata,             0x1000     ; [3] (Read-only Data segment)
    ph   PT_LOAD,       PF_R | PF_W,   dynamic,         dynamic + 0x2000,   headers_end - dynamic,  0x1000     ; [4] (Dynamic Segment)
    ph   PT_DYNAMIC,    PF_R | PF_W,   dynamic,         dynamic + 0x2000,   headers_end - dynamic,  0x8        ; [5] (Dynamic Segment)
    ph   PT_GNU_RELRO,  PF_R,          dynamic,         dynamic + 0x2000,   headers_end - dynamic,  0x1        ; [6] (Reloc Segment)
    ph   PT_GNU_STACK,  0,             0,               0,                  0,                      0x8        ; [7] (Stack Segment)
section_headers:
    ;sh [name]            [type]         [flags]                 [virtual addr]  [offset]   [size]                  [link] [info]  [alignment]  [size of entry]
    sh   0,               SHT_NULL,      0,                      0,              0,         0,                      0,     0,      0,           0              ; [0] (.null)
    sh   strtab_text,     SHT_PROGBITS,  SHF_ALLOC | SHF_EXEC,   text,           text,      0,                      0,     0,      0x1,         0              ; [1] (.text)
    sh   strtab_shstrtab, SHT_STRTAB,    0,                      strtab,         strtab,    dynsym - strtab,        0,     0,      0x1,         0              ; [2] (.shstrtab)
    sh   strtab_rodata,   SHT_PROGBITS,  0,                      rodata,         rodata,    eof-rodata,             0,     0,      0x1,         0              ; [3] (.rodata)
    sh   strtab_dynstr,   SHT_STRTAB,    SHF_ALLOC,              dynstr,         dynstr,    dynsym - dynstr,        0,     0,      0x1,         0              ; [4] (.dynstr)
    sh   strtab_dynsym,   SHT_DYNSYM,    SHF_ALLOC,              dynsym,         dynsym,    dynamic - dynsym,       0x4,   0x1,    0x1,         0x18           ; [5] (.dynsym)
    sh   strtab_dynamic,  SHT_DYNAMIC,   SHF_ALLOC | SHF_WRITE,  dynamic,        dynamic,   headers_end - dynamic,  0x4,   0,      0x8,         0x10           ; [6] (.dynamic)
strtab:
    db 0x00
    strtab_text:      db ".text", 0x00
    strtab_shstrtab:  db ".shstrtab", 0x00
    strtab_rodata:    db ".rodata", 0x00
    strtab_dynstr:    db ".dynstr", 0x00
    strtab_dynsym:    db ".dynsym", 0x00
    strtab_dynamic:   db ".dynamic", 0x00
dynstr:
    db 0x00
    dynstr_say_hello: db "say_hello", 0x00
    dynstr_so_name:   db "07-shared-library.so", 0x00
dynsym:
    ; [0] First one needs to be all zeroes, apparently.
    times 0x18 db 0
    ; [1] The "say_hello" function
    dd dynstr_say_hello - dynstr    ; Index of name in dynstr                st_name
    db 0x12                         ; Symbol Info (GLOBAL | FUNCTION)        st_info
    db 0x00                         ; Symbol Visibility (Default)            st_other
    dw 0x0001                       ; Related Section (.text)                st_shndx
    dq say_hello - $$               ; Symbol Value                           st_value
    dq say_hello_size               ; Symbol Size                            st_size
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
    dq strtab                   ; d_ptr
    ; [4] Size of string table
    dq DT_STRSZ                 ; d_tag
    dq dynsym - dynstr          ; d_ptr
    ; [-1] Must be last
    dq DT_NULL                  ; d_tag
    dq 0x0000000000000000       ; d_val
headers_end:

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

rodata:
    message:
        db "Hello from shared library!", 0x0a, 0x00
eof: