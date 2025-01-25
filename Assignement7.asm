.ORIG x3000 

    LEA R1 FD
    ST  R1 FD_START
    LEA R2 FD_PTR
    LEA R3 FD_LEN
    JSR GET_DIGIT           ; Load first number to memory

    LEA R1 FD               
    LD  R2 CONST_10K        ; Adjust pointer to SD
    ADD R1 R2 R1
    
    ST  R1 SD_START
    LEA R2 SD_PTR
    LEA R3 SD_LEN
    JSR GET_DIGIT            ; Load second number to memory
    
    LD  R6 FD_START
    LD  R5 FD_LEN
    JSR RM_LDNG_0           ; Remove leading zeros from FD
    ST  R6 FD_START
    ST  R5 FD_LEN
    
    LD  R6 SD_START
    LD  R5 SD_LEN
    JSR RM_LDNG_0           ; Remove leading zeros from SD
    ST  R6 SD_START
    ST  R5 SD_LEN
    
    
    JSR MAKE_FD_GREATER     ; Makes sure that len(FD) >= len(SD)
    
    LEA R0 FD               ; Adjusts pointer to RD array begining
    LD  R1 CONST_10K
    ADD R0 R1 R0
    ADD R0 R1 R0
    ST  R0 RD_START
    ST  R0 RD_PTR
    
    JSR ADD_FD_SD           ; R3 contains carry after last addition
    
    LD  R0 FD_START
    NOT R0 R0
    ADD R0 R6 R0
    BRn #1                  ; Skip if len(FD) = len(SD)
    JSR FINISH_ADD
    
    ADD R3 R3 #0            ; Add left over carry
    BRz #4
    LD  R6 RD_PTR
    STR R3 R6 #0
    ADD R6 R6 #1
    ST  R6 RD_PTR
    
    JSR PRINT_RD
    
    HALT
    

PRINT_RD    LD  R6 RD_PTR
            LD  R5 RD_START
            NOT R5 R5
            ADD R5 R5 #1
            LD  R4 CONST_48
            
    ITER_RD ADD R6 R6 #-1
            LDR R0 R6 #0
            ADD R0 R4 R0
            PUTC
            
            ADD R2 R6 R5
            BRp ITER_RD
            
            LD R0 CONST_10
            PUTC
            RET

    
FINISH_ADD  LD  R6 RD_PTR   ; Next free location for res
            LD  R5 FD_PTR
            LD  R4 FD_START
            NOT R4 R4
            ADD R4 R4 #1
            
    ITER_FD ADD R5 R5 #-1   ; Lower FD_PTR
            
            LDR R0 R5 #0    ; Load next digit
            ADD R0 R3 R0    ; Add carry
            AND R3 R3 #0    ; Clear carry
            ADD R2 R0 #-10  ; Skip if result < 10
            BRn #2
            
            ADD R0 R2 #0    ; Move last digit of result to R0
            ADD R3 R3 #1    ; Add cary
            
            STR R0 R6 #0    ; Store last digit of result
            ADD R6 R6 #1    ; Increase result pointer
            ADD R2 R5 R4    ; Check if FD_PTR = Start of FD_START
            BRp ITER_FD
            
            ST R6 RD_PTR
            RET

ADD_FD_SD   ST  R7 MAIN_PTR
            
            LD  R7 RD_PTR
            LD  R6 FD_PTR
            LD  R5 SD_PTR
            LD  R4 SD_LEN
            AND R3 R3 #0
            
    ITER_SD ADD R6 R6 #-1
            ADD R5 R5 #-1
            
            LDR R1 R6 #0
            LDR R2 R5 #0
            
            ADD R0 R2 R1    ; Add digits
            ADD R0 R3 R0    ; Add carry
            AND R3 R3 #0    ; Reset carry
            
            ADD R2 R0 #-10  ; If result >= 10
            BRn #2          ; No carry
            ADD R0 R2 #0    ; Move last digit
            ADD R3 R3 #1    ; Set carry
            
            STR R0 R7 #0
            ADD R7 R7 #1
            ADD R4 R4 #-1
            BRp ITER_SD
            
            ST R7 RD_PTR
            ST R6 FD_PTR
            ST R5 SD_PTR
            LD R7 MAIN_PTR
            RET

MAIN_PTR    .FILL #0

MAKE_FD_GREATER 
            LD  R0 FD_LEN    
            LD  R1 SD_LEN
            
            NOT R1 R1
            ADD R1 R1 #1
            
            ADD R3 R0 R1    ; If FD >= SD:
            BRzp #12        ; Skip swapping
            
            NOT R1 R1
            ADD R1 R1 #1
            
            ST  R0 SD_LEN    ; Swaps lengths
            ST  R1 FD_LEN
            
            LD  R0 FD_START  ; Swap array 0 index pointers
            LD  R1 SD_START
            ST  R0 SD_START
            ST  R1 FD_START
            
            LD  R0 FD_PTR    ; Swap array pointers
            LD  R1 SD_PTR
            ST  R0 SD_PTR
            ST  R1 FD_PTR
            RET

; Expects:
;   R6 -> Array Start
;   R5 -> Array Length
RM_LDNG_0   LDR R0 R6 #0    ; If first digit = 0
            BRnp EXIT_RM
            ADD R4 R5 #-1    ; If len of Array is 1
            BRz EXIT_RM
            
    WHILE_0 ADD R6 R6 #1    ; Move start of array
            ADD R5 R5 #-1   ; Shorten Length
            ADD R4 R5 #-1   ; Exit if len = 1
            BRz EXIT_RM
            
            LDR R0 R6 #0    ; Load next digit
            BRz WHILE_0     
            
    EXIT_RM RET

; Expects:
;   R1 -> Starting address of Array
;   R2 -> Ptr to end of array
;   R3 -> Addres to memory that stores no. of digits
GET_DIGIT   LD  R4 CONST_NEG_48
            AND R5 R5 #0
            
    LOOP    GETC
            PUTC
            ADD R0 R0 R4        ; Try conversion to integer (if input = ' ' or '\n' -> R0 < 0)
            BRn FINISH
            
            STR R0 R1 #0        ; Store digit to memory
            ADD R5 R5 #1        ; Increase length
            ADD R1 R1 #1        ; Increase pointer
            BR LOOP
        
    FINISH  STR R1 R2 #0        ; Adjust array pointer
            STR R5 R3 #0        ; Update array length
            RET

; Variables
CONST_10K       .FILL #10000
CONST_48        .FILL #48
CONST_10        .FILL #10
CONST_NEG_48    .FILL #-48

; Digits
FD_START    .FILL #0
SD_START    .FILL #0
FD_PTR      .FILL #0
SD_PTR      .FILL #0
FD_LEN      .FILL #0
SD_LEN      .FILL #0

RD_START    .FILL #0
RD_PTR      .FILL #0

FD  .BLKW #10000
SD  .BLKW #10000
RD  .BLKW #10001
.END