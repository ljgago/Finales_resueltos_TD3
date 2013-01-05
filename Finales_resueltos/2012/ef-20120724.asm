; 1. En un sistema operativo, se ha decidido utilizar un mecanismo de manejo de memoria
; implícito. Esto quiere decir que, cuando una tarea requiere una página de memoria para
; utilizarla, elige directamente una dirección de memoria a su gusto y la utiliza, sin avisarle a nadie
; que lo hará. Para poder funcionar de esta forma, el sistema operativo utiliza la unidad de
; paginación que provee la arquitectura. Al detectar la intención de utilizar una página nueva por
; parte de una tarea, el sistema utiliza el fallo de página (#PF) para realizar las modificaciones
; correspondientes y mapear una nueva página al lugar solicitado.; 

; a. Describa la entrada en la IDT necesaria para la rutina de atención de interrupción de
; fallo de página (#PF).; 

inicio_IDT:
    resb    8       ; INT 0     #DE
    resb    8       ; INT 1     #DB
    resb    8       ; INT 2     #
    resb    8       ; INT 3     #BP
    resb    8       ; INT 4     #OF
    resb    8       ; INT 5     #BR
    resb    8       ; INT 6     #UD
    resb    8       ; INT 7     #NM
    resb    8       ; INT 8     #DF
    resb    8       ; INT 9     #
    resb    8       ; INT 10    #TS
    resb    8       ; INT 11    #NP
    resb    8       ; INT 12    #SS
    resb    8       ; INT 13    #GP

sel_14_INO      equ $-inicio_IDT    ; INT 14    #PF
handler_14_INO:
    istruc descriptor_idt
    at idt_offset_low,      dw      handler_14
    at idt_selector,        dw      sel_codigo
    at idt_param,           db      0
    at idt_access,          db      10000110b
    at idt_offset_high      dw      0
    iend

    resb    8       ; INT 15    #
    resb    8       ; INT 16    #MF
    resb    8       ; INT 17    #AC
    resb    8       ; INT 18    #MC
    resb    8       ; INT 19    #XF
    resb    8       ; INT 20    #
    resb    8       ; INT 21    #
    resb    8       ; INT 22    #
    resb    8       ; INT 23    #
    resb    8       ; INT 24    #
    resb    8       ; INT 25    #
    resb    8       ; INT 26    #
    resb    8       ; INT 27    #
    resb    8       ; INT 28    #
    resb    8       ; INT 29    #
    resb    8       ; INT 30    #
    resb    8       ; INT 31    #

; b. Escriba el código necesario para la rutina de atención de la interrupción de fallo de
; página (#PF). En caso de haber memoria física disponible, la interrupción debe mapear una
; nueva página al lugar solicitado para que la tarea la utilice. Puede asumir que la tarea corre en
; anillo 0 y siempre hay memoria física disponible. Estructurar este código de modo de ordenar el
; trabajo dividiendo el procesamiento en las siguientes funciones:

PAGE_DIR        equ 0x10000
PAGE_TABLE      equ 0x11000


handler_14:
    mov eax, PAGE_DIR




; Accede a las tablas de Página de la tarea y devuelve la dirección física de una nueva página libre.
extern int pagina_libre (void);

GLOBAL pagina_libre

pagina_libre:
    push ebp
    mov ebp, esp

    mov edi, PAGE_DIR
    mov ecx, 1024
    xor eax, eax      

bucle_comparar_1:
    mov eax, dword[edi]             ; Me fijo si tengo la dirección de una Tabla de Página disponible 
    and eax, 1                      ; para utilizar, dentro del Directorio de Tabla de Páginas
        je tabla_pagina_disponible
    add edi, 4                      ; Apunto a la siguiente dirección
    loop bucle_comparar_1

tabla_pagina_disponible:
    mov eax, dword[edi]
    shr eax, 12             ; Guardo obtengo la dirección de la Tabla de páginas disponible
    mov dword[edi], eax
    mov ecx, 1024

bucle_comparar_2:
    mov eax, dword[edi]             ; Me fijo si encuentro una página disponible
    and eax, 1
        je pagina_disponible
    add edi, 4
    loop bucle_comparar_2

pagina_disponible:
    mov eax, dword[edi]     ; Obtengo la dirección física con offset = 0
    and eax, 0xFFFFF000     ; | Dir Física 31-12 | Offset 11-0 |

salida:
    mov esp, ebp            ; Similar a colocar:
    pop ebp                 ;       leave
    ret                     ;       ret
                            ; retorno de la función con el valor que contiene EAX


; Crea un mapeo entre una dirección virtual y una física a partir de basePD.
extern void mapear_pagina (unsigned int virtual, unsigned int fisica, unsigned int basePD);

GLOBAL mapear_pagina

DTP     dd 0    ; Offset del Directorio de Tabla de Páginas
TP      dd 0    ; Offset de la Tabla de Páginas
PTBA    dd 0    ; Page Table Base Addres
PBA     dd 0    ; Page Base Addres

mapear_pagina:
    push ebp
    mov ebp, esp

    ; Divido la dir vertual en | DTP 31-22 | TP 21-12 | OFFSET 11-0 |
    mov eax, dword[ebp + 08h]   ; Obtengo el 1er parametro: virtual
    shr eax, 22                 ; desplazo 22 bits a la derecha para tener el offset del DTP
    mov dword[DTP], eax

    mov eax, dword[ebp + 08h]
    shl eax, 10                 ; El TP ahora esta en los bits MAS significativos
    shl eax, 22                 ; El TP lo muevo a los bits MENOS significativos
    mov dword[TP], eax

    mov eax, dword[DTP]
    add eax, dword[ebp + 10h]   ; EAX = basePD + DTP
    mov eax, dword[eax]         ; EAX = PTBA original
    and eax, FFFFF000h          ; dejo solo la base del PTBA
    mov dword[PTBA], eax        ; Obtengo el PTBA
    
    add eax, dword[TP]          ; EAX = dirección de TBA+Propiedades
    mov edx, eax                ; copio la dirección TBA+Propiedades en EDX como auxiliar
    mov ebx, dword[eax]         ; EBX = TBA+Propiedades
    and ebx, 00000FFFh          ; dejo solo el sector de las propiedades
    mov eax, dword[ebp + 0Ch]   ; copio la dir física en EAX
    and eax, FFFFF000h          ; dejo solo la dir física sin el offset
    add eax, ebx                ; EAX = Base Dir Física + Propiedades
    
    mov dword[edx], eax         ; guardo la Base Dir Física + Propiedades en PBA

    xor eax, eax                ; EAX = 0

    ; Termino mi programa
    mov esp, ebp
    pop ebp
    ret


; Invalida la entrada de la TLB correspondiente a la dirección lineal virtual. Pista: Usar la
; instrucción INVLPG.
void flush_TLB_Entry (unsigned int virtual);

