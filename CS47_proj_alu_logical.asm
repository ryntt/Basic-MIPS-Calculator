.include "./cs47_proj_macro.asm"
.data
mask:	.word 0x1
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	#RTE store
	rte_store
	# initializing "global" variables and conditions for add, sub, mult, or div
	beq $a2, '+', add_logical	# if mode is addition, jump to addition
	beq $a2, '-', sub_logical	# if mode is subtraction, jump to subtract
	beq $a2, '*', mul_unsigned	# if mode is multiplication, jump to multiplication unsigned
	beq $a2, '/', div_unsigned	
add_logical:
	move	$a2, $zero		# sets the mode to addition
	j 	add_sub_logical		# jumps to the main loop for addition
sub_logical:
	li	$t0, '-'		# algorithm for subtraction 
	bne	$t0, $a2, add_sub_logical
	move	$s0, $a0
	move	$a0, $a1
	jal	twos_complement
	move	$a0, $s0
	move	$a1, $v0
	j	add_sub_logical
twos_complement_if_neg:			# if the number is negative, find twos complement
	rte_store
	bltz	$a0, twos_complement	
	move	$v0, $a0
	caller_rte_restore
	jr	$ra
twos_complement:			# finding twos complement of the number
	rte_store
	move	$t0, $zero
	not	$a0, $a0
	move	$a1, $zero	
	jal	add_logical
	caller_rte_restore
	jr	$ra
twos_complement_64_bit:			# find the twos complement of a 64 bit number
	rte_store
	not	$a0, $a0	# !$a0
	not 	$a1, $a1	# !$a1
	move 	$s0, $a1	
	li	$a1, 1 
	jal	add_logical	# add !$a0 + 1
	move 	$a0, $s0
	move 	$a1, $v1	
	move 	$s1, $v0
	jal	add_logical	# add !$a1 + carry
	move	$v1, $v0	# $v1 = hi
	move	$v0, $s1	# $v0 = lo
	caller_rte_restore
	jr 	$ra
bit_replicator:			# bit replicator 
	rte_store
	beqz	$a0, all_f
	beq	$a0, 0x1, all_zero
all_zero:
	move	$v0, $zero
	j	bit_replicator_end
all_f:
	li	$v0, 0xFFFFFFFF
bit_replicator_end:
	caller_rte_restore
	jr	$ra
# body of add_sub_logical
add_sub_logical:
	move	$t0, $zero		# should set $t0 to i for incrementing in the for loop
	li	$v0, 0x00000000		# should set $v0 to the sum for addition and subtraction algorithms
	lw 	$t3, mask
	extract_nth_bit($v1, $a2, $zero)	# should set $v1 to C, the carry over bit (first set to $a2(0))
	beq	$a2, 0xFFFFFFFF, add_sub_logical_invert
add_sub_logical_resume:
	beq 	$t0, 32, au_logical_end		# for loop; if this equals 32, end the algorithm
	# initializing variables for the for loop
	extract_nth_bit($t4, $a0, $t0)		# should set $t4 to the $t0-th bit in $a0
	extract_nth_bit($t5, $a1, $t0)		# should set $t5 to the $t0-th bit in $a1
	xor 	$t6, $t4, $t5			# should set $t6 = $t4 XOR $t5 
	xor	$t2, $v1, $t6 			# $t2 = $v1 XOR $t6 = $v1 XOR ($t4 XOR $t5) (Y)
	and	$t7, $t4, $t5			# should set $t7 = $t4 AND $t5
	and	$t8, $v1, $t6			# should set $t8 = $v1 AND $t6
	or	$v1, $t7, $t8			# $v1 = $t7 OR $t8 = ($t4 AND $t5) OR ($v1 AND $t6)
	insert_to_nth_bit($v0, $t0, $t2, $t3)	# should insert bit $t2 into the $t0-th position of $v0)
	addi	$t0, $t0, 1			# should increment $t0 by 1
	j	add_sub_logical_resume		# loops back again to the for loop
add_sub_logical_invert:
	not	$a1, $a1			# invert $a1
	j	add_sub_logical_resume		# jump to main loop
# end of add_sub_logical
# start of unsigned multiplication
mul_unsigned:
	rte_store
	move	$t0, $zero			# i = 0
	move	$s0, $zero			# H ($s0) = 0
	move	$s1, $a1			# L ($s1) = multiplier
	move	$s0, $a0			# M ($s0) = multiplicand
	lw	$t6, mask
	li	$t5, 31
