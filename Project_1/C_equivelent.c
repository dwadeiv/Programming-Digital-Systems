	.text
.equ    LEDs,0xFF200000
.equ    SWITCHES,   0xFF200040
.global _start
_start:
movia   r2, LEDs # Address of LEDs
movia   r3, SWITCHES    # Address of switches
LOOP:
ldwio   r4, (r3)# Read the state of switches# reads r3 into r4

srli r5, r4, 5 #shift 5 bits in r4 and store in r5
andi r6, r4, 0x1F #Anding last r4 with 0b00001111 and storing in r6
add r4, r5, r6 


stwio   r4, (r2)# Display the state on LEDs #store puts r4 into r2
br	LOOP #branch loop
.end