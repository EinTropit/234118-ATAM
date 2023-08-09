.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
	pushq %rbp
	movq %rsp, %rbp
	# rdi = input
	# rsi = key
	movq $0, %r8 # index = 0

loop_km:
	cmpq $16, %r8 # if(index == 16)
	je exit_km

	movb (%rdi, %r8, 1), %r9b # temp_input = input[index]
	movb (%rsi, %r8, 1), %r10b # temp_key = key[index]
	xorb %r10b, %r9b # xor that
	movb %r9b, (%rdi, %r8, 1) # input[index] = temp_input
	
	incq %r8 # index++
	jmp loop_km

exit_km:
	leave
	ret



byteSubstitution:
	pushq %rbp
	movq %rsp, %rbp
	# rdi = input
	movq $0, %r8 # index = 0

loop_bs:
	cmpq $16, %r8 # if(index == 16)
	je exit_bs

	movzbq (%rdi, %r8, 1), %r9 # temp_input = input[index]
	leaq sbox(%rip), %r10
	movb (%r10, %r9, 1), %r9b # temp_input = AES_BS(temp_input)
	movb %r9b, (%rdi, %r8, 1) # input[index] = temp_input

	incq %r8 # index++
	jmp loop_bs

exit_bs:
	leave
	ret


shiftRows:
	pushq %rbp
	movq %rsp, %rbp
	# rdi = input	
	movq $0, %r8 # index = 0
	movq $0, %rcx # rol_amount = 0

loop_sr:
	cmpq $4, %r8 # if index == 4:
	je exit_sr

	movl (%rdi, %r8, 4), %r10d # temp_row = input[4*index:4*index+3]
	rorl %cl, %r10d # rotating the values
	movl %r10d, (%rdi, %r8, 4) # input[4*index:4*index+3] = temp_row
	
	incq %r8 # index++
	addb $8, %cl # rol_amount += 8
	jmp loop_sr

exit_sr:	
	leave
	ret


cipher:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %rbx

	movq %rdi, %r12 # rdi = r12 = input 
	movq %rsi, %r13	# rsi = r13 = key
	movq %rdx, %r14 # rdx = r14 = len
	movq $0, %r15 # block_index = 0


block_loop_cipher: 
	cmpq %r14, %r15 # if(block_index == block_placement)
	je exit_cipher

	# a call KM
	movq %r12, %rdi
	movq %r13, %rsi
	call keyMixing

	# b do 9 times:
	movq $0, %rbx # nr_idx = 0
loop_NR:	
	cmpq $9, %rbx # if(nr_idx == 9)
	je exit_NR

	# 	1	call BS
	movq %r12, %rdi
	call byteSubstitution
	#	2	call SR
	movq %r12, %rdi
	call shiftRows
	#	3	call MC
	movq %r12, %rdi
	call mixColumns
	#	4	call KM
	movq %r12, %rdi
	movq %r13, %rsi
	call keyMixing

	incq %rbx # nr_index++
	jmp loop_NR

exit_NR:
	# c call BS
	movq %r12, %rdi
	call byteSubstitution
	# d call SR
	movq %r12, %rdi
	call shiftRows
	# e call KM
	movq %r12, %rdi
	movq %r13, %rsi
	call keyMixing

	addq $16, %r12
	incq %r15 # block_index++
	jmp block_loop_cipher

exit_cipher:
	popq %rbx
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	leave
	ret
