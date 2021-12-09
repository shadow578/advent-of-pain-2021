; Advent of Code Day 6 Puzzle 1 (and 2) written in 6502 assembly.
; use https://www.masswerk.at/6502/assembler.html to assemble and run
; made with reference to https://www.c64-wiki.de/wiki/%C3%9Cbersicht_6502-Assemblerbefehle
;
; this version uses 16 bit variables. As such, it cannot calculate the actual puzzle solution (since it is > 2^16)
; but it works fine with the test data, and is pretty similar to the 64 bit version.
; 
; RAM starts at address $200 (defined at the bottom of the file, see ;;RAM;;), but may be moved when needed.
; This program is designed to actually be able to run on real (-ish) hardware, provided you can actually read the result from memory after it finished.
; 
; The result of the computation (= the puzzle answer) is stored at the top of RAM (at $200), LO- byte first.
; expected results (for test input):
; 18 days  -> 26    --> $0200: 1A 00
; 80 days  -> 5934  --> $0200: 2E 17


; the start of our binary, at address $0
.ORG $0
entry:
 ; copy FISH_INPUT_AGES to FISH_AGES 
 LDX #$00                   ; load 0 into X (current value)
copy_fish_input:
 ; copy FISH_INPUT_AGES[X] to FISH_AGES[X] (LO+HI byte)
 LDA FISH_INPUT_AGES,X      ; LO
 STA FISH_AGES,X
 INX
 LDA FISH_INPUT_AGES,X      ; HI
 STA FISH_AGES,X
 INX

 ; check if X is 9*2 (we'd be setup to copy age 9, so we just copied age 8)
 ; if so, go back to age_down (X incremented)
 CPX #18
 BNE copy_fish_input

 ; zero variables (cannot rely on RAM beign cleared)
 LDA #$00
 STA RESULT
 STA RESULT+1
 STA FISH_TO_REPRODUCE
 STA FISH_TO_REPRODUCE+1
 STA CURRENT_DAY


 ; main simulation loop
day_loop:
 ; save the number of fish that will reproduce on this day for later use
 LDA FISH_AGES              ; LO byte
 STA FISH_TO_REPRODUCE
 LDA FISH_AGES+1            ; HI byte
 STA FISH_TO_REPRODUCE+1


 ; age down all fish by copying all values n to n-1, where n is element of [1, 8]
 LDX #$00                   ; load 0 into X (target)
 LDY #$02                   ; load 2 into Y (source)
age_down:
 ; copy FISH_AGES[Y] to FISH_AGES[X] (LO+HI byte)
 LDA FISH_AGES,Y            ; age Y, LO
 STA FISH_AGES,X            ; age X, LO
 INX
 INY
 LDA FISH_AGES,Y            ; age Y, HI
 STA FISH_AGES,X            ; age X, HI
 INX
 INY

 ; check if Y (source age) is 9*2 (so we just copied age 8 to 7)
 ; if not, go back to age_down (with X and Y incremented)
 CPY #18
 BNE age_down


 ; add adult fish that just reproduced to pool of age 6
 CLC                        ; clear carry bit
 LDA FISH_AGES+12           ; load count of fish with age = 6 into A register (LO- byte)
 ADC FISH_TO_REPRODUCE      ; add FISH_TO_REPRODUCE to A (LO- byte)
 STA FISH_AGES+12           ; store updated value (LO- byte)
 LDA FISH_AGES+13           ; load count of fish with age = 6 into A register (HI- byte)
 ADC FISH_TO_REPRODUCE+1    ; add FISH_TO_REPRODUCE to A, with carry from LO- byte (HI- byte) 
 STA FISH_AGES+13           ; store updated value (HI- byte)


 ; newborn fish are age 8
 ; since 8 is our maximum age, and we just aged all our fish,
 ; we can just assign FISH_TO_REPRODUCE to FISH_AGES[8] (LO+HI byte, ofc)
 LDA FISH_TO_REPRODUCE      ; LO
 STA FISH_AGES+16           ; age 8 LO 
 LDA FISH_TO_REPRODUCE+1    ; HI
 STA FISH_AGES+17           ; age 8 HI


 ; increment CURRENT_DAY
 INC CURRENT_DAY

 ; jump to start if CURRENT_DAY != DAYS_TO_SIMULATE
 LDA CURRENT_DAY
 CMP DAYS_TO_SIMULATE
 BNE day_loop


 ; add the fish population together
 LDX #$00                   ; start at age 0
pop_add_loop:
 ; add fish of age X to the result
 CLC                        ; clear carry bit
 LDA FISH_AGES,X            ; age X, LO
 ADC RESULT                 ; add result to A, LO
 STA RESULT                 ; store new RESULT, LO
 INX
 LDA FISH_AGES,X            ; age X, HI
 ADC RESULT+1               ; add result to A, HI
 STA RESULT+1               ; store new RESULT, HI
 INX

 ; check if X is 9*2 (we're at the end of our 'array')
 CPX #18
 BNE pop_add_loop

 ; we're done! halt the CPU
 BRK




;; INPUTS ;;
; how many fish there are of each age (9 * 2 bytes each)
; this is the (preprocessed) input for the puzzle
; to get the number of fish in each age group, use the following:
; LDA FISH_INPUT_AGES+(2n)   ; to load LO byte of fish of age n into A
; LDA FISH_INPUT_AGES+(2n+1) ; to load HI byte of fish of age n into A
; test input: [0,   1,  1,  2,  1,   0,  0,  0, 0]
; real input: [0, 107, 45, 49, 49,  50,  0,  0, 0]
; Note: the assembler shortens the label names to 8 chars, so we have to use a weird name here...
FISH_INPUT_AGES:
 .WORD #0 ; age 0
 .WORD #1 ; age 1
 .WORD #1 ; age 2
 .WORD #2 ; age 3
 .WORD #1 ; age 4
 .WORD #0 ; age 5
 .WORD #0 ; age 6
 .WORD #0 ; age 7
 .WORD #0 ; age 8

; how many days we should simulate (1 byte)
DAYS_TO_SIMULATE:
 .BYTE #18


;; RAM ;;
; RAM starts at $200

; the result of the computation (2 bytes)
RESULT = $0200

; how many fish there are of each age (9 * 2 bytes == 16)
; this contains the current numbers that are worked with by the CPU
; to get the number of fish in each age group, use the following:
; LDA FISH_AGES+(2n)   ; to load LO byte of fish of age n into A
; LDA FISH_AGES+(2n+1) ; to load HI byte of fish of age n into A
FISH_AGES = $0202

; the current day of the simulation (1 byte)
CURRENT_DAY = $0214

; how many fish will reproduce on the current day (2 bytes)
FISH_TO_REPRODUCE = $0215
