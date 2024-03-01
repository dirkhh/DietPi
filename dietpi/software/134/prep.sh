#! /bin/bash
#
# prep.sh
#
# "put the bits in place"

[[ -f '/usr/local/bin/docker-compose' ]] && G_EXEC rm /usr/local/bin/docker-compose # Pre-v8.14
command -v docker-compose > /dev/null && command -v pip3 > /dev/null && G_EXEC_OUTPUT=1 G_EXEC pip3 uninstall -y docker-compose # Pre-v8.2
G_AGI docker-compose-plugin
