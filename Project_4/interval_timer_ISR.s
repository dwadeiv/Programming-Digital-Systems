	.include "address_map_nios2.s"
	.extern	PATTERN					# externally defined variables
	.extern POSITION
	.extern MAX_POSITION
	.extern PATTERN_ADDRESS
	.extern CURRENT_DISPLAY
/*******************************************************************************
 * Interval timer - Interrupt Service Routine
 *
 * Shifts a PATTERN being displayed. The shift direction is determined by the 
 * external variable SHIFT_DIR. Whether the shifting occurs or not is determined
 * by the external variable SHIFT_ON.
 ******************************************************************************/
	.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR: # Prologue
	subi	sp,  sp, 40				# reserve space on the stack
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
	
	movia	r10, TIMER_BASE			# interval timer base address
	sthio	r0,  0(r10)				# clear the interrupt
	
	movia 	r10, PATTERN			# Array containing "HELLO BUFFS"
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
	movia 	r12, 0 			# reset POSITION to 0
	subi  	r21, r21, 76 	# subtract 76 to get back to base address of array
	stw  	r21, 0(r11)

STORE_PATTERN:
	stw  	r20, 0(r15)

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
	addi	sp,  sp, 40				# release the reserved space on the stack

	ret
	.end	