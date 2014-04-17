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

set_disk_path () {
  [ -z $1 ] && echo "you must provide a boxname name as first param" && exit
  VMPATH="/"$(VBoxManage list systemproperties|grep "^Default machine folder"| cut -d '/' -f 2-)"/"$1"/"
  DISKPATH="/"$VMPATH/""$MASCHINE_NAME".vdi"
}

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
  
  #disable the dhcpserver on the hostonly if
  #VBoxManage dhcpserver remove --netname HostInterfaceNetworking-vboxnet$VBOX_NET_NUMBER 
  # hackish reset to something not used so virtualbox sets up everything (including routing)
  VBoxManage hostonlyif ipconfig vboxnet$VBOX_NET_NUMBER --ip 4.3.2.1 --netmask 255.255.255.0
  # the real config  
  VBoxManage hostonlyif ipconfig vboxnet$VBOX_NET_NUMBER --ip $VBOX_NET_IP --netmask $VBOXNET_MASK
}   

unregister_and_delete_vm () {
  
  [ -z $1 ] && echo "you must provide a maschine name as first param" && exit
  
  MASCHINE_NAME=$1
  
  set_disk_path "$MASCHINE_NAME" 

  if [ -f "$DISKPATH"  ] 
  then 
    echo "we already have a "$MASCHINE_NAME" instance, deleting it to start with a fresh one"
    VBoxManage unregistervm "$MASCHINE_NAME" --delete
    rm -rf "$VMPATH"
  fi 
}

create_machine () {
    NEXT_FREE_NUMBER=$((`VBoxManage list vms | grep $NODE_PREFIX | wc -l` + 1))
    MASCHINE_NUMBER=${4:-$NEXT_FREE_NUMBER}
    NUMBER_OF_NICS=${3:-4}
    MEMORY=$2
    MASCHINE_NAME=$1

# start with a fresh one ...
    unregister_and_delete_vm "$MASCHINE_NAME" 

    VBoxManage createvm --name "$MASCHINE_NAME" --ostype Ubuntu_64 --register
    VBoxManage modifyvm "$MASCHINE_NAME" --memory $MEMORY
    VBoxManage storagectl "$MASCHINE_NAME" --name 'IDE Controller' --add ide
    VBoxManage storagectl "$MASCHINE_NAME" --name 'SATA Controller' --add sata --hostiocache off --portcount 1

    set_disk_path $MASCHINE_NAME
    VBoxManage createhd --filename "$DISKPATH" --size 30000 --format VDI 
    VBoxManage storageattach "$MASCHINE_NAME" --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium "$DISKPATH" 

    N=$MASCHINE_NUMBER

    for i in `seq 1 $NUMBER_OF_NICS`;
    do 
	VBoxManage modifyvm "$MASCHINE_NAME" --nic$i hostonly
	VBoxManage modifyvm "$MASCHINE_NAME" --nictype$i $IF_TYPE
	VBoxManage modifyvm "$MASCHINE_NAME" --cableconnected$i on
	VBoxManage controlvm "$MASCHINE_NAME" setlinkstate$i on
	VBoxManage modifyvm "$MASCHINE_NAME" --hostonlyadapter$i vboxnet$(($i + 3))
	VBoxManage modifyvm "$MASCHINE_NAME" --macaddress$i c0ffee000${N}0${i}
	VBoxManage modifyvm "$MASCHINE_NAME" --vrdeport 5010-5030 
	VBoxManage modifyvm "$MASCHINE_NAME" --ioapic on #ioapic for centos pxe boot (verify it again)
	VBoxManage modifyvm "$MASCHINE_NAME" --nicpromisc$i allow-all
        VBoxManage modifyvm "$MASCHINE_NAME" --boot1 net
    done
}
