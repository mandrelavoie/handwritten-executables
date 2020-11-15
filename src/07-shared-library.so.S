[BITS 64]

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
    dq program_header - $$          ; Program Header Offset                  e_phoff
    dq section_header - $$          ; Section Header Offset                  e_shoff
    dd 0x00000000                   ; Processor-specific Flags               e_flags
    dw 0x0040                       ; ELF Header Size                        e_ehsize
    dw 0x0038                       ; Program Header Size                    e_phentsize
    dw 0x0007                       ; Program Header Count                   e_phnum
    dw 0x0040                       ; Section Header Size                    e_shentsize
    dw 0x0008                       ; Section Header Count                   e_shnum
    dw 0x0002                       ; String Table                           e_shstrndx

program_header:
    ; [0] (Headers Segment)
    dd 0x00000006                   ; Type of Segment (Headers)             p_type
    dd 0x00000004                   ; Segment Attributes (Read)              p_flags
    dq program_header - $$          ; Offset in File                         p_offset
    dq program_header               ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq text - program_header        ; Size of Segment in File                p_filesz
    dq text - program_header        ; Size of Segment in Memory              p_memsz
    dq 0x0000000000000008           ; Alignment of Segment                   p_align
    ; [1] (Headers Segment)
    dd 0x00000001                   ; Type of Segment (Loadable)             p_type
    dd 0x00000004                   ; Segment Attributes (Read)              p_flags
    dq 0x0000000000000000           ; Offset in File                         p_offset
    dq $$                           ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq text - $$                    ; Size of Segment in File                p_filesz
    dq text - $$                    ; Size of Segment in Memory              p_memsz
    dq 0x0000000000001000           ; Alignment of Segment                   p_align
    ; [2] (Code segment)
    dd 0x00000001                   ; Type of Segment (Loadable)             p_type
    dd 0x00000005                   ; Segment Attributes (Read | Execute)    p_flags
    dq text - $$                    ; Offset in File                         p_offset
    dq text                         ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq rodata - text                ; Size of Segment in File                p_filesz
    dq rodata - text                ; Size of Segment in Memory              p_memsz
    dq 0x0000000000001000           ; Alignment of Segment                   p_align
    ; [3] (Read-only Data segment)
    dd 0x00000001                   ; Type of Segment (Loadable)             p_type
    dd 0x00000004                   ; Segment Attributes (Read)              p_flags
    dq rodata - $$                  ; Offset in File                         p_offset
    dq rodata                       ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq eof - rodata                 ; Size of Segment in File                p_filesz
    dq eof - rodata                 ; Size of Segment in Memory              p_memsz
    dq 0x0000000000001000           ; Alignment of Segment                   p_align
    ; [4] (Dynamic Segment)
    dd 0x00000001                   ; Type of Segment (Loadable)              p_type
    dd 0x00000006                   ; Segment Attributes (Read | Write)      p_flags
    dq dynamic - $$                 ; Offset in File                         p_offset
    dq dynamic + 0x2000             ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq headers_end - dynamic        ; Size of Segment in File                p_filesz
    dq headers_end - dynamic        ; Size of Segment in Memory              p_memsz
    dq 0x0000000000001000           ; Alignment of Segment                   p_align
    ; [5] (Dynamic Segment)
    dd 0x00000002                   ; Type of Segment (Dynamic)              p_type
    dd 0x00000006                   ; Segment Attributes (Read | Write)      p_flags
    dq dynamic - $$                 ; Offset in File                         p_offset
    dq dynamic + 0x2000             ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq headers_end - dynamic        ; Size of Segment in File                p_filesz
    dq headers_end - dynamic        ; Size of Segment in Memory              p_memsz
    dq 0x0000000000000008           ; Alignment of Segment                   p_align
    ; [6] (Reloc Segment)
    dd 0x6474e552                   ; Type of Segment (GNU_RELRO)            p_type
    dd 0x00000004                   ; Segment Attributes (Read)              p_flags
    dq dynamic - $$                 ; Offset in File                         p_offset
    dq dynamic + 0x2000             ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq headers_end - dynamic        ; Size of Segment in File                p_filesz
    dq 0xd18                        ; Size of Segment in Memory              p_memsz      ; Why??
    dq 0x0000000000000001           ; Alignment of Segment                   p_align
    ; [7] (Stack Segment)
    dd 0x6474e551                   ; Type of Segment (GNU_STACK)            p_type
    dd 0x00000000                   ; Segment Attributes                     p_flags
    dq 0x0000000000000000           ; Offset in File                         p_offset
    dq 0x0000000000000000           ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000           ; Physical Address                       p_paddr
    dq 0x0000000000000000           ; Size of Segment in File                p_filesz
    dq 0x0000000000000000           ; Size of Segment in Memory              p_memsz
    dq 0x0000000000000008           ; Alignment of Segment                   p_align

