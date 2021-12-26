.data
	displayAddress: .word 0x10008000
	doodleGreen: .word  0x7fecad
	backgroundwhite: .word 0xfffbf0
	deadRed: .word 0xff2121
	platformGreen: .word 0x00bc12
	gameOverRed: .word 0xff461f
	gameOverOrange: .word 0xff8936
	gameOverYellow: .word 0xfff143
	currentAddress: .space 1
	randomPlat1: .word 0   		# respect to Array, 
	randomPlat2: .word 0   		# respect to Array
	randomPlat3: .word 0   		# respect to Array
	randomPlat4: .word 0
	randomPlat5: .word 0
	bitMap:      .space 6000	# only need 4096
	newline: .asciiz  "\n"
	currentDoodlePosition: .word 0	# respect to Array
	sHitTime: .word 0
	noMoreJump: .word 0
	height: .word 0
	meet2: .word 0
	disappear3: .word 0
	platDown: .word 0
	terminateTheGame: .word 0
	level1: .word 0
	level2: .word 0
	level3: .word 0

.text

main:
# debug the scrolling
# randomly generate the first platform
# why we need to manually reset the value at 0xffff0004 to zero 

chooseDifficulties:
 	# Fetching keyboard input
 	lw  $t8, 0xffff0000
	beq $t8, 1, recognizeDifficulties		# if a key is pressed, check which key is pressed
	j chooseDifficulties	
 	
recognizeDifficulties:
	lw  $t2, 0xffff0004
 	beq $t2, 0x31, difficulty1
 	beq $t2, 0x32, difficulty2
 	beq $t2, 0x33, difficulty3
 	j chooseDifficulties
 
  
difficulty1:
	add $t1, $zero, $zero
	sw $t1, 0xffff0004
 	addi $t2, $zero, 1
 	sw $t2, level1
 	j fetchKeyboard
 
difficulty2:
	add $t1, $zero, $zero
	sw $t1, 0xffff0004
 	addi $t2, $zero, 1
 	sw $t2, level2
 	j fetchKeyboard
 
difficulty3:
	add $t1, $zero, $zero
	sw $t1, 0xffff0004
 	addi $t2, $zero, 1
 	sw $t2, level3
 	j fetchKeyboard
 	
fetchKeyboard:
	# Fetching keyboard input
 	lw  $t8, 0xffff0000
	beq $t8, 1, gameStartSignal		# if a key is pressed, check which key is pressed
	j fetchKeyboard				# if keyboard is not pressed, keep asking which key is pressed
	
gameStartSignal:
 	lw  $t2, 0xffff0004
 	beq $t2, 0x73, gameStart
 	j fetchKeyboard				# if key pressed is not s, keep asking which key is pressed	

gameStart:
	li $v0, 1
	addi $a0, $zero, 520
	syscall
	# sw $zero, 0xffff0004			# restore value in 0xffff0004
	jal calculatePlatformPosition		# calculate the platform postion at the welcome page
	jal welcomePage				# draw Doodle on a platform
 
playFetchKeyBoard:
	lw $t3, meet2
	bne $t3, 1, doNotIncrease
	
	lw $t2, height
	addi $t2, $t2, 2
	sw $t2, height
	
doNotIncrease:
	jal jump				# calculate current lcoation and height
	
	# Fetching keyboard input
 	lw  $t8, 0xffff0000
	beq $t8, 1, keyboard_input		# if keyboard is pressed, check which key is pressed	
	j drawMap				# if no key is pressed, draw the Doodle jumping shoot
	
	
keyboard_input:
 	lw  $t2, 0xffff0004
 	beq $t2, 0x6a, respond_to_j
 	beq $t2, 0x6b, respond_to_k
 	j drawMap				# if neither j nor k is pressed, jump, and ask for the next key input
 	
respond_to_j:
	# sw $zero, 0xffff0004			# restore value in 0xffff0004
	jal moveToLeft
	
	li $v0, 1
	addi $a0, $zero, 0
	syscall
	
	j drawMap
	
	
