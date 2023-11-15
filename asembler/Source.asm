.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

includelib kernel32.lib
includelib user32.lib
includelib msvcrt.lib
includelib msvcrt.inc



EXTERN GetStdHandle@4: PROC
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN ExitProcess@4: PROC; ������� ������ �� ���������
EXTERN lstrlenA@4: PROC; ������� ����������� ����� ������
EXTERN wsprintfA: PROC; �.�. ����� ���������� ������� �� �����������,
; ������������ ����������, �������� �������� ������� ����
; ���������� ���������



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                         ������ ��������
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 .data

prompt1 db 'Enter the first number (in the 16-digit system): ', 13,10,0
prompt2 db 'Enter the second number (in the 16-digit system): ', 13,10,0
prompt3 db 'Max accessible second number: '
DIN DD ?;���������� �����
DOUT DD ? ;���������� ������
BUF DB 300 dup (?)
LENS DD ?; ���������� ��� ���������� ���������� ��������
num1 DD ?; ������ �����
num2 DD ?; ������ �����
result DD ?
MINUSA DB ?
MINUSB DB ?


resultMsg db 'result: ', 0
newline db 10, 0
bufLength = 512
maxValue = 65536
buf1 DB bufLength DUP(?)


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                          ������ ����
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 .code

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                    ����� ������� ���������
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Main PROC
; ������������ ������ promt1 ��� ����������� ������������� � ������ � �������
MOV EAX, OFFSET prompt1;
PUSH EAX; ��������� ������� ���������� � ���� �������� PUSH
PUSH EAX
CALL CharToOemA@8; ����� ������� 
; (����� ����� @ ���� ���������� ������������ ��� �������� � ��� �����)
; ������������ ������ prompt2 ��� ����������� ������������� � ������ � �������
MOV EAX, OFFSET prompt2
PUSH EAX
PUSH EAX
CALL CharToOemA@8; ����� �������


;������������ ������ resultMsg
MOV EAX, OFFSET resultMsg
PUSH EAX
Push EAX
CALL CharToOemA@8; ����� �������

; ������� ���������� �����
PUSH -10; ���������, ������� ��������� ���������� � �������� ������ �������
CALL GetStdHandle@4
MOV DIN, EAX 	; ����������� ��������� �� �������� EAX 
; � ������ ������ � ������ DIN

; ������� ���������� ������
PUSH -11; ����������� ���������, ������ ���������� � ��������� ������ ������ ��� ������
CALL GetStdHandle@4
MOV DOUT, EAX ; ����������� ��������� �� �������� EAX 
; � ������ ������ � ������ DOUT

REWRITE:
; ��������� ����� ������ prompt1
PUSH OFFSET prompt1; � ���� ���������� ����� ������
CALL lstrlenA@4; ����� � EAX


; ����� ������� WriteConsoleA ��� ������ ������ prompt1
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; 4-� ��������
PUSH EAX; 3-� ��������
PUSH OFFSET prompt1; 2-� ��������
PUSH DOUT; 1-� �������� - ���������� ������
CALL WriteConsoleA@20

; ���� ������ ���������� ������
PUSH 0;
PUSH OFFSET LENS;
PUSH 300;
PUSH OFFSET BUF;
PUSH DIN; ���������� �����
CALL ReadConsoleA@20

PUSH OFFSET BUF; ��������� ��������� �������� 
CALL lstrlenA@4; � EAX ��������� �����

SUB EAX, 2


; ����������� hex ����� � �������� int
MOV DI, 16; � hex 10
MOV ECX, EAX; ecx ��������� ����� ���������� ��������
MOV ESI, OFFSET BUF; � esi ��������� ����� ��������� ��������
MOV BL, [ESI]; bl ������ ������ ������
CMP BL, '-'; ���� �� �����
JNE NEXT; ���� bl �� ����� -, �� ������� �� next
MOV MINUSA, '-'
INC ESI; ��������� �� ������� ����
SUB ECX, 1; �������� ����� �� ������� 
NEXT:
XOR BX, BX; ������� ax 
XOR AX, AX; ������� bx 
; ���������� �������������� ����������� �����

CONVERT:
MOV BL, [ESI];
CMP BL, '0'
JB REWRITE
CMP BL, 'F'
JA REWRITE
CMP BL, '9'
JBE CORRECT
CMP BL, 'A'
JB REWRITE
CORRECT:
CMP BL, 'A';
JB MARK;
SUB BL, '7';
JMP ENDOFIF
MARK: 
SUB BL, '0';
ENDOFIF: 
MUL DI;
ADD AX, BX;
INC ESI;
LOOP CONVERT;

; �������� ������������ ����� � num1
MOV num1, EAX

; ����������� �������� ��� ������� �����
REWRITE2:
; ��������� ����� ������ prompt2
PUSH OFFSET prompt2; � ���� ���������� ����� ������
CALL lstrlenA@4; ����� � EAX


; ����� ������� WriteConsoleA ��� ������ ������ prompt2
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; 4-� ��������
PUSH EAX; 3-� ��������
PUSH OFFSET prompt2; 2-� ��������
PUSH DOUT; 1-� ��������
CALL WriteConsoleA@20

