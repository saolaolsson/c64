* = $0801

	.word	$080b	;next line
	.word	$0001	;line number
	.byte	$9e	;basic command sys
	.text	"2061"	;basic command sys argument
	.byte	0	;end of line
	.word	0	;end of program

	sei		;set interrupt handler
	lda #<inth
	sta $0314
	lda #>inth
	sta $0315
	cli
	
	lda $d011	;reset bits 0-8 of raster interrupt line
	and #%01111111
	sta $d011	
	lda #0
	sta $d012
	lda #1		;enable raster interrupt
	sta $d01a
	rts

inth	lda $d019	;raster interrupt?
	and #1
	bne rint
	jmp $ea31	;no, skip to default interrupt handler
	
rint	sta $d019	;acknowledge raster interrupt
	
	lda $d012
	cmp #58
	bcc pixscrl
	
	lda #%1000	;at raster line 58
	sta $d016
	lda #0		;set next interrupt at raster line 0
	sta $d012
	jmp $ea81

pixscrl	lda #58		;set next interrupt at raster line 58
	sta $d012

	lda scrpos	;smooth scroll
	sec
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
