#! /bin/bash
#
# uninstall.sh
#
# "uninstall the app from the target system"

Remove_Service docker

# Packages, repo and key
G_AGP docker-ce docker-ce-cli docker-engine
[[ -f '/etc/apt/sources.list.d/docker.list' ]] && G_EXEC rm /etc/apt/sources.list.d/docker.list
[[ -f '/etc/apt/trusted.gpg.d/dietpi-docker.gpg' ]] && G_EXEC rm /etc/apt/trusted.gpg.d/dietpi-docker.gpg

# DietPi data dir
[[ -d '/mnt/dietpi_userdata/docker-data' ]] && G_EXEC rm -R /mnt/dietpi_userdata/docker-data
# Default data dir
[[ -d '/var/lib/docker' ]] && G_EXEC rm -R /var/lib/docker
# Config dir
[[ -d '/etc/docker' ]] && G_EXEC rm -R /etc/docker

# Set Portainer as not installed
aSOFTWARE_INSTALL_STATE[185]=0
