.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  ####### Some smart student's code here #######
  pushq %rax
  pushq %rsi
  pushq %rdx
  pushq %rcx
  pushq %r8
  pushq %r9
  pushq %r10
  pushq %r11
  pushq %r12
  pushq %rbx

  movq $0, %rbx
  movq 80(%rsp), %r12
  movb (%r12), %bl
  cmpb $0x0F, %bl
  je two_byte_opcode # short for 2 bytes
  leaq 1(%r12), %r12
  jmp end_opcode
two_byte_opcode:
  movb 1(%r12), %bl
  leaq 2(%r12), %r12
end_opcode:

  pushq %rdi
  movq %rbx, %rdi
  call what_to_do
  popq %rdi
  
  cmpq $0, %rax
  je default_handler

  movq %r12, 80(%rsp)
  movq %rax, %rdi
  jmp exit_ili_handler

default_handler: 
  popq %rbx
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rcx
  popq %rdx
  popq %rsi
  popq %rax

  jmp *old_ili_handler

exit_ili_handler:
  popq %rbx
  popq %r12
  popq %r11
  popq %r10
  popq %r9
  popq %r8
  popq %rcx
  popq %rdx
  popq %rsi
  popq %rax


  iretq
  
