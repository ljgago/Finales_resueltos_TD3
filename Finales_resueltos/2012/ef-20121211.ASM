; 1) Cambio de Nivel de Privilegio de una tarea. Responda los siguientes ítems indicando el modo
; de trabajo que considera para sus respuestas (IA-32 o IA-32e):

; A) Mencione dos mecanismos por los cuales una tarea pueda acceder cuando lo necesite,
; a un servicio residente en un segmento no conforming de mayor Nivel de Privilegio.

Mecanismos:
    (mediante un CALL o un JMP)
    Se puede acceder mediante una compuerta de llamada (Call Gate)

; B) ¿Que valor de privilegio debe tener los mecanismos mencionados en (a)?.

    Duda con estos puntos ...
    CALL    CPL <= Call gate DPL
            RPL <= Call gate DPL

    JMP     CPL <= Call gate DPL
            RPL =  Call gate DPL

; C) Para los escenarios descriptos en (a), se pide una descripción detallada del tratamiento de pila. 
; ¿Que valores contienen los registros SS:ESP una vez accedido el código privilegiado?.
; Indicar como se obtienen estos valores.

Tratamiento de la pila:
    1) Se utiliza el DPL del Segmento de Código (el nuevo CPL) destino para seleccionar un puntero
    al el nuevo stack.

    2) Se guardan temporalmente los valores actuales de los registros SS y ESP del proceso llamante.

    3) Se pushean los registros SS y ESP del proseso "llamante" en el stack del proceso "llamado" 
    (stack de mayor nivel de provilegio).

    4) Se copian los parámetros del proceso "llamante" al proceso "llamado" el el nuevo stack.

    5) Se pushea la dirección de retorno (el CS y el EIP).

El CS y el EIP contiene la dirección de retorno del proceso "llamante".

; 2) Protección de páginas:
; A) Explicar como es el mapeo del CPL en los niveles de privilegio de las páginas.

RESPUESTA: los CPLs 0, 1, 2 del segmento se mapean en el nivel supervisor de las
páginas, mientras que el nivel 3 se corresponde al nivel de usuario.

; B) Un código cuyo CPL mapea como supervisor, intenta escribir una página que tiene
; permiso Read Only. ¿Cuál es el resultado?

RESPUESTA: Por default (CR0.WP = 0) el supervisor tiene acceso a lectura y escritura
    independientemente del valor del flag R/W

; C) Explicar que ocurre en el caso detallado en (b) si el acceso se realiza con CR0.WP=1.
; En función de su respuesta indique en que casos resulta útil el empleo de este bit.

RESPUESTA: Si CR0.WP = 1, el acceso esta determinado por el flag R/W del DIRECTORIO
DE TABLAS y por las TABLAS DE PÁGINAS, en este caso se produce un fallo de página #PF

; 3) En un esquema de segmentación Flat, escriba el código que permita implementar un esquema
; de paginación que permita clonar tareas de modo que al ser creada la tarea nueva comparta
; las mismas páginas que contienen el código y los datos de la original. Ni bien la original o
; alguna de las tareas clon intenten modiﬁcar un dato, el kernel le proveerá su propia copia a
; la tarea que ejecutó la modiﬁcación, de modo que sea esta copia “personal” la que utilizará a
; partir de ese momento.

; 4) Sea la función void sobel (char *orig , char *dest, int ancho, int alto, int profundidad)
; una función que aplica el operador Sobel a una imagen monocromo para efectuar un gradiente
; clásico para detección de bordes. Se pide que implemente dicha función mediante threads, a
; razón de uno por cada ﬁla. El algoritmo genérico consiste en la convolución de la matriz de
; 3x3 compuesta por el pixel en cuestión y su N8, con cada operador de Sobel.

;      |-1 0 +1|
; Gx = |-2 0 +2|
;      |-1 0 +1|
 
;      |+1 +2 +1|
; Gy = | 0  0  0|
;      |-1 -2 -1|
 
 
; El valor absoluto del gradiente es para calcular cada pixel resultante es:
 
; |G| = sqrt(Gx^2 + Gy^2)

; Para simpliﬁcar el cálculo puede usar la siguiente aproximación (saturando el resultado):
; |G| = |Gx| + |Gy|




 // Matriz Gx rotada 180º
int Gx[3][3] = {{1, 0, -1}, {2, 0, -2}, {1, 0, -1}};

// Matriz Gy rotada 180º
int Gy[3][3] = {{-1, -2, 1}, {0, 0, 0}, {1, 2, 1}};

pthread_t tid1, tid2, tid3;

struct data {
    char *orig;
}

void sobel (char *orig, char *dest, int ancho, int alto, int profundidad) {

    pthread_create (&tid1, NULL, sobel_fila, &arg1);
    pthread_create (&tid2, NULL, sobel_fila, &arg2);
    pthread_create (&tid3, NULL, sobel_fila, &arg3);

    pthread_join (tid1, &arg1_);
    pthread_join (tid2, &arg2_);
    pthread_join (tid3, &arg3_);    
}


void sobel_fila (void *arg) {

}


