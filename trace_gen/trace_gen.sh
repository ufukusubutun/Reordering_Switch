#!/bin/bash

current_loc=$(pwd)
echo current_loc: $current_loc
model_loc="${current_loc}/flow-models/data/agh_2015/mixtures/tcp/size"
echo model_loc $model_loc
# ----------------------------------------------------------- #
# TODO Set the number of data points you would like to generate
num=10000000
# ----------------------------------------------------------- #
flow-models-generate -x size -s $num ${model_loc} > flows_w_bytes_raw.txt
cat flows_w_bytes_raw.txt | awk '{print $20}' | tr -d , > ${current_loc}/flows_w_bytes.txt

N_NODES=12
# ----------------------------------------------------------- #
# TODO Set the number of flow generator logs you want to chop the output into
N_FLOWS_P_NODE=200
# ----------------------------------------------------------- #

num_serv=$(expr $N_NODES \* $N_FLOWS_P_NODE)

INPUT_FILE="flows_w_bytes.txt"  # The input file
N=$(wc -l < $INPUT_FILE)
step=($(expr $N / $num_serv )) # total number of flow gens
last=($(expr $N - $step))

echo $N $step $last

LINE_NUMBERS=( $(seq -f %1.0f $step $step $last) ) # The given line numbers (array)
START=1                 # The offset to calculate lines
IDX=0                   # The index used in the name of generated files: file1, file2 ...

echo $LINE_NUMBERS

for i in "${LINE_NUMBERS[@]}"
do
    # Extract the lines using the head and tail commands
    #echo $i
    tail -n +$START "$INPUT_FILE" | head -n $(( i-START+1 )) > "trace_n$(expr $IDX / $N_FLOWS_P_NODE)-f$(expr $IDX % $N_FLOWS_P_NODE).txt"
    (( IDX++ ))
    START=$(( i+1 ))
done
# Extract the last given line - last line in the file
tail -n +$START "$INPUT_FILE" > "trace_n$(expr $IDX / $N_FLOWS_P_NODE)-f$(expr $IDX % $N_FLOWS_P_NODE).txt"

zip data_gen.zip trace_n*
rm *.txt