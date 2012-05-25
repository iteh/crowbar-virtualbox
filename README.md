# Virtualbox Environment for Crowbar/Openstack #

## Goal ##


Provide a transportable virtual environment for crowbar/openstack

The solution is inspired by:

http://jedi.be/blog/2011/11/04/vagrant-virtualbox-hostonly-pxe-vlans/ 

Its opinionated in a sense as we need ubuntu-12.04 to work, so fork an help to make it more useable for other distros :-)

## Prerequisites ##

A crowbar iso image. See https://github.com/dellcloudedge/crowbar/wiki/Build-Crowbar.ISO or use https://github.com/iteh/crowbar-iso to build one (ubuntu)

## Usage ##

```
create_base_nodes_and_hostonly_ifs.sh
```

will create the needed networks (default crowbar 122 - 125)

```
create_crowbar.sh /path/to/crowbar.iso
```              

create a crowbar admin server 