# creates a file per colection of intervention vectors

for fullfile in ./ips-vectors-full/*.csv
do
  filename=$(basename -- "$fullfile")

  simfile=./predictions-raw/predicted-${filename}
  if [[ ! -f ${simfile} ]]
  then
    echo "${simfile} does not exist on your filesystem."
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
