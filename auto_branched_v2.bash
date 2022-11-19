#!/bin/bash

# author Ufuk Usubutun - usubutun@nyu.edu
# for reordering experiments with branching

#declare -A pattern_lines

filename="exp_$(date +"%Y_%m_%d_%H_%M").txt"
touch $filename
echo 'alg_ind, RTT, lam, N, cap, trial, avg_meas_rtt, avg_min_rtt, avg_cwnd, socket_snd, avg_reo_wnd, avg_reo_wnd_steps, avg_reo_wnd_persists' >> $filename

exp_time=40 #150 #100 #0
exp_time_safe=45 #160 # 110 #25 # 125 

sudo echo sudooo

int2exp_sink="\$(ip route get 10.14.1.2 | grep -oP \"(?<= dev )[^ ]+\")"
int2o_sink="\$(ip route get 10.14.2.2 | grep -oP \"(?<= dev )[^ ]+\")"

#intFromBtlnck="\$(ip route get 10.13.1.1 | grep -oP \"(?<= dev )[^ ]+\")"
int2node_gen ()
{
    int2node="\$(ip route get 10.10.${1}.1 | grep -oP \"(?<= dev )[^ ]+\")"
}


switch_cap[1]=100 # rate should not be smaller than N - (rate/N) intiger division gives 1
switch_cap[2]=500
switch_cap[3]=1000 #1000
switch_cap[4]=2500
switch_cap[5]=4800
switch_cap[6]=7000
switch_cap[7]=11000


algo[1]='sudo sysctl -w net.ipv4.tcp_recovery=1 net.ipv4.tcp_max_reordering=300 net.ipv4.tcp_sack=1 net.ipv4.tcp_dsack=1' # 1 rack
algo[2]='sudo sysctl -w net.ipv4.tcp_recovery=0 net.ipv4.tcp_max_reordering=300 net.ipv4.tcp_sack=1 net.ipv4.tcp_dsack=1' # 2 dupthresh
algo[3]='sudo sysctl -w net.ipv4.tcp_recovery=0 net.ipv4.tcp_max_reordering=3 net.ipv4.tcp_sack=1 net.ipv4.tcp_dsack=1'   # 3 dupack
algo[4]='sudo sysctl -w net.ipv4.tcp_recovery=0 net.ipv4.tcp_max_reordering=3 net.ipv4.tcp_sack=0 net.ipv4.tcp_dsack=0'   # 4 1980 + cubic


#uname="uu2001"
uname="uu20010"
location="/users/$uname"
keyfile="$location/.ssh/ufuk"

# changing below parameters MAY NOT (and probably will not) change all parameter automatically, (it will change some)
# before doing so please review loops and calculations in the rest of the code
declare -a sources=("node-0" "node-1" "node-2" "node-3" "node-4" "node-5" "node-6" "node-7" "node-8" "node-9" "node-10" "node-11")
# new array with source IPs, in the same order - management IPs 
N_NODES=12
N_FLOWS_P_NODE=200
declare -a step1=("agg0" "agg1" "agg2" "agg3" "agg4" "agg5")
declare -a step2=("tor0" "tor1" "tor2")
#declare -a bottleneck=("core0")
#emulator=thisNode
exp_sink="sink"
o_sink="sink2"


kill_senders ()
{
	echo killing source iperf3s
	for host in "${sources[@]}"
	do
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile -f killall iperf3
	done
}

kill_sinks ()
{
	echo killing sink iperf3s
	ssh -oStrictHostKeyChecking=no ${uname}@${exp_sink} -i $keyfile -f killall iperf3
	ssh -oStrictHostKeyChecking=no ${uname}@${o_sink} -i $keyfile -f killall iperf3
}

cleanup ()
{
	kill_senders
	kill_sinks
	exit 0
}

trap cleanup SIGINT SIGTERM


run_q_capture=0 # set to 1 to capture parallel queue logs as csv at the emulator node # not implemented yet

round_robin=0 # use round robin packet placement if 1, use port number based placement if 0
prob=1 # # use probabilistic if 1 and rr is 0, use port number based placement if 0

