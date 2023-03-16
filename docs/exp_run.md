Click [here](https://github.com/ufukusubutun/Reordering_Switch#running-the-experiment) to go back to the main readme page.

WORK IN PROGRESS

## Running The Experiment


At this stage, it is assumed that, you have a Cloudlab experiments reserved and running, cloned the repository into the work directory and have the TCP flow size traces (`data_gen.zip`) ready in your work directory of `~/Reordering_Switch`. If you haven't done so, please [go back](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) and complete those steps.


### Setting up the workspace

The emulator node acts as the controller of the entire experiment. Make sure you have an ssh connection with the **emulator** node and follow the instructions below at the emulator node.

	sudo apt-get update
	sudo apt-get -y install tshark

Pick YES (or OK and then YES) if prompted.

Make sure you are in the working directory:

	cd ~/Reordering_Switch

Open `set_up.sh` with your favorite text editor (vim, nano) and complete the two parts maked with `--TODO--`. You will need to enter your Cloudlab username and the path to your ssh key. This is necessary in order to run the experiments from a single central node. The scripts will use `ssh` and `scp` to connect to all nodes, run necessary commands and transfer files/scripts necessary for our experiment to function properly. Once you are done enetering your username and ssh key location run:

	bash set_up.sh

Make sure you get no errors except for `Error: Cannot delete qdisc with handle of zero.` If you get errors with respect to ssh key, make sure you have your ssh key placed under `~/.ssh/` and updated the name of the file at the beginning of the set_up.bash properly. If you get an error with scp that involves `data_gen.zip` that means there is a problem with the trace files. They are either not generated or it is not placed in the directory you are working. 

When you are done with the step above. Run the same command with the argument `u`. This will also run `apt-get update` and `apt-get install` commands at each node. The ssh output might be a little messy.

	bash set_up.sh u

### Specifying desired traffic and switch configurations

We will be using a single script named `auto_branched_v2.bash` to:
* Set up the desired switch configuration at the emulator node
* Set up link capacities, buffer sizes, fixed delays at each of the nodes/links
* Set the desired TCP Recovery algorithm at each of the traffic generating nodes
* Simultaneously start and manage flow generators at the traffic generating nodes

This script will achieve those by calling other scripts (namely `node_init.sh`, `flow_gen.sh`, `server_init.sh` etc.) at the corresponding nodes. The set up through the `set_up.sh` must be completed for this step to work.

This script will also be the place where we will set a lot of parameters with respect to the experiment we would like to run. Open the script `auto_branched_v2.bash` with your favorite text editor and review all the fields marked with **TODO**. As we did in the `set_up.sh` script, do not forget to also enter your Cloudlab username and ssh key location.

The parameters that are immediately in your control are:
* Experiment duration - how long the flow generators will keep on running
* Number of flow generators - how many flow generators to set up at each node (value x in the paper.)
* Buffer size scaling - how large the buffers at each node should be (2 * BDP of that link or equivalent for LB by default.)
* Switch configuration - LB or non-LB config, i.e., w/ or w/o reordering
* Recovery algorithm to use - RACK, adapThresh (dupthresh with adaptive threshold) or 3Thresh (dupthresh with fixed threshold of 3)
* Fixed base delay - Fixed amount of delay to be applied in the reverse direction. (value T in the paper.)
* Switch size - corresponds to value N in the paper
* Line rate - corresponds to value C in the paper
* Portion of flows to be headed to sink1 or sink2 - this is fixed to 50% in the paper

### Starting the flows and setting up the switch configuration

Once the parameters above are set


### Capturing packet headers

Open 5 new terminal windows into the emulator node and change to a directory with large disk space in each. E.g.,

	cd /mydata/
Egress capture for output 1:

	sudo tcpdump -B 4096 -n -i $(ip route get 10.14.1.2 | grep -oP "(?<= dev )[^ ]+") -s 64 -w egress_cap1.pcap tcp dst portrange 50000-59600
Egress capture for output 2:

	sudo tcpdump -B 4096 -n -i $(ip route get 10.14.2.2 | grep -oP "(?<= dev )[^ ]+") -s 64 -w egress_cap2.pcap tcp dst portrange 50000-59600
Ingress capture for input 1:

	sudo tcpdump -B 4096 -n -i $(ip route get 10.10.1.1 | grep -oP "(?<= dev )[^ ]+") -s 64 -w ingress_cap1.pcap tcp dst portrange 50000-59600
Ingress capture for input 2:

	sudo tcpdump -B 4096 -n -i $(ip route get 10.10.5.1 | grep -oP "(?<= dev )[^ ]+") -s 64 -w ingress_cap2.pcap tcp dst portrange 50000-59600
Ingress capture for input 3:

	sudo tcpdump -B 4096 -n -i $(ip route get 10.10.9.1 | grep -oP "(?<= dev )[^ ]+") -s 64 -w ingress_cap3.pcap tcp dst portrange 50000-59600

### Saving and storing experiment data

`rename.sh`

### Advanced: Suggestions with respect to choice of parameters in `auto_branched_v2.bash`

As the random wait times from the start of one flow to the next at the flow generators is scaled inversely as a function of line rate, I also suggest scaling the experiment durations inversely with respect to the line rate. In that case, the total amount and the trace of files transfered will be very close across experiments conducted at line rates and similar average link utilization values shoudl be achieved.
Increasing the number of flow generators beyond 250-300 might lead to performance issues at the flow generating nodes. Modifying the flow sizes might be an alternative way to further increase the utilization if needed.
In general, every parameter interracts with a high number of moving parts, caution and verification is needed when changing parameters.



Click [here](https://github.com/ufukusubutun/Reordering_Switch#running-the-experiment) to go back to the main readme page.
