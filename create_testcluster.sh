#!/bin/bash 
#
# Copyright 2012, Deutsche Telekom Laboratories 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# This script will help you to create a test cluster with 5 nodes that
# use 4 NICs so that you can simulate a more complex real set up.
#
# The MAC addresses follow a simple rule
#  - All addresses start with c0ffee00
#  - the following byte represents the NIC (e.g. eth0: 00, eth1:01)
#  - the last byte represents the node in our system (e.g. admin:00, node1:01)
#  
#  So the second NIC (eth1) on the third node would have c0ffee000103
#
#  eth0 will be set up in vboxnet4
#  eth1 will be set up in vboxnet5
#  eth2 will be set up in vboxnet6 
#  eth3 will be set up in vboxnet7
#

[ -z $CONFIG_SH_SOURCED ] && source config.sh
[ -z $FUNCTIONS_SH_SOURCED ] && source functions.sh

set -e
set -x

#create the hostonly networks, do it at least four times as we start at 4
for i in 1 2 3 4;
do 
  ./reset-network.sh
done

ISO_FILE=${1:-"`pwd`/crowbar.iso"}

NODE_NAME="testcluster-admin"

create_machine $NODE_NAME $ADMIN_MEMORY $NUMBER_ADMIN_NICS 

VBoxManage storageattach $NODE_NAME --storagectl "IDE Controller" --device 0 --port 1 --type dvddrive --medium "$ISO_FILE"
VBoxManage modifyvm $NODE_NAME --boot1 disk

echo "start it with VBoxHeadless -s crowbar_admin"

for I in `seq 1 $NUMBER_OPENSTACK_NODES`
do
  create_machine testcluster-node-${I} $COMPUTE_MEMORY $NUMBER_COMPUTE_NICS $I 
done

for I in `seq $(($NUMBER_OPENSTACK_NODES + 1)) $(($NUMBER_STORAGE_NODES + $NUMBER_OPENSTACK_NODES))`
do
  NODE_NAME="testcluster-node-${I}"
  create_machine $NODE_NAME $STORAGE_MEMORY $NUMBER_STORAGE_NICS $I
  set_disk_path $NODE_NAME
  DISKPATH_2="/"$VMPATH/"/storage.vdi"
  VBoxManage createhd --filename "$DISKPATH_2" --size 5000 --format VDI
  VBoxManage storageattach $NODE_NAME --storagectl 'SATA Controller' --port 1 --device 0 --type hdd --medium "${DISKPATH_2}"
done

echo "current registered crowbar VMs"

VBoxManage list vms|grep testcluster