for alg_ind in 1 # 2 3 4 #1 2 3 # 1 rack, 2 dupthresh, 3 dupack, 4 1980 + cubic
do
	echo Setting algortihm to = $alg_ind  1 rack, 2 dupthresh, 3 dupack, 4 1980 + cubic

	for host in "${sources[@]}"
	do
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "${algo[$alg_ind]}"
	done

    
    sleep 0.1

    #RTT=10 # Base RTT in milliseconds
    
	for RTT in 10 # 16 #8 # 4 12 #1 5 10 # 15 25 50 # 3 25
	do
		RTT_par_us=$(expr $(expr $RTT \* 1000) / 4 )  # Base RTT to be applied per step in microseconds, will be added at 4 separate places
		RTT_us=$(expr $RTT \* 1000)
		echo RTT $RTT ms, RTT_par_us $RTT_par_us us 
		for lam in 5 #5 #3 # 5 9 #1 5 9
		do
			echo "lam 0.$lam"
			for N in 8 #1 2 4 8 16 #32 # 64 # switch size
			do
				for cap_ind in 5 #6 #5 #5 4 3 2 1  #4 # switch capacity 100 500 1000 4000 10000
				do
					echo '************************'
					echo algortihm = $alg_ind '(1 rack, 2 dupthresh, 3 dupack)'
					echo RTT = $RTT ms
					echo N = $N
					echo "lam 0.$lam"
					echo network_capacity= ${switch_cap[$cap_ind]} 
					echo '************************'
					
		

					# set up switch patterns
					echo ""
					echo "----commands on emulatorg---"
					echo "sudo tc qdisc del dev $(eval echo $int2exp_sink) root"
					sudo tc qdisc del dev $(eval echo $int2exp_sink) root
					echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) root handle 1: htb default $(expr $N + 11)"
					sudo tc qdisc add dev $(eval echo $int2exp_sink) root handle 1: htb default $(expr $N + 11)
					echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1: classid 1:1 htb rate ${switch_cap[$cap_ind]}mbit ceil ${switch_cap[$cap_ind]}mbit"
					sudo tc class add dev $(eval echo $int2exp_sink) parent 1: classid 1:1 htb rate ${switch_cap[$cap_ind]}mbit ceil ${switch_cap[$cap_ind]}mbit
					echo "sudo iptables -t mangle -F"
					sudo iptables -t mangle -F


					que_cap=$(expr ${switch_cap[$cap_ind]} / $N ) 
					echo "que_cap: $que_cap"
					

					if [[ $round_robin -eq 1 ]] # && [[ $alg_ind -eq 6 ]]
					then
						for ind in $(seq 11 1 $(expr $N + 10) )
						do
							echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit"
							sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit
							echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 )" # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive (org value was 250) - CURRENTLY TAILORED TO 2*BDP for N=16 or the equal sum (2*BDP*16/N) for all other cases
							sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 ) # 2*BDP of that link in in bytes # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive
							echo "sudo iptables -A PREROUTING -m statistic --mode nth --every $(expr $N - $(expr $ind - 11)) --packet 0 -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind" # DO NOT FORGET TO CHANGE THE VAL BELOW FOR HASHING
							sudo iptables -A PREROUTING -m statistic --mode nth --every $(expr $N - $(expr $ind - 11)) --packet 0 -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind
							sudo iptables -A PREROUTING -m mark --mark $ind -t mangle -j RETURN
							#sudo iptables -A PREROUTING -m statistic --mode nth --every $(expr $N - $(expr $ind - 11)) --packet 0 -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j RETURN
							
							#echo "sudo iptables -A PREROUTING -m statistic --mode nth --every $N --packet $(expr $ind - 11) -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind" # DO NOT FORGET TO CHANGE THE VAL BELOW FOR HASHING
                                                        #sudo iptables -A PREROUTING -m statistic --mode nth --every $N --packet $(expr $ind - 11) -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind
							#echo "iptables -t mangle -A PREROUTING -m mark --mark $ind -j LOG --log-prefix \"fwmark $ind: \""
							#sudo iptables -t mangle -A PREROUTING -m mark --mark $ind -j LOG --log-prefix "fwmark $ind: "
							echo "sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind"
							sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind
						done
					elif [[ $prob -eq 1 ]] # && [[ $alg_ind -eq 6 ]] # STILL TO DO
					then
						for ind in $(seq 11 1 $(expr $N + 10) )
						do
							echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit"
							sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit
							echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 )" # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive (org value was 250) - CURRENTLY TAILORED TO 2*BDP for N=16 or the equal sum (2*BDP*16/N) for all other cases
							sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 ) # 2*BDP of that link in in bytes # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive
							echo "sudo iptables -A PREROUTING -m statistic --mode random --probability $(bc <<< "scale=6; 1/$(expr $N - $(expr $ind - 11))")  -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind" 
							sudo iptables -A PREROUTING -m statistic --mode random --probability 0$(bc <<< "scale=6; 1/$(expr $N - $(expr $ind - 11))") -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind
							sudo iptables -A PREROUTING -m mark --mark $ind -t mangle -j RETURN
							
							#echo "sudo iptables -A PREROUTING -m statistic --mode nth --every $N --packet $(expr $ind - 11) -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind" # DO NOT FORGET TO CHANGE THE VAL BELOW FOR HASHING
                                                       #sudo iptables -A PREROUTING -m statistic --mode nth --every $N --packet $(expr $ind - 11) -t mangle --destination 10.14.0.0/16 --source 10.10.0.0/16 -j MARK --set-mark $ind
							#echo "iptables -t mangle -A PREROUTING -m mark --mark $ind -j LOG --log-prefix \"fwmark $ind: \""
							#sudo iptables -t mangle -A PREROUTING -m mark --mark $ind -j LOG --log-prefix "fwmark $ind: "
							echo "sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind"
							sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind
						done
							
					else # if quasi-hashed Q placement with no reordering

						#echo $(expr $N_NODES \* $N_FLOWS_P_NODE)
						port_step=$(expr $(expr $(expr $N_NODES \* $N_FLOWS_P_NODE) / $N) / 3)
						echo "port_step=$port_step MAKE SURE THIS VALUE IS NOT 0 because of roudning down"

						for ind in $(seq 11 1 $(expr $N + 10) )
						do
							echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit"
							sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$ind htb rate ${que_cap}mbit ceil ${que_cap}mbit
							echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 )"
							sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$ind handle ${ind}0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 ) # 2*BDP of that link in in bytes

							ranges="$(expr 60000 + $(expr $(expr $ind - 11) \* $port_step) ):$(expr 59999 + $(expr $(expr $ind - 10) \* $port_step) )"
					        ranges="${ranges},$(expr 60800 + $(expr $(expr $ind - 11) \* $port_step) ):$(expr 60799 + $(expr $(expr $ind - 10) \* $port_step) )"
					        ranges="${ranges},$(expr 61600 + $(expr $(expr $ind - 11) \* $port_step) ):$(expr 61599 + $(expr $(expr $ind - 10) \* $port_step) )"

					        echo "sudo iptables -A PREROUTING -p tcp --match multiport --dports $ranges -t mangle --destination 10.14.0.0/16 -j MARK --set-mark $ind"
							sudo iptables -A PREROUTING -p tcp --match multiport --dports $ranges -t mangle --destination 10.14.0.0/16 -j MARK --set-mark $ind  				

							echo "sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind"
							sudo tc filter add dev $(eval echo $int2exp_sink) protocol ip parent 1: prio 0 handle $ind fw classid 1:$ind
						done
				

					fi

					#echo "iptables -t mangle -A PREROUTING  --destination 10.14.0.0/16 -j LOG --log-prefix \"bu ney: \""
                                        #sudo iptables -t mangle -A PREROUTING  --destination 10.14.0.0/16 ! --source 10.10.0.0/16  -j LOG --log-prefix "bu ney: "

					

					echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$(expr $N + 11) htb rate ${que_cap}mbit ceil ${que_cap}mbit"
					sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$(expr $N + 11) htb rate ${que_cap}mbit ceil ${que_cap}mbit

					#echo "sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$(expr $N + 11) htb rate 10mbit ceil 10mbit"
					#sudo tc class add dev $(eval echo $int2exp_sink) parent 1:1 classid 1:$(expr $N + 11) htb rate 10mbit ceil 10mbit
					#echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$(expr $N + 11) handle $(expr $N + 11)0: tbf rate 20mbit buffer 1600 limit 3000"
					#sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$(expr $N + 11) handle $(expr $N + 11)0: tbf rate 10mbit buffer 16000 limit 3000

					echo "sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$(expr $N + 11) handle $(expr $N + 11)0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 )" # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive (org value was 250) - CURRENTLY TAILORED TO 2*BDP for N=16 or the equal sum (2*BDP*16/N) for all other cases
					sudo tc qdisc add dev $(eval echo $int2exp_sink) parent 1:$(expr $N + 11) handle $(expr $N + 11)0: bfifo limit $(expr $(expr $(expr ${que_cap} \* 250 ) \* $RTT_us ) / 1000 ) # 2*BDP of that link in in bytes # PLAYING AROUND WITH THE BUFFER CAPACITIES - currently left at 8 times - not adaptive


					## second sink
					network_capacity=${switch_cap[$cap_ind]}

					echo "sudo tc qdisc del dev $(eval echo $int2o_sink) root"
					sudo tc qdisc del dev $(eval echo $int2o_sink) root

					echo "sudo tc qdisc add dev $(eval echo $int2o_sink) root handle 1: htb default 19"
					sudo tc qdisc add dev $(eval echo $int2o_sink) root handle 1: htb default 19
					echo "sudo tc class add dev $(eval echo $int2o_sink) parent 1: classid 1:1 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit"
					sudo tc class add dev $(eval echo $int2o_sink) parent 1: classid 1:1 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit 
					echo "sudo tc class add dev $(eval echo $int2o_sink) parent 1:1 classid 1:19 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit"
					sudo tc class add dev $(eval echo $int2o_sink) parent 1:1 classid 1:19 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit
					echo "sudo tc qdisc add dev $(eval echo $int2o_sink) parent 1:19 handle 190: bfifo limit $(expr $(expr $(expr ${network_capacity} \* 250 ) \* $RTT_us ) / 1000 )" # 2*BDP of that link in bytes
					sudo tc qdisc add dev $(eval echo $int2o_sink) parent 1:19 handle 190: bfifo limit $(expr $(expr $(expr ${network_capacity} \* 250 ) \* $RTT_us ) / 1000 ) # 2*BDP of that link in in bytes

					echo "Press any key to move to next experiment (1)"
					while [ true ] ; do
						read -t 3 -n 1
						if [ $? = 0 ] ; then
							break ;
						fi
					done

