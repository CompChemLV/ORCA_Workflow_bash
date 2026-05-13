#!/bin/bash
#SBATCH --job-name=NiC         # Job Name
#SBATCH --ntasks=10              # Tasks
#SBATCH --nodes=1              # Nodes
#SBATCH --partition=main

# DEFINE EL DIRECTORIO DE TRABAJO
#SBATCH --time=8-0        # days-hours:minutes:seconds

#SBATCH --error=error%j.err
#SBATCH --output=output%j.log


## AQUI SE DEFINEN LOS COMANDOS NECESARIOS PARA LANZAR EL JOB

module load intel/2019b
module load ORCA/5.0.4-may2023-intel2019b-OpenMPI-4.1.1
module list


export NBOMEN=1gb
export NBOIN=/home/fruette/nbo7/bin/
export NBOEXE=/home/fruette/nbo7/bin/nbo7.i4.exe
export GENEXE=/home/fruette/nbo7/bin/gennbo.i4.exe


ORCA=v5.0.4
DISPERSION=D3BJ
CHARGE=0
BASIS=(def2-SVP def2-TZVP def2-QZVPP)
FUNCTIONAL=(PBE0)
XYZ=(Ni_cor_edge_1 Ni_cor_edge_2 Ni_cor_edge_3)
for xyz in ${XYZ[@]}
do
    for functional in ${FUNCTIONAL[@]}
    do
        for basis in ${BASIS[@]}
        do 
            Sum=$(awk 'FNR==NR {a[$1]=$2; next} ($1 in a){print $5, a[$1]}' elements_reference.csv ../../Structure/${xyz}.xyz  | awk '{sum += $1} END{print sum}')
            Parity=$((Sum % 2))
            if [ $Parity -eq 0 ]
            then
                MULTIPLICITY=(1 3)
            else
                MULTIPLICITY=(2 4)
            fi
            
            for multiplicity in ${MULTIPLICITY[@]}
            do
                if [ ${multiplicity} -eq 1 ]
                then
                    DFTYP=RKS
                else
                    DFTYP=UKS
                fi
                
                task=${xyz}_${functional}_${basis}_${DFTYP}_${CHARGE}_${multiplicity}_${DISPERSION}_${ORCA}                
                if [ -d $task ]
                then
                    cp ../../Structure/${xyz}.xyz $task/
                    cd ${task}
                else                
                    mkdir ${task}
                    cp ../../Structure/${xyz}.xyz $task/
                    cd ${task}
                fi

                INPUT=(${task}_OPT_chile.inp ${task}_FREQ_chile.inp ${task}_SP_NBO_chile.inp)
                for input in ${INPUT[@]}
                do
                    script=$(echo ${input} | sed "s/^$task/generador_de_input/; s/.inp$/.slurm/")
                    . ../${script}
                
                /home/lmod/software/ORCA/5.0.4-may2023-intel2019b-intel-2019b-OpenMPI-4.1.1/orca ${input} &> ${input%%.inp}.out 
                rm *.tmp
                
                done
		cd ../
            done
        done
    done
done
