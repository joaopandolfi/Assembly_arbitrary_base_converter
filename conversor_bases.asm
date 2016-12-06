;; CONVERSOR DE BASES 

org 100h
 
; Imprime mensagem    
mov dx, offset msg1
mov ah, 9
int 21h

; Scan numero
call scan_num
mov num,cx
mov tam,bl

; Pula Linha:
putc 0Dh
putc 0Ah

;chama funcao principal
call converte

; Imprime mensagem    
mov dx, offset msg2
mov ah, 9
int 21h 

;imprime Valor Decimal
mov ax, valDec
call print_num


; Pula Linha:
putc 0Dh
putc 0Ah

; Imprime mensagem    
mov dx, offset msg3
mov ah, 9
int 21h 

;imprime Hexa
mov dx, offset valHex
mov ah , 9
int 21h

; Pula Linha:
putc 0Dh
putc 0Ah

; Imprime mensagem    
mov dx, offset msg4
mov ah, 9
int 21h 

;imprime Valor Binario
mov dx, offset valBin
mov ah , 9
int 21h

ret

; ===== Mensagens ======
msg1 db "Digite o Valor a ser Convertido: $"
msg2 db "Valor em Dec: $"
msg3 db "Valor em Hexa: $"
msg4 db "Valor em Bin: $"

; ===== Variaveis ======
num dw ?
;16 valores
valLido db 16 DUP('$')
valHex  db  4 DUP('$')
valBin  db 16 DUP('$')
valDec  dw 0
auxDec  dw 0
auxBin  db 16 DUP('$')
tam     db 0
cursor  db 0
         
; ===== FUNCOES ========

;calcula potencia [pot=ax, base = bx]                    
potencia PROC
mov cx,ax
cmp cx,1
je pot_val1 
sub cx,1
mov al,1
calculaPot:
mul bx ; ax = al*bx
loop calculaPot;
jmp pot_end
pot_val1:
mov ax,1
pot_end:
mov bx , ax
RET
potencia ENDP

;Char To Int (AL = parametro)
CharToInt PROC
    CMP AL,65
    JL c_test1 ;AL < 65
    SUB AL,55  ;AL >=65
    JMP c_exit1
    c_test1:
    SUB AL,48
    c_exit1:
    RET
CharToInt ENDP

;Int To Char (AL = parametro)
IntToChar PROC
    CMP AL,10
    JL c_test2 ;AL < 10
    ADD AL,55  ;AL >=10
    JMP c_exit2
    c_test2:
    ADD AL,48
    c_exit2:
    RET
IntToChar ENDP


; ===== PRINCIPAL =====
Converte PROC 
    ; 1->bin 2->hex 0->dec
    CMP BH,1
    JE flag_bin
    CMP BH,2
    JE flag_hex
    JMP flag_dec  
    flag_hex:
        MOV CX,4 ;tamanho 
        MOV SI,0 ;[]indice
        cpy_loop1:
            MOV al,valLido[si]
            MOV valHex[si],al
            add si,1
        loop cpy_loop1
        CALL HexToDec
        CALL DecToBin
        JMP end_conv
    flag_bin:
        MOV CX,16 ;tamanho 
        MOV SI,0 ;[]indice
        cpy_loop2:
            MOV al,valLido[si]
            MOV valBin[si],al
            add si,1
        loop cpy_loop2
        CALL BinToDec
        CALL DecToHex
        JMP end_conv
    flag_dec:
        MOV AX,num
        MOV valDec,AX        
        CALL DecToHex 
        CALL DecToBin
    end_conv:
    RET       
Converte ENDP

; ===== FUNCOES DE CONVERSAO =====

DecToBin PROC
    mov ax,valDec
    mov si,0   ;indice da lista
    mov bh,0   ;tamanho
    mov dx,0   ;limpo dx
    calcDecToBin:
    push bx      ;guardo bx
    mov dx,0     ;limpo dx 
    mov bx,2
    div bx       ;ax = ax/bx  dx=ax mod bx
    pop bx
    mov cl,al       ;guardo al
    mov al,dl       ;dl resto
    call IntToChar;trabalha com al
    mov dl,al
    mov al,cl       ;recupero al
    mov valBin[si],dl
    add si,1      ;si =  si+1
    add bh,1      ;bh =  bh+1
    mov dl,0
    cmp ax,0
    jne calcDecToBin
    ;inverto string 
    mov ch,0
    mov cl,bh     ;cont = tamanho
    mov si,0      ;[0]
    mov ax,0
    loopPush1:
        mov al,valBin[si]
        push ax ;empilho
        add si,1    
    loop loopPush1
    mov cl,bh     ;cont = tamanho
    mov si,0      ;[0] 
    loopPop1:
        pop ax    ;desempilho
        mov valBin[si],al
        add si,1
    loop loopPop1
    RET    
DecToBin ENDP

