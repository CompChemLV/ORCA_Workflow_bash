input=$task.inp
MAX_CORE=$((GB_PER_CORE * 1024))

cat > ${input} <<EOF
# $task
! XTB1 TightSCF

%pal
    nprocs ${NUM_PROCS}
end

%MaxCore ${MAX_CORE}

#%basis
#    Basis "${basis}"
#    AuxJ ""
#    AuxJK ""
#    AuxC ""
#    CABS ""
#end

%method
    RunTyp ${RUNTYPE}
end

%scf
    HFTYP ${DFTYP}
    Guess PAtom
    GuessMode CMatrix
    AutoStart false
    Convergence tight
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
    print[p_mos] false
    print[p_basis] 0
end

%base "${xyz}_XTB_${RUNTYPE}"

%geom
    MaxIter 500
    coordsys cartesian
    Step rfo
    UseGDIIS false
    MaxStep 0.3
    Trust -0.3
    Convergence tight
    ProjectTR false
end

* xyzfile ${CHARGE} ${multiplicity} ${xyz}.xyz *
EOF
