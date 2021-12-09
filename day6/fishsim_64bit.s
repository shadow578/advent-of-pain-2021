; Advent of Code Day 6 Puzzle 1 (and 2) written in 6502 assembly.
; use https://www.masswerk.at/6502/assembler.html to assemble and run
; made with reference to https://www.c64-wiki.de/wiki/%C3%9Cbersicht_6502-Assemblerbefehle
; 
; this version uses 64 bit variables. As such, it is able to calculate the actual puzzle solution for both part 1 and 2.
; it is, however, a bit slower and somewhat more complex than the 16 bit version.
;
; RAM starts at address $200 (defined at the bottom of the file, see ;;RAM;;), but may be moved when needed.
; This program is designed to actually be able to run on real (-ish) hardware, provided you can actually read the result from memory after it finished.
; 
; The result of the computation (= the puzzle answer) is stored at the top of RAM (at $200), LO- byte first.
; expected results (for test input):
; 18 days  -> 26    --> $0200: 1A 00 00 00 00 00 00 00
; 80 days  -> 5934  --> $0200: 2E 17 00 00 00 00 00 00


; the start of our binary, at address $0
.ORG $0
entry:
 ; copy FISH_INPUT_AGES to FISH_AGES 
 LDX #$00                   ; load 0 into X (output offset)
 LDY #$00                   ; load 0 into Y (input offset)
