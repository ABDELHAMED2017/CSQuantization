#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l walltime=192:00:00
#PBS -q q16p192h@Raptor
#PBS -m e
#PBS -r n
#PBS -N 1bit_srm-full_dct
#PBS -M ewt16@msstate.edu
#PBS -o 1bit_srm-full_dct.out
#PBS -e 1bit_srm-full_dct.err

EXP_NAME="1bit_srm-full_dct";
BITRATES="linspace(0.05,1,10)"
MODULE="@experiment_module_biht2d"
PARAMS="csq_load_params('1bit/$EXP_NAME.m')"

LENA_SAVEFILE="csq_full_path('results/rd/lena_$EXP_NAME.mat')"
BARBARA_SAVEFILE="csq_full_path('results/rd/barbara_$EXP_NAME.mat')"
BOATS_SAVEFILE="csq_full_path('results/rd/boats_$EXP_NAME.mat')"
PEPPERS_SAVEFILE="csq_full_path('results/rd/peppers_$EXP_NAME.mat')"

cd ~/git/CSQuantization/experiments

/usr/local/matlab/bin/matlab -nodisplay -r "csq_deps('common'); image_ratedistortion_experiment('lena.jpg',$BITRATES,$LENA_SAVEFILE,$MODULE,$PARAMS);"&
sleep 5s
/usr/local/matlab/bin/matlab -nodisplay -r "csq_deps('common'); image_ratedistortion_experiment('barbara.jpg',$BITRATES,$BARBARA_SAVEFILE,$MODULE,$PARAMS);"&
sleep 5s
/usr/local/matlab/bin/matlab -nodisplay -r "csq_deps('common'); image_ratedistortion_experiment('boats.jpg',$BITRATES,$BOATS_SAVEFILE,$MODULE,$PARAMS);"&
sleep 5s
/usr/local/matlab/bin/matlab -nodisplay -r "csq_deps('common'); image_ratedistortion_experiment('peppers.jpg',$BITRATES,$PEPPERS_SAVEFILE,$MODULE,$PARAMS);"&


wait