respond_to_k:
	# sw $zero, 0xffff0004			# restore value in 0xffff0004
	jal moveToRight
	li $v0, 1
	addi $a0, $zero, 1
	syscall

drawMap:	
	jal checkScreen				# check whether my doodler is at the bottom of the screen
	lw $t3, terminateTheGame
	beq $t3, 0, checkPlatforms		# if terminateTheGame is set to 0, begin to move the platform and draw
	jal drawEndScreen			# if terminateTheGame is set to 1, terminate the game
	# jal drawExplosion
	# jal drawGameOver
	j EXIT
	
	
checkPlatforms:
	lw  $t1, meet2				# otherwise, check the consider whether or not showr the platforms
	beq $t1, 0, drawFinalBitMap		# if meet2 = 0, don't move the platform
	jal movePlatforms 			# if meet2 = 1, begin to move the platforms
	
drawFinalBitMap:
	jal drawBitMap				# draw background, platform, doodle based on currentDoodlePosition

	
sleep:			
	li $v0, 32				# sleep
	li $a0, 25
	syscall					

# go back to playFetchKeyBoard
	j playFetchKeyBoard

EXIT: 
	li $v0, 10
	syscall	
		
	
# functions
gameOver:
	li $v0, 1
	addi $a0, $zero, 1998
	syscall
	# letter g
	lw $t9, gameOverYellow
	lw $t8, gameOverRed
	lw $t7, gameOverOrange
	
	
	addi $a0, $zero, 1292			# load anchor of letter g
	
	add  $t2, $zero, $zero			# clear index
while_g_1:
 	beq  $t2, 4, letterG
 	sw   $t9, bitMap($a0)
 	addi $a0, $a0, 4
 	addi $t2, $t2, 1
 	j while_g_1
 	
 letterG:
 	addi $a0, $zero, 1420
 	sw   $t9, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw   $t7, bitMap($a0)
 	
 	addi $a0, $a0, 12
 	sw   $t7, bitMap($a0)
 	
 	addi $a0, $a0, 4
 	sw   $t7, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw   $t8, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw   $t8, bitMap($a0)
 	
 	addi $a0, $a0, -4
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $a0, -4
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $a0, -4
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $a0, -132
 	sw  $t8, bitMap($a0)
 
 	
 	add  $t2, $zero, $zero			# clear index
 	addi $a0, $zero, 1328			# 1292 + 8 * 4 (anchor of A)
 	
 	
 while_a_1:
 	beq  $t2, 3, letterA
 	sw   $t9, bitMap($a0)
 	addi $a0, $a0, 4
 	addi $t2, $t2, 1
 	j while_a_1
 	
letterA:
 	addi $a0, $zero, 1452
 	sw   $t9, bitMap($a0)
 	
 	addi $a0, $a0, 16
 	sw   $t9, bitMap($a0)
 	
 	addi $a0, $zero, 1580
 	add  $t2, $zero, $zero			# clear index
 while_a_2:
 	beq $t2, 5, restOfLetterA
 	sw  $t7, bitMap($a0)
 	addi $a0, $a0, 4
 	addi $t2, $t2, 1
 	j while_a_2
 	
 restOfLetterA:
 	addi $a0, $zero, 1708
 	sw  $t8, bitMap($a0)
 	addi $a0, $a0, 128
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $zero, 1724
 	sw  $t8, bitMap($a0)
 	addi $a0, $a0, 128
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $zero, 1352
 	sw $t9, bitMap($a0)
 	
 	addi $a0, $a0, 16
 	sw $t9, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw $t9, bitMap($a0)
 	
 	addi $a0, $a0, -4
 	sw  $t9, bitMap($a0)
 	
 	addi $a0, $a0, -8
 	sw  $t9, bitMap($a0)
 	
 	addi $a0, $a0, -4
 	sw   $t9, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw  $t7, bitMap($a0)
 	
 	addi $a0, $a0, 8
 	sw  $t7, bitMap($a0)
 	
 	addi $a0, $a0, 8
 	sw  $t7, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $a0, 128
 	sw $t8, bitMap($a0)
 	
 	addi $a0, $a0, -16
 	sw $t8, bitMap($a0)
 	
 	addi $a0, $a0, -128
 	sw  $t8, bitMap($a0)
 	
 	addi $a0, $zero, 1376
 	add  $t2, $zero, $zero			# clear index
 while_e_1:
 	beq $t2, 5, restOfLetterE
 	sw  $t9, bitMap($a0)
 	addi $a0, $a0, 4
 	addi $t2, $t2, 1
 	j while_e_1
 	
 restOfLetterE:
 	
 	
 	
 	
 	jr $ra
 	
welcomePage:

	addi $sp, $sp, -4			# save $ra
	sw  $ra, 0($sp)
	
	#jal paintBackground			# drawBackground	
	
	lw $a0, randomPlat1
	jal drawPlatform
	
	lw $a0, randomPlat2
	jal drawPlatform
	
	lw $a0, randomPlat3
	jal drawPlatform

seeLevel2:
	lw $t2, level2
	beq $t2, 0, seeLevel1
	lw $a0, randomPlat4			# if game level2 = 1, draw extra platform4
	jal drawPlatform
	j drawLevel3
		
seeLevel1: 
	lw $t1, level1
	beq $t1, 0, drawLevel3
	lw $a0, randomPlat4			# if game level1 = 1, draw extra platform4
	jal drawPlatform
	
	lw $a0, randomPlat5			# if game level1 = 1, draw extra platform5
	jal drawPlatform
	
drawLevel3:
	lw   $a0, randomPlat3			# calculate the doodler position
	addi $a0, $a0, -768
	
	sw   $a0, currentDoodlePosition		# update current location

	lw $a1, doodleGreen
	jal drawMyDoodle			# drawDoodle
	jal readBitMap				# readBitMap
	
	
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4
	jr $ra



# draw the explosion after the doodle is dead
drawExplosion:
	addi $sp, $sp, -4			# save $ra
	sw  $ra, 0($sp)
	
	jal drawExplosion1
	#jal drawExplosion2
	#jal drawExplosion3
	
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4
	
	jr $ra
	
	
drawExplosion1:
	jal paintBackground			# drawBackground	

	lw $a0, randomPlat1
	jal drawPlatform
	
	lw $a0, randomPlat2
	jal drawPlatform
	
	lw $a0, randomPlat3
	jal drawPlatform
	
	# $a0 is the start blank box before the first head piece
	lw    $a0, currentDoodlePosition
	addi  $a0, $a0, 4        		# draw head that one unit later than the anchor 

	lw    $t3, deadRed   			# load doodle color
	
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_deadHead1:
	# draw head1
	beq  $s0, 3, draw_deadHead2
	sw   $t3, bitMap($a0)          		# colored as green 
	addi $a0, $a0, 4           		# move to next MA
	addi $s0, $s0, 1
	j while_deadHead1
	
	draw_deadHead2:
	addi   $a0, $a0, 112    		# load head2 address
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_deadHead2:
	beq  $s0, 5, draw_deadHead3
	sw   $t3, bitMap($a0)          		# colored as green 
	addi $a0, $a0 4           		# move to next MA
	addi $s0, $s0, 1
	j while_deadHead2
	
	draw_deadHead3:
	addi $a0, $a0, 108   			# load head3 address
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_deadHead3:
	beq  $s0, 7, draw_deadHead4
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 4				# move to next MA
	addi $s0, $s0, 1
	j while_deadHead3
	
	draw_deadHead4:
	addi $a0, $a0, 100			# load head3 address
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_deadHead4:
	beq  $s0, 5, draw_deadLeg1
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 4				# move to next MA
	addi $s0, $s0, 1
	j while_deadHead4
	
	draw_deadLeg1:
	addi $a0, $a0, 112
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_deadLeg1:
	beq  $s0, 2, draw_deadLeg2
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 128			# move to next MA
	addi $s0, $s0, 1
	j while_deadLeg1
	
	draw_deadLeg2:
	addi $a0, $a0, -256
	addi $a0, $a0, 8
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_deadLeg2:
	beq  $s0, 2, finishedDeadDoodle
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 128			# move to next MA
	addi $s0, $s0, 1
	j while_deadLeg2
	
