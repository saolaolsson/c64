* = $0801

	.word	$080b	;next line
	.word	$0001	;line number
	.byte	$9e	;basic command sys
	.text	"2061"	;basic command sys argument
	.byte	0	;end of line
	.word	0	;end of program

	sei		;set interrupt pointer
	lda #<int
	sta $0314
	lda #>int
	sta $0315
	cli
	
	lda #$7f
	sta $dc0d	;turn off timer interrupt
	lda $d011
	and #%01111111
	sta $d011	;reset bit 8 of raster interrupt line
	lda #0
	sta $d012	;reset bits 0-7 of raster interrupt line
	lda #1
	sta $d01a	;enable raster interrupt
	rts

int	lda #1
	sta $d019	;reset raster interrupt bit

	lda $d011
	and #%10000000
	ora $d012
	beq pixscrl	;raster line 0?

	lda #0
	sta $d012	;set next interrupt at raster line 0
	lda #%1000
	sta $d016	;reset horizontal screen position
	jmp $ea31

pixscrl	lda #58
	sta $d012	;set next interrupt at raster line 58

	lda scrpos	;smooth scroll
	sbc #1
	and #%111
	sta $d016
	sta scrpos
	bcs return
	
	ldx #0		;shift line one character
chrloop	lda $0401,x	
	sta $0400,x
	inx
	cpx #40
	bne chrloop
	
	ldy texti	;output next character
	lda text,y
	bne chrout
	ldy #0
	sty texti
	lda text,y
chrout	sta $0427	;last column on first line
	inc texti
return	jmp $ea81

scrpos	.byte 0
texti	.byte 0
text	.screen "this is a string of text scrolling across the screen "
	.byte 0
