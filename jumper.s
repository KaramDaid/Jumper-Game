#####################################################################
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#
# List of additional features
# 1. Score is displayed on screen and is constantly updated as the player progresses. When the player wins or loses the score is also displayed on the gameover screen.
# 2. Player is able to input their name using a keyboard, name is shown on screen throughout the game and on the gameover screen/
# 3. Dynamic on-screen notifications are shown while progressing throughout the game.
#
# Additional information:
# - You can a input name of exactly 5 chars, but since letter are printing using 3x5 pixels some
# 	letters/numbers may look similar/identical to others, also w/m can't be printed as they are too wide
# - There is gameover screen for win and loss, getting a 90+ score is considered a win, game will end at 99 and show win screen
#
# HOW TO START A GAME:
#	- open and connect bitmap display and keyboard/display MMIO simulator
#	- compile and run
#	- RUN I/O will ask for 5 character name, exactly 5
#	- game should start, input j/k in keyboard MMIO to move around
#####################################################################
                    
.data
	#screen
	screenWidth:	.word	32
	screenHeight:	.word	32
	screenFinal:	.word	4096
	
	#display
	displayAddress:	.word	0x10008000
	displayConsole:	.word	0xffff000c
	
	#keyboard
	keyboardAddress:	.word	0xffff0004
	
	#colors
	skyColour: .word 0x87ceff
	red: .word 0xff0000
	blue: .word 0x0000ff
	green: .word 0x00ff00
	black:	.word	0x000000
	white:	.word	0xffffff
	orange:	.word	0xFFBF00
	purple:	.word	0x800080
	
	#name
	askName: .asciiz "\nEnter a Name (exactly 5 chars, letters only): "
	nameLength: .space 6
	
	#platforms
	platformArray:	.word	12
	
.text

main:
	lw $t0, displayAddress	# $t0 stores the base address for display
	addi $t2, $t0, 4096 #last bitmap address in $t2
	
	la $a0, askName
	li $v0, 4 #set to print
	syscall #ask name
	
	li $v0, 8 #set to read string
	addi $a1, $0, 6 #number of chars to read
	syscall
	
	move $t7, $a0 #store name into $t7
	
	addi $t5, $zero, 0 #platform array index
	
	addi $t4, $zero, 20 #setup initial platform locations
	sw $t4, platformArray($t5)
	addi $t5, $t5, 4
	
	addi $t4, $0, 13
	sw $t4, platformArray($t5)
	addi $t5, $t5, 4
	
	addi $t4, $0, 16
	sw $t4, platformArray($t5)
	
	addi $s2, $zero, 11#platform decreaser
	addi $s3, $zero, 0#since last jump
	addi $s4, $zero, 16 #doodler x
	addi $s5, $zero, 30 #doodler y
	addi $s6, $zero, 0 # score first digit
	addi $s7, $zero, 0 # score second digit

	
	
drawSky:
	lw $t0, displayAddress	# $t0 stores the base address for display
	addi $t2, $t0, 4096 #last bitmap address in $t2
	addi $t0, $t0, 896
	lw $t1, skyColour
	drawSkyLoop:
		beq $t0, $t2, drawScoreBar
		sw $t1, 0($t0)
		addiu $t0, $t0, 4
		j drawSkyLoop



drawScoreBar:
	lw $t0, displayAddress
	lw $t1, black
	li $t2, 0
	addi $t2, $t0, 896
	drawScoreBarLoop:
		beq $t0, $t2, drawNameText
		sw $t1, 0($t0)
		addiu $t0, $t0, 4
		j drawScoreBarLoop
	drawNameText:
		lw $t1, white
		
		lw $a0, displayAddress
		addiu $a0, $a0, 132 #first letter print location
		lb $t6, 0($t7) #first letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 148 #second letter print location
		lb $t6, 1($t7) #second letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 164 #third letter print location
		lb $t6, 2($t7) #third letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 180 #fourth letter print location
		lb $t6, 3($t7) #fourth letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 196 #fifth letter print location
		lb $t6, 4($t7) #fifth letter stored
		jal drawLetter
				
		lw $a0, displayAddress
		addiu $a0, $a0, 224 #first number print location
		move $t6, $s6
		jal drawNumber
		
		lw $a0, displayAddress
		addiu $a0, $a0, 240 #first number print location
		move $t6, $s7
		jal drawNumber
		j dynamicNotification
		
