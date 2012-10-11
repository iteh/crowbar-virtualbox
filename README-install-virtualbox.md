# Install Virtualbox on a remote Ubuntu machine #

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