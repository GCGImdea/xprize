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

HAMMERS_DIR='hammer-dfs'

for hammer in `ls $HAMMERS_DIR/hammer*.csv`; do
    start_=`echo $hammer | grep -o "sn-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`
    end_=`echo $hammer | grep -o "e-[0-9]\+-[0-9]\+-[0-9]\+" |
        grep -o "[0-9][0-9\-]*"`

    out=$(echo predicted-`echo $hammer | cut -d'/' -f2`)
    echo "[HAMMERMAN] Applying hammer $hammer"
    echo "[HAMMERMAN]   invoking predictor"
    python3 standard_predictor/predict.py -s "$start_" -e "$end_"\
        -ip $(pwd)/$hammer\
        -o $(pwd)/hammerman-dfs/$out
    echo "[HAMMERMAN]   results stored @hammerman-dfs/$out"
done
