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


# needs some serious cleanup
ISO="/home/crowbardev/crowbar-iso/share/iso/crowbar-v1.2-openstack-1632-g064b54d-dev.iso"

IF_TYPE=82540EM

VBoxManage unregistervm crowbar_admin --delete
VBoxManage clonevm pxe --name crowbar_admin --register

VBoxManage modifyvm crowbar_admin --memory 4096 --ostype Ubuntu_64

VBoxManage modifyvm crowbar_admin --nic1 hostonly
VBoxManage modifyvm crowbar_admin --nic2 hostonly
VBoxManage modifyvm crowbar_admin --nic3 nat
VBoxManage modifyvm crowbar_admin --nic4 none
VBoxManage modifyvm crowbar_admin --macaddress1 080027BA2DAE
VBoxManage modifyvm crowbar_admin --macaddress2 080027BE8E74
VBoxManage modifyvm crowbar_admin --macaddress3 auto
VBoxManage modifyvm crowbar_admin --macaddress4 auto
VBoxManage modifyvm crowbar_admin --nictype1 $IF_TYPE
VBoxManage modifyvm crowbar_admin --nictype2 $IF_TYPE
VBoxManage modifyvm crowbar_admin --nictype3 $IF_TYPE
VBoxManage modifyvm crowbar_admin --nictype4 $IF_TYPE
VBoxManage modifyvm crowbar_admin --cableconnected2 off
VBoxManage controlvm crowbar_admin setlinkstate2 off
VBoxManage modifyvm crowbar_admin --cableconnected3 off
VBoxManage controlvm crowbar_admin setlinkstate3 off
VBoxManage modifyvm crowbar_admin --hostonlyadapter1 vboxnet0
VBoxManage modifyvm crowbar_admin --hostonlyadapter2 vboxnet1
VBoxManage storageattach crowbar_admin --storagectl "IDE Controller" --device 0 --port 1 --type dvddrive --medium "$ISO"
VBoxManage modifyvm crowbar_admin --boot1 disk

echo "start it with VBoxHeadless -s crowbar_admin"
