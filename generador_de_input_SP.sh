MAX_CORE=$((GB_PER_CORE * 1024))

cat > $input <<EOF
# $task_SP

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

%base "${xyz}_SP"

%scf
    HFTYP ${DFTYP}
    Guess PAtom
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
    Print[ P_Internal ] 1
end

* xyzfile ${CHARGE} ${multiplicity} ${xyz}.xyz *

EOF
