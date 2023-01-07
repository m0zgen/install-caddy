#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, https://sys-adm.in
# Caddy server installer for Debian-based distros
# Reference: https://caddyserver.com/docs/install#debian-ubuntu-raspbian

set -e

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Functions
# ---------------------------------------------------\

# Help information
usage() {

    echo -e "\nJust run ./install.sh"
    exit 1

}

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -q|--quiet) _Q=1; ;;
        -h|--help) usage ;; 
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Checks supporting distros
checkDistro() {
    # Checking distro
    if [ -e /etc/centos-release ]; then
        DISTRO=`cat /etc/redhat-release | awk '{print $1,$4}'`
        RPM=1
    elif [ -e /etc/fedora-release ]; then
        DISTRO=`cat /etc/fedora-release | awk '{print ($1,$3~/^[0-9]/?$3:$4)}'`
        RPM=2
    elif [ -e /etc/os-release ]; then
        DISTRO=`lsb_release -d | awk -F"\t" '{print $2}'`
        RPM=0
        DEB=1
    else
        DISTRO="UNKNOWN"
        RPM=0
        DEB=0
    fi
}

# Init official repo
# ---------------------------------------------------\

aptUpdate() {
    sudo apt update
}

pushCaddy() {

    echo "Apt update starting..."
    aptUpdate

    echo "Install packages..."
    sudo apt -y install ca-certificates curl gnupg lsb-release debian-keyring debian-archive-keyring apt-transport-https

    echo "Install official Caddy keys and Docker repo..."
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    
    echo "Apt update..."
    aptUpdate

    echo "Install Docker packages..."
    sudo apt -y install caddy

    echo -e "\nDone!\n"
    exit 0
}

instalDebian() {

    if ! [ -x "$(command -v caddy)" ]; then
        echo "Caddy installation process starting..."
        pushCaddy
    else
        echo "Caddy already installed. Exit. Bye."
        exit 1
    fi


}

checkDistro

if [[ "${DEB}" -eq "1" ]]; then
    instalDebian
else
    echo -e "Not supported distro. Exit..."
    exit 1
fi