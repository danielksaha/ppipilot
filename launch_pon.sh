#!/bin/bash
scriptdir=/home/dmalload/ppipilot/scripts
usage="$0 pon.txt outputdir [bed]\npon.txt: space-separated file with casename file_T\n"

if [[ $# -lt 2 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] || [[ ! -f $1 ]]
then
    echo -e $usage
    exit
fi

bed=""

if [[ $# -gt 2 ]] && [[ $3 != "" ]]
then
    bed=$3
fi

outputdir=$2

echo "Outputdir $outputdir"
mkdir -p $outputdir

dependency="--dependency=afterok"

while read name tumor
do
    tumor=$(readlink -e $tumor)
    mkdir -p $outputdir/$name
    dir=$(readlink -e $outputdir/$name)
    echo "Submitting case $name. Results in $dir"
    njob=$(submit $scriptdir/mutect2_tonly.sh $tumor $dir $bed | sed "s/Queued job //g")
    dependency=$dependency":"$njob
done < $1

submit $dependency $scriptdir/pon.sh $outputdir