#$(expr ${network_capacity} \* 2 )


					# set up bottleneck
					#network_capacity=$((${switch_cap[$cap_ind]}*$lam/10))
					#btlnck_rate=$(( ${network_capacity} - ${network_capacity}/10 ))
					
					branch_rate=$(expr $(expr $network_capacity \* 5) / 3)

					echo network_capacity = $network_capacity # btlnck_rate = $btlnck_rate\M \n 


					echo ""
					echo "----commands on sources---"
					
					index=0
					for host in "${sources[@]}"
					do
						echo ------ at $host -------
						echo "echo $int2exp_sink"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "echo $int2exp_sink" 
						echo "sudo tc qdisc del dev $int2exp_sink root"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
						sleep 0.1

						echo "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						sleep 0.01
						echo "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${branch_rate}mbit ceil ${branch_rate}mbit"
						ssh ${uname}@${host} -i $keyfile "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${branch_rate}mbit ceil ${branch_rate}mbit" # limit $(expr ${branch_rate} \* 500 )" # in bytes
						sleep 0.01
						echo "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${branch_rate} \* 250 ) \* $RTT_us ) / 1000 )"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${branch_rate} \* 250 ) \* $RTT_us ) / 1000 )" # 2*BDP of that link in in bytes
						sleep 0.01
						# logging
						echo "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_${host}.log"
						sleep 0.01
						echo "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_${host}.log" 
						index=$( expr $index + 2 )
					done
					
					echo ""
					echo "----commands on step1---"
					
					index=0
					for host in "${step1[@]}"
					do
						echo ------ at $host -------
						echo "echo $int2exp_sink"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "echo $int2exp_sink" 
						echo "sudo tc qdisc del dev $int2exp_sink root"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
						sleep 0.1

						echo "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						sleep 0.01
						echo "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${branch_rate}mbit ceil ${branch_rate}mbit"
						ssh ${uname}@${host} -i $keyfile "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${branch_rate}mbit ceil ${branch_rate}mbit" # limit $(expr ${branch_rate} \* 500 )" # in bytes
						sleep 0.01
						echo "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${branch_rate} \* 250 ) \* $RTT_us ) / 1000 )"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${branch_rate} \* 250 ) \* $RTT_us ) / 1000 )" # 2*BDP of that link in in bytes
						sleep 0.01
						# handle node facing interfaces
						for n in 1 2
						do
							int2node_gen $( expr $index + $n )
							echo "sudo tc qdisc del dev $int2node root"
							ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2node root"
							echo "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
							ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
							# logging
							echo "sudo tc -s -d qdisc show dev $int2node >> shaping_log_bottleneck_${host}.log"
							ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2node >> shaping_log_${host}.log"
						done
						# logging
						echo "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_${host}.log"
						sleep 0.01
						echo "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_${host}.log" 
						index=$( expr $index + 2 )
					done
					
					
					index=0
					for host in "${step2[@]}"
					do
						echo ------ at $host -------
						echo "echo $int2exp_sink"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "echo $int2exp_sink"
						echo "sudo tc qdisc del dev $int2exp_sink root"
						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
						sleep 0.1

						echo "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
						sleep 0.01
						echo "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit"
						ssh ${uname}@${host} -i $keyfile "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${network_capacity}mbit ceil ${network_capacity}mbit" # limit $(expr ${network_capacity} \* 500 )" # in bytes
						sleep 0.01
						echo "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${network_capacity} \* 250 ) \* $RTT_us ) / 1000 )"
						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr $(expr $(expr ${network_capacity} \* 250 ) \* $RTT_us ) / 1000 )" # 2*BDP of that link in in bytes
						sleep 0.01
						# handle node facing interfaces
						for n in 1 3
						do
							int2node_gen $( expr $index + $n )
							echo "sudo tc qdisc del dev $int2node root"
							ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2node root"
							echo "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
							ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
							# logging
							echo "sudo tc -s -d qdisc show dev $int2node >> shaping_log_bottleneck_${host}.log"
							ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2node >> shaping_log_${host}.log"
						done
						# logging
						echo "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_${host}.log"
						sleep 0.01
						echo "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_${host}.log" 
						index=$( expr $index + 4 )
					done

					# bottleneck will be the bottleneck - should have the lowest capacity limiting the traffic 
#					for host in "${bottleneck[@]}"
#					do
#						echo ------ at $host -------
#						echo "echo $int2exp_sink"
#						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "echo $int2exp_sink" 
#						echo "sudo tc qdisc del dev $int2exp_sink root"
#						ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
#						sleep 0.01
#
#						echo "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
#						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink root handle 1: htb default 3"
#						sleep 0.01
#						echo "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${btlnck_rate}mbit ceil ${btlnck_rate}mbit"
#						ssh ${uname}@${host} -i $keyfile "sudo tc class add dev $int2exp_sink parent 1: classid 1:3 htb rate ${btlnck_rate}mbit ceil ${btlnck_rate}mbit" # limit $(expr ${btlnck_rate} \* 500 )" # in bytes
#						sleep 0.01
#						echo "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr ${btlnck_rate} \* 500 )"
#						ssh ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2exp_sink parent 1:3 bfifo limit $(expr ${btlnck_rate} \* 500 )" # for cap * 2ms in bytes
#						sleep 0.01
#						# logging
#						echo "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
#						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
#						sleep 0.01
#						echo "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log"
#						ssh ${uname}@${host} -i $keyfile "sudo tc -s -d class show dev $int2exp_sink >> shaping_log_bottleneck_${host}.log" 
#					done


					# handle node facing interfaces on emulator
					echo ------ at emulator -------
					for n in 1 5 9
					do
						int2node_gen $n
						echo "sudo tc qdisc del dev $(eval echo $int2node) root" #$(eval echo $int2o_sink)
						sudo tc qdisc del dev $(eval echo $int2node) root
						#ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2node root"

						echo "sudo tc qdisc add dev $(eval echo $int2node) root netem delay ${RTT_par_us}us"
						sudo tc qdisc add dev $(eval echo $int2node) root netem delay ${RTT_par_us}us
						#ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
						### logging
						#echo "sudo tc -s -d qdisc show dev $(eval echo $int2node) >> shaping_log_bottleneck_${host}.log"
						#sudo tc -s -d qdisc show dev $(eval echo $int2node) >> shaping_log_bottleneck_emulator.log
						#ssh ${uname}@${host} -i $keyfile "sudo tc -s -d qdisc show dev $int2node >> shaping_log_${host}.log"
					done


					# handle node facing interfaces on two servers
					int2node_gen 1 # any node would work
					echo "sudo tc qdisc del dev $int2node root"
					ssh -oStrictHostKeyChecking=no ${uname}@${exp_sink} -i $keyfile "sudo tc qdisc del dev $int2node root"
					echo "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
					ssh -oStrictHostKeyChecking=no ${uname}@${exp_sink} -i $keyfile "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
					int2node_gen 1 # any node would work
					echo "sudo tc qdisc del dev $int2node root"
					ssh -oStrictHostKeyChecking=no ${uname}@${o_sink} -i $keyfile "sudo tc qdisc del dev $int2node root"
					echo "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"
					ssh -oStrictHostKeyChecking=no ${uname}@${o_sink} -i $keyfile "sudo tc qdisc add dev $int2node root netem delay ${RTT_par_us}us"


					echo "Press any key to start the experiment"
                                        while [ true ] ; do
                                                read -t 3 -n 1
                                                if [ $? = 0 ] ; then
                                                        break ;
                                                fi
                                        done
					## FROM THIS POINT ON CALL INDIVIDUAL SCRIPTS LOCATED AT END NODES WITH PROPER ARGUMENTS TO RUN THE EXPERIMENTS

					
					num_serv=$(expr $N_NODES \* $N_FLOWS_P_NODE)

					echo 'setting up sink servers'
					ssh ${uname}@${exp_sink} -i $keyfile bash $location/init_server.sh $num_serv
					####sudo ssh uu2001@server -i $keyfile -f iperf3 -s  -1 --logfile $exp_save_name\-server.log
					echo 'setting up sink2 servers'
					ssh ${uname}@${o_sink} -i $keyfile bash $location/init_server.sh $num_serv
					sleep 1
					####echo 'starting iperf client'
					####sudo iperf3 -c 10.10.3.2 -M 1460 -t $exp_time -C cubic -O 10 --logfile $exp_save_name\-sender.log



					for trial in 1 #2 #3 #4 5
					do
						echo '************'
						echo trial num=$trial
						echo '************'

						###################sudo dmesg -c >/dev/null. ############ BRING BACK FOR RACK DATA COLLECTION

						exp_save_name="exp$trial-alg$alg_ind-RTT$RTT-N$N-swcap${switch_cap[$cap_ind]}-lam$lam"
						sleep 0.1



#						echo "Press any key to start flows"
#						while [ true ] ; do
#							read -t 3 -n 1
#							if [ $? = 0 ] ; then
#								break ;
#							fi
#						done


						echo starting Exps!
						exp_params_rec="$alg_ind, $RTT, $lam, $N, ${switch_cap[$cap_ind]}, $trial,"
						node_id=0 # should be a number from 0 to n
						for host in "${sources[@]}"
						do
							echo "starting up $host flows"
							ssh ${uname}@${host} -i $keyfile -f bash $location/node_init.sh $node_id $N_FLOWS_P_NODE $exp_time $lam ${switch_cap[$cap_ind]} &
							node_id=$(expr $node_id + 1)
						done

						sudo mkdir -p /mydata/tshark_logs
						# tshark stuff						
						if [[ $trial -eq 1 ]] && [[ $alg_ind -eq 8 ]]; # change alg ind to enable
						then
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2exp_sink) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_outcap1.csv & #2> /dev/null &#
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2o_sink) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_outcap2.csv & #2> /dev/null &#
							#(ip.dst==10.14.1.2)&&(ip.proto==6)&&((ip.src==10.10.1.1)||(ip.src==10.10.2.1)||(ip.src==10.10.3.1)||(ip.src==10.10.4.1) )
#							sleep 0.1
							int2node_gen 1 # any node 1 to 4 would work
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap1.csv & #2> /dev/null &#
							int2node_gen 5 # any node 5 to 8 would work
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap2.csv &
							int2node_gen 9 # any node 9 to 12 would work
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap3.csv &

							#"(ip.dst==10.10.1.1)&&(ip.proto==6)" -T fields -e frame.time -e tcp.stream -e tcp.ack -e tcp.options.sack_le -e tcp.options.sack_re -E header=y -E separator=, -E aggregator=\; -E occurrence=a > capture_acks.txt &#2> /dev/null
#
#							sleep 2
#							#sudo ssh uu20010@server -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate-server.pcap
#							#sudo ssh uu20010@emulator -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate--emulator.pcap
#							echo 'starting server capture'
#							ssh uu20010@server -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i enp6s0f0 -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_out.txt"
#							echo 'starting emulator capture'
#							ssh uu20010@emulatorg -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i $int2exp_sink -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_in.txt"
#
						fi

						if [[ $trial -eq 1 ]] && [[ $alg_ind -eq 10 ]]; # change alg ind to enable
						then
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2exp_sink) -s 64 -B 4 -Y "(ip.dst==10.14.1.2)&&(ip.proto==6)&&((ip.src==10.10.1.1)||(ip.src==10.10.2.1)||(ip.src==10.10.3.1)||(ip.src==10.10.4.1) )" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_outcap1.csv & #2> /dev/null &#
							#####sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2o_sink) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_outcap2.csv & #2> /dev/null &#
							#(ip.dst==10.14.1.2)&&(ip.proto==6)&&((ip.src==10.10.1.1)||(ip.src==10.10.2.1)||(ip.src==10.10.3.1)||(ip.src==10.10.4.1) )
#							sleep 0.1 ############################################################################ ALSO CHECK IF PORT NUMBER FILTERS CAN BE USEFUL OR NOT
							int2node_gen 1 # any node 1 to 4 would work
							sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -B 4 -Y "(ip.dst==10.14.1.2)&&(ip.proto==6)&&((ip.src==10.10.1.1)||(ip.src==10.10.2.1)||(ip.src==10.10.3.1)||(ip.src==10.10.4.1) )" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap1.csv & #2> /dev/null &#
							####int2node_gen 5 # any node 5 to 8 would work
							####sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap2.csv &
							####int2node_gen 9 # any node 9 to 12 would work
							####sudo tshark -a duration:$exp_time_safe -q -i $(eval echo $int2node) -s 64 -Y "(ip.proto==6)" -T fields -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.seq -e tcp.seq_raw -e tcp.ack -e tcp.ack_raw -e tcp.len -e tcp.flags -E header=y -E separator=, -E occurrence=a > /mydata/tshark_logs/${exp_save_name}_incap3.csv &

							#"(ip.dst==10.10.1.1)&&(ip.proto==6)" -T fields -e frame.time -e tcp.stream -e tcp.ack -e tcp.options.sack_le -e tcp.options.sack_re -E header=y -E separator=, -E aggregator=\; -E occurrence=a > capture_acks.txt &#2> /dev/null
#
#							sleep 2
#							#sudo ssh uu20010@server -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate-server.pcap
#							#sudo ssh uu20010@emulator -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate--emulator.pcap
#							echo 'starting server capture'
#							ssh uu20010@server -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i enp6s0f0 -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_out.txt"
#							echo 'starting emulator capture'
#							ssh uu20010@emulatorg -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i $int2exp_sink -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_in.txt"
#
						fi




						sleep $exp_time_safe
						kill_senders
						sleep 2

						echo "Press any key to move to start the iperf log transfer"
						while [ true ] ; do
							read -t 3 -n 1
							if [ $? = 0 ] ; then
								break ;
							fi
						done

						mkdir -p $location/iperf_logs
						mkdir -p $location/iperf_logs/workspace

						node_id=0 # should be a number from 0 to n
						for host in "${sources[@]}"
						do
							echo "zipping at $host and transferring"
							#ssh ${uname}@${host} -i $keyfile "cat n${node_id}-f* | jq '[.[] | { from: \"$node_id\", to: .start.connecting_to.host, size_bytes: .start.test_start.bytes , mean_rtt: .end.streams[0].sender.mean_rtt , min_rtt: .end.streams[0].sender.min_rtt , max_rtt: .end.streams[0].sender.max_rtt , rtx: .end.streams[0].sender.retransmits, recv_bytes: .end.streams[0].receiver.bytes , recv_tp_bitsps: .end.streams[0].receiver.bits_per_second , duration: .end.streams[0].receiver.seconds}]' > ${exp_save_name}_$host.json"
							ssh ${uname}@${host} -i $keyfile "rm -f n${node_id}.zip"
							ssh ${uname}@${host} -i $keyfile "zip -jrq $location/n${node_id}.zip $location/n$node_id-f*"
							scp  -i $keyfile ${uname}@${host}:/users/${uname}/n${node_id}.zip $location/iperf_logs/
							ssh ${uname}@${host} -i $keyfile "rm -rf $location/n$node_id-f*"
							node_id=$(expr $node_id + 1)
						done

						# combine all into a single file per experiment
						echo "combining zips"
						for z in $location/iperf_logs/n*;
						do
							sudo mkdir -p /mydata/iperf_logs/workspace/$(echo $z | sed 's/.zip//g')
							sudo unzip -q "$z" -d /mydata/iperf_logs/workspace/$(echo $z | sed 's/.zip//g');
							#mkdir -p $location/iperf_logs/workspace/$(echo $z | sed 's/.zip//g')
							#unzip -q "$z" -d $location/iperf_logs/workspace/$(echo $z | sed 's/.zip//g');
						done
						sudo mkdir -p /mydata/iperf_logs_comb
						sudo zip -jrq /mydata/iperf_logs_comb/comb_${exp_save_name}.zip /mydata/iperf_logs/workspace
						#sudo zip -jrq /mydata/iperf_logs_comb/comb_${exp_save_name}.zip $location/iperf_logs/workspace
						#rm -rf $location/iperf_logs/workspace
						sudo rm -rf /mydata/iperf_logs
						#rm -rf $location/iperf_logs
						echo "experiment done"

						#$(expr $(expr $lam \* $n_flow) / 10) 
						# sudo tshark  -q -i $(ip route get 10.14.2.2 | grep -oP "(?<= dev )[^ ]+") -s 400 -Y "(tcp.dstport > 5000) && (tcp.dstport < 6000)" -T fields -e tcp.srcport -e tcp.dstport -e tcp.seq -E header=y -E separator=, -E occurrence=a | ts '%.s'


 						#jq -s . $location/iperf_logs/exp* > $location/iperf_logs/comb_${exp_save_name}.json
 						#rm $location/iperf_logs/exp*

						echo "Press any key to move to next experiment"
						while [ true ] ; do
							read -t 3 -n 1
							if [ $? = 0 ] ; then
								break ;
							fi
						done


