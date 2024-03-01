#! /bin/bash
#
# configure.sh
#
# "configure the app on the target system"

# create a symlink so the config files reside where they should be in /mnt/dietpi_userdata/adsb-feeder
G_EXEC mkdir -p /mnt/dietpi_userdata/adsb-feeder/config
G_EXEC ln -s /mnt/dietpi_userdata/adsb-feeder/config /opt/adsb/

# finally move the services in place
G_EXEC mv /opt/adsb/etc/systemd/system/* /etc/systemd/system
# now that everything is in place, run the one time service to get the software pre-configured
# running this as a service allows it to do a bit of housekeeping in the background without disrupting
# the software install flow
G_EXEC systemctl start adsb-nonimage
