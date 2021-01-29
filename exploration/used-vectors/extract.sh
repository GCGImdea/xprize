# creates a file per colection of intervention vectors, numbered ips-vector-1 and on
# input is file usage.csv

cp usage.csv kk.$$
COUNTER=1
while [ -s kk.$$ ]
do
  awk -f first-occurence.awk kk.$$ > kkk.$$
  cat hd kkk.$$ > ips-vectors/ips-vector-${COUNTER}.csv
  awk -f remove-first-occurence.awk kk.$$ > kkk.$$
  mv kkk.$$ kk.$$

  Rscript generate-dance.R "2020-11-01" "2020-12-31" "2021-02-28" dance_iplan.csv ips-vectors/ips-vector-${COUNTER}.csv ips-vectors/ips-vector-${COUNTER}-full.csv

  COUNTER=$[$COUNTER +1]
done
rm kk.$$
