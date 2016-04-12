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
	
	lda #8		;sprite y coordinate
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	
	lda #24		;sprite x coordinates
	sta $d000
	adc #48
	sta $d002
	adc #48
	sta $d004
	adc #48
	sta $d006
	adc #48
	sta $d008
	adc #48
	sta $d00a
	adc #48
	sta $d00c

	lda #%01100000	;msb of sprites x coordinate
	sta $d010

	lda #%01111111	;enable sprites
	sta $d015
	lda #%01111111	;expand sprites
	sta $d017
	sta $d01d
	
	lda #$80	;sprite memory: 128*64 = 8192, 129*64 = ...
	ldx #0
l1	sta $07f8,x
	adc #1
	inx
	cpx #7
	bne l1
	
	lda #%011	;switch in character rom
	sta $1
	
	ldx #0		;copy characters from rom to ram
l2	lda $d000,x
	sta $3000,x
	inx
	bne l2
	
	lda #%111	;switch out character rom
	sta $1

	rts

int	lda #1		;reset raster interrupt bit
	sta $d019

	lda $d011
	and #%10000000
	ora $d012
	beq rl0		;raster line 0?

	lda #0
	sta $d012	;set next interrupt at raster line 0

	lda $d011	;set 24-row mode
	and #%11110111
	sta $d011
	
	jsr scroll	;scroll sprite pixels
	
	lda pi
	adc #1
	and #%111
	sta pi
	bne done
	
	ldy texti	;output next character
	lda text,y
	bne chrout
	ldy #0
	sty texti
	lda text,y
chrout	inc texti
	asl		;multiply by 8
	asl
	asl
	tax
	lda $3000,x
	sta $2182
	lda $3001,x
	sta $2185
	lda $3002,x
	sta $2188
	lda $3003,x
	sta $218b
	lda $3004,x
	sta $218e
	lda $3005,x
	sta $2191
	lda $3006,x
	sta $2194
	
done	jmp $ea31

rl0	lda #249
	sta $d012	;set next interrupt at raster line 249

	lda $d011
	ora #%1000	;set 25-row mode
	sta $d011
	jmp $ea81

scroll	rol $2182	;line 1
	rol $2181
	rol $2180
	rol $2142
	rol $2141
	rol $2140
	rol $2102
	rol $2101
	rol $2100
	rol $20c2
	rol $20c1
	rol $20c0
	rol $2082
	rol $2081
	rol $2080
	rol $2042
	rol $2041
	rol $2040
	rol $2002
	rol $2001
	rol $2000
	clc

	rol $2185	;line 2
	rol $2184
	rol $2183
	rol $2145
	rol $2144
	rol $2143
	rol $2105
	rol $2104
	rol $2103
	rol $20c5
	rol $20c4
	rol $20c3
	rol $2085
	rol $2084
	rol $2083
	rol $2045
	rol $2044
	rol $2043
	rol $2005
	rol $2004
	rol $2003
	clc
	
	rol $2188	;line 3
	rol $2187
	rol $2186
	rol $2148
	rol $2147
	rol $2146
	rol $2108
	rol $2107
	rol $2106
	rol $20c8
	rol $20c7
	rol $20c6
	rol $2088
	rol $2087
	rol $2086
	rol $2048
	rol $2047
	rol $2046
	rol $2008
	rol $2007
	rol $2006
	clc
	
	rol $218b	;line 4
	rol $218a
	rol $2189
	rol $214b
	rol $214a
	rol $2149
	rol $210b
	rol $210a
	rol $2109
	rol $20cb
	rol $20ca
	rol $20c9
	rol $208b
	rol $208a
	rol $2089
	rol $204b
	rol $204a
	rol $2049
	rol $200b
	rol $200a
	rol $2009
	clc

	rol $218e	;line 5
	rol $218d
	rol $218c
	rol $214e
	rol $214d
	rol $214c
	rol $210e
	rol $210d
	rol $210c
	rol $20ce
	rol $20cd
	rol $20cc
	rol $208e
	rol $208d
	rol $208c
	rol $204e
	rol $204d
	rol $204c
	rol $200e
	rol $200d
	rol $200c
	clc

	rol $2191	;line 6
	rol $2190
	rol $218f
	rol $2151
	rol $2150
	rol $214f
	rol $2111
	rol $2110
	rol $210f
	rol $20d1
	rol $20d0
	rol $20cf
	rol $2091
	rol $2090
	rol $208f
	rol $2051
	rol $2050
	rol $204f
	rol $2011
	rol $2010
	rol $200f
	clc

	rol $2194	;line 7
	rol $2193
	rol $2192
	rol $2154
	rol $2153
	rol $2152
	rol $2114
	rol $2113
	rol $2112
	rol $20d4
	rol $20d3
	rol $20d2
	rol $2094
	rol $2093
	rol $2092
	rol $2054
	rol $2053
	rol $2052
	rol $2014
	rol $2013
	rol $2012
	clc

	rts

pi	.byte 0
texti	.byte 0
text	.screen "this is a string of text scrolling across the screen "
	.byte 0
