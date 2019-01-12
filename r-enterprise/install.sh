#!/bin/bash
#
# Installs Oracle R Enterprise Server on Red Hat Enterprise Linux 7. Ensure that
# the Oracle 12c EE database has been installed and all required files have been
# downloaded and placed in the working directory. Run this script as root.
#
# Copyright 2017 Sufyan Muhammad
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

# Define variables
WORK_DIR=/tmp/ore
ORACLE_USER=oracle
ORACLE_SID=ORE
RQSYS_PASS=syspasswd
RQSYS_PERM=SYSAUX
RQSYS_TEMP=TEMP
RQUSER=rquser
RQUSER_PASS=usrpasswd
RQUSER_PERM=USERS
RQUSER_TEMP=TEMP

# Check script is run as root
[[ $EUID -ne 0 ]] && echo "This script must be run as root" && exit 1

# Check all files required are available in $WORK_DIR
[ -f $WORK_DIR/libRmath-3.2.0-2.el7.x86_64.rpm ] || echo "File libRmath-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/libRmath-devel-3.2.0-2.el7.x86_64.rpm ] || echo "File libRmath-devel-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/libRmath-static-3.2.0-2.el7.x86_64.rpm ] || echo "File libRmath-static-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/R-core-3.2.0-2.el7.x86_64.rpm ] || echo "File R-core-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/R-devel-3.2.0-2.el7.x86_64.rpm ] || echo "File R-devel-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/R-3.2.0-2.el7.x86_64.rpm ] || echo "File R-3.2.0-2.el7.x86_64.rpm not found" && exit 1
[ -f $WORK_DIR/ore-server-linux-x86-64-1.5.zip ] || echo "File ore-server-linux-x86-64-1.5.zip not found" && exit 1
[ -f $WORK_DIR/ore-supporting-linux-x86-64-1.5.zip ] || echo "File ore-supporting-linux-x86-64-1.5.zip not found" && exit 1

# Enable required repository for Red Hat Enterprise Linux 7
subscription-manager repos --enable=rhel-7-server-optional-rpms

# Install Oracle R Distribution
yum -y localinstall $WORK_DIR/libRmath-3.2.0-2.el7.x86_64.rpm
yum -y localinstall $WORK_DIR/libRmath-devel-3.2.0-2.el7.x86_64.rpm
yum -y localinstall $WORK_DIR/libRmath-static-3.2.0-2.el7.x86_64.rpm
yum -y localinstall $WORK_DIR/R-core-3.2.0-2.el7.x86_64.rpm
yum -y localinstall $WORK_DIR/R-devel-3.2.0-2.el7.x86_64.rpm
yum -y localinstall $WORK_DIR/R-3.2.0-2.el7.x86_64.rpm

# Install Oracle R Enterprise Server
cat << EOF > $WORK_DIR/ore-install.sh
unzip -d $WORK_DIR $WORK_DIR/ore-server-linux-x86-64-1.5.zip
unzip -d $WORK_DIR $WORK_DIR/ore-supporting-linux-x86-64-1.5.zip

# Set environment variables
export ORACLE_SID=$ORACLE_SID
export ORAENV_ASK=NO
export R_HOME=/usr/lib64/R
export LD_LIBRARY_PATH=\$RHOME/lib:\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH
export PATH=/usr/lib64/R:\$ORACLE_HOME/bin:\$PATH

# Set Oracle environment
. oraenv

cd $WORK_DIR && ./server.sh -y --perm $RQSYS_PERM --temp $RQSYS_TEMP --rqsys $RQSYS_PASS --user $RQUSER --pass $RQUSER_PASS --user-perm $RQUSER_PERM --user-temp $RQUSER_TEMP
EOF
chmod 755 $WORK_DIR/ore-install.sh
su - $ORACLE_USER -c $WORK_DIR/ore-install.sh

# Clean up working directory
rm -rf $WORK_DIR
