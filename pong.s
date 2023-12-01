// These are addresses for the pixel buffer and text buffer
.EQU PIX_BUFFER, 0xc8000000
.EQU TEXT_BUFFER, 0xc9000000
.EQU BUTTON_BUFFER, 0xff200050
// These are some useful defines that will help you access structure fields
.EQU PIXMAP_WIDTH, 0
.EQU PIXMAP_HEIGHT, 2
.EQU PIXMAP_TRANSPARENCY, 4
.EQU PIXMAP_PIXELDATA, 6

// structure Pong
.EQU PONG_XPOS, 0
.EQU PONG_YPOS, 1
.EQU PONG_YVEL, 2

// structure Paddle
.EQU PADDLE_XPOS, 0
.EQU PADDLE_YPOS, 1
.EQU PADDLE_XVEL, 2

.global _start
_start:
	
	// Inital stack
	mov sp, #0x800000
	
	
inf_loop:
	ldr r0, =0x0

	// Place Your Test Code Here
	// clear the screen

	bl ClearTextBuffer
	
	ldr r0, =0x00ff
	bl ClearVGA
	
	bl DrawPong
	bl DrawPaddle
	
	bl UpdtPong
	bl UpdtPaddle
	
	b inf_loop
	
GameOverInf:
	ldr r0, =0x0
	
	b GameOverInf
	
