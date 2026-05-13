paths=$(find . -type f -name "*_OPT.molden.input")
for p in $paths
	do
	directory=$(dirname $p)
	file=$(basename $p)
	cd $directory
	Multiwfn $file  < ../Multiwfn_CPs_instructions.txt
	Multiwfn $file  < ../Multiwfn_Baders_charge_instructions.txt > dummy.txt
	sed -n '/Normalization factor of the integral of electron density is/,/Integrating basins took up wall clock time/p' dummy.txt > Bader_charges.txt
	rm dummy.txt
	cd ../
	done
