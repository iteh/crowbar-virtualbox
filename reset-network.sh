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

source functions.sh

ensure_vboxnet 4 "192.168.124.1"
ensure_vboxnet 5 "192.168.122.1"
ensure_vboxnet 6 "192.168.125.1"
ensure_vboxnet 7 "192.168.123.1"


