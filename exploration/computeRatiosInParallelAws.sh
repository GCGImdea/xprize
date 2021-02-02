#!/bin/bash

NUMINSTANCES=$1

for n in `seq 1 $NUMINSTANCES`; do
    rm -rf ipsv-$n
    mkdir -p ipsv-$n
done

curInst=1
for file in `ls -r ips-vectors-aws/*` ; do

    cp $file ipsv-$curInst
    let curInst=curInst+1
    if [ $curInst -gt $NUMINSTANCES ] ; then
	curInst=1
    fi
done	   


for n in `seq 1 $NUMINSTANCES`; do
    Rscript compute_ratios.R ./ipsv-$n/ >ipsv-$n.out 2>&1 &

done

wait
