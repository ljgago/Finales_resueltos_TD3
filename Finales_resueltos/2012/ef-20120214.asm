; 1) Proponga en forma completa, un esquema de paginación que permita a 3 tareas, tener
; alojado tanto su código como datos de los primeros 4K lineales que “ve cada una”
; en el primer, segundo y tercer GB respectivamente. Se pide: las tablas de paginación
; con sus valores en cada descriptor significativo, descriptores de tabla de páginas,
; Descriptores de página y los valores de CR3 que debería tener la TSS de cada tarea.
; Modelo de segmentación FLAT.


; Interpretación: en los primeros 4KB de cada GB de memoria tengo los datos y el
; codigo 

+===========================================+
|                                           |
+                1GB - 4KB                  +
|                                           |
+===========================================+
|           4KB Datos y Codigo              |
+===========================================+
|                                           |
+                1GB - 4KB                  +
|                                           |
+===========================================+
|           4KB Datos y Codigo              |
+===========================================+
|                                           |
+                1GB - 4KB                  +
|                                           |
+===========================================+
|           4KB Datos y Codigo              |
+===========================================+

CR3_T1 = 0x00000000
CR3_T2 = 0x40000000
CR3_T3 = 0x80000000

Direcciones lineales:

T1 - Dir: 000h      Table: 000h         Offset: 000h
T2 - Dir: 100h      Table: 000h         Offset: 000h
T3 - Dir: 200h      Table: 000h         Offset: 000h


; Cada tarea va tener 1 directorio de tablas de páginas y 1 tabla de páginas.

DIR_TABLE_T1 = 0000h
TABLE_PAGE_T1 = 1000h


; 2) Siendo el siguiente código, el correspondiente a un servidor concurrente en régimen;
; y siendo fdset un set compuesto por un socket TCP y un descriptor de stdin, complete
; el código faltante para que:

; a. Si se recibe información por el socket, se debe procesar dicha información
; mediante la función char * restult processRequest(char * request) y enviar el
; resultado obtenido en al cliente TCP. (no hace falta desarrollar la funcion
; processRequest)

; b. Si se recibe información por stdin, debe ser procesada utilizando la misma
; funcion del punto a) pero el resultado obtenido debe ser presentado por pantalla.

while ( 1) {
    FD_ZERO (&fdset);
    FD_SET(fdsock, &fdset);
    FD_SET(fdstdin, &fdset);

    // *** Este el código faltante: ***
    tv.tv_sec = 10;
    tv.tv_usec = 0;

    select (fdsock + 1, &fdset, NULL, NULL, &tv);

    if ( FD_ISSET(fdsock, &fdset) ) {
        recv (fdsock, &Datos, sizeoff(Datos), 0);
        processRequest(&Datos);
    }
    else {
        recv (0, &Datos, sizeoff(Datos), 0);
        // scanf ("%s", &Datos);

        printf ("%s\n", Datos);
    }
}




; 4) Sea la función long prod_escalar (int * a, long * b, int cant) una función que calcula
; y devuelve el producto escalar de 2 vectores de cant elementos de tipo long. Se pide
; que implemente dicha función mediante 2 threads, donde el primero de ellos calcule
; los primeros 50 elementos, y el segundo se encargue de los 50 elementos restantes.


struct sembuf lock={0, -1, 0};
struct sembuf unlock={0, 1, 0};
#define lock()      semop(semid, &lock, 1)
#define unlock()    semop(semid, &unlock, 1)

long res1, res2;

void funcion1 (int *a, long *b, int cant) {
    long res1 = 0;

    lock();
    for (int i = 0 ; i <= cant/2 ; i++) {
        res1 = (long) a[i] * b[i] + res1;
    }
    return;
}

void funcion2 (int *a, long *b, int cant) {
    res2 = 0;
    
    //lock();
    for (int i = cant/2 ; i <= cant ; i++) {
        res2 = (long) a[i] * b[i] + res2;
    }
    return;
}

long prod_escalar (int * a, long * b, int cant) {
    pthread_t hilo_1;
    pthread_t hilo_2;
    pthread_create (&hilo_1, NULL, &funcion1, NULL);
    pthread_create (&hilo_2, NULL, &funcion2, NULL);

    pthread_join (hilo_1, NULL);
    pthread_join (hilo_2, NULL);

    return res1 + res2;
}







