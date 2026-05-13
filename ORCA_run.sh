# Cargar variables externas (como las listas XYZ, FUNCTIONAL, BASIS, CHARGE, etc.)
. ./ORCA_variables.sh

# Configuración de variables de entorno para OpenMPI y NBO
export PATH="/opt/openmpi/openmpi-4.1.6/bin:$PATH"
export LD_LIBRARY_PATH="/opt/openmpi/openmpi-4.1.6/lib:$LD_LIBRARY_PATH"
export NBOEXE=/opt/nbo7/bin/nbo7.i4.exe
export NBOFIL=${input}

# Definición de rutas a los ejecutables de ORCA y herramientas relacionadas
runorca=/opt/orca_6_1_1_avx2/orca
runorca_2mkl=/opt/orca_6_1_1_avx2/orca_2mkl
rungennbo=/opt/nbo7/bin/gennbo.i4.exe

# Ciclo principal: Itera sobre cada estructura (XYZ), funcional y base de orbitales
for xyz in ${XYZ[@]}
do
    for functional in ${FUNCTIONAL[@]}
    do
        for basis in ${BASIS[@]}
        do 
            # Cálculo de la multiplicidad basado en la suma de electrones (referencia en CSV)
            # Determina si el sistema es de capa cerrada (singlete) o abierta (doblete)
            Sum=$(awk 'FNR==NR {a[$1]=$2; next} ($1 in a){print $5, a[$1]}' elements_reference.csv ../Structures/${xyz}.xyz  | awk -v charge="${CHARGE}" '{sum += $1} END{print sum - charge}')
            Parity=$((Sum % 2))
            if [ $Parity -eq 0 ]
            then
                MULTIPLICITY=(1 3)
            else
                MULTIPLICITY=(2 4)
            fi
            
            # Itera sobre la multiplicidad (usualmente una única entrada definida arriba)
            for multiplicity in ${MULTIPLICITY[@]}
            do
                # Elige RKS para singletes y UKS para dobletes
                if [ ${multiplicity} -eq 1 ]
                then
                    DFTYP=RKS
                else
                    DFTYP=UKS
                fi
                
                # Define el nombre de la tarea combinando los parámetros de cálculo
                task=${xyz}_${functional}_${basis}_${DFTYP}_${CHARGE}_${multiplicity}_${DISPERSION}_${ORCA_VERSION}                
                
                # Crea o gestiona el directorio de trabajo para la tarea actual
                if [ -d $task ]
                then
                    cp ../Structures/${xyz}.xyz $task/
                    cd ${task}
                else                
                    mkdir ${task}
                    cp ../Structures/${xyz}.xyz $task/
                    cd ${task}
                fi
                
                # Generación y ejecución de los inputs de ORCA
                for type in "${CALC_TYPES[@]}"
                do
                    input="${task}_${type}.inp"
                    # Llama al script generador de input correspondiente
                    script=$(echo ${input} | sed "s/^$task/generador_de_input/; s/.inp$/.sh/")
                    . ../${script}
                    
echo "
#############################################################
****   comienza trabajo ${input}   ****    
#############################################################
"
echo "
orca ${input} > ${input%%.inp}.out 
"
                    # Ejecución principal de ORCA
                $runorca ${input} > ${input%%.inp}.out 2> Errores.txt
echo "
****  ${input} termino   ****
"
                done
                
                # Limpieza de archivos temporales .tmp
                if [ -f "*.tmp" ]
                then
                    rm *.tmp
                    echo "Se eliminaron todos los archivos temporales"
                else
                    echo "No hay archivos temporales que eliminar"
                fi
                
                # Post-procesamiento: Generar archivo molden y convertir para AIM
                if [ -f "${xyz}_OPT.gbw" ]
                then
                    $runorca_2mkl ${xyz}_OPT -molden
                fi    
                
                # Configuración y ejecución de la conversión a AIM
                . ../generador_de_m2a.ini.sh
                ../molden2aim.exe -i ${xyz}_OPT.molden.input
                
                # Limpieza final antes de subir de nivel
                rm *.tmp 
                
                cd ../
            done
        done
    done
done