finishedDeadDoodle:	
	jr $ra

		

# draw the gameOver scene


# draw the screen shown at the end of the program
drawEndScreen:
	addi $sp, $sp, -4			# save $ra
	sw  $ra, 0($sp)
	
	#jal paintBackground			# drawBackground	

	lw $a0, randomPlat1
	jal drawPlatform
	
	lw $a0, randomPlat2
	jal drawPlatform
	
	lw $a0, randomPlat3
	jal drawPlatform
	
	lw $a1, deadRed				
	jal drawMyDoodle			# drawDoodle
	jal gameOver
	jal readBitMap				# readBitMap
	
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4
	
	jr $ra
	

# set terminateTheGame to 1 if my doodler is at the bottom of the screen
# no argument
checkScreen:
	lw $t9, currentDoodlePosition
	sge $s0, $t9, 3324				# $t9 > 991
	beq $s0, 1, terminate
	jr $ra
	
terminate:
	addi $t4, $zero, 1
	sw   $t4, terminateTheGame
	jr   $ra

# calculate how to move platform to create scrolling screen effect
# precondition: one and one of level1, 2, 3 is set to 1 and the others are set to 0
# no argument
movePlatforms:
	lw $t9, level1
	lw $t8, level2
	lw $t7, level3
	
	beq  $t7, 1, moveLevel3
	beq  $t8, 1, moveLevel2
	beq  $t9, 1, moveLevel1
	
	
moveLevel1: # move 5 platfroms
	lw $t2, platDown
	
	beq $t2, 6, resetMeet2_level1			# if platDown = 10, reset meet2, platDown to 0 and do 
							# nothing to randomPlats
	
	addi $t2, $t2, 1				# increment platDown 
	sw   $t2, platDown			
	
	lw $t7, randomPlat1				# if platDown != 10, move the platforms
	addi $t7, $t7, 128
	sw  $t7, randomPlat1
	
	lw $t6, randomPlat2
	addi $t6, $t6, 128
	sw  $t6, randomPlat2
	
	lw $t6, randomPlat3				
	addi $t6, $t6, 128
	sw  $t6, randomPlat3			
	
	lw $t6, randomPlat4				
	addi $t6, $t6, 128
	sw  $t6, randomPlat4
	
	lw $t6, randomPlat5				
	addi $t6, $t6, 128
	sw  $t6, randomPlat5
	
	lw   $t3, height				# change the height
	addi $t3, $t3, -1
	sw   $t3, height
		
	jr $ra
	
resetMeet2_level1: 
	add $t2, $zero, $zero				# reset meet2 and platDown to 0
	sw  $t2, meet2
	sw  $t2, platDown
	
	lw  $t3, randomPlat5				# give value in randomPlat2 to randomPlat3, 
	sw  $t3, randomPlat3
			
	lw  $t7, randomPlat2				# give value in randomPlat1 to randomPlat2
	sw  $t7, randomPlat5
	
	lw  $t7, randomPlat4				# give value in randomPlat1 to randomPlat2
	sw  $t7, randomPlat2
	
	lw  $t7, randomPlat1				# give value in randomPlat1 to randomPlat2
	sw  $t7, randomPlat4
	
	li $v0, 42					# generate a random number and lw it to randomPlat1
 	li $a0, 0
 	li $a1, 14
 	syscall
 	
 	addi $a0, $a0, 64				# 2 * 32
 	sll  $a0, $a0, 2				# address from 0 = random box * 4
 	sw $a0, randomPlat1
				
	jr  $ra
	
	
	