sleep:
	addi $a0, $zero, 130
	li $v0, 32
	syscall
	jr $ra
	
dynamicNotification:
	lw $t1, orange
	addi $t0, $0, 3
	div $s7, $t0
	
	mfhi $t4
	addi $t0, $0, 0
	beq $t4, $t0, drawNice
	
	addi $t0, $0, 1
	beq $t4, $t0, drawCool
	
	addi $t0, $0, 2
	beq $t4, $t0, drawGoodjob
	
	drawNice:
		lw $a0, displayAddress
		addiu $a0, $a0, 1028
		jal drawN
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1044
		jal drawI
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1060
		jal drawC
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1076
		jal drawE
		j dynamicNotificationEnd
		
	drawCool:
		lw $a0, displayAddress
		addiu $a0, $a0, 1028
		jal drawC
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1044
		jal drawO
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1060
		jal drawO
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1076
		jal drawL
		j dynamicNotificationEnd
		
	drawGoodjob:
		lw $a0, displayAddress
		addiu $a0, $a0, 1028
		jal drawG
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1044
		jal drawO
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1060
		jal drawO
	
		lw $a0, displayAddress
		addiu $a0, $a0, 1076
		jal drawD
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1092
		jal drawJ
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1108
		jal drawO
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1124
		jal drawB
		j dynamicNotificationEnd
		
	dynamicNotificationEnd:
		j drawPlatforms

drawPlatforms:
	addi $a1, $zero, 24
	li $v0, 42
	syscall
	addi $a0, $a0, 4 
	add $t9, $a0, $zero #t9 has new randomly generated platform location
	
	addi $t5, $zero, 0 #platform array index
	lw $t1, green #platform colour
	addi $t6, $zero, 4 # register with number 4
	
	lw $a0, displayAddress #get display address
	addi $a0, $a0, 1536 #go to appropriate line
	jal platformDecreaser
	lw $t4, platformArray($t5) #load platform location into t4
	addi $t5, $t5, 4 #increment index
	mult $t4, $t6
	mflo $t4
	add $a0, $t4, $a0
	jal drawPlatformLoop
	
	lw $a0, displayAddress #get display address
	addi $a0, $a0, 2816 #go to appropriate line
	jal platformDecreaser
	lw $t4, platformArray($t5) #load platform location into t4
	addi $t5, $t5, 4 #increment index
	mult $t4, $t6
	mflo $t4
	add $a0, $t4, $a0
	jal drawPlatformLoop
	
	lw $a0, displayAddress #get display address
	addi $a0, $a0, 3968 #go to appropriate line
	jal platformDecreaser
	lw $t4, platformArray($t5) #load platform location into t4
	addi $t5, $t5, 4 #increment index
	mult $t4, $t6
	mflo $t4
	add $a0, $t4, $a0
	jal drawPlatformLoop
	addi $s2, $s2, 1
	
	addi $t4, $zero, 10
	beq $t4, $s2, makeNewPlatform
	j drawPlatformsEnd
	
	makeNewPlatform:
		addi $t5, $zero, 0 #platform array index
		lw $t1, platformArray($t5)
		addi $t5, $t5, 4 #increment index
		lw $t2, platformArray($t5)
		
		sw $t1, platformArray($t5)
		addi $t5, $t5, 4 #increment index
		sw $t2, platformArray($t5)
		addi $t5, $zero, 0 #reset platform array index
		sw $t9, platformArray($t5)
		
		j drawPlatformsEnd
	platformDecreaser:
		addi $t4, $zero, 10
		ble $t4, $s2, platformDecreaserReturn
		addi $t4, $s2, 0 #s2
		addi $t8, $zero, 128
		mult $t4, $t8
		mflo $t4
		add $a0, $a0, $t4
		j platformDecreaserReturn
		platformDecreaserReturn:
			jr $ra
	
	drawPlatformLoop:
		sw $t1, -4($a0)
		sw $t1, -8($a0)
		sw $t1, -12($a0)
		sw $t1, -16($a0)
		sw $t1, 0($a0)
		sw $t1, 4($a0)
		sw $t1, 8($a0)
		sw $t1, 12($a0)
		sw $t1, 16($a0)
		jr $ra
	drawPlatformsEnd:
		j moveDoodler

