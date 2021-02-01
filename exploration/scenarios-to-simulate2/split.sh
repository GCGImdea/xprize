#!/bin/bash


i=0;
for f in `ls *csv`; do
  # retrieve the percent. order
  p=`echo "scale=2; $i/501" | bc`;
  echo $p

  # 
  if (( `echo "scale=2; $p < .25" | bc -l` )); then
    cp $f sim2-1st-quarter
    echo first
  elif (( `echo "scale=2; $p < .5" | bc -l` )); then
    cp $f sim2-2st-quarter
    echo second
  elif (( `echo "scale=2; $p < .75" | bc -l` )); then
    cp $f sim2-3st-quarter
    echo third
  else
    echo fourt fourthh 
    cp $f sim2-4st-quarter
  fi
  
  i=$(( i + 1 ))
done

