# IC_P3
Diagrama de dependencias:
          [ Cargar Imagen (image) ]
                        |
   +--------------------+--------------------+--------------------+--------------------+
   |                    |                    |                    |                    |
   v                    v                    v                    v                    v
[ compute_srm(3) ] [ compute_srm(5) ] [ compute_ela ] [ compute_dct(true) ] [ compute_dct(false) ]
   |                    |                    |                    |                    |
   v                    v                    v                    v                    v
[ Guardar SRM 3x3 ] [ Guardar SRM 5x5 ] [ Guardar ELA ] [ Guardar DCT Inv ] [ Guardar DCT Dir ]


hay que hacer pararelismo secuencial en estas 5 ya que no dependen ninguna entres si, se puede usar std::async para lanzar estas 5 funciones de forma asíncrona, permitiendo que se ejecuten en paralelo en diferentes hilos.

Ahora, analicemos dentro de cada función para identificar los bucles costosos. Aquí es donde aplicarás el paralelismo de datos con OpenMP.

1. compute_srm (en main.cc)

Esta función es una cadena de operaciones de procesamiento de imagen. La mayoría de estas operaciones (definidas en image.h y image.cc) son bucles for que recorren todos los píxeles.

    image.to_grayscale(): Contiene un bucle for anidado (filas j, columnas i) [en image.h]. Es paralelizable.

    srm.convolution(...): Contiene un bucle for triplemente anidado (filas j, columnas i, canales c) y luego dos bucles más para el kernel (u, v) [en image.h]. Los bucles exteriores (j, i, c) son perfectamente paralelizables con #pragma omp parallel for.

    srm.abs(), srm.normalized(), srm * 255 y srm.convert(): Todas estas funciones auxiliares [en image.h] contienen bucles anidados (j, i, c) para aplicar una operación simple a cada píxel. Todas son paralelizables con OpenMP.

        Nota: normalized() requiere encontrar un min y max en un primer bucle. Deberás usar una cláusula reduction(min:min_value) reduction(max:max_value) en ese bucle.

2. compute_dct (en main.cc)

Este es el proceso más interesante y costoso. Tiene dos niveles claros donde se puede aplicar paralelismo:

    Paralelismo de Bloques (Nivel 1): El bucle principal de esta función es for(int i=0; i<blocks.size(); i++). Este bucle itera sobre todos los bloques de 8x8 de la imagen, y el procesamiento de cada bloque es totalmente independiente de los demás.

        Acción: Este es el candidato más importante y efectivo para paralelizar con #pragma omp parallel for.

    Paralelismo dentro de la DCT (Nivel 2): Dentro de ese bucle, se llama a dct::direct y/o dct::inverse [en dct.cc]. Si miras esas funciones, ambas contienen cuatro bucles for anidados (i, j, k, l).

        Acción: Los bucles exteriores (i, j) también podrían paralelizarse con OpenMP.

        ¡Advertencia! El enunciado de la práctica te pregunta: "¿Se degrada el rendimiento al paralelizar ciertas partes?". Si paralelizas el bucle de bloques (Nivel 1) y también los bucles dentro de la DCT (Nivel 2), estarás usando paralelismo anidado. Esto puede crear muchísimos más hilos de los necesarios, saturando la CPU y degradando el rendimiento debido al overhead.

        Estrategia recomendada: Paraleliza únicamente el bucle exterior (Nivel 1, sobre los bloques) y deja que cada hilo ejecute el cálculo de la DCT de forma secuencial.

3. compute_ela (en main.cc)

Esta función tiene un problema clave:

    Cuello de botella secuencial: Para funcionar, necesita guardar una imagen comprimida en el disco (save_to_file("_temp.jpg", ...)) y luego volver a cargarla (load_from_file("_temp.jpg")). Estas operaciones de Entrada/Salida (I/O) son inherentemente secuenciales y no las puedes paralelizar.

    Partes paralelizables: Sin embargo, las operaciones aritméticas que se realizan después de cargar la imagen (como compressed + ..., .abs(), .normalized(), etc.) son los mismos bucles for que procesan píxel a píxel que vimos en compute_srm. Esas partes sí se pueden paralelizar con OpenMP.