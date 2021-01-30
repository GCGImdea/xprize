# creates a file per colection of intervention vectors

for fullfile in ./ips-vectors/*.csv
do
  filename=$(basename -- "$fullfile")
  extension="${filename##*.}"
  filename="${filename%.*}"
  Rscript generate-dance.R "2020-11-01" "2020-12-31" "2021-02-28" dance_iplan.csv $fullfile ips-vectors-full/${filename}-full.csv
done
