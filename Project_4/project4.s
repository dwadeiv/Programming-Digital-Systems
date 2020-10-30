/* Memory */
	.equ	SDRAM_BASE,				0x00000000
	.equ	SDRAM_END,				0x03FFFFFF
	.equ	FPGA_ONCHIP_BASE,		0x08000000
	.equ	FPGA_ONCHIP_END,		0x0800FFFF
	.equ	FPGA_CHAR_BASE,			0x09000000
	.equ	FPGA_CHAR_END,			0x09001FFF

/* Devices */
	.equ	LEDR_BASE,				0xFF200000
	.equ	HEX3_HEX0_BASE,			0xFF200020
	.equ	HEX5_HEX4_BASE,			0xFF200030
	.equ	SW_BASE,				0xFF200040
	.equ	KEY_BASE,				0xFF200050
	.equ	JP1_BASE,				0xFF200060
	.equ  	ARDUINO_GPIO,			0xFF200100
	.equ	ARDUINO_RESET_N,		0xFF200110	
	.equ	JTAG_UART_BASE,			0xFF201000
	.equ	TIMER_BASE,				0xFF202000
	.equ	TIMER_2_BASE,			0xFF202020
	.equ	PIXEL_BUF_CTRL_BASE,	0xFF203020
	.equ	CHAR_BUF_CTRL_BASE,		0xFF203030

/*******************************************************************************
 * RESET SECTION
 * Note: "ax" is REQUIRED to designate the section as allocatable and executable.
 * Also, the Debug Client automatically places the ".reset" section at the reset
 * location specified in the CPU settings in SOPC Builder.
 ******************************************************************************/
	.section	.reset, "ax"

	movia	r2, _start
	jmp		r2						# branch to main program

/*******************************************************************************
 * EXCEPTIONS SECTION
 * Note: "ax" is REQUIRED to designate the section as allocatable and executable.
 * Also, the Monitor Program automatically places the ".exceptions" section at 
 * the exception location specified in the CPU settings in SOPC Builder.
 ******************************************************************************/
	.section	.exceptions, "ax"
	.global		EXCEPTION_HANDLER

EXCEPTION_HANDLER:
	subi	sp, sp, 16				# make room on the stack
	stw		et, 0(sp)

	rdctl	et, ctl4
	beq		et, r0, SKIP_EA_DEC		# interrupt is not external

	subi	ea, ea, 4				# must decrement ea by one instruction
									#  for external interrupts, so that the
									#  interrupted instruction will be run
SKIP_EA_DEC:
	stw		ea, 4(sp)				# save all used registers on the Stack
	stw		ra, 8(sp)				# needed if call inst is used*/
	stw		r22, 12(sp)
	
	rdctl	et, ctl4
	bne		et, r0, CHECK_LEVEL_0	# interrupt is an external interrupt*/

NOT_EI:								# exception must be unimplemented instruction or TRAP
	br		END_ISR					# instruction. This code does not handle those cases

CHECK_LEVEL_0:						# interval timer is interrupt level 0
	andi	r22, et, 0b1
	beq		r22, r0, CHECK_LEVEL_1

	call	INTERVAL_TIMER_ISR				
	br		END_ISR

CHECK_LEVEL_1:						# pushbutton port is interrupt level 1
	andi	r22, et, 0b10
	beq		r22, r0, END_ISR		# other interrupt levels are not handled in this code

	call	PUSHBUTTON_ISR				

END_ISR:
	ldw		et, 0(sp)				# restore all used register to previous values
	ldw		ea, 4(sp)					
	ldw		ra, 8(sp)				# needed if call inst is used
	ldw		r22, 12(sp)
	addi	sp, sp, 16

	eret

/*******************************************************************************
 * Interval timer - Interrupt Service Routine
 *
 * Shifts a PATTERN being displayed. The shift direction is determined by the 
 * external variable SHIFT_DIR. Whether the shifting occurs or not is determined
 * by the external variable SHIFT_ON.
 ******************************************************************************/
	.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR: # Prologue
	subi	sp,  sp, 60				# reserve space on the stack
	stw		ra, 0(sp)
	stw		r4, 4(sp)
	stw		r5, 8(sp)
	stw		r6, 12(sp)
	stw		r8, 16(sp)
	stw		r10, 20(sp)
	stw		r20, 24(sp)
	stw		r21, 28(sp)
	stw		r22, 32(sp)
	stw		r23, 36(sp)
	stw		r12, 40(sp)
	stw		r15, 44(sp)
	stw		r11, 48(sp)
	stw		r13, 52(sp)
	stw		r14, 56(sp)
	
	movia	r10, TIMER_BASE			# interval timer base address
	sthio	r0,  0(r10)				# clear the interrupt
	
	movia 	r4,  PATTERN			# Array containing "HELLO BUFFS"
	movia 	r11, PATTERN_ADDRESS
	movia 	r12, POSITION
	movia 	r13, CURRENT_DISPLAY
	movia 	r14, MAX_POSITION
	movia 	r15, HEX3_HEX0_BASE
	ldw		r20, 0(r11)				# PATTERN_ADDRESS
	ldw 	r21, 0(r13)				# CURRENT_DISPLAY
	ldw		r22, 0(r14)  			# MAX_POSITION
	ldw 	r23, 0(r12)				# POSITION

SHIFT_L:
	slli 	r21, r21, 8 	# shift CURRENT_DISPLAY 8 bits to the left to store next letter
	ldw  	r5, (r20) 		# load value from PATTERN
	or   	r21, r21, r5 	# store next letter into first 8 bits of 7 seg register
	stw  	r21, 0(r13) 	# save CURRENT_DISPLAY
	addi 	r20, r20, 4 	# add 4 to PATTERN_ADDRESS for offset to get next value
	stw  	r20, 0(r11) 	# save r20
	addi 	r23, r23, 4 	# add 4 to POSITION
	stw  	r23, 0(r12) 	# save updated POSITION
	beq  	r23, r22, RESET
	br   	STORE_PATTERN

RESET:
	stw  	r0, 0(r12) # reset POSITION 
	subi  	r20, r20, 72 # subtract 76 to get back to base address of array
	stw  	r20, 0(r11)
	mul     r21, r21, r0 # Blank the display
	
STORE_PATTERN:
	stwio  	r21, 0(r15)

END_INTERVAL_TIMER_ISR: # Epilogue
	ldw		ra, 0(sp)				# restore registers
	ldw		r4, 4(sp)
  	ldw		r5, 8(sp)
	ldw		r6, 12(sp)
	ldw		r8, 16(sp)
	ldw		r10, 20(sp)
	ldw		r20, 24(sp)
	ldw		r21, 28(sp)
	ldw		r22, 32(sp)
	ldw		r23, 36(sp)	
	ldw		r12, 40(sp)
	ldw		r15, 44(sp)
	ldw		r11, 48(sp)
	ldw		r13, 52(sp)
	ldw		r14, 56(sp)
	addi	sp,  sp, 60				# release the reserved space on the stack

	ret

/******************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine checks which KEY has been pressed and updates the global
 * variables as required.
 ******************************************************************************/
	.global	PUSHBUTTON_ISR
PUSHBUTTON_ISR: # Prologue
	subi	sp, sp, 60				# reserve space on the stack
	stw		ra, 0(sp)
	stw		r2, 4(sp)
	stw		r3, 8(sp)
	stw		r4, 12(sp)
	stw		r5, 16(sp)
	stw		r6, 20(sp)
	stw		r7, 24(sp)
	stw		r8, 28(sp)
	stw		r9, 32(sp)
	stw		r10, 36(sp)
	stw		r11, 40(sp)
	stw		r12, 44(sp)
	stw		r13, 48(sp)
	stw 	r14, 52(sp)
	stw		r15, 56(sp)

	movia	r10, KEY_BASE			# base address of pushbutton KEY parallel port
	movia 	r14, CURRENT_RATE		# current rate at which the program is running 
	movia	r16, TIMER_BASE			# store interval timer base address
	
	# Following speeds are in descending order
	movi	r3, 1	# SLOWEST
	movi 	r4, 2	
	movi 	r5, 3
	movi 	r6, 4	# DEFAULT
	movi 	r7, 5
	movi	r8, 6
	movi 	r9, 7	# FASTEST

	ldwio	r11, 0xC(r10)			# read edge capture register
	stwio	r11, 0xC(r10)			# clear the interrupt
	ldw 	r15, 0(r14)	  

CHECK_KEY0:	# Speed up Scrolling
	andi	r13, r11, 0b0001				# check KEY0
	beq		r13, zero, CHECK_KEY1
	beq 	r15, r9, END_PUSHBUTTON_ISR 	# If already at the max speed
	addi	r15, r15, 1						# Add 1 from CURRENT_RATE
	br SPEED_HANDLER

CHECK_KEY1:	# Slow down scrolling
	andi	r13, r11, 0b0010				# check KEY1
	beq		r13, zero, END_PUSHBUTTON_ISR
	beq 	r15, r3, END_PUSHBUTTON_ISR 	# If already at the min speed
	subi	r15, r15, 1						# Subtract 1 from CURRENT_RATE

SPEED_HANDLER:
	stw 	r15, 0(r14)
	beq 	r15, r3, MIN_SPEED
	beq 	r15, r4, SLOWER
	beq 	r15, r5, SLOW
	beq 	r15, r6, NORMAL_SPEED
	beq 	r15, r7, FAST
	beq 	r15, r8, FASTER
	beq 	r15, r9, MAX_SPEED

# All the different rates of oepration
MAX_SPEED:
	movia	r12, 15000000		# 1/(100 MHz) x (1.5 x 10^7) = 150 msec
	br CHANGE_SPEED

