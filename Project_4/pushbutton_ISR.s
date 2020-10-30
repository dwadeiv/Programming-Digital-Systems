	.include "address_map_nios2.s"
	.extern CURRENT_RATE
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
	movi	r3, 1	# FASTEST
	movi 	r4, 2	
	movi 	r5, 3
	movi 	r6, 4	# DEFAULT
	movi 	r7, 5
	movi	r8, 6
	movi 	r9, 7	# SLOWEST

	ldwio	r11, 0xC(r10)			# read edge capture register
	stwio	r11, 0xC(r10)			# clear the interrupt
	ldw 	r15, 0(r14)	  

CHECK_KEY0:	# Speed up Scrolling
	andi	r13, r11, 0b0001				# check KEY0
	beq		r13, zero, CHECK_KEY1
	beq 	r15, r9, END_PUSHBUTTON_ISR 	# If already at the min speed
	addi	r15, r15, 1						# Add 1 from CURRENT_RATE
	br SPEED_HANDLER

CHECK_KEY1:	# Slow down scrolling
	andi	r13, r11, 0b0010				# check KEY1
	beq		r13, zero, END_PUSHBUTTON_ISR
	beq 	r15, r3, END_PUSHBUTTON_ISR 	# If already at the max speed
	subi	r15, r15, 1						# Subtract 1 from CURRENT_RATE

SPEED_HANDLER:
	stw 	r15, 0(r14)
	beq 	r15, r3, MAX_SPEED
	beq 	r15, r4, FASTER
	beq 	r15, r5, FAST
	beq 	r15, r6, NORMAL_SPEED
	beq 	r15, r7, SLOW
	beq 	r15, r8, SLOWER
	beq 	r15, r9, MIN_SPEED 

# All the different rates of oepration
MAX_SPEED:
	movia	r12, 10000000		# 1/(100 MHz) x (1 x 10^7) = 100 msec
	br CHANGE_SPEED

FASTER:
	movia	r12, 15000000		# 1/(100 MHz) x (1.5 x 10^7) = 150 msec
	br CHANGE_SPEED

FAST:
	movia	r12, 20000000		# 1/(100 MHz) x (2 x 10^7) = 200 msec
	br CHANGE_SPEED

NORMAL_SPEED:
	movia	r12, 22500000		# 1/(100 MHz) x (2.25 x 10^7) = 225 msec (default speed)
	br CHANGE_SPEED

SLOW:
	movia	r12, 25000000		# 1/(100 MHz) x (2.5 x 10^7) = 250 msec
	br CHANGE_SPEED

SLOWER:
	movia	r12, 30000000		# 1/(100 MHz) x (3 x 10^7) = 300 msec
	br CHANGE_SPEED

MIN_SPEED:
	movia	r12, 32500000		# 1/(100 MHz) x (3.25 x 10^7) = 325 msec
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
	.end	