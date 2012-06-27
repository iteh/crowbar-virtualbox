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

[ -z $1 ] && echo "you must provide a snapshot name" && exit

VBoxManage snapshot crowbar_admin take "$1" --pause 
VBoxManage snapshot crowbar-essex-1 take "$1" --pause 
VBoxManage snapshot crowbar-essex-2 take "$1" --pause 
VBoxManage snapshot crowbar-essex-3 take "$1" --pause 
VBoxManage snapshot crowbar-essex-4 take "$1" --pause 
VBoxManage snapshot crowbar-essex-5 take "$1" --pause 
