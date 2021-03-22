############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  #saving caller $s registers on the stack
  addi	$sp, $sp, -36			# $sp = $sp + -28 
  sw		$s0, 0($sp)		# 
  sw		$s1, 4($sp)		# 
  sw		$s2, 8($sp)		# 
  sw		$s3, 12($sp)		# 
  sw		$s4, 16($sp)		#
  sw		$s5, 20($sp)		#
  sw		$s6, 24($sp)		#
  sw		$s7, 28($sp)		# 
  sw		$ra, 32($sp)		#
  
  #initializing the stacks
  la		$s0, val_stack		#
  li		$s1, 0		# $s6 = 0 
  la		$s2, op_stack		# 
  addi	$s2, $s2, 2000			# $s2 = $ts2+ 2000
  li		$s3, 0		# $t3 = 0

  move 	$s4, $a0		# $s4 = $a0 string address
  lb	$s5, 0($s4)	# 

  j read_and_simplify


#read the string and branch based on if char is a number
read_and_simplify:
  beq		$s5, $0, op_stack_empty	# if $s5 == $0 then finish_computation

  #check if digit
  move 	$a0, $s5		# $a0 = $s5
  jal		is_digit				# jump to is_digit and save position of $ra

  beq		$v0, $0, is_not_num	# if $s5 == $0 then is_not_num
  
  #get the number
  move 	$a0, $s4		# $a0 = $s4
  jal		get_number				# jump to get_number and save position to $ra
  move 	$s6, $v0		# $s6 = $v0
  move 	$s4, $v1		# $s4 = $v1

  #add number to the stack
  j do_stack_push_num


#pushes to the stack if its an op or paren, returns error otherwise
is_not_num:
  li 		$t0, '('
  beq		$s5, $t0, do_stack_push_op	# if $s5 == $t2 then do_stack_push_op
  li 		$t0, ')'
  beq		$s5, $t0, adjacent_parens # if $s5 == $t3 then eval_cParen
  
  #use the function
  move 	$a0, $s5		# $a0 = $s5
  jal		valid_ops				# jump to  and save position to $ra

  bne		$v0, $0, eval_op	# if $v0 != $0 then eval_op

  j invalid_char

eval_op:
  #if stack empty then push op
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  bne		$v0, $0, do_stack_push_op	# if $v0 != $0 then do_stack_push_op

  #peek the stop of the op stack
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  move 	$a1, $s2		# $a1 = $s2
  jal		stack_peek				# jump to stack_peek and save position to $ra
  
  #check if top of the stack is parenthesis
  li		$t0, '('		# $t0 = '('
  beq		$v0, $t0, do_stack_push_op	# if $v0 == $t0 then do_stack_push_op

  #get the precedence for top of stack
  move $a0, $v0
  jal		op_precedence				# jump to op_precedence and save position to $ra
  move 	$s7, $v0		# $t0 = $v0

  #get the precedence for current op 
  move 	$a0, $s5		# $a0 = $s5
  jal		op_precedence				# jump to op_precedence and save position to $ra
  move 	$t0,$s7		# $t0 =$s7
  move 	$t1, $v0		# $t1 = $v0

  #if top < current, just push current
  blt		$t0, $t1, do_stack_push_op	
  
  #pop and apply and save new tps
  move 	$a0, $s0		# $a0 = $s0
  move 	$a1, $s1		# $a1 = $s1
  move 	$a2, $s2		# $a2 = $s2
  move 	$a3, $s3		# $a3 = s31
  jal		pop_and_apply				# jump to pop_and_apply and save position to $ra
  move 	$s1, $v0		# $s1 = $v0
  move 	$s3, $v1		# $s3 = $v1

  j		eval_op       # jump to eval_op

adjacent_parens:
  #peek the top of the op stack
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  move 	$a1, $s2		# $a1 = $s2
  jal		stack_peek				# jump to stack_peek and save position to $ra
  
  #check if top of the stack is parenthesis
  li		$t0, '('		# $t0 = '('
  beq		$v0, $t0, parse_error	# if $v0 == $t0 then do_stack_push_op

  j eval_cParen

