#! /bin/bash
#
# uninstall.sh
#
# "uninstall the app from the target system"

G_EXEC_NOHALT=1 G_EXEC_OUTPUT=1 G_EXEC /opt/adsb/docker-compose-adsb down
Remove_Service adsb-docker
Remove_Service adsb-feeder-update
Remove_Service adsb-setup
[[ -f /opt/adsb/pre-uninstall-cleanup ]] && G_EXEC /opt/adsb/pre-uninstall-cleanup
G_EXEC rm -Rf /opt/adsb /mnt/dietpi_userdata/adsb-feeder /opt/adsb-feeder-update
