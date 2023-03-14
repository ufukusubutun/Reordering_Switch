Click [here](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) to go back to the main readme page.

WORK IN PROGRESS

## Trace-Generation

At this stage, it is assumed that, you have a Cloudlab experiment reserved and running, cloned the repository into the work directory. If you haven't done so, please [go back](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) and complete those steps. 

Here you have two options, you can either generate new fresh TCP flow size traces as you desire using the instructions below, or download a trace I prepared and uploaded to Google Drive for your convenience.

### Download Sample Trace
	
Download the sample trace that supports up to x=200 flow generators from Google Drive using the following command:

	wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1NSQV1XJgDNFN38HdLjlIFdYNxwUpIIPD' -O data_gen.zip

If this fails (as Google plays around with things,) you can still download it from [here](https://drive.google.com/file/d/1NSQV1XJgDNFN38HdLjlIFdYNxwUpIIPD/view) to your own computer and then transfer it to the emulator node with scp.

### Generate New Trace

	sudo apt update
	sudo apt install python3-pip
	pip install flow-models
	export PATH=$PATH:$HOME/.local/bin
	python -m pip install numpy pandas scipy


Also use what is inside trace_gen to generate the flows. That requires the package from this repo:
https://github.com/piotrjurkiewicz/flow-models


Click [here](https://github.com/ufukusubutun/Reordering_Switch#trace-generation) to go back to the main readme page.