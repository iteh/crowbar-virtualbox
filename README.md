# Deployment of Openstack on a Virtualbox Multi Node Environment#

First get the project files from the [Github repository](https://github.com/iteh/crowbar-virtualbox).

    git clone https://github.com/iteh/crowbar-virtualbox.git
    
## Goal ##

Provide a transportable virtual environment for crowbar/openstack

The solution is inspired by:

[vagrant virtualbox hostonly pxe vlans](http://jedi.be/blog/2011/11/04/vagrant-virtualbox-hostonly-pxe-vlans/) 

Its opinionated in a sense as we need ubuntu-12.04 to work, so fork and help to make it more useable for other distros :-)

## Prerequisites ##

A running and tested [VirtualBox environment](https://www.virtualbox.org/wiki/Downloads) with the VirtualBox Extension Pack installed. Tested on Ubuntu 12.04 LTS with the installation instructions and packages from [https://www.virtualbox.org/wiki/Linux_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)

A crowbar iso image. See https://github.com/dellcloudedge/crowbar/wiki/Build-Crowbar.ISO or use https://github.com/iteh/crowbar-iso to build one (ubuntu) 

copy the config file to customize it 

    cp config.sh.example config.sh

## Install Virtualbox ##

See [VirtualBox environment](https://github.com/iteh/crowbar-virtualbox/blob/master/README-install-virtualbox.md)

## Setup Crowbar Openstack Environment ##

Copy the config file to customize the memory and networking settings. Depending on the hardware you have at hand you should set the admin server at 2GB or higher and the compute nodes at 1GB or higher.

     cp config.sh.example config.sh

 This is the tested config.sh for the crowbar-virtualbox.git project:

     CONFIG_SH_SOURCED=1

     BASE_BOX_NAME="crowbar-base-box" 

     ADMIN_MEMORY=4048
     COMPUTE_MEMORY=2048
     SWIFT_MEMORY=512

     # one of Am79C970A|Am79C973|82540EM|82543GC|82545EM|virtio  
     # according to http://humbledown.org/virtualbox-intel-vlan-tag-stripping.xhtml
     # the Intel Familiy does not work in VLAN setups
     # virtio causes problems (enumartion of device) in ubunut 12.04
     # please verify and update this information ...

     IF_TYPE=Am79C973  
     #IF_TYPE=82540EM  
     #IF_TYPE=virtio

     VBOXNET_4_IP="10.124.0.1" 
     VBOXNET_5_IP="10.125.0.1" 
     VBOXNET_6_IP="10.122.0.1"  
     VBOXNET_7_IP="10.123.0.1" 

     VBOXNET_MASK="255.255.0.0"

 **You can always change this but this is prepared to work for the sample configuration**    

To create a 6 node openstack environment you need to download or build a crowbar iso first. An ISO to start with can be found at [@Zehicle Crowbar Resources](http://crowbar.zehicle.com). 

Next create the crowbar environment with the following commands (tested on Ubuntu 11.10 with Virtualbox 4.1.10r76795):

     ./create_base_nodes_and_hostonly_ifs.sh   
     ./reset-network.sh

     # you MUST use an absolute path to the iso

     ./create_bonding_testcluster.sh /home/crowbar/crowbar.iso 

Now you can start the the admin server. Either use the Virtualbox GUI or run one of the following commands:

On your local environment you can use the GUI:

     VBoxManage startvm crowbar_admin

On a remote environment (e.g. a server with decent RAM and CPU) you should use the headless mode:

     VBoxManage startvm crowbar_admin --type headless
     VBoxManage controlvm crowbar_admin vrde on

Next we have to change the default IP configuration
 
Login to the crowbar server with your favorite remote desktop application (windows rdp client on default port 3389. Do NOT forget to install the Extensionpack) and change the network config in the file `/etc/network/interfaces`. This is for testing that all the networking settings in crowbar are not using hardcoded values. 

     # This file describes the network interfaces available on your system
     # and how to activate them. For more information, see interfaces(5).

     # The loopback network interface
     auto lo
     iface lo inet loopback
     auto eth0
     iface eth0 inet static
         address 10.124.0.10
         netmask 255.255.0.0

and restart the network:

     /etc/init.d/networking restart

Now we can start installing the Crowbar Environment

### Install the Crowbar Admin Server###

The official installation documentation can be found here: [Crowbar Install Guide](https://github.com/dellcloudedge/crowbar/wiki/Install-crowbar)

connect to it with the default IP  and crowbar:crowbar

    ssh crowbar@10.124.0.10

become root to start the install process #

    sudo -i

At this point in time you must choose the network config you want to use. You can find some pre-defined configs in the configs folder. Please read the corresponding README for further instructions! This might change the admin IP address of the test cluster!

    cd /tftpboot/ubuntu_dvd/extra 

As an example we deploy the bonding network config from `configs/bc-template-network-bonding-virtualbox.json`. Edit the file 
 
    vi /opt/dell/barclamps/network/chef/data_bags/crowbar/bc-template-network.json

and install the admin server:

    ./install admin.cr0wbar.org

you can watch the install with

    tail -f /var/log/install* 

it is finished if you see this in the install log file

    root@admin:~# tail -3 /var/log/install.log 
    Deleted role[crowbar-dtest-machine-2_dell_com]

    Script done on Tue Aug 28 10:49:58 2012    

depending on the Virtualbox host this might take some time (>15 min)

After successful installation you can reach the individual vms on the vboxnet hostonly network. Check `http://10.124.0.10:3000` with your browser.  

Now its a good time to create a snapshot of the admin server. The `--pause` is essential if you did not stop the machine

    vboxmanage snapshot crowbar_admin take fresh-crowbar-admin-test --pause

### Install Additional Nodes ###

The next step is to start additional nodes so Crowbar has something. Turn on one or more VMs (it is suggested to use 3 VMs at the moment) that will act as hosts which Crowbar can provision (as described above)

    for I in 1 2 3 
    do
      VBoxManage startvm crowbar-essex-${I} --type headless  
      # starting at 5010  crowbar-essex-${I} -> 5010 - 1 + ${I}
      VBoxManage controlvm crowbar-essex-${I} vrde on  
  
    done

Wait for the VM to show up in the Crowbar Admin web UI with a **blinking yellow** icon indicating Sledgehammer is waiting for instructions (the VM is ready to be allocated)

The VM will display something like the following on the console when it has reached a state ready for allocation (watch it with the Virtualbox GUI or a RDP client):

    BMC_ROUTER=
    BMC_ADDRESS=10.124.0.163
    BMC_NETMASK=255.255.0.0
    HOSTNAME=dc0-ff-ee-00-00-01.crOwbar.org
    NODE_STATE=false 

Now we are ready to allocate the nodes. This will:

* Initial Chef run
* Reboot
* Install of base system via PXE & preseed
* Reboot into newly installed system (login prompt)
    
## Install OpenStack ##

### Install Point and Click ###

See [Crowbar Install Guide](https://github.com/dellcloudedge/crowbar/wiki/Install-crowbar) for the official documentation on howto install Openstack with the Crowbar Webapplication.

### Install Commandline ###

Make sure to re login after crowbar is installed, so that the `CROWBAR_KEY` ENV variable is set. To make sure the IP numbering is consistent and reflects the VM numbering, wait after each allocate until the currently allocating VM is allocated.

On the Crowbar Admin server:

    /opt/dell/bin/crowbar machines allocate dc0-ff-ee-00-00-01.cr0wbar.org
    /opt/dell/bin/crowbar machines allocate dc0-ff-ee-00-00-02.cr0wbar.org
    /opt/dell/bin/crowbar machines allocate dc0-ff-ee-00-00-03.cr0wbar.org

    /opt/dell/bin/crowbar node_state status  --no-ready

Wait until all nodes are ready. Then create the proposals in the following order as they depend on each other. When editing the JSON files, make sure, that the assignment of the nodes is according to your plans. No other options need to be changed.

mysql, keystone, glance, nova_dashboard is known to work on one machine (call it nova-control) 

    /opt/dell/bin/crowbar mysql proposal create proposal 
    /opt/dell/bin/crowbar mysql proposal show proposal > mysql.json 

edit the json file (put the host in the appropriate elements element) e.g.

    ...
    "elements": {
      "mysql-server": [
        "dc0-ff-ee-00-00-01.cr0wbar.org"
      ]
    ...

and save it:

    /opt/dell/bin/crowbar mysql proposal edit proposal  --file mysql.json
    /opt/dell/bin/crowbar mysql proposal commit proposal  
    
you can follow watching the progress with

    tail -f /var/log/syslog             

in another console. Additionally, the webu-ui gives feedback on the current state of the cluster. Open [Crowbar Admin Web UI](http://192.168.224.10:3000/crowbar/openstack/1.0) in your browser. You should see a green dot on the barclamp if it finished successfully.

    /opt/dell/bin/crowbar keystone proposal create proposal
    /opt/dell/bin/crowbar keystone proposal show proposal > keystone.json

edit the json file (put the host in the appropriate elements element)

    /opt/dell/bin/crowbar keystone proposal edit proposal --file keystone.json
    /opt/dell/bin/crowbar keystone proposal commit proposal

    /opt/dell/bin/crowbar glance proposal create proposal  
    /opt/dell/bin/crowbar glance proposal show proposal > glance.json

edit the json file (put the host in the appropriate elements element)

    /opt/dell/bin/crowbar glance proposal edit proposal --file glance.json
    /opt/dell/bin/crowbar glance proposal commit proposal

    /opt/dell/bin/crowbar nova_dashboard proposal create proposal
    /opt/dell/bin/crowbar nova_dashboard proposal show proposal > nova_dashboard.json

edit the json file (put the host in the appropriate elements element)

    /opt/dell/bin/crowbar nova_dashboard proposal edit proposal --file nova_dashboard.json
    /opt/dell/bin/crowbar nova_dashboard proposal commit proposal

    /opt/dell/bin/crowbar nova proposal create proposal
    /opt/dell/bin/crowbar nova proposal show proposal > nova.json
    
edit the json file (put the host in the appropriate elements element)

    "elements": {
      "nova-multi-volume": [
        "dc0-ff-ee-00-00-04.cr0wbar.org",
        "dc0-ff-ee-00-00-05.cr0wbar.org"
      ],
      "nova-multi-controller": [
        "dc0-ff-ee-00-00-01.cr0wbar.org"
      ],
      "nova-multi-compute": [
        "dc0-ff-ee-00-00-02.cr0wbar.org",
        "dc0-ff-ee-00-00-03.cr0wbar.org"
      ]
    },
    
    /opt/dell/bin/crowbar nova proposal edit proposal --file nova.json
    /opt/dell/bin/crowbar nova proposal commit proposal

## Usernames and Passwords ##

Chef is a configuration management database so a lot of the information is IN chef.

e.g. to get the current MySql password issue:


    root@admin:~# knife search node mysql:* -a mysql |grep password
    db_maker_password:       dwrwet9yc3zf
    old_passwords:           0
    server_debian_password:  9eh6sdfsy39a
    server_repl_password:    d5n6xzcvcxvv
    server_root_password:    vptcxvbnnqmv
    old_passwords:   0


Knife search documentation can be found at http://wiki.opscode.com/display/chef/Search    

### Default Passwords: ###

The IP might differ in your environment!

- Crowbar UI on [http://10.124.0.10:3000](http://10.124.0.10:3000) (crowbar/crowbar)
- Chef UI on [http://10.124.0.10:4040](http://10.124.0.10:4040) (admin/password)
- Nagios on [http://10.124.0.10/nagios3](http://10.124.0.10/nagios3) (nagiosadmin/password)
- Ganglia on [http://10.124.0.10/ganglia](http://10.124.0.10/ganglia) (nagiosadmin/password)
- Openstack Dashboard on [http://10.124.3.3/](http://10.124.3.3/) (crowbar/crowbar)
- Openstack Dashboard on [http://10.124.3.3/](http://10.124.3.3/) (admin/crowbar)

### Commandline Access ###

there is a credentials file in the root account of the nova-control node. just source .openrc and things should work.

or export this in your environment and use the nova-control instance IP for 10.124.3.3:


    # NOVA ENV VARIABLES
    export NOVA_USERNAME=crowbar
    export NOVA_PASSWORD=crowbar
    export NOVA_PROJECT_ID=openstack

    # COMMON ENV VARIABLES
    export OS_AUTH_USER=${NOVA_USERNAME}
    export OS_AUTH_KEY=${NOVA_PASSWORD}
    export OS_AUTH_TENANT=${NOVA_PROJECT_ID}
    export OS_AUTH_URL=${NOVA_URL}

## Destroy cluster

To start over use:

    ./destroy_cluster.sh
        
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

list running vms:

    vboxmanage list runningvms

list vms:

    vboxmanage list vms

poweroff a vm:

    vboxmanage controlvm <vm-name> poweroff

start a vm in headless mode:

    vboxheadless -s <vm-name> poweroff

unregister and delete a vm:

    vboxmanage unregistervm <vm-name> --delete  

set nic config according to the settings in config.sh

    ./reset-network.sh
