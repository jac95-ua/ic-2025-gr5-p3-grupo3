README para generar la MEMORIA de la Práctica 3 (guía para ChatGPT)
===============================================================

Este README está pensado como un "contrato" y plantilla estructurada que puedes pasar a un modelo (ChatGPT u otro) para que te genere la MEMORIA de la práctica a partir del código y resultados del repositorio.

Objetivo
--------
- Documentar brevemente el diseño, la paralelización (OpenMP + std::async), los experimentos realizados y las conclusiones.
- Proveer todos los comandos reproducibles, archivos de salida y un esquema de secciones que deben aparecer en la memoria.

Estructura mínima que debe tener la memoria (usar esta jerarquía para generar el documento)
---------------------------------------------------------------------------------
1. Portada
   - Asignatura, curso, título de la práctica (Práctica 3: Paralelismo a nivel de hilos), nombres del grupo, miembros y profesor.

2. Resumen / Abstract (1 párrafo)

3. Índice

4. Introducción
   - Objetivos de la práctica.
   - Breve descripción del problema (análisis forense: SRM, ELA, DCT).

5. Estado inicial y requisitos
   - Requisitos de software y hardware (Linux, libpng-dev, libjpeg-dev, CMake, GCC con OpenMP).
   - Cómo compilar y ejecutar (comandos exactos).

6. Descripción del código secuencial
   - Estructura del proyecto (ficheros clave): `src/main.cc`, `src/utils/image.h`, `src/utils/dct.cc`.
   - Flujo de datos y diagrama de dependencias (qué funciones se ejecutan y si dependen de otras).

7. Estrategia de paralelización
   - Paralelismo funcional: qué tareas se ejecutan con `std::async` (lista y por qué).
   - Paralelismo de datos: dónde se aplicó OpenMP (bucles por bloques DCT, bucles por filas en operaciones de imagen, convolution, etc.).
   - Decisiones de granularidad y scheduling (ej.: `#pragma omp parallel for schedule(static)`).
   - Riesgos (oversubscription, false sharing, I/O thread-safety) y cómo se mitigaron.

8. Implementación (cambios concretos)
   - Ficheros modificados y breve patch/nota (ejemplos):
       * `src/main.cc`: paralelización del bucle de bloques DCT.
       * `src/utils/image.h`: pragmas OpenMP en operaciones pixel-wise (operator*, operator+, abs, convolution, ...).
       * Scripts añadidos: `run_experiments.sh`, `run_experiments_full.sh`, `plot_results.py`.
   - Mostrar extractos de código relevantes y explicar por qué se colocan ahí los pragmas.

9. Instrumentación y metodología experimental
   - Cómo medir: `std::chrono::steady_clock` en funciones y tiempo total en `main`.
   - Scripts usados (ruta relativa):
       * `run_experiments.sh` — barrido básico (threads 1,2,4; reps=3).
       * `run_experiments_full.sh` — barrido completo (threads 1,2,4,8,nproc; reps=5).
       * `plot_results.py` — genera `run_summary.csv`, `time_vs_threads.png`, `speedup_vs_threads.png`.
   - Formato de salida: CSV con columnas `threads,rep,time_ms`.

10. Resultados
    - Incluir la tabla con los resultados (`run_results_full.csv`) y un resumen (`run_summary.csv`).
    - Figuras: `time_vs_threads.png` y `speedup_vs_threads.png`.
    - Calcular y mostrar: speed-up medio, eficiencia (E = S/p), desviaciones estándar.
    - Analizar por etapas: SRM, ELA, DCT (mostrar tiempos por etapa impresos por el programa). Si se precisa, generar tablas con tiempos por etapa.

11. Análisis (interpretación)
    - Comparar secuencial vs paralelo.
    - Aplicar Amdahl: estimar la fracción paralelizable p (usando tiempos medidos) y la ganancia máxima teórica.
    - Discutir cuellos de botella (I/O, contención de memoria, oversubscription) y explicar por qué 8 hilos no siempre mejora.

12. Conclusiones y recomendaciones
    - Resumen de mejoras conseguidas, limitaciones y recomendaciones para trabajo futuro (ej.: usar OpenMP tasks, limitar std::async o migrar a un único runtime, vectorización de DCT).

13. Anexos
    - Comandos exactos usados para reproducir los experimentos.
    - `lscpu` y `cat /proc/cpuinfo` (información de la máquina de pruebas).
    - Parches / snippets de código si procede.

Comandos reproducibles (copiar/pegar)
----------------------------------
Instalación (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install -y build-essential cmake libpng-dev libjpeg-dev python3-pip
pip3 install --user matplotlib
```

Compilar:
```bash
cd P3/P3IC/source/detect
cmake -S . -B build
cmake --build build -j$(nproc)
```

Pruebas rápidas (ejecución manual):
```bash
cd P3/P3IC/source/detect
export OMP_NUM_THREADS=4
./build/detect ./build/face_swap_enhanced.png
```

Ejecutar los experimentos y generar gráficos:
```bash
cd P3/P3IC/source/detect
chmod +x run_experiments_full.sh
./run_experiments_full.sh   # genera run_results_full.csv
python3 plot_results.py run_results_full.csv
```

Archivos de salida importantes
-----------------------------
- `run_results_full.csv` — resultados crudos
- `run_summary.csv` — medias y desviación estándar por nº hilos
- `time_vs_threads.png` — tiempo medio con barras de error
- `speedup_vs_threads.png` — speed-up relativo al caso single-thread
- imágenes generadas por el programa: `ela.png`, `srm_kernel_3x3.png`, `srm_kernel_5x5.png`, `dct_invert.png`, `dct_direct.png`

Sugerencia para pedir a ChatGPT que genere la MEMORIA
-----------------------------------------------------
Proporciona a ChatGPT (o al modelo que uses) los siguientes elementos en este orden:
1. El enunciado resumido (puedes pegar la sección de la práctica que te pasé inicialmente).
2. Este README (explicando que debe seguir la estructura de secciones).
3. El CSV `run_results_full.csv` y `run_summary.csv` (copiar las tablas o pegarlas como texto).
4. Las imágenes `time_vs_threads.png` y `speedup_vs_threads.png` (adjuntarlas si el modelo lo permite o describirlas).
5. Pídele una memoria con N páginas (ej. 6–10), incluyendo: portada, introducción, metodología, resultados (con tablas/figuras), análisis (incluyendo Amdahl) y conclusiones.

Ejemplo de prompt corto para ChatGPT:
"Genera una memoria académica (6–8 páginas) para la Práctica 3 de la asignatura 'Ingeniería de los Computadores' siguiendo esta estructura: [pega el índice del punto 4 al 13]. Usa estos resultados (pega aquí run_summary.csv y run_results_full.csv) y estas gráficas (describe o adjunta). Explica decisiones de paralelización (OpenMP + std::async), incluye análisis Amdahl y conclusiones prácticas."

Notas finales y limitaciones
---------------------------
- Este README está pensado para un flujo de trabajo práctico y reproducible. Puedes adaptar los scripts para más tamaños de imagen o para ejecutar en paralela en el laboratorio.
- Si vais a mezclar `std::async` y OpenMP en producción, decidid una política de concurrencia (limitar `OMP_NUM_THREADS` y/o limitar tareas concurrentes con semáforos) para evitar oversubscription.

Contacto / autor de estas modificaciones
--------------------------------------
Los cambios en este repositorio (paralelización simple y scripts de experimentos) fueron aplicados por los autores del grupo; incluir en la memoria una nota que explique quién hizo qué cambios.

Fin del README para la memoria.
