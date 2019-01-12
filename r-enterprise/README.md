# Oracle R Enterprise

This repository contains scripts to install Oracle R Enterprise on Red Hat Enterprise Linux 7.

## Prerequisites

Oracle 12c Enterprise Edition must be installed on the machine before installing Oracle R Enterprise.

## Downloads

Download all the files below and place it in the `/tmp/ore` working directory.

* [Oracle R Enterprise Server](http://download.oracle.com/otn/linux/ore/ore-server-linux-x86-64-1.5.zip)
* [Oracle R Enterprise Supporting Packages](http://download.oracle.com/otn/linux/ore/ore-supporting-linux-x86-64-1.5.zip)
* [libRmath-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/libRmath-3.2.0-2.el7.x86_64.rpm)
* [libRmath-devel-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/libRmath-devel-3.2.0-2.el7.x86_64.rpm)
* [libRmath-static-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/libRmath-static-3.2.0-2.el7.x86_64.rpm)
* [R-core-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/R-core-3.2.0-2.el7.x86_64.rpm)
* [R-devel-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/R-devel-3.2.0-2.el7.x86_64.rpm)
* [R-3.2.0-2](http://public-yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/getPackage/R-3.2.0-2.el7.x86_64.rpm)

## Installation

The installation scripts will install the Oracle R Distribution then the Oracle R Enterprise Server and Oracle R Enterprise Supporting Packages.

* `git clone https://github.com/sufyanm/oracle.git /tmp/oracle`
* Run `cd /tmp/oracle/r-enterprise && chmod 755 *.sh && ./install.sh` as `root`