section_header:
    ; [0] (.null)
    dd 0x00000000                   ; Section Name                           sh_name
    dd 0x00000000                   ; Section Type (PROGBITS)                sh_type
    dq 0x0000000000000000           ; Section Attributes (Alloc | Exec)      sh_flags
    dq 0x0000000000000000           ; Virtual Address in Memory              sh_addr
    dq 0x0000000000000000           ; Offset in File                         sh_offset
    dq 0x0000000000000000           ; Size of Section                        sh_size
    dd 0x0000000000000000           ; Link to Other Section                  sh_link
    dd 0x0000000000000000           ; Miscellaneous Information              sh_info
    dq 0x0000000000000000           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
    ; [1] (.text)
    dd strtab_text - strtab         ; Section Name                           sh_name
    dd 0x00000001                   ; Section Type (PROGBITS)                sh_type
    dq 0x0000000000000006           ; Section Attributes (Alloc | Exec)      sh_flags
    dq text                         ; Virtual Address in Memory              sh_addr
    dq text - $$                    ; Offset in File                         sh_offset
    dq rodata - text                ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
    ; [2] (.shstrtab)
    dd strtab_shstrtab - strtab     ; Section Name                           sh_name
    dd 0x00000003                   ; Section Type (STRTAB)                  sh_type
    dq 0x0000000000000000           ; Section Attributes                     sh_flags
    dq strtab                       ; Virtual Address in Memory              sh_addr
    dq strtab - $$                  ; Offset in File                         sh_offset
    dq dynsym - strtab              ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
    ; [3] (.rodata)
    dd strtab_rodata - strtab       ; Section Name                           sh_name
    dd 0x00000001                   ; Section Type (PROGBITS)                sh_type
    dq 0x0000000000000000           ; Section Attributes                     sh_flags
    dq rodata                       ; Virtual Address in Memory              sh_addr
    dq rodata - $$                  ; Offset in File                         sh_offset
    dq eof - rodata                 ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
    ; [4] (.dynstr)
    dd strtab_dynstr - strtab       ; Section Name                           sh_name
    dd 0x00000003                   ; Section Type (STRTAB)                  sh_type
    dq 0x0000000000000002           ; Section Attributes (Alloc)             sh_flags
    dq dynstr                       ; Virtual Address in Memory              sh_addr
    dq dynstr - $$                  ; Offset in File                         sh_offset
    dq dynsym - dynstr              ; Size of Section                        sh_size
    dd 0x00000000                   ; Link to Other Section                  sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000000           ; Size of Entry                          sh_entsize
    ; [5] (.dynsym)
    dd strtab_dynsym - strtab       ; Section Name                           sh_name
    dd 0x0000000b                   ; Section Type (DYNSYM)                  sh_type
    dq 0x0000000000000002           ; Section Attributes (Alloc)             sh_flags
    dq dynsym                       ; Virtual Address in Memory              sh_addr
    dq dynsym - $$                  ; Offset in File                         sh_offset
    dq dynamic - dynsym             ; Size of Section                        sh_size
    dd 0x00000004                   ; Link to Other Section (.dynstr)        sh_link
    dd 0x00000001                   ; Miscellaneous Information (# symbols)  sh_info
    dq 0x0000000000000001           ; Address Alignment                      sh_addralign
    dq 0x0000000000000018           ; Size of Entry                          sh_entsize
    ; [6] (.dynamic)
    dd strtab_dynamic - strtab      ; Section Name                           sh_name
    dd 0x00000006                   ; Section Type (DYNAMIC)                 sh_type
    dq 0x0000000000000003           ; Section Attributes (Alloc | Write)     sh_flags
    dq dynamic                      ; Virtual Address in Memory              sh_addr
    dq dynamic - $$                 ; Offset in File                         sh_offset
    dq headers_end - dynamic        ; Size of Section                        sh_size
    dd 0x00000004                   ; Link to Other Section (.dynstr)        sh_link
    dd 0x00000000                   ; Miscellaneous Information              sh_info
    dq 0x0000000000000008           ; Address Alignment                      sh_addralign
    dq 0x0000000000000010           ; Size of Entry                          sh_entsize
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
    dd 0x00000000                   ; Index of name in dynstr                st_name
    db 0x00                         ; Symbol Info                            st_info
    db 0x00                         ; Symbol Visibility (Default)            st_other
    dw 0x0000                       ; Related Section                        st_shndx
    dq 0x0000000000000000           ; Symbol Value                           st_value
    dq 0x0000000000000000           ; Symbol Size                            st_size
    ; [1] The "say_hello" function
    dd dynstr_say_hello - dynstr    ; Index of name in dynstr                st_name
    db 0x12                         ; Symbol Info (GLOBAL | FUNCTION)        st_info
    db 0x00                         ; Symbol Visibility (Default)            st_other
    dw 0x0001                       ; Related Section (.text)                st_shndx
    dq say_hello - $$               ; Symbol Value                           st_value
    dq say_hello_size               ; Symbol Size                            st_size
dynamic:
    ;; Table of valid tags for the .dynamic section (taken from glibc)
    ; DT_NULL                   0                 Marks end of dynamic section
    ; DT_NEEDED                 1                 Name of needed library
    ; DT_PLTRELSZ               2                 Size in bytes of PLT relocs
    ; DT_PLTGOT                 3                 Processor defined value
    ; DT_HASH                   4                 Address of symbol hash table
    ; DT_STRTAB                 5                 Address of string table
    ; DT_SYMTAB                 6                 Address of symbol table
    ; DT_RELA                   7                 Address of Rela relocs
    ; DT_RELASZ                 8                 Total size of Rela relocs
    ; DT_RELAENT                9                 Size of one Rela reloc
    ; DT_STRSZ                  10                Size of string table
    ; DT_SYMENT                 11                Size of one symbol table entry
    ; DT_INIT                   12                Address of init function
    ; DT_FINI                   13                Address of termination function
    ; DT_SONAME                 14                Name of shared object
    ; DT_RPATH                  15                Library search path (deprecated)
    ; DT_SYMBOLIC               16                Start symbol search here
    ; DT_REL                    17                Address of Rel relocs
    ; DT_RELSZ                  18                Total size of Rel relocs
    ; DT_RELENT                 19                Size of one Rel reloc
    ; DT_PLTREL                 20                Type of reloc in PLT
    ; DT_DEBUG                  21                For debugging; unspecified
    ; DT_TEXTREL                22                Reloc might modify .text
    ; DT_JMPREL                 23                Address of PLT relocs
    ; DT_BIND_NOW               24                Process relocations of object
    ; DT_INIT_ARRAY             25                Array with addresses of init fct
    ; DT_FINI_ARRAY             26                Array with addresses of fini fct
    ; DT_INIT_ARRAYSZ           27                Size in bytes of DT_INIT_ARRAY
    ; DT_FINI_ARRAYSZ           28                Size in bytes of DT_FINI_ARRAY
    ; DT_RUNPATH                29                Library search path
    ; DT_FLAGS                  30                Flags for the object being loaded
    ; DT_ENCODING               32                Start of encoded range
    ; DT_PREINIT_ARRAY          32                Array with addresses of preinit fc
    ; DT_PREINIT_ARRAYSZ        33                size in bytes of DT_PREINIT_ARRAY
    ; DT_SYMTAB_SHNDX           34                Address of SYMTAB_SHNDX section
    ; DT_NUM                    35                Number used
    ;;
    ; [0] SONAME (Name of shared object)
    dq 14                       ; d_tag
    dq dynstr_so_name - dynstr  ; d_ptr
    ; [1] SYMTAB (Address of symbol table)
    dq 6                        ; d_tag
    dq dynsym                   ; d_val
    ; [2] SYMENT (Size of one symbol table entry)
    dq 11                       ; d_tag
    dq 0x0000000000000018       ; d_val
    ; [3] STRTAB (Address of string table)
    dq 5                        ; d_tag
    dq strtab                   ; d_ptr
    ; [4] STRSZ (Size of string table)
    dq 10                       ; d_tag
    dq dynsym - dynstr          ; d_ptr
    ; [-1] NULL (Must be last)
    dq 0x00000000               ; d_tag
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