moveLevel2: # move 4 platforms
	lw $t2, platDown
	
	beq $t2, 10, resetMeet2_level2			# if platDown = 8, reset meet2, platDown and disappear3 to 0 and do 
							# nothing to randomPlats
	
	addi $t2, $t2, 1				# increment platDown 
	sw   $t2, platDown			
	
	lw $t7, randomPlat1				# if platDown != 8, move the platforms
	addi $t7, $t7, 128
	sw  $t7, randomPlat1
	
	lw $t6, randomPlat2
	addi $t6, $t6, 128
	sw  $t6, randomPlat2
	
	lw $t6, randomPlat3				# if the third plat is not moved down twice, move it down
	addi $t6, $t6, 128
	sw  $t6, randomPlat3		
	
	lw $t6, randomPlat4				# if the third plat is not moved down twice, move it down
	addi $t6, $t6, 128
	sw  $t6, randomPlat4
	
	lw   $t3, height				# decrement the height
	addi $t3, $t3, -1
	sw   $t3, height
		
	jr $ra
	
resetMeet2_level2:
	add $t2, $zero, $zero				# reset meet2 and platDown to 0
	sw  $t2, meet2
	sw  $t2, platDown
	
	lw  $t3, randomPlat2				# give value in randomPlat2 to randomPlat3, 
	sw  $t3, randomPlat3
			
	lw  $t7, randomPlat4				# give value in randomPlat4 to randomPlat2
	sw  $t7, randomPlat2
	
	lw  $t7, randomPlat1				# give value in randomPlat1 to randomPlat4
	sw  $t7, randomPlat4
	
	li $v0, 42					# generate a random number and lw it to randomPlat1
 	li $a0, 0
 	li $a1, 14
 	syscall
 	
 	addi $a0, $a0, 96				# 3 * 32
 	sll  $a0, $a0, 2				# address from 0 = random box * 4
 	sw $a0, randomPlat1
				
	jr  $ra


moveLevel3: # move 3 platforms
	lw $t2, platDown
	
	beq $t2, 10, resetMeet2_level3				# if platDown = 10, reset meet2, platDown and disappear3 to 0 and do 
							# nothing to randomPlats
	
	addi $t2, $t2, 1				# increment platDown 
	sw   $t2, platDown			
	
	lw $t7, randomPlat1				# if platDown != 10, move the platforms
	addi $t7, $t7, 128
	sw  $t7, randomPlat1
	
	lw $t6, randomPlat2
	addi $t6, $t6, 128
	sw  $t6, randomPlat2
	
	lw $t6, randomPlat3				# if the third plat is not moved down twice, move it down
	addi $t6, $t6, 128
	sw  $t6, randomPlat3			
	
	lw   $t3, height				# decrement the height
	addi $t3, $t3, -1
	sw   $t3, height
		
	jr $ra
	
resetMeet2_level3:
	add $t2, $zero, $zero				# reset meet2 and platDown to 0
	sw  $t2, meet2
	sw  $t2, platDown
	
	lw  $t3, randomPlat2				# give value in randomPlat2 to randomPlat3, 
	sw  $t3, randomPlat3
			
	lw  $t7, randomPlat1				# give value in randomPlat1 to randomPlat2
	sw  $t7, randomPlat2
	
	li $v0, 42					# generate a random number and lw it to randomPlat1
 	li $a0, 0
 	li $a1, 14
 	syscall
 	addi $a0, $a0, 320				# 10 * 32
 	sll  $a0, $a0, 2				# address from 0 = random box * 4
 	sw $a0, randomPlat1
				
	jr  $ra



# draw background, platform, Doodle according to the current location information
drawBitMap:
	
	
	addi $sp, $sp, -4			# save $ra
	sw  $ra, 0($sp)
	
	jal paintBackground			# drawBackground	
	
	lw $a0, randomPlat1
	jal drawPlatform
	
	lw $a0, randomPlat2
	jal drawPlatform
	
	lw $a0, randomPlat3
	jal drawPlatform

drawLevel2:
	lw $t2, level2
	beq $t2, 0, drawLevel1
	lw $a0, randomPlat4			# if game level2 = 1, draw extra platform4
	jal drawPlatform
	j finallyDrawLevel3
		
