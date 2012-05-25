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

[ -z $1 ] && echo "you must provide a maschine name" && exit

MASCHINE_NAME=$1

echo "creating $MASCHINE_NAME"


VBoxManage unregistervm "$MASCHINE_NAME" --delete
VBoxManage clonevm crowbar-base-box --name "$MASCHINE_NAME" --register

VBoxManage modifyvm "$MASCHINE_NAME" --memory 2048 --ostype Debian_64  
VBoxManage modifyvm "$MASCHINE_NAME" --vrdeport 5010-5030 --ioapic on #ioapic for centos pxe boot (verify it again)

VBoxManage modifyvm "$MASCHINE_NAME" --boot1 net 

echo "start it with VBoxHeadless -s $MASCHINE_NAME"
