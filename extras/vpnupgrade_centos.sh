#!/bin/sh
#
# Script to upgrade Libreswan on CentOS and RHEL
#
# Copyright (C) 2016 Lin Song <linsongui@gmail.com>
#
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License: http://creativecommons.org/licenses/by-sa/3.0/
#
# Attribution required: please include my name in any derivative and let me
# know how you have improved it!

# Check for the latest version at https://libreswan.org and update as necessary
swan_ver=3.17

### Do not edit below this line

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

exiterr() { echo "Error: ${1}" >&2; exit 1; }

if [ ! -f /etc/redhat-release ]; then
  exiterr "This script only supports CentOS/RHEL."
fi

if ! grep -qs -e "release 6" -e "release 7" /etc/redhat-release; then
  exiterr "This script only supports CentOS/RHEL 6 and 7."
fi

if [ -f /proc/user_beancounters ]; then
  exiterr "This script does not support OpenVZ VPS."
fi

if [ "$(id -u)" != 0 ]; then
  exiterr "Script must be run as root. Try 'sudo sh $0'"
fi

if [ -z "$swan_ver" ]; then
  exiterr "Libreswan version 'swan_ver' not specified."
fi

/usr/local/sbin/ipsec --version 2>/dev/null | grep -qs "Libreswan"
if [ "$?" != "0" ]; then
  exiterr "This script requires Libreswan already installed."
fi

/usr/local/sbin/ipsec --version 2>/dev/null | grep -qs "Libreswan $swan_ver"
if [ "$?" = "0" ]; then
  echo "You already have Libreswan version $swan_ver installed! "
  echo "If you continue, the same version will be re-installed."
  echo
  printf "Do you wish to continue anyway? [y/N] "
  read -r response
  case $response in
    [yY][eE][sS]|[yY])
      echo
      ;;
    *)
      echo "Aborting."
      exit 1
      ;;
  esac
fi

clear

cat <<EOF
Welcome! This script will build and install Libreswan $swan_ver on your server.
Additional packages required for Libreswan compilation will also be installed.

This is intended for use on servers running an older version of Libreswan.
Your existing VPN configuration files will NOT be modified.

EOF

printf "Do you wish to continue? [y/N] "
read -r response
case $response in
  [yY][eE][sS]|[yY])
    echo
    echo "Please be patient. Setup is continuing..."
    echo
    ;;
  *)
    echo "Aborting."
    exit 1
    ;;
esac

# Create and change to working dir
mkdir -p /opt/src
cd /opt/src || exiterr "Cannot enter /opt/src."

# Install Wget
yum -y install wget

# Add the EPEL repository
yum -y install epel-release
yum list installed epel-release >/dev/null 2>&1
[ "$?" != "0" ] && exiterr "Cannot add EPEL repository."

# Install necessary packages
yum -y install nss-devel nspr-devel pkgconfig pam-devel \
    libcap-ng-devel libselinux-devel \
    curl-devel flex bison gcc make \
    fipscheck-devel unbound-devel xmlto

# Install libevent2 and systemd-devel (CentOS 7)
if grep -qs "release 6" /etc/redhat-release; then
  yum -y remove libevent-devel
  yum -y install libevent2-devel
elif grep -qs "release 7" /etc/redhat-release; then
  yum -y install libevent-devel systemd-devel
fi

# Compile and install Libreswan
swan_file="libreswan-${swan_ver}.tar.gz"
swan_url1="https://download.libreswan.org/$swan_file"
swan_url2="https://github.com/libreswan/libreswan/archive/v${swan_ver}.tar.gz"
wget -t 3 -T 30 -nv -O "$swan_file" "$swan_url1" || wget -t 3 -T 30 -nv -O "$swan_file" "$swan_url2"
[ "$?" != "0" ] && exiterr "Cannot download Libreswan source."
/bin/rm -rf "/opt/src/libreswan-$swan_ver"
tar xzf "$swan_file" && /bin/rm -f "$swan_file"
cd "libreswan-$swan_ver" || exiterr "Cannot enter Libreswan source dir."
echo "WERROR_CFLAGS =" > Makefile.inc.local
make -s programs && make -s install

# Verify the install and clean up
cd /opt/src || exiterr "Cannot enter /opt/src."
/bin/rm -rf "/opt/src/libreswan-$swan_ver"
/usr/local/sbin/ipsec --version 2>/dev/null | grep -qs "$swan_ver"
[ "$?" != "0" ] && exiterr "Libreswan $swan_ver failed to build."

# Restore SELinux contexts
restorecon /etc/ipsec.d/*db 2>/dev/null
restorecon /usr/local/sbin -Rv 2>/dev/null
restorecon /usr/local/libexec/ipsec -Rv 2>/dev/null

# Restart IPsec service
service ipsec restart

echo
echo "Libreswan $swan_ver was installed successfully! "
echo

exit 0
