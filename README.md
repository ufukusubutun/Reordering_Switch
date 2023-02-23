# Reordering_Switch

## Running Experiment
All experiment files are to be trensfered to the emulator node.
(Including flow size traces that (will be) available at this link):
https://drive.google.com/drive/folders/13lMalGCIaGQ8IE_72NblcA9p2WbxnvYf?usp=sharing

The emulator node acts as the controller of the entire experiment.

The 'set_up.sh' script should be run in order to transfer all scripts and files to all nodes. It takes an option to (or not to) perfom apt-get updates at the nodes

Then the experiment is performed thru the 'automated_exp_v2 script'. (To set parameters, that script should be modified.)
This script will call node_init, flow_gen and server_init at the corresponding nodes and will set queues and bottlenecks thru ssh
I suggest running 'automated_exp_v2' thru 'screen' and with '>> script_log.txt 2>&1' so that all the outputs are recorded and can be viewed real time.

At the end the results are zipped together at /mydrive of emulator


## Post-Processing
After the exp is done, transfer all the files back to a local computer and use the script inside post_precessing for doing the "post processing". 
Results for one example experiment is found below (still uploading). You can use just the pickle to speed things up.
https://drive.google.com/drive/folders/156-LIkzNkzj4xJ4mGw0_7vBk7mW816Ov?usp=sharing

## Trace-Generation
Also use what is inside trace_gen to generate the flows. That requires the package from this repo:
https://github.com/piotrjurkiewicz/flow-models

## Experiment Profile
You can use the following Cloudlab profile to initiate the 24 node topology used for the experiments with a couple of clicks.
https://www.cloudlab.us/show-profile.php?uuid=c672ee4b-4fbf-11ed-994d-e4434b2381fc
