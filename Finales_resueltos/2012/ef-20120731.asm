; 1.a) Describa como completar las primeras entradas de la GDT en función de los segmentos que 
; se detallan en la siguiente tabla. Los valores base y límite deben indicarse en hexadecimal.

istruc descriptor_GDT
    at gdt_limit_low        dw      0xFFFF      ;
    at gdt_base_low         dw      0x0000      ;
    at gdt_base_high        db      0x00        ;
    at gdt_access_rights    db      10001011b   ;
    at gdt_attrib_lim       db      11011101b   ;
    at gdt_base_ehi         db      0x00        ;
iend

istruc descriptor_GDT
    at gdt_limit_low        dw      0xFDFF      ;
    at gdt_base_low         dw      0x0000      ;
    at gdt_base_high        db      0x00        ;
    at gdt_access_rights    db      10100011b   ;
    at gdt_attrib_lim       db      11011101b   ;
    at gdt_base_ehi         db      0x80        ;
iend

istruc descriptor_GDT
    at gdt_limit_low        dw      0x0FCD      ;
    at gdt_base_low         dw      0x3400      ; Base de 4KB
    at gdt_base_high        db      0x00        ;
    at gdt_access_rights    db      11001001b   ;
    at gdt_attrib_lim       db      01010000b   ;
    at gdt_base_ehi         db      0x00        ;
iend

istruc descriptor_GDT
    at gdt_limit_low        dw      0x01FF      ; limite 512KB
    at gdt_base_low         dw      0x0000      ;
    at gdt_base_high        db      0x30        ;
    at gdt_access_rights    db      11100011b   ;
    at gdt_attrib_lim       db      11010000b   ;
    at gdt_base_ehi         db      0x00        ;
iend

; b) Especifique todas las entradas de las estructuras necesarias para construir un 
; esquema de paginación según la siguiente tabla. Suponga que todas las entradas no 
; mencionadas son nulas. Los rangos incluyen el último valor. Los permisos deben 
; definirse como supervisor.

Rango Lineal                        Rango físico
0xABCFE000 - 0xABD02FFF             0xBDFFE000 - 0xBE002FFF
0x00000000 - 0x00003FFF             0x033E0000 - 0x033E3FFF

+===========================================+
|                                           |
+===========================================+

Tengo 5 páginas:
Pág 0:  0x0000 - 0x0FFF
Pág 1:  0x1000 - 0x1FFF
Pág 2:  0x2000 - 0x2FFF
Pág 3:  0x3000 - 0x3FFF
Pág 4:  0x4000 - 0x4FFF


; c. Resolver las siguientes direcciones, de lógica a lineal y a física. Utilizar las estructuras
; definidas en los ítems anteriores. Si se produjera un error de protección, indicar cual es el
; mismo y en que unidad de la MMU se produce.
; i.      0x008:0xE0000005 - CPL 00 - ejecución
; ii.     0x009:0xABCFE000 - CPL 00 - lectura
; iii.    0x010:0xABAFE222 - CPL 01 - lectura
; iv.     0x01B:0x00000800 - CPL 11 - lectura
; v.      0x023:0x00000000 - CPL 10 - escritura
; vi.     0x033:0x00000010 - CPL 11 - ejecución

0x008 --> 1er descriptor RPL = 0
0x009 --> 1er descriptor RPL = 1
0x010 --> 2do descriptor RPL = 0
0x01B --> 3er descriptor RPL = 3
0x023 --> 4to descriptor RPL = 3
0x033 --> 6to descriptor RPL = 3



http://www.guitarristas.info/foros/listado-escalas-mayores-menores-naturales-pentatonicas/20497


