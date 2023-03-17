"""The branched topology to study the interraction of TCP with reordering on core network switches.

Instructions:
Please refer to github.com/ufukusubutun/Reordering_Switch for detailed instructions and the publication.
"""	  
#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Describe the parameter(s) this profile script can accept.
portal.context.defineParameter( "emulator_hw", "emulator_hw_type (check cloudlab hardware list)", portal.ParameterType.STRING, "c6525-25g" )
portal.context.defineParameter( "all_other_large_hw", "all_other_large_hw_type (check cloudlab hardware list)", portal.ParameterType.STRING, "c6525-25g" )
portal.context.defineParameter( "all_other_small_hw", "all_other_small_hw_type (check cloudlab hardware list)", portal.ParameterType.STRING, "xl170" )

# Dataset parameter
pc.defineParameter("dataset", "Enter your permanent storage dataset URN here, currently set to a made up Dataset URN, if not changed, a dataset will not be mounted!",
                   portal.ParameterType.STRING,
                   "urn:publicid:IDN+utah.cloudlab.us:THIS-IS-AN-EXAMPLE-LTDATASET-URN+and:will-be-ignored")

pc.defineParameter("big_cap", "Larger capacity 5C/3",
                   portal.ParameterType.INTEGER,
                   8000000)
                   
pc.defineParameter("small_cap", "Smaller capacity C",
                   portal.ParameterType.INTEGER,
                   4800000)


# Retrieve the values the user specifies during instantiation.
params = portal.context.bindParameters()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()


big_cap = params.big_cap 
small_cap = params.small_cap 


# Node node-0
node_0 = request.RawPC('node-0')
node_0.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_0.Site('Site 1')
iface0 = node_0.addInterface('interface-0', pg.IPv4Address('10.10.1.1','255.255.255.0'))

# Node node-1
node_1 = request.RawPC('node-1')
node_1.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_1.Site('Site 1')
iface1 = node_1.addInterface('interface-2', pg.IPv4Address('10.10.2.1','255.255.255.0'))

# Node node-2
node_2 = request.RawPC('node-2')
node_2.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_2.Site('Site 1')
iface2 = node_2.addInterface('interface-4', pg.IPv4Address('10.10.3.1','255.255.255.0'))

# Node node-3
node_3 = request.RawPC('node-3')
node_3.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_3.Site('Site 1')
iface3 = node_3.addInterface('interface-6', pg.IPv4Address('10.10.4.1','255.255.255.0'))

# Node node-4
node_4 = request.RawPC('node-4')
node_4.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_4.Site('Site 1')
iface4 = node_4.addInterface('interface-8', pg.IPv4Address('10.10.5.1','255.255.255.0'))

# Node node-5
node_5 = request.RawPC('node-5')
node_5.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_5.Site('Site 1')
iface5 = node_5.addInterface('interface-10', pg.IPv4Address('10.10.6.1','255.255.255.0'))

# Node node-6
node_6 = request.RawPC('node-6')
node_6.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_6.Site('Site 1')
iface6 = node_6.addInterface('interface-12', pg.IPv4Address('10.10.7.1','255.255.255.0'))

# Node node-7
node_7 = request.RawPC('node-7')
node_7.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_7.Site('Site 1')
iface7 = node_7.addInterface('interface-14', pg.IPv4Address('10.10.8.1','255.255.255.0'))

# Node agg0
node_agg0 = request.RawPC('agg0')
node_agg0.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg0.Site('Site 1')
iface8 = node_agg0.addInterface('interface-1', pg.IPv4Address('10.10.1.2','255.255.255.0'))
iface9 = node_agg0.addInterface('interface-3', pg.IPv4Address('10.10.2.2','255.255.255.0'))
iface10 = node_agg0.addInterface('interface-22', pg.IPv4Address('10.11.1.1','255.255.255.0'))

# Node agg1
node_agg1 = request.RawPC('agg1')
node_agg1.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg1.Site('Site 1')
iface11 = node_agg1.addInterface('interface-5', pg.IPv4Address('10.10.3.2','255.255.255.0'))
iface12 = node_agg1.addInterface('interface-7', pg.IPv4Address('10.10.4.2','255.255.255.0'))
iface13 = node_agg1.addInterface('interface-20', pg.IPv4Address('10.11.2.1','255.255.255.0'))

