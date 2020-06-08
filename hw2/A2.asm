#####################################################################
#                                                                   #
# Name:                                                             #
# KUSIS ID:                                                         #
#####################################################################

# This file serves as a template for creating 
# your MIPS assembly code for assignment 2

.eqv MAX_LEN_BYTES 400
.eqv SYS_PRINT_STRING 4
.eqv SYS_PRINT_INT 1
#====================================================================
# Variable definitions
#====================================================================

.data

arg_err_msg:       .asciiz   "Argument error"
input_msg:         .asciiz   "Input integers:\n"
input_data:        .space    MAX_LEN_BYTES     #Define length of input list
#  You can define other data as per your need. 
input_prompt_size: .asciiz "Enter size of the list: "
input_unsorted: .asciiz "Unsorted list:\n"
input_sorted: .asciiz "\nSorted list:\n"
input_removed: .asciiz  "\nRemoved Duplicates:\n"
newSpace: .asciiz " "
input_data_removed: .space MAX_LEN_BYTES
input_reduction: .asciiz "\nReduction:\n"
#==================================================================== 
# Program start
#====================================================================

.text
.globl main

main:
   # Main program entry
   #prompt the user to enter size of the list
	li $v0, SYS_PRINT_STRING
	la $a0, input_prompt_size
   	syscall
  
   #get size of the list
   	li $v0, 5
	syscall 
   #Check for first argument to be n
   #invalid input error if n=0
   	beqz $v0, Arg_Err
    
   #invalid input error if n<0
    	slt $t0, $v0, $zero 
    	bnez $t1, Arg_Err
    	
   #store result of size of the list
	add $s0, $v0, $zero

   #for(int i=0; i < n; n++)
   	addi $t0 $zero 0  #i = 0 + 0
	add $t1 $zero $s0 #temp = 0 + size of the list
	
	addi $t3, $zero, 0 #temp3 = 0 
	
	li $v0, SYS_PRINT_STRING 
	la $a0, input_msg
   	syscall
   	
Data_Input:
   # Get integers from user as per value of n
   	
   	slt $t2 $t0 $t1 #if(i<temp)
	beq $t2 $zero Stop_Input #exit if t2==0
   	
   	li $v0, 5	#user input integer
	syscall 
   	
   	#invalid input
    	slt $t9, $v0, $zero #if smaller than 0, not an integer error
    	bnez $t9, Arg_Err
    	slti $t9, $v0, 10 #if bigger than 9, not an integer
    	beqz  $t9, Arg_Err	
   	
   	sw $v0, input_data($t3) #store the value in input_data
   	addi $t3, $t3, 4
   	
   	addi $t0 $t0 1 #i = i + 1
   	j Data_Input #jump to Data_Input, loop continues
   
Stop_Input:
#prints the whole list to see
	li $v0, SYS_PRINT_STRING 
	la $a0, input_unsorted
   	syscall
   	
   	addi $t3 $zero 0  #temp3 = 0 + 0
   	
   	addi $t0 $zero 0  #i = 0 + 0
	add $t1 $zero $s0 #temp = 0 + size of the list
   	
Print_Loop:   	slt $t2 $t0 $t1 #if(i<temp)
		beq $t2 $zero sort_data #exit if t2==0
   	
   		lw $t6, input_data($t3) #loads from the array
   		addi $t3, $t3, 4
   		
   		li $v0, SYS_PRINT_INT #prints the integers
		move $a0, $t6
		syscall
		
		li $v0, SYS_PRINT_STRING #prints the space
		la $a0, newSpace
		syscall
   	
   		addi $t0 $t0 1 #i = i + 1
   		j Print_Loop #jump to Data_Input, loop continues
   	
# Insertion sort begins here
sort_data:
	addi $t0 $zero 1  #i = 0 + 1
	add $t1 $zero $s0 #temp = 0 + size of the list
	
sort_loop:	slt $t2 $t0 $t1 #if(i<temp)
		beq $t2 $zero remove_duplicates #exit if t2==0
	
		add $t4 $zero $t0 #temp4 = i

while:		slt $t5 $zero $t4 # if 0 < j, set t5 = 1 else t5 = 0
		beqz $t5, exit_while

		sll $t9, $t4, 2
		lw $t6, input_data($t9) #input_data[temp4]
		addi $t3, $t9, -4
		lw $t7, input_data($t3) #input_data[temp4-1]
		slt $t8, $t6, $t7 # if t6 < t7 set t8 = 1 else t8 = 0
		beqz $t8, exit_while
		
		sw $t6, input_data($t3)
		sw $t7, input_data($t9) 
		addi $t4, $t4, -1
		j while
		
