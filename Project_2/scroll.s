.text
	.equ	HEX3_TO_HEX0, 0xFF200020

.global _start
_start:
	movia	r2, HEX3_TO_HEX0    # Stores address of HEX0 to HEX3 in r2
	stwio	r0, 0(r2)           # initially blank display
    mov 	r10, r0             # clears Hex Displays from previous run
	mov 	r11, r0             # clears Hex Displays from previous run
	movia	r3, message         # Stores address of message into r3
	movia	r4, pattern         # Stores address of patter into r4
	movi 	r5, 0               # r5 stores the program's stage
	movia   r6, 1500000         # r6 represents the delay that controlls the speed of the program
	movi 	r7, 18             	# Message scroll done at r5 = 18
	movi	r8, 30             	# Pattern flashing done at r5 = 30
	
DELAY_LOOP:
	subi	r6, r6, 1			# Decrement 1 from r6
	bgt 	r6, r0, DELAY_LOOP	# Call DELAY_LOOP until r6 = 0
	br  	PROGRAM_LOOP
	
PROGRAM_LOOP:
	blt 	r5, r7, MESSAGE_SCROLL     	# Call MESSAGE_SCROLL until r5 = r7
	blt 	r5, r8, PATTERN_FLASHING   	# Call PATTERN_FLASHING until r5 = r8
	br  	RESTART 					# Restart code
	

MESSAGE_SCROLL:
	ldw 	r9, 0(r3)  	 # Load first byte from message into r9
	slli	r10, r10, 8  # Shift r10 by one byte to the left (scrolling)
	or  	r10, r10, r9 # OR byte at the end of r8
	stwio	r10, 0(r2)   # Put r10 on Hex Displays
	addi	r5, r5, 1 	 # Increment stage
	addi	r3,	r3, 4  	 # Increment message address
	movia   r6, 1500000	 # Reset r6 to 1,500,000
	br  	DELAY_LOOP

PATTERN_FLASHING:
	ldw 	r11, 0(r4) 		# Load 32 bit pattern from pattern into r11
	stwio 	r11, 0(r2) 		# Put r11 on Hex Displays
	addi	r5, r5, 1 		# Increment stage
	addi	r4, r4, 4 		# Increment pattern address
	movia   r6, 1500000	 	# Reset r6 to 1,500,000
	br  	DELAY_LOOP

RESTART:
	movia	r3, message  # Reset message address
	movia	r4, pattern  # Reset pattern address
	movi	r5, 0        # Reset statge to 0
	br  	DELAY_LOOP

.data
pattern: #      A           B           A           B           A           B           C         blank         C         blank         C         blank
	.word	0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000, 0x7F7F7F7F, 0x00000000, 
message: #   H     E     L     L     O   blank   b     U     F     F     S     -     -     -   blank blank blank blank
	.word	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7C, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00
.end