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

### Install Virtualbox on a remote Ubuntu machine ###

You need to have root access to the machine you want to install Virtualbox. There are several steps needed to install Virtualbox. You can get more information about the installation at the following location:

* [http://wiki.ubuntuusers.de/virtualbox/Installation](http://wiki.ubuntuusers.de/virtualbox/Installation)

Virtualbox can be downloaded from: [https://www.virtualbox.org/wiki/Linux_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)

First we must add the repository key and the apt repository itself to the apt environment:  

Add one of the following lines according to your distribution to your /etc/apt/sources.list:

````
deb http://download.virtualbox.org/virtualbox/debian precise contrib
deb http://download.virtualbox.org/virtualbox/debian oneiric contrib
deb http://download.virtualbox.org/virtualbox/debian natty contrib
deb http://download.virtualbox.org/virtualbox/debian maverick contrib non-free
deb http://download.virtualbox.org/virtualbox/debian lucid contrib non-free
deb http://download.virtualbox.org/virtualbox/debian karmic contrib non-free
deb http://download.virtualbox.org/virtualbox/debian hardy contrib non-free
deb http://download.virtualbox.org/virtualbox/debian squeeze contrib non-free
deb http://download.virtualbox.org/virtualbox/debian lenny contrib non-free
````

Add the Oracle public key for apt-secure  

```
sudo wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add - 
```

The next step ist to update the apt cache and install Virtualbox:

```
sudo apt-get update 
sudo apt-get install virtualbox-4.1       
```
    
For remote access to the console and PXE booting we need the Virtualbox extension pack. 

```
wget http://download.virtualbox.org/virtualbox/4.1.18/Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.1.4-74291.vbox-extpack    
```
    
Now we are able to move on and configure the Virtualbox environment  

## Usage ##

```
./create_base_nodes_and_hostonly_ifs.sh   
./reset-network.sh # just to be sure check with ifconfig
```

will create the needed networks (defaults in config.sh) and a base box to clone from

```
./create_crowbar.sh /absolute/path/to/crowbar.iso
```

creates a crowbar admin server and deletes it first if it exists. 

### Install crowbar admin ###

[Crowbar Install Guide](https://github.com/dellcloudedge/crowbar/wiki/Install-crowbar)

```
# start the crowbar admin vm
VBoxHeadless -s crowbar_admin&  
```
or use 

```
VBoxManage startvm crowbar_admin --type headless
VBoxManage controlvm crowbar_admin vrde on
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
```

At this point in time you must choose the network config you want to use. You can find some pre-defined configs in the configs folder. Please read the corresponding README for further instructions! This might change the admin IP address of the test cluster!

```
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


```bash
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

## Snapshots ##

The scripting is not generic but uses the names chosen above
### create a snapshot:

./snapshot_cluster.sh "snapshot_name"     

save the snapshot name somewere

### restore a snapshot:

./stop_cluster.sh
./restore_from_snapshot.sh "snapshot_name" 
./start_cluster.sh 

and give it some time, you are starting 6 vms at once!

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
