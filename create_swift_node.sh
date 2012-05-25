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

[ -z $1 ] && echo "you must provide a swift maschine name" && exit

MASCHINE_NAME=$1

echo "creating $MASCHINE_NAME"

IF_TYPE=82540EM #virtio causes problems (enumartion of device in ubunut 12.04

VBoxManage unregistervm "$MASCHINE_NAME" --delete
VBoxManage clonevm swift --name "$MASCHINE_NAME" --register

VBoxManage modifyvm "$MASCHINE_NAME" --memory 512 --ostype Debian_64

VBoxManage modifyvm "$MASCHINE_NAME" --nic1 hostonly
VBoxManage modifyvm "$MASCHINE_NAME" --nic2 hostonly
VBoxManage modifyvm "$MASCHINE_NAME" --nic3 nat
VBoxManage modifyvm "$MASCHINE_NAME" --nic4 none
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress1 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress2 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress3 auto
VBoxManage modifyvm "$MASCHINE_NAME" --macaddress4 auto
VBoxManage modifyvm "$MASCHINE_NAME" --nictype1 $IF_TYPE # virtio failed pxe boot using the intel card
VBoxManage modifyvm "$MASCHINE_NAME" --nictype2 $IF_TYPE
VBoxManage modifyvm "$MASCHINE_NAME" --nictype3 $IF_TYPE
VBoxManage modifyvm "$MASCHINE_NAME" --nictype4 $IF_TYPE
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected2 off
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate2 off
VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected3 off
VBoxManage controlvm "$MASCHINE_NAME" setlinkstate3 off
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter1 vboxnet0
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter2 vboxnet1
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter3 vboxnet3
VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter4 vboxnet4
VBoxManage modifyvm "$MASCHINE_NAME" --vrdeport 5010-5030 --ioapic on #ioapic for centos pxe boot (verify it again)
VBoxManage modifyvm "$MASCHINE_NAME" --boot1 net 

echo "start it with VBoxHeadless -s $MASCHINE_NAME"