exit_while:	addi $t0, $t0, 1 #i = i + 1
   		j sort_loop #jump to sort_data, loop continues

remove_duplicates:
		addi $t0, $zero, 0 #i = 0 
		addi $t1, $s0, -1 #temp = size of the list - 1
		
		addi $s2, $zero, 0 #length of the new array initialized
		
remove_loop:	slt $t2 $t0 $t1 #if(i<temp)
		beqz $t2, exit_remove_loop #exit if t2==0
    
 		sll $t9, $t0, 2 
		lw $t6, input_data($t9) #input_data[temp4]
		addi $t3, $t9, 4
		lw $t7, input_data($t3) #input_data[temp4+1]
		beq $t7, $t6, not_into_array #if [temp4] == [tamp4+1], skip storing into new array
		sll $t5, $s2, 2 
		sw $t6, input_data_removed($t5)#insert into the new array 
		addi $s2, $s2, 1
not_into_array:
   		addi $t0, $t0, 1 #i = i + 1
   		j remove_loop #jump to Data_Input, loop continues
exit_remove_loop:
		sll $t9, $t0, 2 
		sll $t4, $s2, 2 
   		lw $t6, input_data($t9) #the last element is loaded
   		sw $t6, input_data_removed($t4)   #the last element is inserted
   		addi $s2, $s2, 1

# Print sorted list with and without duplicates

print_w_dup: #prints the whole list to see
	li $v0, SYS_PRINT_STRING 
	la $a0, input_sorted
   	syscall
   	
   	addi $t3 $zero 0  #temp3 = 0 + 0
   	
   	addi $t0 $zero 0  #i = 0 + 0
	add $t1 $zero $s0 #temp = 0 + size of the list
   	
Print_Loop_dupl:   	
		slt $t2 $t0 $t1 #if(i<temp)
		beq $t2 $zero print_wo_dup #exit if t2==0
   	
   		lw $t6, input_data($t3) #loads from the array
   		addi $t3, $t3, 4
   		
   		li $v0, SYS_PRINT_INT #prints the integers
		move $a0, $t6
		syscall
		
		li $v0, SYS_PRINT_STRING #prints the space
		la $a0, newSpace
		syscall
   	
   		addi $t0 $t0 1 #i = i + 1
   		j Print_Loop_dupl #jump to Data_Input, loop continues

print_wo_dup:
	li $v0, SYS_PRINT_STRING 
	la $a0, input_removed
   	syscall
   	
   	addi $t3 $zero 0  #temp3 = 0 + 0
   	
   	addi $t0 $zero 0  #i = 0 + 0
	add $t1 $zero $s2 #temp = 0 + size of the removed list
	
Print_Loop_nodupl:   	
		slt $t2 $t0 $t1 #if(i<temp)
		beq $t2 $zero Reduction #exit if t2==0
   	
   		lw $t6, input_data_removed($t3) #loads from the array
   		addi $t3, $t3, 4
   		
   		li $v0, SYS_PRINT_INT #prints the integers
		move $a0, $t6
		syscall
		
		li $v0, SYS_PRINT_STRING #prints the space
		la $a0, newSpace
		syscall
   	
   		addi $t0 $t0 1 #i = i + 1
   		j Print_Loop_nodupl #jump to Data_Input, loop continues


# Perform reduction
Reduction:
	addi $t3 $zero 0  #temp3 = 0 + 0
	addi $t9 $zero 0
   	
   	addi $t0 $zero 0  #i = 0 + 0
	add $t1 $zero $s2 #temp = 0 + size of the ordered list
   
reduction_loop:
  	slt $t2 $t0 $t1 #if(i<temp)
	beq $t2 $zero Stop_Reduction #exit if t2==0
	
	lw $t6, input_data_removed($t9) #loads from the array
   	addi $t9, $t9, 4
   	add $t3, $t3, $t6 #add each element to t3
	
	addi $t0 $t0 1 #i = i + 1
   	j reduction_loop #jump to Data_Input, loop continues

Stop_Reduction:
	li $v0, SYS_PRINT_STRING
	la $a0, input_reduction
   	syscall
   	
# Print sum
  li  $v0, 1
  addi $a0, $t3, 0      # $t3 contains the sum  
  syscall
  j Exit 
   
Arg_Err:
   # Error message when no input arguments specified
   # or when argument format is not valid
   la $a0, arg_err_msg
   li $v0, 4
   syscall
   j Exit

Exit:  
   # Jump to this label at the end of the program
   li $v0, 10
   syscall
