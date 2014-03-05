#!/bin/sh
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

VBoxManage controlvm crowbar_admin poweroff
sleep 2
VBoxManage unregistervm crowbar_admin --delete
for I in 1 2 3 4 5 6
do
  VBoxManage controlvm crowbar-essex-${I} poweroff
  sleep 2
  VBoxManage unregistervm crowbar-essex-${I} --delete
done
