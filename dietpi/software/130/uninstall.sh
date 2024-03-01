#! /bin/bash
#
# uninstall.sh
#
# "uninstall the app from the target system"

command -v pip3 > /dev/null && G_EXEC_OUTPUT=1 G_EXEC pip3 uninstall -y pip setuptools wheel
G_AGP python3-dev python3-pip # python3-pip: Pre-v6.32
[[ -f '/etc/pip.conf' ]] && G_EXEC rm /etc/pip.conf
[[ -f '/etc/pip-constraints.txt' ]] && G_EXEC rm /etc/pip-constraints.txt
G_EXEC rm -Rf /{root,home/*}/.cache/pip
