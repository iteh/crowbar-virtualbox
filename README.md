# Virtualbox Environment for Crowbar/Openstack #

## Goal ##


Provide a transportable virtual environment for crowbar/openstack

The solution is inspired by:

http://jedi.be/blog/2011/11/04/vagrant-virtualbox-hostonly-pxe-vlans/ 

Its opinionated in a sense as we need ubuntu-12.04 to work, so fork and help to make it more useable for other distros :-)

## Prerequisites ##

A crowbar iso image. See https://github.com/dellcloudedge/crowbar/wiki/Build-Crowbar.ISO or use https://github.com/iteh/crowbar-iso to build one (ubuntu)

## Usage ##

```
create_base_nodes_and_hostonly_ifs.sh
```

will create the needed networks (default crowbar 122 - 125) and a base box to clone from

```
create_crowbar.sh /path/to/crowbar.iso
```              

create a crowbar admin server and delete it first if it exists.  

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