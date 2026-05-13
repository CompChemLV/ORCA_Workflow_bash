MAX_CORE=$((GB_PER_CORE * 1024))

cat > $input <<EOF
# $task
! ${functional}
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
end

%basis
    Basis "${basis}"
    AuxJ "def2-mTZVP/J"
    AuxJK "def2/JK"
    AuxC "def2-QZVPP/C"
end

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

%base "${xyz}_FREQ"


%freq
   AnFreq true
   NumFreq false
   Temp 298.15
   Pressure 1
end

* xyzfile ${CHARGE} ${multiplicity} ${xyz}_OPT.xyz *

EOF
