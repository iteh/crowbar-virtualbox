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

MASCHINE_NAME="crowbar-base-box"   
IF_TYPE=82540EM #virtio causes problems (enumartion of device in ubunut 12.04

VMPATH="/"$(VBoxManage list systemproperties|grep "^Default"| cut -d '/' -f 2-)"/"$MASCHINE_NAME"/"
DISKPATH="/"$VMPATH/""$MASCHINE_NAME".vdi"

#[ -f "$DISKPATH"  ] && echo "we already have a "$MASCHINE_NAME" instance" && exit

VBoxManage unregistervm "$MASCHINE_NAME" --delete
rm -rf "$VMPATH"
VBoxManage createvm --name "$MASCHINE_NAME" --ostype Ubuntu_64 --register
VBoxManage storagectl "$MASCHINE_NAME" --name 'IDE Controller' --add ide
VBoxManage storagectl "$MASCHINE_NAME" --name 'SATA Controller' --add sata --hostiocache off --sataportcount 1

VBoxManage createhd --filename "$DISKPATH" --size 20000 --format VDI 
VBoxManage storageattach "$MASCHINE_NAME" --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium "$DISKPATH" 

VBoxManage modifyvm "$MASCHINE_NAME" --nic1 hostonly
VBoxManage modifyvm "$MASCHINE_NAME" --nic2 hostonly
VBoxManage modifyvm "$MASCHINE_NAME" --nic3 hostonly
VBoxManage modifyvm "$MASCHINE_NAME" --nic4 none
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress1 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress2 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress3 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress4 auto
VBoxManage modifyvm "$MASCHINE_NAME" --nictype1 $IF_TYPE # virtio failed pxe boot using the intel card
VBoxManage modifyvm "$MASCHINE_NAME" --nictype2 $IF_TYPE
VBoxManage modifyvm "$MASCHINE_NAME" --nictype3 $IF_TYPE
VBoxManage modifyvm "$MASCHINE_NAME" --nictype4 $IF_TYPE 
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected1 on
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate1 on
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected2 on
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate2 on
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected3 on
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate3 on   
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected4 on
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate4 on

VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter1 vboxnet4
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter2 vboxnet5
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter3 vboxnet6
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter4 vboxnet7

