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
EXTERN ExitProcess@4: PROC; функция выхода из программы
EXTERN lstrlenA@4: PROC; функция определения длины строки
EXTERN wsprintfA: PROC; т.к. число параметров функции не фиксировано,
; используется соглашение, согласно которому очищает стек
; вызывающая процедура



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                         СЕКЦИЯ КОНСТАНТ
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 .data

prompt1 db 'Enter the first number (in the 16-digit system): ', 13,10,0
prompt2 db 'Enter the second number (in the 16-digit system): ', 13,10,0
prompt3 db 'Max accessible second number: '
DIN DD ?;дескриптор ввода
DOUT DD ? ;дескриптор вывода
BUF DB 300 dup (?)
LENS DD ?; переменная для количества выведенных символов
num1 DD ?; первое число
num2 DD ?; второе число
result DD ?
MINUSA DB ?
MINUSB DB ?


resultMsg db 'result: ', 0
newline db 10, 0
bufLength = 512
maxValue = 65536
buf1 DB bufLength DUP(?)


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                          СЕКЦИЯ КОДА
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 .code

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                    Самая Главная Процедура
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Main PROC
; перекодируем строку promt1 для дальнейшего использования и вывода в консоль
MOV EAX, OFFSET prompt1;
PUSH EAX; параметры функции помещаются в стек командой PUSH
PUSH EAX
CALL CharToOemA@8; вызов функции 
; (после знака @ идет количество используемых бит командой и так везде)
; перекодируем строку prompt2 для дальнейшего использования и вывода в консоль
MOV EAX, OFFSET prompt2
PUSH EAX
PUSH EAX
CALL CharToOemA@8; вызов функции


;перекодируем строку resultMsg
MOV EAX, OFFSET resultMsg
PUSH EAX
Push EAX
CALL CharToOemA@8; вызов функции

; получим дескриптор ввода
PUSH -10; константа, которая позволяет обратиться к входному буферу консоли
CALL GetStdHandle@4
MOV DIN, EAX 	; переместить результат из регистра EAX 
; в ячейку памяти с именем DIN

; получим дескриптор вывода
PUSH -11; аналогичная константа, только обращается к активному буферу экрана для вывода
CALL GetStdHandle@4
MOV DOUT, EAX ; переместить результат из регистра EAX 
; в ячейку памяти с именем DOUT

REWRITE:
; определим длину строки prompt1
PUSH OFFSET prompt1; в стек помещается адрес строки
CALL lstrlenA@4; длина в EAX


; вызов функции WriteConsoleA для вывода строки prompt1
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH EAX; 3-й параметр
PUSH OFFSET prompt1; 2-й параметр
PUSH DOUT; 1-й параметр - дескриптор вывода
CALL WriteConsoleA@20

; ввод строки аналогично выводу
PUSH 0;
PUSH OFFSET LENS;
PUSH 300;
PUSH OFFSET BUF;
PUSH DIN; дескриптор ввода
CALL ReadConsoleA@20

PUSH OFFSET BUF; сохраняем введенное значение 
CALL lstrlenA@4; в EAX сохраняем длину

SUB EAX, 2


; превращение hex чисел в знаковое int
MOV DI, 16; в hex 10
MOV ECX, EAX; ecx сохраняем длину введенного значения
MOV ESI, OFFSET BUF; в esi сохраняем адрес введенное значение
MOV BL, [ESI]; bl хранит первый символ
CMP BL, '-'; есть ли минус
JNE NEXT; если bl не равно -, то прыгвем на next
MOV MINUSA, '-'
INC ESI; переходим ко второму биту
SUB ECX, 1; вычитаем длину на единицу 
NEXT:
XOR BX, BX; очищаем ax 
XOR AX, AX; очищаем bx 
; производим соответственно конвертацию чисел

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

; помещаем получившееся число в num1
MOV num1, EAX

; аналогичный алгоритм для второго числа
REWRITE2:
; определим длину строки prompt2
PUSH OFFSET prompt2; в стек помещается адрес строки
CALL lstrlenA@4; длина в EAX


; вызов функции WriteConsoleA для вывода строки prompt2
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH EAX; 3-й параметр
PUSH OFFSET prompt2; 2-й параметр
PUSH DOUT; 1-й параметр
CALL WriteConsoleA@20

