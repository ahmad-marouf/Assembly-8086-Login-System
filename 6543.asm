 
ORG 100H        
        .DATA

idChar      DB '0123456789ABCDEFabcdef?'
wrongID     DB 'Incorrect ID format, Please try again (Enter 4 digit HEX number)', '$'
idNotFound  DB 'ID not registered, Please recheck and try again or create new account', '$'
wrongPASS   DB 'Incorrect Password format, Please try again (Enter 1 digit HEX number)', '$'
denied      DB 'Access Denied, Incorrect Password', '$'
granted     DB 'Access Granted', '$'
idPrompt    DB 'Enter your Employee Identification Number : ', '$'
passPrompt  DB 'Enter your password : ', '$'
empID       DW 0AAAAH,0BBBBH,0CCCCH,0DDDDH,0EEEEH,0FFFFH,1111H,2222H,3333H,4444H,5555H,6666H,7777H,8888H,9999H,0110H,0220H,0330H,0440H,1234H
empPass     DW 0AH,0BH,0CH,0DH,0EH,0FH,1H,2H,3H,4H,5H,6H,7H,8H,9H,0AH,0BH,0CH,0DH,0EH
getID       DB 5,?,5 DUP(?)
getPass     DB 2,?,2 DUP(?)
progOutput  DB 00H
matchedID   DB 00H

;*******************************************************************************
        .CODE
MAIN            PROC FAR            
                MOV AX,@DATA            
                MOV DS,AX         
                         
START:          CALL ASK_ID                ; Ask employee to enter ID                              
                CALL INPUT_ID              ; Get ID from employee
		        
                CALL CHECK_IDL             ; Check ID Length (4 digits)
                CALL CHECK_IDF             ; Check ID Format (HEX)
                
                MOV  SI,OFFSET getID+2     ; Compare ID against Saved IDs
                CALL ID2AX
                CALL VERIFY_ID

                CALL NEWLINE

                
PASS:           CALL ASK_PASS              ; Ask employee to enter Password                           
                CALL INPUT_PASS            ; Get Password from employee
		        
                CALL CHECK_PL              ; Check password Length (1 digit)
                CALL CHECK_PF              ; Check password Format (HEX)
                
                MOV  SI,OFFSET getPASS+2   ; Compare Password against saved password for entered ID
                CALL PASS2AX
                CALL VERIFY_PASS
                
                CALL RESULT                ; If password matches employee is given access
                
                
                MOV  AH,4CH                ; END program
                INT  21H  
MAIN            ENDP                
;*******************************************************************************            
CHECK_IDF       PROC                       ; Checks ID Format
                MOV AH,4
                LEA SI,getID+2
LOOP_ID:        LEA DI,idChar
                MOV CX,23
                MOV AL,[SI]
                REPNZ SCASB
                CMP CX,00
                JZ  END_ID
                INC SI
                DEC AH
                JNZ LOOP_ID
                RET
END_ID:         CALL ERR1_ID
CHECK_IDF       ENDP
;---------------                           ; Checks ID Length
CHECK_IDL       PROC
                LEA SI,getID[1]
                CMP [SI],04H
                JNZ ERR1_ID
                RET
CHECK_IDL       ENDP
;--------------- 
CHECK_PF        PROC                       ; Checks Password Format
                LEA SI,getPass+2
LOOP_PF:        LEA DI,idChar
                MOV CX,23
                MOV AL,[SI]
                REPNZ SCASB
                CMP CX,00
                JZ  END_PF
                RET
END_PF:         CALL ERR1_PASS
CHECK_PF        ENDP
;---------------                            
CHECK_PL        PROC                       ; Checks Password Length
                LEA SI,getPass[1]
                CMP [SI],01H
                JNZ ERR1_PASS
                RET
CHECK_PL        ENDP
;--------------
ID2AX            PROC                      ; Converts ID from string to HEX and saves it in AX
                 MOV CX,04H
AGAIN:           CMP [SI],39H        
                 JA  LETTER   
NUM:             SUB [SI],30H
                 JMP ADD2AX         
LETTER:          CMP [SI],70
                 JA  SMALL
CAPITAL:         SUB [SI],55
                 JMP ADD2AX 
