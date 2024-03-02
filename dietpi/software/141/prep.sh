#! /bin/bash
#
# prep.sh
#
# "put the bits in place"

# this is a massive hack to make things boot faster for the adsb.im images
# shellcheck disable=SC2154  # this file is sourced into dietpi-software
if [[ $G_DIETPI_PREINSTALL == 1 ]]
then
    # deal with zerotier and tailscale prereqs
    G_EXEC systemctl mask zerotier-one
    G_EXEC systemctl mask tailscaled
    # APT key: Download from GitHub instead of https://download.zerotier.com/contact%40zerotier.com.gpg for enhanced protection against corrupted download server
    zturl='https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg'
    G_CHECK_URL "$zturl"
    G_EXEC eval "curl -sSfL '$zturl' | gpg --dearmor -o /etc/apt/trusted.gpg.d/dietpi-zerotier.gpg --yes"

    # APT list
    # shellcheck disable=SC2154  # this file is sourced into dietpi-software
    G_EXEC eval "echo 'deb https://download.zerotier.com/debian/${G_DISTRO_NAME/trixie/bookworm} ${G_DISTRO_NAME/trixie/bookworm} main' > /etc/apt/sources.list.d/dietpi-zerotier.list"

    # APT key
    # shellcheck disable=SC2154  # this file is sourced into dietpi-software
    G_EXEC curl -sSfL "https://pkgs.tailscale.com/stable/debian/$G_DISTRO_NAME.noarmor.gpg" -o /etc/apt/trusted.gpg.d/dietpi-tailscale.gpg

    # APT list
    # shellcheck disable=SC2154  # this file is sourced into dietpi-software
    G_EXEC eval "echo 'deb https://pkgs.tailscale.com/stable/debian $G_DISTRO_NAME main' > /etc/apt/sources.list.d/dietpi-tailscale.list"

    G_AGUP

    ADD_PKGS=()
    # shellcheck disable=SC2154  # this file is sourced into dietpi-software
    [[ $G_HW_MODEL == [45] ]] && ADD_PKGS=(binutils binutils-aarch64-linux-gnu binutils-common libbinutils libctf-nobfd0 libctf0 libgprofng0 libjansson4 libpci3 pci.ids pciutils python3-pycryptodome rpi-eeprom)
    # setup python, git, zerotier, tailscale, rtl-sdr and the rpi-eeprom dependencies (if needed)
    G_AGI python3 python3-flask python3-requests git zerotier-one tailscale librtlsdr0 rtl-sdr "${ADD_PKGS[@]}"
    # do the pip install dance
    # shellcheck disable=SC1091
    source "/boot/dietpi/software/130/prep.sh"
    # now get docker
    # shellcheck disable=SC1091
    source "/boot/dietpi/software/162/prep.sh"
    # and docker compose (which requires pip)
    apt install -y --no-install-recommends docker-compose-plugin

    # and ironically - we actually do NOT install adsb.im here... we must do this on first install so that things are copied and configured
    # the way we need it - but all of the time intensive heavy lifting is in the above
else
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
# shellcheck disable=SC2154  # this file is sourced into dietpi-software
if (( $G_DISTRO < 7 ))
then
    G_EXEC_OUTPUT=1 G_EXEC pip3 install -U flask
else
    G_AGI python3-flask
fi
fi
