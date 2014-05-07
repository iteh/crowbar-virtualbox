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

[ $DEBUG -gt 0 ] && set -x

NODE_NAME="${NODE_PREFIX}Orchestration-FE"

create_machine $NODE_NAME $ORCHESTRATION_FE_MEMORY $NUMBER_ORCHESTRATION_FE_NICS 192 $ORCHESTRATION_FE_DISKSIZE

VBoxManage modifyvm $NODE_NAME --boot1 disk
set_disk_path $MASCHINE_NAME

# Image must be in VDI Format
cp "$ORCHESTRATION_FE_IMAGE" "$DISKPATH.vdi" 

#VBoxManage clonehd "$ORCHESTRATION_FE_IMAGE" "$DISKPATH.vdi" 
VBoxManage storageattach "$MASCHINE_NAME" --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium "$DISKPATH.vdi" 

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"

#------------------------------------------------------------------------------
# NSX-Manager

NODE_NAME="${NODE_PREFIX}Orchestration-BE"

create_machine $NODE_NAME $ORCHESTRATION_BE_MEMORY $NUMBER_ORCHESTRATION_BE_NICS 193 $ORCHESTRATION_BE_DISKSIZE

VBoxManage modifyvm $NODE_NAME --boot1 disk
set_disk_path $MASCHINE_NAME

# Image must be in VDI Format
cp "$ORCHESTRATION_BE_IMAGE" "$DISKPATH" 

echo "start it with VBoxManage startvm ${NODE_NAME} --type headless"



