
.MODEL SMALL
.STACK 100H

.DATA
    MESAJ_1 DB "Introduceti numarul urmat de caracterul $:", 0DH, 0AH, '$'
    MESAJ_2 DB "Cifrele sunt in numar de:", 0DH, 0AH, '$'
    LINIE_NOUA DB 0DH, 0AH, '$'
    MESAJ_PAR DB "Numarul este par.", 0DH, 0AH, '$'
    MESAJ_IMPAR DB "Numarul este impar.", 0DH, 0AH, '$' 
.CODE

    START:
    MOV AX, @DATA ; Copiem adresa segmentului de date
    MOV DS, AX    ; Incarcam adresa in registrul DS pentru a putea stii de unde o sa accesam datele

    LEA DX, MESAJ_1     ; Incarcam adresa Mesajului 1 in registrul DX   
    MOV AH, 9           ; Apelam functia 9 pentru a tipari mesajul respectiv
    INT 21H             ; Functia 9 este o intrerupere DOS (de aceea avem INT 21H)

    MOV BL, 0       ; Initializam registrul BL unde vor urma sa fie transferate si stocate cifrele introduse
    MOV CX, 0       ; Initializam registrul CX care va avea rol de contor pentru cifrele pe care le introducem

    CITIRE_NUMAR:
        MOV BL, AL      ;Salvam caracterul citit in registrul BL, pentru a putea determina corect paritatea numarului format

        MOV AH, 1
        INT 21H         ; Apelam functia 1 pentru a citi un singur caracter de la tastatura

        CMP AL, '$'         ; Verificam daca ultimul caracter citit este "$"
        JE OPRIRE_CITIRE    ; In cazul in care ultimul caracter este "$", sarim la eticheta data pentru a ne opri din citire
        
        INC CX            ; Dupa ce am citit cu succes o cifra incrementam contorul de cifre
        JMP CITIRE_NUMAR    ; In cazul in care ultimul caracter citit nu a fost "$", ne intoarcem la eticheta CITIRE_NUMAR pentru a putea continua citirea

    OPRIRE_CITIRE:
        LEA DX, LINIE_NOUA      ; Tiparim o linie noua prin incarcarea adresei in registrul DX  
        MOV AH, 9               ; si apelarea functiei 9
        INT 21H                 

        RCR BL, 1           ; Verificam paritatea numarului introdus prin rotirea bitului de carry la dreapta in binar
        JC NUMAR_IMPAR      ; Daca bitul de carry este 1 (bitul de carry este setat), atunci sarim la eticheta NUMAR_IMPAR 

        LEA DX, MESAJ_PAR   ; Incarcam adresa sirului de caractere in registrul DX, urmand ca acesta sa fie mesajul afisat in cazul in care numarul este par 
        JMP PRINTARE_MESAJ  ; Sarim la eticheta de PRINTARE_MESAJ

    NUMAR_IMPAR:
        LEA DX, MESAJ_IMPAR ;  Incarcam adresa sirului de caractere in registrul DX, urmand ca acesta sa fie mesajul afisat in cazul in care numarul este impar 
    
    PRINTARE_MESAJ:        
        MOV AH, 9       ; Apelam la functia 9 pentru a putea afisa mesajul
        INT 21H

        LEA DX, MESAJ_2     ; Incarcam adresa mesajului 2 in registrul DX
        MOV AH, 9           ; Apelam la functia 9 pentru a afisa mesajul
        INT 21H

        PUSH CX            ; Plasam valoarea din CX (numarul de cifre) pe stiva
        POP BX             ; Extragem valoarea stocata in stiva si o incarcam in registrul BX
        MOV AX, CX         ; Salvam Numarul de cifre in registrul AX, pregatindu-ne sa-l afisam
        CALL PRINTARE_NR_CIFRE     ; Facem un apel la procedura de afișare a numărului de cifre

    IESIRE_PROGRAM:
        MOV AH, 4CH     ; Apelam la functia 4C pentru a incheia programul dupa ce se apeleaza eticheta care printeaza numarul de cifre
        INT 21H

    PRINTARE_NR_CIFRE PROC      ; Initializam procedura de afisare a numarului de cifre
        MOV BX, 10      ; Incarcam valoarea 10 in registrul BX care ne va ajuta sa impartim numarul in cifre
        XOR CX, CX      ; Initializam contorul pentru cifrele numarului

    URMATOAREA_CIFRA:
        XOR DX, DX         ; Resetam registrul DX înainte de a face impartirea
        DIV BX             ; Împărțim continutul registrului AX la 10, rezultatul fiind salvat in AX
        PUSH DX            ; Salvam restul împărțirii (cifra) în stivă
        INC CX             ; Incrementam contorul de cifre
        TEST AX, AX        ; Verificam dacă AX este 0 (in cazul acesta nu mai sunt cifre)
        JNZ URMATOAREA_CIFRA     ; Continuam extragerea cifrelor, dacă nu s-a ajuns la 0
    
    CONTINUARE_PRINTARE:
        POP DX             ; Extragem cifra din stivă si o pune in DX
        ADD DL, '0'        ; Convertim cifra din valoare numerica în caracter ASCII
        MOV AH, 2          ; Apelam functia pentru afisarea caracterului
        INT 21H
        LOOP CONTINUARE_PRINTARE    ; Continuam afișarea cifrelor până când toate au fost afișate
        RET     ; Incheiem procedura si curatam valorile din stiva
    PRINTARE_NR_CIFRE ENDP      ; Incheiem procedura de afisare a numarului de cifre

    END START