copy_fish_input:
 ; copy FISH_INPUT_AGES[X] to FISH_AGES[X] (LO to A, HI to B, rest zero)
 LDA FISH_INPUT_AGES,Y      ; LO -> A
 STA FISH_AGES,X
 INX
 INY
 LDA FISH_INPUT_AGES,Y      ; HI -> B
 STA FISH_AGES,X
 INX
 INY
 LDA #$00
 STA FISH_AGES,X            ; 0 -> C
 INX
 STA FISH_AGES,X            ; 0 -> D
 INX
 STA FISH_AGES,X            ; 0 -> E
 INX
 STA FISH_AGES,X            ; 0 -> F
 INX
 STA FISH_AGES,X            ; 0 -> G
 INX
 STA FISH_AGES,X            ; 0 -> H
 INX

 ; check if Y is 9*2 (we'd be setup to copy age 9, so we just copied age 8)
 ; if so, go back to age_down (X and Y are incremented)
 CPY #18
 BNE copy_fish_input

 ; zero variables (cannot rely on RAM beign cleared)
 LDA #$00                   ; load 0 into A
 STA CURRENT_DAY            ; clear CURRENT_DAY (LO, HI)
 STA CURRENT_DAY+1
 LDX #$00
clear_result_loop:          ; clear RESULT and FISH_TO_REPRODUCE (A, B, C, D, E, F, G, H)
 STA RESULT,X               
 STA FISH_TO_REPRODUCE,X 
 INX                        ; increment X
 CPX #8                     ; until we cleared offset 7
 BNE clear_result_loop


 ; main simulation loop
day_loop:
 ; save the number of fish that will reproduce on this day for later use
 LDX #$00
adult_fish_copy_loop:
 LDA FISH_AGES,X            ; load FISH_AGES[0], Xth byte
 STA FISH_TO_REPRODUCE,X    ; save into FISH_TO_REPRODUCE, Xth byte
 INX                        ; increment X
 CPX #8                     ; until we copied the 8th byte (offset 7)
 BNE adult_fish_copy_loop

 ; age down all fish by copying all values n to n-1, where n is element of [1, 8]
 ; we copy the individual bytes here, because it's easier and does the same thing
 LDX #$00                   ; load 0 into X (target)
 LDY #$08                   ; load 8 into Y (source)
age_down:
 LDA FISH_AGES,Y            ; load Yth byte of FISH_AGES (source; Y == X-8)
 STA FISH_AGES,X            ; save to Xth byte of FISH_AGES (target)
 INX
 INY

 ; check if Y (source) is equal to the number of bytes we want to copy (+1)
 ; if not, go back to age_down (with X and Y incremented)
 ; we want this to copy all of FISH_AGES, so 72 bytes
 CPY #73
 BNE age_down


 ; add adult fish that just reproduced to pool of age 6
 CLC                        ; clear carry bit
 LDX #$00                   ; set X to 0
 PHP                        ; save processor status register (to make PLP happy)
add_adult_fish:
 PLP                        ; restore saved processor status
 LDA FISH_AGES+48,X         ; load count of fish with age = 6 into A register (Xth- byte)
 ADC FISH_TO_REPRODUCE,X    ; add FISH_TO_REPRODUCE to A (Xth- byte)
 STA FISH_AGES+48,X         ; store updated value (Xth- byte)
 PHP                        ; save the current processor status register (mainly the carry- bit, as CPX messes with that...)
 INX                        ; increment X
 CPX #8                     ; until we added all 8 bytes together
 BNE add_adult_fish

 ; newborn fish are age 8
 ; since 8 is our maximum age, and we just aged all our fish,
 ; we can just assign FISH_TO_REPRODUCE to FISH_AGES[8] (LO+HI byte, ofc)
 LDX #$00                   ; set X to 0
add_newborn_fish:
 LDA FISH_TO_REPRODUCE,X    ; load Xth byte of FISH_TO_REPRODUCE
 STA FISH_AGES+64,X         ; store in Xth byte of FISH_AGES[8]
 INX                        ; increment X
 CPX #8                     ; until we copied all 8 bytes
 BNE add_newborn_fish


 ; increment CURRENT_DAY (LO+HI)
 INC CURRENT_DAY            ; LO
 BNE day_did_not_overflow
 INC CURRENT_DAY+1          ; if LO overflowed, increment HI
day_did_not_overflow:


 ; jump to start if CURRENT_DAY != DAYS_TO_SIMULATE
 LDA CURRENT_DAY            ; LO
 CMP DAYS_TO_SIMULATE
 BNE day_loop
 LDA CURRENT_DAY+1          ; HI
 CMP DAYS_TO_SIMULATE+1
 BNE day_loop


 ; add the fish population together
 LDX #$00                   ; start at age 0
 LDY #$00
pop_add_loop:
 ; add fish of age X to the result
 CLC                        ; clear carry bit
 LDA FISH_AGES,X            ; age X, A
 ADC RESULT                 ; add result to A, A
 STA RESULT                 ; store new RESULT, A
 INX
 LDA FISH_AGES,X            ; age X, B
 ADC RESULT+1 
 STA RESULT+1
 INX
 LDA FISH_AGES,X            ; age X, C
 ADC RESULT+2
 STA RESULT+2
 INX
 LDA FISH_AGES,X            ; age X, D
 ADC RESULT+3 
 STA RESULT+3
 INX
 LDA FISH_AGES,X            ; age X, E
 ADC RESULT+4 
 STA RESULT+4
 INX
 LDA FISH_AGES,X            ; age X, F
 ADC RESULT+5 
 STA RESULT+5
 INX
 LDA FISH_AGES,X            ; age X, G
 ADC RESULT+6 
 STA RESULT+6
 INX
 LDA FISH_AGES,X            ; age X, H
 ADC RESULT+7 
 STA RESULT+7
 INX
 INY

 ; check if Y is 9 (we're at the end of our 'array')
 CPY #9
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

; how many days we should simulate (2 bytes)
DAYS_TO_SIMULATE:
 .WORD #18


;; RAM ;;
; RAM starts at $200

; the result of the computation (8 bytes)
RESULT = $0200

; how many fish there are of each age (9 * 8 bytes == 72 bytes)
; this contains the current numbers that are worked with by the CPU
; to get the number of fish in each age group, use the following:
; LDA FISH_AGES+(8n)   ; to load A byte of fish of age n into A
; LDA FISH_AGES+(8n+1) ; to load B byte of fish of age n into A
; ... 
; LDA FISH_AGES+(8n+7) ; to load H byte of fish of age n into A
FISH_AGES = $0208

; the current day of the simulation (2 bytes)
CURRENT_DAY = $0250

; how many fish will reproduce on the current day (8 bytes)
FISH_TO_REPRODUCE = $0252
