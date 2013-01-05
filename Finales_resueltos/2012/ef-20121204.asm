; 1) Siendo que en modo protegido IA-32 la estructura de un segmento TSS no contempla re-
; gistros del tipo XMM, y que en modo IA-32e directamente no hay soporte para cambio de
; contexto, responda los siguientes ítems indicando el modo de trabajo que considera para sus
; respuestas (IA-32 o IA-32e):

; a) ¿Que recursos del procesador, relacionados con la conmutación de tareas y manejo de
; excepciones, utilizaría para generar eventos que incluyan a los mismos en un contexto
; propio desarrollado por el programador de sistemas?.

; b) En base a lo contestado en el ítem anterior especifique el contenido que deberán tener
; los recursos indicados durante la ejecución del sistema y durante la conmutación de
; tarea.

; c) Desarrolle el handler de la excepción utilizada para el resguardo de estos registros.


; 2) Para un procesador trabajando en modo protegido IA-32 (32 bits):
; a) Explique el manejo de pila durante una interrupción existiendo y no existiendo cambio
; de nivel de privilegio. Dibuje el esquema de las pilas de nivel 0 resultante para cada
; caso.

Con cambio de privilegio:
    1) El STACK SEGMENT SELECTOR (SS) y el STACK POINTER (ESP) a ser usado por el handler
    se obtiene de la TSS de la tarea que se esta ejecutando. En este nuevo stack el 
    procesador pushea el STACK SEGMENT SELECTOR y el STACK POINTER del procedimiento interrumpido.

    2) El procesador guarda los estados actuales de los registros EFLAGS, CS y EIP en el
    nuevo stack.

    3) Si una excepción (en este caso es una interrupción) causa un error, el CODE ERROR es
    pusheado al stack despues del valor EIP

Sin cambio de nivel de privilegio:
    1) El procesador guarda los estados actuales de los registros EFLAGS, CS, y EIP 
    en el stack actual.

    2) Si una excepción (en este caso es una interrupción) causa un error, el CODE ERROR es
    pusheado al stack despues del valor EIP

; b) Qué relación posee la pregunta anterior con que Linux mantenga una sola TSS por CPU,
; siendo que la conmutación se realiza por software?

; 3) Explique que relación debe existir entre el CPL del código interrumpido, el campo DPL del
; descriptor de la IDT de la interrupción en cuestión, considerando en su opinión cual es el
; nivel de privilegio en el que se ejecutará dicha interrupción para:

; a) Interrupciones de Hardware
; b) Interrupciones de Software
; c) Excepciones

; 4) Sea la función long * prod_escalar (long *a , long *b, int numelem) una función que calcula y
; devuelve el producto escalar de 2 vectores de numelem elementos. Se pide que implemente
; dicha función mediante 2 threads, donde el primero de ellos calcule los primeros 50 elemen-
; tos, y el segundo se encargue de los 50 elementos restantes. Algoritmo genérico del producto
; escalar:


struct data {
    long *a;
    long *b;
    int numelem;
    int mitad;
};

long * prod_escalar (long *a , long *b, int numelem) {

    pthread_t tid1, tid2;
    struct data dat;

    dat.a = a;
    dat.b = b;
    dat.numelem = numelem;
    dat.mitad = 0

    pthread_create (&tid1, NULL, &convolution, &dat);

    dat.midad = 1;

    pthread_create (&tid2, NULL, &convolution, &dat);

    
}

long * handler (long *a, long *b, int numelem) {



}