moveDoodler:
	lw $t1, 0xffff0004
	
	beq $t1, 0x6a, inputJ
	beq $t1, 0x6b, inputK
	j moveDoodlerEnd
	
	inputJ:
		addi $s4, $s4, -1 #doodler x to the left
		addi $t2, $zero, 0
		blt $s4, $t2,setDoodlerX31
		j moveDoodlerEnd
		setDoodlerX31:
			addi $s4, $zero, 31
			j moveDoodlerEnd

	inputK:
		addi $s4, $s4, 1 #doodler x to the left
		addi $t2, $zero,32
		bgt $s4, $t2,setDoodlerX0
		j moveDoodlerEnd
		setDoodlerX0:
			addi $s4, $zero, 0
			j moveDoodlerEnd
	moveDoodlerEnd:
		sw $zero, 0xffff0004 #reset input to 0
		j drawDoodler

drawDoodler:
	lw $t1, purple #doodler colour
	lw $a0, displayAddress #get display address
	addi $t2, $zero, 128
	mult $t2, $s5
	mflo $t3
	add $a0, $a0, $t3 #go to appropriate Y
	
	addi $t2, $zero, 4
	mult $t2, $s4
	mflo $t3
	add $a0, $a0, $t3 #go to appropriate X
	
	#sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, -4($a0)
	sw $t1, -256($a0)
	sw $t1, -128($a0)
	sw $t1, -124($a0)
	sw $t1, -132($a0)
	j doodlerMovement

doodlerMovement:
	addi $t4, $zero, 10 #distance up after bounce
	ble $s3, $t4, doodlerMoveUp #check if you need to move up
	addi $s5, $s5, 1 #move doodler down
	j doodlerMovementEnd
	doodlerMoveUp:
		addi $s5, $s5, -1 #move doodler up
		addi $s3, $s3, 1 #increment counter
		j doodlerMovementEnd
	doodlerMovementEnd:
		j checkDoodlerCollision
checkDoodlerCollision:
	addi $t4, $zero, 10 #distance up after bounce
	ble $s3, $t4, checkDoodlerCollisionEnd #if doodler is going up, exit
	
	addi $t4, $zero, 32
	beq $t4, $s5, drawGameOver #check if doodler fell to bottom
	
	add $t4, $zero, $s5 # doodle y location in t4
	
	add $t1, $zero, 30 #first platform y location
	beq $t4, $t1, firstPlatformCheck
	
	add $t1, $zero, 21 #second platform y location
	beq $t4, $t1, secondPlatformCheck
	
	j checkDoodlerCollisionEnd
	firstPlatformCheck:
		
		addi $t1, $zero, 8 #platform array index
		lw $t2, platformArray($t1) #load platform middle location
		add $t4, $zero, $s4 # doodle x location in t4
		
		addi $t3, $t4, -1 #left leg of doodler
		
		beq $t2, $t3, bounceUp #check platform middle
		addi $t2, $t2, -1 #check platform -1
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -2
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -3
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -4
		beq $t2, $t3, bounceUp
		lw $t2, platformArray($t1) #load platform middle location
		addi $t2, $t2, 1 #check platform 1
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 2
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 3
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 4
		beq $t2, $t3, bounceUp
		
		lw $t2, platformArray($t1) #load platform middle location
		addi $t3, $t4, 1 #right leg of doodler
		beq $t2, $t3, bounceUp #check platform middle
		
		addi $t2, $t2, -1 #check platform -1
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -2
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -3
		beq $t2, $t3, bounceUp
		addi $t2, $t2, -1 #check platform -4
		beq $t2, $t3, bounceUp
		lw $t2, platformArray($t1) #load platform middle location
		addi $t2, $t2, 1 #check platform 1
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 2
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 3
		beq $t2, $t3, bounceUp
		addi $t2, $t2, 1 #check platform 4
		beq $t2, $t3, bounceUp
		
		j checkDoodlerCollisionEnd
		
	secondPlatformCheck:
		addi $t1, $zero, 4 #platform array index
		lw $t2, platformArray($t1) #load platform middle location
		add $t4, $zero, $s4 # doodle x location in t4
		
		addi $t3, $t4, -1 #left leg of doodler
		
		beq $t2, $t3, bounceUpNewPlatform #check platform middle
		addi $t2, $t2, -1 #check platform -1
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -2
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -3
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -4
		beq $t2, $t3, bounceUpNewPlatform
		lw $t2, platformArray($t1) #load platform middle location
		addi $t2, $t2, 1 #check platform 1
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 2
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 3
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 4
		beq $t2, $t3, bounceUpNewPlatform
		
		lw $t2, platformArray($t1) #load platform middle location
		addi $t3, $t4, 1 #right leg of doodler
		beq $t2, $t3, bounceUpNewPlatform #check platform middle
		
		addi $t2, $t2, -1 #check platform -1
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -2
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -3
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, -1 #check platform -4
		beq $t2, $t3, bounceUpNewPlatform
		lw $t2, platformArray($t1) #load platform middle location
		addi $t2, $t2, 1 #check platform 1
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 2
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 3
		beq $t2, $t3, bounceUpNewPlatform
		addi $t2, $t2, 1 #check platform 4
		beq $t2, $t3, bounceUpNewPlatform
		
		j checkDoodlerCollisionEnd
			
	bounceUp:
		add $s3, $zero, $zero #reset bounce
		j checkDoodlerCollisionEnd
		
	bounceUpNewPlatform:
		addi $t1, $zero, 3
		add $s3, $zero, $t1 #reset bounce
		add $s2, $zero, $zero #used to move platforms
		jal incrementScore
	
		j checkDoodlerCollisionEnd
	checkDoodlerCollisionEnd:
		jal sleep
		j drawSky
	
