#!/bin/bash

# This script is designed to install Grafana and influxdb

# Checking for Root Permissions # Thanks to Github User "codygarver" for the recommendation
check_your_privilege () {
    if [[ "$(id -u)" != 0 ]]; then
        echo -e "\e[91mError: This setup script requires root permissions. Please run the script as root.\e[0m" > /dev/stderr
        exit 1
    fi
}
check_your_privilege

# Define spinner function that displays during slow tasks.
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

clear

# Update Package Database
while true; do
    echo -n -e "\e[7mDo you wish to run system updates? [y/n]:\e[0m "
    read yn
    case $yn in
        [yY] | [yY][Ee][Ss] ) echo -ne "\e[36mUpdating System - This may take awhile!\e[0m";  (apt-get -y update >/dev/null 2>>install.log && apt-get -y upgrade >/dev/null 2>>install.log) & spinner $!;clear;echo -e "\r\033[K\e[36mUpdating System ----- Complete\e[0m"; break;; #(Run both in one line)
        [nN] | [n|N][O|o] ) echo -e "\e[36mSkipping Updates\e[0m"; break;;  #Boring people don't update
        * ) echo -e "\e[7mPlease answer y or n.\e[0m ";;  #Error handling to get the right answer
    esac
done

#### Grafana Installation ####

# Downloading GPG Key - Adding Packagecloud to Repo
echo -ne "\e[36mAdding GPG Key for Packagecloud Repo\e[0m"
(curl -s https://packagecloud.io/gpg.key | apt-key add - >>/dev/null 2>>install.log) & spinner $!
(add-apt-repository "deb https://packagecloud.io/grafana/stable/debian/ stretch main" >>/dev/null 2>>install.log) & spinner $!
echo -e "\r\033[K\e[36mAdding GPG Key for Packagecloud Repo ----- Complete\e[0m"

# Install Grafana
echo -ne "\e[36mInstalling Grafana\e[0m"
(apt-get update > /dev/null && apt-get install grafana -y >>/dev/null 2>>install.log) & spinner $!
echo -e "\r\033[K\e[36mInstalling Grafana ----- Complete\e[0m"

# Starting grafana
echo -ne "\e[36mStarting Grafana\e[0m"
systemctl start grafana-server >>/dev/null 2>>install.log
echo -e "\r\033[K\e[36mStarting Grafana ----- Complete\e[0m"

# Enable Grafana - Allows Auto Start on reboot
echo -ne "\e[36mEnabling Grafana\e[0m"
systemctl enable grafana-server >>/dev/null 2>>install.log
echo -e "\r\033[K\e[36mEnabling Grafana ----- Complete\e[0m"

#### influxdb Installation ####

# Downloading GPG Key - Adding Packagecloud to Repo - Clearing APT Cache
echo -ne "\e[36mAdding GPG Key for influxdb Repo\e[0m"
(curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - >>/dev/null 2>>install.log) & spinner $!
source /etc/lsb-release
(echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list >>/dev/null 2>>install.log) & spinner $!
echo -e "\r\033[K\e[36mAdding GPG Key for influxdb Repo ----- Complete\e[0m"

# Install influxdb
echo -ne "\e[36mInstalling influxdb\e[0m"
(apt-get update >>/dev/null 2>>install.log && apt-get install influxdb -y >>/dev/null 2>>install.log) & spinner $!
echo -e "\r\033[K\e[36mInstalling influxdb ----- Complete\e[0m"

# Starting influxdb
echo -ne "\e[36mStarting influxdb\e[0m"
systemctl start influxdb >>/dev/null 2>>install.log
echo -e "\r\033[K\e[36mStarting influxdb ----- Complete\e[0m"

# Enabling influxdb for auto start on reboot
echo -ne "\e[36mEnabling influxdb\e[0m"
systemctl enable influxdb >>/dev/null 2>>install.log
echo -e "\r\033[K\e[36mEnabling influxdb ----- Complete\e[0m"

# Install other Dependencies for various collection scripts
echo -ne "\e[36mInstalling SSHPASS and SNMP dependencies - This may take awhile!\e[0m"
(apt-get install -y sshpass >>/dev/null 2>>install.log) & spinner $!
(apt-get install -y snmp snmp-mibs-downloader >>/dev/null 2>>install.log) & spinner $!
echo -e "\r\033[K\e[36mInstalling SSHPASS and SNMP dependencies ----- Complete\e[0m"
