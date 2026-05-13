# Detección de archivos para reinicio (gbw y xyz de cálculo previo)
if [ -f "${xyz}_OPT.gbw" ] && [ -f "${xyz}_OPT.xyz" ]; then
    cp "${xyz}_OPT.gbw" "${xyz}_OPT_restart.gbw"
    GUESS="MORead"
    MOINP="MOInp \"${xyz}_OPT_restart.gbw\""
    COORD_FILE="${xyz}_OPT.xyz"
else
    GUESS="PAtom"
    MOINP=""
    COORD_FILE="${xyz}.xyz"
fi

MAX_CORE=$((GB_PER_CORE * 1024))

cat > $input <<EOF
# $task
! ${functional}
%pal
    nprocs ${NUM_PROCS}
end

%MaxCore ${MAX_CORE}

%method
    RunTyp OPT
    method DFT
    AngularGrid 7
    IntAcc 5.0
    AngularGridX 1,2,3
    IntAccX 4.5
end

%basis
    Basis "${basis}"
    AuxJ "def2-mTZVP/J"
    AuxJK "def2/JK"
    AuxC "def2-QZVPP/C"
end

%scf
    HFTYP ${DFTYP}
    Guess ${GUESS}
    ${MOINP}
    GuessMode CMatrix
    AutoStart false
    Convergence VeryTight
    ConvCheckMode 2
    ConvForced 1
    MaxIter 1000
    CNVZerner true
    CNVDamp true
    DampFac 0.5
    DampErr 0.01
    CNVShift false
    LevelShift 0.5
    ShiftErr 0
    CNVDIIS true
    DIISMaxIt 10
    DIISStart 0.001
    DIISMaxEq 7
    DIISBFac 1.3
    DIISMaxC 15.
end

%output
    JSONPropFile True
    print[P_Cartesian] 1
    print[P_Internal] 1
    print[P_MOs] 1
    print[P_Basis] 2
    Print[P_Mulliken] 1
    Print[P_Mayer] 1
    Print[P_Loewdin] 1
    Print[P_Symmetry] 1
end

%nbo
NBOKEYLIST = "\$NBO NPA NBO PLOT ARCHIVE AONBO=C AONBO=W File=./${xyz}_NBO \$END" 
end

%base "${xyz}_OPT"

%geom
    MaxIter 800
    coordsys cartesian
    Step rfo
    UseSOSCF true
    MaxStep 0.3
    Trust -0.3
    Convergence tight
    ProjectTR false
end

* xyzfile ${CHARGE} ${multiplicity} ${COORD_FILE} *

EOF