// Functions for game
DrawPong:
	// prologue
	push {r4, lr}
	ldr r4, =Pong
	ldr r0, =PongPix
	ldrb r1, [r4, #PONG_XPOS] // loading the x-pos
	ldrb r2, [r4, #PONG_YPOS] // loading the y-pos
	bl BitBlit
	//epilogue
	pop {r4, pc}
	
UpdtPong:
	// prologue
	push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	//bl ClearTextBuffer
	ldr r0, =Pong // loading the Pong struct
	ldr r1, =PongPix // loading the Pong PixMap
	ldrb r4, [r0, #PONG_XPOS] // loading the x-pos
	ldrb r5, [r0, #PONG_YPOS] // loading the y-pos
	ldrsb r6, [r0, #PONG_YVEL] // loading the y-vel
	ldrh r7, [r1, #PIXMAP_WIDTH]
	ldrh r8, [r1, #PIXMAP_HEIGHT]
	add r5, r5, r6 // updtYPos
	// if (updtYPos <= 0) change vel and y-pos goes to 0
	sub r9, r5, r8, lsr #1 // checking the upper bound of pixmap
	sub r9, r9, #1 // finalizing upper bound
	cmp r9, #0
	bge UpdtPong1
	// updating the velocity and the y-pos
	mov r5, #0
	add r5, r5, r8, lsr #1
	add r5, r5, #1
	rsb r6, r6, #0
	strb r6, [r0, #PONG_YVEL]	
UpdtPong1:
	// if (updtYPos >= 240) game over
	add r9, r5, r8, lsr #1 // checking the lower bound of pixmap
	cmp r9, #240
	ble UpdtPong2
	// print game over
	mov r0, #35
	mov r1, #30
	ldr r2, =GameOver
	bl DrawStr
	bl GameOverInf
UpdtPong2:
	// if (updtYPos <= paddle y-pos) print
	ldr r0, =PaddlePix
	// loading the width and height of the paddle
	ldrh r1, [r0, #PIXMAP_WIDTH]
	ldrh r2, [r0, #PIXMAP_HEIGHT]
	lsr r1, #1 // half the width
	lsr r2, #1 // half the height
	// loading the x and y pos of the paddle
	ldr r0, =Paddle
	ldrb r10, [r0, #PADDLE_XPOS] // paddle x-pos
	ldrb r11, [r0, #PADDLE_YPOS] // paddle y-pos
	add r9, r5, r8, lsr #1 // checking the lower bound of pixmap
	add r11, r11, #1
	add r11, r11, r2
	cmp r9, r11
	bge UpdtPong3
	b UpdtPongEpilogue
UpdtPong3:
	// checking to see if the x-positions intersect
	// updating the velocity and the y-pos
	// come back and update the y-pos to right on top of the paddle
	// if the right bound is less than or equal to the left bound continue
	add r9, r4, r7, lsr #1 // checking the right bound of pong
	sub r10, #1
	sub r10, r10, r1
	cmp r9, r10
	blt UpdtPongEpilogue
	sub r9, r4, r7, lsr #1 // checking the left bound of pong
	sub r9, r9, #1
	ldrb r10, [r0, #PADDLE_XPOS] // reset load the paddle x-pos to center
	add r10, r1
	cmp r9, r10
	bgt UpdtPongEpilogue
	//// **come back and figure out where to properly draw the pong**
	sub r5, r5, r6
	rsb r6, r6, #0
	ldr r0, =Pong // reloading the Pong struct
	strb r6, [r0, #PONG_YVEL]
UpdtPongEpilogue:	//epilogue
	ldr r0, =Pong // reloading the Pong struct
	strb r5, [r0, #PONG_YPOS]
	pop {r4, r5, r6, r7, r8, r9, r10, r11, pc}
	
DrawPaddle:
	// prologue
	push {r4, lr}
	ldr r4, =Paddle 
	ldr r0, =PaddlePix
	ldrb r1, [r4, #PADDLE_XPOS] // loading the x-pos
	ldrb r2, [r4, #PADDLE_YPOS] // loading the y-pos
	bl BitBlit
	//epilogue
	pop {r4, pc}	

UpdtPaddle:
	// prologue
	push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	ldr r0, =Paddle // loading the Paddle struct
	ldr r1, =PaddlePix // loading the Paddle PixMap
	ldrb r4, [r0, #PADDLE_XPOS] // loading the x-pos
	ldrsb r5, [r0, #PADDLE_XVEL] // loading the x-vel
	ldrh r6, [r1, #PIXMAP_WIDTH]
	add r4, r4, r5 // updtXPos
	// if (updtXPos <= 0) change vel
	sub r7, r4, r6, lsr #1 // checking the left bound of pixmap
	sub r7, r7, #1 // finalizing upper bound
	cmp r7, #0
	bge UpdtPaddle1
	// updating the velocity and the x-pos
	mov r4, #0
	add r4, r4, r6, lsr #1
	add r4, r4, #1
	rsb r5, r5, #0
	strb r5, [r0, #PADDLE_XVEL]
	add r4,r4,r5
UpdtPaddle1:
	add r7, r4, r6, lsr #1 // checking the right bound of paddle
	cmp r7, #260
	blt UpdtPaddle2
	// updating the velocity and the x-pos
	mov r4, #260
	sub r4, r4, r6, lsr #1
	rsb r5, r5, #0
	strb r5, [r0, #PADDLE_XVEL]
	//sub r4,r4,r5
UpdtPaddle2:
	ldr r8, =BUTTON_BUFFER
	ldr r9, [r8]
	cmp r9, #1
	bne UpdtPaddleEpilogue
	rsb r5, r5, #0
	strb r5, [r0, #PADDLE_XVEL]
	mov r9, #0
	str r9, [r8, #0]
	
UpdtPaddleEpilogue:	//epilogue
	strb r4, [r0, #PADDLE_XPOS]
	pop {r4, r5, r6, r7, r8, r9, r10, r11, pc}	
	
// Write your ClearTextBuffer, ClearVGA, and BitBlit routines below!
.align 4
ClearTextBuffer:
	// Clears the text buffer by filling it with spaces (ASCII 0x20).
	// prologue
	push {r4, r5, r6, r7, r8, lr}
	ldrb r4, =0x20 // ASCII for space
	ldr r5, =TEXT_BUFFER // CHARBUFFER
	mov r6, #0 // x-coord
	mov r7, #0 // y-coord
	b ClearTextBufferCond
ClearTextBufferBody:
	add r8, r6, r7, lsl #7 // this is the location
	strb r4, [r5, r8] // printing out the space
	add r6, r6, #1 // incrementing the x-pos
ClearTextBufferCond:
	cmp r6, #80 // checking to see if x-pos is less than 80
	blt ClearTextBufferBody
	mov r6, #0 // if we got here then reset x-pos
	add r7, r7, #1 // also increment the y-pos
	cmp r7, #60 // check to see if we completed the entire screen
	blt ClearTextBufferBody
	//epilogue
	pop {r4, r5, r6, r7, r8, pc}

.align 2
ClearVGA:
	// r0 - color : uint
	// Clears the video buffer by filling it with the given color value.
	// prologue
	push {r4, r5, r6, r7, r8, lr}
	mov r4, r0 // stores the given color value into r4
	ldr r5, =PIX_BUFFER // loads the pixel buffer into r5
	mov r6, #0 // x-pos variable
	mov r7, #0 // y-pos variable
	b ClearVGACond
ClearVGABody:
	add r8, r6, r7, lsl #7 // storing the x-pos and y-pos into r8
	lsl r8, #1 // finalizing the location
	strh r4, [r5, r8] // printing the new color
	add r6, r6, #1 // incrementing the x-pos
ClearVGACond:
	cmp r6, #320 // checking to see if x-pos is less than 320
	blt ClearVGABody
	mov r6, #0 // if we got here then reset x-pos
	add r7, r7, #4 // also increment the y-pos
	ldr r1, =960
	cmp r7, r1 // check to see if we completed the entire screen
	blt ClearVGABody
	//epilogue
	pop {r4, r5, r6, r7, r8, pc}


.align 2
BitBlit:
	// r0 - pmap : pixmap_ptr
	// r1 - x : int 
	// r2 - y : int
	push {r4, r5, r6, r7, r8, r9, r10, r11, lr}
	ldrb r5, [r0, #PIXMAP_WIDTH] // pixmap_width
	ldrb r6, [r0, #PIXMAP_HEIGHT] // pixmap_height
	//mov r5, #8
	//mov r6, #8
	mov r7, #-1 // this is the pixel x-pos
	mov r8, #0 // this is the pixel y-pos
	b BitBlitPixelCond
BitBlitBody:
	ldrh r4, [r0, #PIXMAP_TRANSPARENCY]
	cmp r4, r9
	beq BitBlitPixelCond
	ldr r4, =PIX_BUFFER // loads the pixel buffer
	strh r9, [r4, r11]
BitBlitPixelCond:
	// getting the proper pixel data location
	add r7, r7, #1 // increment the pixel x-pos
	cmp r7, r5 // making sure that we haven't reached the end of the pixel row
	blt BitBlitVGACond
	mov r7, #0 // reset the pixel x-pos for the next row
	add r8, r8, #1 // increment the pixel y-pos
	cmp r8, r6 // making sure that we haven't completed the pixel data
	beq BitBlitEpilogue
BitBlitVGACond:	 
	// loading the proper pixel
	mov r10, #2
	mul r10, r7, r10 // multiplying the pixel x-pos by 2 to account for correct halfword
	mov r11, #2
	mul r11, r8, r11 // multiplying the pixel y-pos by 2 to account for correct halfword
	mul r9, r11, r5 // multiply the pixel y-pos by the pixel width
	add r9, r9, r10 // add the x-pos
	add r9, r9, #PIXMAP_PIXELDATA // finalize pixel pos in pixel data
	ldrh r9, [r0,r9] // load the pixel into r9
	// getting the proper VGA x-pos and checking if within bounds
	sub r10, r1, #1 // subtract 1 to the center
	sub r10, r10, r5, lsr #1 // subtract the x-pos by the half the width
	add r10, r10, r7 // add the current pixel x-pos
	cmp r10, #0 // checking if x-pos is negative
	blt BitBlitPixelCond
	cmp r10, #320 // checking if x-pos exceeds VGA x-limit
	bge BitBlitPixelCond
	// getting the proper VGA y-pos and checking if within bounds
	sub r11, r2, #1 // subtract 1 to the center
	sub r11, r11, r6, lsr #1 // subtract the y-pos by the half the width
	add r11, r11, r8 // add the current pixel y-pos
	cmp r11, #0 // checking if y-pos is negative
	blt BitBlitPixelCond
	ldr r4, =960
	cmp r11, r4 // checking if y-pos exceeds VGA y-limit
	bge BitBlitEpilogue
	// At this point we have the x-pos, y-pos, and the pixel
	// getting the proper position into r11
	mov r4, #4
	mul r11, r11, r4
	add r11, r10, r11, lsl #7 // storing the x-pos and y-pos into r8
	lsl r11, #1 // finalizing the location
	b BitBlitBody
BitBlitEpilogue:
	pop {r4, r5, r6, r7, r8, r9, r10, r11, pc}
	

// previous code from Assignment 2
MyStr:
    .string "Hello world!"

.align 4

GameOver:
    .string "Game Over!"

.align 4


// Place your implementations for DrawStr and DrawNum here
DrawStr:
	// Draws a string (s – null terminated) at screen column x, row y
	// r0 - x
	// r1 - y
	// r2 - s
	push {r4,r5,r6,r7,lr}
	add r6, r0, r1, lsl #7 // this is the location
	ldr r5, =CHARBUF 
	b DrawStr_Cond
DrawStr_Body:
	strb r4, [r5,r6]
	add r2, r2, #1
	add r6, r6, #1
DrawStr_Cond:
	// checking that the y coord is less than 60
	cmp r1,#CHAR_HEIGHT
	bge DrawStr_Epilogue
	// checking that the x coord is less than 80
	mov r7, #0xff
	and r7, r6, r7, lsr #1
	cmp r7,#CHAR_WIDTH
	bge DrawStr_Epilogue
	// checking for the null terminator
	ldrb r4, [r2]
	cmp r4, #0
	bne DrawStr_Body
	b DrawStr_Epilogue
DrawStr_Epilogue:
	pop {r4,r5,r6,r7,lr}
	bx lr
		
	
DrawNum:
	// Draws an integer (decimal/base 10) value (n – signed int) 
	// at screen column x, row y
	// r0 - x
	// r1 - y
	// r2 - n
	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	ldr r5, =CHARBUF // loading CHARBUF to r5
	add r6, r0, r1, lsl #7
	mov r7, #ASCII_ZERO
	mov r4,r2 // storing n in r4
	cmp r4,#0 // checking if n is negative
	blt DrawNum_Neg
	cmp r4,#0 // checking if n is negative
	blt DrawNum_Neg
	// reversing the digits
	mov r0,r4
	bl ReverseDigits
	mov r4,r0
	// preparing for GetnextNum_Func
	mov r9, #0
	mov r10, r4
	cmp r4,#0 // checking if n is zero
	bne DrawNum_GetNextNum_Condition
DrawNum_PrintZero:
	mov r8, r7
	b DrawNum_Print 
DrawNum_Print:
	// checking that the y coord is less than 60
	cmp r1,#CHAR_HEIGHT
	bge DrawNum_Epilogue
	// checking that the x coord is less than 80
	mov r9, #0xff
	and r9, r6, r9, lsr #1
	cmp r9,#CHAR_WIDTH
	bge DrawNum_Epilogue
	// printing number then incrementing
	strb r8, [r5,r6]
	add r6, r6, #1
	// done printing
	mov r9, #0
	mov r10, r4
	cmp r4,#0 // checking if n is zero
	bne DrawNum_GetNextNum_Condition
	b DrawNum_Epilogue
DrawNum_Neg:
	mvn r4,r4
	add r4,r4,#1
	sub r8, r7, #3
	mov r0,r4
	bl ReverseDigits
	mov r4,r0
	b DrawNum_Print
DrawNum_GetNextNum:
	sub r10, r10, #10
	add r9,r9,#1
DrawNum_GetNextNum_Condition:
	cmp r10,#10
	bge DrawNum_GetNextNum
	// getting k
	lsl r11, r9, #3
	add r11, r11, r9
	add r11, r11, r9
	// getting the proper num in r8
	sub r4,r4,r11
	add r8,r7,r4
	
	mov r4, r9
	b DrawNum_Print
DrawNum_Epilogue:	
	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
	
ReverseDigits:
	push {r4,r5,r6,r7,r8,r9,lr}
	mov r4, r0
	mov r5, #0
	mov r8, #0
	cmp r4, #0
	beq ReverseDigits_Epilogue
ReverseDigits_Div:	
	sub r4, r4, #10
	add r5, r5,#1
ReverseDigits_Condition:
	cmp r4,#10
	bge ReverseDigits_Div
	// getting remainder
	lsl r6, r5, #3
	add r6, r6, r5
	add r6, r6, r5
	// adding the new digit to the current
	sub r7,r0,r6
	add r8,r8,r7
	// multiplying r8 by 10, then adding new digit
	lsl r9, r8, #3
	add r9, r9, r8
	add r9, r9, r8
	mov r8, r9
	// update the digit
	mov r4, r5
	mov r0, r5
	mov r5, #0
	cmp r4,#10
	bge ReverseDigits_Div
	add r8,r8,r4
	// storing the result
	mov r0, r8
ReverseDigits_Epilogue:
	pop {r4,r5,r6,r7,r8,r9,pc}
	
// Feel free to use helpful constants below
.equ ASCII_ZERO, 48

// **** DO NOT MODIFY ANYTHING BELOW ****

// 320x240, 1024 bytes/row, 2 bytes per pixel: DE1-SoC
.equ WIDTH, 320
.equ HEIGHT, 240
.equ BUFFER_SIZE, 1024 * 240
.equ LOG2_BYTES_PER_ROW, 10
.equ LOG2_BYTES_PER_PIXEL, 1

.equ CHAR_WIDTH, 80
.equ CHAR_HEIGHT, 60

.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ CHARBUF, 0xc9000000	// Character buffer

init:
	ldr sp, =0x800000	// Initial stack pointer	
	bx lr

BlankScreen:
	// Blanks the screen
	
    ldr r3, =PIXBUF
    mov r2, #0
	mov r0, #0
BlankScreen_Loop:
	mov r1, #0
BlankScreen_RowLoop:
    str r2, [r3, r1]
	add r1, r1, #4
    cmp r1, #640
    blo  BlankScreen_RowLoop
	add r3, r3, #1024
	add r0, r0, #1
	cmp r0, #240
	blo BlankScreen_Loop
    bx lr
	

DrawPixel:
	// Draws a single pixel at (r0, r1) with color r2
	// r0 - x
	// r1 - y
	// r2 - color
	lsl r1, #LOG2_BYTES_PER_ROW
	lsl r0, #LOG2_BYTES_PER_PIXEL
	add r0, r0, r1
	ldr r1, =PIXBUF
	strh r2, [r1, r0]
	bx lr

DrawStar:
	// Draws a single star at (r0, r1) of size r2
	// r0 - x center
	// r1 - y center
	// r2 - size (1,2)
	push {r4, r5, r6, r7, lr}
	mov r4, r0
	mov r5, r1
	mov r6, r2

	mvn r2, #0
	bl DrawPixel

	cmp r6, #1
	beq DS0
	
	add r0, r4, #0
	add r1, r5, #1
	mvn r2, #0
	bl DrawPixel

	add r0, r4, #1
	add r1, r5, #0
	mvn r2, #0
	bl DrawPixel

	add r0, r4, #1
	add r1, r5, #1
	mvn r2, #0
	bl DrawPixel

DS0:
	pop {r4, r5, r6, r7, lr}
	bx lr
	
// structures
Pong:
	.byte 150, 150, -10
	
Paddle:
	.byte 150, 200, 10
	

.data
SimplePix:
	.hword 8, 8, 0xfffe
	.hword 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xfffe, 0xfffe, 0xfffe, 0xfffe, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xfffe, 0xfffe, 0xfffe, 0xfffe, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xfffe, 0xfffe, 0xfffe, 0xfffe, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xfffe, 0xfffe, 0xfffe, 0xfffe, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4
	.hword 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4, 0xc4c4

PaddlePix:
	.hword 16, 4, 0x0000
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	
PongPix:
	.hword 4, 4, 0x0000
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.hword 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff