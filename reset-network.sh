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

set -e
set -x

[ -z $CONFIG_SH_SOURCED ] && source config.sh
[ -z $FUNCTIONS_SH_SOURCED ] && source functions.sh

# find maximum number of nics
for v in $NUMBER_COMPUTE_NICS $NUMBER_STORAGE_NICS $NUMBER_ADMIN_NICS
do
  [[ $v -gt $max ]] && max=$v
done

# create max number hostonly ifs starting at 4
for i in `seq 1 $max`
do
  I=$(($i + 3))
  NET="VBOXNET_${I}_IP"
  ensure_vboxnet $I ${!NET}
done

