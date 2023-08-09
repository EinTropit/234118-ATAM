.global _start

.section .text
_start:
    movq (root), %rax # currNode = *root
    movq $root, %rbx # toWrite = root
    movq (new_node), %rcx # new_node->data
    movq $0, %r8 # temp

loop_HW1:
    # loop condition
    cmpq $0, %rax # if currNode == NULL
    je addNode_HW1
    
    movq (%rax), %r8
    cmpq %rcx, %r8  # if(curNode->data > new_node->data)
    ja lson_HW1
    jb rson_HW1
    je exit_HW1

lson_HW1:
    leaq 8(%rax), %rbx # toWrite = &currNode->left
    movq 8(%rax), %rax # currNode = currNode->left
    jmp loop_HW1

rson_HW1:
    leaq 16(%rax), %rbx # toWrite = &currNode->right
    movq 16(%rax), %rax # currNode = currNode->right
    jmp loop_HW1

addNode_HW1:
    movq $new_node, (%rbx) # *toWrite = &newNode

exit_HW1:

