main_menu_hacks:

//=============================================================================================
// This set of hacks makes the game load and display long strings on main menu stuff correctly.
//=============================================================================================

.write_item_text:
push {r0-r1,lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
pop  {r0}
str  r0,[sp,#0xC]            // clobbered code
ldr  r0,[r4,#0x0]
pop  {r1,pc}
//

+
ldr  r0,=#0x2013070          // starting address of our item names in RAM
mov  r1,#0x58                // # of max letters per item * 4, since each letter has 4 bytes for some reason
mul  r1,r6                   // r6 has the current item counter, which is nice and convenient for us
add  r0,r0,r1                // r2 now has the proper spot in RAM for the item

pop  {r1}                    // get the address the game would write to normally
str  r0,[r1,#0x0]            // r0 leaves with the new address in RAM for longer names yay

str  r0,[sp,#0xC]            // clobbered code
ldr  r0,[r4,#0x0]
pop  {r1,pc}

//=============================================================================================

.write_item_eos:
push {lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r1,=#0x2013070
mov  r0,r10
sub  r0,#1
mov  r2,#0x58
mul  r0,r2
add  r1,r0,r1
lsl  r6,r6,#2
add  r1,r1,r6
mov  r0,#1
neg  r0,r0
str  r0,[r1,#0]

+
mov  r1,r10                  // clobbered code
lsl  r0,r1,#0x10
pop  {pc}

//=============================================================================================

.clear_data:
push {r2-r3,lr}

// custom jeff code
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
beq  +
//

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x2013060
ldr  r2,=#0x908

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

add  sp,#4
+
mov  r0,#0xD8 // I assume this is clobbered code?
lsl  r0,r0,#0x7
pop  {r2-r3,pc}

//=============================================================================================

.check_for_eos:
push {r5,lr}

// custom jeff code
ldr  r5,=#0x201A288
ldrb r5,[r5,#0]
cmp  r5,#6
beq  +
//

mov  r1,#1
neg  r1,r1                   // r1 = FFFFFFFF
ldr  r0,[r6,#0x0]            // load the value
cmp  r0,r1                   // if they're not equal, we're not at end of string, so leave
bne  +

ldr  r6,=#0x2013060
mov  r1,#0
strb r1,[r6,#0x4]            // swap_address = false

ldr  r6,[r6,#0x0]            // load the real address that pointed to this string
add  r6,#4                   // move it to the next spot

+
ldr  r0,[r6,#0x0]            // load the real next value
lsl  r0,r0,#0x14             // clobbered code
pop  {r5,pc}

//=============================================================================================

.get_ram_address2:
push {lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r1,=#0x2013060          // temporary address storage
ldrb r0,[r6,#0x4]            // load address_swap
cmp  r0,#0
bne  +

str  r6,[r1,#0x0]            // store the address in temporary storage
ldr  r6,[r6,#0x0]            // switch the read address to our custom address

mov  r0,#0x1
strb r0,[r1,#0x4]            // address_swap = TRUE

+
ldr  r0,[r6,#0x0]            // original code
lsl  r0,r0,#0x10
pop  {pc}

//=============================================================================================

.clear_swap_flag:
push {lr}

// custom jeff code
ldr  r3,=#0x201A288
ldrb r3,[r3,#0]
cmp  r3,#6
beq  +
//

mov  r0,#0
ldr  r3,=#0x2013060
strb r0,[r3,#0x4]            // swap_address = false for future callings

+
ldr  r3,=#0x25F4             // clobbered code
add  r0,r4,r3
pop  {pc}

//=============================================================================================

.check_special_bit:
push {r2,lr} // why are you pushing r2? :P
strh r1,[r6,#2]              // original code
ldr  r0,[r4,#0]

// custom jeff code
// maybe this is why :O
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
beq  +
//

ldr  r0,[r0,#0]              // load the first letter data of the real text in
+
pop  {r2,pc}

//=============================================================================================

.store_total_letters:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r2,=#0x2013040
ldrh r0,[r2,#0]              // load the current letter total
add  r0,#1
strh r0,[r2,#0]              // increment and store the letter total back
bx   lr

+
ldrb r0,[r1,#0] // clobbered code
add  r0,#1
strb r0,[r1,#0]
bx   lr

//=============================================================================================

// 2013040  halfword  total # of letters
// 2013041  ...
// 2013042  byte      total # of passes that will be needed
// 2013043  byte      current pass #
// this routine initializes most of this stuff

.write_group_lengths:
push {r2-r4,lr}

// custom jeff code
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
bne  +
ldrb r0,[r0,#0] // clobbered code
lsr  r1,r0,#2
pop  {r2-r4,pc}
//

+
ldr  r4,=#0x2013040          // custom area of RAM for this is here
mov  r2,#0
strh r2,[r4,#2]              // total # of passes = 0, current pass = 0
str  r2,[r4,#0x10]           // now clear out the pass info on the next line
str  r2,[r4,#0x14]           // now clear out the pass info on the next line
str  r2,[r4,#0x18]           // now clear out the pass info on the next line
str  r2,[r4,#0x1C]           // now clear out the pass info on the next line

ldrh r0,[r4,#0]              // load the total # of letters
mov  r1,#40                  // total # of glyph buffers the game allows
swi  #6                      // total letters / 40, r0 = result, r1 = remainder

mov  r3,r0                   // r3 will be our total # of passes
mov  r0,#40                  // each normal pass will have 40 letters
mov  r2,#0                   // start our loop at 0
add  r4,#0x10                // move r4 to the pass info line

-
cmp  r2,r3
bge  +
strb r0,[r4,r2]              // store normal pass length
add  r2,#1
b    -                       // loop back, this is like a small for loop

+
cmp  r1,#0                   // check that remainder
beq  +                       // if remainder == 0, don't need to add an extra pass

add  r3,#1
strb r1,[r4,r2]              // add the extra final pass length

+
sub  r4,#0x10
strb r3,[r4,#2]              // store the total # of passes
ldrh r0,[r4,#0]              // load the total # of letters
lsr  r1,r0,#4                // original code, divides total # of letters by 16
pop  {r2-r4,pc}

//=============================================================================================

.load_curr_group_length1:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
ldrb r0,[r5,#0] // clobbered code
lsl  r0,r0,#0x1D
lsr  r0,r0,#0x1D
ldr  r2,=#0x76D2
add  r1,r4,r2
add  r0,r0,r1
ldrb r1,[r0,#0]
bx   lr
//
+
ldr  r0,=#0x2013040
ldrb r1,[r0,#3]              // get the current pass #
add  r0,#0x10
ldrb r1,[r0,r1]              // load the current length of the current group
bx   lr

//=============================================================================================

.load_curr_group_length2:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
add  r0,r4,r3 // clobbered code
ldrb r0,[r0,#0]
bx   lr
//
+
ldr  r0,=#0x2013040          // address of our group length array is this + 10
ldrb r1,[r0,#3]              // load the current pass #
mov  r3,r1
//add  r3,r1,#1
//strb r3,[r0,#3]              // increment the pass #

add  r0,#0x10                // move to the array now
ldrb r0,[r0,r1]              // load the proper group length, this is still tricky business though
bx   lr

//=============================================================================================

.group_add_check:
push {r2-r3}
// custom jeff code
ldr  r3,=#0x201A288
ldrb r3,[r3,#0]
cmp  r3,#6
bne  +
add  r0,#1 // clobbered code
mov  r1,#7
pop  {r2-r3}
bx   lr
//

+
mov  r3,#0                   // this will be r0's final default result

ldr  r2,=#0x2013040          // address of start of counter area
ldrb r1,[r2,#3]              // load the pass #
add  r1,#1                   // increment the pass #
ldrb r0,[r2,#2]              // load the total # of passes

cmp  r1,r0                   // is curr_pass > total_passes?, if so, set r0 to 4 to signal the end
ble  +                       // if it's <= total_passes, skip this extra stuff

mov  r3,#4                   // this will be r0 at the end, it signals the code that items are done
mov  r1,#0                   // set the pass # back to 0
strh r1,[r2,#0]              // set the total length back to 0 so the game won't freak out

+
strb r1,[r2,#3]              // store the new pass #
mov  r0,r3                   // give r0 its proper value that the game expects

mov  r1,#7                   // clobbered code
pop  {r2-r3}
bx   lr





//=============================================================================================
// This hack fixes the string used when you try to sell an item at a shop.
//=============================================================================================

.sell_text:
push {r4-r6,lr}
mov  r6,r8
mov  r0,r7
push {r0,r6}
add  sp,#-0x8

mov  r7,#0x26                // starting x position

// Add the sell string to the shitpile
// First get its address
mov  r0,#0x7D                // using entry #0x7D in menus1
bl   $80486A0                // gets the address of the sell string

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// Set the variables/coords and add it to the shitpile
mov  r5,#0x1
neg  r5,r5
mov  r2,#0xF
str  r2,[sp,#0]
mov  r6,#1
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,r5
bl   $8047CDC

// Add the item string to the shitpile
mov  r0,r8                   // pos += width of last string
add  r7,r7,r0

ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C

push {r0}
bl   get_string_width
mov  r8,r0
pop  {r0}

mov  r4,r0
mov  r1,#0xF
str  r1,[sp,#0x0]
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,#0x16
bl   $8047CDC

mov  r0,r8
add  r1,r7,r0

// Add the question mark to the shitpile
ldr  r0,=#.question_mark     // address of a question mark
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC

// Add yes/no to the shitpile
mov  r0,#0x3
bl   $80486A0
mov  r1,#0xF
str  r1,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x44
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC
mov  r0,#0x4
bl   $80486A0
mov  r2,#0xF
str  r2,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x94
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC

add  sp,#0x8
pop  {r3,r4}
mov  r7,r4
mov  r8,r3
pop  {r4-r6,pc}

.question_mark:
dw $001F

//=============================================================================================
// This hack fixes the string used when you try to buy an item at a shop.
//=============================================================================================

.buy_text:
push {r4-r6,lr}
mov  r6,r8
mov  r0,r7
push {r0,r6}
add  sp,#-0x8

mov  r7,#0x26                // starting x position

// Add the buy string to the shitpile
// First get its address
mov  r0,#0x7C                // using entry #0x7C in menus1
bl   $80486A0                // gets the address of the buy string

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// Set the variables/coords and add it to the shitpile
mov  r5,#0x1
neg  r5,r5
mov  r2,#0xF
str  r2,[sp,#0]
mov  r6,#1
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,r5
bl   $8047CDC

// Add the item string to the shitpile
mov  r0,r8                   // pos += width of last string
add  r7,r7,r0

ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C

push {r0}
bl   get_string_width
mov  r8,r0
pop  {r0}

mov  r4,r0
mov  r1,#0xF
str  r1,[sp,#0x0]
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,#0x16
bl   $8047CDC

mov  r0,r8
add  r1,r7,r0

// Add the question mark to the shitpile
ldr  r0,=#.question_mark     // address of a question mark
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC

// Add yes/no to the shitpile
mov  r0,#0x3
bl   $80486A0
mov  r1,#0xF
str  r1,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x44
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC
mov  r0,#0x4
bl   $80486A0
mov  r2,#0xF
str  r2,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x94
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC

add  sp,#0x8
pop  {r3,r4}
mov  r7,r4
mov  r8,r3
pop  {r4-r6,pc}

//=============================================================================================
// This hack fixes the first frame that appears when you try to use an item.
//=============================================================================================

//.setup_block_use_frame1:
//push    {lr}
//ldr     r0,=#0x2003F08 //Don't print menu for the next frame
//mov     r1,#1
//strb    r1,[r0,#0]
//mov     r1,r9
//ldrb    r0,[r1,#0]
//pop     {pc}

//.prevent_printing_maybe:
//push    {lr}
//ldr     r1,=#0x2003F08 //Don't print menu for the next frame
//ldrb    r2,[r1,#0]
//cmp     r2,#1
//bne +
//mov     r2,#0
//strb    r2,[r1,#0]
//mov     r5,#1
//b .end_prevent_printing_maybe
//+
//mov     r5,#0
//.end_prevent_printing_maybe:
//pop     {r1}
//str     r4,[sp,#0]
//str     r5,[sp,#4]
//bx      r1

//.block_normal_use_frame1:
//push    {lr}
//ldr     r0,=#0x2003F08 //Do we need to print this?
//ldrb    r1,[r0,#0]
//cmp     r1,#1
//bne +
//mov     r1,#2
//strb    r1,[r0,#0]
//pop     {r1}
//ldr     r1,=#0x8045E6D //If not, then branch away, we'll have .use_frame1 print instead
//bx      r1
//+
//mov      r0,#0x3E
//bl       $80486A0
//pop     {pc}

//.print_normal_use_frame1:
//push    {lr}
//ldr     r0,=#0x2003F08 //Do we need to print this?
//ldrb    r1,[r0,#0]
//cmp     r1,#2
//bne +
//mov     r1,#1
//strb    r1,[r0,#0]

//push    {r0-r7}
//push    {r5-r6}
//add     sp,#-0x8
//mov     r0,#0x41 // Goods
//bl      $80486A0
//mov     r7,#0x1
//neg     r7,r7
//mov     r6,#0xF
//str     r6,[sp,#0]
//mov     r4,#0x1
//str     r4,[sp,#0x4]
//mov     r1,#0xBF
//mov     r2,#0x07
//mov     r3,r7
//bl      $8047CDC
//add     sp,#0x8
//pop     {r5-r6}
//pop     {r0-r7}

//+
//mov      r0,#0x3E
//bl       $80486A0
//pop     {pc}

//.block_frame1_goods:
//push    {lr}
//ldr     r0,=#0x2003F08 //Do we need to print this?
//ldrb    r1,[r0,#0]
//cmp     r1,#1
//bne +
//mov r1,#2
//strb r1,[r0,#0]
//pop {r1}
//ldr r1,=#0x804045F
//bx r1
//+
//mov      r0,#0x41
//bl       $80486A0
//pop     {pc}

//.use_frame1:
//push    {lr}
//mov     r0,r2
//bl      $8055594 // Call that sets the OAM entries for the text
// Everything from here to the next comment loads the Menu/Use/Give/Drop sprites, so we skip those
//push    {r0-r7}
//push    {r5-r6}
//ldr     r0,=#0x2003F08 //Do we need to print this?
//ldrb    r7,[r0,#0]
//cmp     r7,#1
//bne     .end_use_frame1
//add     sp,#-0x8
//mov     r0,#0x41 // Goods
//bl      $80486A0
//mov     r7,#0x1
//neg     r7,r7
//mov     r6,#0xF
//str     r6,[sp,#0]
//mov     r4,#0x1
//str     r4,[sp,#0x4]
//mov     r1,#0xBF
//mov     r2,#0x07
//mov     r3,r7
//bl      $8047CDC
//mov     r0,#0x3C // Menu
//bl      $80486A0
//mov     r7,#0x1
//neg     r7,r7
//mov     r6,#0xF
//str     r6,[sp,#0]
//mov     r4,#0x0
//str     r4,[sp,#0x4]
//mov     r1,#0x1A
//mov     r2,#0x30
//mov     r3,r7
//bl      $8047CDC
//mov     r0,#0x3E // Use
//bl      $80486A0
//str     r6,[sp,#0]
//str     r4,[sp,#0x4]
//mov     r1,#0x1A
//mov     r2,#0x3C
//mov     r3,r7
//bl      $8047CDC
//mov     r0,#0x3F // Give
//bl      $80486A0
//str     r6,[sp,#0]
//str     r4,[sp,#0x4]
//mov     r1,#0x1A
//mov     r2,#0x48
//mov     r3,r7
//bl      $8047CDC
//mov     r0,#0x40 // Drop
//bl      $80486A0
//str     r6,[sp,#0]
//str     r4,[sp,#0x4]
//mov     r1,#0x1A
//mov     r2,#0x54
//mov     r3,r7
//bl      $8047CDC
//ldr     r0,=#0x2003F08    //If we printed this once, then it's not needed anymore
//mov     r1,#0x0
//strb    r1,[r0,#0]
//add     sp,#0x8
//.end_use_frame1:
//pop     {r5-r6}
//pop     {r0-r7}
//pop     {pc}

//=============================================================================================
// This hack fixes the string used when you try to drop an item.
//=============================================================================================

.drop_text:
// ----------------------------------------------
// Everything from here to the next comment loads the Menu/Use/Give/Drop sprites, so we skip those
push    {r4-r7,lr}
mov     r6,r8
push    {r6}
add     sp,#-0x8
mov     r0,#0x3C // Menu
bl      $80486A0
mov     r7,#0x1
neg     r7,r7
mov     r6,#0xF
str     r6,[sp,#0]
mov     r4,#0x0
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x30
mov     r3,r7
bl      $8047CDC
mov     r0,#0x3E // Use
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x3C
mov     r3,r7
bl      $8047CDC
mov     r0,#0x3F // Give
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x48
mov     r3,r7
bl      $8047CDC
mov     r0,#0x40 // Drop
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x54
mov     r3,r7
bl      $8047CDC
// ----------------------------------------------
// Get some value
ldr     r0,=#0x2015D98
ldrb    r0,[r0,#0]
// Dunno what this is for, but it skips the rest of the routine if somevalue << 0x1D is negative
lsl     r0,r0,#0x1D
cmp     r0,#0x0
blt     .drop_text_end
// ----------------------------------------------
// Load the "-- Throw away?" text address
mov     r0,#0x81
bl      $80486A0

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// ----------------------------------------------
// Add the Throw Away text to the shitpile
mov     r5,#1
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x26
mov     r8,r1 // store the current X loc to r9
mov     r2,#0x87
mov     r3,r7
mov     r4,r0 // back up the address
bl      $8047CDC
// ----------------------------------------------
// Get the width of the Throw Away string
mov  r0,r4
bl   get_string_width
add  r8,r0 // xloc += width_of_throwaway
// ----------------------------------------------
// Get the item ID
ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
// ----------------------------------------------
// Do something mysterious
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
// ----------------------------------------------
// Gets the item address
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C
mov  r4,r0
//      r0/r4 = address, r3 = max length
// ----------------------------------------------
// Add the item name to the shitpile
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16             // max length for normal items
bl      $8047CDC
// ----------------------------------------------
// Get the width of the item name

mov  r0,r4
bl   get_string_width
add  r8,r0 // xloc += width_of_itemname
// ----------------------------------------------
// Add the question mark to the shitpile
str  r6,[sp,#0]
str  r5,[sp,#0x4]
ldr  r0,=#.question_mark
mov  r1,r8
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC
// ----------------------------------------------
// Add Yes and No to the shitpile
mov     r0,#0x3
bl      $80486A0
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r7
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r7
bl      $8047CDC
// ----------------------------------------------
.drop_text_end:
add     sp,#0x8
pop     {r3}
mov     r8,r3
pop     {r4-r7}
pop     {r0}
bx      r0

//=============================================================================================
// This hack fixes the string used when you are asked to equip a bought item.
//=============================================================================================

.equip_text:
push    {r4-r6,lr}
mov     r6,r8
push    {r6}
add     sp,#-0x8
// ----------------------------------------------
// Check the mystery value again
ldr     r0,=#0x2015D98
ldrb    r0,[r0,#0]
lsl     r0,r0,#0x1D
cmp     r0,#0x0
bge     +
// ----------------------------------------------
// If it's negative again, use a different string
mov     r0,#0xB9 // [person] equipped the [item]!
bl      $80486A0
mov     r4,r0
mov     r1,#0x1C
mov     r2,#0x87
bl      $8047F28
b       .equip_text_end
+
// ----------------------------------------------
// Load the "-- Equip now?" text address
mov     r0,#0x80
bl      $80486A0

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0


// ----------------------------------------------
// Add it to the shitpile
mov     r5,#0xF
str     r5,[sp,#0]
mov     r6,#0x1
str     r6,[sp,#0x4]
mov     r1,#0x26
mov     r8,r1
mov     r2,#0x87
mov     r3,#1
neg     r3,r3
mov     r4,r0
bl      $8047CDC
// ----------------------------------------------
// Get the width of the equip text
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Do the mystery item function
ldr     r4,=#0x201A1FD
ldrb    r0,[r4,#0]
mov     r1,#0xC
mov     r2,#0x86
bl      $8046974
// ----------------------------------------------
// Get the item address
ldrb    r1,[r4,#0]
mov     r0,#0x2
bl      $8001C5C
mov     r4,r0
// ----------------------------------------------
// Add the item name to the shitpile
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r0,r4
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16
bl      $8047CDC
// ----------------------------------------------
// Get the width of the item name
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Add " now?" to the shitpile
str  r5,[sp,#0]
str  r6,[sp,#0x4]
ldr  r0,=#.equip_now_text
mov  r1,r8
mov  r2,#0x87
//mov  r3,#5
mov  r3,#1
bl   $8047CDC
// ----------------------------------------------
// Add Yes and No to the shitpile
mov  r4,#1
neg  r4,r4
mov     r0,#0x3
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
// ----------------------------------------------
.equip_text_end:
add     sp,#0x8
pop     {r3}
mov     r8,r3
pop     {r4-r6}
pop     {r0}
bx      r0

.equip_now_text:
dw $001F
//dw $0040,$004E,$004F,$0057,$001F

//=============================================================================================
// This hack fixes the string used when you are asked to sell a currently equipped item after
// buying new equipment.
//=============================================================================================

//print pc
.sell_old_equip_text:
push    {r4-r7,lr}
mov     r7,r9
mov     r6,r8
push    {r6,r7}
add     sp,#-0x8
// ----------------------------------------------
// Get the address of "Sell your "
mov  r0,#0x7F
bl   $80486A0
mov  r4,r0

// ----------------------------------------------
// Add it to the shitpile
mov  r5,#0xF
str  r5,[sp,#0]
mov  r6,#0x1
str  r6,[sp,#0x4]
mov  r1,#0x26
mov  r8,r1
mov  r2,#0x87
mov  r3,#1
neg  r3,r3
bl   $8047CDC
// ----------------------------------------------
// Get the width of "Sell your "
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Get the item ID, do the mystery function
ldr     r7,=#0x201A1FD
ldrb    r0,[r7,#0]
mov     r1,#0xC
mov     r2,#0x86
bl      $8046974
// ----------------------------------------------
// Get the item address
ldrb    r1,[r7,#0]
mov     r0,#0x2
bl      $8001C5C
// ----------------------------------------------
// Add the item to the shitpile
mov     r4,r0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16
bl      $8047CDC
// ----------------------------------------------
// Get the item width
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Do some extra crap; don't touch
ldr     r2,=#0x80E5108
ldrb    r1,[r7,#0]
mov     r0,#0x6C
mul     r0,r1
add     r0,r0,r2
ldrh    r1,[r0,#0xA]
ldr     r0,=#0x201A518
strh    r1,[r0,#0]
// ----------------------------------------------
// Get the address of "-- [DPAMT] DP"
mov     r0,#0x7E
bl      $80486A0
// ----------------------------------------------
// Add the DP text to the shitpile
mov     r1,r8
mov     r2,#0x87
bl      $8047F28 // alternate shitpiler
// ----------------------------------------------
// Get the width of the parsed DP text
ldr  r0,=#0x203FFFC
ldr  r0,[r0,#0]
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Add Yes and No to the shitpile
mov     r0,#0x3
bl      $80486A0
mov     r4,#1
neg     r4,r4
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
// ----------------------------------------------
add     sp,#0x8
pop     {r3,r4}
mov     r8,r3
mov     r9,r4
pop     {r4-r7}
pop     {r0}
bx      r0

//=============================================================================================
// This hack steps into the menu text parser and stores the parsed address to 203FFFC.
//=============================================================================================

.parser_stepin:
ldr  r0,=#0x203FFF8
str  r6,[r0,#0] // Original address
str  r5,[r0,#4] // Parsed address
lsl  r4,r4,#2
add  r4,r9
bx   lr

// This sets the parsed flag for use with 8047CDC
.parser_stepin2:
ldr  r4,=#0x203FFF7
mov  r5,#1
strb r5,[r4,#0]
mov  r5,r0
mov  r4,r1 // clobbered code
bx   lr

// This adds the real address to the table at 203FFA0
.parser_stepin3:
push {r0,r2,r3}
// r0 = counter
// ----------------------------------------------
// Get the target address ready; addr = 203FFA0 + (counter * 4)
ldr  r1,=#0x203FFA0
lsl  r0,r0,#2
add  r1,r1,r0
// ----------------------------------------------
// Check the parsed flag
ldr  r2,=#0x203FFF7
ldrb r0,[r2,#0]
mov  r3,#0
strb r3,[r2,#0]
cmp  r0,#0
bne  +
// Use the address in r5
str  r5,[r1,#0]
b    .parser_stepin3_end
+
// Use the original address from 203FFF8
add  r2,#1
ldr  r0,[r2,#0]
// ----------------------------------------------
// Store it to the table
str  r0,[r1,#0]

.parser_stepin3_end:
pop  {r0,r2,r3}
mov  r1,r0
lsl  r0,r1,#2 // clobbered code
bx   lr

//=============================================================================================
// This hack applies a VWF to item text and other non-sprite text in the main menus.
//=============================================================================================

.item_vwf:
push {r2,r6,lr}

ldr  r6,[r6,#0]
lsl  r6,r6,#0x14
lsr  r0,r6,#0x14             // r0 has the letter now

ldr  r2,=#0x8D1CE78          // r2 now points to the start of 16x16 font's width table
ldrb r0,[r2,r0]              // load r0 with the appropriate width
pop  {r2,r6,pc}

//=============================================================================================
// This hack makes Chapter End (and other stuff?) appear nicely on the file select screens
//=============================================================================================

.chap_end_text:
push {lr}

cmp  r1,#0xCA
bne  +
sub  r0,r0,#2

+
lsl  r0,r0,#0x10
add  r3,r6,r0
asr  r3,r3,#0x10
pop  {pc}

//=============================================================================================
// This hack manually clears the tile layer with non-sprite text on it, since the game
// doesn't seem to want to do it itself all the time. We're basically shoving a bunch of 0s
// into the tilemap.
//
//
// Note that this is buggy so it's not being used now. Fix it later maybe?
//=============================================================================================

.clear_non_sprite_text:
push {lr}

cmp  r4,#0
bne  +

bl   .delete_vram

+
mov  r0,r5                   // clobbered code
mov  r1,r6
pop  {pc}


//=============================================================================================
// This hack implements a VWF for the battle memory non-sprite text.
//=============================================================================================

.battle_mem_vwf:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  r14,r5                  // Move the former LR value back into LR 
ldr  r5,=#0x804999B          // This is different from the other functions. At the old code from the branch,
                             // there is an unconditional branch after mov r0,#8 to this address.
                             // This is where we want to return to.
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

ldr  r0,=#0x8D1CE78          // load r0 with the address of our 16x16 font width table (FIX : that was 8x8)
ldrb r0,[r0,r1]
pop  {pc}


//=============================================================================================
// This hack will make the game load alternate text than the game would normally expect.
// This affects:
//   - Short enemy names in the Battle Memory screen
//   - Short enemy names used in gray name boxes outside
//   - Fixed item descriptions in battle, with descs that would normally use status icons
//   - Sleep mode message, which had to be done using prewelded text
//=============================================================================================

.load_alternate_text:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  lr,r5                   // Move the former LR value back into LR 
ldr  r5,[sp,#0x04]           // Grab the LR value for THIS function 
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

push {r5-r6}                 // need to use these registers real quick
cmp  r2,#0x07                // if r2 == 7, then we're dealing with enemy names
beq  .short_enemy_name

cmp  r2,#0x00                // in battle, status icons don't get displayed
beq  .status_icon_text       // so we prepare alternate text

cmp  r1,#0x25                // we have to do some magic to make the sleep mode message work
beq  .sleepmode_text

b    .orig_load_code         // so let's just jump to the original code for non-enemy names

//---------------------------------------------------------------------------------------------

.short_enemy_name:
ldr  r5,=#0x80476FB          // load r5 with 0x80476FB, which we'll use to compare the calling address from
ldr  r6,[sp,#0x1C]           // load in the calling address
cmp  r5,r6                   // if equal, this is for the battle memory menu
beq  +

ldr  r5,=#0x8023B1F          // load r5 with 0x8023B1F, which is used for the gray name boxes
cmp  r5,r6
bne  .orig_load_code         // if not equal, jump to the original code

+
ldr  r0,=#0x8D23494          // load the base address of the abbreviated names list
b    .end_load_code

//---------------------------------------------------------------------------------------------

.status_icon_text:
ldr  r5,=#0x8064B89          // see if this is being loaded from battle, if not, do normal code
ldr  r6,[sp,#0x18]
cmp  r5,r6
bne  .orig_load_code

cmp  r4,#0x8B                // if item # < 0x8B or item # > 0x92, use normal code and desc text
blt  .orig_load_code
cmp  r4,#0x92
bgt  .orig_load_code

ldr  r0,=#0x9F8F004          // else use special item descriptions just for this instance
cmp  r1,#4
bne  +
ldr  r0,=#0x9F8F204

+
b    .end_load_code

//---------------------------------------------------------------------------------------------

.sleepmode_text:
ldr  r5,=#0x9AF3790          // just making extra sure we won't trigger this fix on accident
cmp  r0,r5                   // see if r0 directs to the menus3 block
bne  .orig_load_code         // if it doesn't, skip all this and do the original code

ldr  r5,=#0x9FB0300          // start of custom sleep mode text/data

cmp  r6,#0x1F                // if this is the first sleep mode line, redirect pointer
bne  +                       // if this isn't the first sleep mode line, see if it's the 2nd
mov  r0,r5
add  r0,#2                   // r0 now has the address of the first line of custom SM text
b    .special_end_load

+
cmp  r6,#0x20                // see if this is the 2nd line of sleep mode text
bne  .orig_load_code         // if it isn't, we continue the original load routine as usual
ldrh r0,[r5,#0]              // load the offset to the 2nd line
add  r0,r5,r0                // r0 now has the address to the 2nd line
b    .special_end_load

//---------------------------------------------------------------------------------------------

.orig_load_code:
lsl r1,r1,#0x10              // when this whole routine ends, it will go back to 80028A4
lsr r1,r1,#0x0E
add r1,r1,r0
ldr r1,[r1,#0x04]
add r0,r0,r1

.end_load_code:
pop {r5-r6,pc}               // Pop the registers we used off the stack, and return 

//---------------------------------------------------------------------------------------------

.special_end_load:
mov  r5,lr                   // we need to do some return address magic if we're doing
add  r5,#8                   // the sleep mode text fix
mov  lr,r5
pop  {r5-r6,pc}
                         


//=============================================================================================
// These three little hacks move item descriptions in RAM and allow for up to 256 letters,
// though there wouldn't be enough room in the box for that of course :P
//=============================================================================================

.load_desc_address1:
ldr  r0,=#0x2014330
mov  r2,r8
bx   lr

//---------------------------------------------------------------------------------------------

.load_desc_address2:
mov  r0,r4
ldr  r1,=#0x2014330
bx   lr

//---------------------------------------------------------------------------------------------

.load_desc_clear_length:
ldr  r1,=#0x1F8
mov  r2,r8
bx   lr




//=============================================================================================
// These six hacks allow for longer messages in main menus. The max is somewhere around 200
// letters.
//=============================================================================================

.save_menu_msg_address:
add  r5,#2
ldr  r0,=#0x2014310
str  r5,[r0,#0]
pop  {r4-r7}
pop  {r0}
bx   lr

//---------------------------------------------------------------------------------------------

.load_menu_msg_address:
ldr  r0,=#0x2014310
ldr  r5,[r0,#0]
bx   lr

//---------------------------------------------------------------------------------------------

.init_menu_msg_address:
ldr  r0,=#0x201A374
ldr  r7,=#0x2014310
str  r0,[r7,#0]
mov  r7,#0
mov  r0,#1
bx   lr

//---------------------------------------------------------------------------------------------

.change_menu_msg_address1:
push {r2,lr}
ldr  r0,=#0xFFFFFFFF
ldr  r1,=#0x2014330
ldr  r2,=#0x100
bl   fill_mem
mov  r0,r6
pop  {r2,pc}

//---------------------------------------------------------------------------------------------

.change_menu_msg_address2:
mov  r0,r5
ldr  r1,=#0x2014330
bx   lr

//---------------------------------------------------------------------------------------------

.change_menu_msg_clear_amt:
ldr  r1,=#0x201A510
sub  r1,r1,r5
mov  r2,r8
bx   lr


//=============================================================================================
// This hack processes our custom control codes. Since we don't need to bother with enemy
// stuff here, only custom item control codes need to be handled here.
//
// The custom item control codes are [10 EF] through [15 EF].
//
//   [10 EF] - Prints the proper article if it's the first word of a sentence (ie "A/An")
//   [11 EF] - Prints the proper article if it's not the first word of a sentence (ie "a/an")
//   [12 EF] - Prints an uppercase definite article ("The", etc.)
//   [13 EF] - Prints a lowercase definite article ("the", etc.)
//   [14 EF] - Prints this/these/nothing depending on the item
//   [15 EF] - Prints is/are/nothing depending on the item
//   [18 EF] - Prints it/them depending on the item
//
//   [20 EF] - Prints string fragments about the type of equipment the current item is
//
//=============================================================================================

.execute_custom_cc:
push {r0-r3,lr}

ldrb r0,[r4,#1]                  // load the high byte of the current letter
cmp  r0,#0xEF                    // if it isn't 0xEF, do normal stuff and then leave
beq  +

ldrh r0,[r4,#0]                  // load the correct letter again
strh r0,[r5,#0]                  // store the letter
add  r4,#2                       // increment the read address
add  r5,#2                       // increment the write address
b    .ecc_end                    // leave this subroutine

//---------------------------------------------------------------------------------------------

+
ldrb r0,[r4,#0]                  // load the low byte of the current letter, this is our argument
cmp  r0,#0x20                    // if this is EF20, go do that code elsewhere
beq  +

mov  r2,#0x10
sub  r2,r0,r2                    // r2 = argument - #0x10, this will make it easier to work with

ldr  r0,=#0x201A1FD              // this gets the current item #
ldrb r0,[r0,#0]

mov  r1,#7                       // 7 article entries per letter
mul  r0,r1                       // r3 = item num * 7
ldr  r1,=#{item_extras_address}  // this is the base address of our extra item data table in ROM
add  r0,r0,r1                    // r0 now has the address of the correct item table
ldrb r0,[r0,r2]                  // r0 now has the proper article entry #
mov  r1,#40
mul  r0,r1                       // calculate the offset into custom_text.bin
ldr  r1,=#{custom_text_address}  // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                    // r0 now has the address of the string we want

mov  r1,r5                       // r1 now has the address to write to
bl   custom_strcopy              // r0 returns with the # of bytes copied

add  r5,r5,r0                    // update the write address
add  r4,#2                       // increment the read address
b    .ecc_end

//---------------------------------------------------------------------------------------------

+                                // all this code here prints the proper "is equipment" message
ldr  r0,=#0x201A1FD              // this gets the current item #
ldrb r0,[r0,#0]
ldr  r1,=#0x80E510C              // start of item data blocks + item_type address
mov  r2,#0x6C                    // size of each item data block
mul  r0,r2                       // item_num * 6C
add  r0,r0,r1                    // stored at this address is the current item's type
ldrb r0,[r0,#0]                  // load the item type
add  r0,#20                      // add 20 -- starting on line 20 of item_extras.txt are the strings we want
mov  r1,#40
mul  r0,r1
ldr  r1,=#{custom_text_address}  // this is the base address of our custom text array
add  r0,r0,r1                    // r0 now has the correct address

mov  r1,r5
bl   custom_strcopy              // r0 returns the # of bytes copied

add  r5,r5,r0                    // update the write address
add  r4,#2                       // increment the read address

//---------------------------------------------------------------------------------------------

.ecc_end:
pop  {r0-r3,pc}


//=============================================================================================
// This hack fixes the main menu string length counting routine so that character names
// don't wind up with extra long names. If the counting routine thought a name was > 8,
// manually make the length = 8.
//=============================================================================================

.counter_fix1:
push {lr}
//mov  r5,#8                   // r5 will be the new value to change to if need be

ldr  r0,[sp,#8]              // load r0 with the base address of the string we just counted
bl   check_name              // check if the name is custom
cmp  r0,#0
beq  +

cmp  r3,r0                   // is the length > r5 (normally 8)?
ble  +                       // if not, continue as normal, else manually make it = r5 (normally 8)
mov  r3,r0

+
mov  r0,r3                   // clobbered code
pop  {r4}
mov  lr,r4
pop  {r4,r5}
bx   lr


//=============================================================================================
// This hack fixes the rare case of the menu message "Fav. Food - XXX has XXX of this item."
// The game always assumes the fav. food's max length is 22, because that's the length of
// normal items.
//=============================================================================================

.counter_fix2:
ldr  r2,=#0x2004F02          // load the address of where the fav. food string is stored
cmp  r4,r2                   // if we're working with the fav. food address, alter the max length
bne  +
mov  r0,#9                   // 9 is the max length for fav. food

+
lsl  r0,r0,#0x10             // clobbered code
lsr  r2,r0,#0x10
bx   lr

//=============================================================================================
// This hack deletes the content of VRAM that is being shown
//=============================================================================================
.delete_vram:
push {r0-r2,lr}

mov  r0,#0
push {r0}
mov  r0,sp
ldr  r1,=#0x600E800
ldr  r2,=#0x01000140         // (0x500 => 160 pixels, the GBA screen's height, 24th bit is 1 to fill instead of copying)

swi  #0x0C                   // clear old data out
pop {r0}

pop  {r0-r2,pc}

//=============================================================================================
// This hack deletes the content of VRAM in equip when the data shouldn't be shown. Optimized.
//=============================================================================================
.delete_vram_equip:
push {r1-r7,lr}
bl   $805504C                // Get if the character's data can be shown
lsl  r0,r0,#0x10

cmp  r0,#0                   // If it can be shown, jump to the end
beq  +

push {r0}

// Setup
ldr  r6,=#0x01000008         // (0x20 bytes of arrangements, 24th bit is 1 to fill instead of copying)
ldr  r7,=#0x600E9A0
mov  r4,#0x40
lsl  r5,r4,#2
mov  r0,#0
push {r0}

//Actual clearing

//Weapon
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Body
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Head
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Other
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

pop  {r0}                    // Ending
pop  {r0}

+
pop  {r1-r7,pc}

//=============================================================================================
// This hack deletes the content of VRAM in status when the data shouldn't be shown. Optimized.
//=============================================================================================
.delete_vram_status:
push {r1-r7,lr}
bl   $805504C                // Get if the character's data can be shown
lsl  r0,r0,#0x10

cmp  r0,#0                   // If it can be shown, jump to the end
beq  +

push {r0}

// Setup
ldr  r6,=#0x01000008         // (0x20 bytes of arrangements, 24th bit is 1 to fill instead of copying)
ldr  r7,=#0x600EAA0
mov  r4,#0x40
lsl  r5,r4,#1
mov  r0,#0
push {r0}

//Actual clearing

//Weapon
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Body
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Head
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Other
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

add  r7,r7,r5                // Next section

//Skill
//First row
mov  r0,sp
mov  r1,r7
mov  r2,r6
swi  #0x0C                   // clear old data out
//Second row
mov  r0,sp
add  r1,r7,r4
mov  r2,r6
swi  #0x0C                   // clear old data out

pop  {r0}                    // Ending
pop  {r0}

+
pop  {r1-r7,pc}

//=============================================================================================
// This hack deletes the content of VRAM that is being shown when going from the inventory to the battle memory
//=============================================================================================
.delete_vram_inv_to_battle_memory:
push {lr}

bl   .delete_vram

bl   $800399C                // Clobbered code
pop  {pc}

//=============================================================================================
// This hack deletes the content of VRAM that is being shown when going from the battle memory to the inventory
//=============================================================================================
.delete_vram_battle_memory_to_inv:
push {lr}

bl   .delete_vram

bl   $804BE64                // Clobbered code
pop  {pc}

//=============================================================================================
// This hack changes how up/down scrolling in menus works - Based off of 0x8046D90, which is basic menu printing
//=============================================================================================

.new_print_menu_offset_table:
  dd .new_main_inventory_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_withdrawing_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1
  dd .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1, .new_default_scroll_print+1

.new_print_menu_up_down:
push {r4,lr}
ldr  r3,=#0x2016028                    // Base code
ldr  r0,=#0x44F2
add  r2,r3,r0
ldrb r1,[r2,#0]
lsl  r0,r1,#0x1C
cmp  r0,#0
bge  +
b    .end_new_print_menu_up_down
+
mov  r0,#8
orr  r0,r1
strb r0,[r2,#0]
ldr  r1,=#0x4260
add  r0,r3,r1                          //Get the type of menu this is
ldrb r0,[r0,#0]
cmp  r0,#0x10
bhi  +
ldr  r0,=#0x2016078
ldr  r2,=#0x41EC
add  r1,r0,r2
mov  r2,#1
mov  r3,#0

bl   .new_clear_menu                   //New code!!!

+
bl   $8049D5C                          //Back to base code
ldr  r3,=#0x2016028
ldr  r1,=#0x41C6
add  r0,r3,r1
ldrb r1,[r0,#0]
mov  r0,#1
and  r0,r1
cmp  r0,#0
beq  +
ldr  r2,=#0x41BC
add  r1,r3,r2
ldrh r0,[r1,#0]
cmp  r0,#3
bhi  .end_new_print_menu_up_down
ldr  r0,=#0x9B8FD74
ldrh r1,[r1,#0]
lsl  r1,r1,#2
add  r1,r1,r0
ldr  r4,=#0x3060
add  r0,r3,r4
ldr  r1,[r1,#0]
bl   $8091938
b    .end_new_print_menu_up_down
+
ldr  r0,=#0x4260
add  r2,r3,r0
ldrb r0,[r2,#0]
cmp  r0,#0x12
bhi  .end_new_print_menu_up_down
ldr  r1,=#0x9B8FD28
lsl  r2,r0,#2
add  r2,r2,r1
lsl  r0,r0,#5
mov  r4,#0xB8
lsl  r4,r4,#6
add  r1,r3,r4
add  r0,r0,r1
ldr  r1,=#0x201A288
ldrb r1,[r1,#0]
lsl  r1,r1,#2
ldr  r2,=#.new_print_menu_offset_table
add  r1,r2,r1
ldrh r2,[r1,#2]
lsl  r2,r2,#0x10
ldrh r1,[r1,#0]
add  r1,r1,r2

bl   $8091938  // New code!

.end_new_print_menu_up_down:
pop  {r4,pc}

//=============================================================================================
// This hack changes how menu clearing works, based off of 0x80012BC
//=============================================================================================
.new_clear_menu:
push {r4-r7,lr}
mov  r7,r8                             //base code
push {r7}
add  sp,#-0xC
mov  r8,r0
mov  r5,r1
lsl  r2,r2,#0x10
lsr  r7,r2,#0x10
mov  r0,sp
strh r3,[r0,#0]
cmp  r5,#0
beq  .next_spot
mov  r1,#0
ldsh r0,[r5,r1]
cmp  r0,#0
bge  +
add  r0,#7
+
lsl  r0,r0,#0xD
lsr  r0,r0,#0x10
ldr  r2,=#0xFFFF0000
ldr  r1,[sp,#4]
and  r1,r2
orr  r1,r0
str  r1,[sp,#4]
mov  r1,#2
ldsh r0,[r5,r1]
cmp  r0,#0
bge  +
add  r0,#7
+
asr  r0,r0,#3
add  r4,sp,#4
strh r0,[r4,#2]
ldrh r0,[r5,#4]
lsr  r0,r0,#3
strh r0,[r4,#4]
ldrh r0,[r5,#6]
lsr  r0,r0,#3
strh r0,[r4,#6]
ldrh r2,[r4,#0]
ldrh r3,[r4,#2]
mov  r0,r8
mov  r1,r7
bl   $8001378
mov  r5,r0
mov  r6,#0
ldrh r0,[r4,#6]
cmp  r6,r0
bcs  +

//New code!
bl   .get_direction
cmp  r0,#0
bne  .new_clear_menu_descending
//Swap arrangements' place - if we're ascending
mov  r1,r5
mov  r0,#0x38
lsl  r0,r0,#4
add  r4,r1,r0                          // Get to bottom
-
mov  r1,r4
mov  r0,#0x80
sub  r4,r4,r0
mov  r0,r4
mov  r2,#0x20                          // Put the arrangements one below
swi  #0xC
cmp  r4,r5
bgt  -
mov  r0,#0
push {r0}
mov  r0,sp
mov  r1,r5
ldr  r2,=#0x01000020                   // (0x80 bytes of arrangements, 24th bit is 1 to fill instead of copying)
swi  #0xC
pop  {r0}
b    +

//Swap arrangements' place - if we're descending
.new_clear_menu_descending:
mov  r1,r5
mov  r0,#0x80
add  r0,r0,r1
mov  r2,#0xE0                          // Put the arrangements one above
swi  #0xC
mov  r0,#0
push {r0}
mov  r0,#0x80
lsl  r1,r0,#3
sub  r1,r1,r0
mov  r0,sp
add  r1,r1,r5
ldr  r2,=#0x01000020                   // (0x80 bytes of arrangements, 24th bit is 1 to fill instead of copying)
swi  #0xC
pop  {r0}
b    +

.next_spot:                            //Back to base code
mov  r0,r8
mov  r1,r7
mov  r2,#0
mov  r3,#0
bl   $8001378
mov  r5,r0
mov  r1,#0x80
lsl  r1,r1,#4
bl   $80019DC
+
mov  r0,sp
ldrh r0,[r0,#0]
cmp  r0,#0
beq  +
lsl  r1,r7,#1
mov  r0,#0xB1
lsl  r0,r0,#6
add  r0,r8
add  r0,r0,r1
ldrh r1,[r0,#0]
mov  r1,#1
strh r1,[r0,#0]
+
add  sp,#0xC
pop  {r3}
mov  r8,r3
pop  {r4-r7,pc}

//=============================================================================================
// This hack gives a default print scroller
//=============================================================================================
.new_default_scroll_print:
bx   lr

//=============================================================================================
// This hack changes what the withdrawing scrolling will print, based off of 0x8046EF0
//=============================================================================================
.new_withdrawing_scroll_print:
push {r4-r7,lr}
mov  r7,r9
mov  r6,r8
push {r6,r7}
add  sp,#-4                            //base code
mov  r1,r0
ldr  r3,=#0x2016028
ldr  r0,=#0x4282
add  r2,r3,r0

bl   .get_direction                    //New code!
cmp  r0,#0
bne  .new_withdrawing_scroll_print_descending
mov  r0,#2
ldrh r1,[r1,#8]
b    +
.new_withdrawing_scroll_print_descending:
ldrh r0,[r2,#0]
ldrh r1,[r1,#8]
add  r1,#0xE
sub  r0,r0,r1
cmp  r0,#2
ble  +
mov  r0,#2
+

lsl  r2,r0,#0x10                       //base code
lsr  r4,r2,#0x10
mov  r9,r4
lsl  r1,r1,#2
ldr  r4,=#0x3DBC
add  r0,r3,r4
add  r5,r1,r0
mov  r7,#0xF
mov  r6,#0
lsr  r0,r2,#0x11
cmp  r6,r0
bcs  +
mov  r8,r0                             //Set the thing to print the bottom two items at the right position
ldrb r1,[r5,#0]
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#1
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C
add  r5,#4
ldrb r1,[r5,#0]
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#0xA
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C
mov  r0,#0
mov  r1,#0
mov  r2,#1
bl   $8047D90
+
mov  r0,#1
mov  r1,r9
and  r0,r1
cmp  r0,#0
beq  +
ldrb r1,[r5,#0]                        //Set the thing to print the bottom item at the right position
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#0x1
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C
+
add  sp,#4
pop  {r3,r4}
mov  r8,r3
mov  r9,r4
pop  {r4-r7,pc}

//=============================================================================================
// This hack changes what the main inventory scrolling will print, based off of 0x8046EF0
//=============================================================================================
.new_main_inventory_scroll_print:
push {r4-r7,lr}
mov  r7,r9
mov  r6,r8
push {r6,r7}
add  sp,#-4                            //base code
mov  r3,r0
ldr  r2,=#0x2016028
ldr  r0,=#0x2DFA
add  r1,r2,r0
ldrh r0,[r3,#0xA]
ldrh r1,[r1,#0]                        //is this the key items inventory?
cmp  r0,r1
bcc  .new_main_inventory_scroll_print_end
mov  r0,r3
bl   .new_key_inventory_scroll_print

.new_main_inventory_scroll_print_end:
add  sp,#4
pop  {r3,r4}
mov  r8,r3
mov  r9,r4
pop  {r4-r7,pc}

//=============================================================================================
// This hack changes what scrolling in the key items inventory will print, based off of 0x8046FD8
//=============================================================================================
.new_key_inventory_scroll_print:
push {r4-r7,lr}
mov  r7,r9
mov  r6,r8
push {r6,r7}
add  sp,#-4                            //base code
mov  r1,r0
ldr  r3,=#0x2016028
bl   .get_direction
cmp  r0,#0
bne  .new_key_inventory_scroll_print_descending_items
mov  r0,#2                             //If we're scrolling up, there will be two items for sure. No need to edit r1 either.
ldrh r1,[r1,#8]
b    +
.new_key_inventory_scroll_print_descending_items:
ldr  r0,=#0x426A
add  r2,r3,r0
ldrh r0,[r2,#0]
ldrh r1,[r1,#8]
add  r1,#0xE                           //Only if we're descending!
sub  r0,r0,r1
cmp  r0,#2
ble  +
mov  r0,#2
+
lsl  r2,r0,#0x10
lsr  r4,r2,#0x10
mov  r9,r4
lsl  r1,r1,#2
mov  r4,#0xC2
lsl  r4,r4,#6
add  r0,r3,r4
add  r5,r1,r0
mov  r6,#0
lsr  r0,r2,#0x11
cmp  r6,r0
bcs  +
mov  r7,#0xF                           //Set the thing to print the bottom two items at the right position
ldrb r1,[r5,#0]
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#1
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C
add  r5,#0x4
ldrb r1,[r5,#0]
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#0xB
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C
+
mov  r0,#1
mov  r1,r9
and  r0,r1
cmp  r0,#0
beq  .new_key_inventory_scroll_print_end

mov  r7,#0xF                           //Set the thing to print the bottom item at the right position
ldrb r1,[r5,#0]
mov  r0,#2
bl   $8001C5C
str  r7,[sp,#0]
mov  r1,#1
bl   .get_inventory_height
mov  r3,#0x16
bl   $8047B9C

.new_key_inventory_scroll_print_end:
add  sp,#4
pop  {r3,r4}
mov  r8,r3
mov  r9,r4
pop  {r4-r7,pc}

//=============================================================================================
// This hack gets the scrolling direction for any given menu
//=============================================================================================
.get_direction:
push {r1-r2,lr}
ldr  r1,=#0x201A288
ldrb r1,[r1,#0]                        //Get menu type
lsl  r1,r1,#5
ldr  r2,=#0x2016028
ldr  r0,=#0x2DFA
add  r0,r2,r0                          //Get menu info array in RAM
add  r1,r0,r1
mov  r2,#1
ldrh r0,[r1,#0xA]
ldrh r1,[r1,#0xE]
lsr  r0,r0,#1
lsr  r1,r1,#1
cmp  r0,r1
bne +
mov  r2,#0                             //Going up if they're the same! Otherwise, going down!
+
mov  r0,r2
pop  {r1-r2,pc}

//=============================================================================================
// This hack gets the height for printing in the inventory/withdrawing menu
//=============================================================================================
.get_inventory_height:
push {r0,lr}
bl   .get_direction
cmp  r0,#0
bne  .get_inventory_height_descending
mov  r2,#0x2
b    .get_inventory_height_end
.get_inventory_height_descending:
mov  r2,#0x9
.get_inventory_height_end:
pop  {r0,pc}

//=============================================================================================
// This hack is called in order to change where everything is printed in VRAM. Based on 0x80487D4
//=============================================================================================
.new_print_vram_container:
push {r4,r5,lr}
ldr  r4,=#0x201AEF8                    //We avoid printing OAM entries...
ldr  r0,=#0x76DC                       //Base code
add  r5,r4,r0
ldrb r1,[r5,#0]
mov  r0,#8
and  r0,r1
cmp  r0,#0
beq  +
mov  r0,r4
bl   $8048878
mov  r0,r4
bl   $80489F8
mov  r0,r4
bl   $8048C5C
+
bl   .load_curr_group_length1          //Hmmm...
ldr  r3,=#0x76D6
add  r0,r4,r3
mov  r2,#0
strb r1,[r0,#0]
add  r3,#1
add  r0,r4,r3
strb r2,[r0,#0]
lsl  r1,r1,#0x18
cmp  r1,#0
beq  +

mov  r0,r4
bl   .new_print_vram                   //New code!

mov  r0,r4                             //Base code
bl   $8048EF8
+
ldr  r1,=#0x6C28
add  r0,r4,r1
ldr  r0,[r0,#0]
ldrb r1,[r0,#0x11]
cmp  r1,#0
bne  +
ldr  r2,=#0x3004B00
ldrh r0,[r2,#0]
cmp  r0,#0
beq  +
ldr  r3,=#0xFFFFF390
add  r0,r4,r3
ldrb r0,[r0,#0]
cmp  r0,#0
blt  +
cmp  r0,#2
ble  .new_print_vram_container_inner
cmp  r0,#4
bne  +
.new_print_vram_container_inner:
strh r1,[r2,#0]
+
pop  {r4,r5,pc}

//=============================================================================================
// This hack is called in order to change where everything is printed in VRAM. Based on 0x80487D4
//=============================================================================================
.new_print_vram:
push {r4-r7,lr}
mov  r7,r10                            //Base code
mov  r6,r9
mov  r5,r8
push {r5-r7}
add  sp,#-0x10
mov  r4,r0
ldr  r0,=#0x76D7
add  r1,r4,r0
mov  r0,#0
strb r0,[r1,#0]
ldr  r1,=#0x25F4
add  r0,r4,r1
ldr  r6,[r0,#0]
mov  r2,#0xAA
lsl  r2,r2,#3
add  r2,r2,r4
mov  r9,r2
ldr  r3,=#0x76D6
bl   .load_curr_group_length2
str  r0,[sp,#0xC]
mov  r1,sp
mov  r0,#1
strh r0,[r1,#0]
ldr  r0,[sp,#0xC]
cmp  r0,#0
bne  +
b    .new_print_vram_out_of_loop
+
add  r1,sp,#4
mov  r10,r1
add  r2,sp,#8
mov  r8,r2
mov  r3,#0xC3
lsl  r3,r3,#3
add  r7,r4,r3
.new_print_vram_start_of_loop:
bl   .check_for_eos
cmp  r0,#0
bne  +
b    .new_print_vram_end_of_loop
+
ldr  r1,=#0x25F8
add  r0,r4,r1
ldr  r1,[r0,#0]
add  r0,r1,#4
cmp  r6,r0
bne  .new_print_vram_keep_going
ldr  r0,[r1,#4]
lsl  r0,r0,#0xC
cmp  r0,#0
bge  +
.new_print_vram_keep_going:
mov  r0,r4
mov  r1,r6
add  r2,sp,#4
bl   $8049280
add  r5,sp,#4
b    .new_print_vram_keep_going_2
+
mov  r0,sp
ldrh r0,[r0,#0]
add  r5,sp,#4
cmp  r0,#0
beq  .new_print_vram_keep_going_2
ldr  r2,=#0x25FC
add  r0,r4,r2
ldrh r0,[r0,#0]
mov  r3,r10
strh r0,[r3,#0]
ldr  r1,=#0x25FE
add  r0,r4,r1
ldrh r0,[r0,#0]
strh r0,[r3,#2]

.new_print_vram_keep_going_2:
mov  r2,#0
ldsh r1,[r5,r2]
cmp  r1,#0
bge  +
add  r1,#7
+
lsl  r1,r1,#0xD
lsr  r1,r1,#0x10
ldr  r2,=#0xFFFF0000
ldr  r0,[sp,#8]
and  r0,r2
orr  r0,r1
str  r0,[sp,#8]
mov  r0,r5
mov  r3,#2
ldsh r0,[r0,r3]
cmp  r0,#0
bge  +
add  r0,#7
+
asr  r0,r0,#3
mov  r1,r8
strh r0,[r1,#2]
bl   .get_ram_address2
lsr  r0,r0,#0x1C
lsl  r0,r0,#3
ldrb r1,[r7,#0]
mov  r3,#0x79
neg  r3,r3
mov  r2,r3
and  r1,r2
orr  r1,r0
strb r1,[r7,#0]
mov  r3,r8
ldrh r0,[r3,#0]
ldrh r1,[r3,#2]

bl   .new_get_address                  //New code!

mov  r2,r9
str  r0,[r2,#0]

//We change the target arrangement to match our expectations
ldr  r3,=#0x6008000
sub  r2,r0,r3
lsl  r2,r2,#2
ldr  r0,[r7,#0]
ldr  r1,=#0xFFFE007F
and  r0,r1
orr  r0,r2
str  r0,[r7,#0]                        //Store target arrangement

mov  r3,r8                             //Base code
ldrh r0,[r3,#0]
ldrh r1,[r3,#2]
bl   $80498C4                          //Gets where to put the arrangements - This we keep as is
mov  r1,r9
str  r0,[r1,#4]
ldrh r0,[r5,#0]
mov  r2,#7
and  r2,r0
ldrb r0,[r7,#0]
mov  r3,#8
neg  r3,r3
mov  r1,r3
and  r0,r1
orr  r0,r2
strb r0,[r7,#0]
ldr  r1,[r6,#0]
lsl  r1,r1,#0x14
lsr  r1,r1,#0x14
mov  r0,r9
bl   $8048F74
ldr  r0,[r7,#0]
lsl  r0,r0,#0xF
lsr  r0,r0,#0x16
ldr  r2,=#0x25F0
add  r1,r4,r2
strh r0,[r1,#0]
mov  r0,r9
add  r0,#8
ldr  r3,=#0x2530
add  r1,r4,r3
mov  r2,#0x60
bl   $8001B18
mov  r0,r9
add  r0,#0x68
ldr  r2,=#0x2590
add  r1,r4,r2
mov  r2,#0x60
bl   $8001B18
ldr  r3,=#0x76D7
add  r1,r4,r3
ldrb r0,[r1,#0]
add  r0,#1
strb r0,[r1,#0]
ldr  r0,[sp,#0xC]
sub  r0,#1
lsl  r0,r0,#0x10
lsr  r0,r0,#0x10
str  r0,[sp,#0xC]
add  r7,#0xCC
mov  r0,#0xCC
add  r9,r0
ldr  r0,[r6,#0]
lsl  r0,r0,#0x14
lsr  r0,r0,#0x14
bl   $8049954
mov  r1,r10
ldrh r1,[r1,#0]
add  r0,r0,r1
mov  r2,r10
strh r0,[r2,#0]
ldr  r3,=#0x25F8
add  r1,r4,r3
str  r6,[r1,#0]
add  r2,r3,#4
add  r1,r4,r2
strh r0,[r1,#0]
ldrh r1,[r5,#2]
add  r3,#6
add  r0,r4,r3
strh r1,[r0,#0]
.new_print_vram_end_of_loop:
add  r6,#4
mov  r1,#0xAA
lsl  r1,r1,#3
add  r0,r4,r1
cmp  r6,r0
bcs  .new_print_vram_out_of_loop
mov  r1,sp
mov  r0,#0
strh r0,[r1,#0]
ldr  r2,[sp,#0xC]
cmp  r2,#0
beq  .new_print_vram_out_of_loop
b    .new_print_vram_start_of_loop

.new_print_vram_out_of_loop:
bl   .clear_swap_flag
str  r6,[r0,#0]
add  sp,#0x10
pop  {r3-r5}
mov  r8,r3
mov  r9,r4
mov  r10,r5
pop  {r4-r7,pc}

//=============================================================================================
// This hack changes the target vram address to whatever we want it to be.
// It uses the values found by new_get_empty_tiles
//=============================================================================================
.new_get_address:
ldr  r1,[sp,#0x44]
cmp  r0,r1                             //If we're after a certain threshold (which depends on the menu), use the second address
blt  +
ldr  r1,[sp,#0x3C]
b    .new_get_address_keep_going
+
ldr  r1,[sp,#0x40]
.new_get_address_keep_going:
lsl  r0,r0,#0x10
lsr  r0,r0,#0xB
add  r0,r0,r1
bx   lr

//=============================================================================================
// This hack gets the tiles which will be empty
//=============================================================================================

//Table that dictates which menus are valid to read the empty buffer tiles of
.new_get_empty_tiles_valid:
  dw $8001, $0000

//Table which dictates the limit value of a menu used to change the valid buffer tiles to the second ones
.new_get_empty_tiles_limit_values:
  db $10, $FF, $FF, $FF, $FF, $FF, $FF, $FF
  db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0F
  db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
  db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

.new_get_empty_tiles:
push {r4-r6,lr}
ldr  r0,=#0x2016078
mov  r1,#1
mov  r2,#0
mov  r3,#0
bl   $8001378
ldr  r6,=#0x6008000
ldr  r1,=#0x201A288
ldr  r3,=#.new_get_empty_tiles_valid
ldrh r2,[r3,#2]
ldrh r3,[r3,#0]
lsl  r2,r2,#0x10
orr  r3,r2
ldrb r2,[r1,#0]
mov  r1,#1
lsl  r1,r2
and  r1,r3
cmp  r1,#0
bne  +
mov  r0,r6
mov  r1,r6
b    .end_new_get_empty_tiles
+
mov  r3,r0
add  r3,#0x82
ldr  r4,=#0xFFF00003                   //Bitmap for occupied/not occupied zone
mov  r5,#0
-
add  r3,#0x80
ldrh r1,[r3,#0x1E]
ldrh r0,[r3,#0]
lsr  r0,r0,#4
mov  r2,#1
and  r2,r0
lsr  r0,r0,#1
orr  r0,r2
mov  r2,#1
lsl  r2,r0 
orr  r4,r2                             //Set r0-th zone to occupied
lsr  r1,r1,#4
mov  r2,#1
and  r2,r1
lsr  r1,r1,#1
orr  r1,r2
mov  r2,#1
lsl  r2,r1
orr  r4,r2                             //Set r1-th zone to occupied
add  r5,#1
cmp  r5,#8
blt  -
mov  r5,#0                             //Now get the free zones
mov  r3,#0
mov  r2,#0
mov  r1,#0
-
mov  r0,#1
lsl  r0,r5
and  r0,r4
cmp  r0,#0
bne  +
mov  r2,r3
mov  r3,r5
add  r1,#1
+
add  r5,#1
cmp  r5,#0x20
bge  +
cmp  r1,#2
blt  -
+
// r2 and r3 have our numbers
mov  r5,#1
and  r5,r2
sub  r2,r2,r5
lsl  r2,r2,#1
orr  r2,r5
lsl  r2,r2,#9
add  r0,r2,r6
mov  r5,#1
and  r5,r3
sub  r3,r3,r5
lsl  r3,r3,#1
orr  r3,r5
lsl  r3,r3,#9
add  r1,r3,r6
mov  r2,#0x10
lsl  r3,r2,#5
sub  r1,r1,r3
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
ldr  r4,=#.new_get_empty_tiles_limit_values
ldrb r2,[r4,r2]

.end_new_get_empty_tiles:
pop  {r4-r6,pc}

//=============================================================================================
// This hack combines all the hacks above.
// It moves the arrangements around instead of re-printing everything.
// It only prints what needs to be printed.
//=============================================================================================
.up_down_scrolling_print:
push {lr}
add  sp,#-0xC
bl   .new_get_empty_tiles
str  r2,[sp,#8]
str  r0,[sp,#4]
str  r1,[sp,#0]
bl   .new_print_menu_up_down
ldr  r4,=#0x201AEF8
mov  r0,r4
bl   $803E908
-
bl   .new_print_vram_container
mov  r0,r4
bl   $803E908
ldr  r0,=#0x2013040
ldrb r1,[r0,#2]                        //Unreal, two names with 21 letters on the same line
ldrb r2,[r0,#3]
cmp  r1,r2
bne  -
add  sp,#0xC
pop  {pc}

//=============================================================================================
// This hack fixes 8-letter names on the main file load screen.
//=============================================================================================

.filechoose_lengthfix:
str  r3,[sp,#0]     // clobbered code
// Address in r0. Return the length in r3.
push {r0,lr}
mov  r3,#9          // default value
bl   check_name     // see if it's a custom name
cmp  r0,#0
beq  +
mov  r3,r0
+
pop  {r0,pc}

//=============================================================================================
// This hack fixes the fact that if you lose the first battle Claus won't have any PP left
//=============================================================================================

claus_pp_fix:
.main:
push {lr}
lsl  r0,r0,#0x10             //Character identifier
lsr  r0,r0,#0x10
cmp  r0,#2                   //Lucas
beq  +
cmp  r0,#4                   //Kumatora
beq  +
cmp  r0,#0xD                 //Claus
bne  .failure
+
mov  r0,#1                   //Allow copying PPs
b    .end

.failure:                    //If it's not one of them, then they should not have PPs
mov  r0,#0

.end:
pop  {pc}

//=============================================================================================
// This set of hacks cleans the writing stack
//=============================================================================================

refreshes:
.main:
push {lr}
ldr  r1,=#0x2013040          //Address of the stack
mov  r0,#0
str  r0,[r1,#0x10]           //Clean the words' lengths so it won't print
str  r0,[r1,#0x14]
str  r0,[r1,#0x18]
str  r0,[r1,#0x1C]
pop  {pc}

.lr:
push {lr}
bl   .main
ldrh r1,[r5,#0xA]            //Normal stuff the game expects from us
ldr  r2,=#0x4264
pop  {pc}

.select:
push {lr}
bl   .main
mov  r0,#0xD2                //Normal stuff the game expects from us
bl   $800399C
pop  {pc}

.b:
push {lr}
bl   .main
mov  r0,#0xD3                //Normal stuff the game expects from us
bl   $800399C
pop  {pc}

.up_and_down:
push {r0-r2,lr}
bl   .main
//bl   $8046D90              //Normal stuff the game expects from us
bl   main_menu_hacks.up_down_scrolling_print
pop  {r0-r2,pc}

.status_a:
push {lr}
bl   .main
mov  r0,r4                   //Normal stuff the game expects from us
bl   $804EDFC
pop  {pc}

.inv_spec_a:
push {lr}
bl   .main
ldr  r1,=#0x426A             //Normal stuff the game expects from us
add  r0,r1,r7
pop  {pc}

.inv_block_a:
push {lr}
ldr  r0,=#0x2013040          //Have we finished printing?
ldrh r0,[r0,#0]
cmp  r0,#0
beq  .inv_block_a_passed     //Yes! Then let it do what it wants to do
pop  {r0}
ldr  r0,=#0x804CC35          //No! Prevent the game from opening stuff we don't want yet.
bx   r0

.inv_block_a_passed:
ldr  r0,=#0x2DFA             //Normal stuff the game expects from us
add  r1,r7,r0
pop  {pc}

.inv_submenu_block_a:
push {lr}
ldr  r0,=#0x2013040          //Have we finished printing?
ldrh r0,[r0,#0]
mov  r1,#0
cmp  r0,#0
bne  +
ldrh r1,[r4,#0]              //Normal input loading
+
mov  r0,#3
pop  {pc}


.memo_a:
push {lr}
bl   .main
mov  r0,r5                   //Normal stuff the game expects from us
bl   $804EEE8
pop  {pc}

.sell_a:
push {r2,lr}                 //Let's save r2, since the game needs it
bl   .main
pop  {r2}
mov  r0,r2                   //Normal stuff the game expects from us
bl   $804F0D4
pop  {pc}

.equip_a:
push {lr}
bl   .main
mov  r0,r4                   //Normal stuff the game expects from us
bl   $804EB68
pop  {pc}

.inv_submenu_a:
ldr  r0,=#0x804E84F          //We have to return here instead of where the call happened
push {r0}
bl   .main
bl   $804FCB0                //Normal stuff the game expects from us
pop  {pc}

.deposit_a:
push {lr}
bl   .main
mov  r0,r4                   //Normal stuff the game expects from us
bl   $804F1D8
pop  {pc}

.withdraw_a:
push {lr}
ldr  r1,=#0x201A294          //Check if the inventory is full. If it is, then the game won't print again and we need to let it do its thing. We need to manually increment this, as the original devs forgot to do it.
mov  r0,r1
ldrh r1,[r1,#0]
cmp  r1,#0x10
bge  +
add  r1,#1
strh r1,[r0,#0]
bl   .main
+
mov  r0,r5                   //Normal stuff the game expects from us
bl   $804F294
pop  {pc}

.inner_memo_scroll:
push {r1,lr}                 //Let's save r1, since the game needs it
bl   .main
pop  {r1}
mov  r0,r1                   //Normal stuff the game expects from us
bl   $804EF38
pop  {pc}

.inner_equip_a:
push {lr}
bl   .main
ldr  r7,=#0x2016028          //Normal stuff the game expects from us
ldr  r0,=#0x41C6
pop  {pc}

.inner_equip_scroll:
push {lr}
bl   .main
bl   $8046D90                //Normal stuff the game expects from us
pop  {pc}

.buy_lr:
push {lr}
bl   .main
ldrh r0,[r6,#4]              //Normal stuff the game expects from us
bl   $8053E98
pop  {pc}

.switch_lr:
push {lr}
bl   .main
ldrh r0,[r4,#4]              //Normal stuff the game expects from us
bl   $8053E98
pop  {pc}

.status_lr:
push {lr}
bl   .main
ldrh r1,[r4,#0xA]            //Normal stuff the game expects from us
ldr  r2,=#0x4264
pop  {pc}

//=============================================================================================
// This hack enables the "Delete all saves" prompt only once the fading in has ended
//=============================================================================================
fix_lag_delete_all:

.hack:
push {lr}
push {r0-r3}
ldr  r2,=#0x2016028
ldr  r0,=#0x41DA
add  r3,r2,r0
mov  r1,#0x12
sub  r1,r0,r1
add  r0,r1,r2                //Load the submenu we're in. 5 is a sub-submenu
ldrh r1,[r0,#4]              //Load the subscreen we're in. 0x1D is the "Delete all saves" one.
cmp  r1,#0x1D
bne  +
ldrh r1,[r0,#0]
cmp  r1,#5
bne  +
ldrb r0,[r3,#0]              //Make it so this is properly odded only once we can get the input
cmp  r0,#4
bne  +
mov  r1,#0x86
add  r1,r1,r3
ldrb r1,[r1,#0]
cmp  r1,#0x10                //Is this the file selection menu?
bne  +
mov  r1,#0x16
add  r1,r1,r3
ldrh r0,[r1,#0]
cmp  r0,#0x16                //Have a 6 frames windows for the fadein to properly end
bne  +

mov  r0,#5
strb r0,[r3,#0]

+

pop  {r0-r3}
ldrb r0,[r0,#0]              //Clobbered code
lsl  r0,r0,#0x1F
pop  {pc}
