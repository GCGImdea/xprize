#!/bin/bash - 
#===============================================================================
#
#          FILE: hammerman.sh
# 
#         USAGE: ./hammerman.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 27/01/21 12:43
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#HAMMERS_DIR='hammer-dfs'
#HAMMERS_DIR='exploration/hammer-dfs-with-HX'
HAMMERS_DIR='./scenarios-to-simulate'
DEPTH=`echo $HAMMERS_DIR | grep -oe "/" | wc -l`
DEPTH=$(( $DEPTH + 2 ))
PRED_DIR="./predictions-raw"


# If an argument is given, it is used as hammers' prefix
if [ "$#" -ge 1 ]; then
    hammers_prefix="$1"
else
    hammers_prefix="hammmer"
fi

# If a 2nd argument is given, it is used as hammers' suffix
if [ "$#" -eq 2 ]; then
    hammers_sufix="$2"
else
    hammers_sufix=""
fi



# Execute predictor for every hammer with the above prefix
# for hammer in `ls $HAMMERS_DIR/"$hammers_prefix"*"$hammers_sufix".csv`; do
for hammer in `ls $HAMMERS_DIR/*.csv`; do
    start_=`echo $hammer | grep -o "sn-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`
    end_=`echo $hammer | grep -o "e-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`

    out=$(echo predicted-`echo $hammer | cut -d'/' -f$DEPTH`)

    # Specify dates if not present in filename (e.g., Anta's files)
    if [ -z $start_ ]; then
        start_="2020-11-01"
    fi
    if [ -z $end_ ]; then
	end_="2021-02-08"
    fi
    echo $start_ $end_

    echo "[HAMMERMAN] Applying hammer $hammer"
    echo "[HAMMERMAN]   invoking predictor"
    python3 standard_predictor/predict.py -s "$start_" -e "$end_"\
        -ip $(pwd)/$hammer\
        -o $(pwd)/$PRED_DIR/$out
    echo "[HAMMERMAN]   results stored $(pwd)/$PRED_DIR/$out"
done