incrementScore:
	addi $t0, $0, 9
	beq $t0, $s7, upTen
	j incrementNormal
	upTen:
		addi $s6, $s6, 1
		add $s7, $0, $0
		jr $ra
	incrementNormal:
		addi $s7, $s7, 1
	
	addi $t0, $0, 9
	beq $t0, $s6, scoreNinety
	jr $ra
	scoreNinety:
		beq $t0, $s7, drawGameOver
	jr $ra
	
drawGameOver:
	lw $t0, displayAddress
	lw $t1, black
	addi $t2, $t0, 4096
	drawGameOverLoop:
		beq $t0, $t2, drawGameOver2
		sw $t1, 0($t0)
		addiu $t0, $t0, 4
		j drawGameOverLoop
	drawGameOver2:
		lw $t1, red
		lw $a0, displayAddress
		addiu $a0, $a0, 132
		jal drawY
		
		lw $a0, displayAddress
		addiu $a0, $a0, 148
		jal drawO
		
		lw $a0, displayAddress
		addiu $a0, $a0, 164
		jal drawU
		
		addi $t0, $0, 9
		beq $t0, $s6, gameOverWin
		
		lw $a0, displayAddress
		addiu $a0, $a0, 900
		jal drawL
		
		lw $a0, displayAddress
		addiu $a0, $a0, 916
		jal drawO
		
		lw $a0, displayAddress
		addiu $a0, $a0, 932
		jal drawS
		
		lw $a0, displayAddress
		addiu $a0, $a0, 948
		jal drawE
		
		j gameOverScoreDisplay
		
		gameOverWin:
		lw $a0, displayAddress
		addiu $a0, $a0, 900
		jal drawU
		lw $a0, displayAddress
		addiu $a0, $a0, 908
		jal drawU
		
		lw $a0, displayAddress
		addiu $a0, $a0, 924
		jal drawI
		
		lw $a0, displayAddress
		addiu $a0, $a0, 940
		jal drawN
		j gameOverScoreDisplay
		
		gameOverScoreDisplay:
		lw $a0, displayAddress
		addiu $a0, $a0, 1668 #first letter print location
		lb $t6, 0($t7) #first letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1684 #second letter print location
		lb $t6, 1($t7) #second letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1700 #third letter print location
		lb $t6, 2($t7) #third letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1716 #fourth letter print location
		lb $t6, 3($t7) #fourth letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 1732 #fifth letter print location
		lb $t6, 4($t7) #fifth letter stored
		jal drawLetter
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2692
		jal drawS
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2708
		jal drawC
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2724
		jal drawO
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2740
		jal drawR
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2756
		jal drawE
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2776 #first number print location
		move $t6, $s6
		jal drawNumber
		
		lw $a0, displayAddress
		addiu $a0, $a0, 2792 #first number print location
		move $t6, $s7
		jal drawNumber
		
		j Exit

