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
VBoxManage startvm crowbar-essex-1 --type headless
VBoxManage startvm crowbar-essex-2 --type headless
VBoxManage startvm crowbar-essex-3 --type headless
VBoxManage startvm crowbar-essex-4 --type headless
VBoxManage startvm crowbar-essex-5 --type headless 

# 3389
vboxmanage controlvm crowbar_admin vrde on 
# 5010
vboxmanage controlvm crowbar-essex-1 vrde on
# 5011
vboxmanage controlvm crowbar-essex-2 vrde on
# 5012
vboxmanage controlvm crowbar-essex-3 vrde on
# 5013
vboxmanage controlvm crowbar-essex-4 vrde on
# 5014
vboxmanage controlvm crowbar-essex-5 vrde on

