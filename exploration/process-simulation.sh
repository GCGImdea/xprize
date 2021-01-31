# creates a file per colection of intervention vectors

# The scenarios are in folder ips-vectors-full
# The results of the simulation are in folder predictions-raw
# Folder ips-vectors contains a short intervention vector file, with one line per country

for fullfile in ./ips-vectors-full/*.csv
do
  filename=$(basename -- "$fullfile")

  simfile=./predictions-raw/predicted-${filename}
  if [[ ! -f ${simfile} ]]
  then
    echo "${simfile} does not exist on your filesystem."
    # Here goes the code to run the simulation
  fi

  ipsfile=./ips-vectors/${filename}
  if [[ ! -f ${ipsfile} ]]
  then
    echo "${ipsfile} does not exist on your filesystem. Generating it..."
    head -1 ${fullfile} > kk1.$$
    grep "2021-01-01" ${fullfile} | sed 's/2021/2020/' > kk2.$$
    cat kk1.$$ kk2.$$ > ${ipsfile}
    rm kk1.$$ kk2.$$
  fi
done

# This adds columns for the daily ratio
#
for fullfile in ./predictions-raw/*.csv
do
  filename=$(basename -- "$fullfile")
  simfile=./predictions-with-ratio/${filename}
  if [[ ! -f ${simfile} ]]
  then
    echo "${simfile} does not exist on your filesystem. Running process..."
    Rscript add_daily_ratio.R $fullfile ${simfile}
  fi
done

echo "Generating performance.csv"
cp performance.csv performance.csv.bak
grep -h "2021-0" predictions-with-ratio/* | cut -d "," -f 1,2,7- | sort | uniq > kk.csv
cat hd kk.csv > performance.csv

echo "Generating performance-wo-dance.csv"
cp performance-wo-dance.csv performance-wo-dance.csv.bak
tail +2 performance.csv | cut -d "," -f 1,2,6- | sort | uniq > kk.csv
cat hd-wo-dance kk.csv > performance-wo-dance.csv

# This adds columns for the Rt
# It is not done with the daily ratio because this one takes a lot of time
for fullfile in ./predictions-with-ratio/*.csv
do
  filename=$(basename -- "$fullfile")
  simfile=./predictions-with-Rt/${filename}
  if [[ ! -f ${simfile} ]]
  then
    echo "${simfile} does not exist on your filesystem. Running process..."
    Rscript add_Rt.R $fullfile ${simfile}
  fi
done
