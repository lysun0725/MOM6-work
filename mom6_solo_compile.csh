#!/bin/csh
set root=/lustre/lysun/models/MOM6-test/MOM6-examples


#template=${root}/src/mkmf/templates/ncrc-intel.mk
set template=${root}/src/mkmf/templates/dt2-intel.mk
set DO_NO_SIS2=0 # 1 if ocean_only; 0 if ice_sea_SIS2

# Compiling the FMS shared mode

mkdir -p ${root}/build/intel/shared/repro/
(cd ${root}/build/intel/shared/repro/; rm -f path_names; \
${root}/src/mkmf/bin/list_paths ${root}/src/FMS; \
${root}/src/mkmf/bin/mkmf -t $template -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

# The above creates the file build/intel/shared/repro/Makefile which you can use to build the fms library:

(cd ${root}/build/intel/shared/repro/; source ../../env.dt2; make NETCDF=3 REPRO=1 libfms.a -j)

# which creates the file build/intel/shared/repro/libfms.a. This is a library that we will link to after compiling the MOM6 source code.

if (${DO_NO_SIS2} == 1) then
  # Compiling MOM6 in ocean-only mode (Without SIS)
  mkdir -p ${root}/build/intel/ocean_only/repro/
  cd ${root}/build/intel/ocean_only/repro/
  rm -f path_names

  # use executive file list_paths to list all the paths of the targeted file and generate "path_names"
  ${root}/src/mkmf/bin/list_paths ${root}/src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}

  # use exective file mkmf to compile all files listed in the "path_names" and generate the ex
  cd ${root}/build/intel/ocean_only/repro/ 
  #${root}/src/mkmf/bin/mkmf -t $template -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names

  ### modified by CDA_START
  ${root}/src/mkmf/bin/mkmf -t $template -o '-I../../shared/repro -I/lustre/lysun/models/MOM6-test/MOM6-examples/src/MOM6/src/parameterizations/CVmix' -p MOM6 -l '-L../../shared/repro -lfms -L/lustre/lysun/models/MOM6-test/MOM6-examples/src/MOM6/src/parameterizations/CVmix/ -lcvmix' -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names
  ### modified by CDA_END

  (cd ${root}/build/intel/ocean_only/repro/; source ../../env.dt2; make NETCDF=3 REPRO=1 MOM6 -j)


  # NOTES:1. Passing -I ../../shared/repro via the -o option to mkmf is making sure that the modules files associated with libfms.a can be found. Similarly passing '-L../../shared/repro -lfms' via the -l option to mkmf is specifying where to look for libfms.a.

  # 2. Again, to compile in debug mode, change "repro" to "debug" in every place above.

  # 3. To run the circle_obcs case, you need to replace config_src/dynamic with config_src/dynamic_symmetric above.

else
  # Compiling MOM6 in MOM6-SIS2 coupled mode
  mkdir -p ${root}/build/intel/ice_ocean_SIS2/repro/
  (cd ${root}/build/intel/ice_ocean_SIS2/repro/; rm -f path_names; \
  ${root}/src/mkmf/bin/list_paths ${root}/src/MOM6/config_src/{dynamic_symmetric,coupled_driver} \
  ${root}/src/MOM6/src/{*,*/*} \
  ${root}/src/{atmos_null,coupler,land_null,ice_ocean_extras,icebergs,FMS/coupler,FMS/include} \
  ${root}/src/SIS2/{config_src/dynamic_symmetric,src})

 
  
  cd ${root}/build/intel/ice_ocean_SIS2/repro/
#  ${root}/src/mkmf/bin/mkmf -t ${template} -o '-I../../shared/repro' -p MOM6 -l '-L../../shared/repro -lfms' -c '-Duse_libMPI -Duse_netCDF -DSPMD -DUSE_LOG_DIAG_FIELD_INFO -Duse_AM3_physics' path_names
  ${root}/src/mkmf/bin/mkmf -t $template -o '-I../../shared/repro -I/lustre/lysun/models/MOM6-test/MOM6-examples/src/MOM6/src/parameterizations/CVmix    ' -p MOM6 -l '-L../../shared/repro -lfms -L/lustre/lysun/models/MOM6-test/MOM6-examples/src/MOM6/src/parameterizations/CVmix/ -lcvmix' -c '-Duse_libMPI -Duse_netCDF -DSPMD -D_USE_LEGACY_LAND_ -Duse_AM3_physics' path_names

  # compile the MOM6 sea-ice ocean coupled model with:
  (cd ${root}/build/intel/ice_ocean_SIS2/repro/; source ../../env.dt2; make NETCDF=3 REPRO=1 MOM6 -j)
endif

echo "NOTE: Natural end-of-script."
exit 0