eval_cParen:
  #if stack empty then throw error
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  bne		$v0, $0, parse_error	# if $v0 != $0 then parse_error

  #peek the top of the op stack
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  move 	$a1, $s2		# $a1 = $s2
  jal		stack_peek				# jump to stack_peek and save position to $ra
  
  #check if top of the stack is parenthesis
  li		$t0, '('		# $t0 = '('
  beq		$v0, $t0, paren_eval_done	# if $v0 == $t0 then do_stack_push_op

  # #get the precedence for top of stack
  # move $a0, $v0
  # jal		op_precedence				# jump to op_precedence and save position to $ra
  # move 	$s7, $v0		# $t0 = $v0

  # #get the precedence for current op 
  # move 	$a0, $s5		# $a0 = $s5
  # jal		op_precedence				# jump to op_precedence and save position to $ra
  # move 	$t0,$s7		# $t0 =$s7
  # move 	$t1, $v0		# $t1 = $v0

  # #if top < current, just push current
  # blt		$t0, $t1, do_stack_push_op	
  
  #pop and apply and save new tps
  move 	$a0, $s0		# $a0 = $s0
  move 	$a1, $s1		# $a1 = $s1
  move 	$a2, $s2		# $a2 = $s2
  move 	$a3, $s3		# $a3 = s31
  jal		pop_and_apply				# jump to pop_and_apply and save position to $ra
  move 	$s1, $v0		# $s1 = $v0
  move 	$s3, $v1		# $s3 = $v1

  j eval_cParen

paren_eval_done:
  #pop the top of the op stack
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  move 	$a1, $s2		# $a1 = $s2
  jal		stack_pop				# jump to stack_peek and save position to $ra
  move $s3, $v0 

  #increment the string by 1 and load byte
  addi	$s4, $s4, 1			# $s4 = $s4 + 1
  lb	$s5, 0($s4)	# 
  

  move 	$a0, $s5		# $a0 = $s5
  jal		valid_ops				# jump to valid_ops and save position to $ra
  bne		$v0, $0, read_and_simplify	# if $v0 == $0 then read_and_simplify
  li		$t0, ')'		# $t0 = ')'
  beq		$v0, $t0, read_and_simplify	# if $v0 == $t0 then read_and_simplify
  beq		$v0, $0, read_and_simplify	# if $v0 == $0 then read_and_simplo
  j parse_error


do_stack_push_num:
  #loading inputs to push
  move 	$a0, $s6		# $a0 = $s6
  move 	$a1, $s1		# $a1 = $s1
  move 	$a2, $s0		# $a2 = $s0

  #call the function
  jal		stack_push				# jump to stack_push and save position to $ra
  
  move 	$s1, $v0		# $s1 = $v0

  #increment the string by 1 and load byte
  addi	$s4, $s4, 1			# $s4 = $s4 + 1
  lb	$s5, 0($s4)	# 

  j read_and_simplify


do_stack_push_op:
  #loading inputs to push
  move 	$a0, $s5		# $a0 = $s5
  move 	$a1, $s3		# $a1 = $s1
  move 	$a2, $s2		# $a2 = $s0

  #call the function
  jal		stack_push				# jump to stack_push and save position to $ra

  move 	$s3, $v0		# $s3 = $v0
  
  #increment the string by 1 and load byte
  addi	$s4, $s4, 1			# $s4 = $s4 + 1
  lb	$s5, 0($s4)	# 

  j read_and_simplify


op_stack_empty:
  #check if op stack is empty
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra

  #if empty then end_eval
  bne		$v0, $0, end_eval	# if $v0 != $0 t1 end_eval

  #pop and apply and save new tps
  move 	$a0, $s0		# $a0 = $s0
  move 	$a1, $s1		# $a1 = $s1
  move 	$a2, $s2		# $a2 = $s2
  move 	$a3, $s3		# $a3 = s31
  jal		pop_and_apply				# jump to pop_and_apply and save position to $ra
  move 	$s1, $v0		# $s1 = $v0
  move 	$s3, $v1		# $s3 = $v1

  j op_stack_empty
  

end_eval: 
  #if num stack empty then return error
  addi	$a0, $s1, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  bne		$v0, $0, parse_error	# if $v0 != $0 then do_stack_push_op

  #pop from num stack
  addi	$a0, $s1, -4			# $a0 = $s3 + -4
  move 	$a1, $s0		# $a1 = $s0
  jal		stack_pop
  move 	$s1, $v0		# $s1 = $v0
  move 	$s6, $v1		# $s6 = $v1

  #if num stack is not empty, then return error
  addi	$a0, $s1, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  beq		$v0, $0, parse_error	# if $v0 != $0 then do_stack_push_op


  #prepare the output
  move 	$v0, $s6		# $v0 = s61

  #restore the stack
  lw		$s0, 0($sp)		# 
  lw		$s1, 4($sp)		# 
  lw		$s2, 8($sp)		# 
  lw		$s3, 12($sp)		# 
  lw		$s4, 16($sp)		#
  lw		$s5, 20($sp)		#
  lw		$s6, 24($sp)		#
  lw		$s7, 28($sp)		# 
  lw		$ra, 32($sp)		#
  jr		$ra					# jump to $ra


parse_error:
  la		$a0, ParseError		# 
  li		$v0, 4		# $v0 = 4
  syscall
  j exit

invalid_char:
  la		$a0, BadToken		# 
  li		$v0, 4		# $v0 = 4
  syscall
  j exit


