.global _start

.section .text
_start:
    movl (num), %eax # num
    movq $0, %rdx # offset

    # check for num negativity
    cmpl $0, %eax # if 0 > num
    jl negative_HW1

    movq $source, %r9
    movq $destination, %r10
    cmpq %r9, %r10 # if source > destination
    jb normal_loop_HW1
  
    movq %rax, %rdx # offset = num
    jmp reverse_loop_HW1


normal_loop_HW1:
    # loop condition
    cmpl %edx, %eax # if offset >= num
    jle exit_HW1

    # take from src + ofst and write to dest + ofst
    movb source(%rdx), %r8b
    movb %r8b, destination(%rdx)
    inc %rdx
    
    jmp normal_loop_HW1

reverse_loop_HW1:
    dec %rdx
    # loop condition
    cmpq $0, %rdx # if 0 > offset
    jl exit_HW1

    # take from src + ofst and write to dest + ofst
    movb source(%rdx), %r8b
    movb %r8b, destination(%rdx)
    
    jmp reverse_loop_HW1

negative_HW1:
    movl %eax, (destination) 

exit_HW1:



