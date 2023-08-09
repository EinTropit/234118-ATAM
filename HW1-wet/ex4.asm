.global _start

.section .text
_start:
    movl (Value), %ebx # value

    movq (head),   %r8  # currNode address, starts with head
    movq $head,    %r9  # currnode->parent address. starts with null
    movq $0,       %r10 # currnode->next address.
    movq (Source), %r11 # source address
    movq $head,    %r12 # source->parent address. starts with null
    movq 4(%r11),  %r13 # source->next address

    movq $0, %r15 # temp


find_source_parent_HW1:
    # loop condition
    cmpq %r11, %r8 # if currNode == source
    je init_head_HW1

    leaq 4(%r8), %r12 # source->parent = &currNode->next
    movq 4(%r8), %r8 # currNode = currNode->next
    jmp find_source_parent_HW1


init_head_HW1:
    movq (head), %r8 

find_val_HW1:
    # loop condition
    cmpq $0, %r8 # if currNode == NULL
    je exit_HW1

    movl (%r8), %r15d
    cmpl %r15d, %ebx # if currNode->val == value
    je swap_nodes_HW1

    leaq 4(%r8), %r9  # valNode->parent = &currNode->next
    movq 4(%r8), %r8 # currNode = currNode->next
    jmp find_val_HW1

swap_nodes_HW1: 
    cmpq %r8, %r11 # val == source
    je exit_HW1

    movq 4(%r8), %r10


    movq %r8, (%r12)
    movq %r13, 4(%r8)

    movq %r11, (%r9)
    movq %r10, 4(%r11)
    
    cmpq  4(%r8),  %r8
    je near_fix_HW1
    cmpq  4(%r11),  %r11
    je near_fix_HW1
    jmp exit_HW1

near_fix_HW1:

    cmpq (%r12), %r8
    je near_fix_2_HW1
    movq %r8, 4(%r11)
    jmp exit_HW1

near_fix_2_HW1:
    movq %r11, 4(%r8)
    jmp exit_HW1

exit_HW1:

