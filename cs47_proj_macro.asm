# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	# $regD = the bit to display, $regS = bit pattern to extract from, $regT = nth value to extract from
	#extracts the nth bit from a bit pattern and displays it 
	.macro extract_nth_bit($regD, $regS, $regT)
	move	$s1, $regS
	srlv 	$s1, $s1, $regT
	andi 	$regD, $s1, 1 
	.end_macro
	
	# $regD = bit pattern to insert a bit in, $regS = the location to insert, $regT = the bit to insert, $maskReg = the mask to filter out the location to insert
	# inserts a bit into the nth value of a bit pattern 
	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li	$maskReg, 1
	sllv	$maskReg, $maskReg, $regS
	not	$maskReg, $maskReg
	and	$regD, $regD, $maskReg
	sllv	$regT, $regT, $regS
	or	$regD, $regT, $regD
	.end_macro
	
	.macro rte_store
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$s0, 52($sp)
	sw	$s1, 48($sp)
	sw	$s2, 44($sp)
	sw	$s3, 40($sp)
	sw	$s4, 36($sp)
	sw	$s5, 32($sp)
	sw	$s6, 28($sp)
	sw	$s7, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$a3, 8($sp)
	addi	$fp, $sp, 60
	.end_macro
	
	.macro caller_rte_restore
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$s0, 52($sp)
	lw	$s1, 48($sp)
	lw	$s2, 44($sp)
	lw	$s3, 40($sp)
	lw	$s4, 36($sp)
	lw	$s5, 32($sp)
	lw	$s6, 28($sp)
	lw	$s7, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$a3, 8($sp)
	addi	$sp, $sp, 60
	.end_macro
	