# tshark stuff						
#						if [[ $trial -eq 6 ]] && [[ $alg_ind -eq 4 ]];
#						then
#							tshark -a duration:$exp_time_safe -q -i $(ip route get 10.10.3.2 | grep -oP \"(?<= dev )[^ ]+\") -s 400 -Y "(ip.dst==10.10.3.2)&&(ip.proto==6)" -T fields -e frame.time -e tcp.stream -e tcp.seq -E header=y -E separator=, -E occurrence=a > capture_packets.txt &#2> /dev/null
#							sleep 0.1
#
#							tshark -a duration:$exp_time_safe -q -i $(ip route get 10.10.3.2 | grep -oP \"(?<= dev )[^ ]+\") -s 400 -Y "(ip.dst==10.10.1.1)&&(ip.proto==6)" -T fields -e frame.time -e tcp.stream -e tcp.ack -e tcp.options.sack_le -e tcp.options.sack_re -E header=y -E separator=, -E aggregator=\; -E occurrence=a > capture_acks.txt &#2> /dev/null
#
#							sleep 2
#							#sudo ssh uu20010@server -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate-server.pcap
#							#sudo ssh uu20010@emulator -i ufuk -f sudo timeout $exp_time_safe tcpdump -S -s 100 -i ens2f0 -w exp$trial-rack$mode-mean$reord_mean-reord$reord_rate--emulator.pcap
#							echo 'starting server capture'
#							ssh uu20010@server -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i enp6s0f0 -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_out.txt"
#							echo 'starting emulator capture'
#							ssh uu20010@emulatorg -i $keyfile -f "sudo tshark -a duration:$exp_time_safe -i $int2exp_sink -s 400 -Y \"(ip.dst==10.10.3.2)&&(ip.proto==6)\" -T fields -e frame.time -e tcp.stream -e tcp.seq_raw -E header=y -E separator=, -E occurrence=f > deneme_in.txt"
#
#						fi
					


#---------------TODO---------- ALL THE PARAM CAPTURES 		   				
#						echo 'starting tcp_params capture'
#						sudo screen -d -m timeout $exp_time_safe sudo bash $location/ss-output-filename.sh 10.10.3.2 tcp_params_cap
						###################echo 'starting reo_wnd data capture'############ BRING BACK FOR RACK DATA COLLECTION
						###################sudo screen -d -m sudo sh -c "timeout $exp_time_safe dmesg -l 7 -w > /mydata/reo_wnd_data.log" ############ BRING BACK FOR RACK DATA COLLECTION
#-------------------------
						####sleep 1
						####echo 'starting iperf server'
						####sudo ssh uu20010@server -i $keyfile -f iperf3 -s  -1 --logfile $exp_save_name\-server.log
						####sleep 1
						####echo 'starting iperf client'
						####sudo iperf3 -c 10.10.3.2 -M 1460 -t $exp_time -C cubic -O 10 --logfile $exp_save_name\-sender.log
						
						
