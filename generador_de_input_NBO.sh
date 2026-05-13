MAX_CORE=$((GB_PER_CORE * 1024))

cat > $input <<EOF
# $task_NBO

! NBO ${DISPERSION} ${functional}

%nbo
NBOKEYLIST = "\$NBO NPA NBO NRT PLOT ARCHIVE AONBO=C AONBO=W File=./${xyz}_SP_NBO \$END" 
end

%pal
    nprocs ${NUM_PROCS}
end

%MaxCore ${MAX_CORE}

%method
    RunTyp SP
    method DFT
    AngularGrid 7
    IntAcc 5.0
    AngularGridX 1,2,3
    IntAccX 4.5
    WriteJSONPropertyfile True
end

%basis
    Basis "${basis}"
    AuxJ "def2-mTZVP/J"
    AuxJK "def2/JK"
    AuxC "def2-QZVPP/C"
end

%base "${xyz}_SP_NBO"

%scf
    HFTYP ${DFTYP}
    Guess MORead
    MOInp "${xyz}_OPT.gbw"
    GuessMode CMatrix
    AutoStart false
    Convergence VeryTight
    ConvCheckMode 2
    ConvForced 1
    MaxIter 800
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

* xyzfile ${CHARGE} ${multiplicity} ${xyz}_OPT.xyz *

EOF
