# additional config files #


## virtualbox with nat interface ##

http://www.wanderingcanadian.ca/enabling-internet-access-on-vm-hosted-crowbar
https://gist.github.com/2647677   

copy over the config:

```
scp configs/virtualbox_with_nat_on_third_nic.json  crowbar@192.168.124.10:

# hop on the admin server 

ssh crowbar@192.168.124.10

root@unassigned-hostname:~# mv /home/crowbar/virtualbox_with_nat_on_third_nic.json /opt/dell/barclamps/network/chef/data_bags/crowbar/bc-template-network.json 

```

alter the config of the network in /etc/networking/interfaces from ```192.168.124.10``` to ```192.168.224.10``` and restart networking. Be aware that you must re-login to the server if you used ssh to do this. You might want to use the remote desktop connection which will not be affected by this change.  

