
.flag_reset:
cmp r0,#0x4F
bne .NotCycle
ldr r1,=#0x2003F04 								//Flag
mov r5,#1
strb r5,[r1,#0]									//Set the flag
mov r5,#0
b .ending

.NotCycle:
ldr r1,=#0x2003F04 								//Reset the Flag
mov r5,#0
strb r5,[r1,#0]
b .ending

.ending:
mov r1,r0
ldr r0,=#0x9B8FFC0								//Normal stuff the game does
lsl r1,r1,#0x10
lsr r1,r1,#0x10
ldr r5,=#0x804A2F1								//Return to the cycle
bx r5