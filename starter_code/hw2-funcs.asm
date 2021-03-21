############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  jr $ra

#check if an input is a valid digit
is_digit:
  li    $t0, 48		# $t0 = 48
  li    $t1, 57		# $t1 = 57
  slt   $t3, $a0, $t0
  bne		$t3, $0, invalid_digit	# if $t3 != $0 then invalid_digit
  slt   $t3, $t1, $a0
  bne		$t3, $0, invalid_digit	# if $t3 != $0 then invalid_digit
  li		$v0, 1		# $v0 = 1
  jr $ra

invalid_digit:
  li		$v0, 0		# $v0 = 0
  jr $ra

stack_push:
  li		$t0, 2000		# $t0 = 2000
  bge		$a1, $t0, stack_overflow 	# if $a0 >= $10 then stack_overflow
  add		$a2, $a2, $a1		# $a2 = $a2 + $a1
  sw		$a0, 0($a2)		# 
  addi	$a1, $a1, 4			# $a1 = $a1 + 4
  move 	$v0, $a1		# $v0 = $a1
  jr $ra

stack_overflow:
  la		$a0, ParseError		# 
  li		$v0, 4		# $v0 = 4
  syscall
  j exit

stack_peek:
  li		$t0, -4		# $t0 = -4
  beq		$a0, $t0, empty_stack_err	# if $a0 == $t0 then empty_pop_err
  add		$a1, $a1, $a0		# $a1 = $a1 + $a0
  lw		$v0, 0($a1)		# 
  jr $ra

stack_pop:
  li		$t0, -4		# $t0 = -4
  beq		$a0, $t0, empty_stack_err	# if $a0 == $t0 then empty_pop_err
  add		$a1, $a1, $a0		# $a1 = $a1 + $a0
  lw		$v1, 0($a1)		# 
  move 	$v0, $a0		# $v0 = $a0
  jr $ra

empty_stack_err:

  li		$v0, 4		# $v0 = 4
  syscall
  j exit

is_stack_empty:
  li		$t0, -4		# $t0 = -4
  bne		$a0, $t0, empty_stack_err	# if $a0 != $t0 then empty_pop_err
  li		$v0, 1		# $v0 = 1
  jr $ra

empty_stack_false:
  li		$v0, 0		# $v0 = 0
  jr $ra

#check if an input is a valid boolean operator
valid_ops:
  li		$t0, '+'		# $t0 = '+'
  beq		$a0, $t0, is_valid_op	# if $a0 == $t0 then is_valid_op
  li		$t0, '-'		# $t0 = '-'
  beq		$a0, $t0, is_valid_op	# if $a0 == $t0 then is_valid_op
  li		$t0, '*'		# $t0 = '*'
  beq		$a0, $t0, is_valid_op	# if $a0 == $t0 then is_valid_op
  li		$t0, '/'		# $t0 = '/'
  beq		$a0, $t0, is_valid_op	# if $a0 == $t0 then is_valid_op
  li		$v0, 0		# $v0 = 0
  jr  $ra

is_valid_op:
  li		$v0, 1		# $v0 = 1
  jr $ra

#check the precedence of the boolean operator
op_precedence:
  li		$v0, 1		  #$v0 = 1
  li		$t1, '+'		# $t1 = '+'
  li		$t2, '-'		# $t2 = '-'
  beq		$a0, $t1, valid_precedence 	# if $a0 == $t1 then valid_precedence
  beq		$a0, $t2, valid_precedence	# if $a0 == $t2 then valid_precedence
  li		$v0, 2		  #$v0 = 2
  li		$t1, '*'		# $t1 = '*'
  li		$t2, '/'		# $t2 = '/'
  beq		$a0, $t1, valid_precedence 	# if $a0 == $t1 then valid_precedence
  beq		$a0, $t2, valid_precedence	# if $a0 == $t2 then valid_precedence
  la $a0, BadToken
  li $v0, 4
  syscall
  j	exit			
  

valid_precedence:
  jr $ra

#apply the boolean operation to two integers
apply_bop:
  li		$t1, '+'		# $t1 = '+'
  beq		$a1, $t1, add_op	# if $a1 == $t  add_op
  li		$t1, '-'		# $t1 = '-'
  beq		$a1, $t1, sub_op	# if $a1 == $t  sub_op
  li		$t1, '*'		# $t1 = '*'
  beq		$a1, $t1, mult_op	# if $a1 == $t  mult_op
  li		$t1, '/'		# $t1 = '/'
  beq		$a1, $t1, div_op	# if $a1 == $t  div_op

add_op:
  add		$v0, $a0, $a2		# $v0 = $a0 + $a2
  jr $ra

sub_op:
  sub		$v0, $a0, $a2		# $v0 = $a0 - $a2
  jr $ra

mult_op:
  mult	$a0, $a2			# $a0 * $a2 = Hi and Lo registers
  mflo	$v0					# copy Lo to $v0
  jr $ra

div_op: 
  li		$t0, 0		# $t0 = 0
  beq		$a2, $0, div_by_zero	# if $a2 == $0 then div_by_zero
  div		$a0, $a2			# $a0 / $a2
  mflo	$v0					# $v0 = floor($a0 / $a2)
  bgtz  $a0, second_arg_neg
  addi	$t0, $t0, 1			# $t0 = $t0 + 1
  bgtz  $a2, check_neg_counter
  addi	$t0, $t0, 1			# $t0 = $t0 + 1
  j check_neg_counter

second_arg_neg:
  bgtz  $a2, check_neg_counter
  addi	$t0, $t0, 1			# $t0 = $t0 + 1
  j check_neg_counter

check_neg_counter:
  li		$t1, 1		# $t1 = 1
  mfhi  $t2
  bne		$t0, $t1, floor_neg	# if $t0 != $t1 then floor_neg
  beq		$t2, $0, floor_neg	# if $t2 = $0 then floor_neg
  addi	$v0, $v0, -1			# $v0 = $v0 + -1
  jr $ra 
  
floor_neg:  
  jr $ra 

div_by_zero:
  la $a0, ApplyOpError
  li $v0, 4
  syscall
  j exit
  # li		$v0, 'e'		# $v0 = 'e'
  # jr $ra

exit:
  li $v0, 10
  syscall
