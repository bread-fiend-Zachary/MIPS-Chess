# Zachary Sun
# zbsun

.include "hw4_helpers.asm"


.text

##########################################
#  Part #1 Functions
##########################################
initBoard:
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2
	
	sll $t3, $t1, 4
	sll $t4, $t2, 4
	
	or $t5, $t3, $t0
	or $t6, $t4, $t0
	
	#li $t7, 0xffff0060
	li $t8, 0xffff0000
	li $t9, 'E'
	
	li $t0, 0
	li $t1, 0
	
fillBoardLight:
	beq $t1, 64, doneFill
	beq $t0, 8, doubleFillDark
	
	#store light bg
	sb $t9, 0($t8)
	sb $t6, 1($t8)
	
	#increment array address 
	addi $t8, $t8, 2
	#add 1 to counter
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	j fillBoardDark
	
fillBoardDark:
	beq $t1, 64, doneFill
	beq $t0, 8, doubleFillLight
	
	#store dark bg
	sb $t5, 1($t8)
	sb $t9, 0($t8)
	
	#add 1 to counter
	addi $t0, $t0, 1
	#add another. pls i didnt know how to stop the l00p
	addi $t1, $t1, 1
	#increment array address
	addi $t8, $t8, 2
	
	j fillBoardLight
	
doubleFillDark:

	sb $t5, 1($t8)
	sb $t9, 0($t8)
	
	addi $t8, $t8, 2
	li $t0, 1
	addi $t1, $t1, 1
	j fillBoardLight
	
doubleFillLight:
	#store light bg
	sb $t9, 0($t8)
	sb $t6, 1($t8)
	
	addi $t8, $t8, 2
	addi $t1, $t1, 1
	li $t0, 1
	j fillBoardDark
	
doneFill:
	jr $ra
	
setSquare:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	
	move $t0, $a0	# row
	move $t1, $a1	# col
	move $t2, $a2	# piece
	move $t3, $a3	# player
	lw $t4, 16($sp)	# fg
	
	#error checking
	bltz $t0, notinRange
	bltz $t1, notinRange
	bgt $t0, 7, notinRange
	bgt $t1, 7, notinRange
	bgt $t4, 15, notinRange
	bne $t3, 1, checkP2

errorCheckDone:
	#check if piece is 'E'
	#get the row, column
	#address = base + (i*num col + j) * elem size
	li $s0, 0xffff0000
	li $t5, 8
	li $t6, 2
	mul $s1, $t0, $t5	# i * num col
	add $s1, $s1, $t1	# i * num col + j
	mul $s1, $s1, $t6	# ( i * num col + j ) * elem size
	add $s0, $s0, $s1 	# add base address
	
	beq $t3, 2, fgIsWhite
	#player 2 >>> if comes down
	li $t5, 0xF
	
isBack:
	lb $s1, 1($s0)
	
	#keeps the first 4 most significant bits, replaces the least significant bits with the FG given.
	#li $t6, 11110000
	# changed for the bold bit, 248 = 11111000
	li $t6, 240
	and $t6, $s1, $t6
	or $t6, $t6, $t5
	#or $t6, $t6, $t4
	#sll $s1, $s1, 4
	#or $t6, $s1, $t4

	beq $t2, 'E', setFg
	
	sb $t6, 1($s0)
	sb $t2, 0($s0)	
	
	j restoreStackB
	
fgIsWhite:
	li $t5, 0
	j isBack

setFg:
	or $t6, $t6, $t4
	sb $t6, 1($s0)
	sb $t2, 0($s0)
	j restoreStackB

notinRange:
	li $v0, -1
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra

checkP2:
	#if piece != 2
	bne $t3, 2, notinRange
	j errorCheckDone
	
restoreStackB:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	
	li $v0, 0
	jr $ra
	
initPieces:

	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	
	li $s0, 0	# initial row
	li $s1, 0	# initial column
	li $s2, 'R'	# initial piece
	li $s3, 2 	# intiial player
	li $s4, 0xF	# t4 is fg colour.. ?
	
	li $s5, 0	# counter for pieces
	
	li $t5, 0
	li $t6, 0
	#another helper - this is player 1 for a loop to change pieces.
	li $s6, 1
	#helper - this is the player currently.
	li $s7, 2
			
