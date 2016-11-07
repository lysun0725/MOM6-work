#!/bin/csh
#SBATCH -n 80         #STEVE: number of processors
#SBATCH -t 10:00:00   #STEVE: wall clock limit
#SBATCH -A aosc-hi 
#SBATCH -J mom6_test
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lysun@umd.edu

set root       = /lustre/lysun/models/MOM6-test/MOM6-examples
set platform   = intel
set exp1       = ice_ocean_SIS2 
set exp2       = OM4_025 
 

set exp_dir    = ${root}/${exp1}/${exp2}

rm -rf ${exp_dir}/CPU_stats
rm -rf ${exp_dir}/ocean.stats
rm -rf ${exp_dir}/time_stamp.out
rm -rf ${exp_dir}/logfile.000000.out
rm -rf ${exp_dir}/fms.out
cd ${exp_dir}
mkdir -p RESTART

source $root/build/${platform}/env.dt2

mpirun -np 80 ${root}/build/${platform}/${exp1}/repro/MOM6 > fms.out

