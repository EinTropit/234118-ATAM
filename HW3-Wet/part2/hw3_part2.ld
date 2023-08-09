
ENTRY(_hw3_unicorn)

EXTERN(purple)
EXTERN(white)

PHDRS
{
  data PT_LOAD AT(0x60000) FLAGS(6);
  text PT_LOAD AT(0x400000) FLAGS(3);
  rodata PT_LOAD AT(0x80000000) FLAGS(5);
}

SECTIONS
{
  . = 0x60000;
  .data : {	*(.data) } : data
	.bss : { *(.bss) } : data
  
  . = 0x400000;
  .text : {	*(.text) } : text

  . = 0x80000000;
  .rodata : { *(.rodata) } : rodata
}