setBackRowTop:
	beq $s1, 8, setPawnsTop
	beq $s1, 1, setknight
	beq $s1, 2, setbishop
	beq $s1, 3, setqueen
	beq $s1, 4, setking
	beq $s1, 5, setbishop
	beq $s1, 6, setknight
	beq $s1, 7, setrook

changedPieceTop:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	#save fg color to stack
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	
	jal setSquare
	
	addi $s1, $s1, 1	# increment column
	
	#close the stack
	addi $sp, $sp, 4
		
	j setBackRowTop
	
setknight:
	li $s2, 'H'
	beq $s7, $s6, changedPieceBottom
	j changedPieceTop
	
setbishop:
	li $s2, 'B'
	beq $s7, $s6, changedPieceBottom
	j changedPieceTop
	
setqueen:
	li $s2, 'Q'
	beq $s7, $s6, changedPieceBottom
	j changedPieceTop
setking:
	li $s2, 'K'
	beq $s7, $s6, changedPieceBottom
	j changedPieceTop
setrook:
	li $s2, 'R'
	beq $s7, $s6, changedPieceBottom
	j changedPieceTop
	
#	li $s0, 0	# initial row
#	li $s1, 0	# initial column
#	li $s2, 'R'	# initial piece
#	li $s3, 2 	# intiial player
#	li $s4, 0xF	# t4 is fg colour.. ?
	
setPawnsTop:
	li $s1, 0	#reset column to 0
	li $s0, 1	#move to pawn location
	li $s2, 'P'	#set pawns
	
	#li $s7, 1 	don't need rn - remember to change when doing p1.]
	#li $s3, 2	s3 is already 2
	# s4 is already rigfht color as well
	
	
setPawnTopLoop:
	beq $s1, 8, setBottomPawn
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	
	
	move $a2, $s2 	
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	
	jal setSquare
	
	#close stack
	addi $sp, $sp, 4
	
	addi $s1, $s1, 1

	j setPawnTopLoop
	


setBottomPawn:
	li $s0, 6	#row
	li $s1, 0	#column
	li $s2, 'P'	# piece
	li $s3, 1	 # player
	li $s4, 0	 # fg color
	li $s7, 1	# player 1 change


setBottomPawnLoop:
	beq $s1, 8, setBottomBackbe4
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	addi $s1, $s1, 1

	j setBottomPawnLoop
	
setBottomBackbe4:
	li $s0, 7
	li $s1, 0
	li $s2, 'R'
	li $s3, 1
	li $s4, 0
	
setBottomBack:
	beq $s1, 8, doneInitBoard
	beq $s1, 1, setknight
	beq $s1, 2, setbishop
	beq $s1, 3, setqueen
	beq $s1, 4, setking
	beq $s1, 5, setbishop
	beq $s1, 6, setknight
	beq $s1, 7, setrook
changedPieceBottom:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	#save fg color to stack
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	
	jal setSquare
	
	addi $s1, $s1, 1	# increment column
	
	#close the stack
	addi $sp, $sp, 4
		
	j setBottomBack

doneInitBoard:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	
	jr $ra

mapChessMove:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	
	move $t0, $a0	# letter 
	move $t1, $a1	# num
	
	blt $t0, 65, invalidMove
	bgt $t0, 72, invalidMove
	
	li $t2, 65	# 'A' to get the column,
	subu $t2, $t0, $t2	# t2 is the column we get.
	li $t3, 56	
	subu $t3, $t3, $t1	# t3 is the row we get.
	
	blt $t3, 0, invalidMove
	bgt $t3, 7, invalidMove
	
	sll $t3, $t3, 8	#t2 = column
	or $t4, $t2, $t3	#t3 = row
	
	move $v0, $t4
	#sb $t2, 0($v0)
	#sb $t3, 1($v0)
	
	jr $ra
invalidMove:
	li $v0, 0xFFFF
	jr $ra
	

loadGame:
	#a0 is the address of the file
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	#open file
	li $v0, 13
	li $a1, 0
	li $a2, 0
	syscall
	
	move $s0, $v0	# save the file descriptor
	
	bltz $s0, invalidFile
	
