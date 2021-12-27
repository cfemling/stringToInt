#cassidy femling
.data
error1:	.asciiz "incorrect characters in string\n"
error2:	.asciiz "base is out of range\n"
.align 2
string:	.asciiz "F"

.text
	la	$a0, string			# $s0 = string address
	addi	$a1, $0, 16			# $a1 = base
	jal	stringToInt
	move	$a0, $v0			# $a0 = result
	li	$v0, 1
	syscall
	li	$v0, 10
	syscall

# function to convert string of a certain base into an integer
stringToInt:					# $a0 = string address; $a1 = base
	addi	$t0, $0, 2
	addi	$t1, $0, 16
	slt	$t2, $a1, $t0
	bne	$t2, $0, endError2		# base input < 2
	slt	$t2, $t1, $a1
	bne	$t2, $0, endError2		# base input > 16
	addi	$sp, $sp, -4			# free space
	sw	$ra, 0($sp)			# store $ra
	jal	checkSize
	lw	$ra, 0($sp)			# restore $ra
	addi	$sp, $sp, 4			# restore $sp
	addi	$sp, $sp, -12			# free space
	sw	$s0, 8($sp)			# store $s0
	sw	$s1, 4($sp)			# store $s1
	sw	$s2, 0($sp)			# store $s2
	move	$s0, $v0			# $s0 = size
	beq	$s0, $0, end			# if  string is empty, end
	move	$s1, $0				# $s1 = result
	move	$s2, $0				# $s2 = digit
	addi	$t3, $0, 1			# $t3 = position value
	while1:
		sub	$t4, $s0, $s2
		addi	$t4, $t4, -1		# $t4 = modified index
		add	$t5, $a0, $t4		# $t5 = address of string[index]
		lb	$t5, 0($t5)		# $t5 = current digit
		addi	$sp, $sp, -8		# free space
		sw	$a0, 4($sp)		# store $a0
		sw	$ra, 0($sp)		# store $ra
		move	$a0, $t5		# current digit
		jal	convertDigit
		move	$t6, $v0		# $t6 = current digit value
		lw	$ra, 0($sp)		# restore $ra
		lw	$a0, 4($sp)		# restore $a0
		addi	$sp, $sp, 8		# restore $sp
		mult	$t6, $t3		# $t6 = current digit value * position value
		mflo	$t6
		add	$s1, $s1, $t6		# result = result + $t6
		mult	$t3, $a1		# position value increase by base
		mflo	$t3
		addi	$s2, $s2, 1		# increase digit
		slt	$t7, $s2, $s0		# check digit < size
		bne	$t7, $0, while1		# repeat while if digit < size
	done:
	move	$v0, $s1			# set result
	lw	$s2, 0($sp)			# restore $s2
	lw	$s1, 4($sp)			# restore $s1
	lw	$s0, 8($sp)			# restore $s0
	addi	$sp, $sp, 8			# restore $sp
	jr	$ra				# end of stringToInt
	
# function to iterate through string and return number of chars
checkSize:
	move	$t0, $0				# $t0 = index
	move	$t1, $0				# $t1 = size of string
	while2:
		add	$t2, $a0, $t0		# $t2 = address of string[index]
		lb	$t3, 0($t2)		# $t3 = element string[index]
		beq	$t3, $0, endWhile2	# if char is null, end loop
		addi	$t0, $t0, 1		# increase index
		addi	$t1, $t1, 1		# increase size
		j	while2
	endWhile2:
		move	$v0, $t1		# return size
		jr	$ra			# continue to stringToInt

# branch to handle negative char
isNeg:
	bne	$t4, $0, endError1		# branch if neg sign is in the middle
	addi	$t2, $0, -1
	mult	$s1, $t2			# make answer negative
	mflo	$s1
	lw	$ra, 0($sp)			# restore $ra
	lw	$a0, 4($sp)			# restore $a0
	addi	$sp, $sp, 8			# restore $sp
	j	done				# go to end of stringToInt function

# function to convert string char value to decimal value
convertDigit:
	addi	$t0, $0, 47			
	slt	$t0, $t0, $a0			# $t0 = 1 if current digit > 47
	addi	$t1, $0, 58
	slt	$t1, $a0, $t1			# $t1 = 1 if current digit < 58
	beq	$t0, $t1, number		# if $t0 = $t1 = 1 then branch (cant both be 0)
	addi	$t0, $0, 64
	slt	$t0, $t0, $a0			# $t0 = 1 if current digit > 64
	addi	$t1, $0, 71
	slt	$t1, $a0, $t1			# $t1 = 1 if current digit < 71
	beq	$t0, $t1, letter		# if $t0 = $t1 = 1 then branch (cant both be 0)
	addi	$t2, $0, 45			# value for neg sign
	beq	$t2, $a0, isNeg			# branch if neg
	j	endError1			# else error

# branch to handle conversion of 0-9
number:
	addi	$v0, $a0, -48
	slt	$t1, $v0, $a1			# if current converted digit is out of range of base
	beq	$t1, $0, endError1		# error
	jr	$ra				# else continue
	
# branch to handle conversion of A-F
letter:
	addi	$v0, $a0, -65
	addi	$v0, $v0, 10
	slt	$t1, $v0, $a1			# if current converted digit is out of range of base
	beq	$t1, $0, endError1		# error
	jr	$ra				# else continue
	
# branch to handle empty string
end:
	move	$v0, $0				# return 0
	lw	$s2, 0($sp)			# restore $s2
	lw	$s1, 4($sp)			# restore $s1
	lw	$s0, 8($sp)			# restore $s0
	addi	$sp, $sp, 8			# restore $sp
	jr	$ra				# end of stringToInt
	
# branch to handle incorrect characters in string input
endError1:
	lw	$ra, 0($sp)			# restore $ra
	lw	$a0, 4($sp)			# restore $a0
	lw	$s2, 8($sp)			# restore $s2
	lw	$s1, 12($sp)			# restore $s1
	lw	$s0, 16($sp)			# restore $s0
	addi	$sp, $sp, 20			# restore $sp
	la	$a0, error1			# display error
	li	$v0, 4
	syscall
	move	$v0, $0				# return 0
	jr	$ra				# end of stringToInt
	
# branch to handle incorrect characters in base input
endError2:
	la	$a0, error2			# display error
	li	$v0, 4
	syscall
	move	$v0, $0				# return 0
	jr	$ra				# end of stringToInt
