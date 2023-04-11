#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Faizan Naseer, 1008124405, naseerf1, f.naseer@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. A - Score Bar
# 2. B - Fail Condition
# 3. D - Moving Objects
# 4. C - Win Condition
# 5. E - Moving Platforms
# 6. K - Double Jump
#
# Link to video demonstration for final submission:
# - https://youtu.be/X-bKcF4vhAg
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, *https://github.com/faizannaseerr/ProjectB58*
#
# Any additional information that the TA needs to know:
# - Score is shown as 1 M (minute) survived in the win screen.
# - To do your second jump, your first jump should be on a platform.
# - The platforms are there to aid survival.
#
#####################################################################

.eqv 	base_address 0x10008000
.eqv	floor_colour 0x008000

#stones as obstacles, level bar at the top
.data

disapp_timer: .word 0
score: .word 0

.text
.globl main

main: 		jal clear_board
		
		li $t1, 0x003820
		li $v0, 32
		li $a0, 1000
		syscall
		
		#global var.
		li $t0, base_address
		addi $s0, $t0, 14112 #7056 #6920  #6952 #bottom-left of character - static
		#maybe add speed of rock, speed of platform
		addi $a1, $t0, 14304 #7152 #starting pos of rock
		addi $a2, $t0, 12032 #4088 #3576 # starting postition of level/floor, when resetting add random delay
		li $a3, 0 #first jump flag
		
		jal create_char
		jal create_floor
		jal create_rock
		jal create_disapp
		jal create_level
		jal create_level_bar
		
main_loop:	jal rock_loop
		jal disapp_loop
		jal level_loop
		jal update_score
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		beq $t8, 1, keypress  
		
		jal platform_check #gravity
		jal contact_check #fail-condition	
		

main_sleep:	#sw $t1, 504($t0)
		li $v0, 32
		li $a0, 20 #frame rate
		syscall
	
		j main_loop
			
end:		li $v0, 10 # use this when level bar finishes and game is won!
		syscall

update_score: 	li $t0, base_address
		la $t4, score
		lw $t5, 0($t4)
		beq $t5, 771, game_won #771
		addi $t5, $t5, 1
		sw $t5, 0($t4)
		li $t6, 0xffffff
		addi $t7, $t0, 684
		beq $t5, 77, score1
		beq $t5, 154, score2
		beq $t5, 231, score3
		beq $t5, 308, score4
		beq $t5, 385, score5
		beq $t5, 462, score6
		beq $t5, 539, score7
		beq $t5, 616, score8
		beq $t5, 693, score9
		beq $t5, 770, score10
		
		
score1:		sw $t6, 0($t7)
		j end_update_score
		
score2:		sw $t6, 4($t7)
		j end_update_score
		
score3:		sw $t6, 8($t7)
		j end_update_score
		
score4:		sw $t6, 12($t7)
		j end_update_score
		
score5:		sw $t6, 16($t7)
		j end_update_score
		
score6:		sw $t6, 20($t7)
		j end_update_score
		
score7:		sw $t6, 24($t7)
		j end_update_score

score8:		sw $t6, 28($t7)
		j end_update_score
		
score9:		sw $t6, 32($t7)
		j end_update_score
		
score10:	sw $t6, 36($t7)
		j end_update_score

end_update_score:
		jr $ra
		