# Node agg2
node_agg2 = request.RawPC('agg2')
node_agg2.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg2.Site('Site 1')
iface14 = node_agg2.addInterface('interface-9', pg.IPv4Address('10.10.5.2','255.255.255.0'))
iface15 = node_agg2.addInterface('interface-11', pg.IPv4Address('10.10.6.2','255.255.255.0'))
iface16 = node_agg2.addInterface('interface-18', pg.IPv4Address('10.11.3.1','255.255.255.0'))

# Node agg3
node_agg3 = request.RawPC('agg3')
node_agg3.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg3.Site('Site 1')
iface17 = node_agg3.addInterface('interface-13', pg.IPv4Address('10.10.7.2','255.255.255.0'))
iface18 = node_agg3.addInterface('interface-15', pg.IPv4Address('10.10.8.2','255.255.255.0'))
iface19 = node_agg3.addInterface('interface-16', pg.IPv4Address('10.11.4.1','255.255.255.0'))

# Node tor0
node_tor0 = request.RawPC('tor0')
node_tor0.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_tor0.Site('Site 1')
iface20 = node_tor0.addInterface('interface-21', pg.IPv4Address('10.11.2.2','255.255.255.0'))
iface21 = node_tor0.addInterface('interface-23', pg.IPv4Address('10.11.1.2','255.255.255.0'))
iface22 = node_tor0.addInterface('interface-44', pg.IPv4Address('10.12.1.1','255.255.255.0'))

# Node tor1
node_tor1 = request.RawPC('tor1')
node_tor1.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_tor1.Site('Site 1')
iface23 = node_tor1.addInterface('interface-17', pg.IPv4Address('10.11.4.2','255.255.255.0'))
iface24 = node_tor1.addInterface('interface-19', pg.IPv4Address('10.11.3.2','255.255.255.0'))
iface25 = node_tor1.addInterface('interface-42', pg.IPv4Address('10.12.2.1','255.255.255.0'))

# Node emulator
node_emulator = request.RawPC('emulator')
node_emulator.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
node_emulator.Site('Site 1')
# add extra disk space
bs = node_emulator.Blockstore("bs", "/mydata")
bs.size = "120GB" #30GB

if params.dataset!= "urn:publicid:IDN+utah.cloudlab.us:THIS-IS-AN-EXAMPLE-LTDATASET-URN+and:will-be-ignored":
    
    # We need a link to talk to the remote file system, so make an interface.
    ifaceDataset = node_emulator.addInterface()
    
    # The remote file system is represented by special node.
    fsnode = request.RemoteBlockstore("fsnode", "/mypermdata")
    # This URN is displayed in the web interfaace for your dataset.
    fsnode.dataset = params.dataset
    
    # The "rwclone" attribute allows you to map a writable copy of the
    # indicated SAN-based dataset. In this way, multiple nodes can map
    # the same dataset simultaneously. In many situations, this is more
    # useful than a "readonly" mapping. For example, a dataset
    # containing a Linux source tree could be mapped into multiple
    # nodes, each of which could do its own independent,
    # non-conflicting configure and build in their respective copies.
    # Currently, rwclones are "ephemeral" in that any changes made are
    # lost when the experiment mapping the clone is terminated.
    #
    #fsnode.rwclone = True
    
    #
    # The "readonly" attribute, like the rwclone attribute, allows you to
    # map a dataset onto multiple nodes simultaneously. But with readonly,
    # those mappings will only allow read access (duh!) and any filesystem
    # (/mydata in this example) will thus be mounted read-only. Currently,
    # readonly mappings are implemented as clones that are exported
    # allowing just read access, so there are minimal efficiency reasons to
    # use a readonly mapping rather than a clone. The main reason to use a
    # readonly mapping is to avoid a situation in which you forget that
    # changes to a clone dataset are ephemeral, and then lose some
    # important changes when you terminate the experiment.
    #
    #fsnode.readonly = True
    
    # Now we add the link between the node and the special node
    fslink = request.Link("fslink")
    fslink.addInterface(ifaceDataset)
    fslink.addInterface(fsnode.interface)
    
    # Special attributes for this link that we must use.
    fslink.best_effort = True
    fslink.vlan_tagging = True
    
    #
    # If the node type you want to use has only one experiment network interface, and you want
    # to also create a link to other nodes in the experiment, you need to multiplex multiple
    # vlans over the physical link. To do that you need to mark all of your links with this
    # property (and the two properties above).
    #
    #fslink.link_multiplexing = True

