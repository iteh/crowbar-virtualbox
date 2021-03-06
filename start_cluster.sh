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

[ $DEBUG -gt 0 ] && set -x

MACHINES=`VBoxManage list vms | grep $NODE_PREFIX | awk '{ gsub (/"/,""); print $1}'`
RUNNING_MASCHINES=`VBoxManage list runningvms | grep $NODE_PREFIX | awk '{ gsub (/"/,""); print $1}'`

for I in $MACHINES
do
  if ! echo $RUNNING_MASCHINES| grep $I &> /dev/null
  then 
    VBoxManage startvm ${I} --type headless
    VBoxManage controlvm ${I} vrde on
    MESSAGE="${I} just started"
    echo Starting $I watch progress with a Windows Remote Client at port $PORT 
  else 
    MESSAGE="${I} already running" 
  fi
  PORT=`VBoxManage showvminfo ${I}|grep "VRDE port"|awk '{print $3}'`
  echo "${MESSAGE}: Connect to it with rdp on the local port ${PORT}"

done
