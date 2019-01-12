#!/bin/bash

INVENTORY_GROUP=
DBA_GROUP=
OPER_GROUP=

# Add repository for compat-libstdc++-33
subscription-manager repos --enable rhel-7-server-optional-rpms

# Install required packages
yum -y install binutils compat-libcap1 gcc gcc-c++ glibc.i686 glibc.x86_64 \
  glibc-devel.i686 glibc-devel.x86_64 ksh libaio.i686 libaio.x86_64 \
  libaio-devel.i686 libaio-devel.x86_64 libgcc.i686 libgcc.x86_64 \
  libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 \
  libXi.i686 libXi.x86_64 libXtst.i686 libXtst.x86_64 make sysstat unzip \
  compat-libstdc++-33

# Add the Oracle Inventory, OSDBA, and OSOPER groups
groupadd $INVENTORY_GROUP
groupadd $DBA_GROUP
groupadd $OPER_GROUP

# Add the Oracle software owner, ORACLE_USER
useradd -g $INVENTORY_GROUP -G $DBA_GROUP,$OPER_GROUP $ORACLE_USER

# Create directories for software
mkdir -p /u01/app
chown -R $ORACLE_USER:$INVENTORY_GROUP /u01/app
chmod -R 775 /u01/app

# Create directories for data files
mkdir -p /u02/oradata
chown -R $ORACLE_USER:$INVENTORY_GROUP /u02/oradata
chmod -R 775 /u02/oradata

# Configure kernel parameters
MEM_TOTAL=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)

cat << EOF > /etc/sysctl.d/oracle.conf
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = $(($MEM_TOTAL * 1024 / 2))
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

# Read /etc/sysctl.conf
sysctl -p

# Configure resource limits
cat << EOF > /etc/security/limits.d/oracle.conf
$ORACLE_USER    soft    nofile    4096
$ORACLE_USER    hard    nofile    65536
$ORACLE_USER    soft    nproc     2047
$ORACLE_USER    hard    nproc     16384
$ORACLE_USER    soft    stack     10240
$ORACLE_USER    hard    stack     32768
EOF

# Unzip software installer
unzip -d $TMP $TMP/linuxamd64_12102_database_1of2.zip
unzip -d $TMP $TMP/linuxamd64_12102_database_2of2.zip

# Prepare response file for a silent install
cat << EOF > $TMP/db_install-$HOSTNAME.rsp
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=$HOSTNAME
UNIX_GROUP_NAME=$INVENTORY_GROUP
INVENTORY_LOCATION=$INVENTORY_LOCATION
SELECTED_LANGUAGES=en
ORACLE_HOME=$ORACLE_HOME
ORACLE_BASE=$ORACLE_BASE
oracle.install.db.InstallEdition=$EDITION
oracle.install.db.DBA_GROUP=$DBA_GROUP
oracle.install.db.OPER_GROUP=$OPER_GROUP
oracle.install.db.BACKUPDBA_GROUP=$BACKUPDBA_GROUP
oracle.install.db.DGDBA_GROUP=$DGDBA_GROUP
oracle.install.db.KMDBA_GROUP=$KMDBA_GROUP
EOF

# Run installer (as ORACLE_USER)
su - $ORACLE_USER -c "cd $TMP/database; ./runInstaller -silent -noconfig -waitforcompletion -responseFile $TMP/db_install-$HOSTNAME.rsp"

# Run post installation scripts
$INVENTORY_LOCATION/orainstRoot.sh
$ORACLE_HOME/root.sh

# Cleanup
rm -f $TMP/db_install-$HOSTNAME.rsp
rm -f $TMP/linuxamd64_12102_database_1of2.zip
rm -f $TMP/linuxamd64_12102_database_2of2.zip
