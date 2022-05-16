# Reordering_Switch
all experiment files are to be trensfered to the emulator node.
(Including flow size traces that (will be) available at this link):
https://drive.google.com/drive/folders/1PlF5LqZj0Nxc_oOZ_jk_e4iga3oVrxKr?usp=sharing

The emulator node acts as the controller of the entire experiment.

The set_up.sh script should be run in order to transfer all scripts and files to all nodes. It takes an option to (or not to) perfom apt-get updates at the nodes

Then the experiment is performed thru the automated_exp_v2 script. (To set parameters, that script should be modified.)
This script will call node_init, flow_gen and server_init at the corresponding nodes and will set queues and bottlenecks thru ssh
I suggest running automated_exp_v2 thru screen and with (>> script_log.txt 2>&1) so that all the outputs are recorded and can be viewed real time.

At the end the results are zipped together at /mydrive of emulator

After the exp is done, transfer all the files back to a local computer and use the script inside post_precessing for doing the "post processing".

Also use what is inside trace_gen to generate the flows. That requires the package from this repo:
https://github.com/piotrjurkiewicz/flow-models



Latest versions of rspecs are porivded both for geni and Cloudlab
(though the cloudlab version is out of date as the other cloudlab format is currently being used at the profile. The profile is available below:)
https://www.cloudlab.us/show-profile.php?uuid=a96d8311-cd81-11ec-ba12-e4434b2381fc
