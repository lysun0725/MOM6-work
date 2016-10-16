#!/bin/csh
#SBATCH -n 20         #STEVE: number of processors
#SBATCH -t 01:00:00   #STEVE: wall clock limit
#SBATCH -A aosc-hi 
#SBATCH -J mom6_test
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lysun@umd.edu

set root       =  /lustre/lysun/models/MOM6-examples
set platform   =  intel
set exp        =  ocean_only/double_gyre/

set exp_dir    = ${root}/${exp}

rm -rf ${exp_dir}/CPU_stats
rm -rf ${exp_dir}/ocean.stats

cd ${root}/${exp}
mkdir -p RESTART

mpirun -n 20 ${root}/build/${platform}/ocean_only/repro/MOM6

