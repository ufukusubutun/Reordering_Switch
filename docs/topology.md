Click [here](https://github.com/ufukusubutun/Reordering_Switch#initializing-the-topology-and-setting-up-the-experiment-environment) to go back to the main readme page.

WORK IN PROGRESS

## Initializing the Topology and Setting up the Experiment Environment

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topo.png"  width="25%" >

The experiments were realized at the [Cloudlab Testbed](https://www.cloudlab.us/) using a 24 node topology making use of bare metal servers. Cludlab provides extensive documentation and guides to get started [here](http://docs.cloudlab.us/).


You can use the following Cloudlab profile to instantiate the 24 node topology used for the experiments with a couple of clicks.
https://www.cloudlab.us/show-profile.php?uuid=999fe067-bf91-11ed-b28b-e4434b2381fc

The topology comes built in with a temporary 120 GB storage at the emulator node (that is wiped at the completion of the reservation.) This storage is built under `/mydata`.


### Instantiating:

In order to instantiate the topology, navigate to the [Cloudlab profile](https://www.cloudlab.us/show-profile.php?uuid=999fe067-bf91-11ed-b28b-e4434b2381fc) and click on 'Instantiate'. You will need a Cloudlab account.

This will bring about a page with customazible parameters including what hardware to use for specific node on the topology, link capacities to request and a possibility to attach a permenant Cloudlab Storage space (called 'dataset'). The defeault parameters would provide the environment we used on the paper. However, to be able to effectively work with multiple experiments and store results, you may want to create a dataset through your Cloudlab account, see [Advanved](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topology.md#advanced).

Once you are done with the parameters you can keep clicking next and set the duration you want to run this experiment for. If you are asked to choose a cluster, pick Utah as this is where the nodes we asked for are located.

Once we request the resources, it might be the case that resources are not immediately available. You might need to reserve these resources in advance to be able to use them. If this is the case, you can try asking for less capable nodes of m400 (that are usually not in high demand) at first to set up the experiment environment and get familiar with the setup. To be able to do that, while instantiating the experiment, you can replace the node names of 'xl170' or 'c6525-25g' with 'm400'. In case you get an error matching hardware to the topology, you can use the 'm400' for `all_other_large_hw_type` and `all_other_small_hw_type` while using 'xl170' or 'c6525-25g' for `emulator_hw_type`. This would request 'm400' nodes for all nodes except for the emulator node.

### Logging In and Setting Up

Once the experiment reaches a ready status, ssh into the emulator node following the link provided by Cloudlab on the list view. You will need an ssh key file both to be able to ssh into the **emulator** node from your own system and also to be able to communicate with all the nodes during experiments.

**emulator** node will act as the command control for all the experiments. We will start/end experiments by running scripts at the emulator node and this will also be the place where we will capture packet headers and store results at the mounted drives.

Transfer your ssh key file into `~/.ssh/` of the emulator node. This file will be needed. This can be done by running the following `scp` command **in your local computer** by replacing the <> with the provided items.

	scp -i <location/of/your/keyfile> <location/of/your/keyfile> <your-username>@<your-emulators-hw>.utah.cloudlab.us:/users/<your-username>/.ssh/

### Cloning the Repository

Clone this repository into `~/` of the **emulator** node with the following command and `cd` into it:

	git clone https://github.com/ufukusubutun/Reordering_Switch.git
	cd Reordering_Switch

Once you cloned the repository, we will need to take one more step before we can run the experiments. We will need to have TCP flow size traces to work with. Click [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/trace_gen.md#trace-generation-to-be-used-in-experiments) to display detailed instructions.

### Advanced 

The topology also allows you to attach a permanent storage (termed long term dataset in Cloudlab jargon.) To have access to a long term dataset create your own dataset under Storage > Create Dataset and enter the URN address when instantiating the topolgy using the provided profile. This storage will be built in under `/mypermdata` of the **emulator** node.

You might also want to work with different hardware. See [the Cloudlab documentation on hardware](http://docs.cloudlab.us/hardware.html) to pick different servers.


Click [here](https://github.com/ufukusubutun/Reordering_Switch#initializing-the-topology-and-setting-up-the-experiment-environment) to go back to the main readme page.

