; Build params: ------------------------------------------------------------------------------

CHEATS	set 1

; Constants: ---------------------------------------------------------------------------------
	MD_PLUS_OVERLAY_PORT:			equ $0003F7FA
	MD_PLUS_CMD_PORT:				equ $0003F7FE
	MD_PLUS_RESPONSE_PORT:			equ $0003F7FC

	RESET_VECTOR_ORIGINAL:			equ $00000206
	REGISTER_Z80_BUS_REQUEST:		equ $00A11100

	OFFSET_RESET_VECTOR:			equ $4
	OFFSET_COMMAND_HANLDER:			equ	$000021B8
	OFFSET_WOLFTEAM_INTRO_INCISION: equ	$000043EC

	Z80_RAM_AUDIO_COMMAND_INPUT:	equ	$00A01FFF
	Z80_RAM_AUDIO_SFX_PARAM_INPUT:	equ	$00A01FFE

	COMMAND_ALL_AUDIO_STOP1:		equ $E0
	COMMAND_ALL_AUDIO_STOP2:		equ $E1
	COMMAND_PAUSE_TOGGLE:			equ	$FF
	COMMAND_STOP:					equ	$FE
	COMMAND_FADE_OUT:				equ $FD
	COMMAND_RESUME:					equ	$80

	MUSIC_01:						equ	$01	; Marching Way (Stage 4 - Underground Cavern)	- LOOP
	MUSIC_02:						equ	$02	; Smashing Street (Stage 9 - Enemy Base)		- LOOP
	MUSIC_03:						equ	$03	; Bumpy Road (Stage 8 - Volcano)				- LOOP
	MUSIC_04:						equ	$04	; Windy Avenue (Stage 2 - Carrier)				- LOOP
	MUSIC_05:						equ	$05	; Good-bye 'Granada' (Ending Theme)				- NO LOOP
	MUSIC_06:						equ $06	; Hopping Express (Stage 3 - Underground City)	- LOOP
	MUSIC_07:						equ	$07	; Heavy Line (Stage 1 - Dead City)				- LOOP
	MUSIC_08:						equ	$08	; Quick Cepter (Timer Low)						- LOOP
	MUSIC_09:						equ	$09	; Mountain Path (Stage 6 - Fortress)			- LOOP
	MUSIC_10:						equ $0A	; Clap (Stages 1-4 Boss)						- LOOP
	MUSIC_11:						equ $0B	; Take a Chance (Stage 7 - Destroyed Base)		- LOOP
	MUSIC_12:						equ	$0C	; Tap (Stages 5-8 Boss)							- LOOP
	MUSIC_13:						equ	$0D	; Beat (Final Boss)								- LOOP
	MUSIC_14:						equ $0E	; Nature Trail (Stage 5 - Mountains)			- LOOP
	MUSIC_15:						equ	$0F	; Survivor Leon (Level Complete)				- NO LOOP
	MUSIC_16:						equ $10 ; Advance 'Granada' (Opening Theme)				- LOOP
	MUSIC_17:						equ	$11	; Broken Oath (Game Over)						- NO LOOP
	MUSIC_18:						equ $12	; IPL (Time Over)								- NO LOOP
;
; Overrides: ---------------------------------------------------------------------------------

	org OFFSET_RESET_VECTOR
	dc.l DETOUR_RESET_VECTOR

	org OFFSET_COMMAND_HANLDER
	jsr	COMMAND_HANDLER_DETOUR
	rept 3
		nop
	endr

	org OFFSET_WOLFTEAM_INTRO_INCISION
	jsr WOLFTEAM_INTRO_DETOUR_LOGIC

; Detours: -----------------------------------------------------------------------------------

	org $00080000
COMMAND_HANDLER_DETOUR
	cmpi.b	#COMMAND_PAUSE_TOGGLE,D0
	beq		CDDA_PAUSE_TOGGLE_LOGIC
	cmpi.b	#COMMAND_STOP,D0
	beq		CDDA_STOP_LOGIC
	cmpi.w	#COMMAND_FADE_OUT,D0
	beq		CDDA_FADE_OUT_LOGIC
	cmpi.b	#MUSIC_18,D0
	bgt		RETURN_FROM_DETOUR_LOGIC