; очищаем буфер 
MOV EDI, OFFSET BUF ; записываем что очищаем 
MOV CX, 200 ; количество повторений команды rep
MOV AL, 0; чем именно будем заполнять
REP STOSB; соответственно заполняем 200 раз по байту 0 по адресу BUF
  
    ; ввод строки
PUSH 0
PUSH OFFSET LENS
PUSH 300
PUSH OFFSET BUF
PUSH DIN
CALL ReadConsoleA@20 

PUSH OFFSET BUF;
CALL lstrlenA@4;

SUB EAX, 2;


;перевод 2-ого числа в 10 систему счисления
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
; записываем получившееся число в num2
MOV num2, EAX

; перемещаем num1 and num2 в EAX и ECX
MOV EAX, num1
MOV ECX, num2


; умножение
MOV BL, MINUSA
ADD BL, MINUSB

CMP BL, 0; если bl==0, то число получается положительным
JNE NEXTCHECK; если в предыдущем не равно, то прыгаем на проверку с минусом
CMP EAX, ECX
; без знаковое сравнение двух чисел
JA CONT
MOV EAX, num2
MOV ECX, num1
CONT: IMUL EAX, ECX; непосредственно проводим умножение 
MOV result, EAX
JMP ENDCHECK

NEXTCHECK:
CMP BL, 45; если bl==45, то число получается отрицательным(так как - в ANSI == 45)
JNE NEXTCHECK2
IMUL EAX, ECX; непосредственно проводим умножение 
MOV result, EAX
JMP ENDCHECK

NEXTCHECK2:
CMP BL, 90; два минуса тоже дают при умножении положительное значение
JE BOTHNEG
BOTHNEG:
CMP EAX, ECX
; знаковое сравнеине двух чисел
JB CONT2
MOV EAX, num2
MOV ECX, num1
CONT2: IMUL ECX, EAX; непосредственно проводим умножение 
MOV result, ECX
JMP ENDCHECK

ENDCHECK:
MOV EDI, 10
MOV EAX, result; записываем результат умножения
CMP EAX, 0; проверка на ноль
XOR EBX, EBX
JNE BEGINLOOP
BEGINLOOP: CMP EAX, 0
; если при умножении получилось 0, то просто просто ничего не выводим
JE EXITMARK
XOR EDX, EDX
DIV EDI; деление нашего результата на 10, по фактам смотрим сколько получилось знаков в числе
PUSH EDX
INC EBX; как раз хранит это количество, сколько будем выводить
JMP BEGINLOOP

; очищение буфера
EXITMARK: 
MOV EDI, OFFSET BUF
MOV CX, 300
MOV AL, 0
REP STOSB

;формирование строки для вывода
; записываем все необходимые данные для вывода
MOV EDI, EBX; кол-во символов выхода
MOV ESI, OFFSET BUF; буфер

MOV CL, MINUSA; минус первого
ADD CL, MINUSB; минус второго

MOV EAX, num1; значение первого
MOV EBX, num2; значение второго

CMP CL, 0; опять сравниваем на два положиетльных числа
JNE NEXTCHECK11
CMP EAX, EBX
JMP CONT3

NEXTCHECK11:
CMP CL, 45; проверка на одно отрицательное
JNE NEXTCHECK22
CMP MINUSA, '-'
JE ADDMIN1
CMP MINUSB, '-'
JNE CONT3
ADDMIN1:
; записываем - в буфер
MOV EDX, 45
MOV [ESI], EDX
INC ESI
JMP CONT3

NEXTCHECK22:
CMP CL, 90; проверка на два отрицательных числа
CMP EAX, EBX
JMP CONT3

CONT3:
MOV ECX, EDI; лупаемся по кол-ву цифр в произведении
LOOPSTR: 
; записываем в буфер следующую цифру 
POP EAX
ADD EAX, 48; прибавляем 48 так как по ANSI 0 - 48
MOV [ESI], EAX
INC ESI
LOOP LOOPSTR

;Определим длину строки BUF
PUSH OFFSET BUF
CALL lstrlenA@4
; выписываем получившееся произведение
PUSH 0
PUSH OFFSET LENS
PUSH EAX
PUSH OFFSET BUF
PUSH DOUT
CALL WriteConsoleA@20

; выход из программы
PUSH 0; параметр: код выхода
CALL ExitProcess@4
Main ENDP

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


end Main