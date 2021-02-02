#!/bin/bash - 

echo "usage: $0 start_date end_date ips_file output_file"

    python3 standard_predictor/predict.py -s "$1" -e "$2"\
        -ip $3\
        -o $4