drawLevel1: 
	lw $t1, level1
	beq $t1, 0, finallyDrawLevel3
	lw $a0, randomPlat4			# if game level1 = 1, draw extra platform4
	jal drawPlatform
	lw $a0, randomPlat5			# if game level1 = 1, draw extra platform5
	jal drawPlatform
	
finallyDrawLevel3:

	lw $a1, doodleGreen
	jal drawMyDoodle			# drawDoodle
	jal readBitMap				# readBitMap
	
	
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4
	jr $ra


	
# update currentDoodlePosition
moveToLeft:
	lw   $t2, currentDoodlePosition		
	addi $t2, $t2, -4
	sw   $t2, currentDoodlePosition
	jr $ra


# update currentDoodlePosition
moveToRight: 
	lw   $t2 currentDoodlePosition
	addi $t2, $t2, 4
	sw   $t2, currentDoodlePosition
	jr $ra
	

# calculate where to jump to and update:
#     					1. the currentDoodlePosition 
#					2. height
jump:
	lw $t7, level3	
	beq  $t7, 0, maybeLevel2
	addi $s1, $zero, 13		# if $t7 = 1, set $s1 = 10
	j jumpUp

maybeLevel2:
	lw $t8, level2
	beq  $t8, 0, mustbeLevel1
	addi $s1, $zero, 12		# if $t8 = 1, set $s1 = 12
	j jumpUp
	
mustbeLevel1:
	addi $s1, $zero, 8		# if not level3, not level2, then it must be level1
	
 # $s1 = 8 for level3, 9 for level2, 13 for level1
	
jumpUp:	
	lw $t6 height
	sge $s0, $t6, $s1			# original, the value of $s1 is based on the game level
	beq $s0, 1, jumpDown			# if $t7 > $s1
	#beq $t7, 11, jumpDown			# if already jumped up 5 grid
						# if not, still jump up
					
	addi $t6, $t6, 1			# update height
	sw   $t6, height
	
	lw   $t2, currentDoodlePosition		# update currentDoodlePosition
	addi $t2, $t2, -128
	sw   $t2, currentDoodlePosition
	jr   $ra
	
jumpDown:
	
	lw  $t7, currentDoodlePosition		# update currentDoodlePosition
	addi $t7, $t7, 128				
	sw   $t7, currentDoodlePosition
	
	# jump up by changing the value of height to 0
	
	lw $t8, platformGreen			# load platformGreen
	lw $t9, currentDoodlePosition		# load position to ask bitMap
	
	addi $t9, $t9, 772			# currentDoodlePosition + 4 + 6*128 (left feet)
	addi $t5, $t9, 8			# currentDoodlePosition + 4 + 6*128 + 8 (right feet)
	
	lw $t7, bitMap($t9)			# ask bitMap (left feet)
	lw $t4, bitMap($t5)			# ask bitMap (right feet)
	
	beq $t7, $t8, meetPlatform		# if the color underneath Doodle's left feet is platGreen, reset height to 0
	beq $t4, $t8, meetPlatform
	
	jr $ra					# if the color is not platGreen, then keep the height = 5, then
						# at the next shot, Doodle will still jumpdown
	
meetPlatform:						
	add $t6, $zero, $zero			# reset the height to 0, then Doodle can jump up at the next shot
	sw  $t6, height				
	
	# check whether the platform hit is at the second platform, if it is true, set meet2 to 1
	
	lw $t7, randomPlat2			# check randomPlat2
	
	lw $t9, currentDoodlePosition		# load position to ask bitMap
	
	addi $t9, $t9, 772			# 4 + 6*128 (left feet)
						# $t9: plat under left feet
	
	#addi $t6, $t7, -8			# if $t9 < randomPlat2 - 8, don't set the value of meet2 to 1
	#slt $s0, $t9, $t6			# $t9 < $t6
	#beq $s0, 1, finishedJump
	
	addi $t3, $t7, 36			# if $t9 > randomPlat2 + 28, don't set the value of meet2 to 1
	sgt  $s0, $t9, $t3			# $t9 > $t3
	beq  $s0, 1, finishedJump
	
	li $v0, 1
	addi $a0, $zero, 5
	syscall

	addi $t5, $zero, 1			# set meet2 = 1
	sw   $t5, meet2
	