; ������� ����� 
MOV EDI, OFFSET BUF ; ���������� ��� ������� 
MOV CX, 200 ; ���������� ���������� ������� rep
MOV AL, 0; ��� ������ ����� ���������
REP STOSB; �������������� ��������� 200 ��� �� ����� 0 �� ������ BUF
  
    ; ���� ������
PUSH 0
PUSH OFFSET LENS
PUSH 300
PUSH OFFSET BUF
PUSH DIN
CALL ReadConsoleA@20 

PUSH OFFSET BUF;
CALL lstrlenA@4;

SUB EAX, 2;


;������� 2-��� ����� � 10 ������� ���������
MOV DI, 16;
MOV ECX, EAX;
MOV ESI, OFFSET BUF;
MOV BL, [ESI]
CMP BL, '-'
JNE NEXT2
MOV MINUSB, '-'
INC ESI
SUB ECX, 1
NEXT2:
XOR BX, BX;
XOR AX, AX;
CONVERT2:
MOV BL, [ESI];
CMP BL, '0'
JB REWRITE2
CMP BL, 'F'
JA REWRITE2
CMP BL, '9'
JBE CORRECT2
CMP BL, 'A'
JB REWRITE2
CORRECT2:
CMP BL, 'A';
JB MARK2;
SUB BL, '7';
JMP ENDOFIF2
MARK2: SUB BL, '0';
ENDOFIF2: MUL DI;
ADD AX, BX;
INC ESI;
LOOP CONVERT2;
; ���������� ������������ ����� � num2
MOV num2, EAX

; ���������� num1 and num2 � EAX � ECX
MOV EAX, num1
MOV ECX, num2


; ���������
MOV BL, MINUSA
ADD BL, MINUSB

CMP BL, 0; ���� bl==0, �� ����� ���������� �������������
JNE NEXTCHECK; ���� � ���������� �� �����, �� ������� �� �������� � �������
CMP EAX, ECX
; ��� �������� ��������� ���� �����
JA CONT
MOV EAX, num2
MOV ECX, num1
CONT: IMUL EAX, ECX; ��������������� �������� ��������� 
MOV result, EAX
JMP ENDCHECK

NEXTCHECK:
CMP BL, 45; ���� bl==45, �� ����� ���������� �������������(��� ��� - � ANSI == 45)
JNE NEXTCHECK2
IMUL EAX, ECX; ��������������� �������� ��������� 
MOV result, EAX
JMP ENDCHECK

NEXTCHECK2:
CMP BL, 90; ��� ������ ���� ���� ��� ��������� ������������� ��������
JE BOTHNEG
BOTHNEG:
CMP EAX, ECX
; �������� ��������� ���� �����
JB CONT2
MOV EAX, num2
MOV ECX, num1
CONT2: IMUL ECX, EAX; ��������������� �������� ��������� 
MOV result, ECX
JMP ENDCHECK

ENDCHECK:
MOV EDI, 10
MOV EAX, result; ���������� ��������� ���������
CMP EAX, 0; �������� �� ����
XOR EBX, EBX
JNE BEGINLOOP
BEGINLOOP: CMP EAX, 0
; ���� ��� ��������� ���������� 0, �� ������ ������ ������ �� �������
JE EXITMARK
XOR EDX, EDX
DIV EDI; ������� ������ ���������� �� 10, �� ������ ������� ������� ���������� ������ � �����
PUSH EDX
INC EBX; ��� ��� ������ ��� ����������, ������� ����� ��������
JMP BEGINLOOP

; �������� ������
EXITMARK: 
MOV EDI, OFFSET BUF
MOV CX, 300
MOV AL, 0
REP STOSB

;������������ ������ ��� ������
; ���������� ��� ����������� ������ ��� ������
MOV EDI, EBX; ���-�� �������� ������
MOV ESI, OFFSET BUF; �����

MOV CL, MINUSA; ����� �������
ADD CL, MINUSB; ����� �������

MOV EAX, num1; �������� �������
MOV EBX, num2; �������� �������

CMP CL, 0; ����� ���������� �� ��� ������������� �����
JNE NEXTCHECK11
CMP EAX, EBX
JMP CONT3

NEXTCHECK11:
CMP CL, 45; �������� �� ���� �������������
JNE NEXTCHECK22
CMP MINUSA, '-'
JE ADDMIN1
CMP MINUSB, '-'
JNE CONT3
ADDMIN1:
; ���������� - � �����
MOV EDX, 45
MOV [ESI], EDX
INC ESI
JMP CONT3

NEXTCHECK22:
CMP CL, 90; �������� �� ��� ������������� �����
CMP EAX, EBX
JMP CONT3

CONT3:
MOV ECX, EDI; �������� �� ���-�� ���� � ������������
LOOPSTR: 
; ���������� � ����� ��������� ����� 
POP EAX
ADD EAX, 48; ���������� 48 ��� ��� �� ANSI 0 - 48
MOV [ESI], EAX
INC ESI
LOOP LOOPSTR

;��������� ����� ������ BUF
PUSH OFFSET BUF
CALL lstrlenA@4
; ���������� ������������ ������������
PUSH 0
PUSH OFFSET LENS
PUSH EAX
PUSH OFFSET BUF
PUSH DOUT
CALL WriteConsoleA@20

; ����� �� ���������
PUSH 0; ��������: ��� ������
CALL ExitProcess@4
Main ENDP

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


end Main