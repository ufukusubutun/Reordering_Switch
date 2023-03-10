#!/bin/bash

num=10000000


N_NODES=12
N_FLOWS_P_NODE=800 #200

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