finishedJump:
	jr $ra
	
	#addi $t8, $t7, 36			# if $t9 > randomPlat3 + 36, don't set the value of meet2 to 1
	#sgt  $s1, $t9, $t8 			# $t9 > $t8
						
	
# Doodle
# $a1: color of doodle

  drawMyDoodle:
  
	# $a0 is the start blank box before the first head piece
	lw    $a0, currentDoodlePosition
	addi  $a0, $a0, 4        		# draw head that one unit later than the anchor 
	add   $t3, $zero,$a1			# load color to draw my doodler
	
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_head1:
	# draw head1
	beq  $s0, 3, draw_head2
	sw   $t3, bitMap($a0)          		# colored as green 
	addi $a0, $a0, 4           		# move to next MA
	addi $s0, $s0, 1
	j while_head1
	
	draw_head2:
	addi   $a0, $a0, 112    		# load head2 address
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_head2:
	beq  $s0, 5, draw_head3
	sw   $t3, bitMap($a0)          		# colored as green 
	addi $a0, $a0 4           		# move to next MA
	addi $s0, $s0, 1
	j while_head2
	
	draw_head3:
	addi $a0, $a0, 108   			# load head3 address
	
	add  $s0, $zero, $zero    		# clear index to 0
	
	while_head3:
	beq  $s0, 7, draw_head4
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 4				# move to next MA
	addi $s0, $s0, 1
	j while_head3
	
	draw_head4:
	addi $a0, $a0, 100			# load head3 address
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_head4:
	beq  $s0, 5, draw_leg1
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 4				# move to next MA
	addi $s0, $s0, 1
	j while_head4
	
	draw_leg1:
	addi $a0, $a0, 112
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_leg1:
	beq  $s0, 2, draw_leg2
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 128			# move to next MA
	addi $s0, $s0, 1
	j while_leg1
	
	draw_leg2:
	addi $a0, $a0, -256
	addi $a0, $a0, 8
	
	add  $s0, $zero, $zero			# clear index to 0
	
	while_leg2:
	beq  $s0, 2, finishedDoodle
	sw   $t3, bitMap($a0)			# colored as green 
	addi $a0, $a0 128			# move to next MA
	addi $s0, $s0, 1
	j while_leg2
	
finishedDoodle:	
	jr $ra


# no argument
paintBackground:
 	add $t4, $zero, $zero			# clear index
 	lw  $t1, backgroundwhite		# load background colour
 	
 
 	while_paintBackground:
 	beq  $t4, 4096, finishedBackground
 	sw   $t1, bitMap($t4)
 	addi $t4, $t4, 4  
 	j while_paintBackground
 	
 finishedBackground:
 	jr $ra
 
 # no argument
 # $t1: loop index
 readBitMap:
 	lw $t9, displayAddress
 	
 	# clear index
 	add  $t1, $zero, $zero
 	
 while_readBitMap:
 	beq  $t1, 4096, finishedBitMap
 	lw   $t2, bitMap($t1)			# load color from bitMap Array
 	sw   $t2, 0($t9)			# save color to bitMap display
 	addi $t1, $t1, 4			
 	addi $t9, $t9, 4
 	j while_readBitMap
 	
 finishedBitMap:
 	jr $ra
 	
 	

# $a0: staring position of the platform
# draw a platform with length depends on the game level
drawPlatform:	
	
 	lw $t9, level1
	lw $t8, level2
	lw $t7, level3
	
	# this is level3
	beq  $t7, 0, check_level2
	addi $s1, $zero, 8			# if $t7 = 1, (level3)platform has length 7
	j draw_platform
	
