#!/bin/sh

#Set number of Runs(Only relevant if parallel is installed).
# Will automatically use GNU parallel if found or else run normally.
NRuns=5

#Set relevant flags and inputs files.
#e.g. "-m Materials/mat_B11.dat -b Beams/beam.dat"
Flags="-m Materials/mat_Water.dat -b Beams/beam.dat -d Scoring/detect.dat -g Geometries/Phantom_Small.dat"



#Check if shieldhit is availabel as a global executable.
if ! command -v shieldhit > /dev/null
then
    echo "Shieldhit is not availabel as a global executable. This can be \"fixed\"
     by adding: export PATH=<path to executable>:\$PATH
     to your .bashrc file if you are on a linux system.

"
    exit
fi

#Create output directory with relevant subdirectories.
# (make sure that the output directory is included in the .gitignore file)
if [ ! -d output ]
then
    mkdir output
    mkdir output/ShieldLog
    mkdir output/GEMCA
    mkdir output/SecondaryNeutrons
    mkdir output/data
fi
# Check if privious data exist from old simulations and delete.
mkdir -p output
mkdir -p output/ShieldLog
mkdir -p output/GEMCA
mkdir -p output/SecondaryNeutrons
mkdir -p output/data
if [ -d output/data ]
then
  if [ "$(ls -A output/data)" ]
  then
       echo "cleaned out the privius output/data"
           cd output/data
           ls | xargs gio trash
           cd -
  else
      echo "output/data is Empty"
  fi
fi

if [ -d output/GEMCA ]
then
  if [ "$(ls -A output/GEMCA)" ]
  then
       echo "cleaned out the privius output/GEMCA"
           cd output/GEMCA
           ls | xargs gio trash
           cd -
  else
      echo "output/GEMCA is Empty"
  fi
fi

if [ -d output/SecondaryNeutrons ]
then
  if [ "$(ls -A output/SecondaryNeutrons)" ]
  then
       echo "cleaned out the privius output/SecondaryNeutrons"
           cd output/SecondaryNeutrons
           ls | xargs gio trash
           cd -
  else
      echo "output/SecondaryNeutrons is Empty"
  fi
fi
if [ -d output/ShieldLog ]
then
  if [ "$(ls -A output/ShieldLog)" ]
  then
       echo "cleaned out the privius output/ShieldLog"
           cd output/ShieldLog
           ls | xargs gio trash
           cd -
  else
      echo "output/ShieldLog is Empty"
  fi
fi

#Create input string for ShieldHit12A(Setting seed number depending on run number).
SH_Input=""
for i in $(seq $NRuns)
do
  SH_Input="${SH_Input}-N$i "
done

# For doing multithreaded simulaitons we use GNU parallel (https://www.gnu.org/software/parallel/)

#Check if parallel is installed and use if it is
if command -v parallel > /dev/null #ERROR ON PORPUSE
then
    echo $SH_Input | xargs parallel --eta -j 10 shieldhit $Flags :::
else
    shieldhit $Flags

    mv *_log output/ShieldLog
    mv fort.17 output/GEMCA
    mv fort.28 output/SecondaryNeutrons
fi


# Relocate output files to relevant directory
mv *.bdo output/data
mv *.log output/ShieldLog
mv for017* output/GEMCA
mv for028* output/SecondaryNeutrons

# Use convertmc to generate graphs
cd output/data
# Not sure this is correct...
convertmc image --many "msh_y*.bdo" 
convertmc image --many "msh_z*.bdo" 

convertmc plotdata --many "msh_y*.bdo" 
convertmc plotdata --many "msh_z*.bdo" 