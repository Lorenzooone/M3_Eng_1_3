naming_screen_hacks:

// ==============================================
// These hacks align the bullets correctly
// on the naming screens.
// ==============================================

.bullets1:
cmp  r4,#0
bne  +
mov  r1,#4
add  r1,r8
bx   lr
+
mov  r1,#3
add  r1,r1,r2
bx   lr

.bullets2:
ldr  r1,=#0x8D1CF78
add  r3,#1
lsl  r3,r3,#1
sub  r2,r2,r3
-
ldrh r3,[r2,#0]
add  r2,#2
cmp  r3,#0xFF
bgt  +
ldrb r3,[r1,r3]
add  r7,r7,r3
b    -
+
sub  r1,r7,#1
bx   lr


// ==============================================
// These hacks make the factory screen load the
// sanctuary name.
// ==============================================

.factload1:

mov  r1,#0x00
//orr  r0,r1  // no longer needed

// Check the naming screen type
ldr  r4,=#0x201AA58
ldrb r4,[r4,#0]
cmp  r4,#0xE
bne  +
ldr  r1,=#0x2004F26
-
ldrb r4,[r1,#0]
add  r1,r1,#2
cmp  r4,#0xFF
beq  +
add  r0,r0,#1
b    -
+
bx   lr

.factload2:
// Check the naming screen type
ldr  r4,=#0x201AA58
ldrb r4,[r4,#0]
cmp  r4,#0xE
bne  .factload2_end
ldr  r3,=#0x2004F26
mov  r4,#0
-
ldrb r6,[r3,#0]
add  r3,r3,#2
cmp  r6,#0xFF
beq  +
strh r6,[r5,r4]
add  r4,r4,#2
b    -
+
lsr  r4,r4,#1
//ldrb r6,[r7,#0]
//add  r6,r6,r4
//strb r6,[r7,#0]
strb r4,[r7,#0]
.factload2_end:
pop  {r3-r5}
mov  r8,r3
bx   lr


// ==============================================
// These hacks display the player name properly
// in the staff credits.
// ==============================================

// This one loads the correct upper letter tile
.credits1:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
ldr  r1,=#0x9F86140
lsl  r0,r0,#1
ldrh r1,[r1,r0]
pop  {pc}

// This one loads the correct lower letter tile
.credits2:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
ldr  r1,=#0x9F86140
lsl  r2,r5,#1
ldrh r1,[r1,r2]
add  r1,#0x20
pop  {pc}

// This one makes it read from the correct address
.credits3:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
mov  r1,#0x1B
lsl  r1,r1,#6
add  r1,r1,#6
add  r2,r1,r0
pop  {pc}


//=====================================================================================
// This function completely fixes up the cursor coord crap on naming screens.
//=====================================================================================

.cursor_lookup_tables:
incbin data_namingcursors.bin

.cursor_megafix:
push {r3-r7,lr}

// ---------------------------------------
// Get the current value
ldrb r7,[r0,#0]            // r7 = current cursor value
// ---------------------------------------
// Get the layout type
ldr  r6,=#0x201AA58
ldrb r6,[r6,#0]
cmp  r6,#0xD
beq  +
cmp  r6,#0xE
beq  +
mov  r6,#0
b    .cursor_megafix_jump1
+
mov  r6,#1
.cursor_megafix_jump1:     // r6 = layout type (0 = normal, 1 = sans dont care)
// ---------------------------------------
// Get the arrow direction
ldrh r5,[r1,#2]
mov  r4,#0xF0
and  r5,r4
cmp  r5,#0
beq  .cursorfix_end        // Return only if no arrow keys are pressed whatsoever
lsr  r5,r5,#5              // {10, 20, 40, 80} is now {0, 1, 2, 4}
cmp  r5,#4
blt  +
mov  r5,#3                 // {0, 1, 2, 4} is now {0, 1, 2, 3}
+                          // r5 = arrow direction (0 = right, 1 = left, 2 = up, 3 = down)
// ---------------------------------------
// Play the sound effect
push {r0-r3}
lsr  r0,r5,#1              // r3 = 0 for right,left; 1 for up,down
mov  r2,#1
eor  r0,r2                 // r3 = 1 for right,left; 0 for up,down
add  r0,#0xD0
bl   $800399C
pop  {r0-r3}
// ---------------------------------------
// Get table address
mov  r3,#0x69
ldr  r4,=#.cursor_lookup_tables
mul  r6,r3
lsl  r6,r6,#2              // r6 *= 0x1A4
mul  r5,r3                 // r5 *= 0x69
add  r4,r4,r5
add  r4,r4,r6
// ---------------------------------------
// Load the new value and store it
ldrb r4,[r4,r7]
// If r4 == #0xFF, something went wrong, let jeffmeister know
strb r4,[r0,#0]
// ---------------------------------------
// Finished
.cursorfix_end:
pop  {r3-r7,pc}


//--------------------------------------------------------
//                 New summary hacks!
//--------------------------------------------------------

summary_hacks:

//First part of the new hacks

.impede_refresh_oam:
push {r4-r5,lr}
mov r5,r1
ldr r1,=#0x2003F04                  //Let's check in our flag what's happening
ldrb r0,[r1,#0]
cmp r0,#1                           //If the value is one, then we need to print the text ONE time and set it to - not printing
bne .keep_going
mov r0,#2
strb r0,[r1,#0]                     //Sets the flag to - not printing
b .keep_keep


.keep_going:
cmp r0,#2                           //Is this 2? If it is, we don't print, but we need to make some checks to avoid some stuff...
beq .partially

.keep_keep:
bl $8050EED                         //This is the standard OAM refreshing routine, call it in case it's 1 or 0, since we need to print

.rest:
pop {r4-r5,pc}

.partially:
ldr r4,=#0x2003F08                  //This cicle, we don't print a thing...
ldrb r0,[r4,#0]
cmp r0,r12                          //Do we need to print the cursor/New text? If we do, r12 will have changed! What a handy register!
beq .handy_check
ldr r4,=#0x2015D98                  //Address that tells us if we're still in the yes/no portion of the summary screen, if we aren't, we don't need to print anything!
ldrb r0,[r4,#0]
mov r4,#2
cmp r0,#2                           //If this is 2, the cursor still needs to be printed!
bne +
mov r4,#1                           //Reset the flag
+
cmp r0,#0                           //The same address goes to 0 every time we enter a new menu, resetting for us and avoiding a lot of problems!
bne +
mov r4,#0                           //If this is not 0 or 2, then just keep it 2 and avoid printing!
+
mov r0,r4
ldr r4,=#0x2003F08
sub r4,#4
strb r0,[r4,#0]                     //Let's store the updated status of the printing flag!
add r4,#4
mov r0,r12
strb r0,[r4,#0]                     //Let's store the cursor's current status, to see if we have to update the next time or not

.handy_check:
cmp r0,#1
beq +
cmp r0,#0x1A                       //If this isn't 0x1A or 0x1, we're not in the summary screen! Let's store 0. This is to prevent some possible glitches.
beq +
mov r0,#0
sub r4,#4
strb r0,[r4,#0]
+
b .rest

//--------------------------------------------------------------------------------------------------

//Second part of the new hacks

.flag_reset:
push {lr}
cmp r0,#0x4F                                    //Summary's arrangement is being loaded?
bne .NotCycle

.Fix_Copy_Bug:                                 //Let's manually fix the save coping bug while we're at it
ldr r1,=#0x2004F80
mov r5,#0
str r5,[r1,#0]
str r5,[r1,#4]
str r5,[r1,#0x1C]
strh r5,[r1,#0x20]
ldr r5,=#0x880                                   //Reset PSI flags
add r1,#0x1A
strh r5,[r1,#0]
//ldr r1,=#0x2004947
//mov r5,#0
//strb r5,[r1,#0]
//str r5,[r1,#4]                                  //Reset Duster's items
ldr r1,=#0x20041B0                              //Reset Equipments, Flint
ldr r5,=#0x0410000
str r5,[r1,#0]
add r1,#0x6C                                    //Next character, Lucas
mov r5,#0
str r5,[r1,#0]
add r1,#0x6C                                    //Next character, Duster
ldr r5,=#0x4E002516
str r5,[r1,#0]
add r1,#0x6C                                    //Next character, Kumatora
ldr r5,=#0x4F46B50D
str r5,[r1,#0]
add r1,#0x6C                                    //Next character, Boney
ldr r5,=#0x2E00
str r5,[r1,#0]
add r1,#0x6C                                    //Next character, Salsa
mov r5,#0
str r5,[r1,#0]

.Flag_Stuff:
ldr r1,=#0x2003F04                              //Flag
mov r5,#1
strb r5,[r1,#0]                                 //Set the flag
mov r5,#0
b .ending

.NotCycle:
ldr r1,=#0x2003F04                              //Reset the Flag
mov r5,#0
strb r5,[r1,#0]
b .ending

.ending:
mov r1,r0
lsl r1,r1,#0x10                                 //Stuff the game does
pop {pc}                                        //Return to the cycle

//---------------------------------------------------------------------------------------------------

//Third part of the new hacks

.check_change_and_stop_OAM:
push {r1-r3, lr}
mov r2,r0 //Load cursor's position
ldrh r1,[r2,#4]
lsl r2,r1,#2
add r2,r2,r1
lsl r2,r2,#0x13
mov r1,#0xA0
lsl r1,r1,#0xF
add r2,r2,r1
asr r2,r2,#0x10 //Cursor's position is loaded into r2

ldr r1,=#0x2003F00
ldrb r3,[r1,#0]
cmp r3,r2
beq .check_ending
ldrb r3,[r1,#4]                      //Load our flag
cmp r3,#2                            //Is it set to -not printing?
bne +
mov r3,#1                            //If it is, set it to printing, the cursor just changed position!
strb r3,[r1,#4]
+
strb r2,[r1,#0]                      //Store the new position of the cursor

.check_ending:
ldrb r3,[r1,#4]
cmp r3,#2 //If set to not printing, don't create the OAM entries if in a specific moment
bne .normalEnd
ldr r2,=#0x2015D98 //Do we need to print?
ldrb r3,[r2,#0]
cmp r3,#2
beq .oneBeforeEnd
.gotoEnd:
pop {r4-r6} //Clear the stack
pop {r4}
bl $8042F43

.oneBeforeEnd: //Called during the Yes/No choice. Unless we need to print, let's only create the OAM entry we need for timing purposes: the cursor
mov r7,r10
mov r6,r9
mov r5,r8
pop {r1-r3} //Normal stuff the game does
pop {r1}
push {r5-r7}
add sp,#-8
mov r10,r0
mov r4,#0x94 //Properly setup registers
ldr r5,=#0x201AB1A
mov r6,#0xC0
sub r6,r5,r6
mov r7,#0xF
mov r8,r7
mov r7,#0
sub r7,#1
mov r9,r7
mov r7,#1

bl $8042F17 //Do the cursor's routine

.normalEnd:
mov r7,r10
mov r6,r9
pop {r1-r3, pc} //Normal stuff the game does

//--------------------------------------------------------------------------------------------------

//Rearrange graphics for is this okay

.change_is_this_okay:
push {lr}
ldr r1, =#0x600F414 								//Arrangement bytes to change
ldrb r2,[r1,#0]
cmp r2,#0x3B
beq +

mov r2,#0x3B										//Top row of "Is this okay?"
mov r3,#33
lsl r3,r3,#8
add r2,r2,r3
strh r2,[r1,#0]
add r2,#1
strh r2,[r1,#2]
add r2,#1
strh r2,[r1,#4]
add r2,#2
add r1,#8
strh r2,[r1,#0]
sub r2,#0x42
strh r2,[r1,#4]

mov r2,#0x5B										//Bottom row of "Is this okay?"
add r2,r2,r3
ldr r1,=#0x600F454
strh r2,[r1,#0]
add r2,#1
strh r2,[r1,#2]
add r2,#1
strh r2,[r1,#4]
add r2,#1
strh r2,[r1,#6]
add r2,#1
add r1,#8
strh r2,[r1,#0]
sub r2,#0x21
strh r2,[r1,#2]
sub r2,#0x21
strh r2,[r1,#4]

mov r2,#0x4A										//Top row of "Yes No"
add r2,r2,r3
ldr r1,=#0x600F496
strh r2,[r1,#0]
add r2,#1
strh r2,[r1,#2]
add r1,#0xA
sub r2,#0x4F
strh r2,[r1,#0]
sub r2,#0x25
strh r2,[r1,#2]

mov r2,#0x6A										//Bottom row of "Yes No"
add r2,r2,r3
ldr r1,=#0x600F4D6
strh r2,[r1,#0]
add r2,#1
strh r2,[r1,#2]
sub r2,#2
strh r2,[r1,#4]
add r1,#0xA
sub r2,#0x4D
strh r2,[r1,#0]
sub r2,#0x25
strh r2,[r1,#2]

+
pop {pc}								//Return to normal cycle