readtildone:

	addi $sp, $sp, -4
	#read file
	li $v0, 14
	move $a0, $s0
	sw $a1, 0($sp)
	li $a2, 5
	syscall
	
	j readtildone

invalidFile:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	li $v0, -1
	li $v1, -1
	
	jr $ra	

##########################################
#  Part #2 Functions
##########################################

getChessPiece:
	move $t0, $a0
	li $t1, 1111111100000000

	and $t1, $t1, $t0
	subu $t2, $t0, $t1
	srl $t1, $t1, 8

	#t1 is row
	#t2 is column
	
	#this code segment travels to the chess position
	li $t3, 0xffff0000
	li $t4, 8
	li $t5, 2
	mul $t9, $t1, $t4	# i * num col
	add $t9, $t9, $t2	# i * num col + j
	mul $t9, $t9, $t5	# ( i * num col + j ) * elem size
	add $t9, $t9, $t3 	# add base address
	
	lbu $t1, 0($t9)	# loads the chess piece
	lbu $t2, 1($t9)	# loads the colour to get the player number
	
	#get first 4 bits
	li $t3, 000000001111
	and $t3, $t3, $t2
	#check if empty sq
	beq $t1, 'E', emptySq
	# look for player number
	# 0 = black = p2
	# 15 = white = p1
	beq $t3, 64, player2
	beq $t3, 0, player2
	beq $t3, 73, player1
	beq $t3, 0xF, player1
	beq $t3, 9, player1

player1:
	move $v0, $t1
	li $v1, 1
	jr $ra
	
player2:
	move $v0, $t1
	li $v1, 2
	jr $ra
	

emptySq:
	li $v0, 'E'
	li $v1, -1
	jr $ra
	

validBishopMove:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0	#	from
	move $s1, $a1	#	to
	move $s2, $a2	#	player
	move $s3, $a3	#	short &capture? (PASS BY REFERENCE :<>]]
	
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	
	beq $s0, $s1, invalidMoveBishop		# if to and from areon the same spot, invalid move


	li $t9, 1111111100000000
	# t0 = row for FROM
	# t1 = column for FROM
	and $t0, $t9, $s0
	subu $t1, $s0, $t0
	srl $t0, $t0, 8

	# t2 = row for TO
	# t3 = column for TO
	and $t2, $t9, $s1
	subu $t3, $s1, $t2
	srl $t2, $t2, 8
	
	#error checking here
	# check if PALYER IS VALIDh
	bne $s2, 1, checkP2Bish
contErrorCheck:
	#check if row and columns are VALID from FROM
	#check if FROM ROW is >0$
	blt $t0, 0, invalidArgumentBish
	#check if FROM ROW is <7
	bgt $t0, 7, invalidArgumentBish
	#check if FROM COLUMN is >0
	blt $t1, 0, invalidArgumentBish
	#check if FROM COLUMN is <7
	bgt $t1, 7, invalidArgumentBish
	
	#check if row, column is valid for TO
	# TO ROW <0
	blt $t2, 0, invalidArgumentBish
	# TO ROW <7
	bgt $t2, 7, invalidArgumentBish
	# TO COLUMN > 0
	blt $t3, 0, invalidArgumentBish
	# TO COLUMN < 7
	bgt $t3, 7, invalidArgumentBish
	# if FROM column = TO column
	beq $t1, $t3, invalidMoveBishop
	# if FROM row = TO row
	beq $t0, $t2, invalidMoveBishop
	
	
	#check if bishop wants to go to the RIGHT of it
	bgt $t3, $t1, branchRight
	#else, it is going to the left

	j branchLeft

branchRight:
	#check if bishop wants to move up or down by comparing ROW values
	blt $t2, $t0, fortoprightloop
	#changed saturday ^^^^^^^^^^^^ from blt $t0, $t2 
	
	#here, it is moving bottom right
forBottomRightLoop:
	#bottom right = row increase, column increase
	#if FROM row = TO row, then maybe bishop moved to right spot. 
	
	#logic checks out here 5:00 pm sat
	
