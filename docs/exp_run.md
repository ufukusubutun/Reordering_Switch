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

Make sure you get no errors except for `Error: Cannot delete qdisc with handle of zero.` That is fine. If you get errors with respect to ssh key, make sure you have your ssh key placed under `~/.ssh/` and updated the name of the file at the beginning of the set_up.bash properly. If you get an error with scp that involves `data_gen.zip` that means there is a problem with the trace files. They are either not generated or it is not placed in the directory you are working. 

When you are done with the step above. Run the same command with the argument `u`. This will also run `apt-get update` and `apt-get install` commands at each node. The ssh output might be a little messy.

	bash set_up.sh u

### Specifying desired traffic and switch configurations

We will be using a single script named `auto_branched_v2.bash` to:
* Set up the desired switch configuration at the emulator node
* Set up link capacities, buffer sizes, fixed delays at each of the nodes/links
* Set the desired TCP Recovery algorithm at each of the traffic generating nodes
* Simultaneously start and manage flow generators at the traffic generating nodes

This script will achieve those by calling other scripts (namely `node_init.sh`, `flow_gen.sh`, `server_init.sh` etc.) at the corresponding nodes. The set up through the `set_up.sh` must be completed as above for this step to work.

This script will also be the place where we will set a lot of parameters with respect to the experiment we would like to run. Open the script `auto_branched_v2.bash` with your favorite text editor and review all the fields marked with **TODO**. As we did in the `set_up.sh` script, do not forget to also enter your Cloudlab username and ssh key location.

The parameters that are immediately in your control are:
* *Experiment duration* - how long the flow generators will keep on running
* *Number of flow generators* - how many flow generators to set up at each node (value x in the paper.)
* *Buffer size scaling* - how large the buffers at each node should be (2 * BDP of that link or equivalent for LB by default.)
* *Switch configuration* - LB or non-LB config, i.e., w/ or w/o reordering
* *Recovery algorithm to use* - RACK, adapThresh (dupthresh with adaptive threshold) or 3Thresh (dupthresh with fixed threshold of 3)
* *Fixed base delay* - Fixed amount of delay to be applied in the reverse direction. (value T in the paper.)
* *Switch size* - corresponds to value N in the paper
* *Line rate* - corresponds to value C in the paper
* *Portion of flows to be sent to sink1 or sink2* - this is fixed to 50% in the paper

### Starting the flows and setting up the switch configuration

Once the parameters above are set you are now clear to run the script:

	bash auto_branched_v2.bash

This will first, set the recovery algorithm at the traffic generating nodes, display the current set of paramters and set up the switch emulation. Review the output and make sure the parameters are displayed correctly.

Hitting any key to continue, will start setting up link capacities and buffer sizes in each node on the network. The following diagram with node names and link capacities might be helpful in getting a graps of the system.

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/caps-topo.png"  width="45%" >

This might take a while. Make sure there are no ssh related errors, meaning the script cannot communicate with a given server. When this will be done, you will once again be prompted to start the experiment by hitting any key. 

Starting the experiment means, first the `iperf` servers will be set up at the sink nodes and then the flow generators would be started at the traffic generating nodes.

runs for exp time
you will first be notified that flowgens are being set up. and then when all flow generators are running at each node
you will also get a notification when the flow generators that were the first to be started at a given node terminated
transfers and merges flowgen logs

does not capture packets on its own - ideally the capture should be manualy collected during the time in which all flow generators are running
killing the script during the experiment may not be able to terminate flow generator scripts



### Capturing packet headers

Open 5 new terminal windows into the emulator node and change to a directory with large disk space in each. E.g.,

	cd /mydata/

In order to capture packets at all ingress/egress nodes we will need to manually start and stop tcpdump captures. This is to be done when all generators are running. The post processing script will be capable of synchronizing captures and discarding incomplete parts at the start and the end. Run all 5 of these commands at 5 terminal windows at the emulator node when all flow generators are running and stop them with `Ctrl+C` when the first flow generators complete. 

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

### Meaningfully renaming the experiment data

The script called `rename.sh` is prepared to systematically store and save experiment results. **Edit the script before running** following the example formatting provided to reflect the experiment parameters used to generate the capture (e.g., line rate, algorithm, base delay etc.). This script will rename the genericly named experiment result files to a systematic format that we will later use to ease post-processing.

	bash rename.sh

Based on the available disk space and how many other parameters you would like to test, you may want to let the results rest while you are making experiments with different paramaters and renaming the `.pcap` and `.log` files the same way.

### Producing `.csv` files out of the `.pcap` packet captures

The script called `run_v4.sh` is prepared to systematically convert `.pcap` files into `.csv`s that are useful for post-processing. The script contains loops of parameters to consider. Based on the experiments you conducted, **edit the script before running** following the example formatting provided. 

	bash run_v4.sh

This script is expected to run on the order of minutes and will not print anything, so in order to see how many processes are still running you can run the following command at the different terminal window.

	ps aux | grep tshark

Tip: running `run_v4.sh` for too many experiments at the same time might result in excessive RAM usage and might crash some of the processes. Make sure no process is terminated due to RAM shortage. In case that happens, expect to see some errors on the terminal where the script is running.

### Saving and storing experiment data

For the rest of the process, only `.csv` and `.log` files will be necessary. The most efficient way of storing experiment data is to zip those files into an archive. However, `.pcap` files could potentially be useful for dbugging purposes. I would suggest setting up permanent storage (or a dataset) in Cloudlab as decribed in the [topology set up section](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topology.md#advanced) as transfering the rekatively large experiment data and storing them locally is burdensome. As we also handle the post-processing on Cloudlab it is the most convenient to keep everything there.


### Advanced: Suggestions with respect to choice of parameters in `auto_branched_v2.bash`

As the random wait times from the start of one flow to the next at the flow generators is scaled inversely as a function of line rate, I also suggest scaling the experiment durations inversely with respect to the line rate. In that case, the total amount and the trace of files transfered will be very close across experiments conducted at line rates and similar average link utilization values shoudl be achieved.
Increasing the number of flow generators beyond 250-300 might lead to performance issues at the flow generating nodes. Modifying the flow sizes might be an alternative way to further increase the utilization if needed.
In general, every parameter interracts with a high number of moving parts, caution and verification is needed when changing parameters.

### Advanced: Suggestions with respect to tuning of flow generators in `flow_gen.sh`

TODO - explain how to interpret the logs and make sure random wait times are good enough

Click [here](https://github.com/ufukusubutun/Reordering_Switch#running-the-experiment) to go back to the main readme page.