mul_unsigned_resume:
	beq	$t0, 32, mul_unsigned_end
	extract_nth_bit($t2, $s1, $zero)	# $t2 = L[0]
	move	$a0, $t2			# move L[0] to $a0 for bit replicator to use
	jal 	bit_replicator			# bit replicator of L[0]
	move	$t1, $v0			# $t1 = R = bit replicator of L[0]
	and	$t3, $s0, $t1			# t3 = X = M AND R	
	move	$a0, $s0			# move H to $a0 for addition
	move	$a1, $t3			# move X to $a1 for addition
	jal	add_logical			# add H and X
	move	$s0, $v0			# $s0 = H = H + X
	srl	$s1, $s1, 1			# $ shift L one bit right
	extract_nth_bit($t4, $s0, $zero)	# $t4 = H[0]
	insert_to_nth_bit($s1, $t5, $t4, $t6)	# inserts H[0] into L[31] 
	srl	$s0, $s0, 1			# H >> 1
	addi	$t0, $t0, 1			# i++
	j	mul_unsigned_resume
mul_unsigned_end:
	move	$v0, $s1
	move	$v1, $s0
	caller_rte_restore
	jr	$ra
mul_signed:
	rte_store
	move	$s0, $a0	
	move	$s1, $a1
	jal 	twos_complement_if_neg
	move	$s2, $v0	# move result of twos complement of a0 to s2
	move	$a0, $s1
	jal	twos_complement_if_neg
	move	$s3, $v0	# move result of twos complement of a1 to s3
	move	$a0, $s2
	move	$a1, $s3
	jal	mul_unsigned
	li	$s4, 31
	extract_nth_bit($s5, $s0, $s4)		# extract 31 bit of original a0
	extract_nth_bit($s6, $s1, $s4)		# extract 31 bit of original a1
	xor	$s7, $s5, $s6
	beq 	$s7, 0x1, mul_signed_64
	j	mul_signed_end
mul_signed_64:
	move 	$a0, $v0
	move	$a1, $v1
	jal	twos_complement_64_bit
	j	mul_signed_end
mul_signed_end:
	caller_rte_restore
	jr	$ra
div_unsigned:
	rte_store
	move	$t0, $zero		# i = 0
	move 	$s0, $a0		# q = dividend
	move	$s1, $a1		# d = divisor
	move	$s4, $zero		# r = 0
	li	$s2, 31			# setting a constant of 31
	lw	$s3, mask		# setting the mask
	li	$s5, 1
div_unsigned_resume:
	beq 	$t0, 32, div_unsigned_end
	sll	$s4, $s4, 1		# R = R << 1
	extract_nth_bit($t2, $s0, $s2)	# Q[31]
	insert_to_nth_bit($s4, $zero, $t2, $s3)		# R[0] = Q[31]
	sll	$s0, $s0, 1				# Q = Q << q
	move	$a0, $s4				# set a0 to R
	move	$a1, $s1				# set a1 to D
	jal	sub_logical				# subtract R - D
	bltz 	$v0, div_unsigned_cont			# S < 0 --> i++
	move	$s4, $v0				# move S to R
	insert_to_nth_bit($s0, $zero, $s5, $s3)		# Q[0] = 1
div_unsigned_cont:
	addi	$t0, $t0, 1				# i++
	j	div_unsigned_resume
div_unsigned_end:
	move	$v0, $s0
	move	$v1, $s4
	caller_rte_restore
	jr	$ra
div_signed:
	rte_store
	move	$s0, $a0	
	move	$s1, $a1
	jal 	twos_complement_if_neg
	move	$s2, $v0	# move result of twos complement of a0 to s2
	move	$a0, $s1
	jal	twos_complement_if_neg
	move	$s3, $v0	# move result of twos complement of a1 to s3
	move	$a0, $s2
	move	$a1, $s3
	jal	div_unsigned
	li	$s4, 31
	extract_nth_bit($t0, $s0, $s4)		# extract 31 bit of original a0
	extract_nth_bit($t1, $s1, $s4)		# extract 31 bit of original a1
	xor	$s7, $t0, $t1
	beq 	$s7, 0x1, q_twos_complement
div_signed_cont:
	beq 	$t1, 0x1, r_twos_complement	
div_signed_end:
	move	$v0, $s5
	move	$v1, $s6
	caller_rte_restore
	jr	$ra
q_twos_complement:
	move 	$a0, $v0
	jal	twos_complement
	move	$s5, $v0			# move v0 from two complement to s5
	j	div_signed_cont
r_twos_complement:
	move	$a0, $v1
	jal	twos_complement
	move	$s6, $v0			# move v1 from two complement to s6
	j	div_signed_end
au_logical_end:
	# Caller RTE restore (TBD)
	caller_rte_restore
	# end of program
	jr 	$ra