; 2) En un sistema operativo se desea permitir a las tareas trabajar en equipo. En este
; sistema las tareas son ejecutadas una a una durante intervalos de tiempo fijos (quantum). El
; quantum es global para todas las tareas y no puede modificarse. En cualquier momento, una
; tarea puede decidir delegar su tiempo (quantum) restante de procesador a otra tarea, ya sea la
; siguiente o una tarea determinada. Esta acción se realiza una sola vez. En la siguiente ejecución
; de la tarea, esta recupera su quantum totalmente. Si lo desea, puede volver a delegarlo. El
; sistema permite hacer pedidos a través de la interrupción 66. Los posibles pedidos son:


; mensaje             delegar_siguiente               delegar_tarea
  código(eax)         101                             202
  argumento(ebx)      -                               id_tarea

; a. Escribir el código de la estructura de datos utilizaría para almacenar la lista de tareas
; y que funciones posee para su manipulación.

TASK_STATE_SEGMENTS:
%define pila_sup        FIN+100h
%define pila_inf        FIN+200h
%define pila_sched      FIN+300h

; Declaro las tres struc TSS, dos de ellas con los campos necesarios
; inicializados
;****************** Reservo espacio para la TSS inicial ***********************
TSS_inicial_struc: resb tss_struc_size

; ***************** TSS para la tarea scheduler *******************************
TSS_sched_struc istruc tss_struc
    at tss_struc.reg_PRL,       dw 40h
    at tss_struc.reg_CR3,       dd PAGE_DIR
    at tss_struc.reg_EIP,       dd tarea_sched
    at tss_struc.reg_EFLAGS,    dd 202h
    at tss_struc.reg_ESP,       dd pila_sched
    at tss_struc.reg_CS,        dw sel_codigo
    at tss_struc.reg_SS,        dw sel_datos
    at tss_struc.reg_DS,        dw sel_datos
    at tss_struc.reg_IOMAP,     dw 68h
    at tss_struc.IOMAP,         dd 0FFFFFFFFh
iend
; *****************************************************************************
; ***************** TSS para la tarea T1 **************************************
TSS_T1_struc istruc tss_struc
    at tss_struc.reg_PRL,       dw 40h
    at tss_struc.reg_CR3,       dd PAGE_DIR
    at tss_struc.reg_EIP,       dd tarea_T1
    at tss_struc.reg_EFLAGS,    dd 202h
    at tss_struc.reg_ESP,       dd pila_T1
    at tss_struc.reg_CS,        dw sel_codigo
    at tss_struc.reg_SS,        dw sel_datos
    at tss_struc.reg_IOMAP,     dw 68h
    at tss_struc.IOMAP,         dd 0FFFFFFFFh
iend
; *****************************************************************************
; ***************** TSS para la tarea T2 **************************************
TSS_T2_struc istruc tss_struc
    at tss_struc.reg_PRL,       dw 40h
    at tss_struc.reg_CR3,       dd PAGE_DIR
    at tss_struc.reg_EIP,       dd tarea_T2
    at tss_struc.reg_EFLAGS,    dd 202h
    at tss_struc.reg_ESP,       dd pila_T2
    at tss_struc.reg_CS,        dw sel_codigo
    at tss_struc.reg_SS,        dw sel_datos
    at tss_struc.reg_IOMAP,     dw 68h
    at tss_struc.IOMAP,         dd 0FFFFFFFFh
iend
; *****************************************************************************
; ***************** TSS para la tarea T3 **************************************
TSS_T3_struc istruc tss_struc
    at tss_struc.reg_PRL,       dw 40h
    at tss_struc.reg_CR3,       dd PAGE_DIR
    at tss_struc.reg_EIP,       dd tarea_T3
    at tss_struc.reg_EFLAGS,    dd 202h
    at tss_struc.reg_ESP,       dd pila_T3
    at tss_struc.reg_CS,        dw sel_codigo
    at tss_struc.reg_SS,        dw sel_datos
    at tss_struc.reg_IOMAP,     dw 68h
    at tss_struc.IOMAP,         dd 0FFFFFFFFh
iend
; *****************************************************************************

; b. Escriba las funciones delegar_tarea(int id) y delegar_siguiente(), que como su
; nombre lo indica, delegan el procesador a la tarea id o a la siguiente tarea respectivamente.

