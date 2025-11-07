<<<<<<< HEAD
# IC_P3

Diagrama de dependencias:
          [ Cargar Imagen (image) ]
                        |
   +--------------------+--------------------+--------------------+-----------------+
                 |                                                       |                    |                    |                    |
                 v                                                       v                    v                    v                    v
            [ compute_srm(3) ] [ compute_srm(5) ] [ compute_ela ] [ compute_dct(true) ] [ compute_dct(false) ]
                 |                                                       |                    |                    |                    |
                 v                                                       v                    v                    v                    v
            [ Guardar SRM 3x3 ] [ Guardar SRM 5x5 ] [ Guardar ELA ] [ Guardar DCT Inv ] [ Guardar DCT Dir ]

Hay que ejecutar en paralelo las 5 tareas principales ya que no dependen entre sí; se pueden lanzar con `std::async` para que se ejecuten en hilos distintos.

Dentro de cada función hay bucles costosos donde aplicar paralelismo de datos con OpenMP:

1) compute_srm (en `main.cc` / `image.h` / `image.cc`)
   - Muchas operaciones son bucles por píxel (to_grayscale, convolution, abs, normalized, multiply, convert).
   - Normalized requiere una reducción (min/max) previa; usar `reduction(min:...)` y `reduction(max:...)`.

2) compute_dct (en `main.cc` y `dct.cc`)
   - Paralelismo por bloques (bucle externo sobre bloques 8x8) es el candidato principal para `#pragma omp parallel for`.
   - Paralelizar también los bucles internos de la DCT implica paralelismo anidado y puede degradar rendimiento por oversubscription. Estrategia recomendada: paralelizar el bucle de bloques y mantener la DCT interna secuencial por bloque.

3) compute_ela (en `main.cc`)
   - Requiere operaciones secuenciales de I/O (guardar/comprimir y recargar), pero la parte de procesamiento por píxel tras la recarga se puede paralelizar con OpenMP.

Notas:
- Evitar paralelizar en exceso (mezclar `std::async` sin controlar `OMP_NUM_THREADS` puede producir oversubscription).
- Ignorar los artefactos generados (build, imágenes y CSVs) con un `.gitignore` para mantener el repositorio limpio.