FASTER:
	movia	r12, 17500000		# 1/(100 MHz) x (1.75 x 10^7) = 175 msec
	br CHANGE_SPEED

FAST:
	movia	r12, 20000000		# 1/(100 MHz) x (2 x 10^7) = 200 msec
	br CHANGE_SPEED

NORMAL_SPEED:
	movia	r12, 22500000		# 1/(100 MHz) x (2.25 x 10^7) = 225 msec (default speed)
	br CHANGE_SPEED

SLOW:
	movia	r12, 27000000		# 1/(100 MHz) x (2.7 x 10^7) = 270 msec
	br CHANGE_SPEED

SLOWER:
	movia	r12, 30000000		# 1/(100 MHz) x (3 x 10^7) = 300 msec
	br CHANGE_SPEED

MIN_SPEED:
	movia	r12, 35000000		# 1/(100 MHz) x (3.5 x 10^7) = 350 msec
	br CHANGE_SPEED

CHANGE_SPEED:
	sthio	r12, 8(r16)			# store the low half word of counter start value
	srli	r12, r12, 16		# Shift right by 16 bits to get the other half
	sthio	r12, 0xC(r16)		# store the high half word of counter start value
	/* start interval timer, enable its interrupts */
	movi	r15, 0b0111			# START = 1, CONT = 1, ITO = 1 
	sthio	r15, 4(r16)			

END_PUSHBUTTON_ISR: # Epilogue
	ldw		ra, 0(sp)
	ldw		r2, 4(sp)
	ldw		r3, 8(sp)
	ldw		r4, 12(sp)
	ldw		r5, 16(sp)
	ldw		r6, 20(sp)
	ldw		r7, 24(sp)
	ldw		r8, 28(sp)
	ldw		r9, 32(sp)
	ldw		r10, 36(sp)
	ldw		r11, 40(sp)
	ldw		r12, 44(sp)
	ldw		r13, 48(sp)
	ldw 	r14, 52(sp)
	ldw		r15, 56(sp)
	addi	sp,  sp, 60

	ret

/*******************************************************************************
 * This program demonstrates use of interrupts. It
 * first starts an interval timer with 225 msec timeouts, and then enables 
 * Nios II interrupts from the interval timer and pushbutton KEYs
 *
 * The interrupt service routine for the interval timer displays a pattern
 * on the HEX3-0 displays, and rotates this pattern either left or right:
 *		KEY[0]: loads a new pattern from the SW switches
 *		KEY[1]: toggles rotation direction
 ******************************************************************************/

	.text						# executable code follows
	.global _start
_start:
	/* set up the stack */
	movia 	sp, SDRAM_END - 3	# stack starts from largest memory address

	movia	r16, TIMER_BASE		# interval timer base address
	/* set the interval timer period for scrolling the HEX displays */
	movia	r12, 22500000		# 1/(100 MHz) x (2.25 x 10^7) = 225 msec
	sthio	r12, 8(r16)			# store the low half word of counter start value
	srli	r12, r12, 16
	sthio	r12, 0xC(r16)		# high half word of counter start value

	/* start interval timer, enable its interrupts */
	movi	r15, 0b0111			# START = 1, CONT = 1, ITO = 1
	sthio	r15, 4(r16)

	/* write to the pushbutton port interrupt mask register */
	movia	r15, KEY_BASE		# pushbutton key base address
	movi	r7, 0b11			# set interrupt mask bits
	stwio	r7, 8(r15)			# interrupt mask register is (base + 8)

	/* enable Nios II processor interrupts */
	movia	r7, 0x00000001		# get interrupt mask bit for interval timer
	movia	r8, 0x00000002		# get interrupt mask bit for pushbuttons
	or		r7, r7, r8
	wrctl	ienable, r7			# enable interrupts for the given mask bits
	movi	r7, 1
	wrctl	status, r7			# turn on Nios II interrupt processing
	movia r18, PATTERN
	movia r19, PATTERN_ADDRESS
	stw r18, 0(r19)

IDLE:
	br 		IDLE				# main program simply idles

	.data
/*******************************************************************************
 * The global variables used by the interrupt service routines for the interval
 * timer and the pushbutton keys are declared below
 ******************************************************************************/
	.global	PATTERN
PATTERN: #   H     E     L     L     O   blank   b     U     F     F     S     -     -     -   blank blank blank blank
	.word	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7C, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00

	.global PATTERN_ADDRESS
PATTERN_ADDRESS:
	.word 0 # Starting letter of display
	
	.global POSITION
POSITION:
	.word	0 # Start of message display

	.global MAX_POSITION
MAX_POSITION:
	.word 72 # Entire message has been displayed at this position number

	.global CURRENT_DISPLAY
CURRENT_DISPLAY:
	.word 0

	.global CURRENT_RATE
CURRENT_RATE:
	.word 4	 # the number default rate is set to in pushbutton_ISR.s

	.end

