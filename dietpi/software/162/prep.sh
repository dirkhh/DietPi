#! /bin/bash
#
# prep.sh
#
# "put the bits in place"

__162_prep() {
    # APT package name
    # - RISC-V: Use "docker.io" from Debian repo as the official Docker repo does not support RISC-V yet: https://download.docker.com/linux/debian/dists/
    local package='docker.io'
    if (( $G_HW_ARCH != 11 ))
    then
        # Detect distro
        local distro='debian'
        (( $G_RASPBIAN )) && distro='raspbian'

        # APT key
        local url="https://download.docker.com/linux/$distro/gpg"
        G_CHECK_URL "$url"
        G_EXEC eval "curl -sSfL '$url' | gpg --dearmor -o /etc/apt/trusted.gpg.d/dietpi-docker.gpg --yes"

        # APT list
        G_EXEC eval "echo 'deb https://download.docker.com/linux/$distro/ ${G_DISTRO_NAME/trixie/bookworm} stable' > /etc/apt/sources.list.d/docker.list"
        G_AGUP

        # APT package name
        package='docker-ce'
    fi

    # APT package
    # - Mask service to prevent iptables related startup failure: https://github.com/MichaIng/DietPi/issues/6013
    G_EXEC systemctl mask --now docker
    G_AGI "$package"
    G_EXEC systemctl unmask docker
    G_EXEC systemctl start docker.socket

    # Change Docker service type to "simple": https://github.com/MichaIng/DietPi/issues/2238#issuecomment-439474766
    G_EXEC mkdir -p /lib/systemd/system/docker.service.d
    G_EXEC eval "echo -e '[Service]\nType=simple' > /lib/systemd/system/docker.service.d/dietpi-simple.conf"

    # Config: https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
    # - Move Docker containers to dietpi_userdata
    # - Log to systemd-journald (journalctl) by default with reduced log level: https://github.com/MichaIng/DietPi/issues/2388
    #	+ containerd: https://github.com/docker/docker.github.io/issues/9091
    G_EXEC mkdir -p /mnt/dietpi_userdata/docker-data
    if [[ -f '/etc/docker/daemon.json' ]]
    then
        GCI_PRESERVE=1 G_CONFIG_INJECT '"data-root":' '    "data-root": "/mnt/dietpi_userdata/docker-data",' /etc/docker/daemon.json '^\{([[:space:]]|$)'
        GCI_PRESERVE=1 G_CONFIG_INJECT '"log-driver":' '    "log-driver": "journald",' /etc/docker/daemon.json '^\{([[:space:]]|$)'
        GCI_PRESERVE=1 G_CONFIG_INJECT '"log-level":' '    "log-level": "warn",' /etc/docker/daemon.json '^\{([[:space:]]|$)'
        GCI_PRESERVE=1 G_CONFIG_INJECT '"debug":' '    "debug": false,' /etc/docker/daemon.json '^\{([[:space:]]|$)'
    else
        G_EXEC mkdir -p /etc/docker
        echo '{
    "data-root": "/mnt/dietpi_userdata/docker-data",
    "log-driver": "journald",
    "log-level": "warn",
    "debug": false
}' > /etc/docker/daemon.json
    fi
    G_CONFIG_INJECT '\[debug\]' '[debug]' /etc/containerd/config.toml
    GCI_PRESERVE=1 G_CONFIG_INJECT 'level[[:blank:]]*=' '  level = "warn"' /etc/containerd/config.toml '^\[debug\]'

    Enable_memory_cgroup
    Configure_iptables
}

__162_prep
