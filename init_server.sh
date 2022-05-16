#!/bin/bash

n_serv=$1;
i_serv=$(expr $n_serv - 1)

#sink_mode=$2

#IS_EXP_SINK=1
#IS_O_SINK=0

echo "===================================";
echo "Setting up $n_serv iperf3 servers."
echo "==================================";

#echo "Bash version ${BASH_VERSION}..."

echo "n_serv: $1";
echo "From port:60000 to $(expr 60000 + $i_serv)";

for i in $(seq 0 1 $i_serv)
do
   port_num=$(expr 60000 + $i)
   #echo "Welcome $port_num times"
   iperf3 -s -p $port_num -D &
done