// En C
extern int delegar_tarea (int id);
extern int delegar_siguiente (void);

; En ASM

GLOBAL delegar_tarea
GLOBAL delegar_siguiente


delegar_tarea:
    push ebp
    mov ebp, esp
    mov eax, dword[ebp + 08h]   ; Guardo el 1er parametro de la función en EAX







; c. Indique como configurar la IDT para cumplir con los requerimientos. Además escriba
; el código del handler de la INT 66 utilizando las funciones anteriores, delegar_tarea(int id) y
; delegar_siguiente().


; if (quantum == conmutar)
;   ir a cambio_tarea;
;
; cambio_tarea:
;   quantum = 0;
;   if (flg_conm == 1) {
;       flg_conm = 0;
;       ir a sin_cambio_tarea;
;   }
;   if (T1 == 1)
;       ir a cambio_tarea_2
;   if (T2 == 1)
;       ir a cambio_tarea_3
;   if (T3 == 3)
;       ir a cambio_tarea_1



%define FIN_CICLO   15


conmutar db 5
T1 db 1
T2 db 0
T3 db 0
quantum db 0
flg_conm db 0


tarea_sched:
    pushad
    mov ah, 0
    mov al, 20h
    out 20h, al

; Verifico de que tarea venia, e incremento el contador de tiempo
; de la tarea correspondiente
; las tareas guardan ese valor en EDX
    mov ax, word[TSS_sched_struc + tss_struc.reg_PTL]
    cmp ax, sel_tss_T1
        je _incermentar_T1
    cmp ax, sel_tss_T2
        je _incermentar_T2
    cmp ax, sel_tss_T3
        je _incrementar_T3
    jmp _seguir
    
_incrementar_T1:
    inc byte[TSS_T1_struc + tss_struc.reg_EDX]
    jmp _seguir

_incrementar_T2:
    inc byte[TSS_T2_struc + tss_struc.reg_EDX]
    jmp _seguir

_incrementar_T3:
    inc byte[TSS_T3_struc + tss_struc.reg_EDX]
    jmp _seguir

_seguir:
    inc byte[quantum]
    mov al, [quantum]
    cmp al, [conmutar]   ; if(quantum == conmutar)
        jae cambio_tareas
    iret
    ; jmp tarea_sched

cambio_tareas:
    mov byte[quantum], 0
    mov al, 1
    cmp al, [flg_conm]
        jae sin_cambio_tarea
    cmp al, [T1]                ; if (T1 == 1)
        jae cambio_tarea_T2     ; ir a cambio_tarea_T2
    cmp al, [T2]                ; if (T2 == 1)
        jae cambio_tarea_T3     ; ir a cambio_tarea_T3
    cmp al, [T3]                ; if (T3 == 1)
        jae cambio_tarea_T1     ; ir a cambio_tarea_T1

sin_cambio_tarea:
    mov byte[flg_conm], 0
    iret

cambio_tarea_T1:
    jmp sel_tarea_T1:0
    
cambio_tarea_T2:
    jmp sel_tarea_T2:0

cambio_tarea_T3:
    jmp sel_tarea_T3:0




; 3. Indique como es la estructura de un módulo que contiene un char device en Linux.
; Escriba el código (al menos los ítems fundamentales) para el manejo de una interrupción y de
; una función de lectura que bloquea el proceso invocante. Explique como maneja el Sistema
; operativo ambas situaciones.

MODULE_INIT(my_init);
MODULE_EXIT(my_exit);

struct file_operations {
    .open = my_open,
    .read = my_read,
    .write = my_write,
    .release = my_release,
    .owner = THIS_MODULE
};

int my_init (void) {
    printk (KERNEL_INFO "Iniciando módulo\n");
    return 0;
}

void my_exit (void) {
    printk (KERNEL_INFO "Módulo finalizado\n");
}

int my_open (struct inode *inode, struct file *filp) {

}

