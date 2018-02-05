saving:
.impede_refresh_oam:
push {r4-r5,lr}
mov r5,r1
ldr r1,=#0x2003F04					//Let's check in our flag what's happening
ldrb r0,[r1,#0]
cmp r0,#1							//If the value is one, then we need to print the text ONE time and set it to - not printing
bne .keep_going
mov r0,#2
strb r0,[r1,#0]						//Sets the flag to - not printing
b .keep_keep


.keep_going:
cmp r0,#2							//Is this 2? If it is, we don't print, but we need to make some check to avoid some stuff...
beq .partially

.keep_keep:
mov r0,pc
add r0,#0xF
mov lr,r0
ldr r0,=#0x8050EED
bx r0

.rest:
ldr r4,=#0x20225DC
ldr r0,=#0x803E6F7
bx r0

.partially:
ldr r4,=#0x2003F08					//This cicle, we don't print a thing...
ldrb r0,[r4,#0]
cmp r0,r12							//Do we need to print the cursor/New text? If we do, r12 will have changed! What a handy register!
beq .keep_partially
ldr r4,=#0x2015D98					//Address that tells us if we're still in the yes/no portion of the summary screen, if we aren't, we don't need to print anything!
ldrb r0,[r4,#0]
mov r4,#2
cmp r0,#2							//If this is 2, the cursor still needs to be printed!
bne +
mov r4,#1							//Reset the flag
+
cmp r0,#0							//The same address goes to 0 every time we enter a new menu, resetting for us and avoiding a lot of problems!
bne +
mov r4,#0							//If this is not 0 or 2, then just keep it 2 and avoid printing!
+
mov r0,r4
ldr r4,=#0x2003F08
sub r4,#4
strb r0,[r4,#0]
add r4,#4
mov r0,r12
b .keep_partially

.keep_partially:
strb r0,[r4,#0]
b .rest