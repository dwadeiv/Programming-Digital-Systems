.text
.global sum_two 
sum_two:
    subi    sp, sp, 8
    stw     r4, 0(sp)
    stw     r5, 4(sp)

    add     r2, r4, r5

    ldw     r4, 0(sp)
    ldw     r5, 4(sp)
    addi    sp, sp, 8
    ret 

.global op_three 
op_three:
    subi sp, sp, 16
    stw ra, 12(sp)
    stw r4, 8(sp)
    stw r5, 4(sp)
    stw r6, 0(sp)

    call op_two
    mov r4, r2
    ldw r6, 0(sp)
    mov r5, r6
    call op_two

    ldw ra, 12(sp)
    ldw r4, 8(sp)
    ldw r5, 4(sp)
    ldw r6, 0(sp)
    addi sp, sp, 12
    ret    

.global fibonacci 
fibonacci:
    beq     r4, r0, fib_zero
    addi    r2, r0, 1
    beq     r4, r2, fib_one

    subi    sp, sp, 12
    stw     ra, 8(sp)
    stw     r17, 4(sp)
    stw     r16, 0(sp)

    add     r16, r4, r0
    subi    r4, r4, 1
    call    fibonacci

    add     r17, r2, r0
    subi    r4, r16, 2
    call    fibonacci
    
    add     r2, r17, r2
    br      End

   fib_zero:
        add     r2, r2, r0
        ret

   fib_one:
        add     r2, r0, 1
        ret

   End:
        ldw     ra, 8(sp)
        ldw     r17, 4(sp)
        ldw     r16, 0(sp)
        addi    sp, sp, 12
        ret 