drawNumber:
	
	addi $t3, $zero, 0
	beq, $t6, $t3, drawZero
	
	addi $t3, $zero, 1
	beq, $t6, $t3, drawOne
	
	addi $t3, $zero, 2
	beq, $t6, $t3, drawTwo
	
	addi $t3, $zero, 3
	beq, $t6, $t3, drawThree
	
	addi $t3, $zero, 4
	beq, $t6, $t3, drawFour
	
	addi $t3, $zero, 5
	beq, $t6, $t3, drawFive
	
	addi $t3, $zero, 6
	beq, $t6, $t3, drawSix
	
	addi $t3, $zero, 7
	beq, $t6, $t3, drawSeven
	
	addi $t3, $zero, 8
	beq, $t6, $t3, drawEight
	
	addi $t3, $zero, 9
	beq, $t6, $t3, drawNine
	
	
	bne $t6, $t3, drawM #when a non-accpeted input is given
	
drawLetter:
	addi $t3, $zero, 97
	beq, $t6, $t3, drawA
	addi $t3, $zero, 65
	beq $t6, $t3, drawA
	 
	addi $t3, $zero, 98
	beq, $t6, $t3, drawB
	addi $t3, $zero, 66
	beq $t6, $t3, drawB
	 
	addi $t3, $zero, 99
	beq, $t6, $t3, drawC
	addi $t3, $zero, 67
	beq $t6, $t3, drawC
	 
	addi $t3, $zero, 100
	beq, $t6, $t3, drawD
	addi $t3, $zero, 68
	beq $t6, $t3, drawD
	 
	addi $t3, $zero, 101
	beq, $t6, $t3, drawE
	addi $t3, $zero, 69
	beq $t6, $t3, drawE
	 
	addi $t3, $zero, 102
	beq, $t6, $t3, drawF
	addi $t3, $zero, 70
	beq $t6, $t3, drawF
	 
	addi $t3, $zero, 103
	beq, $t6, $t3, drawG
	addi $t3, $zero, 71
	beq $t6, $t3, drawG
	 
	addi $t3, $zero, 104
	beq, $t6, $t3, drawH
	addi $t3, $zero, 72
	beq $t6, $t3, drawH
	 
	addi $t3, $zero, 105
	beq, $t6, $t3, drawI
	addi $t3, $zero, 73
	beq $t6, $t3, drawI
	 
	addi $t3, $zero, 106
	beq, $t6, $t3, drawJ
	addi $t3, $zero, 74
	beq $t6, $t3, drawJ
	 
	addi $t3, $zero, 107
	beq, $t6, $t3, drawK
	addi $t3, $zero, 75
	beq $t6, $t3, drawK
	 
	addi $t3, $zero, 108
	beq, $t6, $t3, drawL
	addi $t3, $zero, 76
	beq $t6, $t3, drawL
	 
	addi $t3, $zero, 109
	beq, $t6, $t3, drawM
	addi $t3, $zero, 77
	beq $t6, $t3, drawM
	 
	addi $t3, $zero, 110
	beq, $t6, $t3, drawN
	addi $t3, $zero, 78
	beq $t6, $t3, drawN
	 
	addi $t3, $zero, 111
	beq, $t6, $t3, drawO
	addi $t3, $zero, 79
	beq $t6, $t3, drawO
	 
	addi $t3, $zero, 112
	beq, $t6, $t3, drawP
	addi $t3, $zero, 80
	beq $t6, $t3, drawP
	 
	addi $t3, $zero, 113
	beq, $t6, $t3, drawQ
	addi $t3, $zero, 81
	beq $t6, $t3, drawQ
	 
	addi $t3, $zero, 114
	beq, $t6, $t3, drawR
	addi $t3, $zero, 82
	beq $t6, $t3, drawR
	 
	addi $t3, $zero, 115
	beq, $t6, $t3, drawS
	addi $t3, $zero, 83
	beq $t6, $t3, drawS
	 
	addi $t3, $zero, 116
	beq, $t6, $t3, drawT
	addi $t3, $zero, 84
	beq $t6, $t3, drawT
	 
	addi $t3, $zero, 117
	beq, $t6, $t3, drawU
	addi $t3, $zero, 85
	beq $t6, $t3, drawU
	 
	addi $t3, $zero, 118
	beq, $t6, $t3, drawV
	addi $t3, $zero, 86
	beq $t6, $t3, drawV
	 
	addi $t3, $zero, 119
	beq, $t6, $t3, drawW
	addi $t3, $zero, 87
	beq $t6, $t3, drawW
	 
	addi $t3, $zero, 120
	beq, $t6, $t3, drawX
	addi $t3, $zero, 88
	beq $t6, $t3, drawX
	 
	addi $t3, $zero, 121
	beq, $t6, $t3, drawY
	addi $t3, $zero, 89
	beq $t6, $t3, drawY
	 
	addi $t3, $zero, 122
	beq, $t6, $t3, drawZ
	addi $t3, $zero, 90
	beq $t6, $t3, drawZ
	
	bne $t6, $t3, drawM #when a non-accpeted input is given
	
