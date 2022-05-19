#!/bin/bash

N=$1
savename=$2
filename=q_log_$savename.csv #$3

touch $filename

rm -f $filename



grep_str="bfifo $(echo $(seq 110 10 $(expr $(expr $N \* 10) + 100)) | sed 's/ /|bfifo /g')"    # without ''


for host in "${sources[@]}"
	do
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "${algo[$alg_ind]}"
	done

while [ 1 ]; do 
	echo exp_sink:
	tc -s -d qdisc show dev $(ip route get 10.14.1.2 | grep -oP "(?<= dev )[^ ]+") | grep -A2 -E "$grep_str" | grep backlog | awk -F" " '{print $2}' | sed 's/b//g' | paste -s -d, - | tee -a $filename
	#tc -s -d qdisc show dev $(ip route get 10.14.1.2 | grep -oP "(?<= dev )[^ ]+") | grep backlog | tee -a $filename\.txt 
	#echo o_sink:
	#tc -s -d qdisc show dev $(ip route get 10.14.2.2 | grep -oP "(?<= dev )[^ ]+") | grep backlog | ts '%.s' | tee -a $filename\.txt
done
