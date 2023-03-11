Click [here](https://github.com/ufukusubutun/Reordering_Switch#running-the-experiment) to go back to the main readme page.


## Running The Experiment

All experiment files are to be trensfered to the emulator node.
(Including flow size traces that are available at this link):
https://drive.google.com/drive/folders/13lMalGCIaGQ8IE_72NblcA9p2WbxnvYf?usp=sharing

The emulator node acts as the controller of the entire experiment.

### Setting up the workspace

The `set_up.sh` script should be run in order to transfer all scripts and files to all nodes. It takes an option to (or not to) perfom apt-get updates at the nodes

### Generating desired traffic and realizing desired switch configuration

Then the experiment is performed thru the 'automated_exp_v2 script'. (To set parameters, that script should be modified.)
This script will call node_init, flow_gen and server_init at the corresponding nodes and will set queues and bottlenecks thru ssh

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


Click [here](https://github.com/ufukusubutun/Reordering_Switch#running-the-experiment) to go back to the main readme page.
