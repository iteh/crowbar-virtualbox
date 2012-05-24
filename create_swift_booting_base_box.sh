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


VMPATH="/"$(VBoxManage list systemproperties|grep "^Default"| cut -d '/' -f 2-)"/swift/"
DISKPATH_1="/"$VMPATH/"/swift-root.vdi"
DISKPATH_2="/"$VMPATH/"/swift-store.vdi"

[ -f "$DISKPATH"  ] && echo "we already have a swift instance" && exit

VBoxManage unregistervm swift --delete
rm -rf "$VMPATH"
VBoxManage createvm --name swift --ostype Ubuntu_64 --register
VBoxManage storagectl 'swift' --name 'IDE Controller' --add ide
VBoxManage storagectl 'swift' --name 'SATA Controller' --add sata --hostiocache off --sataportcount 2

VBoxManage createhd --filename "$DISKPATH_1" --size 5000 --format VDI 
VBoxManage createhd --filename "$DISKPATH_2" --size 10000 --format VDI 
VBoxManage storageattach 'swift' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium "$DISKPATH_1"
VBoxManage storageattach 'swift' --storagectl 'SATA Controller' --port 1 --device 0 --type hdd --medium "$DISKPATH_2"
