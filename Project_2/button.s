.text
	.equ	HEX3_TO_HEX0, 0xFF200020
    .equ    PUSHBUTTONS, 0xFF200050
	
.global _start
_start:
    movia r2, HEX3_TO_HEX0      # Stores address of HEX0 to HEX3 in r2
    movia r3, PUSHBUTTONS       # Stores address of KEYs to r3
    stwio r0, 0(r2)             # initially blank dispay
    mov 	r11, r0             # clears Hex Displays from previous run
	mov 	r13, r0             # clears Hex Displays from previous run
    movia r4, pattern_1         # Stores address of pattern_1 into r4
    movia r5, pattern_2         # Stores address of pattern_2 into r5
    movi  r6, 0                 # r6 stores the program's stage
    movi  r8, 8                 # pattern_1 scroll done at r5 = r8
    movi  r9, 8                 # pattern_1 scroll done at r5 = r9
	movi r15, 0				    # Direction of program 0 = left; 1 = right
	movi r16, 0					# Button Previously pressed
	
RESET_DELAY:
	movia   r7, 1500000	        # Reset r7 to 1,500,000
   
DELAY_LOOP: 
    subi r7, r7, 1              #Decrement 1 from r7
    bgt  r7, r0, DELAY_LOOP     #Call DELAY_LOOP until r6 = 0

DIRECTION:
    ldwio r10, 0(r3)                # Load pushbttons address into r10
# if (buttonPressed) {
#    if (! buttonWasPreviouslyPressed) {
#.       buttonPreviouslyPressed = 1;
#.       Direction = ! Direction;
#.       break;
#	 }
# } else {
#    buttonPreviouslyPressed = 0;
# }
	beq r10, r0, ButtonNotPressed
	bne r16, r0, ButtonTakeNoAction
	xori r15, r15, 1  # Switch direction
	movi r16, 1
	br  RESTART
	
ButtonNotPressed:
	mov r16, r0

ButtonTakeNoAction:	
	bne r15, r0, P2_LOOP        # If Direction = Right, enter P2_SCROLL
    br P1_LOOP                   # Else Call P1_LOOP

P1_LOOP:
    blt     r6, r8, P1_SCROLL   # Call P1_SCROLL until r6 = r8
    br      RESTART

P1_SCROLL:
	ldw 	r10, 0(r4)  	    # Load first byte from pattern_1 into r10
	slli	r11, r11, 8         # Shift r11 by one byte to the left (scrolling)
	or  	r11, r11, r10       # OR byte at the end of r8
	stwio	r11, 0(r2)          # Put r11 on Hex Displays
	addi	r6, r6, 1 	        # Increment stage
	addi	r4,	r4, 4  	        # Increment pattern_1 address
	br  	RESET_DELAY

P2_LOOP:
    blt     r6, r9, P2_SCROLL  # Call P2_SCROLL until r6 = r9
    br      RESTART

P2_SCROLL:
	ldw 	r12, 0(r5)  	    # Load first byte from pattern_2 into r12
    slli	r12, r12, 24        # puts pattern_2 to far left off screen
	srli	r13, r13, 8         # Shift r13 by one byte to the right (scrolling)
	or  	r13, r13, r12       # OR byte at the end of r8
	stwio	r13, 0(r2)          # Put r12 on Hex Displays
	addi	r6, r6, 1 	        # Increment stage
	addi	r5,	r5, 4  	        # Increment pattern_2 address
	br  	RESET_DELAY

RESTART:
	movia	r4, pattern_1  # Reset pattern_1 address
	movia	r5, pattern_2  # Reset pattern_2 address
	movi	r6, 0          # Reset statge to 0
    movi    r11, 0
    movi    r13, 0
	br  	RESET_DELAY
 
.data
pattern_1:
	.word	0x79, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
pattern_2:
    .word   0x4F, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
.end