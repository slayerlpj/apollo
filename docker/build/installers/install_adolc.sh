#!/usr/bin/env bash

###############################################################################
# Copyright 2018 The Apollo Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

# Fail on first error.
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

#apt-get install autoconf automake libtool

echo "Build and install ColPack"

git clone https://github.com/CSCsw/ColPack.git

# works
pushd ColPack
pushd build/automake      # automake folder
autoreconf -vif        # generate configure files based on the machince
mkdir mywork && cd mywork
fullpath=$(pwd)        # modify fullpath to your destination folder if need
../configure --prefix=${fullpath}
make -j$(nproc)        # Where "4" is the number of cores on your machine
make install           # install lib and include/ColPack to destination

mkdir -p /usr/local/colpack
cp -r include /usr/local/colpack/ && cp -r lib /usr/local/colpack/
popd
cp LICENSE /usr/local/colpack/
popd

echo "colpack done."
echo "Build and install ADOL-C"

wget https://www.coin-or.org/download/source/ADOL-C/ADOL-C-2.6.3.zip -O ADOL-C-2.6.3.zip
unzip ADOL-C-2.6.3.zip

pushd ADOL-C-2.6.3
autoreconf --install
automake
./configure --prefix="/apollo/docker/build/installers/ADOL-C-2.6.3" --enable-sparse --enable-addexa --with-openmp-flag="-fopenmp" --with-colpack="/usr/local/colpack" ADD_CXXFLAGS="-fPIC" ADD_CFLAGS="-fPIC" ADD_FFLAGS="-fPIC"

make -j8 all
make install

echo "Build ADOL-C done."
mkdir -p /usr/local/adolc
cp -r include /usr/local/adolc/ && cp -r lib64 /usr/local/adolc/
cp LICENSE /usr/local/adolc/
popd

export LD_LIBRARY_PATH=/usr/local/adolc/lib64:$LD_LIBRARY_PATH

# Clean up.
apt-get clean && rm -rf /var/lib/apt/lists/*
rm -fr ADOL-C-2.6.3.zip ADOL-C-2.6.3 ColPack
