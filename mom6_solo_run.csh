#!/bin/csh
#SBATCH -n 80         #STEVE: number of processors
#SBATCH -t 10:00:00   #STEVE: wall clock limit
#SBATCH -A aosc-hi 
#SBATCH -J mom6_test
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lysun@umd.edu

set root0      = /lustre/lysun/models/MOM6-test/
set root       = /lustre/lysun/models/MOM6-test/MOM6-examples
set root_dr    = ${root0}/MOM6-drifter-example
set platform   = intel
set exp1       = ice_ocean_SIS2 
set exp2       = GulfOfMexico 
set npes       = 80

set exp_dir    = ${root_dr}/${exp1}/${exp2}

set mppnccombine  = ${root0}/MOM6-work/bin/mppnccombine.$platform  # path to executable mppnccombine
set time_stamp    = ${root0}/MOM6-work/bin/time_stamp.csh          # path to cshell to

rm -rf ${exp_dir}/CPU_stats
rm -rf ${exp_dir}/ocean.stats
rm -rf ${exp_dir}/time_stamp.out
rm -rf ${exp_dir}/logfile.000000.out
rm -rf ${exp_dir}/fms.out
rm -rf ${exp_dir}/OUTPUT
rm -rf ${exp_dir}/RESTART
cd ${exp_dir}
mkdir -p RESTART
mkdir -p OUTPUT

source ${root}/build/${platform}/env.dt2
mpirun ${root}/build/${platform}/${exp1}/repro/MOM6 > fms.out

#----------------------------------------------------------------------------------------------
# generate date for file names ---
#    set begindate = `$time_stamp -bf digital`
#    if ( $begindate == "" ) set begindate = tmp`date '+%j%H%M%S'`
#    set enddate = `$time_stamp -ef digital`
#    if ( $enddate == "" ) set enddate = tmp`date '+%j%H%M%S'`
#    if ( -f time_stamp.out ) rm -rf time_stamp.out

#----------------------------------------------------------------------------------------------
# get a tar restart file
#  cd RESTART
#  rm -rf input.nml
#  rm -rf *_table
#  rm -rf icebergs.res.nc.* # Note only for OM4_025

# combine netcdf files
#  if ( $npes > 1 ) then
#    set file_previous = ""
#    set multires = (`ls *.nc.????`)
#    foreach file ( $multires )
#	if ( $file:r != $file_previous:r ) then
#	    set input_files = ( `ls $file:r.????` )
#              if ( $#input_files > 0 ) then
#                 $mppnccombine $file:r $input_files
#                 if ( $status != 0 ) then
#                   echo "ERROR: in execution of mppnccombine on restarts"
#                   exit 1
#                 endif
#                 rm -rf $input_files
#              endif
#           else
#              continue
#           endif
#           set file_previous = $file
#       end
#  endif

#  cd ${exp_dir}
#  rm -rf  history
#  mkdir -p history
#  rm -rf  ascii
#  mkdir -p ascii

#----------------------------------------------------------------------------------------------
# rename ascii files with the date
#  foreach out (`ls *.out`)
#     mv -f $out ascii/$begindate.$out
#  end

# combine netcdf files
#  if ( $npes > 1 ) then
#    set file_previous = ""
#    set multires = (`ls *.nc.????`)
#    foreach file ( $multires )
#	if ( $file:r != $file_previous:r ) then
#	    set input_files = ( `ls $file:r.????` )
#              if ( $#input_files > 0 ) then
#                 $mppnccombine $file:r $input_files
#                 if ( $status != 0 ) then
#                   echo "ERROR: in execution of mppnccombine on history"
#                   exit 1
#                 endif
#                 rm -rf $input_files
#              endif
#           else
#              continue
#           endif
#           set file_previous = $file
#       end
#  endif

#----------------------------------------------------------------------------------------------
# rename nc files with the date
#  foreach ncfile (`/bin/ls *.nc`)
#     mv -f $ncfile history/$begindate.$ncfile
#  end
#
#  unset echo


echo end_of_run
echo "NOTE: Natural end-of-script."
exit 0

