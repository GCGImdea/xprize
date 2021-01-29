# creates a file per colection of intervention vectors

for fullfile in ./predictor-dfs-with-HX/*.csv
do
  filename=$(basename -- "$fullfile")
  Rscript process_simulation.R $fullfile predictions-with-Rt/${filename}
done
