# Virtualbox Environment for Crowbar/Openstack #

## Goal ##


Provide a transportable virtual environment for crowbar/openstack

The solution is inspired by:

http://jedi.be/blog/2011/11/04/vagrant-virtualbox-hostonly-pxe-vlans/ 

Its opinionated in a sense as we need ubuntu-12.04 to work, so fork and help to make it more useable for other distros :-)

## Prerequisites ##

A crowbar iso image. See https://github.com/dellcloudedge/crowbar/wiki/Build-Crowbar.ISO or use https://github.com/iteh/crowbar-iso to build one (ubuntu) 

copy the config file to customize it 

```
cp config.sh.example config.sh
```

## Usage ##

```
create_base_nodes_and_hostonly_ifs.sh
```

will create the needed networks (defaults in config.sh) and a base box to clone from

```
create_crowbar.sh /path/to/crowbar.iso

```              

creates a crowbar admin server and deletes it first if it exists. 

### Install crowbar admin ###

"Crowbar Install Guide":https://github.com/dellcloudedge/crowbar/wiki/Install-crowbar

```
# start the crowbar admin vm #
VBoxHeadless -s crowbar_admin&

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

# set nic config (this is maybe the wrong way as it forgets about this settings on a vm start)#
/usr/lib/virtualbox/VBoxNetAdpCtl vboxnet0 192.168.124.1 netmask 255.255.255.0

```