############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  #saving caller $s registers on the stack
  addi	$sp, $sp, -20			# $sp = $sp + -16 
  sw		$s0, 16($sp)		# 
  sw		$s1, 12($sp)		# 
  sw		$s2, 8($sp)		# 
  sw		$s3, 4($sp)		# 
  sw		$s4, 0($sp)		#
  
  #initializing the stacks
  la		$s0, val_stack		#
  li		$s1, 0		# $t1 = 0 
  la		$s2, op_stack		# 
  addi	$s2, $s2, 2000			# $s2 = $ts2+ 2000
  li		$s3, 0		# $t3 = 0

  move 	$s4, $a0		# $s4 = $a0 string address
  lb		$t0, 0($s4)	# 

  #check for parens
  li		$t2, '('		# $t3 = '('
  li		$t3, ')'		# $t4 = ')'

  j read_and_simplify

read_and_simplify:


is_num:
  
  #make space on the stack and save
  move $fp, $sp
  addi	$sp, $sp, -20			# $sp = $sp + -16
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)
  sw $t3, 12($sp)
  sw $ra, 16($sp)
  
  move 	$t0, $a0		# $t0 = $a0
  jal		is_digit				# jump to is_digit and save position to $ra
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  lw $t3, 12($sp)
  

finish_computation:


  
  # #if not parens then assume digit and branch
  # j parse_string_digit

# parse_string_digit:
#   beq		$t1, $0, parse_complete	# if $t1 == $0 then parse_complete

  
#   #saving current $t registers before calling another function
#   move 	$fp, $sp		# $fp = $sp
#   addi	$sp, $sp, -8			# $sp = $sp + -8
#   sw		$t0, 4($sp)		# 
#   sw		$t1, 0($sp)		# 
  
#   #call the is_digit function and restore registers
#   move 	$a0, $t1		# $a0 = $t1
#   jal		is_digit				# jump to is_digit and save position to $ra
#   lw		$t0, 4($sp)		#
#   lw		$t1, 0($sp)		# 

# parse_string_op:


# parse_string_oParens:
#   #increment paren counter by 1
#   addi	$t1, $t1, 1			# $t2 = $t2 + 1

#   #load next byte and check for null char
#   addi	$s4, $s4, 1			# $s4 = $s4 + 1
#   lb		$t0, 0($s4)		#
#   beq		$t0, $0, parse_error	# if $t0 == $0 then ParseError
  
#   #check for another open paren 
#   beq		$t0, $t2, parse_string_oParens	# if $t0 == $t2 then parse_string_oParens
  
#   #close paren immediately after open paren
#   beq		$t0, $t3, parse_error	# if $t0 == $t3 then parse_error
  
#   j parse_string_digit
  

# parse_string_cParens:
#   #decrement paren counter by 1
#   addi	$t1, $t1, -1			# $t1 = $t1 + -1

#   #check if paren counter is negative
#   bltz  $t1, parse_error
  
#   #load next byte and check for null char
#   addi	$s4, $s4, 1			# $s4 = $s4 + 1
#   lb		$t0, 0($s4)		#
#   beq		$t0, $0, parse_complete	# if $t0 == $0 then ParseError

#   #check for another close paren
#   beq		$t0, $t3, parse_string_cParens	# if $t0 == $t3 then parse_string_cParens
  
#   #open paren immediately after close paren
#   beq		$t0, $t2, parse_error	# if $t0 == $t2 then parse_error

#   j parse_string_op
  

# parse_complete:


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


# #Checks and returns a number in a string
# is_num:
#   add		$t0, $a0, $a1		# $t0 = $a0 + $a1
#   li		$t1, 0		# $t1 = 0
#   j is_num_recursion

# is_num_recursion:
#   lb		$t2, 0($t0)		#
#   addi	$sp, $sp, -16			# $sp = $t1 + 0
#   sw		$ra, 12($sp)		# 
#   sw		$t0, 8($sp)		# 
#   sw		$t1, 4($sp)		# 
#   sw		$t2, 0($sp)		# 
#   jal		is_digit				# jump to is_digit and save position to $ra
#   lw		$ra, 12($sp)		# 
#   lw		$t0, 8($sp)		# 
#   lw		$t1, 4($sp)		# 
#   lw		$t2, 0($sp)
#   addi	$sp, $sp, 16			# $sp = $t1 + 0
#   beq		$v0, $0, return_number	# if $v0 == $0 then return_number
#   li		$t3, 10		# $t3 = 10
#   mult	$t1, $t3			# $t1 * $t3 = Hi and Lo registers
#   mflo	$t1					# copy Lo to $t1
#   add		$t1, $t1, $t2		# $t1 = $t1 + $t2
#   addi	$t0, $t0, 1			# $t0 = $t0 + 1
#   j is_num_recursion

# return_number:
#   sub		$v0, $t0, $a0		# $v0 = $t0 - $a0
#   beq		$v0, $a0, not_a_num	# if $v0 == $a0 then not_a_num
#   move 	$v1, $t1		# $v1 = $t1
#   jr		$ra					# jump to $ra
  

# not_a_num:
#   li		$v1, -1		# $v0 = -1
#   jr $ra

  

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
