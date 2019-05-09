#!/usr/bin/env bash

# Copyright 2014 The Kubernetes Authors.
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

# Run a command in the docker build container.  Typically this will be one of
# the commands in `hack/`.  When running in the build container the user is sure
# to have a consistent reproducible build environment.

#! /bin/bash

#set -o errexit
#set -o nounset
#set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

HOSTIP=(
    "192.168.28.90"
    "192.168.28.91"
    "192.168.28.92"
    "192.168.28.93"
    "192.168.28.94"
)
HOSTNAME=(
    "n00"
    "n01"
    "n02"
    "n03"
    "n04"
)

echo "${HOSTIP[3]}:6443"