iface26 = node_emulator.addInterface('interface-30', pg.IPv4Address('10.14.1.1','255.255.255.0'))
iface27 = node_emulator.addInterface('interface-24', pg.IPv4Address('10.14.2.1','255.255.255.0'))
iface28 = node_emulator.addInterface('interface-41', pg.IPv4Address('10.12.3.2','255.255.255.0'))
iface29 = node_emulator.addInterface('interface-43', pg.IPv4Address('10.12.2.2','255.255.255.0'))
iface30 = node_emulator.addInterface('interface-45', pg.IPv4Address('10.12.1.2','255.255.255.0'))

# Node sink
node_sink = request.RawPC('sink')
node_sink.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_sink.Site('Site 1')
iface31 = node_sink.addInterface('interface-31', pg.IPv4Address('10.14.1.2','255.255.255.0'))

# Node sink2
node_sink2 = request.RawPC('sink2')
node_sink2.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_sink2.Site('Site 1')
iface32 = node_sink2.addInterface('interface-25', pg.IPv4Address('10.14.2.2','255.255.255.0'))

# Node tor2
node_tor2 = request.RawPC('tor2')
node_tor2.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_tor2.Site('Site 1')
iface33 = node_tor2.addInterface('interface-37', pg.IPv4Address('10.11.6.2','255.255.255.0'))
iface34 = node_tor2.addInterface('interface-39', pg.IPv4Address('10.11.5.2','255.255.255.0'))
iface35 = node_tor2.addInterface('interface-40', pg.IPv4Address('10.12.3.1','255.255.255.0'))

# Node agg4
node_agg4 = request.RawPC('agg4')
node_agg4.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg4.Site('Site 1')
iface36 = node_agg4.addInterface('interface-27', pg.IPv4Address('10.10.9.2','255.255.255.0'))
iface37 = node_agg4.addInterface('interface-29', pg.IPv4Address('10.10.10.2','255.255.255.0'))
iface38 = node_agg4.addInterface('interface-38', pg.IPv4Address('10.11.5.1','255.255.255.0'))

# Node agg5
node_agg5 = request.RawPC('agg5')
node_agg5.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_agg5.Site('Site 1')
iface39 = node_agg5.addInterface('nterface-33', pg.IPv4Address('10.10.11.2','255.255.255.0'))
iface40 = node_agg5.addInterface('interface-35', pg.IPv4Address('10.10.12.2','255.255.255.0'))
iface41 = node_agg5.addInterface('interface-36', pg.IPv4Address('10.11.6.1','255.255.255.0'))

# Node node-8
node_8 = request.RawPC('node-8')
node_8.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_8.Site('Site 1')
iface42 = node_8.addInterface('interface-26', pg.IPv4Address('10.10.9.1','255.255.255.0'))

# Node node-9
node_9 = request.RawPC('node-9')
node_9.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_9.Site('Site 1')
iface43 = node_9.addInterface('interface-28', pg.IPv4Address('10.10.10.1','255.255.255.0'))

# Node node-10
node_10 = request.RawPC('node-10')
node_10.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_10.Site('Site 1')
iface44 = node_10.addInterface('interface-32', pg.IPv4Address('10.10.11.1','255.255.255.0'))

# Node node-11
node_11 = request.RawPC('node-11')
node_11.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
node_11.Site('Site 1')
iface45 = node_11.addInterface('interface-34', pg.IPv4Address('10.10.12.1','255.255.255.0'))

# Link link-0
link_0 = request.Link('link-0')
link_0.Site('undefined')
iface0.bandwidth = big_cap
link_0.addInterface(iface0)
iface8.bandwidth = big_cap
link_0.addInterface(iface8)
link_0.link_multiplexing=True
link_0.vlan_tagging = True

# Link link-1
link_1 = request.Link('link-1')
link_1.Site('undefined')
iface1.bandwidth = big_cap
link_1.addInterface(iface1)
iface9.bandwidth = big_cap
link_1.addInterface(iface9)
link_1.link_multiplexing=True
link_1.vlan_tagging = True

# Link link-2
link_2 = request.Link('link-2')
link_2.Site('undefined')
iface2.bandwidth = big_cap
link_2.addInterface(iface2)
iface11.bandwidth = big_cap
link_2.addInterface(iface11)
link_2.link_multiplexing=True
link_2.vlan_tagging = True


# Link link-3
link_3 = request.Link('link-3')
link_3.Site('undefined')
iface3.bandwidth = big_cap
link_3.addInterface(iface3)
iface12.bandwidth = big_cap
link_3.addInterface(iface12)
link_3.link_multiplexing=True
link_3.vlan_tagging = True

# Link link-4
link_4 = request.Link('link-4')
link_4.Site('undefined')
iface4.bandwidth = big_cap
link_4.addInterface(iface4)
iface14.bandwidth = big_cap
link_4.addInterface(iface14)
link_4.link_multiplexing=True
link_4.vlan_tagging = True


# Link link-5
link_5 = request.Link('link-5')
link_5.Site('undefined')
iface5.bandwidth = big_cap
link_5.addInterface(iface5)
iface15.bandwidth = big_cap
link_5.addInterface(iface15)
link_5.link_multiplexing=True
link_5.vlan_tagging = True


# Link link-6
link_6 = request.Link('link-6')
link_6.Site('undefined')
iface6.bandwidth = big_cap
link_6.addInterface(iface6)
iface17.bandwidth = big_cap
link_6.addInterface(iface17)
link_6.link_multiplexing=True
link_6.vlan_tagging = True

# Link link-7
link_7 = request.Link('link-7')
link_7.Site('undefined')
iface7.bandwidth = big_cap
link_7.addInterface(iface7)
iface18.bandwidth = big_cap
link_7.addInterface(iface18)
link_7.link_multiplexing=True
link_7.vlan_tagging = True

# Link link-8
link_8 = request.Link('link-8')
link_8.Site('undefined')
iface19.bandwidth = big_cap
link_8.addInterface(iface19)
iface23.bandwidth = big_cap
link_8.addInterface(iface23)
link_8.link_multiplexing=True
link_8.vlan_tagging = True

# Link link-9
link_9 = request.Link('link-9')
link_9.Site('undefined')
iface16.bandwidth = big_cap
link_9.addInterface(iface16)
iface24.bandwidth = big_cap
link_9.addInterface(iface24)
link_9.link_multiplexing=True
link_9.vlan_tagging = True

# Link link-10
link_10 = request.Link('link-10')
link_10.Site('undefined')
iface13.bandwidth = big_cap
link_10.addInterface(iface13)
iface20.bandwidth = big_cap
link_10.addInterface(iface20)
link_10.link_multiplexing=True
link_10.vlan_tagging = True

# Link link-11
link_11 = request.Link('link-11')
link_11.Site('undefined')
iface10.bandwidth = big_cap
link_11.addInterface(iface10)
iface21.bandwidth = big_cap
link_11.addInterface(iface21)
link_11.link_multiplexing=True
link_11.vlan_tagging = True

# Link link-15
link_15 = request.Link('link-15')
link_15.Site('undefined')
iface26.bandwidth = big_cap
link_15.addInterface(iface26)
iface31.bandwidth = big_cap
link_15.addInterface(iface31)
link_15.link_multiplexing=True
link_15.vlan_tagging = True

# Link link-12
link_12 = request.Link('link-12')
link_12.Site('undefined')
iface27.bandwidth = big_cap
link_12.addInterface(iface27)
iface32.bandwidth = big_cap
link_12.addInterface(iface32)
link_12.link_multiplexing=True
link_12.vlan_tagging = True


# Link link-13
link_13 = request.Link('link-13')
link_13.Site('undefined')
iface42.bandwidth = big_cap
link_13.addInterface(iface42)
iface36.bandwidth = big_cap
link_13.addInterface(iface36)
link_13.link_multiplexing=True
link_13.vlan_tagging = True

# Link link-14
link_14 = request.Link('link-14')
link_14.Site('undefined')
iface43.bandwidth = big_cap
link_14.addInterface(iface43)
iface37.bandwidth = big_cap
link_14.addInterface(iface37)
link_14.link_multiplexing=True
link_14.vlan_tagging = True


# Link link-16
link_16 = request.Link('link-16')
link_16.Site('undefined')
iface44.bandwidth = big_cap
link_16.addInterface(iface44)
iface39.bandwidth = big_cap
link_16.addInterface(iface39)
link_16.link_multiplexing=True
link_16.vlan_tagging = True


# Link link-17
link_17 = request.Link('link-17')
link_17.Site('undefined')
iface45.bandwidth = big_cap
link_17.addInterface(iface45)
iface40.bandwidth = big_cap
link_17.addInterface(iface40)
link_17.link_multiplexing=True
link_17.vlan_tagging = True


# Link link-18
link_18 = request.Link('link-18')
link_18.Site('undefined')
iface41.bandwidth = big_cap
link_18.addInterface(iface41)
iface33.bandwidth = big_cap
link_18.addInterface(iface33)
link_18.link_multiplexing=True
link_18.vlan_tagging = True


# Link link-19
link_19 = request.Link('link-19')
link_19.Site('undefined')
iface38.bandwidth = big_cap
link_19.addInterface(iface38)
iface34.bandwidth = big_cap
link_19.addInterface(iface34)
link_19.link_multiplexing=True
link_19.vlan_tagging = True

# Link link-20
link_20 = request.Link('link-20')
link_20.Site('undefined')
iface35.bandwidth = small_cap
link_20.addInterface(iface35)
iface28.bandwidth = small_cap
link_20.addInterface(iface28)
link_20.link_multiplexing=True
link_20.vlan_tagging = True


# Link link-21
link_21 = request.Link('link-21')
link_21.Site('undefined')
iface25.bandwidth = small_cap
link_21.addInterface(iface25)
iface29.bandwidth = small_cap
link_21.addInterface(iface29)
link_21.link_multiplexing=True
link_21.vlan_tagging = True

# Link link-22
link_22 = request.Link('link-22')
link_22.Site('undefined')
iface22.bandwidth = small_cap
link_22.addInterface(iface22)
iface30.bandwidth = small_cap
link_22.addInterface(iface30)
link_22.link_multiplexing=True
link_22.vlan_tagging = True

#set node types
node_0.hardware_type = params.all_other_small_hw
node_1.hardware_type = params.all_other_small_hw 
node_2.hardware_type = params.all_other_small_hw 
node_3.hardware_type = params.all_other_small_hw 
node_4.hardware_type = params.all_other_small_hw 
node_5.hardware_type = params.all_other_small_hw 
node_6.hardware_type = params.all_other_small_hw 
node_7.hardware_type = params.all_other_small_hw 
node_8.hardware_type = params.all_other_small_hw 
node_9.hardware_type = params.all_other_small_hw 
node_10.hardware_type = params.all_other_small_hw 
node_11.hardware_type = params.all_other_small_hw 

node_agg0.hardware_type = params.all_other_large_hw 
node_agg1.hardware_type = params.all_other_large_hw 
node_agg2.hardware_type = params.all_other_large_hw
node_agg3.hardware_type = params.all_other_large_hw
node_agg4.hardware_type = params.all_other_large_hw 
node_agg5.hardware_type = params.all_other_large_hw

node_tor0.hardware_type = params.all_other_large_hw
node_tor1.hardware_type = params.all_other_large_hw 
node_tor2.hardware_type = params.all_other_large_hw 
node_emulator.hardware_type = params.emulator_hw
node_sink.hardware_type = params.all_other_small_hw 
node_sink2.hardware_type = params.all_other_small_hw 

# Print the generated rspec
pc.printRequestRSpec(request)