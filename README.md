# Virtualbox Environment for Crowbar/Openstack #

## Goal ##


Provide a transportable virtual environment for crowbar/openstack

The solution is inspired by:

[vagrant virtualbox hostonly pxe vlans](http://jedi.be/blog/2011/11/04/vagrant-virtualbox-hostonly-pxe-vlans/) 

Its opinionated in a sense as we need ubuntu-12.04 to work, so fork and help to make it more useable for other distros :-)

## Prerequisites ##

A running and tested [VirtualBox environment](https://www.virtualbox.org/wiki/Downloads) with the VirtualBox Extension Pack installed. Tested on Ubuntu 12.04 LTS with the installation instructions and packages from https://www.virtualbox.org/wiki/Linux_Downloads

A crowbar iso image. See https://github.com/dellcloudedge/crowbar/wiki/Build-Crowbar.ISO or use https://github.com/iteh/crowbar-iso to build one (ubuntu) 

copy the config file to customize it 

```
cp config.sh.example config.sh
```

## Usage ##

```
./create_base_nodes_and_hostonly_ifs.sh   
./reset-network.sh # just to be sure check with ifconfig
```

will create the needed networks (defaults in config.sh) and a base box to clone from

```
./create_crowbar.sh /absolute/path/to/crowbar.iso

```              

./creates a crowbar admin server and deletes it first if it exists. 

### Install crowbar admin ###

"Crowbar Install Guide":https://github.com/dellcloudedge/crowbar/wiki/Install-crowbar

```
# start the crowbar admin vm #
VBoxHeadless -s crowbar_admin&
```
which gives you something like:

```
Oracle VM VirtualBox Headless Interface 4.1.18
(C) 2008-2012 Oracle Corporation
All rights reserved.

VRDE server is listening on port 3389.
```                                   

As you must have the Extensionpack installed you could use a rdp client (there is one from microsoft for osx) to connect to the virtual machine and watch the install process.

```
#connect to it with the default IP  and crowbar:crowbar

ssh crowbar@192.168.124.10

# become root to start the install process #


sudo -i
# change /opt/dell/barclamps/network/chef/data_bags/crowbar/bc-template-network.json if needed 
# e.g. use one of the configs in the configs directory

cd /tftpboot/ubuntu_dvd/extra 
./install admin.cr0wbar.org

# watch the install with #

tail -f /var/log/install.log 
```

after successful installation you can reach the individual vms on the vboxnet hostonly network. 
check ```http://192.168.124.10:3000```   

now its a good time to create a snapshot of the admin server

```
# the --pause is essential if you did not stop the machine
vboxmanage snapshot crowbar_admin take fresh-crowbar-admin-test --pause
```  


### Install additional Nodes ###


```
./create_nova_node.sh crowbar-essex-1
./create_nova_node.sh crowbar-essex-2
./create_nova_node.sh crowbar-essex-3
./create_nova_node.sh crowbar-essex-4
./create_nova_node.sh crowbar-essex-5
VBoxHeadless -s crowbar-essex-1&
VBoxHeadless -s crowbar-essex-2&
VBoxHeadless -s crowbar-essex-3&
VBoxHeadless -s crowbar-essex-4&
VBoxHeadless -s crowbar-essex-5&
```

they should show up in the crowbar admin ui

## Useful Virtualbox Commands ##
``` 
#list running vms:
vboxmanage list runningvms

#list vms:
vboxmanage list vms

#poweroff a vm:
vboxmanage controlvm <vm-name> poweroff

#start a vm in headless mode:
vboxheadless -s <vm-name> poweroff

#unregister and delete a vm:
vboxmanage unregistervm <vm-name> --delete  

# set nic config according to the settings in config.sh#
./reset-network.sh
```