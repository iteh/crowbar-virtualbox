# additional config files #


## virtualbox with nat interface ##

http://www.wanderingcanadian.ca/enabling-internet-access-on-vm-hosted-crowbar
https://gist.github.com/2647677   

copy over the config:

```
scp configs/virtualbox_with_nat_on_third_nic.json  crowbar@192.168.224.10:

# hop on the admin server 

ssh crowbar@192.168.224.10

root@unassigned-hostname:~# mv /home/crowbar/virtualbox_with_nat_on_third_nic.json /opt/dell/barclamps/network/chef/data_bags/crowbar/bc-template-network.json 

```
