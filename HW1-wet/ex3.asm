.global _start

.section .text
_start:
    movq $0, %rax # array2 index [a]
    movq $0, %rbx # array2 index [b]
    movq $0, %rcx # mergedArray index [c]
    movl $0, %r8d # temp1
    movl $0, %r9d # temp2

loop_HW1:
    # do
    movl array1(, %rax, 4), %r8d
    movl array2(, %rbx, 4), %r9d
    cmpl %r8d, %r9d # if array1[a] <= array2[b]
    jae fill2_HW1 # insert from array 1
    jmp fill1_HW1 # else insert from array2

fill1_HW1:
    movl array1(, %rax, 4), %r8d # temp = array1[a]
    inc %rax # a++
    jmp ret_loop_HW1

fill2_HW1:
    movl array2(, %rbx, 4), %r8d # temp = array2[b]
    inc %rbx # b++
    jmp ret_loop_HW1

ret_loop_HW1:
	cmpq $0, %rcx # if c == 0
	je first_HW1 # don't check previous
	dec %rcx # c--
    movl mergedArray(, %rcx, 4), %r9d
    cmpl %r9d, %r8d # if temp == mergedArray[c-1]
    je skip_HW1 # don't insert to mergedArray
	inc %rcx # c++
first_HW1:
    movl %r8d, mergedArray(, %rcx, 4) # meregedArray[c] = temp
    
    # loop condition
    cmpl $0, %r8d # if meregedArray[c] == 0
    je exit_HW1

skip_HW1:
	inc %rcx # c++
    jmp loop_HW1


exit_HW1:

