#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
    asm ("SIDT %0" : "=m" (*idtr) );
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
    asm ("LIDT %0" : : "m" (*idtr) );
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    gate->offset_low = (unsigned short) addr;
    addr = addr >> 16;
    gate->offset_middle = (unsigned short) addr;
    addr = addr >> 16;
    gate->offset_high = (unsigned int) addr;
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    unsigned long addr = gate->offset_high;
    addr = addr << 16;
    addr += gate->offset_middle;
    addr = addr << 16;
    addr += gate->offset_low;
    return addr;
// </STUDENT FILL>
}
