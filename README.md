# Reordering_Switch

WORK IN PROGRESS - will be updated soon for reviewers of IEEE HPSR 2023




## Running Experiment
All experiment files are to be trensfered to the emulator node.
(Including flow size traces that are available at this link):
https://drive.google.com/drive/folders/13lMalGCIaGQ8IE_72NblcA9p2WbxnvYf?usp=sharing

The emulator node acts as the controller of the entire experiment.

The 'set_up.sh' script should be run in order to transfer all scripts and files to all nodes. It takes an option to (or not to) perfom apt-get updates at the nodes

Then the experiment is performed thru the 'automated_exp_v2 script'. (To set parameters, that script should be modified.)
This script will call node_init, flow_gen and server_init at the corresponding nodes and will set queues and bottlenecks thru ssh


## Trace-Generation
Also use what is inside trace_gen to generate the flows. That requires the package from this repo:
https://github.com/piotrjurkiewicz/flow-models

## Experiment Profile
You can use the following Cloudlab profile to initiate the 24 node topology used for the experiments with a couple of clicks.
https://www.cloudlab.us/show-profile.php?uuid=999fe067-bf91-11ed-b28b-e4434b2381fc