SMALL:           SUB [SI],87       
ADD2AX:          INC SI 
                 DEC CX   
                 JNZ AGAIN       
                 SUB SI,4
                 MOV AH,[SI]
                 MOV AL,[SI+2]
                 MOV BH,[SI+1]
                 MOV BL,[SI+3]
                 SHL AX,4
                 OR  AX,BX  
                 RET
ID2AX            ENDP
;--------------                           
PASS2AX         PROC                       ; Converts Password from string to HEX and saves it in AX
                CMP [SI],39H
                JA  LETTER2
NUM2:           SUB [SI],30H
                JMP END_PASS2AX
LETTER2:        CMP [SI],70
                JA  SMALL2
CAPITAL2:       SUB [SI],55
                JMP END_PASS2AX
SMALL2:         SUB [SI],87                
END_PASS2AX:    MOV AH,00H
                MOV AL,[SI] 
                RET
PASS2AX         ENDP                        
;-------------
VERIFY_ID       PROC                        ; Checks ID against Registered IDs
                MOV CX,21
                LEA DI, empID
                CLD
                REPNE SCASW
                CMP CX,0000H
                JZ  ERR2_ID
                LEA SI, empID
                MOV BX,DI
                SUB BX,SI
                SUB BX,2
                LEA SI,matchedID
                MOV [SI],BX
                RET
VERIFY_ID       ENDP
;-------------                                                         
VERIFY_PASS     PROC                       ; Checks Password against matched ID
                LEA DI, empPass
                LEA SI, matchedID
                ADD DI, [SI]            
                CMP AX,[DI]          
                JZ  SET_ALLOWED
                RET
SET_ALLOWED:    MOV SI,OFFSET progOutput   
                MOV [SI],01H
                RET
VERIFY_PASS     ENDP
;---------------

ASK_ID         PROC                        ; Functions for printing error/access prompts
               MOV AH,09                 
               MOV DX,OFFSET idPrompt
               INT 21H 
               RET
ASK_ID         ENDP
;---------------
ASK_PASS       PROC                         
               MOV AH,09                 
               MOV DX,OFFSET passPrompt
               INT 21H 
               RET
ASK_PASS       ENDP
;---------------
INPUT_ID       PROC                          
               MOV AH,0AH                
               MOV DX,OFFSET getID
               INT 21H
               XOR BX,BX
		       MOV BL, getID[1]
		       MOV getID[BX+2], '$'
               RET
INPUT_ID       ENDP
;---------------
INPUT_PASS     PROC                          
               MOV AH,0AH                
               MOV DX,OFFSET getPass
               INT 21H
               XOR BX,BX
		       MOV BL, getPass[1]
		       MOV getPass[BX+2], '$'
               RET
INPUT_PASS     ENDP
;---------------
ERR1_ID        PROC                         
    
               CALL NEWLINE
               MOV AH,09
               MOV DX,OFFSET wrongID
               INT 21H
               CALL NEWLINE
               CALL NEWLINE
               JMP START                    
ERR1_ID        ENDP
;---------------
ERR2_ID         PROC
                CALL NEWLINE
                MOV AH,09
                MOV DX,OFFSET idNotFound
                INT 21H
                CALL NEWLINE
                CALL NEWLINE
                JMP START                    
ERR2_ID         ENDP
;---------------
ERR1_PASS       PROC
                CALL NEWLINE
                MOV AH,09
                MOV DX,OFFSET wrongPass
                INT 21H
                CALL NEWLINE
                JMP PASS                    
ERR1_PASS       ENDP
;---------------
RESULT          PROC
                CALL NEWLINE
                MOV SI,OFFSET progOutput
                CMP [SI],00H
                JZ  DEN
                MOV DX,OFFSET granted
                JMP PRINT
DEN:            MOV DX,OFFSET denied  
PRINT:          MOV AH,09
                INT 21H
                CALL NEWLINE
                CALL NEWLINE
                MOV [SI],00H
                JMP START
RESULT          ENDP              
;---------------
NEWLINE         PROC
                MOV AH,02H
                MOV DL,0DH
                INT 21H
                MOV DL,0AH
                INT 21H 
                RET
NEWLINE         ENDP              
;---------------
RET                                              