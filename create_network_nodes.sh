#!/bin/bash
#
# Copyright 2014, Edmund Haselwanter 
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

[ -z $CONFIG_SH_SOURCED ] && source config.sh
[ -z $FUNCTIONS_SH_SOURCED ] && source functions.sh

set -x

NODE_NAME="${NODE_PREFIX}Network-Controller"

create_machine $NODE_NAME $NETWORK_CONTROLLER_MEMORY $NUMBER_NETWORK_CONTROLLER_NICS 160 $NETWORK_CONTROLLER_DISKSIZE  

VBoxManage modifyvm $NODE_NAME --cpus 4
VBoxManage modifyvm $NODE_NAME --boot1 disk

#VBoxManage modifyvm $VM1 --nic1 bridged --bridgeadapter1 en3
VBoxManage storageattach $NODE_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $NETWORK_CONTROLLER_ISO  

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"

#------------------------------------------------------------------------------
# NSX-Manager

NODE_NAME="${NODE_PREFIX}Network-Manager"

create_machine $NODE_NAME $NETWORK_MANAGER_MEMORY $NUMBER_NETWORK_MANAGER_NICS 161 $NETWORK_MANAGER_DISKSIZE  

VBoxManage modifyvm $NODE_NAME --boot1 disk
VBoxManage modifyvm $NODE_NAME --cpus 2

#VBoxManage modifyvm $NODE_NAME --nic1 bridged --bridgeadapter1 en3
VBoxManage storageattach $NODE_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $NETWORK_MANAGER_ISO 

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"

#------------------------------------------------------------------------------
# Service Node

NODE_NAME="${NODE_PREFIX}Network-Service-Node"

create_machine $NODE_NAME $NETWORK_SERVICE_NODE_MEMORY $NUMBER_NETWORK_SERVICE_NODE_NICS 161 $NETWORK_SERVICE_NODE_DISKSIZE  

VBoxManage modifyvm $NODE_NAME --boot1 disk
VBoxManage modifyvm $NODE_NAME --cpus 2

#VBoxManage modifyvm $NODE_NAME --nic1 bridged --bridgeadapter1 en3 --nic2 bridged --bridgeadapter1 en5
VBoxManage storageattach $NODE_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $NETWORK_SERVICE_NODE_ISO 

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"

#------------------------------------------------------------------------------
# Gateway Node (L3 Gateway)

NODE_NAME="${NODE_PREFIX}Network-L3Gateway"

create_machine $NODE_NAME $NETWORK_L3GATEWAY_MEMORY $NUMBER_NETWORK_L3GATEWAY_NICS 161 $NETWORK_L3GATEWAY_DISKSIZE  

VBoxManage modifyvm $NODE_NAME --boot1 disk
VBoxManage modifyvm $NODE_NAME --cpus 2

#VBoxManage modifyvm $NODE_NAME --nic1 bridged --bridgeadapter1 en3 --nic2 bridged --bridgeadapter1 en5 --nic3 bridged --bridgeadapter1 en7
VBoxManage storageattach $NODE_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $NETWORK_L3GATEWAY_ISO 

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"

#------------------------------------------------------------------------------