#	beq $t0, $t2, checkColBottomRight
#
#	changed sat 6:16 - did not think i need separate check cols. can use just 1.
#
#
#
	beq $t0, $t2, checkCol
	
	#increment both row and column to go diagonal
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
		#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
		
	#if space is occupied, then invalid
	bne $v0, 'E', obstructiondetectedbeforedestination
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j forBottomRightLoop
	
fortoprightloop:
#bottom right = row decrease, column increase
	#if FROM row = TO row, then maybe bishop moved to right spot. 
	
	#logic checks out here 5:00 pm sat
	beq $t0, $t2, checkCol
	
	#increment both row and column to go diagonal
	addi $t0, $t0, -1
	addi $t1, $t1, 1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture	
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructiondetectedbeforedestination
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j fortoprightloop
	
branchLeft:
	blt $t0, $t2, movebottomLeft

movetopLeft:
	#top left = row decrease, column increase
	#if FROM row = TO row, then maybe bishop moved to right spot. 
	
	#logic checks out here 5:00 pm sat
	beq $t0, $t2, checkCol
	
	#increment both row and column to go diagonal
	addi $t0, $t0, -1
	addi $t1, $t1, -1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructiondetectedbeforedestination
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j movetopLeft

movebottomLeft:
	#bottom left = row decrease, column increase
	#if FROM row = TO row, then maybe bishop moved to right spot. 
	
	#logic checks out here 5:00 pm sat
	beq $t0, $t2, checkCol
	
	#increment both row and column to go diagonal
	addi $t0, $t0, 1
	addi $t1, $t1, -1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructiondetectedbeforedestination

	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j movebottomLeft
		
checkCol:
	bne $t1, $t3, invalidMoveBishop
	#is valid move - check if this square is holding anything
	#move TO to a0 to check whats inside
	move $a0, $s1
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	#return piece in v0, player in v1
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	# check what is in this square
	#moved to an empty spot
	beq $v0, 'E', unoccupiedSpace
	
	#check if palyer captured piece on same team
	beq $v1, $s2, selfCapture
	
	#otherwise, this square contains opponent's piece
	j takeopponentpiece
	
takeopponentpiece:
	#store the TO value to the address
	sh $s1, 0($s3)
	#v0 contains piece that we deducted from getchesspiece
	move $v1, $v0
	li $v0, 1
	
	j restoreStackBishop
	
obstructiondetectedbeforedestination:
	beq $t0, $t2, checkCol
	li $v0, -1
	li $v1, '\0'
	
	j restoreStackBishop
	
unoccupiedSpace:
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackBishop
	
selfCapture:
	li $v0, -1
	li $v1, '\0'
	
	j restoreStackBishop
	
checkP2Bish:
	bne $s2, 2, invalidArgumentBish
	j contErrorCheck
	
invalidMoveBishop:
	li $v0, -1
	li $v1, '\0'
	
	j restoreStackBishop
	
invalidArgumentBish:
	li $v0, -2
	li $v1, '\0'
	
	j restoreStackBishop
	
restoreStackBishop:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	
	jr $ra
	
	###################	###################	###################	###################	###################

	###################	###################	###################	###################
validRookMove:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0	#	from
	move $s1, $a1	#	to
	move $s2, $a2	#	player
	move $s3, $a3	#	short &capture? (PASS BY REFERENCE :<>]]
	
	beq $s0, $s1, invalidMoveRook
	
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	
	li $t9, 1111111100000000
	# t0 = row for FROM
	# t1 = column for FROM
	and $t0, $t9, $s0
	subu $t1, $s0, $t0
	srl $t0, $t0, 8

	# t2 = row for TO
	# t3 = column for TO
	and $t2, $t9, $s1
	subu $t3, $s1, $t2
	srl $t2, $t2, 8
	
	#error checking here
	# check if PALYER IS VALIDh
	bne $s2, 1, checkP2ROOK
