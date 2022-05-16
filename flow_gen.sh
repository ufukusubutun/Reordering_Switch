#!/bin/bash

node_id=$1; # should be from 0 to 11
flow_gen_id=$2; # should be from 0 to 199
duration=$3
to_other_sink=$4
port_num=$5 #  $(expr 60000 + $(expr $(expr 10 \* $node_id) + $flow_gen_id))
cap=$6

#exp_params_rec=$6 #'alg_ind, RTT, lam, N, cap, trial'


TO_EXP_SINK=0
TO_SINK_2=1


destination='sink'
if [[ "$TO_SINK_2" == "$to_other_sink"  ]]; then
    destination='sink2'    
fi


#echo "=======================================================================================================";
#echo node_id: $node_id flow_id: $flow_gen_id "Setting up flows at port $port_num to iperf3 servers at $destination."
#echo "This will last $duration seconds."
#echo "======================================================================================================";


# make a new directory and save everything there.
# no modifications
mkdir -p ~/n$node_id-f$flow_gen_id
rm -f ~/n$node_id-f$flow_gen_id/*


rand_delay_m=$(expr $(expr 8000 / $cap ) \* 100) # 1 MB/cap(mbps) in ms x 10 (8000/cap) x 100

#echo rand_delay_m= $rand_delay_m

end=$(( SECONDS + $duration))

flow_ind=0
while [ $SECONDS -lt $end ] && read line ; do
    # calculate the random wait and record timestamp
    random_wait=$(shuf -i ${rand_delay_m}-$(expr $rand_delay_m \* 10) -n 1) # random wait in ms
    flw_start_time=$(date +%s%N)

    payload=$line

    if [ $payload -ge 128000 ]
    then
        # save each flow into a separate json file
        len=128000
        num=$(expr $payload / $len)
        #  --cport $port_num
        iperf3 -c $destination -p $port_num -O 10 -J -n $num -l $len > ~/n$node_id-f$flow_gen_id/n$node_id-f$flow_gen_id-i$flow_ind.json
    else
        #  --cport $port_num
        iperf3 -c $destination -p $port_num -O 10 -J --cport $port_num -n 1 -l $payload > ~/n$node_id-f$flow_gen_id/n$node_id-f$flow_gen_id-i$flow_ind.json
    fi
    
    flow_ind=$(expr $flow_ind + 1)

    # wait until random wait has elapsed
    while [ $(expr $(expr $(date +%s%N) - $flw_start_time) / 1000000) -lt $random_wait ]; do
        sleep .0001 # sleep 0.1 ms
    done
    
done < ~/data_gen/trace_n$node_id-f$flow_gen_id.txt


#rm ~/n$node_id-f$flow_gen_id/*

