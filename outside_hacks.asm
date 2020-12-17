outside_hacks:

//===========================================================================================
// This hack centers names in the Name/HP/PP boxes when you press Select outside.
//===========================================================================================

.center_names:
push {r2,r4-r5,lr}
ldr  r2,=#0x8D1CF78          // This is the address of the 8x8 font width table
mov  r0,r9
mov  r3,#0
mov  r4,#0
mov  r5,#0xFF
lsl  r5,r5,#8

-
ldrh r3,[r0,#0]
add  r0,#2
cmp  r3,r5
bge  +
ldrb r3,[r2,r3]
add  r4,r4,r3
b -

+
lsr  r4,r4,#1
sub  r3,r1,r4
pop  {r2,r4-r5,pc}


//===========================================================================================
// This hack is used in many places throughout the game. It counts strings and parts of
// strings. We're hacking it here to allow for longer character names and nameable names.
//===========================================================================================

.string_length_count:
push {r2,r4-r7,lr}

mov  r5,#0                   // r5 is our count

mov  r2,#8                   // max length of names in RAM
ldr  r4,=#0x200417E          // Flint's name in RAM = $200417E
cmp  r0,r4
beq  .limited_count

add  r4,#0x6C                // Lucas' name in RAM = $20041EA
cmp  r0,r4
beq  .limited_count

add  r4,#0x6C                // Duster's name in RAM = $2004256
cmp  r0,r4
beq  .limited_count

add  r4,#0x6C                // Kumatora's name in RAM = $20042C2
cmp  r0,r4
beq  .limited_count

add  r4,#0x6C                // Boney's name in RAM = $200432E
cmp  r0,r4
beq  .limited_count

add  r4,#0x6C                // Salsa's name in RAM = $200439A
cmp  r0,r4
beq  .limited_count

add  r4,#0xFC
add  r4,#0xFC
add  r4,#0xFC                // Claus's name in RAM = $200468E
cmp  r0,r4
beq  .limited_count

ldr  r4,=#0x2004EE2          // Hinawa's name in RAM = $2004EE2
cmp  r0,r4
beq  .limited_count

add  r4,#0x10                // Claus's repeated name in RAM = $2004EF2
cmp  r0,r4
beq  .limited_count

mov  r2,#9                   // Japanese version allowed for 9 letters...
add  r4,#0x10                // Fav. Food in RAM = $2004F02
cmp  r0,r4
beq  .limited_count

mov  r2,#8                   // back to 8 letters max
add  r4,#0x12                // Fav. Thing in RAM = $200F414
cmp  r0,r4
beq  .limited_count

mov  r2,#16                  // player's name can be 16 letters
add  r4,#0x12                // Player's name in RAM = $800F426
cmp  r0,r4
beq  .limited_count

b    .unlimited_count

//--------------------------------------------------------------------------------------------

.limited_count:
ldr  r4,=#0xFFFF             // r4 is the [END] code

ldrh r1,[r0,#0]              // load current character
cmp  r1,r4                   // is it an end code?
beq  +                       // if so, end
add  r5,#1                   // otherwise increment our count

cmp  r5,r2                   // check to see if we're >= our RAM name limit
bge  +                       // so quit if the name is too far

add  r0,#2                   // and increment the read address by 2
b    .limited_count          // and loop back

//--------------------------------------------------------------------------------------------

.unlimited_count:
ldr  r4,=#0xFFFF             // r4 is the [END] code

ldrh r1,[r0,#0]              // load the current character
cmp  r1,r4                   // is it an end code?
beq  +                       // if so, end
add  r5,#1                   // otherwise increment our count
add  r0,#2                   // and increment the read address by 1
b    .unlimited_count

//--------------------------------------------------------------------------------------------

+
mov  r0,r5                   // r0 now has the count, as the game expects
pop  {r2,r4-r7,pc}


//===========================================================================================
// This routine is meant to trick the game into using a good size for the gray name boxes.
// This is because we now have a VWF in there, so not everything is 8 pixels wide. We're
// basically gonna calculate up the total width of the name, divide it by 8, and round up
// if there's a remainder. Then we'll do some code we clobbered.
//
// There's a chance we might need to insert another hack elsewhere so that the game will
// use the correct # for the string's length and not our output value here.
//
// This hack should be linked from 8023A10.
//
// r0 starts with the string length
// [sp + 8] contains the address of the current string
//
// the resultant value needs to be stored in r7 before leaving

//===========================================================================================
//===========================================================================================
// This is some routine initialization stuff

.gray_box_resize:
push {r1-r6,lr}

mov  r1,r0                   // r1 has the string length now
mov  r2,#0                   // r2 will be our loop counter
mov  r0,#0                   // r0 will be our width counter
ldr  r5,[sp,#0x24]           // load r5 with the address of the string
ldr  r6,=#0x8D1CF78          // r6 has the address of our 8x8 font width table

//--------------------------------------------------------------------------------------------
// Now we need to do a loop to get the total width of the current string

-
ldrh r3,[r5,#0]              // load the current letter
ldrb r3,[r6,r3]              // load the current letter's width
add  r0,r0,r3                // add the current width to the total width

add  r5,#2                   // increment the read address

add  r2,#1                   // increment the loop counter
cmp  r2,r1                   // compare the loop counter with the string length
bge  +                       // if >= string length, then time to move to the math conv. stuff
b    -

//--------------------------------------------------------------------------------------------

+
mov  r1,#8                    // we're now going to divide the total width (in r0) by 8
swi  #6
cmp  r1,#0                    // r1 now has the remainder, if non-zero, we need to add 1 to r0
beq  +
add  r0,#1                    // add 1 because we used a partial tile in theory

//--------------------------------------------------------------------------------------------

+
mov  r7,r0                    // r7 now has the final result
pop  {r1-r6,pc}
