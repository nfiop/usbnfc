
/*
 * STM32H753ZITx
 * NUCLEO-H753ZI
 *
 * Cortex-M7
 * Flash: 2 MB
 * RAM:   1 MB total
 */

/* Entry point */
ENTRY(Reset_Handler)

/* Initial stack pointer */
_estack = ORIGIN(RAM_D1) + LENGTH(RAM_D1);

/* Minimum heap and stack sizes */
_Min_Heap_Size  = 0x200;
_Min_Stack_Size = 0x400;

MEMORY
{
    FLASH   (rx)  : ORIGIN = 0x08000000, LENGTH = 2048K

    DTCMRAM (xrw) : ORIGIN = 0x20000000, LENGTH = 128K

    RAM_D1  (xrw) : ORIGIN = 0x24000000, LENGTH = 512K

    RAM_D2  (xrw) : ORIGIN = 0x30000000, LENGTH = 288K

    RAM_D3  (xrw) : ORIGIN = 0x38000000, LENGTH = 64K
}

SECTIONS
{
    /* Interrupt vector table */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } > FLASH

    /* Program code */
    .text :
    {
        . = ALIGN(4);

        *(.text)
        *(.text*)

        *(.glue_7)
        *(.glue_7t)

        *(.eh_frame)

        KEEP(*(.init))
        KEEP(*(.fini))

        . = ALIGN(4);
        _etext = .;
    } > FLASH

    /* Read-only data */
    .rodata :
    {
        . = ALIGN(4);

        *(.rodata)
        *(.rodata*)

        . = ALIGN(4);
    } > FLASH

    /* Exception handling information */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH

    .ARM.exidx :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } > FLASH

    /* C/C++ initialization arrays */
    .preinit_array :
    {
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP(*(.preinit_array*))
        PROVIDE_HIDDEN(__preinit_array_end = .);
    } > FLASH

    .init_array :
    {
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array*))
        PROVIDE_HIDDEN(__init_array_end = .);
    } > FLASH

    .fini_array :
    {
        PROVIDE_HIDDEN(__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array*))
        PROVIDE_HIDDEN(__fini_array_end = .);
    } > FLASH

    /* Initialized data: stored in FLASH, copied to RAM */
    _sidata = LOADADDR(.data);

    .data :
    {
        . = ALIGN(4);

        _sdata = .;
        *(.data)
        *(.data*)

        . = ALIGN(4);
        _edata = .;
    } > RAM_D1 AT> FLASH

    /* Zero-initialized data */
    .bss :
    {
        . = ALIGN(4);

        _sbss = .;
        __bss_start__ = _sbss;

        *(.bss)
        *(.bss*)
        *(COMMON)

        . = ALIGN(4);

        _ebss = .;
        __bss_end__ = _ebss;
    } > RAM_D1

    /* Heap and stack reservation */
    ._user_heap_stack :
    {
        . = ALIGN(8);

        PROVIDE(end = .);
        PROVIDE(_end = .);

        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;

        . = ALIGN(8);
    } > RAM_D1

    /* Uninitialized data that must survive startup */
    .noinit (NOLOAD) :
    {
        . = ALIGN(4);
        *(.noinit)
        *(.noinit*)
        . = ALIGN(4);
    } > RAM_D1

    /* Remove unused metadata */
    /DISCARD/ :
    {
        *(.note.GNU-stack)
    }

    .ARM.attributes 0 :
    {
        *(.ARM.attributes)
    }
}

/* Check that RAM allocations fit */
ASSERT(_ebss <= ORIGIN(RAM_D1) + LENGTH(RAM_D1),
       "RAM_D1 overflow")

