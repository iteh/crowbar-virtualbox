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

FUNCTIONS_SH_SOURCED=1

ensure_vboxnet () { 
  [ -z $1 ] && echo "you must provide a vboxnetnumber name as first param" && exit
  [ -z $2 ] && echo "you must provide a Ipadress as second param" && exit 
  
  VBOX_NET_NUMBER=$1
  VBOX_NET_IP="$2"
  CURRENT_NUMBER_OF_NETWORK_INTERFACES=`VBoxManage list hostonlyifs|grep VBoxNetworkName|wc -l`  
  
  if [ "$CURRENT_NUMBER_OF_NETWORK_INTERFACES" -lt $(expr $VBOX_NET_NUMBER + 1) ] 
  then
    VBoxManage hostonlyif create
  fi
  
  # hackish reset to something not used so virtualbox sets up everything (including routing)
  VBoxManage hostonlyif ipconfig vboxnet$VBOX_NET_NUMBER --ip 4.3.2.1 --netmask 255.255.255.0
  # the real config  
  VBoxManage hostonlyif ipconfig vboxnet$VBOX_NET_NUMBER --ip $VBOX_NET_IP --netmask 255.255.255.0
}   

unregister_and_delete_vm () {
  
  [ -z $1 ] && echo "you must provide a maschine name as first param" && exit
  
  MASCHINE_NAME=$1
  
  VMPATH="/"$(VBoxManage list systemproperties|grep "^Default"| cut -d '/' -f 2-)"/"$MASCHINE_NAME"/"
  DISKPATH="/"$VMPATH/""$MASCHINE_NAME".vdi"

  if [ -f "$DISKPATH"  ] 
  then 
    echo "we already have a "$MASCHINE_NAME" instance, deleting it to start with a fresh one"
    VBoxManage unregistervm "$MASCHINE_NAME" --delete
    rm -rf "$VMPATH"
  fi 
}