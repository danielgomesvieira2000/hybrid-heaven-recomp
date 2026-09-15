SECTIONS
{
    __romPos = 0;
    header_ROM_START = __romPos;
    header_VRAM = ADDR(.header);
    .header : AT(header_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        header_DATA_START = .;
        build-elf/asm/header.s.o(.data);
        header_DATA_END = .;
        header_DATA_SIZE = ABSOLUTE(header_DATA_END - header_DATA_START);
    }
    __romPos += SIZEOF(.header);
    header_ROM_END = __romPos;
    header_VRAM_END = .;

    ipl3_ROM_START = __romPos;
    ipl3_VRAM = ADDR(.ipl3);
    .ipl3 : AT(ipl3_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        ipl3_DATA_START = .;
        build-elf/unpacked/assets/ipl3.bin.o(.data);
        ipl3_DATA_END = .;
        ipl3_DATA_SIZE = ABSOLUTE(ipl3_DATA_END - ipl3_DATA_START);
    }
    __romPos += SIZEOF(.ipl3);
    ipl3_ROM_END = __romPos;
    ipl3_VRAM_END = .;

    resident_ROM_START = __romPos;
    resident_VRAM = ADDR(.resident);
    .resident 0x80000400 : AT(resident_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        resident_TEXT_START = .;
        build-elf/asm/resident.s.o(.text);
        . = ALIGN(., 16);
        resident_TEXT_END = .;
        resident_TEXT_SIZE = ABSOLUTE(resident_TEXT_END - resident_TEXT_START);
        resident_DATA_START = .;
        build-elf/asm/resident.s.o(.data);
        build-elf/asm/asm/data/resident_data.data.s.o(.data);
        . = ALIGN(., 16);
        resident_DATA_END = .;
        resident_DATA_SIZE = ABSOLUTE(resident_DATA_END - resident_DATA_START);
        resident_RODATA_START = .;
        build-elf/asm/resident.s.o(.rodata);
        . = ALIGN(., 16);
        resident_RODATA_END = .;
        resident_RODATA_SIZE = ABSOLUTE(resident_RODATA_END - resident_RODATA_START);
    }
    resident_bss_VRAM = ADDR(.resident_bss);
    .resident_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        resident_BSS_START = .;
        build-elf/asm/resident.s.o(.bss);
        build-elf/asm/asm/data/resident_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        resident_BSS_END = .;
        resident_BSS_SIZE = ABSOLUTE(resident_BSS_END - resident_BSS_START);
    }
    __romPos += SIZEOF(.resident);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    resident_ROM_END = __romPos;
    resident_VRAM_END = .;

    gap_ROM_START = __romPos;
    gap_VRAM = ADDR(.gap);
    .gap : AT(gap_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        gap_DATA_START = .;
        build-elf/unpacked/assets/gap.bin.o(.data);
        gap_DATA_END = .;
        gap_DATA_SIZE = ABSOLUTE(gap_DATA_END - gap_DATA_START);
    }
    __romPos += SIZEOF(.gap);
    gap_ROM_END = __romPos;
    gap_VRAM_END = .;

    file_008_ROM_START = __romPos;
    file_008_VRAM = ADDR(.file_008);
    .file_008 0x80107830 : AT(file_008_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_008_TEXT_START = .;
        build-elf/asm/file_008.s.o(.text);
        . = ALIGN(., 16);
        file_008_TEXT_END = .;
        file_008_TEXT_SIZE = ABSOLUTE(file_008_TEXT_END - file_008_TEXT_START);
        file_008_DATA_START = .;
        build-elf/asm/file_008.s.o(.data);
        build-elf/asm/asm/data/file_008_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_008_DATA_END = .;
        file_008_DATA_SIZE = ABSOLUTE(file_008_DATA_END - file_008_DATA_START);
        file_008_RODATA_START = .;
        build-elf/asm/file_008.s.o(.rodata);
        . = ALIGN(., 16);
        file_008_RODATA_END = .;
        file_008_RODATA_SIZE = ABSOLUTE(file_008_RODATA_END - file_008_RODATA_START);
    }
    file_008_bss_VRAM = ADDR(.file_008_bss);
    .file_008_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_008_BSS_START = .;
        build-elf/asm/file_008.s.o(.bss);
        build-elf/asm/asm/data/file_008_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_008_BSS_END = .;
        file_008_BSS_SIZE = ABSOLUTE(file_008_BSS_END - file_008_BSS_START);
    }
    __romPos += SIZEOF(.file_008);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_008_ROM_END = __romPos;
    file_008_VRAM_END = .;

    file_009_ROM_START = __romPos;
    file_009_VRAM = ADDR(.file_009);
    .file_009 0x801BF1A0 : AT(file_009_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_009_TEXT_START = .;
        build-elf/asm/file_009.s.o(.text);
        . = ALIGN(., 16);
        file_009_TEXT_END = .;
        file_009_TEXT_SIZE = ABSOLUTE(file_009_TEXT_END - file_009_TEXT_START);
        file_009_DATA_START = .;
        build-elf/asm/file_009.s.o(.data);
        build-elf/asm/asm/data/file_009_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_009_DATA_END = .;
        file_009_DATA_SIZE = ABSOLUTE(file_009_DATA_END - file_009_DATA_START);
        file_009_RODATA_START = .;
        build-elf/asm/file_009.s.o(.rodata);
        . = ALIGN(., 16);
        file_009_RODATA_END = .;
        file_009_RODATA_SIZE = ABSOLUTE(file_009_RODATA_END - file_009_RODATA_START);
    }
    file_009_bss_VRAM = ADDR(.file_009_bss);
    .file_009_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_009_BSS_START = .;
        build-elf/asm/file_009.s.o(.bss);
        build-elf/asm/asm/data/file_009_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_009_BSS_END = .;
        file_009_BSS_SIZE = ABSOLUTE(file_009_BSS_END - file_009_BSS_START);
    }
    __romPos += SIZEOF(.file_009);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_009_ROM_END = __romPos;
    file_009_VRAM_END = .;

    file_010_ROM_START = __romPos;
    file_010_VRAM = ADDR(.file_010);
    .file_010 0x801E4AA0 : AT(file_010_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_010_TEXT_START = .;
        build-elf/asm/file_010.s.o(.text);
        . = ALIGN(., 16);
        file_010_TEXT_END = .;
        file_010_TEXT_SIZE = ABSOLUTE(file_010_TEXT_END - file_010_TEXT_START);
        file_010_DATA_START = .;
        build-elf/asm/file_010.s.o(.data);
        build-elf/asm/asm/data/file_010_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_010_DATA_END = .;
        file_010_DATA_SIZE = ABSOLUTE(file_010_DATA_END - file_010_DATA_START);
        file_010_RODATA_START = .;
        build-elf/asm/file_010.s.o(.rodata);
        . = ALIGN(., 16);
        file_010_RODATA_END = .;
        file_010_RODATA_SIZE = ABSOLUTE(file_010_RODATA_END - file_010_RODATA_START);
    }
    file_010_bss_VRAM = ADDR(.file_010_bss);
    .file_010_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_010_BSS_START = .;
        build-elf/asm/file_010.s.o(.bss);
        build-elf/asm/asm/data/file_010_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_010_BSS_END = .;
        file_010_BSS_SIZE = ABSOLUTE(file_010_BSS_END - file_010_BSS_START);
    }
    __romPos += SIZEOF(.file_010);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_010_ROM_END = __romPos;
    file_010_VRAM_END = .;

    file_011_ROM_START = __romPos;
    file_011_VRAM = ADDR(.file_011);
    .file_011 0x8021B150 : AT(file_011_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_011_TEXT_START = .;
        build-elf/asm/file_011.s.o(.text);
        . = ALIGN(., 16);
        file_011_TEXT_END = .;
        file_011_TEXT_SIZE = ABSOLUTE(file_011_TEXT_END - file_011_TEXT_START);
        file_011_DATA_START = .;
        build-elf/asm/file_011.s.o(.data);
        build-elf/asm/asm/data/file_011_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_011_DATA_END = .;
        file_011_DATA_SIZE = ABSOLUTE(file_011_DATA_END - file_011_DATA_START);
        file_011_RODATA_START = .;
        build-elf/asm/file_011.s.o(.rodata);
        . = ALIGN(., 16);
        file_011_RODATA_END = .;
        file_011_RODATA_SIZE = ABSOLUTE(file_011_RODATA_END - file_011_RODATA_START);
    }
    file_011_bss_VRAM = ADDR(.file_011_bss);
    .file_011_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_011_BSS_START = .;
        build-elf/asm/file_011.s.o(.bss);
        build-elf/asm/asm/data/file_011_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_011_BSS_END = .;
        file_011_BSS_SIZE = ABSOLUTE(file_011_BSS_END - file_011_BSS_START);
    }
    __romPos += SIZEOF(.file_011);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_011_ROM_END = __romPos;
    file_011_VRAM_END = .;

    file_012_ROM_START = __romPos;
    file_012_VRAM = ADDR(.file_012);
    .file_012 0x802408F0 : AT(file_012_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_012_TEXT_START = .;
        build-elf/asm/file_012.s.o(.text);
        . = ALIGN(., 16);
        file_012_TEXT_END = .;
        file_012_TEXT_SIZE = ABSOLUTE(file_012_TEXT_END - file_012_TEXT_START);
        file_012_DATA_START = .;
        build-elf/asm/file_012.s.o(.data);
        build-elf/asm/asm/data/file_012_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_012_DATA_END = .;
        file_012_DATA_SIZE = ABSOLUTE(file_012_DATA_END - file_012_DATA_START);
        file_012_RODATA_START = .;
        build-elf/asm/file_012.s.o(.rodata);
        . = ALIGN(., 16);
        file_012_RODATA_END = .;
        file_012_RODATA_SIZE = ABSOLUTE(file_012_RODATA_END - file_012_RODATA_START);
    }
    file_012_bss_VRAM = ADDR(.file_012_bss);
    .file_012_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_012_BSS_START = .;
        build-elf/asm/file_012.s.o(.bss);
        build-elf/asm/asm/data/file_012_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_012_BSS_END = .;
        file_012_BSS_SIZE = ABSOLUTE(file_012_BSS_END - file_012_BSS_START);
    }
    __romPos += SIZEOF(.file_012);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_012_ROM_END = __romPos;
    file_012_VRAM_END = .;

    file_013_ROM_START = __romPos;
    file_013_VRAM = ADDR(.file_013);
    .file_013 0x802408F0 : AT(file_013_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_013_TEXT_START = .;
        build-elf/asm/file_013.s.o(.text);
        . = ALIGN(., 16);
        file_013_TEXT_END = .;
        file_013_TEXT_SIZE = ABSOLUTE(file_013_TEXT_END - file_013_TEXT_START);
        file_013_DATA_START = .;
        build-elf/asm/file_013.s.o(.data);
        build-elf/asm/asm/data/file_013_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_013_DATA_END = .;
        file_013_DATA_SIZE = ABSOLUTE(file_013_DATA_END - file_013_DATA_START);
        file_013_RODATA_START = .;
        build-elf/asm/file_013.s.o(.rodata);
        . = ALIGN(., 16);
        file_013_RODATA_END = .;
        file_013_RODATA_SIZE = ABSOLUTE(file_013_RODATA_END - file_013_RODATA_START);
    }
    file_013_bss_VRAM = ADDR(.file_013_bss);
    .file_013_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_013_BSS_START = .;
        build-elf/asm/file_013.s.o(.bss);
        . = ALIGN(., 16);
        file_013_BSS_END = .;
        file_013_BSS_SIZE = ABSOLUTE(file_013_BSS_END - file_013_BSS_START);
    }
    __romPos += SIZEOF(.file_013);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_013_ROM_END = __romPos;
    file_013_VRAM_END = .;

    file_014_ROM_START = __romPos;
    file_014_VRAM = ADDR(.file_014);
    .file_014 0x802408F0 : AT(file_014_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_014_TEXT_START = .;
        build-elf/asm/file_014.s.o(.text);
        . = ALIGN(., 16);
        file_014_TEXT_END = .;
        file_014_TEXT_SIZE = ABSOLUTE(file_014_TEXT_END - file_014_TEXT_START);
        file_014_DATA_START = .;
        build-elf/asm/file_014.s.o(.data);
        build-elf/asm/asm/data/file_014_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_014_DATA_END = .;
        file_014_DATA_SIZE = ABSOLUTE(file_014_DATA_END - file_014_DATA_START);
        file_014_RODATA_START = .;
        build-elf/asm/file_014.s.o(.rodata);
        . = ALIGN(., 16);
        file_014_RODATA_END = .;
        file_014_RODATA_SIZE = ABSOLUTE(file_014_RODATA_END - file_014_RODATA_START);
    }
    file_014_bss_VRAM = ADDR(.file_014_bss);
    .file_014_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_014_BSS_START = .;
        build-elf/asm/file_014.s.o(.bss);
        build-elf/asm/asm/data/file_014_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_014_BSS_END = .;
        file_014_BSS_SIZE = ABSOLUTE(file_014_BSS_END - file_014_BSS_START);
    }
    __romPos += SIZEOF(.file_014);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_014_ROM_END = __romPos;
    file_014_VRAM_END = .;

    file_015_ROM_START = __romPos;
    file_015_VRAM = ADDR(.file_015);
    .file_015 0x802408F0 : AT(file_015_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_015_TEXT_START = .;
        build-elf/asm/file_015.s.o(.text);
        . = ALIGN(., 16);
        file_015_TEXT_END = .;
        file_015_TEXT_SIZE = ABSOLUTE(file_015_TEXT_END - file_015_TEXT_START);
        file_015_DATA_START = .;
        build-elf/asm/file_015.s.o(.data);
        build-elf/asm/asm/data/file_015_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_015_DATA_END = .;
        file_015_DATA_SIZE = ABSOLUTE(file_015_DATA_END - file_015_DATA_START);
        file_015_RODATA_START = .;
        build-elf/asm/file_015.s.o(.rodata);
        . = ALIGN(., 16);
        file_015_RODATA_END = .;
        file_015_RODATA_SIZE = ABSOLUTE(file_015_RODATA_END - file_015_RODATA_START);
    }
    file_015_bss_VRAM = ADDR(.file_015_bss);
    .file_015_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_015_BSS_START = .;
        build-elf/asm/file_015.s.o(.bss);
        build-elf/asm/asm/data/file_015_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_015_BSS_END = .;
        file_015_BSS_SIZE = ABSOLUTE(file_015_BSS_END - file_015_BSS_START);
    }
    __romPos += SIZEOF(.file_015);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_015_ROM_END = __romPos;
    file_015_VRAM_END = .;

    file_016_ROM_START = __romPos;
    file_016_VRAM = ADDR(.file_016);
    .file_016 0x802408F0 : AT(file_016_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_016_TEXT_START = .;
        build-elf/asm/file_016.s.o(.text);
        . = ALIGN(., 16);
        file_016_TEXT_END = .;
        file_016_TEXT_SIZE = ABSOLUTE(file_016_TEXT_END - file_016_TEXT_START);
        file_016_DATA_START = .;
        build-elf/asm/file_016.s.o(.data);
        build-elf/asm/asm/data/file_016_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_016_DATA_END = .;
        file_016_DATA_SIZE = ABSOLUTE(file_016_DATA_END - file_016_DATA_START);
        file_016_RODATA_START = .;
        build-elf/asm/file_016.s.o(.rodata);
        . = ALIGN(., 16);
        file_016_RODATA_END = .;
        file_016_RODATA_SIZE = ABSOLUTE(file_016_RODATA_END - file_016_RODATA_START);
    }
    file_016_bss_VRAM = ADDR(.file_016_bss);
    .file_016_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_016_BSS_START = .;
        build-elf/asm/file_016.s.o(.bss);
        build-elf/asm/asm/data/file_016_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_016_BSS_END = .;
        file_016_BSS_SIZE = ABSOLUTE(file_016_BSS_END - file_016_BSS_START);
    }
    __romPos += SIZEOF(.file_016);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_016_ROM_END = __romPos;
    file_016_VRAM_END = .;

    file_017_ROM_START = __romPos;
    file_017_VRAM = ADDR(.file_017);
    .file_017 0x802408F0 : AT(file_017_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_017_TEXT_START = .;
        build-elf/asm/file_017.s.o(.text);
        . = ALIGN(., 16);
        file_017_TEXT_END = .;
        file_017_TEXT_SIZE = ABSOLUTE(file_017_TEXT_END - file_017_TEXT_START);
        file_017_DATA_START = .;
        build-elf/asm/file_017.s.o(.data);
        build-elf/asm/asm/data/file_017_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_017_DATA_END = .;
        file_017_DATA_SIZE = ABSOLUTE(file_017_DATA_END - file_017_DATA_START);
        file_017_RODATA_START = .;
        build-elf/asm/file_017.s.o(.rodata);
        . = ALIGN(., 16);
        file_017_RODATA_END = .;
        file_017_RODATA_SIZE = ABSOLUTE(file_017_RODATA_END - file_017_RODATA_START);
    }
    file_017_bss_VRAM = ADDR(.file_017_bss);
    .file_017_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_017_BSS_START = .;
        build-elf/asm/file_017.s.o(.bss);
        build-elf/asm/asm/data/file_017_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_017_BSS_END = .;
        file_017_BSS_SIZE = ABSOLUTE(file_017_BSS_END - file_017_BSS_START);
    }
    __romPos += SIZEOF(.file_017);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_017_ROM_END = __romPos;
    file_017_VRAM_END = .;

    file_018_ROM_START = __romPos;
    file_018_VRAM = ADDR(.file_018);
    .file_018 0x802408F0 : AT(file_018_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_018_TEXT_START = .;
        build-elf/asm/file_018.s.o(.text);
        . = ALIGN(., 16);
        file_018_TEXT_END = .;
        file_018_TEXT_SIZE = ABSOLUTE(file_018_TEXT_END - file_018_TEXT_START);
        file_018_DATA_START = .;
        build-elf/asm/file_018.s.o(.data);
        build-elf/asm/asm/data/file_018_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_018_DATA_END = .;
        file_018_DATA_SIZE = ABSOLUTE(file_018_DATA_END - file_018_DATA_START);
        file_018_RODATA_START = .;
        build-elf/asm/file_018.s.o(.rodata);
        . = ALIGN(., 16);
        file_018_RODATA_END = .;
        file_018_RODATA_SIZE = ABSOLUTE(file_018_RODATA_END - file_018_RODATA_START);
    }
    file_018_bss_VRAM = ADDR(.file_018_bss);
    .file_018_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_018_BSS_START = .;
        build-elf/asm/file_018.s.o(.bss);
        build-elf/asm/asm/data/file_018_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_018_BSS_END = .;
        file_018_BSS_SIZE = ABSOLUTE(file_018_BSS_END - file_018_BSS_START);
    }
    __romPos += SIZEOF(.file_018);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_018_ROM_END = __romPos;
    file_018_VRAM_END = .;

    file_019_ROM_START = __romPos;
    file_019_VRAM = ADDR(.file_019);
    .file_019 0x802408F0 : AT(file_019_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_019_TEXT_START = .;
        build-elf/asm/file_019.s.o(.text);
        . = ALIGN(., 16);
        file_019_TEXT_END = .;
        file_019_TEXT_SIZE = ABSOLUTE(file_019_TEXT_END - file_019_TEXT_START);
        file_019_DATA_START = .;
        build-elf/asm/file_019.s.o(.data);
        build-elf/asm/asm/data/file_019_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_019_DATA_END = .;
        file_019_DATA_SIZE = ABSOLUTE(file_019_DATA_END - file_019_DATA_START);
        file_019_RODATA_START = .;
        build-elf/asm/file_019.s.o(.rodata);
        . = ALIGN(., 16);
        file_019_RODATA_END = .;
        file_019_RODATA_SIZE = ABSOLUTE(file_019_RODATA_END - file_019_RODATA_START);
    }
    file_019_bss_VRAM = ADDR(.file_019_bss);
    .file_019_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_019_BSS_START = .;
        build-elf/asm/file_019.s.o(.bss);
        . = ALIGN(., 16);
        file_019_BSS_END = .;
        file_019_BSS_SIZE = ABSOLUTE(file_019_BSS_END - file_019_BSS_START);
    }
    __romPos += SIZEOF(.file_019);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_019_ROM_END = __romPos;
    file_019_VRAM_END = .;

    file_020_ROM_START = __romPos;
    file_020_VRAM = ADDR(.file_020);
    .file_020 0x802408F0 : AT(file_020_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_020_TEXT_START = .;
        build-elf/asm/file_020.s.o(.text);
        . = ALIGN(., 16);
        file_020_TEXT_END = .;
        file_020_TEXT_SIZE = ABSOLUTE(file_020_TEXT_END - file_020_TEXT_START);
        file_020_DATA_START = .;
        build-elf/asm/file_020.s.o(.data);
        build-elf/asm/asm/data/file_020_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_020_DATA_END = .;
        file_020_DATA_SIZE = ABSOLUTE(file_020_DATA_END - file_020_DATA_START);
        file_020_RODATA_START = .;
        build-elf/asm/file_020.s.o(.rodata);
        . = ALIGN(., 16);
        file_020_RODATA_END = .;
        file_020_RODATA_SIZE = ABSOLUTE(file_020_RODATA_END - file_020_RODATA_START);
    }
    file_020_bss_VRAM = ADDR(.file_020_bss);
    .file_020_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_020_BSS_START = .;
        build-elf/asm/file_020.s.o(.bss);
        build-elf/asm/asm/data/file_020_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_020_BSS_END = .;
        file_020_BSS_SIZE = ABSOLUTE(file_020_BSS_END - file_020_BSS_START);
    }
    __romPos += SIZEOF(.file_020);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_020_ROM_END = __romPos;
    file_020_VRAM_END = .;

    file_021_ROM_START = __romPos;
    file_021_VRAM = ADDR(.file_021);
    .file_021 0x802408F0 : AT(file_021_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_021_TEXT_START = .;
        build-elf/asm/file_021.s.o(.text);
        . = ALIGN(., 16);
        file_021_TEXT_END = .;
        file_021_TEXT_SIZE = ABSOLUTE(file_021_TEXT_END - file_021_TEXT_START);
        file_021_DATA_START = .;
        build-elf/asm/file_021.s.o(.data);
        build-elf/asm/asm/data/file_021_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_021_DATA_END = .;
        file_021_DATA_SIZE = ABSOLUTE(file_021_DATA_END - file_021_DATA_START);
        file_021_RODATA_START = .;
        build-elf/asm/file_021.s.o(.rodata);
        . = ALIGN(., 16);
        file_021_RODATA_END = .;
        file_021_RODATA_SIZE = ABSOLUTE(file_021_RODATA_END - file_021_RODATA_START);
    }
    file_021_bss_VRAM = ADDR(.file_021_bss);
    .file_021_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_021_BSS_START = .;
        build-elf/asm/file_021.s.o(.bss);
        build-elf/asm/asm/data/file_021_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_021_BSS_END = .;
        file_021_BSS_SIZE = ABSOLUTE(file_021_BSS_END - file_021_BSS_START);
    }
    __romPos += SIZEOF(.file_021);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_021_ROM_END = __romPos;
    file_021_VRAM_END = .;

    file_022_ROM_START = __romPos;
    file_022_VRAM = ADDR(.file_022);
    .file_022 0x802408F0 : AT(file_022_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_022_TEXT_START = .;
        build-elf/asm/file_022.s.o(.text);
        . = ALIGN(., 16);
        file_022_TEXT_END = .;
        file_022_TEXT_SIZE = ABSOLUTE(file_022_TEXT_END - file_022_TEXT_START);
        file_022_DATA_START = .;
        build-elf/asm/file_022.s.o(.data);
        build-elf/asm/asm/data/file_022_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_022_DATA_END = .;
        file_022_DATA_SIZE = ABSOLUTE(file_022_DATA_END - file_022_DATA_START);
        file_022_RODATA_START = .;
        build-elf/asm/file_022.s.o(.rodata);
        . = ALIGN(., 16);
        file_022_RODATA_END = .;
        file_022_RODATA_SIZE = ABSOLUTE(file_022_RODATA_END - file_022_RODATA_START);
    }
    file_022_bss_VRAM = ADDR(.file_022_bss);
    .file_022_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_022_BSS_START = .;
        build-elf/asm/file_022.s.o(.bss);
        build-elf/asm/asm/data/file_022_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_022_BSS_END = .;
        file_022_BSS_SIZE = ABSOLUTE(file_022_BSS_END - file_022_BSS_START);
    }
    __romPos += SIZEOF(.file_022);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_022_ROM_END = __romPos;
    file_022_VRAM_END = .;

    file_024_ROM_START = __romPos;
    file_024_VRAM = ADDR(.file_024);
    .file_024 0x801BF1A0 : AT(file_024_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_024_TEXT_START = .;
        build-elf/asm/file_024.s.o(.text);
        . = ALIGN(., 16);
        file_024_TEXT_END = .;
        file_024_TEXT_SIZE = ABSOLUTE(file_024_TEXT_END - file_024_TEXT_START);
        file_024_DATA_START = .;
        build-elf/asm/file_024.s.o(.data);
        build-elf/asm/asm/data/file_024_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_024_DATA_END = .;
        file_024_DATA_SIZE = ABSOLUTE(file_024_DATA_END - file_024_DATA_START);
        file_024_RODATA_START = .;
        build-elf/asm/file_024.s.o(.rodata);
        . = ALIGN(., 16);
        file_024_RODATA_END = .;
        file_024_RODATA_SIZE = ABSOLUTE(file_024_RODATA_END - file_024_RODATA_START);
    }
    file_024_bss_VRAM = ADDR(.file_024_bss);
    .file_024_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_024_BSS_START = .;
        build-elf/asm/file_024.s.o(.bss);
        build-elf/asm/asm/data/file_024_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_024_BSS_END = .;
        file_024_BSS_SIZE = ABSOLUTE(file_024_BSS_END - file_024_BSS_START);
    }
    __romPos += SIZEOF(.file_024);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_024_ROM_END = __romPos;
    file_024_VRAM_END = .;

    file_025_ROM_START = __romPos;
    file_025_VRAM = ADDR(.file_025);
    .file_025 0x801BF1A0 : AT(file_025_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_025_TEXT_START = .;
        build-elf/asm/file_025.s.o(.text);
        . = ALIGN(., 16);
        file_025_TEXT_END = .;
        file_025_TEXT_SIZE = ABSOLUTE(file_025_TEXT_END - file_025_TEXT_START);
        file_025_DATA_START = .;
        build-elf/asm/file_025.s.o(.data);
        build-elf/asm/asm/data/file_025_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_025_DATA_END = .;
        file_025_DATA_SIZE = ABSOLUTE(file_025_DATA_END - file_025_DATA_START);
        file_025_RODATA_START = .;
        build-elf/asm/file_025.s.o(.rodata);
        . = ALIGN(., 16);
        file_025_RODATA_END = .;
        file_025_RODATA_SIZE = ABSOLUTE(file_025_RODATA_END - file_025_RODATA_START);
    }
    file_025_bss_VRAM = ADDR(.file_025_bss);
    .file_025_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_025_BSS_START = .;
        build-elf/asm/file_025.s.o(.bss);
        build-elf/asm/asm/data/file_025_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_025_BSS_END = .;
        file_025_BSS_SIZE = ABSOLUTE(file_025_BSS_END - file_025_BSS_START);
    }
    __romPos += SIZEOF(.file_025);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_025_ROM_END = __romPos;
    file_025_VRAM_END = .;

    file_026_ROM_START = __romPos;
    file_026_VRAM = ADDR(.file_026);
    .file_026 0x801E1BE0 : AT(file_026_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_026_TEXT_START = .;
        build-elf/asm/file_026.s.o(.text);
        . = ALIGN(., 16);
        file_026_TEXT_END = .;
        file_026_TEXT_SIZE = ABSOLUTE(file_026_TEXT_END - file_026_TEXT_START);
        file_026_DATA_START = .;
        build-elf/asm/file_026.s.o(.data);
        build-elf/asm/asm/data/file_026_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_026_DATA_END = .;
        file_026_DATA_SIZE = ABSOLUTE(file_026_DATA_END - file_026_DATA_START);
        file_026_RODATA_START = .;
        build-elf/asm/file_026.s.o(.rodata);
        . = ALIGN(., 16);
        file_026_RODATA_END = .;
        file_026_RODATA_SIZE = ABSOLUTE(file_026_RODATA_END - file_026_RODATA_START);
    }
    file_026_bss_VRAM = ADDR(.file_026_bss);
    .file_026_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_026_BSS_START = .;
        build-elf/asm/file_026.s.o(.bss);
        build-elf/asm/asm/data/file_026_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_026_BSS_END = .;
        file_026_BSS_SIZE = ABSOLUTE(file_026_BSS_END - file_026_BSS_START);
    }
    __romPos += SIZEOF(.file_026);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_026_ROM_END = __romPos;
    file_026_VRAM_END = .;

    file_027_ROM_START = __romPos;
    file_027_VRAM = ADDR(.file_027);
    .file_027 0x801E1BE0 : AT(file_027_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_027_TEXT_START = .;
        build-elf/asm/file_027.s.o(.text);
        . = ALIGN(., 16);
        file_027_TEXT_END = .;
        file_027_TEXT_SIZE = ABSOLUTE(file_027_TEXT_END - file_027_TEXT_START);
        file_027_DATA_START = .;
        build-elf/asm/file_027.s.o(.data);
        build-elf/asm/asm/data/file_027_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_027_DATA_END = .;
        file_027_DATA_SIZE = ABSOLUTE(file_027_DATA_END - file_027_DATA_START);
        file_027_RODATA_START = .;
        build-elf/asm/file_027.s.o(.rodata);
        . = ALIGN(., 16);
        file_027_RODATA_END = .;
        file_027_RODATA_SIZE = ABSOLUTE(file_027_RODATA_END - file_027_RODATA_START);
    }
    file_027_bss_VRAM = ADDR(.file_027_bss);
    .file_027_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_027_BSS_START = .;
        build-elf/asm/file_027.s.o(.bss);
        build-elf/asm/asm/data/file_027_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_027_BSS_END = .;
        file_027_BSS_SIZE = ABSOLUTE(file_027_BSS_END - file_027_BSS_START);
    }
    __romPos += SIZEOF(.file_027);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_027_ROM_END = __romPos;
    file_027_VRAM_END = .;

    file_028_ROM_START = __romPos;
    file_028_VRAM = ADDR(.file_028);
    .file_028 0x801E1BE0 : AT(file_028_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_028_TEXT_START = .;
        build-elf/asm/file_028.s.o(.text);
        . = ALIGN(., 16);
        file_028_TEXT_END = .;
        file_028_TEXT_SIZE = ABSOLUTE(file_028_TEXT_END - file_028_TEXT_START);
        file_028_DATA_START = .;
        build-elf/asm/file_028.s.o(.data);
        build-elf/asm/asm/data/file_028_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_028_DATA_END = .;
        file_028_DATA_SIZE = ABSOLUTE(file_028_DATA_END - file_028_DATA_START);
        file_028_RODATA_START = .;
        build-elf/asm/file_028.s.o(.rodata);
        . = ALIGN(., 16);
        file_028_RODATA_END = .;
        file_028_RODATA_SIZE = ABSOLUTE(file_028_RODATA_END - file_028_RODATA_START);
    }
    file_028_bss_VRAM = ADDR(.file_028_bss);
    .file_028_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_028_BSS_START = .;
        build-elf/asm/file_028.s.o(.bss);
        build-elf/asm/asm/data/file_028_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_028_BSS_END = .;
        file_028_BSS_SIZE = ABSOLUTE(file_028_BSS_END - file_028_BSS_START);
    }
    __romPos += SIZEOF(.file_028);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_028_ROM_END = __romPos;
    file_028_VRAM_END = .;

    file_029_ROM_START = __romPos;
    file_029_VRAM = ADDR(.file_029);
    .file_029 0x801E1BE0 : AT(file_029_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_029_TEXT_START = .;
        build-elf/asm/file_029.s.o(.text);
        . = ALIGN(., 16);
        file_029_TEXT_END = .;
        file_029_TEXT_SIZE = ABSOLUTE(file_029_TEXT_END - file_029_TEXT_START);
        file_029_DATA_START = .;
        build-elf/asm/file_029.s.o(.data);
        build-elf/asm/asm/data/file_029_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_029_DATA_END = .;
        file_029_DATA_SIZE = ABSOLUTE(file_029_DATA_END - file_029_DATA_START);
        file_029_RODATA_START = .;
        build-elf/asm/file_029.s.o(.rodata);
        . = ALIGN(., 16);
        file_029_RODATA_END = .;
        file_029_RODATA_SIZE = ABSOLUTE(file_029_RODATA_END - file_029_RODATA_START);
    }
    file_029_bss_VRAM = ADDR(.file_029_bss);
    .file_029_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_029_BSS_START = .;
        build-elf/asm/file_029.s.o(.bss);
        . = ALIGN(., 16);
        file_029_BSS_END = .;
        file_029_BSS_SIZE = ABSOLUTE(file_029_BSS_END - file_029_BSS_START);
    }
    __romPos += SIZEOF(.file_029);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_029_ROM_END = __romPos;
    file_029_VRAM_END = .;

    file_030_ROM_START = __romPos;
    file_030_VRAM = ADDR(.file_030);
    .file_030 0x801E1BE0 : AT(file_030_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_030_TEXT_START = .;
        build-elf/asm/file_030.s.o(.text);
        . = ALIGN(., 16);
        file_030_TEXT_END = .;
        file_030_TEXT_SIZE = ABSOLUTE(file_030_TEXT_END - file_030_TEXT_START);
        file_030_DATA_START = .;
        build-elf/asm/file_030.s.o(.data);
        build-elf/asm/asm/data/file_030_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_030_DATA_END = .;
        file_030_DATA_SIZE = ABSOLUTE(file_030_DATA_END - file_030_DATA_START);
        file_030_RODATA_START = .;
        build-elf/asm/file_030.s.o(.rodata);
        . = ALIGN(., 16);
        file_030_RODATA_END = .;
        file_030_RODATA_SIZE = ABSOLUTE(file_030_RODATA_END - file_030_RODATA_START);
    }
    file_030_bss_VRAM = ADDR(.file_030_bss);
    .file_030_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_030_BSS_START = .;
        build-elf/asm/file_030.s.o(.bss);
        . = ALIGN(., 16);
        file_030_BSS_END = .;
        file_030_BSS_SIZE = ABSOLUTE(file_030_BSS_END - file_030_BSS_START);
    }
    __romPos += SIZEOF(.file_030);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_030_ROM_END = __romPos;
    file_030_VRAM_END = .;

    file_031_ROM_START = __romPos;
    file_031_VRAM = ADDR(.file_031);
    .file_031 0x801E1BE0 : AT(file_031_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_031_TEXT_START = .;
        build-elf/asm/file_031.s.o(.text);
        . = ALIGN(., 16);
        file_031_TEXT_END = .;
        file_031_TEXT_SIZE = ABSOLUTE(file_031_TEXT_END - file_031_TEXT_START);
        file_031_DATA_START = .;
        build-elf/asm/file_031.s.o(.data);
        build-elf/asm/asm/data/file_031_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_031_DATA_END = .;
        file_031_DATA_SIZE = ABSOLUTE(file_031_DATA_END - file_031_DATA_START);
        file_031_RODATA_START = .;
        build-elf/asm/file_031.s.o(.rodata);
        . = ALIGN(., 16);
        file_031_RODATA_END = .;
        file_031_RODATA_SIZE = ABSOLUTE(file_031_RODATA_END - file_031_RODATA_START);
    }
    file_031_bss_VRAM = ADDR(.file_031_bss);
    .file_031_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_031_BSS_START = .;
        build-elf/asm/file_031.s.o(.bss);
        . = ALIGN(., 16);
        file_031_BSS_END = .;
        file_031_BSS_SIZE = ABSOLUTE(file_031_BSS_END - file_031_BSS_START);
    }
    __romPos += SIZEOF(.file_031);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_031_ROM_END = __romPos;
    file_031_VRAM_END = .;

    file_032_ROM_START = __romPos;
    file_032_VRAM = ADDR(.file_032);
    .file_032 0x801E1BE0 : AT(file_032_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_032_TEXT_START = .;
        build-elf/asm/file_032.s.o(.text);
        . = ALIGN(., 16);
        file_032_TEXT_END = .;
        file_032_TEXT_SIZE = ABSOLUTE(file_032_TEXT_END - file_032_TEXT_START);
        file_032_DATA_START = .;
        build-elf/asm/file_032.s.o(.data);
        build-elf/asm/asm/data/file_032_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_032_DATA_END = .;
        file_032_DATA_SIZE = ABSOLUTE(file_032_DATA_END - file_032_DATA_START);
        file_032_RODATA_START = .;
        build-elf/asm/file_032.s.o(.rodata);
        . = ALIGN(., 16);
        file_032_RODATA_END = .;
        file_032_RODATA_SIZE = ABSOLUTE(file_032_RODATA_END - file_032_RODATA_START);
    }
    file_032_bss_VRAM = ADDR(.file_032_bss);
    .file_032_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_032_BSS_START = .;
        build-elf/asm/file_032.s.o(.bss);
        . = ALIGN(., 16);
        file_032_BSS_END = .;
        file_032_BSS_SIZE = ABSOLUTE(file_032_BSS_END - file_032_BSS_START);
    }
    __romPos += SIZEOF(.file_032);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_032_ROM_END = __romPos;
    file_032_VRAM_END = .;

    file_033_ROM_START = __romPos;
    file_033_VRAM = ADDR(.file_033);
    .file_033 0x801E1BE0 : AT(file_033_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_033_TEXT_START = .;
        build-elf/asm/file_033.s.o(.text);
        . = ALIGN(., 16);
        file_033_TEXT_END = .;
        file_033_TEXT_SIZE = ABSOLUTE(file_033_TEXT_END - file_033_TEXT_START);
        file_033_DATA_START = .;
        build-elf/asm/file_033.s.o(.data);
        build-elf/asm/asm/data/file_033_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_033_DATA_END = .;
        file_033_DATA_SIZE = ABSOLUTE(file_033_DATA_END - file_033_DATA_START);
        file_033_RODATA_START = .;
        build-elf/asm/file_033.s.o(.rodata);
        . = ALIGN(., 16);
        file_033_RODATA_END = .;
        file_033_RODATA_SIZE = ABSOLUTE(file_033_RODATA_END - file_033_RODATA_START);
    }
    file_033_bss_VRAM = ADDR(.file_033_bss);
    .file_033_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_033_BSS_START = .;
        build-elf/asm/file_033.s.o(.bss);
        . = ALIGN(., 16);
        file_033_BSS_END = .;
        file_033_BSS_SIZE = ABSOLUTE(file_033_BSS_END - file_033_BSS_START);
    }
    __romPos += SIZEOF(.file_033);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_033_ROM_END = __romPos;
    file_033_VRAM_END = .;

    file_034_ROM_START = __romPos;
    file_034_VRAM = ADDR(.file_034);
    .file_034 0x801E1BE0 : AT(file_034_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_034_TEXT_START = .;
        build-elf/asm/file_034.s.o(.text);
        . = ALIGN(., 16);
        file_034_TEXT_END = .;
        file_034_TEXT_SIZE = ABSOLUTE(file_034_TEXT_END - file_034_TEXT_START);
        file_034_DATA_START = .;
        build-elf/asm/file_034.s.o(.data);
        build-elf/asm/asm/data/file_034_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_034_DATA_END = .;
        file_034_DATA_SIZE = ABSOLUTE(file_034_DATA_END - file_034_DATA_START);
        file_034_RODATA_START = .;
        build-elf/asm/file_034.s.o(.rodata);
        . = ALIGN(., 16);
        file_034_RODATA_END = .;
        file_034_RODATA_SIZE = ABSOLUTE(file_034_RODATA_END - file_034_RODATA_START);
    }
    file_034_bss_VRAM = ADDR(.file_034_bss);
    .file_034_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_034_BSS_START = .;
        build-elf/asm/file_034.s.o(.bss);
        . = ALIGN(., 16);
        file_034_BSS_END = .;
        file_034_BSS_SIZE = ABSOLUTE(file_034_BSS_END - file_034_BSS_START);
    }
    __romPos += SIZEOF(.file_034);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_034_ROM_END = __romPos;
    file_034_VRAM_END = .;

    file_035_ROM_START = __romPos;
    file_035_VRAM = ADDR(.file_035);
    .file_035 0x801E1BE0 : AT(file_035_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_035_TEXT_START = .;
        build-elf/asm/file_035.s.o(.text);
        . = ALIGN(., 16);
        file_035_TEXT_END = .;
        file_035_TEXT_SIZE = ABSOLUTE(file_035_TEXT_END - file_035_TEXT_START);
        file_035_DATA_START = .;
        build-elf/asm/file_035.s.o(.data);
        build-elf/asm/asm/data/file_035_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_035_DATA_END = .;
        file_035_DATA_SIZE = ABSOLUTE(file_035_DATA_END - file_035_DATA_START);
        file_035_RODATA_START = .;
        build-elf/asm/file_035.s.o(.rodata);
        . = ALIGN(., 16);
        file_035_RODATA_END = .;
        file_035_RODATA_SIZE = ABSOLUTE(file_035_RODATA_END - file_035_RODATA_START);
    }
    file_035_bss_VRAM = ADDR(.file_035_bss);
    .file_035_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_035_BSS_START = .;
        build-elf/asm/file_035.s.o(.bss);
        . = ALIGN(., 16);
        file_035_BSS_END = .;
        file_035_BSS_SIZE = ABSOLUTE(file_035_BSS_END - file_035_BSS_START);
    }
    __romPos += SIZEOF(.file_035);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_035_ROM_END = __romPos;
    file_035_VRAM_END = .;

    file_036_ROM_START = __romPos;
    file_036_VRAM = ADDR(.file_036);
    .file_036 0x801E1BE0 : AT(file_036_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_036_TEXT_START = .;
        build-elf/asm/file_036.s.o(.text);
        . = ALIGN(., 16);
        file_036_TEXT_END = .;
        file_036_TEXT_SIZE = ABSOLUTE(file_036_TEXT_END - file_036_TEXT_START);
        file_036_DATA_START = .;
        build-elf/asm/file_036.s.o(.data);
        build-elf/asm/asm/data/file_036_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_036_DATA_END = .;
        file_036_DATA_SIZE = ABSOLUTE(file_036_DATA_END - file_036_DATA_START);
        file_036_RODATA_START = .;
        build-elf/asm/file_036.s.o(.rodata);
        . = ALIGN(., 16);
        file_036_RODATA_END = .;
        file_036_RODATA_SIZE = ABSOLUTE(file_036_RODATA_END - file_036_RODATA_START);
    }
    file_036_bss_VRAM = ADDR(.file_036_bss);
    .file_036_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_036_BSS_START = .;
        build-elf/asm/file_036.s.o(.bss);
        build-elf/asm/asm/data/file_036_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_036_BSS_END = .;
        file_036_BSS_SIZE = ABSOLUTE(file_036_BSS_END - file_036_BSS_START);
    }
    __romPos += SIZEOF(.file_036);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_036_ROM_END = __romPos;
    file_036_VRAM_END = .;

    file_037_ROM_START = __romPos;
    file_037_VRAM = ADDR(.file_037);
    .file_037 0x801E1BE0 : AT(file_037_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_037_TEXT_START = .;
        build-elf/asm/file_037.s.o(.text);
        . = ALIGN(., 16);
        file_037_TEXT_END = .;
        file_037_TEXT_SIZE = ABSOLUTE(file_037_TEXT_END - file_037_TEXT_START);
        file_037_DATA_START = .;
        build-elf/asm/file_037.s.o(.data);
        build-elf/asm/asm/data/file_037_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_037_DATA_END = .;
        file_037_DATA_SIZE = ABSOLUTE(file_037_DATA_END - file_037_DATA_START);
        file_037_RODATA_START = .;
        build-elf/asm/file_037.s.o(.rodata);
        . = ALIGN(., 16);
        file_037_RODATA_END = .;
        file_037_RODATA_SIZE = ABSOLUTE(file_037_RODATA_END - file_037_RODATA_START);
    }
    file_037_bss_VRAM = ADDR(.file_037_bss);
    .file_037_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_037_BSS_START = .;
        build-elf/asm/file_037.s.o(.bss);
        build-elf/asm/asm/data/file_037_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_037_BSS_END = .;
        file_037_BSS_SIZE = ABSOLUTE(file_037_BSS_END - file_037_BSS_START);
    }
    __romPos += SIZEOF(.file_037);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_037_ROM_END = __romPos;
    file_037_VRAM_END = .;

    file_038_ROM_START = __romPos;
    file_038_VRAM = ADDR(.file_038);
    .file_038 0x801E1BE0 : AT(file_038_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_038_TEXT_START = .;
        build-elf/asm/file_038.s.o(.text);
        . = ALIGN(., 16);
        file_038_TEXT_END = .;
        file_038_TEXT_SIZE = ABSOLUTE(file_038_TEXT_END - file_038_TEXT_START);
        file_038_DATA_START = .;
        build-elf/asm/file_038.s.o(.data);
        build-elf/asm/asm/data/file_038_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_038_DATA_END = .;
        file_038_DATA_SIZE = ABSOLUTE(file_038_DATA_END - file_038_DATA_START);
        file_038_RODATA_START = .;
        build-elf/asm/file_038.s.o(.rodata);
        . = ALIGN(., 16);
        file_038_RODATA_END = .;
        file_038_RODATA_SIZE = ABSOLUTE(file_038_RODATA_END - file_038_RODATA_START);
    }
    file_038_bss_VRAM = ADDR(.file_038_bss);
    .file_038_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_038_BSS_START = .;
        build-elf/asm/file_038.s.o(.bss);
        . = ALIGN(., 16);
        file_038_BSS_END = .;
        file_038_BSS_SIZE = ABSOLUTE(file_038_BSS_END - file_038_BSS_START);
    }
    __romPos += SIZEOF(.file_038);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_038_ROM_END = __romPos;
    file_038_VRAM_END = .;

    file_039_ROM_START = __romPos;
    file_039_VRAM = ADDR(.file_039);
    .file_039 0x801E1BE0 : AT(file_039_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_039_TEXT_START = .;
        build-elf/asm/file_039.s.o(.text);
        . = ALIGN(., 16);
        file_039_TEXT_END = .;
        file_039_TEXT_SIZE = ABSOLUTE(file_039_TEXT_END - file_039_TEXT_START);
        file_039_DATA_START = .;
        build-elf/asm/file_039.s.o(.data);
        build-elf/asm/asm/data/file_039_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_039_DATA_END = .;
        file_039_DATA_SIZE = ABSOLUTE(file_039_DATA_END - file_039_DATA_START);
        file_039_RODATA_START = .;
        build-elf/asm/file_039.s.o(.rodata);
        . = ALIGN(., 16);
        file_039_RODATA_END = .;
        file_039_RODATA_SIZE = ABSOLUTE(file_039_RODATA_END - file_039_RODATA_START);
    }
    file_039_bss_VRAM = ADDR(.file_039_bss);
    .file_039_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_039_BSS_START = .;
        build-elf/asm/file_039.s.o(.bss);
        build-elf/asm/asm/data/file_039_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_039_BSS_END = .;
        file_039_BSS_SIZE = ABSOLUTE(file_039_BSS_END - file_039_BSS_START);
    }
    __romPos += SIZEOF(.file_039);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_039_ROM_END = __romPos;
    file_039_VRAM_END = .;

    file_040_ROM_START = __romPos;
    file_040_VRAM = ADDR(.file_040);
    .file_040 0x801E1BE0 : AT(file_040_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_040_TEXT_START = .;
        build-elf/asm/file_040.s.o(.text);
        . = ALIGN(., 16);
        file_040_TEXT_END = .;
        file_040_TEXT_SIZE = ABSOLUTE(file_040_TEXT_END - file_040_TEXT_START);
        file_040_DATA_START = .;
        build-elf/asm/file_040.s.o(.data);
        build-elf/asm/asm/data/file_040_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_040_DATA_END = .;
        file_040_DATA_SIZE = ABSOLUTE(file_040_DATA_END - file_040_DATA_START);
        file_040_RODATA_START = .;
        build-elf/asm/file_040.s.o(.rodata);
        . = ALIGN(., 16);
        file_040_RODATA_END = .;
        file_040_RODATA_SIZE = ABSOLUTE(file_040_RODATA_END - file_040_RODATA_START);
    }
    file_040_bss_VRAM = ADDR(.file_040_bss);
    .file_040_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_040_BSS_START = .;
        build-elf/asm/file_040.s.o(.bss);
        build-elf/asm/asm/data/file_040_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_040_BSS_END = .;
        file_040_BSS_SIZE = ABSOLUTE(file_040_BSS_END - file_040_BSS_START);
    }
    __romPos += SIZEOF(.file_040);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_040_ROM_END = __romPos;
    file_040_VRAM_END = .;

    file_041_ROM_START = __romPos;
    file_041_VRAM = ADDR(.file_041);
    .file_041 0x801E1BE0 : AT(file_041_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_041_TEXT_START = .;
        build-elf/asm/file_041.s.o(.text);
        . = ALIGN(., 16);
        file_041_TEXT_END = .;
        file_041_TEXT_SIZE = ABSOLUTE(file_041_TEXT_END - file_041_TEXT_START);
        file_041_DATA_START = .;
        build-elf/asm/file_041.s.o(.data);
        build-elf/asm/asm/data/file_041_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_041_DATA_END = .;
        file_041_DATA_SIZE = ABSOLUTE(file_041_DATA_END - file_041_DATA_START);
        file_041_RODATA_START = .;
        build-elf/asm/file_041.s.o(.rodata);
        . = ALIGN(., 16);
        file_041_RODATA_END = .;
        file_041_RODATA_SIZE = ABSOLUTE(file_041_RODATA_END - file_041_RODATA_START);
    }
    file_041_bss_VRAM = ADDR(.file_041_bss);
    .file_041_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_041_BSS_START = .;
        build-elf/asm/file_041.s.o(.bss);
        build-elf/asm/asm/data/file_041_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_041_BSS_END = .;
        file_041_BSS_SIZE = ABSOLUTE(file_041_BSS_END - file_041_BSS_START);
    }
    __romPos += SIZEOF(.file_041);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_041_ROM_END = __romPos;
    file_041_VRAM_END = .;

    file_042_ROM_START = __romPos;
    file_042_VRAM = ADDR(.file_042);
    .file_042 0x801E1BE0 : AT(file_042_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_042_TEXT_START = .;
        build-elf/asm/file_042.s.o(.text);
        . = ALIGN(., 16);
        file_042_TEXT_END = .;
        file_042_TEXT_SIZE = ABSOLUTE(file_042_TEXT_END - file_042_TEXT_START);
        file_042_DATA_START = .;
        build-elf/asm/file_042.s.o(.data);
        build-elf/asm/asm/data/file_042_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_042_DATA_END = .;
        file_042_DATA_SIZE = ABSOLUTE(file_042_DATA_END - file_042_DATA_START);
        file_042_RODATA_START = .;
        build-elf/asm/file_042.s.o(.rodata);
        . = ALIGN(., 16);
        file_042_RODATA_END = .;
        file_042_RODATA_SIZE = ABSOLUTE(file_042_RODATA_END - file_042_RODATA_START);
    }
    file_042_bss_VRAM = ADDR(.file_042_bss);
    .file_042_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_042_BSS_START = .;
        build-elf/asm/file_042.s.o(.bss);
        . = ALIGN(., 16);
        file_042_BSS_END = .;
        file_042_BSS_SIZE = ABSOLUTE(file_042_BSS_END - file_042_BSS_START);
    }
    __romPos += SIZEOF(.file_042);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_042_ROM_END = __romPos;
    file_042_VRAM_END = .;

    file_043_ROM_START = __romPos;
    file_043_VRAM = ADDR(.file_043);
    .file_043 0x801E1BE0 : AT(file_043_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_043_TEXT_START = .;
        build-elf/asm/file_043.s.o(.text);
        . = ALIGN(., 16);
        file_043_TEXT_END = .;
        file_043_TEXT_SIZE = ABSOLUTE(file_043_TEXT_END - file_043_TEXT_START);
        file_043_DATA_START = .;
        build-elf/asm/file_043.s.o(.data);
        build-elf/asm/asm/data/file_043_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_043_DATA_END = .;
        file_043_DATA_SIZE = ABSOLUTE(file_043_DATA_END - file_043_DATA_START);
        file_043_RODATA_START = .;
        build-elf/asm/file_043.s.o(.rodata);
        . = ALIGN(., 16);
        file_043_RODATA_END = .;
        file_043_RODATA_SIZE = ABSOLUTE(file_043_RODATA_END - file_043_RODATA_START);
    }
    file_043_bss_VRAM = ADDR(.file_043_bss);
    .file_043_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_043_BSS_START = .;
        build-elf/asm/file_043.s.o(.bss);
        . = ALIGN(., 16);
        file_043_BSS_END = .;
        file_043_BSS_SIZE = ABSOLUTE(file_043_BSS_END - file_043_BSS_START);
    }
    __romPos += SIZEOF(.file_043);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_043_ROM_END = __romPos;
    file_043_VRAM_END = .;

    file_044_ROM_START = __romPos;
    file_044_VRAM = ADDR(.file_044);
    .file_044 0x801E1BE0 : AT(file_044_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_044_TEXT_START = .;
        build-elf/asm/file_044.s.o(.text);
        . = ALIGN(., 16);
        file_044_TEXT_END = .;
        file_044_TEXT_SIZE = ABSOLUTE(file_044_TEXT_END - file_044_TEXT_START);
        file_044_DATA_START = .;
        build-elf/asm/file_044.s.o(.data);
        build-elf/asm/asm/data/file_044_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_044_DATA_END = .;
        file_044_DATA_SIZE = ABSOLUTE(file_044_DATA_END - file_044_DATA_START);
        file_044_RODATA_START = .;
        build-elf/asm/file_044.s.o(.rodata);
        . = ALIGN(., 16);
        file_044_RODATA_END = .;
        file_044_RODATA_SIZE = ABSOLUTE(file_044_RODATA_END - file_044_RODATA_START);
    }
    file_044_bss_VRAM = ADDR(.file_044_bss);
    .file_044_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_044_BSS_START = .;
        build-elf/asm/file_044.s.o(.bss);
        build-elf/asm/asm/data/file_044_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_044_BSS_END = .;
        file_044_BSS_SIZE = ABSOLUTE(file_044_BSS_END - file_044_BSS_START);
    }
    __romPos += SIZEOF(.file_044);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_044_ROM_END = __romPos;
    file_044_VRAM_END = .;

    file_045_ROM_START = __romPos;
    file_045_VRAM = ADDR(.file_045);
    .file_045 0x801E1BE0 : AT(file_045_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_045_TEXT_START = .;
        build-elf/asm/file_045.s.o(.text);
        . = ALIGN(., 16);
        file_045_TEXT_END = .;
        file_045_TEXT_SIZE = ABSOLUTE(file_045_TEXT_END - file_045_TEXT_START);
        file_045_DATA_START = .;
        build-elf/asm/file_045.s.o(.data);
        build-elf/asm/asm/data/file_045_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_045_DATA_END = .;
        file_045_DATA_SIZE = ABSOLUTE(file_045_DATA_END - file_045_DATA_START);
        file_045_RODATA_START = .;
        build-elf/asm/file_045.s.o(.rodata);
        . = ALIGN(., 16);
        file_045_RODATA_END = .;
        file_045_RODATA_SIZE = ABSOLUTE(file_045_RODATA_END - file_045_RODATA_START);
    }
    file_045_bss_VRAM = ADDR(.file_045_bss);
    .file_045_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_045_BSS_START = .;
        build-elf/asm/file_045.s.o(.bss);
        build-elf/asm/asm/data/file_045_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_045_BSS_END = .;
        file_045_BSS_SIZE = ABSOLUTE(file_045_BSS_END - file_045_BSS_START);
    }
    __romPos += SIZEOF(.file_045);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_045_ROM_END = __romPos;
    file_045_VRAM_END = .;

    file_046_ROM_START = __romPos;
    file_046_VRAM = ADDR(.file_046);
    .file_046 0x801E1BE0 : AT(file_046_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_046_TEXT_START = .;
        build-elf/asm/file_046.s.o(.text);
        . = ALIGN(., 16);
        file_046_TEXT_END = .;
        file_046_TEXT_SIZE = ABSOLUTE(file_046_TEXT_END - file_046_TEXT_START);
        file_046_DATA_START = .;
        build-elf/asm/file_046.s.o(.data);
        build-elf/asm/asm/data/file_046_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_046_DATA_END = .;
        file_046_DATA_SIZE = ABSOLUTE(file_046_DATA_END - file_046_DATA_START);
        file_046_RODATA_START = .;
        build-elf/asm/file_046.s.o(.rodata);
        . = ALIGN(., 16);
        file_046_RODATA_END = .;
        file_046_RODATA_SIZE = ABSOLUTE(file_046_RODATA_END - file_046_RODATA_START);
    }
    file_046_bss_VRAM = ADDR(.file_046_bss);
    .file_046_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_046_BSS_START = .;
        build-elf/asm/file_046.s.o(.bss);
        . = ALIGN(., 16);
        file_046_BSS_END = .;
        file_046_BSS_SIZE = ABSOLUTE(file_046_BSS_END - file_046_BSS_START);
    }
    __romPos += SIZEOF(.file_046);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_046_ROM_END = __romPos;
    file_046_VRAM_END = .;

    file_047_ROM_START = __romPos;
    file_047_VRAM = ADDR(.file_047);
    .file_047 0x801E1BE0 : AT(file_047_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_047_TEXT_START = .;
        build-elf/asm/file_047.s.o(.text);
        . = ALIGN(., 16);
        file_047_TEXT_END = .;
        file_047_TEXT_SIZE = ABSOLUTE(file_047_TEXT_END - file_047_TEXT_START);
        file_047_DATA_START = .;
        build-elf/asm/file_047.s.o(.data);
        build-elf/asm/asm/data/file_047_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_047_DATA_END = .;
        file_047_DATA_SIZE = ABSOLUTE(file_047_DATA_END - file_047_DATA_START);
        file_047_RODATA_START = .;
        build-elf/asm/file_047.s.o(.rodata);
        . = ALIGN(., 16);
        file_047_RODATA_END = .;
        file_047_RODATA_SIZE = ABSOLUTE(file_047_RODATA_END - file_047_RODATA_START);
    }
    file_047_bss_VRAM = ADDR(.file_047_bss);
    .file_047_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_047_BSS_START = .;
        build-elf/asm/file_047.s.o(.bss);
        build-elf/asm/asm/data/file_047_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_047_BSS_END = .;
        file_047_BSS_SIZE = ABSOLUTE(file_047_BSS_END - file_047_BSS_START);
    }
    __romPos += SIZEOF(.file_047);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_047_ROM_END = __romPos;
    file_047_VRAM_END = .;

    file_048_ROM_START = __romPos;
    file_048_VRAM = ADDR(.file_048);
    .file_048 0x801E1BE0 : AT(file_048_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_048_TEXT_START = .;
        build-elf/asm/file_048.s.o(.text);
        . = ALIGN(., 16);
        file_048_TEXT_END = .;
        file_048_TEXT_SIZE = ABSOLUTE(file_048_TEXT_END - file_048_TEXT_START);
        file_048_DATA_START = .;
        build-elf/asm/file_048.s.o(.data);
        build-elf/asm/asm/data/file_048_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_048_DATA_END = .;
        file_048_DATA_SIZE = ABSOLUTE(file_048_DATA_END - file_048_DATA_START);
        file_048_RODATA_START = .;
        build-elf/asm/file_048.s.o(.rodata);
        . = ALIGN(., 16);
        file_048_RODATA_END = .;
        file_048_RODATA_SIZE = ABSOLUTE(file_048_RODATA_END - file_048_RODATA_START);
    }
    file_048_bss_VRAM = ADDR(.file_048_bss);
    .file_048_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_048_BSS_START = .;
        build-elf/asm/file_048.s.o(.bss);
        build-elf/asm/asm/data/file_048_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_048_BSS_END = .;
        file_048_BSS_SIZE = ABSOLUTE(file_048_BSS_END - file_048_BSS_START);
    }
    __romPos += SIZEOF(.file_048);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_048_ROM_END = __romPos;
    file_048_VRAM_END = .;

    file_049_ROM_START = __romPos;
    file_049_VRAM = ADDR(.file_049);
    .file_049 0x801E1BE0 : AT(file_049_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_049_TEXT_START = .;
        build-elf/asm/file_049.s.o(.text);
        . = ALIGN(., 16);
        file_049_TEXT_END = .;
        file_049_TEXT_SIZE = ABSOLUTE(file_049_TEXT_END - file_049_TEXT_START);
        file_049_DATA_START = .;
        build-elf/asm/file_049.s.o(.data);
        build-elf/asm/asm/data/file_049_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_049_DATA_END = .;
        file_049_DATA_SIZE = ABSOLUTE(file_049_DATA_END - file_049_DATA_START);
        file_049_RODATA_START = .;
        build-elf/asm/file_049.s.o(.rodata);
        . = ALIGN(., 16);
        file_049_RODATA_END = .;
        file_049_RODATA_SIZE = ABSOLUTE(file_049_RODATA_END - file_049_RODATA_START);
    }
    file_049_bss_VRAM = ADDR(.file_049_bss);
    .file_049_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_049_BSS_START = .;
        build-elf/asm/file_049.s.o(.bss);
        build-elf/asm/asm/data/file_049_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_049_BSS_END = .;
        file_049_BSS_SIZE = ABSOLUTE(file_049_BSS_END - file_049_BSS_START);
    }
    __romPos += SIZEOF(.file_049);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_049_ROM_END = __romPos;
    file_049_VRAM_END = .;

    file_050_ROM_START = __romPos;
    file_050_VRAM = ADDR(.file_050);
    .file_050 0x801E1BE0 : AT(file_050_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_050_TEXT_START = .;
        build-elf/asm/file_050.s.o(.text);
        . = ALIGN(., 16);
        file_050_TEXT_END = .;
        file_050_TEXT_SIZE = ABSOLUTE(file_050_TEXT_END - file_050_TEXT_START);
        file_050_DATA_START = .;
        build-elf/asm/file_050.s.o(.data);
        build-elf/asm/asm/data/file_050_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_050_DATA_END = .;
        file_050_DATA_SIZE = ABSOLUTE(file_050_DATA_END - file_050_DATA_START);
        file_050_RODATA_START = .;
        build-elf/asm/file_050.s.o(.rodata);
        . = ALIGN(., 16);
        file_050_RODATA_END = .;
        file_050_RODATA_SIZE = ABSOLUTE(file_050_RODATA_END - file_050_RODATA_START);
    }
    file_050_bss_VRAM = ADDR(.file_050_bss);
    .file_050_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_050_BSS_START = .;
        build-elf/asm/file_050.s.o(.bss);
        build-elf/asm/asm/data/file_050_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_050_BSS_END = .;
        file_050_BSS_SIZE = ABSOLUTE(file_050_BSS_END - file_050_BSS_START);
    }
    __romPos += SIZEOF(.file_050);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_050_ROM_END = __romPos;
    file_050_VRAM_END = .;

    file_051_ROM_START = __romPos;
    file_051_VRAM = ADDR(.file_051);
    .file_051 0x801E1BE0 : AT(file_051_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_051_TEXT_START = .;
        build-elf/asm/file_051.s.o(.text);
        . = ALIGN(., 16);
        file_051_TEXT_END = .;
        file_051_TEXT_SIZE = ABSOLUTE(file_051_TEXT_END - file_051_TEXT_START);
        file_051_DATA_START = .;
        build-elf/asm/file_051.s.o(.data);
        build-elf/asm/asm/data/file_051_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_051_DATA_END = .;
        file_051_DATA_SIZE = ABSOLUTE(file_051_DATA_END - file_051_DATA_START);
        file_051_RODATA_START = .;
        build-elf/asm/file_051.s.o(.rodata);
        . = ALIGN(., 16);
        file_051_RODATA_END = .;
        file_051_RODATA_SIZE = ABSOLUTE(file_051_RODATA_END - file_051_RODATA_START);
    }
    file_051_bss_VRAM = ADDR(.file_051_bss);
    .file_051_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_051_BSS_START = .;
        build-elf/asm/file_051.s.o(.bss);
        build-elf/asm/asm/data/file_051_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_051_BSS_END = .;
        file_051_BSS_SIZE = ABSOLUTE(file_051_BSS_END - file_051_BSS_START);
    }
    __romPos += SIZEOF(.file_051);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_051_ROM_END = __romPos;
    file_051_VRAM_END = .;

    file_052_ROM_START = __romPos;
    file_052_VRAM = ADDR(.file_052);
    .file_052 0x801E1BE0 : AT(file_052_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_052_TEXT_START = .;
        build-elf/asm/file_052.s.o(.text);
        . = ALIGN(., 16);
        file_052_TEXT_END = .;
        file_052_TEXT_SIZE = ABSOLUTE(file_052_TEXT_END - file_052_TEXT_START);
        file_052_DATA_START = .;
        build-elf/asm/file_052.s.o(.data);
        build-elf/asm/asm/data/file_052_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_052_DATA_END = .;
        file_052_DATA_SIZE = ABSOLUTE(file_052_DATA_END - file_052_DATA_START);
        file_052_RODATA_START = .;
        build-elf/asm/file_052.s.o(.rodata);
        . = ALIGN(., 16);
        file_052_RODATA_END = .;
        file_052_RODATA_SIZE = ABSOLUTE(file_052_RODATA_END - file_052_RODATA_START);
    }
    file_052_bss_VRAM = ADDR(.file_052_bss);
    .file_052_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_052_BSS_START = .;
        build-elf/asm/file_052.s.o(.bss);
        build-elf/asm/asm/data/file_052_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_052_BSS_END = .;
        file_052_BSS_SIZE = ABSOLUTE(file_052_BSS_END - file_052_BSS_START);
    }
    __romPos += SIZEOF(.file_052);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_052_ROM_END = __romPos;
    file_052_VRAM_END = .;

    file_053_ROM_START = __romPos;
    file_053_VRAM = ADDR(.file_053);
    .file_053 0x801E1BE0 : AT(file_053_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_053_TEXT_START = .;
        build-elf/asm/file_053.s.o(.text);
        . = ALIGN(., 16);
        file_053_TEXT_END = .;
        file_053_TEXT_SIZE = ABSOLUTE(file_053_TEXT_END - file_053_TEXT_START);
        file_053_DATA_START = .;
        build-elf/asm/file_053.s.o(.data);
        build-elf/asm/asm/data/file_053_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_053_DATA_END = .;
        file_053_DATA_SIZE = ABSOLUTE(file_053_DATA_END - file_053_DATA_START);
        file_053_RODATA_START = .;
        build-elf/asm/file_053.s.o(.rodata);
        . = ALIGN(., 16);
        file_053_RODATA_END = .;
        file_053_RODATA_SIZE = ABSOLUTE(file_053_RODATA_END - file_053_RODATA_START);
    }
    file_053_bss_VRAM = ADDR(.file_053_bss);
    .file_053_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_053_BSS_START = .;
        build-elf/asm/file_053.s.o(.bss);
        build-elf/asm/asm/data/file_053_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_053_BSS_END = .;
        file_053_BSS_SIZE = ABSOLUTE(file_053_BSS_END - file_053_BSS_START);
    }
    __romPos += SIZEOF(.file_053);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_053_ROM_END = __romPos;
    file_053_VRAM_END = .;

    file_054_ROM_START = __romPos;
    file_054_VRAM = ADDR(.file_054);
    .file_054 0x802408F0 : AT(file_054_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_054_TEXT_START = .;
        build-elf/asm/file_054.s.o(.text);
        . = ALIGN(., 16);
        file_054_TEXT_END = .;
        file_054_TEXT_SIZE = ABSOLUTE(file_054_TEXT_END - file_054_TEXT_START);
        file_054_DATA_START = .;
        build-elf/asm/file_054.s.o(.data);
        build-elf/asm/asm/data/file_054_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_054_DATA_END = .;
        file_054_DATA_SIZE = ABSOLUTE(file_054_DATA_END - file_054_DATA_START);
        file_054_RODATA_START = .;
        build-elf/asm/file_054.s.o(.rodata);
        . = ALIGN(., 16);
        file_054_RODATA_END = .;
        file_054_RODATA_SIZE = ABSOLUTE(file_054_RODATA_END - file_054_RODATA_START);
    }
    file_054_bss_VRAM = ADDR(.file_054_bss);
    .file_054_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_054_BSS_START = .;
        build-elf/asm/file_054.s.o(.bss);
        build-elf/asm/asm/data/file_054_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_054_BSS_END = .;
        file_054_BSS_SIZE = ABSOLUTE(file_054_BSS_END - file_054_BSS_START);
    }
    __romPos += SIZEOF(.file_054);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_054_ROM_END = __romPos;
    file_054_VRAM_END = .;

    file_055_ROM_START = __romPos;
    file_055_VRAM = ADDR(.file_055);
    .file_055 0x803837E0 : AT(file_055_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_055_TEXT_START = .;
        build-elf/asm/file_055.s.o(.text);
        . = ALIGN(., 16);
        file_055_TEXT_END = .;
        file_055_TEXT_SIZE = ABSOLUTE(file_055_TEXT_END - file_055_TEXT_START);
        file_055_DATA_START = .;
        build-elf/asm/file_055.s.o(.data);
        build-elf/asm/asm/data/file_055_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_055_DATA_END = .;
        file_055_DATA_SIZE = ABSOLUTE(file_055_DATA_END - file_055_DATA_START);
        file_055_RODATA_START = .;
        build-elf/asm/file_055.s.o(.rodata);
        . = ALIGN(., 16);
        file_055_RODATA_END = .;
        file_055_RODATA_SIZE = ABSOLUTE(file_055_RODATA_END - file_055_RODATA_START);
    }
    file_055_bss_VRAM = ADDR(.file_055_bss);
    .file_055_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_055_BSS_START = .;
        build-elf/asm/file_055.s.o(.bss);
        build-elf/asm/asm/data/file_055_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_055_BSS_END = .;
        file_055_BSS_SIZE = ABSOLUTE(file_055_BSS_END - file_055_BSS_START);
    }
    __romPos += SIZEOF(.file_055);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_055_ROM_END = __romPos;
    file_055_VRAM_END = .;

    file_056_ROM_START = __romPos;
    file_056_VRAM = ADDR(.file_056);
    .file_056 0x803757E0 : AT(file_056_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_056_TEXT_START = .;
        build-elf/asm/file_056.s.o(.text);
        . = ALIGN(., 16);
        file_056_TEXT_END = .;
        file_056_TEXT_SIZE = ABSOLUTE(file_056_TEXT_END - file_056_TEXT_START);
        file_056_DATA_START = .;
        build-elf/asm/file_056.s.o(.data);
        build-elf/asm/asm/data/file_056_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_056_DATA_END = .;
        file_056_DATA_SIZE = ABSOLUTE(file_056_DATA_END - file_056_DATA_START);
        file_056_RODATA_START = .;
        build-elf/asm/file_056.s.o(.rodata);
        . = ALIGN(., 16);
        file_056_RODATA_END = .;
        file_056_RODATA_SIZE = ABSOLUTE(file_056_RODATA_END - file_056_RODATA_START);
    }
    file_056_bss_VRAM = ADDR(.file_056_bss);
    .file_056_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_056_BSS_START = .;
        build-elf/asm/file_056.s.o(.bss);
        build-elf/asm/asm/data/file_056_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_056_BSS_END = .;
        file_056_BSS_SIZE = ABSOLUTE(file_056_BSS_END - file_056_BSS_START);
    }
    __romPos += SIZEOF(.file_056);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_056_ROM_END = __romPos;
    file_056_VRAM_END = .;

    file_057_ROM_START = __romPos;
    file_057_VRAM = ADDR(.file_057);
    .file_057 0x80358820 : AT(file_057_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_057_TEXT_START = .;
        build-elf/asm/file_057.s.o(.text);
        . = ALIGN(., 16);
        file_057_TEXT_END = .;
        file_057_TEXT_SIZE = ABSOLUTE(file_057_TEXT_END - file_057_TEXT_START);
        file_057_DATA_START = .;
        build-elf/asm/file_057.s.o(.data);
        build-elf/asm/asm/data/file_057_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_057_DATA_END = .;
        file_057_DATA_SIZE = ABSOLUTE(file_057_DATA_END - file_057_DATA_START);
        file_057_RODATA_START = .;
        build-elf/asm/file_057.s.o(.rodata);
        . = ALIGN(., 16);
        file_057_RODATA_END = .;
        file_057_RODATA_SIZE = ABSOLUTE(file_057_RODATA_END - file_057_RODATA_START);
    }
    file_057_bss_VRAM = ADDR(.file_057_bss);
    .file_057_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_057_BSS_START = .;
        build-elf/asm/file_057.s.o(.bss);
        build-elf/asm/asm/data/file_057_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_057_BSS_END = .;
        file_057_BSS_SIZE = ABSOLUTE(file_057_BSS_END - file_057_BSS_START);
    }
    __romPos += SIZEOF(.file_057);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_057_ROM_END = __romPos;
    file_057_VRAM_END = .;

    file_058_ROM_START = __romPos;
    file_058_VRAM = ADDR(.file_058);
    .file_058 0x8038CFC0 : AT(file_058_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_058_TEXT_START = .;
        build-elf/asm/file_058.s.o(.text);
        . = ALIGN(., 16);
        file_058_TEXT_END = .;
        file_058_TEXT_SIZE = ABSOLUTE(file_058_TEXT_END - file_058_TEXT_START);
        file_058_DATA_START = .;
        build-elf/asm/file_058.s.o(.data);
        build-elf/asm/asm/data/file_058_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_058_DATA_END = .;
        file_058_DATA_SIZE = ABSOLUTE(file_058_DATA_END - file_058_DATA_START);
        file_058_RODATA_START = .;
        build-elf/asm/file_058.s.o(.rodata);
        . = ALIGN(., 16);
        file_058_RODATA_END = .;
        file_058_RODATA_SIZE = ABSOLUTE(file_058_RODATA_END - file_058_RODATA_START);
    }
    file_058_bss_VRAM = ADDR(.file_058_bss);
    .file_058_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_058_BSS_START = .;
        build-elf/asm/file_058.s.o(.bss);
        . = ALIGN(., 16);
        file_058_BSS_END = .;
        file_058_BSS_SIZE = ABSOLUTE(file_058_BSS_END - file_058_BSS_START);
    }
    __romPos += SIZEOF(.file_058);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_058_ROM_END = __romPos;
    file_058_VRAM_END = .;

    file_059_ROM_START = __romPos;
    file_059_VRAM = ADDR(.file_059);
    .file_059 0x8038CFC0 : AT(file_059_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_059_TEXT_START = .;
        build-elf/asm/file_059.s.o(.text);
        . = ALIGN(., 16);
        file_059_TEXT_END = .;
        file_059_TEXT_SIZE = ABSOLUTE(file_059_TEXT_END - file_059_TEXT_START);
        file_059_DATA_START = .;
        build-elf/asm/file_059.s.o(.data);
        build-elf/asm/asm/data/file_059_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_059_DATA_END = .;
        file_059_DATA_SIZE = ABSOLUTE(file_059_DATA_END - file_059_DATA_START);
        file_059_RODATA_START = .;
        build-elf/asm/file_059.s.o(.rodata);
        . = ALIGN(., 16);
        file_059_RODATA_END = .;
        file_059_RODATA_SIZE = ABSOLUTE(file_059_RODATA_END - file_059_RODATA_START);
    }
    file_059_bss_VRAM = ADDR(.file_059_bss);
    .file_059_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_059_BSS_START = .;
        build-elf/asm/file_059.s.o(.bss);
        . = ALIGN(., 16);
        file_059_BSS_END = .;
        file_059_BSS_SIZE = ABSOLUTE(file_059_BSS_END - file_059_BSS_START);
    }
    __romPos += SIZEOF(.file_059);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_059_ROM_END = __romPos;
    file_059_VRAM_END = .;

    file_060_ROM_START = __romPos;
    file_060_VRAM = ADDR(.file_060);
    .file_060 0x8038CFC0 : AT(file_060_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_060_TEXT_START = .;
        build-elf/asm/file_060.s.o(.text);
        . = ALIGN(., 16);
        file_060_TEXT_END = .;
        file_060_TEXT_SIZE = ABSOLUTE(file_060_TEXT_END - file_060_TEXT_START);
        file_060_DATA_START = .;
        build-elf/asm/file_060.s.o(.data);
        build-elf/asm/asm/data/file_060_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_060_DATA_END = .;
        file_060_DATA_SIZE = ABSOLUTE(file_060_DATA_END - file_060_DATA_START);
        file_060_RODATA_START = .;
        build-elf/asm/file_060.s.o(.rodata);
        . = ALIGN(., 16);
        file_060_RODATA_END = .;
        file_060_RODATA_SIZE = ABSOLUTE(file_060_RODATA_END - file_060_RODATA_START);
    }
    file_060_bss_VRAM = ADDR(.file_060_bss);
    .file_060_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_060_BSS_START = .;
        build-elf/asm/file_060.s.o(.bss);
        . = ALIGN(., 16);
        file_060_BSS_END = .;
        file_060_BSS_SIZE = ABSOLUTE(file_060_BSS_END - file_060_BSS_START);
    }
    __romPos += SIZEOF(.file_060);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_060_ROM_END = __romPos;
    file_060_VRAM_END = .;

    file_061_ROM_START = __romPos;
    file_061_VRAM = ADDR(.file_061);
    .file_061 0x8038CFC0 : AT(file_061_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_061_TEXT_START = .;
        build-elf/asm/file_061.s.o(.text);
        . = ALIGN(., 16);
        file_061_TEXT_END = .;
        file_061_TEXT_SIZE = ABSOLUTE(file_061_TEXT_END - file_061_TEXT_START);
        file_061_DATA_START = .;
        build-elf/asm/file_061.s.o(.data);
        build-elf/asm/asm/data/file_061_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_061_DATA_END = .;
        file_061_DATA_SIZE = ABSOLUTE(file_061_DATA_END - file_061_DATA_START);
        file_061_RODATA_START = .;
        build-elf/asm/file_061.s.o(.rodata);
        . = ALIGN(., 16);
        file_061_RODATA_END = .;
        file_061_RODATA_SIZE = ABSOLUTE(file_061_RODATA_END - file_061_RODATA_START);
    }
    file_061_bss_VRAM = ADDR(.file_061_bss);
    .file_061_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_061_BSS_START = .;
        build-elf/asm/file_061.s.o(.bss);
        . = ALIGN(., 16);
        file_061_BSS_END = .;
        file_061_BSS_SIZE = ABSOLUTE(file_061_BSS_END - file_061_BSS_START);
    }
    __romPos += SIZEOF(.file_061);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_061_ROM_END = __romPos;
    file_061_VRAM_END = .;

    file_062_ROM_START = __romPos;
    file_062_VRAM = ADDR(.file_062);
    .file_062 0x8038CFC0 : AT(file_062_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_062_TEXT_START = .;
        build-elf/asm/file_062.s.o(.text);
        . = ALIGN(., 16);
        file_062_TEXT_END = .;
        file_062_TEXT_SIZE = ABSOLUTE(file_062_TEXT_END - file_062_TEXT_START);
        file_062_DATA_START = .;
        build-elf/asm/file_062.s.o(.data);
        build-elf/asm/asm/data/file_062_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_062_DATA_END = .;
        file_062_DATA_SIZE = ABSOLUTE(file_062_DATA_END - file_062_DATA_START);
        file_062_RODATA_START = .;
        build-elf/asm/file_062.s.o(.rodata);
        . = ALIGN(., 16);
        file_062_RODATA_END = .;
        file_062_RODATA_SIZE = ABSOLUTE(file_062_RODATA_END - file_062_RODATA_START);
    }
    file_062_bss_VRAM = ADDR(.file_062_bss);
    .file_062_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_062_BSS_START = .;
        build-elf/asm/file_062.s.o(.bss);
        . = ALIGN(., 16);
        file_062_BSS_END = .;
        file_062_BSS_SIZE = ABSOLUTE(file_062_BSS_END - file_062_BSS_START);
    }
    __romPos += SIZEOF(.file_062);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_062_ROM_END = __romPos;
    file_062_VRAM_END = .;

    file_063_ROM_START = __romPos;
    file_063_VRAM = ADDR(.file_063);
    .file_063 0x8038CFC0 : AT(file_063_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_063_TEXT_START = .;
        build-elf/asm/file_063.s.o(.text);
        . = ALIGN(., 16);
        file_063_TEXT_END = .;
        file_063_TEXT_SIZE = ABSOLUTE(file_063_TEXT_END - file_063_TEXT_START);
        file_063_DATA_START = .;
        build-elf/asm/file_063.s.o(.data);
        build-elf/asm/asm/data/file_063_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_063_DATA_END = .;
        file_063_DATA_SIZE = ABSOLUTE(file_063_DATA_END - file_063_DATA_START);
        file_063_RODATA_START = .;
        build-elf/asm/file_063.s.o(.rodata);
        . = ALIGN(., 16);
        file_063_RODATA_END = .;
        file_063_RODATA_SIZE = ABSOLUTE(file_063_RODATA_END - file_063_RODATA_START);
    }
    file_063_bss_VRAM = ADDR(.file_063_bss);
    .file_063_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_063_BSS_START = .;
        build-elf/asm/file_063.s.o(.bss);
        . = ALIGN(., 16);
        file_063_BSS_END = .;
        file_063_BSS_SIZE = ABSOLUTE(file_063_BSS_END - file_063_BSS_START);
    }
    __romPos += SIZEOF(.file_063);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_063_ROM_END = __romPos;
    file_063_VRAM_END = .;

    file_064_ROM_START = __romPos;
    file_064_VRAM = ADDR(.file_064);
    .file_064 0x8038CFC0 : AT(file_064_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_064_TEXT_START = .;
        build-elf/asm/file_064.s.o(.text);
        . = ALIGN(., 16);
        file_064_TEXT_END = .;
        file_064_TEXT_SIZE = ABSOLUTE(file_064_TEXT_END - file_064_TEXT_START);
        file_064_DATA_START = .;
        build-elf/asm/file_064.s.o(.data);
        build-elf/asm/asm/data/file_064_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_064_DATA_END = .;
        file_064_DATA_SIZE = ABSOLUTE(file_064_DATA_END - file_064_DATA_START);
        file_064_RODATA_START = .;
        build-elf/asm/file_064.s.o(.rodata);
        . = ALIGN(., 16);
        file_064_RODATA_END = .;
        file_064_RODATA_SIZE = ABSOLUTE(file_064_RODATA_END - file_064_RODATA_START);
    }
    file_064_bss_VRAM = ADDR(.file_064_bss);
    .file_064_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_064_BSS_START = .;
        build-elf/asm/file_064.s.o(.bss);
        . = ALIGN(., 16);
        file_064_BSS_END = .;
        file_064_BSS_SIZE = ABSOLUTE(file_064_BSS_END - file_064_BSS_START);
    }
    __romPos += SIZEOF(.file_064);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_064_ROM_END = __romPos;
    file_064_VRAM_END = .;

    file_065_ROM_START = __romPos;
    file_065_VRAM = ADDR(.file_065);
    .file_065 0x8038CFC0 : AT(file_065_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_065_TEXT_START = .;
        build-elf/asm/file_065.s.o(.text);
        . = ALIGN(., 16);
        file_065_TEXT_END = .;
        file_065_TEXT_SIZE = ABSOLUTE(file_065_TEXT_END - file_065_TEXT_START);
        file_065_DATA_START = .;
        build-elf/asm/file_065.s.o(.data);
        build-elf/asm/asm/data/file_065_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_065_DATA_END = .;
        file_065_DATA_SIZE = ABSOLUTE(file_065_DATA_END - file_065_DATA_START);
        file_065_RODATA_START = .;
        build-elf/asm/file_065.s.o(.rodata);
        . = ALIGN(., 16);
        file_065_RODATA_END = .;
        file_065_RODATA_SIZE = ABSOLUTE(file_065_RODATA_END - file_065_RODATA_START);
    }
    file_065_bss_VRAM = ADDR(.file_065_bss);
    .file_065_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_065_BSS_START = .;
        build-elf/asm/file_065.s.o(.bss);
        . = ALIGN(., 16);
        file_065_BSS_END = .;
        file_065_BSS_SIZE = ABSOLUTE(file_065_BSS_END - file_065_BSS_START);
    }
    __romPos += SIZEOF(.file_065);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_065_ROM_END = __romPos;
    file_065_VRAM_END = .;

    file_066_ROM_START = __romPos;
    file_066_VRAM = ADDR(.file_066);
    .file_066 0x8038CFC0 : AT(file_066_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_066_TEXT_START = .;
        build-elf/asm/file_066.s.o(.text);
        . = ALIGN(., 16);
        file_066_TEXT_END = .;
        file_066_TEXT_SIZE = ABSOLUTE(file_066_TEXT_END - file_066_TEXT_START);
        file_066_DATA_START = .;
        build-elf/asm/file_066.s.o(.data);
        build-elf/asm/asm/data/file_066_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_066_DATA_END = .;
        file_066_DATA_SIZE = ABSOLUTE(file_066_DATA_END - file_066_DATA_START);
        file_066_RODATA_START = .;
        build-elf/asm/file_066.s.o(.rodata);
        . = ALIGN(., 16);
        file_066_RODATA_END = .;
        file_066_RODATA_SIZE = ABSOLUTE(file_066_RODATA_END - file_066_RODATA_START);
    }
    file_066_bss_VRAM = ADDR(.file_066_bss);
    .file_066_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_066_BSS_START = .;
        build-elf/asm/file_066.s.o(.bss);
        . = ALIGN(., 16);
        file_066_BSS_END = .;
        file_066_BSS_SIZE = ABSOLUTE(file_066_BSS_END - file_066_BSS_START);
    }
    __romPos += SIZEOF(.file_066);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_066_ROM_END = __romPos;
    file_066_VRAM_END = .;

    file_067_ROM_START = __romPos;
    file_067_VRAM = ADDR(.file_067);
    .file_067 0x8038CFC0 : AT(file_067_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_067_TEXT_START = .;
        build-elf/asm/file_067.s.o(.text);
        . = ALIGN(., 16);
        file_067_TEXT_END = .;
        file_067_TEXT_SIZE = ABSOLUTE(file_067_TEXT_END - file_067_TEXT_START);
        file_067_DATA_START = .;
        build-elf/asm/file_067.s.o(.data);
        build-elf/asm/asm/data/file_067_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_067_DATA_END = .;
        file_067_DATA_SIZE = ABSOLUTE(file_067_DATA_END - file_067_DATA_START);
        file_067_RODATA_START = .;
        build-elf/asm/file_067.s.o(.rodata);
        . = ALIGN(., 16);
        file_067_RODATA_END = .;
        file_067_RODATA_SIZE = ABSOLUTE(file_067_RODATA_END - file_067_RODATA_START);
    }
    file_067_bss_VRAM = ADDR(.file_067_bss);
    .file_067_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_067_BSS_START = .;
        build-elf/asm/file_067.s.o(.bss);
        . = ALIGN(., 16);
        file_067_BSS_END = .;
        file_067_BSS_SIZE = ABSOLUTE(file_067_BSS_END - file_067_BSS_START);
    }
    __romPos += SIZEOF(.file_067);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_067_ROM_END = __romPos;
    file_067_VRAM_END = .;

    file_068_ROM_START = __romPos;
    file_068_VRAM = ADDR(.file_068);
    .file_068 0x8038CFC0 : AT(file_068_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_068_TEXT_START = .;
        build-elf/asm/file_068.s.o(.text);
        . = ALIGN(., 16);
        file_068_TEXT_END = .;
        file_068_TEXT_SIZE = ABSOLUTE(file_068_TEXT_END - file_068_TEXT_START);
        file_068_DATA_START = .;
        build-elf/asm/file_068.s.o(.data);
        build-elf/asm/asm/data/file_068_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_068_DATA_END = .;
        file_068_DATA_SIZE = ABSOLUTE(file_068_DATA_END - file_068_DATA_START);
        file_068_RODATA_START = .;
        build-elf/asm/file_068.s.o(.rodata);
        . = ALIGN(., 16);
        file_068_RODATA_END = .;
        file_068_RODATA_SIZE = ABSOLUTE(file_068_RODATA_END - file_068_RODATA_START);
    }
    file_068_bss_VRAM = ADDR(.file_068_bss);
    .file_068_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_068_BSS_START = .;
        build-elf/asm/file_068.s.o(.bss);
        . = ALIGN(., 16);
        file_068_BSS_END = .;
        file_068_BSS_SIZE = ABSOLUTE(file_068_BSS_END - file_068_BSS_START);
    }
    __romPos += SIZEOF(.file_068);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_068_ROM_END = __romPos;
    file_068_VRAM_END = .;

    file_069_ROM_START = __romPos;
    file_069_VRAM = ADDR(.file_069);
    .file_069 0x8038CFC0 : AT(file_069_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_069_TEXT_START = .;
        build-elf/asm/file_069.s.o(.text);
        . = ALIGN(., 16);
        file_069_TEXT_END = .;
        file_069_TEXT_SIZE = ABSOLUTE(file_069_TEXT_END - file_069_TEXT_START);
        file_069_DATA_START = .;
        build-elf/asm/file_069.s.o(.data);
        build-elf/asm/asm/data/file_069_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_069_DATA_END = .;
        file_069_DATA_SIZE = ABSOLUTE(file_069_DATA_END - file_069_DATA_START);
        file_069_RODATA_START = .;
        build-elf/asm/file_069.s.o(.rodata);
        . = ALIGN(., 16);
        file_069_RODATA_END = .;
        file_069_RODATA_SIZE = ABSOLUTE(file_069_RODATA_END - file_069_RODATA_START);
    }
    file_069_bss_VRAM = ADDR(.file_069_bss);
    .file_069_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_069_BSS_START = .;
        build-elf/asm/file_069.s.o(.bss);
        . = ALIGN(., 16);
        file_069_BSS_END = .;
        file_069_BSS_SIZE = ABSOLUTE(file_069_BSS_END - file_069_BSS_START);
    }
    __romPos += SIZEOF(.file_069);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_069_ROM_END = __romPos;
    file_069_VRAM_END = .;

    file_070_ROM_START = __romPos;
    file_070_VRAM = ADDR(.file_070);
    .file_070 0x8038CFC0 : AT(file_070_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_070_TEXT_START = .;
        build-elf/asm/file_070.s.o(.text);
        . = ALIGN(., 16);
        file_070_TEXT_END = .;
        file_070_TEXT_SIZE = ABSOLUTE(file_070_TEXT_END - file_070_TEXT_START);
        file_070_DATA_START = .;
        build-elf/asm/file_070.s.o(.data);
        build-elf/asm/asm/data/file_070_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_070_DATA_END = .;
        file_070_DATA_SIZE = ABSOLUTE(file_070_DATA_END - file_070_DATA_START);
        file_070_RODATA_START = .;
        build-elf/asm/file_070.s.o(.rodata);
        . = ALIGN(., 16);
        file_070_RODATA_END = .;
        file_070_RODATA_SIZE = ABSOLUTE(file_070_RODATA_END - file_070_RODATA_START);
    }
    file_070_bss_VRAM = ADDR(.file_070_bss);
    .file_070_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_070_BSS_START = .;
        build-elf/asm/file_070.s.o(.bss);
        . = ALIGN(., 16);
        file_070_BSS_END = .;
        file_070_BSS_SIZE = ABSOLUTE(file_070_BSS_END - file_070_BSS_START);
    }
    __romPos += SIZEOF(.file_070);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_070_ROM_END = __romPos;
    file_070_VRAM_END = .;

    file_071_ROM_START = __romPos;
    file_071_VRAM = ADDR(.file_071);
    .file_071 0x8038CFC0 : AT(file_071_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_071_TEXT_START = .;
        build-elf/asm/file_071.s.o(.text);
        . = ALIGN(., 16);
        file_071_TEXT_END = .;
        file_071_TEXT_SIZE = ABSOLUTE(file_071_TEXT_END - file_071_TEXT_START);
        file_071_DATA_START = .;
        build-elf/asm/file_071.s.o(.data);
        build-elf/asm/asm/data/file_071_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_071_DATA_END = .;
        file_071_DATA_SIZE = ABSOLUTE(file_071_DATA_END - file_071_DATA_START);
        file_071_RODATA_START = .;
        build-elf/asm/file_071.s.o(.rodata);
        . = ALIGN(., 16);
        file_071_RODATA_END = .;
        file_071_RODATA_SIZE = ABSOLUTE(file_071_RODATA_END - file_071_RODATA_START);
    }
    file_071_bss_VRAM = ADDR(.file_071_bss);
    .file_071_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_071_BSS_START = .;
        build-elf/asm/file_071.s.o(.bss);
        . = ALIGN(., 16);
        file_071_BSS_END = .;
        file_071_BSS_SIZE = ABSOLUTE(file_071_BSS_END - file_071_BSS_START);
    }
    __romPos += SIZEOF(.file_071);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_071_ROM_END = __romPos;
    file_071_VRAM_END = .;

    file_072_ROM_START = __romPos;
    file_072_VRAM = ADDR(.file_072);
    .file_072 0x8038CFC0 : AT(file_072_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_072_TEXT_START = .;
        build-elf/asm/file_072.s.o(.text);
        . = ALIGN(., 16);
        file_072_TEXT_END = .;
        file_072_TEXT_SIZE = ABSOLUTE(file_072_TEXT_END - file_072_TEXT_START);
        file_072_DATA_START = .;
        build-elf/asm/file_072.s.o(.data);
        build-elf/asm/asm/data/file_072_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_072_DATA_END = .;
        file_072_DATA_SIZE = ABSOLUTE(file_072_DATA_END - file_072_DATA_START);
        file_072_RODATA_START = .;
        build-elf/asm/file_072.s.o(.rodata);
        . = ALIGN(., 16);
        file_072_RODATA_END = .;
        file_072_RODATA_SIZE = ABSOLUTE(file_072_RODATA_END - file_072_RODATA_START);
    }
    file_072_bss_VRAM = ADDR(.file_072_bss);
    .file_072_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_072_BSS_START = .;
        build-elf/asm/file_072.s.o(.bss);
        build-elf/asm/asm/data/file_072_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_072_BSS_END = .;
        file_072_BSS_SIZE = ABSOLUTE(file_072_BSS_END - file_072_BSS_START);
    }
    __romPos += SIZEOF(.file_072);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_072_ROM_END = __romPos;
    file_072_VRAM_END = .;

    file_073_ROM_START = __romPos;
    file_073_VRAM = ADDR(.file_073);
    .file_073 0x8038CFC0 : AT(file_073_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_073_TEXT_START = .;
        build-elf/asm/file_073.s.o(.text);
        . = ALIGN(., 16);
        file_073_TEXT_END = .;
        file_073_TEXT_SIZE = ABSOLUTE(file_073_TEXT_END - file_073_TEXT_START);
        file_073_DATA_START = .;
        build-elf/asm/file_073.s.o(.data);
        build-elf/asm/asm/data/file_073_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_073_DATA_END = .;
        file_073_DATA_SIZE = ABSOLUTE(file_073_DATA_END - file_073_DATA_START);
        file_073_RODATA_START = .;
        build-elf/asm/file_073.s.o(.rodata);
        . = ALIGN(., 16);
        file_073_RODATA_END = .;
        file_073_RODATA_SIZE = ABSOLUTE(file_073_RODATA_END - file_073_RODATA_START);
    }
    file_073_bss_VRAM = ADDR(.file_073_bss);
    .file_073_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_073_BSS_START = .;
        build-elf/asm/file_073.s.o(.bss);
        . = ALIGN(., 16);
        file_073_BSS_END = .;
        file_073_BSS_SIZE = ABSOLUTE(file_073_BSS_END - file_073_BSS_START);
    }
    __romPos += SIZEOF(.file_073);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_073_ROM_END = __romPos;
    file_073_VRAM_END = .;

    file_074_ROM_START = __romPos;
    file_074_VRAM = ADDR(.file_074);
    .file_074 0x8038CFC0 : AT(file_074_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_074_TEXT_START = .;
        build-elf/asm/file_074.s.o(.text);
        . = ALIGN(., 16);
        file_074_TEXT_END = .;
        file_074_TEXT_SIZE = ABSOLUTE(file_074_TEXT_END - file_074_TEXT_START);
        file_074_DATA_START = .;
        build-elf/asm/file_074.s.o(.data);
        build-elf/asm/asm/data/file_074_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_074_DATA_END = .;
        file_074_DATA_SIZE = ABSOLUTE(file_074_DATA_END - file_074_DATA_START);
        file_074_RODATA_START = .;
        build-elf/asm/file_074.s.o(.rodata);
        . = ALIGN(., 16);
        file_074_RODATA_END = .;
        file_074_RODATA_SIZE = ABSOLUTE(file_074_RODATA_END - file_074_RODATA_START);
    }
    file_074_bss_VRAM = ADDR(.file_074_bss);
    .file_074_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_074_BSS_START = .;
        build-elf/asm/file_074.s.o(.bss);
        . = ALIGN(., 16);
        file_074_BSS_END = .;
        file_074_BSS_SIZE = ABSOLUTE(file_074_BSS_END - file_074_BSS_START);
    }
    __romPos += SIZEOF(.file_074);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_074_ROM_END = __romPos;
    file_074_VRAM_END = .;

    file_075_ROM_START = __romPos;
    file_075_VRAM = ADDR(.file_075);
    .file_075 0x8038CFC0 : AT(file_075_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_075_TEXT_START = .;
        build-elf/asm/file_075.s.o(.text);
        . = ALIGN(., 16);
        file_075_TEXT_END = .;
        file_075_TEXT_SIZE = ABSOLUTE(file_075_TEXT_END - file_075_TEXT_START);
        file_075_DATA_START = .;
        build-elf/asm/file_075.s.o(.data);
        build-elf/asm/asm/data/file_075_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_075_DATA_END = .;
        file_075_DATA_SIZE = ABSOLUTE(file_075_DATA_END - file_075_DATA_START);
        file_075_RODATA_START = .;
        build-elf/asm/file_075.s.o(.rodata);
        . = ALIGN(., 16);
        file_075_RODATA_END = .;
        file_075_RODATA_SIZE = ABSOLUTE(file_075_RODATA_END - file_075_RODATA_START);
    }
    file_075_bss_VRAM = ADDR(.file_075_bss);
    .file_075_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_075_BSS_START = .;
        build-elf/asm/file_075.s.o(.bss);
        . = ALIGN(., 16);
        file_075_BSS_END = .;
        file_075_BSS_SIZE = ABSOLUTE(file_075_BSS_END - file_075_BSS_START);
    }
    __romPos += SIZEOF(.file_075);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_075_ROM_END = __romPos;
    file_075_VRAM_END = .;

    file_076_ROM_START = __romPos;
    file_076_VRAM = ADDR(.file_076);
    .file_076 0x8038CFC0 : AT(file_076_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_076_TEXT_START = .;
        build-elf/asm/file_076.s.o(.text);
        . = ALIGN(., 16);
        file_076_TEXT_END = .;
        file_076_TEXT_SIZE = ABSOLUTE(file_076_TEXT_END - file_076_TEXT_START);
        file_076_DATA_START = .;
        build-elf/asm/file_076.s.o(.data);
        build-elf/asm/asm/data/file_076_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_076_DATA_END = .;
        file_076_DATA_SIZE = ABSOLUTE(file_076_DATA_END - file_076_DATA_START);
        file_076_RODATA_START = .;
        build-elf/asm/file_076.s.o(.rodata);
        . = ALIGN(., 16);
        file_076_RODATA_END = .;
        file_076_RODATA_SIZE = ABSOLUTE(file_076_RODATA_END - file_076_RODATA_START);
    }
    file_076_bss_VRAM = ADDR(.file_076_bss);
    .file_076_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_076_BSS_START = .;
        build-elf/asm/file_076.s.o(.bss);
        . = ALIGN(., 16);
        file_076_BSS_END = .;
        file_076_BSS_SIZE = ABSOLUTE(file_076_BSS_END - file_076_BSS_START);
    }
    __romPos += SIZEOF(.file_076);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_076_ROM_END = __romPos;
    file_076_VRAM_END = .;

    file_077_ROM_START = __romPos;
    file_077_VRAM = ADDR(.file_077);
    .file_077 0x8038CFC0 : AT(file_077_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_077_TEXT_START = .;
        build-elf/asm/file_077.s.o(.text);
        . = ALIGN(., 16);
        file_077_TEXT_END = .;
        file_077_TEXT_SIZE = ABSOLUTE(file_077_TEXT_END - file_077_TEXT_START);
        file_077_DATA_START = .;
        build-elf/asm/file_077.s.o(.data);
        build-elf/asm/asm/data/file_077_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_077_DATA_END = .;
        file_077_DATA_SIZE = ABSOLUTE(file_077_DATA_END - file_077_DATA_START);
        file_077_RODATA_START = .;
        build-elf/asm/file_077.s.o(.rodata);
        . = ALIGN(., 16);
        file_077_RODATA_END = .;
        file_077_RODATA_SIZE = ABSOLUTE(file_077_RODATA_END - file_077_RODATA_START);
    }
    file_077_bss_VRAM = ADDR(.file_077_bss);
    .file_077_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_077_BSS_START = .;
        build-elf/asm/file_077.s.o(.bss);
        . = ALIGN(., 16);
        file_077_BSS_END = .;
        file_077_BSS_SIZE = ABSOLUTE(file_077_BSS_END - file_077_BSS_START);
    }
    __romPos += SIZEOF(.file_077);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_077_ROM_END = __romPos;
    file_077_VRAM_END = .;

    file_078_ROM_START = __romPos;
    file_078_VRAM = ADDR(.file_078);
    .file_078 0x8038CFC0 : AT(file_078_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_078_TEXT_START = .;
        build-elf/asm/file_078.s.o(.text);
        . = ALIGN(., 16);
        file_078_TEXT_END = .;
        file_078_TEXT_SIZE = ABSOLUTE(file_078_TEXT_END - file_078_TEXT_START);
        file_078_DATA_START = .;
        build-elf/asm/file_078.s.o(.data);
        build-elf/asm/asm/data/file_078_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_078_DATA_END = .;
        file_078_DATA_SIZE = ABSOLUTE(file_078_DATA_END - file_078_DATA_START);
        file_078_RODATA_START = .;
        build-elf/asm/file_078.s.o(.rodata);
        . = ALIGN(., 16);
        file_078_RODATA_END = .;
        file_078_RODATA_SIZE = ABSOLUTE(file_078_RODATA_END - file_078_RODATA_START);
    }
    file_078_bss_VRAM = ADDR(.file_078_bss);
    .file_078_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_078_BSS_START = .;
        build-elf/asm/file_078.s.o(.bss);
        . = ALIGN(., 16);
        file_078_BSS_END = .;
        file_078_BSS_SIZE = ABSOLUTE(file_078_BSS_END - file_078_BSS_START);
    }
    __romPos += SIZEOF(.file_078);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_078_ROM_END = __romPos;
    file_078_VRAM_END = .;

    file_079_ROM_START = __romPos;
    file_079_VRAM = ADDR(.file_079);
    .file_079 0x8038CFC0 : AT(file_079_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_079_TEXT_START = .;
        build-elf/asm/file_079.s.o(.text);
        . = ALIGN(., 16);
        file_079_TEXT_END = .;
        file_079_TEXT_SIZE = ABSOLUTE(file_079_TEXT_END - file_079_TEXT_START);
        file_079_DATA_START = .;
        build-elf/asm/file_079.s.o(.data);
        build-elf/asm/asm/data/file_079_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_079_DATA_END = .;
        file_079_DATA_SIZE = ABSOLUTE(file_079_DATA_END - file_079_DATA_START);
        file_079_RODATA_START = .;
        build-elf/asm/file_079.s.o(.rodata);
        . = ALIGN(., 16);
        file_079_RODATA_END = .;
        file_079_RODATA_SIZE = ABSOLUTE(file_079_RODATA_END - file_079_RODATA_START);
    }
    file_079_bss_VRAM = ADDR(.file_079_bss);
    .file_079_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_079_BSS_START = .;
        build-elf/asm/file_079.s.o(.bss);
        . = ALIGN(., 16);
        file_079_BSS_END = .;
        file_079_BSS_SIZE = ABSOLUTE(file_079_BSS_END - file_079_BSS_START);
    }
    __romPos += SIZEOF(.file_079);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_079_ROM_END = __romPos;
    file_079_VRAM_END = .;

    file_080_ROM_START = __romPos;
    file_080_VRAM = ADDR(.file_080);
    .file_080 0x8038CFC0 : AT(file_080_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_080_TEXT_START = .;
        build-elf/asm/file_080.s.o(.text);
        . = ALIGN(., 16);
        file_080_TEXT_END = .;
        file_080_TEXT_SIZE = ABSOLUTE(file_080_TEXT_END - file_080_TEXT_START);
        file_080_DATA_START = .;
        build-elf/asm/file_080.s.o(.data);
        build-elf/asm/asm/data/file_080_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_080_DATA_END = .;
        file_080_DATA_SIZE = ABSOLUTE(file_080_DATA_END - file_080_DATA_START);
        file_080_RODATA_START = .;
        build-elf/asm/file_080.s.o(.rodata);
        . = ALIGN(., 16);
        file_080_RODATA_END = .;
        file_080_RODATA_SIZE = ABSOLUTE(file_080_RODATA_END - file_080_RODATA_START);
    }
    file_080_bss_VRAM = ADDR(.file_080_bss);
    .file_080_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_080_BSS_START = .;
        build-elf/asm/file_080.s.o(.bss);
        . = ALIGN(., 16);
        file_080_BSS_END = .;
        file_080_BSS_SIZE = ABSOLUTE(file_080_BSS_END - file_080_BSS_START);
    }
    __romPos += SIZEOF(.file_080);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_080_ROM_END = __romPos;
    file_080_VRAM_END = .;

    file_081_ROM_START = __romPos;
    file_081_VRAM = ADDR(.file_081);
    .file_081 0x8038CFC0 : AT(file_081_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_081_TEXT_START = .;
        build-elf/asm/file_081.s.o(.text);
        . = ALIGN(., 16);
        file_081_TEXT_END = .;
        file_081_TEXT_SIZE = ABSOLUTE(file_081_TEXT_END - file_081_TEXT_START);
        file_081_DATA_START = .;
        build-elf/asm/file_081.s.o(.data);
        build-elf/asm/asm/data/file_081_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_081_DATA_END = .;
        file_081_DATA_SIZE = ABSOLUTE(file_081_DATA_END - file_081_DATA_START);
        file_081_RODATA_START = .;
        build-elf/asm/file_081.s.o(.rodata);
        . = ALIGN(., 16);
        file_081_RODATA_END = .;
        file_081_RODATA_SIZE = ABSOLUTE(file_081_RODATA_END - file_081_RODATA_START);
    }
    file_081_bss_VRAM = ADDR(.file_081_bss);
    .file_081_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_081_BSS_START = .;
        build-elf/asm/file_081.s.o(.bss);
        . = ALIGN(., 16);
        file_081_BSS_END = .;
        file_081_BSS_SIZE = ABSOLUTE(file_081_BSS_END - file_081_BSS_START);
    }
    __romPos += SIZEOF(.file_081);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_081_ROM_END = __romPos;
    file_081_VRAM_END = .;

    file_082_ROM_START = __romPos;
    file_082_VRAM = ADDR(.file_082);
    .file_082 0x8038CFC0 : AT(file_082_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_082_TEXT_START = .;
        build-elf/asm/file_082.s.o(.text);
        . = ALIGN(., 16);
        file_082_TEXT_END = .;
        file_082_TEXT_SIZE = ABSOLUTE(file_082_TEXT_END - file_082_TEXT_START);
        file_082_DATA_START = .;
        build-elf/asm/file_082.s.o(.data);
        build-elf/asm/asm/data/file_082_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_082_DATA_END = .;
        file_082_DATA_SIZE = ABSOLUTE(file_082_DATA_END - file_082_DATA_START);
        file_082_RODATA_START = .;
        build-elf/asm/file_082.s.o(.rodata);
        . = ALIGN(., 16);
        file_082_RODATA_END = .;
        file_082_RODATA_SIZE = ABSOLUTE(file_082_RODATA_END - file_082_RODATA_START);
    }
    file_082_bss_VRAM = ADDR(.file_082_bss);
    .file_082_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_082_BSS_START = .;
        build-elf/asm/file_082.s.o(.bss);
        . = ALIGN(., 16);
        file_082_BSS_END = .;
        file_082_BSS_SIZE = ABSOLUTE(file_082_BSS_END - file_082_BSS_START);
    }
    __romPos += SIZEOF(.file_082);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_082_ROM_END = __romPos;
    file_082_VRAM_END = .;

    file_083_ROM_START = __romPos;
    file_083_VRAM = ADDR(.file_083);
    .file_083 0x8038CFC0 : AT(file_083_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_083_TEXT_START = .;
        build-elf/asm/file_083.s.o(.text);
        . = ALIGN(., 16);
        file_083_TEXT_END = .;
        file_083_TEXT_SIZE = ABSOLUTE(file_083_TEXT_END - file_083_TEXT_START);
        file_083_DATA_START = .;
        build-elf/asm/file_083.s.o(.data);
        build-elf/asm/asm/data/file_083_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_083_DATA_END = .;
        file_083_DATA_SIZE = ABSOLUTE(file_083_DATA_END - file_083_DATA_START);
        file_083_RODATA_START = .;
        build-elf/asm/file_083.s.o(.rodata);
        . = ALIGN(., 16);
        file_083_RODATA_END = .;
        file_083_RODATA_SIZE = ABSOLUTE(file_083_RODATA_END - file_083_RODATA_START);
    }
    file_083_bss_VRAM = ADDR(.file_083_bss);
    .file_083_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_083_BSS_START = .;
        build-elf/asm/file_083.s.o(.bss);
        . = ALIGN(., 16);
        file_083_BSS_END = .;
        file_083_BSS_SIZE = ABSOLUTE(file_083_BSS_END - file_083_BSS_START);
    }
    __romPos += SIZEOF(.file_083);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_083_ROM_END = __romPos;
    file_083_VRAM_END = .;

    file_084_ROM_START = __romPos;
    file_084_VRAM = ADDR(.file_084);
    .file_084 0x8038CFC0 : AT(file_084_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_084_TEXT_START = .;
        build-elf/asm/file_084.s.o(.text);
        . = ALIGN(., 16);
        file_084_TEXT_END = .;
        file_084_TEXT_SIZE = ABSOLUTE(file_084_TEXT_END - file_084_TEXT_START);
        file_084_DATA_START = .;
        build-elf/asm/file_084.s.o(.data);
        build-elf/asm/asm/data/file_084_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_084_DATA_END = .;
        file_084_DATA_SIZE = ABSOLUTE(file_084_DATA_END - file_084_DATA_START);
        file_084_RODATA_START = .;
        build-elf/asm/file_084.s.o(.rodata);
        . = ALIGN(., 16);
        file_084_RODATA_END = .;
        file_084_RODATA_SIZE = ABSOLUTE(file_084_RODATA_END - file_084_RODATA_START);
    }
    file_084_bss_VRAM = ADDR(.file_084_bss);
    .file_084_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_084_BSS_START = .;
        build-elf/asm/file_084.s.o(.bss);
        . = ALIGN(., 16);
        file_084_BSS_END = .;
        file_084_BSS_SIZE = ABSOLUTE(file_084_BSS_END - file_084_BSS_START);
    }
    __romPos += SIZEOF(.file_084);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_084_ROM_END = __romPos;
    file_084_VRAM_END = .;

    file_085_ROM_START = __romPos;
    file_085_VRAM = ADDR(.file_085);
    .file_085 0x8038CFC0 : AT(file_085_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_085_TEXT_START = .;
        build-elf/asm/file_085.s.o(.text);
        . = ALIGN(., 16);
        file_085_TEXT_END = .;
        file_085_TEXT_SIZE = ABSOLUTE(file_085_TEXT_END - file_085_TEXT_START);
        file_085_DATA_START = .;
        build-elf/asm/file_085.s.o(.data);
        build-elf/asm/asm/data/file_085_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_085_DATA_END = .;
        file_085_DATA_SIZE = ABSOLUTE(file_085_DATA_END - file_085_DATA_START);
        file_085_RODATA_START = .;
        build-elf/asm/file_085.s.o(.rodata);
        . = ALIGN(., 16);
        file_085_RODATA_END = .;
        file_085_RODATA_SIZE = ABSOLUTE(file_085_RODATA_END - file_085_RODATA_START);
    }
    file_085_bss_VRAM = ADDR(.file_085_bss);
    .file_085_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_085_BSS_START = .;
        build-elf/asm/file_085.s.o(.bss);
        . = ALIGN(., 16);
        file_085_BSS_END = .;
        file_085_BSS_SIZE = ABSOLUTE(file_085_BSS_END - file_085_BSS_START);
    }
    __romPos += SIZEOF(.file_085);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_085_ROM_END = __romPos;
    file_085_VRAM_END = .;

    file_086_ROM_START = __romPos;
    file_086_VRAM = ADDR(.file_086);
    .file_086 0x8038CFC0 : AT(file_086_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_086_TEXT_START = .;
        build-elf/asm/file_086.s.o(.text);
        . = ALIGN(., 16);
        file_086_TEXT_END = .;
        file_086_TEXT_SIZE = ABSOLUTE(file_086_TEXT_END - file_086_TEXT_START);
        file_086_DATA_START = .;
        build-elf/asm/file_086.s.o(.data);
        build-elf/asm/asm/data/file_086_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_086_DATA_END = .;
        file_086_DATA_SIZE = ABSOLUTE(file_086_DATA_END - file_086_DATA_START);
        file_086_RODATA_START = .;
        build-elf/asm/file_086.s.o(.rodata);
        . = ALIGN(., 16);
        file_086_RODATA_END = .;
        file_086_RODATA_SIZE = ABSOLUTE(file_086_RODATA_END - file_086_RODATA_START);
    }
    file_086_bss_VRAM = ADDR(.file_086_bss);
    .file_086_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_086_BSS_START = .;
        build-elf/asm/file_086.s.o(.bss);
        build-elf/asm/asm/data/file_086_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_086_BSS_END = .;
        file_086_BSS_SIZE = ABSOLUTE(file_086_BSS_END - file_086_BSS_START);
    }
    __romPos += SIZEOF(.file_086);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_086_ROM_END = __romPos;
    file_086_VRAM_END = .;

    file_087_ROM_START = __romPos;
    file_087_VRAM = ADDR(.file_087);
    .file_087 0x8038CFC0 : AT(file_087_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_087_TEXT_START = .;
        build-elf/asm/file_087.s.o(.text);
        . = ALIGN(., 16);
        file_087_TEXT_END = .;
        file_087_TEXT_SIZE = ABSOLUTE(file_087_TEXT_END - file_087_TEXT_START);
        file_087_DATA_START = .;
        build-elf/asm/file_087.s.o(.data);
        build-elf/asm/asm/data/file_087_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_087_DATA_END = .;
        file_087_DATA_SIZE = ABSOLUTE(file_087_DATA_END - file_087_DATA_START);
        file_087_RODATA_START = .;
        build-elf/asm/file_087.s.o(.rodata);
        . = ALIGN(., 16);
        file_087_RODATA_END = .;
        file_087_RODATA_SIZE = ABSOLUTE(file_087_RODATA_END - file_087_RODATA_START);
    }
    file_087_bss_VRAM = ADDR(.file_087_bss);
    .file_087_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_087_BSS_START = .;
        build-elf/asm/file_087.s.o(.bss);
        . = ALIGN(., 16);
        file_087_BSS_END = .;
        file_087_BSS_SIZE = ABSOLUTE(file_087_BSS_END - file_087_BSS_START);
    }
    __romPos += SIZEOF(.file_087);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_087_ROM_END = __romPos;
    file_087_VRAM_END = .;

    file_088_ROM_START = __romPos;
    file_088_VRAM = ADDR(.file_088);
    .file_088 0x8038CFC0 : AT(file_088_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_088_TEXT_START = .;
        build-elf/asm/file_088.s.o(.text);
        . = ALIGN(., 16);
        file_088_TEXT_END = .;
        file_088_TEXT_SIZE = ABSOLUTE(file_088_TEXT_END - file_088_TEXT_START);
        file_088_DATA_START = .;
        build-elf/asm/file_088.s.o(.data);
        build-elf/asm/asm/data/file_088_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_088_DATA_END = .;
        file_088_DATA_SIZE = ABSOLUTE(file_088_DATA_END - file_088_DATA_START);
        file_088_RODATA_START = .;
        build-elf/asm/file_088.s.o(.rodata);
        . = ALIGN(., 16);
        file_088_RODATA_END = .;
        file_088_RODATA_SIZE = ABSOLUTE(file_088_RODATA_END - file_088_RODATA_START);
    }
    file_088_bss_VRAM = ADDR(.file_088_bss);
    .file_088_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_088_BSS_START = .;
        build-elf/asm/file_088.s.o(.bss);
        . = ALIGN(., 16);
        file_088_BSS_END = .;
        file_088_BSS_SIZE = ABSOLUTE(file_088_BSS_END - file_088_BSS_START);
    }
    __romPos += SIZEOF(.file_088);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_088_ROM_END = __romPos;
    file_088_VRAM_END = .;

    file_089_ROM_START = __romPos;
    file_089_VRAM = ADDR(.file_089);
    .file_089 0x8038CFC0 : AT(file_089_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_089_TEXT_START = .;
        build-elf/asm/file_089.s.o(.text);
        . = ALIGN(., 16);
        file_089_TEXT_END = .;
        file_089_TEXT_SIZE = ABSOLUTE(file_089_TEXT_END - file_089_TEXT_START);
        file_089_DATA_START = .;
        build-elf/asm/file_089.s.o(.data);
        build-elf/asm/asm/data/file_089_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_089_DATA_END = .;
        file_089_DATA_SIZE = ABSOLUTE(file_089_DATA_END - file_089_DATA_START);
        file_089_RODATA_START = .;
        build-elf/asm/file_089.s.o(.rodata);
        . = ALIGN(., 16);
        file_089_RODATA_END = .;
        file_089_RODATA_SIZE = ABSOLUTE(file_089_RODATA_END - file_089_RODATA_START);
    }
    file_089_bss_VRAM = ADDR(.file_089_bss);
    .file_089_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_089_BSS_START = .;
        build-elf/asm/file_089.s.o(.bss);
        . = ALIGN(., 16);
        file_089_BSS_END = .;
        file_089_BSS_SIZE = ABSOLUTE(file_089_BSS_END - file_089_BSS_START);
    }
    __romPos += SIZEOF(.file_089);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_089_ROM_END = __romPos;
    file_089_VRAM_END = .;

    file_090_ROM_START = __romPos;
    file_090_VRAM = ADDR(.file_090);
    .file_090 0x8038CFC0 : AT(file_090_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_090_TEXT_START = .;
        build-elf/asm/file_090.s.o(.text);
        . = ALIGN(., 16);
        file_090_TEXT_END = .;
        file_090_TEXT_SIZE = ABSOLUTE(file_090_TEXT_END - file_090_TEXT_START);
        file_090_DATA_START = .;
        build-elf/asm/file_090.s.o(.data);
        build-elf/asm/asm/data/file_090_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_090_DATA_END = .;
        file_090_DATA_SIZE = ABSOLUTE(file_090_DATA_END - file_090_DATA_START);
        file_090_RODATA_START = .;
        build-elf/asm/file_090.s.o(.rodata);
        . = ALIGN(., 16);
        file_090_RODATA_END = .;
        file_090_RODATA_SIZE = ABSOLUTE(file_090_RODATA_END - file_090_RODATA_START);
    }
    file_090_bss_VRAM = ADDR(.file_090_bss);
    .file_090_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_090_BSS_START = .;
        build-elf/asm/file_090.s.o(.bss);
        . = ALIGN(., 16);
        file_090_BSS_END = .;
        file_090_BSS_SIZE = ABSOLUTE(file_090_BSS_END - file_090_BSS_START);
    }
    __romPos += SIZEOF(.file_090);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_090_ROM_END = __romPos;
    file_090_VRAM_END = .;

    file_091_ROM_START = __romPos;
    file_091_VRAM = ADDR(.file_091);
    .file_091 0x8038CFC0 : AT(file_091_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_091_TEXT_START = .;
        build-elf/asm/file_091.s.o(.text);
        . = ALIGN(., 16);
        file_091_TEXT_END = .;
        file_091_TEXT_SIZE = ABSOLUTE(file_091_TEXT_END - file_091_TEXT_START);
        file_091_DATA_START = .;
        build-elf/asm/file_091.s.o(.data);
        build-elf/asm/asm/data/file_091_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_091_DATA_END = .;
        file_091_DATA_SIZE = ABSOLUTE(file_091_DATA_END - file_091_DATA_START);
        file_091_RODATA_START = .;
        build-elf/asm/file_091.s.o(.rodata);
        . = ALIGN(., 16);
        file_091_RODATA_END = .;
        file_091_RODATA_SIZE = ABSOLUTE(file_091_RODATA_END - file_091_RODATA_START);
    }
    file_091_bss_VRAM = ADDR(.file_091_bss);
    .file_091_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_091_BSS_START = .;
        build-elf/asm/file_091.s.o(.bss);
        . = ALIGN(., 16);
        file_091_BSS_END = .;
        file_091_BSS_SIZE = ABSOLUTE(file_091_BSS_END - file_091_BSS_START);
    }
    __romPos += SIZEOF(.file_091);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_091_ROM_END = __romPos;
    file_091_VRAM_END = .;

    file_092_ROM_START = __romPos;
    file_092_VRAM = ADDR(.file_092);
    .file_092 0x8038CFC0 : AT(file_092_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_092_TEXT_START = .;
        build-elf/asm/file_092.s.o(.text);
        . = ALIGN(., 16);
        file_092_TEXT_END = .;
        file_092_TEXT_SIZE = ABSOLUTE(file_092_TEXT_END - file_092_TEXT_START);
        file_092_DATA_START = .;
        build-elf/asm/file_092.s.o(.data);
        build-elf/asm/asm/data/file_092_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_092_DATA_END = .;
        file_092_DATA_SIZE = ABSOLUTE(file_092_DATA_END - file_092_DATA_START);
        file_092_RODATA_START = .;
        build-elf/asm/file_092.s.o(.rodata);
        . = ALIGN(., 16);
        file_092_RODATA_END = .;
        file_092_RODATA_SIZE = ABSOLUTE(file_092_RODATA_END - file_092_RODATA_START);
    }
    file_092_bss_VRAM = ADDR(.file_092_bss);
    .file_092_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_092_BSS_START = .;
        build-elf/asm/file_092.s.o(.bss);
        . = ALIGN(., 16);
        file_092_BSS_END = .;
        file_092_BSS_SIZE = ABSOLUTE(file_092_BSS_END - file_092_BSS_START);
    }
    __romPos += SIZEOF(.file_092);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_092_ROM_END = __romPos;
    file_092_VRAM_END = .;

    file_093_ROM_START = __romPos;
    file_093_VRAM = ADDR(.file_093);
    .file_093 0x8038CFC0 : AT(file_093_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_093_TEXT_START = .;
        build-elf/asm/file_093.s.o(.text);
        . = ALIGN(., 16);
        file_093_TEXT_END = .;
        file_093_TEXT_SIZE = ABSOLUTE(file_093_TEXT_END - file_093_TEXT_START);
        file_093_DATA_START = .;
        build-elf/asm/file_093.s.o(.data);
        build-elf/asm/asm/data/file_093_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_093_DATA_END = .;
        file_093_DATA_SIZE = ABSOLUTE(file_093_DATA_END - file_093_DATA_START);
        file_093_RODATA_START = .;
        build-elf/asm/file_093.s.o(.rodata);
        . = ALIGN(., 16);
        file_093_RODATA_END = .;
        file_093_RODATA_SIZE = ABSOLUTE(file_093_RODATA_END - file_093_RODATA_START);
    }
    file_093_bss_VRAM = ADDR(.file_093_bss);
    .file_093_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_093_BSS_START = .;
        build-elf/asm/file_093.s.o(.bss);
        . = ALIGN(., 16);
        file_093_BSS_END = .;
        file_093_BSS_SIZE = ABSOLUTE(file_093_BSS_END - file_093_BSS_START);
    }
    __romPos += SIZEOF(.file_093);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_093_ROM_END = __romPos;
    file_093_VRAM_END = .;

    file_094_ROM_START = __romPos;
    file_094_VRAM = ADDR(.file_094);
    .file_094 0x8038CFC0 : AT(file_094_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_094_TEXT_START = .;
        build-elf/asm/file_094.s.o(.text);
        . = ALIGN(., 16);
        file_094_TEXT_END = .;
        file_094_TEXT_SIZE = ABSOLUTE(file_094_TEXT_END - file_094_TEXT_START);
        file_094_DATA_START = .;
        build-elf/asm/file_094.s.o(.data);
        build-elf/asm/asm/data/file_094_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_094_DATA_END = .;
        file_094_DATA_SIZE = ABSOLUTE(file_094_DATA_END - file_094_DATA_START);
        file_094_RODATA_START = .;
        build-elf/asm/file_094.s.o(.rodata);
        . = ALIGN(., 16);
        file_094_RODATA_END = .;
        file_094_RODATA_SIZE = ABSOLUTE(file_094_RODATA_END - file_094_RODATA_START);
    }
    file_094_bss_VRAM = ADDR(.file_094_bss);
    .file_094_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_094_BSS_START = .;
        build-elf/asm/file_094.s.o(.bss);
        . = ALIGN(., 16);
        file_094_BSS_END = .;
        file_094_BSS_SIZE = ABSOLUTE(file_094_BSS_END - file_094_BSS_START);
    }
    __romPos += SIZEOF(.file_094);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_094_ROM_END = __romPos;
    file_094_VRAM_END = .;

    file_095_ROM_START = __romPos;
    file_095_VRAM = ADDR(.file_095);
    .file_095 0x8038CFC0 : AT(file_095_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_095_TEXT_START = .;
        build-elf/asm/file_095.s.o(.text);
        . = ALIGN(., 16);
        file_095_TEXT_END = .;
        file_095_TEXT_SIZE = ABSOLUTE(file_095_TEXT_END - file_095_TEXT_START);
        file_095_DATA_START = .;
        build-elf/asm/file_095.s.o(.data);
        build-elf/asm/asm/data/file_095_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_095_DATA_END = .;
        file_095_DATA_SIZE = ABSOLUTE(file_095_DATA_END - file_095_DATA_START);
        file_095_RODATA_START = .;
        build-elf/asm/file_095.s.o(.rodata);
        . = ALIGN(., 16);
        file_095_RODATA_END = .;
        file_095_RODATA_SIZE = ABSOLUTE(file_095_RODATA_END - file_095_RODATA_START);
    }
    file_095_bss_VRAM = ADDR(.file_095_bss);
    .file_095_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_095_BSS_START = .;
        build-elf/asm/file_095.s.o(.bss);
        . = ALIGN(., 16);
        file_095_BSS_END = .;
        file_095_BSS_SIZE = ABSOLUTE(file_095_BSS_END - file_095_BSS_START);
    }
    __romPos += SIZEOF(.file_095);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_095_ROM_END = __romPos;
    file_095_VRAM_END = .;

    file_096_ROM_START = __romPos;
    file_096_VRAM = ADDR(.file_096);
    .file_096 0x8038CFC0 : AT(file_096_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_096_TEXT_START = .;
        build-elf/asm/file_096.s.o(.text);
        . = ALIGN(., 16);
        file_096_TEXT_END = .;
        file_096_TEXT_SIZE = ABSOLUTE(file_096_TEXT_END - file_096_TEXT_START);
        file_096_DATA_START = .;
        build-elf/asm/file_096.s.o(.data);
        build-elf/asm/asm/data/file_096_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_096_DATA_END = .;
        file_096_DATA_SIZE = ABSOLUTE(file_096_DATA_END - file_096_DATA_START);
        file_096_RODATA_START = .;
        build-elf/asm/file_096.s.o(.rodata);
        . = ALIGN(., 16);
        file_096_RODATA_END = .;
        file_096_RODATA_SIZE = ABSOLUTE(file_096_RODATA_END - file_096_RODATA_START);
    }
    file_096_bss_VRAM = ADDR(.file_096_bss);
    .file_096_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_096_BSS_START = .;
        build-elf/asm/file_096.s.o(.bss);
        . = ALIGN(., 16);
        file_096_BSS_END = .;
        file_096_BSS_SIZE = ABSOLUTE(file_096_BSS_END - file_096_BSS_START);
    }
    __romPos += SIZEOF(.file_096);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_096_ROM_END = __romPos;
    file_096_VRAM_END = .;

    file_097_ROM_START = __romPos;
    file_097_VRAM = ADDR(.file_097);
    .file_097 0x8038CFC0 : AT(file_097_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_097_TEXT_START = .;
        build-elf/asm/file_097.s.o(.text);
        . = ALIGN(., 16);
        file_097_TEXT_END = .;
        file_097_TEXT_SIZE = ABSOLUTE(file_097_TEXT_END - file_097_TEXT_START);
        file_097_DATA_START = .;
        build-elf/asm/file_097.s.o(.data);
        build-elf/asm/asm/data/file_097_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_097_DATA_END = .;
        file_097_DATA_SIZE = ABSOLUTE(file_097_DATA_END - file_097_DATA_START);
        file_097_RODATA_START = .;
        build-elf/asm/file_097.s.o(.rodata);
        . = ALIGN(., 16);
        file_097_RODATA_END = .;
        file_097_RODATA_SIZE = ABSOLUTE(file_097_RODATA_END - file_097_RODATA_START);
    }
    file_097_bss_VRAM = ADDR(.file_097_bss);
    .file_097_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_097_BSS_START = .;
        build-elf/asm/file_097.s.o(.bss);
        . = ALIGN(., 16);
        file_097_BSS_END = .;
        file_097_BSS_SIZE = ABSOLUTE(file_097_BSS_END - file_097_BSS_START);
    }
    __romPos += SIZEOF(.file_097);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_097_ROM_END = __romPos;
    file_097_VRAM_END = .;

    file_098_ROM_START = __romPos;
    file_098_VRAM = ADDR(.file_098);
    .file_098 0x8038CFC0 : AT(file_098_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_098_TEXT_START = .;
        build-elf/asm/file_098.s.o(.text);
        . = ALIGN(., 16);
        file_098_TEXT_END = .;
        file_098_TEXT_SIZE = ABSOLUTE(file_098_TEXT_END - file_098_TEXT_START);
        file_098_DATA_START = .;
        build-elf/asm/file_098.s.o(.data);
        build-elf/asm/asm/data/file_098_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_098_DATA_END = .;
        file_098_DATA_SIZE = ABSOLUTE(file_098_DATA_END - file_098_DATA_START);
        file_098_RODATA_START = .;
        build-elf/asm/file_098.s.o(.rodata);
        . = ALIGN(., 16);
        file_098_RODATA_END = .;
        file_098_RODATA_SIZE = ABSOLUTE(file_098_RODATA_END - file_098_RODATA_START);
    }
    file_098_bss_VRAM = ADDR(.file_098_bss);
    .file_098_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_098_BSS_START = .;
        build-elf/asm/file_098.s.o(.bss);
        . = ALIGN(., 16);
        file_098_BSS_END = .;
        file_098_BSS_SIZE = ABSOLUTE(file_098_BSS_END - file_098_BSS_START);
    }
    __romPos += SIZEOF(.file_098);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_098_ROM_END = __romPos;
    file_098_VRAM_END = .;

    file_099_ROM_START = __romPos;
    file_099_VRAM = ADDR(.file_099);
    .file_099 0x8038B7E0 : AT(file_099_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_099_TEXT_START = .;
        build-elf/asm/file_099.s.o(.text);
        . = ALIGN(., 16);
        file_099_TEXT_END = .;
        file_099_TEXT_SIZE = ABSOLUTE(file_099_TEXT_END - file_099_TEXT_START);
        file_099_DATA_START = .;
        build-elf/asm/file_099.s.o(.data);
        build-elf/asm/asm/data/file_099_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_099_DATA_END = .;
        file_099_DATA_SIZE = ABSOLUTE(file_099_DATA_END - file_099_DATA_START);
        file_099_RODATA_START = .;
        build-elf/asm/file_099.s.o(.rodata);
        . = ALIGN(., 16);
        file_099_RODATA_END = .;
        file_099_RODATA_SIZE = ABSOLUTE(file_099_RODATA_END - file_099_RODATA_START);
    }
    file_099_bss_VRAM = ADDR(.file_099_bss);
    .file_099_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_099_BSS_START = .;
        build-elf/asm/file_099.s.o(.bss);
        . = ALIGN(., 16);
        file_099_BSS_END = .;
        file_099_BSS_SIZE = ABSOLUTE(file_099_BSS_END - file_099_BSS_START);
    }
    __romPos += SIZEOF(.file_099);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_099_ROM_END = __romPos;
    file_099_VRAM_END = .;

    file_100_ROM_START = __romPos;
    file_100_VRAM = ADDR(.file_100);
    .file_100 0x8038B7E0 : AT(file_100_ROM_START) SUBALIGN(16)
    {
        FILL(0x00000000);
        file_100_TEXT_START = .;
        build-elf/asm/file_100.s.o(.text);
        . = ALIGN(., 16);
        file_100_TEXT_END = .;
        file_100_TEXT_SIZE = ABSOLUTE(file_100_TEXT_END - file_100_TEXT_START);
        file_100_DATA_START = .;
        build-elf/asm/file_100.s.o(.data);
        build-elf/asm/asm/data/file_100_data.data.s.o(.data);
        . = ALIGN(., 16);
        file_100_DATA_END = .;
        file_100_DATA_SIZE = ABSOLUTE(file_100_DATA_END - file_100_DATA_START);
        file_100_RODATA_START = .;
        build-elf/asm/file_100.s.o(.rodata);
        . = ALIGN(., 16);
        file_100_RODATA_END = .;
        file_100_RODATA_SIZE = ABSOLUTE(file_100_RODATA_END - file_100_RODATA_START);
    }
    file_100_bss_VRAM = ADDR(.file_100_bss);
    .file_100_bss (NOLOAD) : SUBALIGN(16)
    {
        FILL(0x00000000);
        file_100_BSS_START = .;
        build-elf/asm/file_100.s.o(.bss);
        build-elf/asm/asm/data/file_100_bss.bss.s.o(.bss);
        . = ALIGN(., 16);
        file_100_BSS_END = .;
        file_100_BSS_SIZE = ABSOLUTE(file_100_BSS_END - file_100_BSS_START);
    }
    __romPos += SIZEOF(.file_100);
    __romPos = ALIGN(__romPos, 16);
    . = ALIGN(., 16);
    file_100_ROM_END = __romPos;
    file_100_VRAM_END = .;

    /DISCARD/ :
    {
        *(*);
    }
}
