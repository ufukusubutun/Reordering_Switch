# Do Switches Still Need to Deliver Packets in Sequence?

Ufuk Usubütün, Fraida Fund, Shivendra Panwar
NYU Networks Research Group

WORK IN PROGRESS - being updated for reviewers of IEEE HPSR 2023

This repository contains all the source code and instructions necessary to run experiments and reproduce results from our paper: 'Do Switches Still Have to Deliver Packets in Sequence?' submitted to IEEE HPSR 2023. To better undertand the motivation and takeaways, please don't forget to check our paper.

We aim to evaluate the resilience of contemporary TCP loss detection (formally called 'recovery') algorithms under patterns of reordering that would be caused by a load-balanced switch located at the network core. The internet core typically has high line rates and large number of flows getting mixed. And our evaluation of load-balanced switches is inspired by the [Load-Balanced Birkhoff-von Neumann Switch design of C.S. Chang](https://web.stanford.edu/class/ee384y/Handouts/BVN-Switches-Chang.pdf)

The experiments involve, generating thousands of flows at nodes located at the branches of a tree. This traffic is mixed and sent through an emulator node where we implement the effect of the desired switch architecture on software. And the traffic terminates at sinks. While the traffic crosses the switch, we collect packet header captures at ingress and egress nodes of the 'emulator' node and post-process those to conduct measurements.

To reproduce the results you can follow the steps below. In general terms, the procedure involves doing the following:

* Instantiate the topology at Cloudlab
* Generate (or copy pre-prepared) TCP trace files
* Move required scripts into the work directory on the 'emulator' node and run scripts to conduct the experiments. Capture packets at ingress/egress ports of the switch emulating node.
* Post-process results to obtain measurements and produce plots.


## Initializing the Topology and Setting up the Experiment Environment

We will conduct the experiments at the [Cloudlab Testbed](https://www.cloudlab.us/) using a 24 node topology making use of bare metal servers. The topology profile can be found [here](https://www.cloudlab.us/show-profile.php?uuid=999fe067-bf91-11ed-b28b-e4434b2381fc).

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topo.png"  width="40%" >

Please follow the detailed information and instructions on initializing the topology on Cloudlab and setting up the experiment environment [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topology.md#initializing-the-topology-and-setting-up-the-experiment-environment).


## Trace Generation to be Used in Experiments

TCP flows will be generated with random flow sizes sampled from [this](https://arxiv.org/abs/1809.03486) study. We will use their model, as implemented in [this repo](https://github.com/piotrjurkiewicz/flow-models), to generate the traces.

Please follow the detailed instructions on trace generation [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/trace_gen.md#trace-generation-to-be-used-in-experiments)

## Running The Experiment

The experiments will be conducted and managed centrally from the emulator node using a number of scripts. To set up desired parameters, start the flows and capture packet headers you will need the instructions in this section.

Please follow the detailed instructions on running the experiment [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/exp_run.md#running-the-experiment).


## Post-Processing

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/plot.png"  width="35%" >

Once we collected the raw packet header captures, we will need to post-process these captures to conduct flow and packet level measurements. Detailed instructions on post-processing and generating plots can be found [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/post_p.md#post-processing).

Made at [this jupyter notebook](https://colab.research.google.com/drive/1e-DUvf5FcGuIN_EmctMthfrdv4Dsvb41?usp=sharing)

## General description of all scripts in this repo

`auto_branched_v2.bash` - The main experiment script that sets up the desired switch configuration at the emulator node, that sets up link capacities, buffer sizes, fixed delays at each of the nodes/links, that sets the desired TCP Recovery algorithm at each of the traffic generating nodes and that simultaneously starts and manages flow generators at the traffic generating nodes

`flow_gen.sh` - An instance of a flow generator to be run in bulk at each traffic generator nodes in parallel. Picks TCP flow sizes from the trace and runs those flows. There is a random wait time between the start of one flow to the start of the oher.

`init_server.sh` - Run locally at the sinks by the auto_branched_v2.bash script, initiallizes and controls iperf3 servers (sinks).

`node_init.sh` - Run locally at each node by the auto_branched_v2.bash script, initiallizes and controls flow_gens at each traffic generating node

`rename.sh` - Renames .pcap packet captures with respect to experiment parameters

`run_v4.sh` - Produces .csv files out of .pcap packet captures

`set_up.sh` - Connects to all physical servers, tranfers necessary files and sets up the experiment environment

