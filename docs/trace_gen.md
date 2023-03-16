Click [here](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) to go back to the main readme page.

WORK IN PROGRESS

## Trace-Generation

At this stage, it is assumed that, you have a Cloudlab experiment reserved and running and cloned the repository into the work directory. If you haven't done so, please [go back](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) and complete those steps. 

In order to generate realistic TCP traffic representative of a core network, we will take advantage of [a wide area network traffic characterization study by Jurkiewicz et al](https://arxiv.org/abs/1809.03486). We will use their tools and model to generate traces with TCP flow sizes in Bytes. For detailed information about the tools please visit [their repo](https://github.com/piotrjurkiewicz/flow-models).

Here you have two options, you can either generate new fresh TCP flow size traces as you desire using the instructions below, or download a trace I prepared using the same tool/model and uploaded to Google Drive for your convenience.

Make sure you have an ssh connection with the **emulator** node and follow the instructions below at the emulator node.

### a) Download Sample Trace
	
Download the sample trace that supports up to x=200 flow generators from Google Drive using the following command:

	cd ~/Reordering_Switch/
	wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1NSQV1XJgDNFN38HdLjlIFdYNxwUpIIPD' -O data_gen.zip

If this fails (as Google plays around with things,) you can still download it from [here](https://drive.google.com/file/d/1NSQV1XJgDNFN38HdLjlIFdYNxwUpIIPD/view) to your own computer and then transfer it to the emulator node with scp.

### b) Generate New Trace

In order to be able to generate the traces we will use the `flow-models` package and their model `agh_2015`. 

Install some packages including `flow-models`.

	sudo apt update
	sudo apt install python3-pip
	python -m pip install flow-models numpy pandas scipy
	export PATH=$PATH:$HOME/.local/bin

Also clone their repo in order to have access to their model.

	cd ~/Reordering_Switch/trace_gen
	git clone https://github.com/piotrjurkiewicz/flow-models.git

We will now generate traces automatically using a script I prepared. This script, by default, generates 10000000 data points (TCP flow size samples) and chops it into 12 * numgen (200 by default) separate trace files. These are then zipped into a single archive named `data_gen.zip`. If you need a larger number of points or need more flow generators update marked fields on `trace_gen.sh` with your favorite text editor (vim, nano).

	bash trace_gen.sh

We will finally need the traces we generated to be present on our working directory. Move/copy them bakc into `~/Reordering_Switch/` by

	cp data_gen.zip ~/Reordering_Switch/

----------

Once you are done with either method (a) or (b) of generating the traces, we should be ready to start running some flows after setting up our environment.


Click [here](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) to go back to the main readme page.