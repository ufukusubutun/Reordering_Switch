#!/bin/bash
# this is the modified new version after topology change decision
# no bottleneck - 2 sinks

update=$1

#uname="uu2001"
uname="uu20010"
keyfile='~/.ssh/ufuk'
chmod 400 ~/.ssh/ufuk

sudo chmod -R a+w /mydata


declare -a sources=("node-0" "node-1" "node-2" "node-3" "node-4" "node-5" "node-6" "node-7" "node-8" "node-9" "node-10" "node-11")
declare -a step1=("agg0" "agg1" "agg2" "agg3" "agg4" "agg5")
declare -a step2=("tor0" "tor1" "tor2")
#declare -a bottleneck=("core0")
#emulator=thisNode
exp_sink="sink"
o_sink="sink2"




int2exp_sink="\$(ip route get 10.14.1.2 | grep -oP \"(?<= dev )[^ ]+\")"
int2o_sink="\$(ip route get 10.14.2.2 | grep -oP \"(?<= dev )[^ ]+\")"
#intFromBtlnck="\$(ip route get 10.13.1.1 | grep -oP \"(?<= dev )[^ ]+\")"

int2node_gen ()
{
    int2node="\$(ip route get 10.10.${1}.1 | grep -oP \"(?<= dev )[^ ]+\")"
}


#mkdir -p ~/iperf_logs
#mkdir -p ~/iperf_logs/workspace


for host in "${sources[@]}"
do
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile ping sink -c 1

	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile echo "connecting to ${host}"
	scp  -i $keyfile data_gen.zip ${uname}@${host}:/users/${uname}
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile unzip -q -o /users/${uname}/data_gen.zip -d ~/data_gen
	scp  -i $keyfile flow_gen.sh ${uname}@${host}:/users/${uname}
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile sudo chmod a+x /users/${uname}/flow_gen.sh
	scp  -i $keyfile node_init.sh ${uname}@${host}:/users/${uname}
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile sudo chmod a+x /users/${uname}/node_init.sh
	echo "sudo tc qdisc del dev $int2exp_sink root"
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile echo "${host} done!"
	if $update
	then
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile -f "sudo apt -y update; sudo apt-get -y update; sudo apt-get -y install iperf3 moreutils jq"
	fi
done

index=0
for host in "${step1[@]}"
do
	echo "sudo tc qdisc del dev $int2exp_sink root"
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
	# handle node facing interfaces
	for n in 1 2
	do
		int2node_gen $( expr $index + $n )
		echo "sudo tc qdisc del dev $int2node root"
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2node root"
	done

	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile echo "${host} done!"

	if $update
	then
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile -f "sudo apt -y update; sudo apt-get -y update; sudo apt-get -y install iperf3 moreutils"
	fi	
	index=$( expr $index + 2 )
done

index=0
for host in "${step2[@]}"
do

	echo "sudo tc qdisc del dev $int2exp_sink root"
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2exp_sink root"
	# handle node facing interfaces
	for n in 1 3
	do
		int2node_gen $( expr $index + $n )
		echo "sudo tc qdisc del dev $int2node root"
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile "sudo tc qdisc del dev $int2node root"
	done
	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile echo "${host} done!"
	if $update
	then
		ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile -f "sudo apt -y update; sudo apt-get -y update; sudo apt-get -y install iperf3 moreutils"
	fi
	index=$( expr $index + 4 )
done

#for host in "${bottleneck[@]}"
#do
#	echo "sudo tc qdisc del dev $int2exp_sink root"
#	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile -f "sudo tc qdisc del dev $int2exp_sink root"
#	ssh -oStrictHostKeyChecking=no ${uname}@${host} -i $keyfile echo "${host} done!"
#done

## TURN SEGMENTATION OFFLOADING OFF
# Get a list of all experiment interfaces, excluding loopback
ifs=$(netstat -i | tail -n+3 | grep -Ev "lo" | cut -d' ' -f1 | tr '\n' ' ')

# Turn off offloading of all kinds, if possible!
for i in $ifs; do 
  sudo ethtool -K $i gro off  
  sudo ethtool -K $i lro off  
  sudo ethtool -K $i gso off  
  sudo ethtool -K $i tso off
  sudo ethtool -K $i ufo off
done

if $update
then
	sudo apt -y update 
	sudo apt-get -y update
	sudo apt-get -y install iperf3 moreutils jq tshark
fi
# handle node facing interfaces
for n in 1 5 9
do
	int2node_gen $n
	echo "sudo tc qdisc del dev $(eval echo $int2node) root"
	sudo tc qdisc del dev $(eval echo $int2node) root
done


IS_EXP_SINK=1
IS_O_SINK=0

# exp sink
scp  -i $keyfile init_server.sh ${uname}@$exp_sink:/users/${uname}
ssh -oStrictHostKeyChecking=no ${uname}@$exp_sink -i $keyfile sudo chmod a+x /users/${uname}/init_server.sh
int2node_gen 1 # any node would work
echo "sudo tc qdisc del dev $int2node root"
ssh -oStrictHostKeyChecking=no ${uname}@${exp_sink} -i $keyfile "sudo tc qdisc del dev $int2node root"
ssh -oStrictHostKeyChecking=no ${uname}@$exp_sink -i $keyfile echo "${exp_sink} done!"
if $update
then
	ssh -oStrictHostKeyChecking=no ${uname}@${exp_sink} -i $keyfile -f "sudo apt -y update; sudo apt-get -y update; sudo apt-get -y install iperf3 moreutils jq"
fi

# other sink
scp  -i $keyfile init_server.sh ${uname}@$o_sink:/users/${uname}
ssh -oStrictHostKeyChecking=no ${uname}@$o_sink -i $keyfile sudo chmod a+x /users/${uname}/init_server.sh
int2node_gen 1 # any node would work
echo "sudo tc qdisc del dev $int2node root"
ssh -oStrictHostKeyChecking=no ${uname}@${o_sink} -i $keyfile "sudo tc qdisc del dev $int2node root"
ssh -oStrictHostKeyChecking=no ${uname}@$o_sink -i $keyfile echo "${o_sink} done!"
if $update
then
	ssh -oStrictHostKeyChecking=no ${uname}@${o_sink} -i $keyfile -f "sudo apt -y update; sudo apt-get -y update; sudo apt-get -y install iperf3 moreutils jq"
fi

