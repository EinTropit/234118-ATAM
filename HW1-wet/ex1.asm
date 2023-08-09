.global _start


.section .text
_start:
    movq (num), %rax # num value
    movq $0, %rbx # loop index
    movb $0, %cl # return value
loop_HW1:
    cmp $64, %rbx
    jge exit_HW1

    movq $1, %rdx # set rdx to 1
    and %rax, %rdx # and the register to see if the bit in rax is 1
    add %dl, %cl # add the and value to cl
    rol $1, %rax # roll rax left by 1 bit to have the next bit as the lsb
    add $1, %rbx
    jmp loop_HW1

exit_HW1:
    movb %cl, (Bool)
    