CDDA_PLAY_LOGIC
	movem.w	D0-D1,-(SP)
	clr.w	D1
	move.b	D0,D1
.loop_table_difference
	move.b	LOOP_TABLE-.loop_table_difference-3(PC,D1),D0	; Load play command (loop or not) from trable
	rol.w	#$8,D0
	move.b	D1,D0
	jsr		WRITE_MD_PLUS_FUNCTION
	movem.w	(SP)+,D0-D1
	rts

LOOP_TABLE:
	dc.b	$12 ; MUSIC_01 - LOOP
	dc.b	$12 ; MUSIC_02 - LOOP
	dc.b	$12 ; MUSIC_03 - LOOP
	dc.b	$12 ; MUSIC_04 - LOOP
	dc.b	$11 ; MUSIC_05 - NO LOOP
	dc.b	$12 ; MUSIC_06 - LOOP
	dc.b	$12 ; MUSIC_07 - LOOP
	dc.b	$12 ; MUSIC_08 - LOOP
	dc.b	$12 ; MUSIC_09 - LOOP
	dc.b	$12 ; MUSIC_10 - LOOP
	dc.b	$12 ; MUSIC_11 - LOOP
	dc.b	$12 ; MUSIC_12 - LOOP
	dc.b	$12 ; MUSIC_13 - LOOP
	dc.b	$12 ; MUSIC_14 - LOOP
	dc.b	$11 ; MUSIC_15 - NO LOOP
	dc.b	$12 ; MUSIC_16 - LOOP
	dc.b	$11 ; MUSIC_17 - NO LOOP
	dc.b	$11 ; MUSIC_18 - NO LOOP

CDDA_PAUSE_TOGGLE_LOGIC
	andi.w	#$FF00,D0
	beq		CDDA_STOP_LOGIC
CDDA_RESUME_LOGIC
	movem.w	D0,-(SP)
	move.w	#$1400,D0
	jsr		WRITE_MD_PLUS_FUNCTION
	movem.w	(SP)+,D0
	jmp		RETURN_FROM_DETOUR_LOGIC

CDDA_STOP_LOGIC
	movem.w	D0,-(SP)
	move.w	#$1300,D0
	jsr		WRITE_MD_PLUS_FUNCTION
	movem.w	(SP)+,D0
	jmp		RETURN_FROM_DETOUR_LOGIC
	
CDDA_FADE_OUT_LOGIC
	movem.w	D0,-(SP)
	move.w	#$1375,D0
	jsr		WRITE_MD_PLUS_FUNCTION
	movem.w	(SP)+,D0
	jmp		RETURN_FROM_DETOUR_LOGIC

RETURN_FROM_DETOUR_LOGIC
	move.b	D0,Z80_RAM_AUDIO_COMMAND_INPUT.l
	move.b	D1,Z80_RAM_AUDIO_SFX_PARAM_INPUT.l
	rts

WOLFTEAM_INTRO_DETOUR_LOGIC
	move.w	#MUSIC_18,D0							; Implement signature track 18 into Wolfteam intro screen
	jsr		CDDA_PLAY_LOGIC
	lea		$FFB30E.l,A1
	rts

DETOUR_RESET_VECTOR
	move.w	#$1300,D0								; Move MD+ stop command into d1
	jsr		WRITE_MD_PLUS_FUNCTION
	incbin	"intro.bin"								; Show MD+ intro screen
	jmp		RESET_VECTOR_ORIGINAL					; Return to game's original entry point

; Helper Functions: --------------------------------------------------------------------------

WRITE_MD_PLUS_FUNCTION:
	move.w  #$CD54,(MD_PLUS_OVERLAY_PORT)			; Open interface
	move.w  D0,(MD_PLUS_CMD_PORT)					; Send command to interface
	move.w  #$0000,(MD_PLUS_OVERLAY_PORT)			; Close interface
	rts