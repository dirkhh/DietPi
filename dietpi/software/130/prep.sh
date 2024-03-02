#! /bin/bash
#
# prep.sh
#
# "put the bits in place"

# Workaround for pip v23
>> /etc/pip.conf
G_CONFIG_INJECT '\[global\]' '[global]' /etc/pip.conf
G_CONFIG_INJECT 'break-system-packages[[:blank:]]*=' 'break-system-packages=true' /etc/pip.conf '\[global\]'

# Disable cache
G_CONFIG_INJECT 'no-cache-dir[[:blank:]]*=' 'no-cache-dir=true' /etc/pip.conf '\[global\]'

# ARMv6/7: Add piwheels
# shellcheck disable=SC2154  # this file is sourced into dietpi-software
(( $G_HW_ARCH < 3 )) && G_CONFIG_INJECT 'extra-index-url[[:blank:]]*=' 'extra-index-url=https://www.piwheels.org/simple/' /etc/pip.conf '\[global\]'

# Buster => Bullseye upgrade: Remove obsolete pip constraint
if [[ -f '/etc/pip-constraints.txt' ]] && grep -q 'numpy' /etc/pip-constraints.txt
then
    G_EXEC sed --follow-symlinks -i '/^constraint=/d' /etc/pip.conf
    G_EXEC rm /etc/pip-constraints.txt
fi

# Perform pip3 install (which includes setuptools and wheel modules)
# shellcheck disable=SC2034  # this file is sourced into dietpi-software
aDEPS=('python3-dev')
Download_Install 'https://bootstrap.pypa.io/get-pip.py'
G_EXEC_OUTPUT=1 G_EXEC python3 get-pip.py
G_EXEC rm get-pip.py