game_won:	jal clear_board
		
		li $t0, base_address
		li $t2,  0x078412 #0x81180B #0x34382f 
		#addi $t4, $s0, 0
		#addi $t3, $t3, -6896 #-6640 #-6128 #16
		addi $t4, $t0, 7216
		
		#G
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 252($t4)
		sw $t2, 508($t4)
		sw $t2, 764($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 520($t4)
		sw $t2, 516($t4)
		sw $t2, 776($t4)
		
		addi $t4, $t4, 16
		#A
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		sw $t2, 268($t4)
		sw $t2, 524($t4)
		sw $t2, 780($t4)
		sw $t2, 1036($t4)
		
		addi $t4, $t4, 20
		#M
		addi $t4, $t4, -256
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		sw $t2, 516($t4)
		sw $t2, 524($t4)
		sw $t2, 776($t4)
		addi $t4, $t4, 16
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		
		addi $t4, $t4, 264
		#E
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 1036($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
	
		addi $t4, $t4, 28
		#O
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 268($t4)
		sw $t2, 512($t4)
		sw $t2, 524($t4)
		sw $t2, 768($t4)
		sw $t2, 780($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		
		addi $t4, $t4, 20
		#V
		sw $t2, 0($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 16($t4)
		sw $t2, 272($t4)
		sw $t2, 528($t4)
		sw $t2, 772($t4)
		sw $t2, 780($t4)
		sw $t2, 1032($t4)
		
		addi $t4, $t4, 24
		#E
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 1036($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		
		addi $t4, $t4, 20
		#R
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 268($t4)
		sw $t2, 512($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		sw $t2, 524($t4)
		sw $t2, 768($t4)
		sw $t2, 776($t4)
		sw $t2, 1024($t4)
		sw $t2, 1036($t4)
		
		addi $t4, $t4, 2216
		
		#1
		sw $t2, 256($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 264($t4)
		sw $t2, 520($t4)
		sw $t2, 776($t4)
		sw $t2, 1032($t4)
		
		addi $t4, $t4, 20
		#M
		addi $t4, $t4, -256
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		sw $t2, 516($t4)
		sw $t2, 524($t4)
		sw $t2, 776($t4)
		addi $t4, $t4, 16
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		
		addi $t4, $t4, -5148
		#:)
		sw $t2, 0($t4)
		sw $t2, 256($t4)
		#sw $t2, 512($t4)
		sw $t2, 8($t4)
		sw $t2, 264($t4)
		#sw $t2, 520($t4)
		addi $t4, $t4, 1024
		sw $t2, -524($t4)
		sw $t2, -264($t4)
		sw $t2, -4($t4)
		sw $t2, 256($t4)
		sw $t2, 260($t4)
		sw $t2, 264($t4)
		sw $t2, 12($t4)
		sw $t2, -240($t4)
		sw $t2, -492($t4)
		
		
		
		
		j end
		
create_level_bar:
		li $t0, base_address
		addi $t1, $t0, 424
		li $t2, 0x339291
		sw $t2, 0($t1)
		sw $t2, 4($t1)
		sw $t2, 8($t1)
		sw $t2, 12($t1)
		sw $t2, 16($t1)
		sw $t2, 20($t1)
		sw $t2, 24($t1)
		sw $t2, 28($t1)
		sw $t2, 32($t1)
		sw $t2, 36($t1)
		sw $t2, 40($t1)
		sw $t2, 44($t1)
		sw $t2, 256($t1)
		sw $t2, 300($t1)
		addi $t1, $t1, 512
		sw $t2, 0($t1)
		sw $t2, 4($t1)
		sw $t2, 8($t1)
		sw $t2, 12($t1)
		sw $t2, 16($t1)
		sw $t2, 20($t1)
		sw $t2, 24($t1)
		sw $t2, 28($t1)
		sw $t2, 32($t1)
		sw $t2, 36($t1)
		sw $t2, 40($t1)
		sw $t2, 44($t1)
		jr $ra

create_char:	li $t0, base_address # $t0 stores the base address for display
		li $t2, 0x66555f # body
		li $t3, 0xffffff # eyes
		li $t5, 0x000000
		add $t4, $s0, $zero #starting address
		sw $t2, 0($t4)
		sw $t2, 12($t4)
		add $t4, $t4, -256
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		add $t4, $t4, -256
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		add $t4, $t4, -256
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		#sw $t3, 16($t4)
		add $t4, $t4, -256
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t3, 8($t4)
		sw $t3, 12($t4)
		#sw $t3, 16($t4)
		add $t4, $t4, -256
		
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		
		
		jr $ra
		
		
create_floor:	li $t0, base_address
		li $t1, 0x7e91a0 #floor
		addi $t2, $t0, 14336 #7168  #i -- floor_address
		addi $t3, $t0, 16384 #8192
floor_loop:	sw $t1, 0($t2)
		addi $t2, $t2, 4
		ble  $t2, $t3, floor_loop
		jr $ra
		
create_rock:	li $t0, base_address
		li $t1, 0x716A68 #rock
		add $t2, $a1, $zero  #i -- rock
		sw $t1, 0($t2)
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		addi $t2, $t2, -256
		sw $t1, 4($t2)
		jr $ra

rock_loop:	li $t3, 0
		addi $a1, $a1, -4
		addi $t1, $t0, 14076 #13816 #6908
		bne $a1, $t1, shift_rock

reset_rock:	li $t3, 1
		li $t2, 0x000000
		sw $t2, 4($a1)
		sw $t2, 8($a1)
		sw $t2, 12($a1)
		sw $t2, -248($a1)
		addi $a1, $t0, 14324 #14312 #7156


shift_rock:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_rock
		addi $t1, $a1, 4
		beq $t3, 1, rock_end
		li $t2, 0x000000
		sw $t2, 8($t1)
		addi $t1, $t1, -256
		sw $t2, 4($t1)
		
		#go back/subtract first, then draw, not the opposite + remove top of old and right of old

rock_end:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
create_level:	li $t0, base_address
		li $t1, 0x7e91a0
		add $t2, $a2, $zero #5376 #address for level
		sw $t1, 0($t2)
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		sw $t1, 20($t2)
		sw $t1, 24($t2)
		jr $ra

level_loop:	li $t3, 0
		addi $a2, $a2, 4
		addi $t1, $t0, 12524 #13816 #6908
		bne $a2, $t1, shift_level
		
reset_level:	li $t3, 1
		li $t2, 0x000000
		sw $t2, -4($a2)
		sw $t2, 0($a2)
		sw $t2, 4($a2)
		sw $t2, 8($a2)
		sw $t2, 12($a2)
		sw $t2, 16($a2)
		sw $t2, 20($a2)
		#sw $t2, 24($a2)
		addi $a2, $t0, 12288 #14312 #7156
		
shift_level:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_level
		addi $t1, $a2, -4
		beq $t3, 1, level_end
		li $t2, 0x000000
		sw $t2, 0($t1)
		
level_end:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
create_disapp:	li $t1, 0x7e91a0
		addi $t2, $t0, 9984 #12288 #5376 #address for level
		sw $t1, 0($t2)
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		sw $t1, 20($t2)
		sw $t1, 24($t2)
		jr $ra
		
disapp_loop:	la $t3, disapp_timer
		lw $t4, 0($t3)
		addi $t4, $t4, 1
		sw $t4, 0($t3)
		bgt $t4, 260, clear_disapp
		bgt $4, 520, recreate
		j end_disapp_loop
		

recreate:	li $t1, 0x7e91a0
		addi $t2, $t0, 9984 #5376 #address for level
		sw $t1, 0($t2)
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		sw $t1, 20($t2)
		sw $t1, 24($t2)
		
end_disapp_loop:		
		jr $ra

clear_disapp:	li $t1, 0x000000
		addi $t2, $t0, 9984 #5376 #address for level
		sw $t1, 0($t2)
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		sw $t1, 20($t2)
		sw $t1, 24($t2)
		j end_disapp_loop
		
		
		
keypress:	lw $s7, 4($t9)
		beq $s7, 0x61, a_pressed
		beq $s7, 0x64, d_pressed
		beq $s7, 0x77, w_pressed
		beq $s7, 0x70, p_pressed
		
a_pressed:	addi $s1, $s0, -4
		#check for wall, if not then shift
		sub $s2, $zero, $t0 #-base
		add $s3, $s1, $s2 #starting pos. - base, later store remainder
		addi $s4, $zero, 256
		div $s3, $s4
		mfhi $s3
		beq $s3, 0, end_keypress
		li $s5, 0x7e91a0
		lw $s6, 0($s1)
		beq $s6, $s5, end_keypress
		lw $s6, -256($s1)
		beq $s6, $s5, end_keypress
		lw $s6, -512($s1)
		beq $s6, $s5, end_keypress
		lw $s6, -768($s1)
		beq $s6, $s5, end_keypress
		lw $s6, -1024($s1)
		beq $s6, $s5, end_keypress
		
		addi $s0, $s0, -4
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_char
		li $s1, 0x000000 #0x004728
		
		addi $s2, $s0, 16
		sw $s1, -12($s2)
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -4
		sw $s1, -256($s2)
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j end_keypress
		
		
d_pressed:	addi $s1, $s0, 16
		#check for wall, if not then shift
		sub $s2, $zero, $t0 #-base
		add $s3, $s1, $s2 #starting pos. - base, later store remainder
		addi $s4, $zero, 256
		div $s3, $s4
		mfhi $s3
		beq $s3, 0, end_keypress
		#li $s5, 0x7e91a0
		#lw $s6, 0($s1)
		
		
		addi $s0, $s0, 4
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_char
		li $s1, 0x000000 #0x004728
		
		sw $s1, -1280($s0)
		sw $s1, 8($s0)
		addi $s2, $s0, -4
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j end_keypress
		
w_pressed:	##addi $s1, $s0, -2304 #(-1280 + blah blah(1024))
		#check for wall, if not then shift -- maybe need to also check for level above head, cant jump through!
		##sub $s2, $zero, $t0 #-base
		##add $s3, $s1, $s2 #starting pos. - base, later store remainder
		##bltz $s3, end_keypress
		#addi $s4, $zero, 256
		#div $s3, $s4
		#mfhi $s3
		# I dont think you need thing above
		
		#checking for floor here under character - fix checking(if its equal to black you cant jump
		#add $s1, $s0, $zero
		#use flag here?

		beq $a3, 0, in_air_check
		
my_second_jump:	li $a3, 0
		j jump
		
in_air_check:	li $s3, 0x000000
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 0($s1)
		beq $s2, $s3, end_keypress
		li $a3, 1
		bne $s2, $s3, jump
		#add $s1, $s0, $zero
		#lw $s3, 4($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 4($s1)
		beq $s2, $s3, end_keypress
		li $a3, 1
		bne $s2, $s3, jump
		#add $s1, $s0, $zero
		#lw $s3, 8($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 8($s1)
		beq $s2, $s3, end_keypress
		li $a3, 1
		bne $s2, $s3, jump
		#add $s1, $s0, $zero
		#lw $s3, 12($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 12($s1)
		beq $s2, $s3, end_keypress
		li $a3, 1
		
		
jump:		#loop here - to calculate till where you need to jump (max 4096)
		add $t1, $s0, $zero
		add $t1, $t1, -1280
		add $t4, $t0, 256
		li $t2, 0 #jump amount
		li $t5, 0x7e91a0 #floor colour 
jump_loop:	lw $t3, -256($t1)
		blt $t1, $t4, perform_jump
		beq $t3, $t5, perform_jump
		lw $t3, -252($t1)
		beq $t3, $t5, perform_jump
		lw $t3, -248($t1)
		beq $t3, $t5, perform_jump
		lw $t3, -244($t1)
		beq $t3, $t5, perform_jump
		beq $t2, -4096, perform_jump
		addi $t1, $t1, -256
		addi $t2, $t2, -256
		j jump_loop
		
		
		
perform_jump:	add $s4, $t2, $zero #new added
		add $s0, $s0, $s4
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_char
		li $s1, 0x000000 #0x028841 #0x004728
		
		
		sub $s2, $s0, $s4  #probs gonna have to turn this into a loop
		li $s6, -256
		div $s4, $s6
		mflo $s4 
		addi $s4, $s4, -1
		
		sw $s1, 0($s2)
		sw $s1, 12($s2)
		
		li $s5, 0 #i for loop
jump_clean:	beq $s5, $s4, final_clean
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s5, $s5, 1
		j jump_clean	
		
		#can probs remove this------
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 0($s2)
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		sw $s1, 12($s2)
		#-----------------
		
final_clean:	addi $s2, $s2, -256
		sw $s1, 4($s2)
		sw $s1, 8($s2)		 
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j end_keypress
		

p_pressed:	la $ra, main
		j end_keypress   #use this to restart game if crash into stone/object


end_keypress: 	jr $ra


clear_board:	li $t0, base_address
		li $t1, 0x000000
		addi $t2, $t0, 16384 #8192
clearing_loop:	sw $t1, 0($t0)
		addi $t0, $t0, 4
		beq $t0, $t2, cleared
		j clearing_loop
		
cleared: 	jr $ra

platform_check:	#basically implement s function
		
		#first will have platform check, if true do nothing, if false s repetitively
		li $s3, 0x000000
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 0($s1)
		bne $s2, $s3, end_platcheck
		#add $s1, $s0, $zero
		#lw $s3, 4($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 4($s1)
		bne $s2, $s3, end_platcheck
		#add $s1, $s0, $zero
		#lw $s3, 8($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 8($s1)
		bne $s2, $s3, end_platcheck
		#add $s1, $s0, $zero
		#lw $s3, 12($s1)
		addi $s1, $s0, 256 #check if floor not underneath
		lw $s2, 12($s1)
		bne $s2, $s3, end_platcheck
		
		addi $s0, $s0, 256
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal create_char
		li $s1, 0x000000 #0x004728 
		
		addi $s2, $s0, -1280
		sw $s1, 0($s2)
		sw $s1, 12($s2)
		addi $s2, $s2, -256
		sw $s1, 4($s2)
		sw $s1, 8($s2)
		addi $s2, $s2, 256
		sw $s1, 12($s2)
		 
		
		#might implement sleep function here too depending on gravity
		#li $v0, 32
		#li $a0, 25
		#syscall
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j end_platcheck
		
		
end_platcheck:	jr $ra

contact_check:	add $t1, $s0, $zero #start here
		li $t2, 0x716A68
		lw $t3, -4($t1)
		beq $t3, $t2, failcond
		lw $t3, 256($t1)
		beq $t3, $t2, failcond
		lw $t3, 4($t1)
		beq $t3, $t2, failcond
		lw $t3, 8($t1)
		beq $t3, $t2, failcond
		lw $t3, 16($t1)
		beq $t3, $t2, failcond
		lw $t3, 268($t1)
		beq $t3, $t2, failcond
		j end_cont_check
		
failcond:	j game_over
		
end_cont_check: jr $ra

game_over:	jal clear_board
		
		li $t0, base_address
		li $t2,  0xffffff #0x81180B #0x34382f 
		#addi $t4, $s0, 0
		#addi $t3, $t3, -6896 #-6640 #-6128 #16
		addi $t4, $t0, 7216
		
		#G
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 252($t4)
		sw $t2, 508($t4)
		sw $t2, 764($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 520($t4)
		sw $t2, 516($t4)
		sw $t2, 776($t4)
		
		addi $t4, $t4, 16
		#A
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		sw $t2, 268($t4)
		sw $t2, 524($t4)
		sw $t2, 780($t4)
		sw $t2, 1036($t4)
		
		addi $t4, $t4, 20
		#M
		addi $t4, $t4, -256
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		sw $t2, 516($t4)
		sw $t2, 524($t4)
		sw $t2, 776($t4)
		addi $t4, $t4, 16
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1280($t4)
		
		addi $t4, $t4, 264
		#E
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 1036($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
	
		addi $t4, $t4, 28
		#O
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 268($t4)
		sw $t2, 512($t4)
		sw $t2, 524($t4)
		sw $t2, 768($t4)
		sw $t2, 780($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		
		addi $t4, $t4, 20
		#V
		sw $t2, 0($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 16($t4)
		sw $t2, 272($t4)
		sw $t2, 528($t4)
		sw $t2, 772($t4)
		sw $t2, 780($t4)
		sw $t2, 1032($t4)
		
		addi $t4, $t4, 24
		#E
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 12($t4)
		sw $t2, 256($t4)
		sw $t2, 512($t4)
		sw $t2, 768($t4)
		sw $t2, 1024($t4)
		sw $t2, 1028($t4)
		sw $t2, 1032($t4)
		sw $t2, 1036($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		
		addi $t4, $t4, 20
		#R
		sw $t2, 0($t4)
		sw $t2, 4($t4)
		sw $t2, 8($t4)
		sw $t2, 256($t4)
		sw $t2, 268($t4)
		sw $t2, 512($t4)
		sw $t2, 516($t4)
		sw $t2, 520($t4)
		sw $t2, 524($t4)
		sw $t2, 768($t4)
		sw $t2, 776($t4)
		sw $t2, 1024($t4)
		sw $t2, 1036($t4)
		
		j end
		
		#fix falling down drawing, implement cannot move left or right while in the air! (only vertical jumps) if i want plus implement if touch rock
		#from left right center jump to p_pressed
		#tasks: implement touch rock from left right down jump to p_pressed (fail cond) (3), implement moving platform (delay when resetting)(2), implement random left side disappearing branch (1)
		# , implement win bar - jumps to main when done (win cond) (4) implement adding another rock(5), implement head touching floor above(6) - done
		
		#doing (3) rn i think so
		# turn it into 512x512!!!!!! - first priority - done
		