contErrorCheckROOK:
	#check if row and columns are VALID from FROM
	#check if FROM ROW is >0$
	blt $t0, 0, invalidArgumentRook
	#check if FROM ROW is <7
	bgt $t0, 7, invalidArgumentRook
	#check if FROM COLUMN is >0
	blt $t1, 0, invalidArgumentRook
	#check if FROM COLUMN is <7
	bgt $t1, 7, invalidArgumentRook
	
	#check if row, column is valid for TO
	# TO ROW <0
	blt $t2, 0, invalidArgumentRook
	# TO ROW <7
	bgt $t2, 7, invalidArgumentRook
	# TO COLUMN > 0
	blt $t3, 0, invalidArgumentRook
	# TO COLUMN < 7
	bgt $t3, 7, invalidArgumentRook
	
	#check moves
	#if FROM ROW = TO ROW
	beq $t0, $t2, moveHorizontal
	
	#if FROM COLUMN = TO COLUMN
	beq $t1, $t3, moveVertical
	
	#if it comes down here, it is not a rook movement
	j invalidMoveRook
	
moveHorizontal:
	beq $t1, $t3, invalidMoveRook
	bgt $t1, $t3, moveHorizontalLeft
	
moveHorizontalRight:
	#if FROM col = TO col then reached destination
	beq $t1, $t3, checkFinalSQ
	
	#increment column
	addi $t1, $t1, 1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructionDetectedRook
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j moveHorizontalRight
	
moveHorizontalLeft:
	#if FROM col = TO col then reached destination
	beq $t1, $t3, checkFinalSQ
	
	#increment column
	addi $t1, $t1, -1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructionDetectedRook
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j moveHorizontalLeft
	
checkFinalSQ:
	#is valid move - check if this square is holding anything
	#move TO to a0 to check whats inside
	move $a0, $s1
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	#return piece in v0, player in v1
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	# check what is in this square
	#moved to an empty spot
	beq $v0, 'E', unoccupiedSpaceRook
	
	#check if palyer captured piece on same team
	beq $v1, $s2, selfCaptureRook
	
	#otherwise, this square contains opponent's piece
	j takeopponentpiecerook
	
moveVertical:
	blt $t0, $t2, moveVerticalDown
	
moveVerticalUp:
#	if FROM row = TO row then reached destination
	beq $t0, $t2, checkFinalSQ
	
	#increment row
	addi $t0, $t0, -1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructionDetectedRook
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j moveVerticalUp
	
moveVerticalDown:
#	if FROM row = TO row then reached destination
	beq $t0, $t2, checkFinalSQ
	
	#increment row
	addi $t0, $t0, -1
	
	#move argument into register
	sll $t4, $t0, 8		#t1 = column
	or $a0, $t1, $t4		#t0 = row
	
	#save important registers
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	jal getChessPiece
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16
	
	#if v1 square is the same player as one moving
	#changed saturday - do not need to check this here 
	#beq $v1, $s2, selfCapture
	
	#if space is occupied, then invalid
	bne $v0, 'E', obstructionDetectedRook
	
	#else, it is empty.
	#keep looping until find obstruction or reached destination
	
	j moveVerticalDown

obstructionDetectedRook:
	sll $t5, $t0, 8
	or $t6, $t1, $t5
	
	beq $t6, $s1, checkFinalSQ
	
	li $v0, -1
	li $v1, '\0'
	j restoreStackRook

selfCaptureRook:
	li $v0, -1
	li $v1, '\0'
	j restoreStackRook
	
unoccupiedSpaceRook:
	li $v0, 0
	li $v1, '\0'
	j restoreStackRook
	
takeopponentpiecerook:
	#store the TO value to the address
	sh $s1, 0($s3)
	#v0 contains piece that we deducted from getchesspiece
	move $v1, $v0
	li $v0, 1
	
	j restoreStackRook
	
checkP2ROOK:
	bne $s2, 2, invalidArgumentRook
	
	j contErrorCheckROOK
	
invalidMoveRook:
	li $v0, -1
	li $v1, '\0'
	j restoreStackRook
	
invalidArgumentRook:
	li $v0, -2
	li $v1, '\0'
	j restoreStackRook
	
	
restoreStackRook:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	
	jr $ra
	
	
