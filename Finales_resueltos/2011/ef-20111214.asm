; 5) Se desea implementar la función combinar que dadas 2 imágenes de igual
; tamaño y en escala de grises retorna una tercera formada a partir de estas 2.
; Cada pixel de la imagen generada se forma de la siguiente manera:

; dst (i,j) = [src1(i,j) – src2(i,j)] / 2 + src2(i,j)

; El prototipo de la función es:
;
; void combinar (unsigned char* src1, unsigned char* src2, unsigned char* dst, int ancho, int alto);

; Aclaraciones:
; La función se debe implementar utilizando instrucciones SIMD.
; El ancho y alto de las imágenes puede tener cualquier valor mayor que 16, las mismas
; no tienen padding.

; Puede presumir que ancho es múltiplo de un valor conveniente para no tener que
; manejar casos bordes (indicar el múltiplo elegido) y que las imágenes no tienen
; padding.

; En cada instrucción SSE se debe mostrar el contenido del registro destino.

shr1mask = 0111 1111  0111 1111  0111 1111  0111 1111  0111 1111  0111 1111  0111 1111  0111 1111b <-- esta = 0x7F7F7F7F7F7F7F7F
shr2mask = 0011 1111  0011 1111  0011 1111  0011 1111  0011 1111  0011 1111  0011 1111  0011 1111b
shr3mask = 0001 1111  0001 1111  0001 1111  0001 1111  0001 1111  0001 1111  0001 1111  0001 1111b
shl1mask = 1111 1110  1111 1110  1111 1110  1111 1110  1111 1110  1111 1110  1111 1110  1111 1110b
shl2mask = 1111 1100  1111 1100  1111 1100  1111 1100  1111 1100  1111 1100  1111 1100  1111 1100b
shl3mask = 1111 1000  1111 1000  1111 1000  1111 1000  1111 1000  1111 1000  1111 1000  1111 1000b

;shr1mask equ 0111111101111111011111110111111101111111011111110111111101111111b
shr1mask dq 0x7F7F7F7F7F7F7F7F

GLOBAL combinar

combinar:
    push ebp            ; 
    mov ebp, esp

    ; Me fijo el tamaño de la imagen en pixels ANCHO x ALTO
    mov eax, dword[ebp + 14h]       ; EAX = ancho
    mov ebx, dword[ebp + 18h]       ; EBX = alto
    mul ebx                         ; EAX = EAX x EBX

    shr eax, 3                      ; Divido por 8 == desplazar 3 bits a la derecha
                                    ; Dibido por 8 porque voy a tener 8 datos de 1 byte
    mov ecx, eax                    ; ECX es el contador

    ; EBP + 08h = *src1
    ; EBP + 0Ch = *src2
    ; EBP + 10h = *dst
loop_funcion_combinar:
    mov esi, dword[ebp + 08h]       ; ESI = *src1
    mov ebx, dword[ebp + 0Ch]       ; EBX = *src2
    mov edi, dword[ebp + 10h]       ; EDI = *dst

    movq mm0, qword[esi]
    movq mm1, qword[ebx]

    psubb mm0, mm1                  ; mm0 = src1(i,j) – src2(i,j)
    
    ;                         |aabb|ccdd|
    ; desplazo paquete word   |0aab|bccd|
    ; desplaso paquete byte   |0aab|0ccd|
    
    ; Utilizo una máscara para simular el shift register empaquetado a byte

    movq mm7, qword[shr1mask]

    psrlw mm0, 1                    ; shift register empaquetado word a la derecha (desplazo 1 bit a la derecha)
    
    ; Al realizar la operación AND con esta máscara, obtengo el shift register empaquetado a byte 
    pand mm0, mm7                   ; mm0 = [src1(i,j) – src2(i,j)] / 2
    
    paddb mm0, mm1                  ; mm0 = [src1(i,j) – src2(i,j)] / 2 + src2(i,j)

    movq qword[edi], mm0

    add esi, 8                      ; Apunto la los 8 bytes siguientes
    add ebx, 8                      ; Apunto la los 8 bytes siguientes
    add edi, 8                      ; Apunto la los 8 bytes siguientes

    loop loop_funcion_combinar
  
    jmp end
end:
    leave   ; mov esp, ebp
            ; pop ebp
    ret



    