check_level2:
	beq  $t8, 0, check_level1		# if $t8 = 1, (level2)platform has length 9
	addi $s1, $zero, 9
	j draw_platform
	
check_level1:
	addi $s1, $zero, 11
		
draw_platform:	
 	lw   $t2, platformGreen			# load platform color
 	add $t1, $zero, $zero			# clear index
 
while_drawplatform:
 	beq  $t1, $s1, finishedplatform
 	sw   $t2, bitMap($a0)
 	addi $a0, $a0, 4  
 	addi $t1, $t1, 1
 	j while_drawplatform
 
 finishedplatform:
  	jr $ra
  	
  	
 # no argument
 # randomly generate three numbers and update randomplat1, 2, 3 (position are based on bitMap variable)
 calculatePlatformPosition:
 	addi $sp, $sp, -4			# save $ra
	sw  $ra, 0($sp)
	
 	lw $t1, level1
	lw $t2, level2
	lw $t3, level3
	
	beq  $t1, 1, calculateLevel1
	beq  $t2, 1, calculateLevel2
	beq  $t3, 1, calculateLevel3

calculateLevel1:
	jal calculate1
	j finishedCalculation	
	
calculateLevel2:
	jal calculate2
	j finishedCalculation

calculateLevel3:
	jal calculate3
	
finishedCalculation:
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4
	
	jr $ra

# calculate the platform position for game level 3
calculate3: # calculate 3 platforms
 	# length of platform is 7
	li $v0, 42
 	li $a0, 0
 	li $a1, 25				# 32 - 7 =15
 	syscall
 	
 	addi $a0, $a0, 320			# 10 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat1
 	
 
	li $v0, 42
 	li $a0, 0
 	li $a1, 25
 	syscall
 	
 	addi $a0, $a0, 640			# 20 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat2
 	
 
	li $v0, 42
 	li $a0, 0
 	li $a1, 25
 	syscall
 	addi $a0, $a0, 960			# 30 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat3
 	
 	jr $ra
 
# calculate the platform position for game level 2
calculate2: # calculate 4 platforms
 	# length of platform is 9
	li $v0, 42
 	li $a0, 0
 	li $a1, 23				# 32 - 9 = 23
 	syscall
 	
 	addi $a0, $a0, 96			# 3 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat1
 	
 	
	li $v0, 42
 	li $a0, 0
 	li $a1, 23
 	syscall
 	
 	addi $a0, $a0, 674			# 21 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat2
 	
 	
	li $v0, 42
 	li $a0, 0
 	li $a1, 23
 	syscall
 	addi $a0, $a0, 960			# 30 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat3
 	
 	
	li $v0, 42
 	li $a0, 0
 	li $a1, 23
 	syscall
 	addi $a0, $a0, 384			# 12 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat4
 	
 	jr $ra
 	
 # calculate the platform position for game level 1
calculate1: # calculate 5 platforms
 	# length of platform is 11
	li $v0, 42
 	li $a0, 0
 	li $a1, 21				# 32 - 11 = 21
 	syscall
 	
 	addi $a0, $a0, 64			# 2 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat1
 	
 	# a0 =  random column
 	#choose a random column
	li $v0, 42
 	li $a0, 0
 	li $a1, 21
 	syscall
 	
 	addi $a0, $a0, 512			# 16 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat2
 	
 	# a0 =  random column
 	#choose a random column
	li $v0, 42
 	li $a0, 0
 	li $a1, 21
 	syscall
 	addi $a0, $a0, 960			# 30 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat3
 	
 	# a0 =  random column
 	#choose a random column
	li $v0, 42
 	li $a0, 0
 	li $a1, 21
 	syscall
 	addi $a0, $a0, 288			# 9 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat4
 	
 	# a0 =  random column
 	#choose a random column
	li $v0, 42
 	li $a0, 0
 	li $a1, 21
 	syscall
 	addi $a0, $a0, 736			# 23 * 32
 	sll  $a0, $a0, 2			# address from 0 = random box * 4
 	sw $a0, randomPlat5
 	
 	jr $ra

 

 	