#---------------TODO---------- ALL THE PARAM CAPTURES 
#						sleep 1
#						temp=$(cat tcp_params_cap.txt | sed 's/bytes_sent:/bytes_sent: /' |  awk '{for (I=1;I<NF;I++) if ($I=="bytes_sent:") print $(I+1)}' | sort -r | head -n 1)
#						echo temp $temp
#						socket=$(cat tcp_params_cap.txt | grep -m 1 -B1 $temp | sed 's/sk:/sk: /' | awk '{for (I=1;I<NF;I++) if ($I=="sk:") print $(I+1)}')
#						echo socket $socket
#						avg_meas_rtt=$(grep -A1 "sk:$socket" tcp_params_cap.txt | sed 's/rtt:/rtt: /' |  awk '{for (I=1;I<NF;I++) if ($I=="rtt:") print $(I+1)}' | sed 's/\/.*//' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }') #| sed -e 's/.*[:]\(.*\)[/].*/\1/'
#						echo avg_meas_rtt $avg_meas_rtt
#						avg_min_rtt=$(grep -A1 "sk:$socket" tcp_params_cap.txt | sed 's/minrtt:/minrtt: /' |  awk '{for (I=1;I<NF;I++) if ($I=="minrtt:") print $(I+1)}' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }') # | sed -e 's/.*[:]\(.*\)[/].*/\1/'
#						echo avg_min_rtt $avg_min_rtt
#						avg_cwnd=$(grep -A1 "sk:$socket" tcp_params_cap.txt | sed 's/cwnd:/cwnd: /' |  awk '{for (I=1;I<NF;I++) if ($I=="cwnd:") print $(I+1)}' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }') # | sed -e 's/.*[:]\(.*\)[/].*/\1/'
#						echo avg_cwnd $avg_cwnd
#
#
#						socket_snd=0
#						avg_reo_wnd=0
#						avg_reo_wnd_steps=0
#						avg_reo_wnd_persists=0
#
#						if [[ $alg_ind -eq 1 ]]
#						then
#							socket_snd=$(cat tcp_params_cap.txt | grep -m 1 -B1 $temp | sed 's/10.10.1.1:/10.10.1.1: /' | awk '{for (I=1;I<NF;I++) if ($I=="10.10.1.1:") print $(I+1)}')
#							echo socke_snd $socket_snd
#
#							avg_reo_wnd=$(cat /mydata/reo_wnd_data.log | grep $socket_snd | awk '{for (I=1;I<NF;I++) if ($I=="reo_wnd=") print $(I+1)}' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }')
#							echo avg_reo_wnd $avg_reo_wnd
#
#							avg_reo_wnd_steps=$(cat /mydata/reo_wnd_data.log | grep $socket_snd | awk '{for (I=1;I<NF;I++) if ($I=="reo_wnd_steps=") print $(I+1)}' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }')
#							echo avg_reo_wnd_steps $avg_reo_wnd_steps
#
#							avg_reo_wnd_persists=$(cat /mydata/reo_wnd_data.log | grep $socket_snd | awk '{for (I=1;I<NF;I++) if ($I=="reo_wnd_persist") print $(I+1)}' | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }')
#							echo avg_reo_wnd_persists $avg_reo_wnd_persists
#						fi
#
#-----------------------------------					
						echo "$alg_ind, $RTT, $lam, $N, ${switch_cap[$cap_ind]}, $trial, $avg_meas_rtt, $avg_min_rtt, $avg_cwnd, $socket_snd, $avg_reo_wnd, $avg_reo_wnd_steps, $avg_reo_wnd_persists" >> $filename
						

						if [[ $trial -eq 1 ]] && [[ $alg_ind -eq 6 ]]
						then
							ssh uu20010@server -i $keyfile -f "cat deneme_out.txt | sed 's/, */ , /g' | awk '{\$1=\$2=\$3=\$4=\$6=\"\"; print \$0}'  | sed 1d | sed '1s/^/frame.time, tcp.stream, tcp.seq_raw\n/' > $exp_save_name-server_in.csv"
							ssh uu20010@emulatorg -i $keyfile -f "cat deneme_in.txt| sed 's/, */ , /g' | awk '{\$1=\$2=\$3=\$4=\$6=\"\"; print \$0}'  | sed 1d | sed '1s/^/frame.time, tcp.stream, tcp.seq_raw\n/' > $exp_save_name-emulatorg_in.csv"

							cat capture_packets.txt | sed 's/, */ , /g' | awk '{$1=$2=$3=$4=$6=""; print $0}' | sed 1d | sed '1s/^/frame.time, tcp.stream, tcp.seq_raw\n/' > $exp_save_name\_cap_packets.csv
							cat capture_acks.txt | sed 's/, */ , /g' | awk '{$1=$2=$3=$4=$6=""; print $0}'| sed 1d | sed '1s/^/frame.time, tcp.stream, tcp.ack, tcp.options.sack_le, tcp.options.sack_re\n/' > $exp_save_name\_cap_acks.csv;
							#sed -i 1d $exp_save_name\_cap_acks.csv; sed -i '1s/^/frame.time, tcp.stream, tcp.ack, tcp.options.sack_le, tcp.options.sack_re\n/' $exp_save_name\_cap_acks.csv;
							sudo mv tcp_params_cap.txt  $exp_save_name\-tcpparams.txt
							sudo mv tcp_params_cap.csv  $exp_save_name\-tcpparams.csv
						fi
					done # trials loop ends
					kill_sinks # sinks are killed here!!! after the trials loop ends
				done
			done
		done
	done
done





# write a function that kills all server-client pairs yo be called at the end of experiment cycle and upon exit
