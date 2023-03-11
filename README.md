# Do Switches Still Have to Deliver Packets in Sequence?

WORK IN PROGRESS - will be updated soon for reviewers of IEEE HPSR 2023

Please don't forget to review the study submitted to IEEE HPSR 2023 to better understand this study.

Aim, how, why??

To reproduce the results you can follow the steps below. In general term the procedure is as follows:

* Instantiate the topology at Cloudlab
* Generate/copy TCP trace files
* Move required scripts into the work directory and run scripts to conduct the experiments.
* Capture packets at ingress/egress ports of the switch emulating node.
* Post-process results to obtain measurements and produce plots.


## Experiment Profile

The experiments were realized at the [Cloudlab Testbed](https://www.cloudlab.us/) using a 24 node topology making use of bare metal servers. The topology profile can be found [here](https://www.cloudlab.us/show-profile.php?uuid=999fe067-bf91-11ed-b28b-e4434b2381fc).

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topo.png"  width="40%" >

Detailed information and instructions on initializing the topology on Cloudlab can be found [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/topology.md).


## Trace Generation

TCP flows were generated with random flow sizes sampled from [this](https://arxiv.org/abs/1809.03486) study. Their model, as implemented in [this repo](https://github.com/piotrjurkiewicz/flow-models), was used to generate the traces.

Detailed instructions on trace generation can be found [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/trace_gen.md).


## Running The Experiment

Detailed instructions on running the experiment can be found [here](https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/exp_run.md).


## Post-Processing

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/plot.png"  width="35%" >

Made at [this jupyter notebook](https://colab.research.google.com/drive/1e-DUvf5FcGuIN_EmctMthfrdv4Dsvb41?usp=sharing)