perform_move:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	
	lw $t0, 0($sp)
	
	addi $sp, $sp, -36
	sw $ra, 0($sp)	#	
	sw $s0, 4($sp)	#	player
	sw $s1, 8($sp)	# 	short from
	sw $s2, 12($sp)	#	short to
	sw $s3, 16($sp)	#	byte fg
	sw $s4, 20($sp)	#	short& king_position\\
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0	#	player
	move $s1, $a1	#	short from
	move $s2, $a2	#	short to
	move $s3, $a3	#	byte fg
	move $s4, $t0	#	short & king position
	
	#get chess piece at from
	move $a0, $s1
	jal getChessPiece
	#v0 = piece
	#v1 = player
	
	bne $v1, $s0, wrongPlayerMove
	beq $v0, 'E', invalidMoveMove
	move $s6, $v1
	move $s5, $v0
	
	#get chess piece at To
	move $a0, $s2
	jal getChessPiece
	#$v0 = piece
	#$v1 = player
	move $s7, $v1
	
	
	#
	#
	#
	#	to do: perform argument error if position is invalid
	
	li $t9, 1111111100000000
	# t0 = row for FROM
	# t1 = column for FROM
	and $t0, $t9, $s1
	subu $t1, $s1, $t0
	srl $t0, $t0, 8
	

	# t2 = row for TO
	# t3 = column for TO
	and $t2, $t9, $s2
	subu $t3, $s2, $t2
	srl $t2, $t2, 8
	
	
	beq $s5, 'P', doPawnMove
	beq $s5, 'p', doPawnMove
	beq $s5, 'K', doKingMove
	beq $s5, 'Q', doQueenMove
	beq $s5, 'H', doHorseMove
	beq $s5, 'R', doRookMove
	beq $s5, 'B', doBishopMove
	
doRookMove:
move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	
	addi $sp, $sp, -4
	move $a3, $sp

	#addi $sp, $sp, -4
	#sw $t9, 0($sp)
		
	jal validRookMove
	
	lh $s7, 0($sp)
	
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	#addi $sp, $sp, 4

	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, rookInvalidArgument
	beq $v0, -1, rookInvalidInput
	beq $v0, 0, rookMoveUnobstructed
	beq $v0, 1, rookMoveCapture
	
rookInvalidArgument:
li $v0, -2
	li $v1, '\0'
	j restoreStackmove
rookInvalidInput:
li $v0, -1
	li $v1, '\0'
	j restoreStackmove
rookMoveUnobstructed:

	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'R'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove
rookMoveCapture:
#set the empty square FROM to empty
	move $a0, $t0
	move $a1, $t1
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 'R'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s6
	j restoreStackmove



doBishopMove:
	move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	
	addi $sp, $sp, -4
	move $a3, $sp

	#addi $sp, $sp, -4
	#sw $t9, 0($sp)
		
	jal validBishopMove
	
	lh $s7, 0($sp)
	
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	#addi $sp, $sp, 4

	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, bishopInvalidArgument
	beq $v0, -1, bishopInvalidInput
	beq $v0, 0, bishopMoveUnobstructed
	beq $v0, 1, bishopMoveCapture
	
	
bishopInvalidArgument:
li $v0, -2
	li $v1, '\0'
	j restoreStackmove
bishopInvalidInput:
li $v0, -1
	li $v1, '\0'
	j restoreStackmove
bishopMoveUnobstructed:

	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'B'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove

bishopMoveCapture:
	#set the empty square FROM to empty
	move $a0, $t0
	move $a1, $t1
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 'B'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s6
	j restoreStackmove

	

doKingMove:
move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	
	addi $sp, $sp, -4
	move $a3, $sp

	#addi $sp, $sp, -4
	#sw $t9, 0($sp)
		
	jal validKingMove
	
	lh $s7, 0($sp)
	
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	#addi $sp, $sp, 4

	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, kingInvalidArgument
	beq $v0, -1, kingInvalidInput
	beq $v0, 0, kingMoveUnobstructed
	beq $v0, 1, kingMoveCapture
	
kingInvalidArgument:
li $v0, -2
	li $v1, '\0'
	j restoreStackmove
kingInvalidInput:
li $v0, -1
	li $v1, '\0'
	j restoreStackmove