;calcula Decimal para Hexadecimal
DecToHex PROC
    mov ax,valDec
    mov si,0   ;indice da lista
    mov bh,0   ;tamanho
    mov dx,0   ;limpo dx
    calcDecToHex:
    push bx      ;guardo bx
    mov dx,0     ;limpo dx 
    mov bx,16
    div bx       ;ax = ax/bx  dx=ax mod bx
    pop bx
    mov cl,al       ;guardo al
    mov al,dl       ;dl resto
    call IntToChar;trabalha com al
    mov dl,al
    mov al,cl       ;recupero al
    mov valHex[si],dl
    add si,1      ;si =  si+1
    add bh,1      ;bh =  bh+1
    mov ah,0
    cmp al,0
    jne calcDecToHex
    ;inverto string
    mov ch,0
    mov cl,bh     ;cont = tamanho
    mov si,0      ;[0]
    loopPush2:
        mov al,valHex[si]
        push ax     ;empilho
        add si,1    
    loop loopPush2
    mov cl,bh     ;cont = tamanho
    mov si,0      ;[0] 
    loopPop2:
        pop ax    ;desempilho
        mov valHex[si],al
        add si,1
    loop loopPop2
    RET    
DecToHex ENDP

;hexadecimal para decimal
HexToDec PROC  
    mov cl,tam
    mov si,0
    mov ax,0
    to_int1:
        mov al,valHex[si]
        call CharToInt
        push ax    ;guardo o valor de ax
        mov  al,cl ;passo a potencia
        mov  bx,16 ;base 16
        push cx   ;guardo valor cx
        call potencia ;bx = bx^al
        pop  cx   ;resgato valor cx
        pop  ax   ;resgato valor ax
        mul  bx   ;ax = al*bx -> bx= valHex[si]*(bx^al)
        mov  bx,ax
        add  valDec,bx
        add  si,1 ;incremento []indice
        mov  ax,0  ;limpo ax
    loop to_int1
    
    ret
HexToDec ENDP

;binario para decimal
BinToDec PROC
    mov cl,tam
    mov si,0
    mov ax,0
    to_int2:
        mov al,valBin[si]
        call CharToInt
        push ax    ;guardo o valor de ax
        mov  al,cl ;passo a potencia
        mov  bx,2 ;base 2
        push cx   ;guardo valor cx
        call potencia ;bx = bx^al
        pop  cx   ;resgato valor cx
        pop  ax   ;resgato valor ax
        mul  bx   ;al = al*bx -> bx= valHex[si]*(bx^al)
        mov  bx,ax
        add  valDec,bx
        add  si,1 ;incremento []indice
        mov  ax,0  ;limpo ax
    loop to_int2
    
    ret
    
BinToDec ENDP

; ==============================
; ==== Funcoes modificadas =====
; =mas ja estavam implementadas=
; =responsavel pela entrada de =
; =========== dados ============ 
; ==============================
    
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI      
        MOV     CX, 0
        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:
        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus         
        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:
        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        PUSH    DX        ;guarda dx
        MOV     DX,0
        MOV     Dl,cursor ;bx=cursor
        CMP     Dl,0      ;verifico se cursor e zero 
        POP     DX        ;recupera dx
        JE      block_backspace
        SUB     cursor,1       
        SUB     SI,1            ;volto uma casa
        MOV     valLido[SI],'$' ;limpo a posicao
        CMP     BL,0            ;se for 0 nao subtrai
        JE      continue_notCr
        SUB     BL,1
        continue_notCr:
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX 
        PUSH    BX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        POP     BX
        JMP     next_digit
backspace_checked:
        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, 'F'
        JBE     ok_digit
        CMP     AL, 'x'
        JE      set_hex
        CMP     AL, 'b'
        JE      set_bin
remove_not_digit:
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
block_backspace:
        PUTC    ' '
        JMP     next_digit
ok_digit:
        ; multiply CX by 10 (first time the result is zero)
        ADD     cursor,1
        ADD     BL ,1
        CMP     BH ,1
        JE      concat_bin
        CMP     BH ,2
        JE      concat_hex
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit
set_hex: ;seto bh para 2 = hexa
        ADD cursor,1
        MOV BH,2
        MOV BL,0 ;contador
        MOV SI,0 ;[]indice
        MOV CX,0 ;valor
        JMP next_digit
set_bin: ;seto bh para 1 = binario
        ADD cursor,1
        MOV BH,1
        MOV BL,0 ;contador
        MOV SI,0 ;[]indice
        MOV CX,0 ;valor
        JMP next_digit
concat_hex:               
        CMP BL,5
        JE  stop_special
        MOV valLido[SI],AL
        ADD SI,1
        JMP next_digit
concat_bin:
        CMP BL,17
        JE  stop_special
        MOV valLido[SI],AL
        ADD SI,1
        JMP next_digit 
stop_special:    
        PUTC    8
        PUTC    ' '  ; apaga o ultimo inserido
        PUTC    8
        JMP stop_input
too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.

stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP                             

; this procedure prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP



ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.