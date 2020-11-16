; Segment types
%define PT_NULL          0
%define PT_LOAD          1
%define PT_DYNAMIC       2
%define PT_INTERP        3
%define PT_NOTE          4
%define PT_SHLIB         5
%define PT_PHDR          6
%define PT_GNU_EH_FRAME  0x6474e550
%define PT_GNU_STACK     0x6474e551
%define PT_GNU_RELRO     0x6474e552

; Segment permissions
%define PF_X   0x1
%define PF_W   0x2
%define PF_R   0x4

%macro ph 6
    dd %1                    ; Type of Segment                        p_type
    dd %2                    ; Segment Attributes                     p_flags
    dq %3 - $$               ; Offset in File                         p_offset
    dq %4                    ; Virtual Address in Memory              p_vaddr
    dq 0x0000000000000000    ; Physical Address                       p_paddr
    dq %5                    ; Size of Segment in File                p_filesz
    dq %5                    ; Size of Segment in Memory              p_memsz
    dq %6                    ; Alignment of Segment                   p_align
%endmacro

%define SHT_NULL 	        0x0
%define SHT_PROGBITS 	    0x1
%define SHT_SYMTAB 	        0x2
%define SHT_STRTAB 	        0x3
%define SHT_RELA 	        0x4
%define SHT_HASH 	        0x5
%define SHT_DYNAMIC 	    0x6
%define SHT_NOTE 	        0x7
%define SHT_NOBITS 	        0x8
%define SHT_REL 	        0x9
%define SHT_SHLIB 	        0xa
%define SHT_DYNSYM 	        0xb
%define SHT_INIT_ARRAY 	    0xc
%define SHT_FINI_ARRAY 	    0xd
%define SHT_PREINIT_ARRAY 	0xe
%define SHT_GROUP 	        0xf
%define SHT_SYMTAB_SHNDX 	0x10
%define SHT_GNU_verdef	    0x6ffffffd
%define SHT_GNU_verneed	    0x6ffffffe
%define SHT_GNU_versym	    0x6fffffff

%define SHF_WRITE              0x1
%define SHF_ALLOC              0x2
%define SHF_EXEC               0x4
%define SHF_MERGE              0x10
%define SHF_STRINGS            0x20
%define SHF_INFO_LINK          0x40
%define SHF_LINK_ORDER         0x80
%define SHF_OS_NONCONFORMING   0x100
%define SHF_GROUP              0x200
%define SHF_TLS                0x400
%define SHF_COMPRESSED         0x800

%macro sh 10
    dd %1 - strtab          ; Section Name                           sh_name
    dd %2                   ; Section Type                           sh_type
    dq %3                   ; Section Attributes                     sh_flags
    dq %4                   ; Virtual Address in Memory              sh_addr
    dq %5 - $$              ; Offset in File                         sh_offset
    dq %6                   ; Size of Section                        sh_size
    dd %7                   ; Link to Other Section                  sh_link
    dd %8                   ; Miscellaneous Information              sh_info
    dq %9                   ; Address Alignment                      sh_addralign
    dq %10                  ; Size of Entry                          sh_entsize
%endmacro

; Dynamic Tags
%define DT_NULL                   0
%define DT_NEEDED                 1
%define DT_PLTRELSZ               2
%define DT_PLTGOT                 3
%define DT_HASH                   4
%define DT_STRTAB                 5
%define DT_SYMTAB                 6
%define DT_RELA                   7
%define DT_RELASZ                 8
%define DT_RELAENT                9
%define DT_STRSZ                  10
%define DT_SYMENT                 11
%define DT_INIT                   12
%define DT_FINI                   13
%define DT_SONAME                 14
%define DT_RPATH                  15
%define DT_SYMBOLIC               16
%define DT_REL                    17
%define DT_RELSZ                  18
%define DT_RELENT                 19
%define DT_PLTREL                 20
%define DT_DEBUG                  21
%define DT_TEXTREL                22
%define DT_JMPREL                 23
%define DT_BIND_NOW               24
%define DT_INIT_ARRAY             25
%define DT_FINI_ARRAY             26
%define DT_INIT_ARRAYSZ           27
%define DT_FINI_ARRAYSZ           28
%define DT_RUNPATH                29
%define DT_FLAGS                  30
%define DT_ENCODING               32
%define DT_PREINIT_ARRAY          32
%define DT_PREINIT_ARRAYSZ        33
%define DT_SYMTAB_SHNDX           34
%define DT_NUM                    35