kingMoveUnobstructed:

	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'K'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove
kingMoveCapture:
#set the empty square FROM to empty
	move $a0, $t0
	move $a1, $t1
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 'K'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s6
	j restoreStackmove

doQueenMove:
	move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	
	addi $sp, $sp, -4
	move $a3, $sp

	#addi $sp, $sp, -4
	#sw $t9, 0($sp)
		
	jal validQueenMove
	
	lh $s7, 0($sp)
	
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	#addi $sp, $sp, 4

	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, QueenInvalidArgument
	beq $v0, -1, QueenInvalidInput
	beq $v0, 0, QueenMoveUnobstructed
	beq $v0, 1, QueenMoveCapture

	
QueenInvalidArgument:
	li $v0, -2
	li $v1, '\0'
	j restoreStackmove

QueenInvalidInput:
	li $v0, -1
	li $v1, '\0'
	j restoreStackmove
	
QueenMoveUnobstructed:

	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'Q'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove
QueenMoveCapture:
#set the empty square FROM to empty
	move $a0, $t0
	move $a1, $t1
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 'Q'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s6
	j restoreStackmove

doHorseMove:
	move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	
	addi $sp, $sp, -4
	move $a3, $sp

	#addi $sp, $sp, -4
	#sw $t9, 0($sp)
		
	jal validKnightMove
	
	lh $s7, 0($sp)
	
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	#addi $sp, $sp, 4

	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, horseInputArgument
	beq $v0, -1, horseInvalidMove
	beq $v0, 0, horseMoveUnobstructed
	beq $v0, 1, horseMoveCapture
	
horseInputArgument:
	li $v0, -2
	li $v1, '\0'
	
	j restoreStackmove
	
horseInvalidMove:
	li $v0, -1
	li $v1, '\0'
	
	j restoreStackmove
	
horseMoveUnobstructed:

	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'H'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove
	
horseMoveCapture:
	#set the empty square FROM to empty
	move $a0, $t0
	move $a1, $t1
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t2
	move $a1, $t3
	li $a2, 'H'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s6
	j restoreStackmove

	
doPawnMove:
	move $a0, $s1
	move $a1, $s2
	move $a2, $s0
	#move $a3, $s4
	#li $t9, 'P'
	addi $sp, $sp, -8
	#sw $t9, 0($sp)
		
	jal validPawnMove	
	
	addi $sp, $sp, 8
	
	move $s5, $v1	# this is the piece if captured
	
	beq $v0, -2, pawnInputArgument
	beq $v0, -1, pawnInvalidMove
	beq $v0, 0, pawnMoveUnobstructed
	beq $v0, 1, pawnMoveCapture
	
pawnInputArgument:
	li $v0, -2
	li $v1, '\0'
	j restoreStackmove

pawnInvalidMove:
	li $v0, -1
	li $v1, '\0'
	j restoreStackmove

pawnMoveUnobstructed:
	
	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'P'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 0
	li $v1, '\0'
	
	j restoreStackmove
	
pawnMoveCapture:
	#set the empty square FROM to empty
	move $a0, $t2
	move $a1, $t3
	li $a2, 'E'
	move $a3, $s6
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	move $a0, $t0
	move $a1, $t1
	li $a2, 'P'
	move $a3, $s0
	
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	
	jal setSquare
	
	addi $sp, $sp, 4
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	
	addi $sp, $sp, 16
	
	
	li $v0, 1
	move $v1, $s7
	j restoreStackmove

wrongPlayerMove:
	li $v0, -2
	li $v1, '\0'
	j restoreStackmove
	
invalidMoveMove:
	li $v0, -1
	li $v1, '\0'
	j restoreStackmove



restoreStackmove:
	lw $ra, 0($sp)	#	
	lw $s0, 4($sp)	#	player
	lw $s1, 8($sp)	# 	short from
	lw $s2, 12($sp)	#	short to
	lw $s3, 16($sp)	#	byte fg
	lw $s4, 20($sp)	#	short& king_position
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	
	jr $ra
	
	
##########################################
#  Part #3 Function
##########################################

check:
	li $v0, 0  
	jr $ra