drawZero: #draw at $a0, needs 3 width, 5 height
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawNine:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 520($a0)
	jr $ra
drawEight:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawSeven:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 520($a0)
	jr $ra
drawSix:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawFive:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawFour:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 520($a0)
	jr $ra
drawThree:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawTwo:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawOne:
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 520($a0)
	jr $ra
	
drawA:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)

	sw $t1, 520($a0)
	jr $ra
	
drawB:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	jr $ra
drawC:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	
	sw $t1, 256($a0)
	
	sw $t1, 384($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawD:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	jr $ra
drawE:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawF:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)

	
	sw $t1, 512($a0)
	jr $ra
drawG:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawH:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 520($a0)
	jr $ra
drawI:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 132($a0)
	sw $t1, 260($a0)
	sw $t1, 388($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra

drawJ:
	sw $t1, 8($a0)
	
	sw $t1, 136($a0)
	

	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawK:
	sw $t1, 0($a0)

	sw $t1, 8($a0)
	
	sw $t1, 128($a0)

	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)

	
	sw $t1, 384($a0)

	sw $t1, 392($a0)
	
	sw $t1, 512($a0)

	sw $t1, 520($a0)
	jr $ra
drawL:
	sw $t1, 0($a0)
	sw $t1, 128($a0)
	sw $t1, 256($a0)
	sw $t1, 384($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawM:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 516($a0)
	jr $ra
drawN:
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 520($a0)
	jr $ra
drawO:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawP:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 384($a0)
	
	sw $t1, 512($a0)
	jr $ra
drawQ:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)

	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 392($a0)

	sw $t1, 520($a0)
	jr $ra
drawR:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	
	sw $t1, 384($a0)

	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 520($a0)
	jr $ra
drawS:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawT:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 132($a0)
	sw $t1, 260($a0)
	sw $t1, 388($a0)
	sw $t1, 516($a0)
	jr $ra
drawU:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra
drawV:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	sw $t1, 128($a0)
	sw $t1, 136($a0)
	sw $t1, 256($a0)
	sw $t1, 264($a0)
	sw $t1, 384($a0)
	sw $t1, 392($a0)
	sw $t1, 516($a0)
	jr $ra
drawW:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 136($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	sw $t1, 516($a0)
	jr $ra
drawX:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)
	sw $t1, 132($a0)
	sw $t1, 136($a0)
	
	sw $t1, 260($a0)	
	sw $t1, 384($a0)
	sw $t1, 388($a0)
	sw $t1, 392($a0)
	
	sw $t1, 512($a0)
	sw $t1, 520($a0)
	jr $ra
drawY:
	sw $t1, 0($a0)
	sw $t1, 8($a0)
	
	sw $t1, 128($a0)

	sw $t1, 136($a0)
	
	sw $t1, 256($a0)
	sw $t1, 260($a0)
	sw $t1, 264($a0)
	
	sw $t1, 388($a0)

	sw $t1, 516($a0)
	jr $ra
drawZ:
	sw $t1, 0($a0)
	sw $t1, 4($a0)
	sw $t1, 8($a0)

	sw $t1, 136($a0)

	sw $t1, 260($a0)
	sw $t1, 384($a0)
	sw $t1, 512($a0)
	sw $t1, 516($a0)
	sw $t1, 520($a0)
	jr $ra

Exit:
	li $v0, 10 # terminate the program
	syscall
        
