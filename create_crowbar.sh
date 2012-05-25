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

[ -z $CONFIG_SH_SOURCED ] && source config.sh
[ -z $FUNCTIONS_SH_SOURCED ] && source functions.sh

[ -z $1 ] && echo "you must provide absolute path to the iso image" && exit

ISO=$1   
IF_TYPE=82540EM
ADMIN_MEMORY=2048 

VBoxManage unregistervm crowbar_admin --delete  

VBoxManage clonevm "$BASE_BOX_NAME" --name crowbar_admin --register

VBoxManage modifyvm crowbar_admin --memory $ADMIN_MEMORY --ostype Ubuntu_64

VBoxManage modifyvm crowbar_admin --nic3 nat
VBoxManage modifyvm crowbar_admin --macaddress3 auto
VBoxManage modifyvm crowbar_admin --nictype3 $IF_TYPE
VBoxManage modifyvm crowbar_admin --cableconnected3 on
VBoxManage controlvm crowbar_admin setlinkstate3 on
VBoxManage storageattach crowbar_admin --storagectl "IDE Controller" --device 0 --port 1 --type dvddrive --medium "$ISO"
VBoxManage modifyvm crowbar_admin --boot1 disk

echo "start it with VBoxHeadless -s crowbar_admin"
