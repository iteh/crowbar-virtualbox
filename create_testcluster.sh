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
 
ISO_FILE=${1:-"`pwd`/crowbar.iso"}

./create_crowbar.sh ${ISO_FILE}

VBoxManage modifyvm crowbar_admin --macaddress1 c0ffee000000
VBoxManage modifyvm crowbar_admin --macaddress2 c0ffee000100
VBoxManage modifyvm crowbar_admin --macaddress3 c0ffee000200

for I in 1 2 3 4 5 6
do
  ./create_nova_node.sh crowbar-essex-${I} c0ffee00000${I}
  sleep 2
  VBoxManage modifyvm crowbar-essex-${I} --macaddress2 c0ffee00010${I}
  VBoxManage modifyvm crowbar-essex-${I} --macaddress3 c0ffee00020${I}
  VBoxManage modifyvm crowbar-essex-${I} --macaddress4 c0ffee00030${I}

  VBoxManage modifyvm crowbar-essex-${I}  --nicpromisc1 allow-all 
  VBoxManage modifyvm crowbar-essex-${I}  --nicpromisc2 allow-all 
  VBoxManage modifyvm crowbar-essex-${I}  --nicpromisc3 allow-all 
  VBoxManage modifyvm crowbar-essex-${I}  --nicpromisc4 allow-all 
done

for I in 4 5 6
do
  set_disk_path "crowbar-essex-${I}"
  DISKPATH_2="/"$VMPATH/"/storage.vdi"
  VBoxManage createhd --filename "$DISKPATH_2" --size 5000 --format VDI
  VBoxManage storageattach crowbar-essex-${I} --storagectl 'SATA Controller' --port 1 --device 0 --type hdd --medium "${DISKPATH_2}"
  VBoxManage modifyvm "crowbar-essex-${I}" --memory "${STORAGE_MEMORY}"
done

echo "current registered crowbar VMs"

`VBoxManage list vms|grep crowbar`