pop_and_apply:
  addi	$sp, $sp, -20			# $sp = $sp + 4
  sw		$ra, 0($sp)		# 
  sw		$s0, 4($sp)		# 
  sw		$s1, 8($sp)		# 
  sw		$s2, 12($sp)		# 
  sw		$s3, 16($sp)		# 
  
  move 	$s0, $a0		# $s0 = $a0
  move 	$s1, $a1		# $s0 = $a0
  move 	$s2, $a2		# $s0 = $a0
  move 	$s3, $a3		# $s0 = $a0

  #pop the op stack
  addi	$a0, $s3, -4			# $a0 = $s3 + -4
  move 	$a1, $s2		      # $a1 = $s2
  jal		stack_pop				# jump to stack_pop and save position to $ra
  move 	$s3, $v0		# $s3 = $v0
  move 	$t4, $v1		# $t4 = $v1

  #if num stack empty then return error
  addi	$a0, $s1, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  bne		$v0, $0, parse_error	# if $v0 != $0 then do_stack_push_op

  #pop the num stack
  addi	$a0, $s1, -4			# $a0 = $s1 + -4
  move 	$a1, $s0		      # $a1 = $s2
  jal		stack_pop				# jump to stack_pop and save position to $ra
  move 	$s1, $v0		# $s3 = $v0
  move 	$t5, $v1		# $s6 = $v1

  #if num stack empty then return error
  addi	$a0, $s1, -4			# $a0 = $s3 + -4
  jal		is_stack_empty				# jump to is_stack_empty and save position to $ra
  bne		$v0, $0, parse_error	# if $v0 != $0 then do_stack_push_op

  #pop the num stack
  addi	$a0, $s1, -4			# $a0 = $s1 + -4
  move 	$a1, $s0		      # $a1 = $s2
  jal		stack_pop				# jump to stack_pop and save position to $ra
  move 	$s1, $v0		# $s3 = $v0
  move 	$t6, $v1		# $s6 = $v1
 
  #apply operation
  move 	$a0, $t6		# $a2 = $v1
  move 	$a1, $t4		# $a0 = $s7
  move 	$a2, $t5		# $a1 = $s6
  jal apply_bop

  #push on the num stack
  move 	$a0, $v0		# $s6 = $v0
  move 	$a1, $s1		# $a1 = $s1
  move 	$a2, $s0		# $a2 = $s0
  jal		stack_push				# jump to stack_push and save position to $ra
  move 	$s1, $v0		# $s1 = $v0

  #return tp for the function
  move 	$v0, $s1		# $v0 = $s1
  move 	$v1, $s3		# $v1 = $s3

  lw		$ra, 0($sp)		# 
  lw		$s0, 4($sp)		# 
  lw		$s1, 8($sp)		# 
  lw		$s2, 12($sp)		# 
  lw		$s3, 16($sp)		# 
  addi	$sp, $sp, 20			# $sp = $sp + 4
  jr		$ra					# jump to $ra
   

get_number:
	addi	$sp, $sp, -20	# $sp = $sp - 4
	sw		$ra, 0($sp)		# 
	sw		$s0, 4($sp)		# 
	sw		$s1, 8($sp)		# 
	sw		$s2, 12($sp)		# 
	sw		$s3, 16($sp)		# 
	
  move 	$s3, $a0		# $s3 = $a0
	lb	$s0, 0($s3)
  addi	$s0, $s0, -48			# $s0 = $s0 + -48
	li	$s1, 0
	li	$s2, 10
	
get_number_helper:
	#if digit then add it to the existing number in $s1
	mult $s1, $s2
	mflo $s1
	add  $s1, $s0, $s1
	
	#increment by 1
	addi $s3, $s3, 1
	lb	$s0, 0($s3)
	
	#check if digit and load back in the registers
	move $a0, $s0
	jal is_digit
	
	beq $v0, $0, num_break
  addi	$s0, $s0, -48			# $s0 = $s0 + -48
	j get_number_helper

num_break:
  addi	$s3, $s3, -1			# $s3 = $s3 + -1
  
	move $v0, $s1
	move $v1, $s3

	lw		$ra, 0($sp)		# 
	lw		$s0, 4($sp)		# 
	lw		$s1, 8($sp)		# 
	lw		$s2, 12($sp)		# 
	lw		$s3, 16($sp)		# 
	addi	$sp, $sp, 20		# $sp = $sp + 4
	jr		$ra				# jump to $ra
	
	

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
  la		$a0, ApplyOpError		# $a0 = ApplyOpError
  li		$v0, 4		# $v0 = 4
  syscall
  j exit

is_stack_empty:
  li		$t9, -4		# $t0 = -4
  bne		$a0, $t9, empty_stack_false	# if $a0 != $t0 then empty_pop_err
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
