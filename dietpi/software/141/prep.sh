#! /bin/bash
#
# prep.sh
#
# "put the bits in place"

# clone the adsb-feeder repo into /tmp
G_EXEC_OUTPUT=1 G_EXEC git clone -b dietpi 'https://github.com/dirkhh/adsb-feeder-image.git' /tmp/adsb-feeder

# remove the files that aren't needed for an app install on DietPi
G_EXEC cd /tmp/adsb-feeder/src/modules/adsb-feeder/filesystem/root
G_EXEC rm ./usr/lib/systemd/system/adsb-bootstrap.service
G_EXEC rm ./usr/lib/systemd/system/adsb-update.service
G_EXEC rm ./usr/lib/systemd/system/adsb-update.timer

# create the target directory for the app and populated with the code from the git checkout
[[ -d '/opt/adsb' ]] && G_EXEC rm -R /opt/adsb
G_EXEC mv /tmp/adsb-feeder/src/modules/adsb-feeder/filesystem/root/opt/adsb /opt/
G_EXEC mkdir -p /opt/adsb/etc/systemd/system
G_EXEC mv /tmp/adsb-feeder/src/modules/adsb-feeder/filesystem/root/usr/lib/systemd/system/* /opt/adsb/etc/systemd/system/

# set the 'image name' and version that are shown in the footer of the Web UI
G_EXEC cd /opt/adsb
G_EXEC eval 'echo '\''ADSB Feeder app running on DietPi'\'' > feeder-image.name'
l_ADSB_FEEDER_TAG_COMPONENT=$(git describe --match 'v[0-9]*' --long | sed 's/-[0-9]*-g[0-9a-f]*//')
G_EXEC eval "echo '$l_ADSB_FEEDER_TAG_COMPONENT(dietpi)' > adsb.im.version"
unset l_ADSB_FEEDER_TAG_COMPONENT

# remove the git clone of the repo we installed from
G_EXEC rm -R /tmp/adsb-feeder

# install Python Flask
# for older distros we need to install via pip in order to get flask 2
if (( $G_DISTRO < 7 ))
then
    G_EXEC_OUTPUT=1 G_EXEC pip3 install -U flask
else
    G_AGI python3-flask
fi
