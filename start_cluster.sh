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


VBoxManage startvm crowbar_admin --type headless
VBoxManage controlvm crowbar_admin vrde on # 3389

for I in 1 2 3 
do
  VBoxManage startvm crowbar-essex-${I} --type headless  
  # starting at 5010  crowbar-essex-${I} -> 5010 - 1 + ${I}
  VBoxManage controlvm crowbar-essex-${I} vrde on  
  
done

for I in 4 5 
do
  VBoxManage startvm crowbar-essex-${I} --type headless
  VBoxManage controlvm crowbar-essex-${I} vrde on
done
