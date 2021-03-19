#!/bin/bash

job_type=master

hb=$3

start=0
index=$2
num=$((start + index))
submission_dir="/afs/cern.ch/user/f/ftorales/condor/IB"
run_list="${submission_dir}/${hb}.fake.good.runs"
echo run_list
run=$(sed "${num}q;d" $run_list)

path=/eos/project/a/alice-its-commissioning/InnerBarrel/runs
#condor=/afs/cern.ch/work/i/itswp2/public/belikov/condor
condor=/eos/user/f/ftorales/its_data/condor
calib_dir=$condor/IB/Calib
noise_file=$calib_dir/noise_run503091_${hb}.root
#noise_file=$calib_dir/noise_run503091.root #for bottom barrel
dicti_file=$calib_dir/ITSdictionary_149runs.bin

out=/eos/user/f/ftorales/its_data/condor #in case outdir needs changing
output_dir=$out/$hb/$run


######################## Constant part of the job ############################

echo "oooooooooooooooo Run $run ooooooooooooooo"


##### Input files 
mkdir $run
cd $run

#cp $condor/libO2ITSWorkflow.so .
cp $condor/o2sim_geometry.root .
cp $condor/o2sim_grp.root .
#cp $condor/MakeNoiseMapFromClusters.C .
cp $condor/candidates.C .
cp $dicti_file ./ITSdictionary.bin
cp $noise_file ./noise.root

for cru in ${hb}0 ${hb}1 ${hb}2a ${hb}2b
do
  echo "$cru"
  mkdir -p $cru
  cd $cru
  for f in `ls $path/$cru/$run/*.lz4`
   do
      echo "  $f"
      unlz4 -c $f > `basename $f .lz4`
   done
   cd ../
done

$condor/IB/gen_cfg.sh $hb > run.cfg

##### The job
#/cvmfs/alice.cern.ch/bin/alienv setenv O2/nightly-20200907-1 -c $condor/${job_type}.sh $run
/cvmfs/alice.cern.ch/bin/alienv setenv O2/nightly-20210215-1 -c $condor/${job_type}.sh $run

##### Output files
mkdir $output_dir 
ln -s $noise_file $output_dir/noise.root
ln -s $dicti_file $output_dir/ITSdictionary.bin

cp o2clus_its.root $output_dir/o2clus_its_${job_type}.root
cp run.cfg h_${job_type}.* *.mylog $output_dir

