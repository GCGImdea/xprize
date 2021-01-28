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
HAMMERS_DIR='exploration/hammer-dfs-with-HX'
PRED_DIR="exploration/predictor-dfs-with-HX"


# If an argument is given, it is used as hammers' prefix
if [ "$#" -eq 1 ]; then
    hammers_prefix="$1"
else
    hammers_prefix="hammmer"
fi

# Execute predictor for every hammer with the above prefix
for hammer in `ls $HAMMERS_DIR/"$hammers_prefix"*.csv`; do
    start_=`echo $hammer | grep -o "sn-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`
    end_=`echo $hammer | grep -o "e-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`

    out=$(echo predicted-`echo $hammer | cut -d'/' -f3`)
    echo "[HAMMERMAN] Applying hammer $hammer"
    echo "[HAMMERMAN]   invoking predictor"
    python3 standard_predictor/predict.py -s "$start_" -e "$end_"\
        -ip $(pwd)/$hammer\
        -o $(pwd)/$PRED_DIR/$out
    echo "[HAMMERMAN]   results stored $(pwd)/$PRED_DIR/$out"
done
