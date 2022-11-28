#!/bin/bash

node_id=$1

n_flow=$2;
i_flow=$(expr $n_flow - 1)

exp_duration=$3
lam=$4 # between (0,10)
cap=$5

TO_EXP_SINK=0
TO_SINK_2=1


base_port=$(expr 60000 + $(expr $n_flow \* $node_id))

#echo "node_id: $node_id";
#echo "From port:$base_port to $(expr $base_port + $i_flow)";


#echo "===================================";
echo "Setting up $n_flow iperf3 flow generators at node $node_id. From port:$base_port to $(expr $base_port + $i_flow)"
#echo "==================================";



for i in $(seq 0 1 $i_flow)
do
   destination=$TO_EXP_SINK
   #if [[ $i -ge $(expr $(expr $lam \* $n_flow) / 10) ]]; then
   if [[ $(expr $i % 10) -ge $lam ]]; then
       destination=$TO_SINK_2
   fi

   port_num=$(expr $base_port + $i)
   #echo "Welcome $port_num times"
   ./flow_gen.sh $node_id $i $exp_duration $destination $port_num $cap &
   #sudo iperf3 -s -1 -p $port_num -D
done
