#!/bin/bash

# 1. Cargar las variables de entorno y configuración del sistema
# Este archivo define la versión de LAMMPS, el número de procesadores y los archivos de entrada.
. LAMMPS_variables.sh

# 2. Configuración de la GPU
# Se define qué GPU (dispositivo) será visible para la ejecución (específico para sistemas AMD).
export ROCR_VISIBLE_DEVICES=1

# 3. Ejecución de la simulación LAMMPS
# Se utiliza mpirun para ejecutar en paralelo usando el número de procesadores ($NUM_PROCS)
# y las opciones de GPU definidas en el archivo de entrada ($IN_FILE).
mpirun -np $NUM_PROCS /usr/local/bin/lmp_amdgpu -sf gpu -pk gpu $GPU -in $IN_FILE

# 4. Post-procesamiento: Conversión de imágenes a video
# Verifica si se generaron archivos de imagen en formato .ppm.
if ls myimage-*.ppm >/dev/null 2>&1; then
    echo "Se encontraron archivos .ppm. Iniciando conversión a video y animación..."
    # Combina todas las imágenes en un video .mp4, ordenándolas numéricamente (1, 2, 10...).
    magick $(ls -v myimage-*.ppm) simulation.mp4
    # Genera un archivo .gif animado con la secuencia numérica correcta.
    magick $(ls -v myimage-*.ppm) simulation.gif
else
    echo "No se encontraron archivos .ppm para convertir."
fi

