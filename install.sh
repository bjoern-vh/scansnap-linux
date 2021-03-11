#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "You must run this script as root"
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    echo "This script only runs on debian-based systems."
fi

# Declare needed variables and constants
REPO="https://github.com/bjoern-vh/scansnap-linux"
DRIVER_PATH="/usr/share/sane/epjitsu"
APT_UPDATE=0
declare -A SCANNERS
install_pkgs=
model=

# Check for needed non existing packages
function sane_install()
{
    echo "Searching for missing packages..."
    check_pkg sane
    check_pkg sane-utils
    check_pkg libsane-extras
    pkg_install
}

function pkg_install()
{
    if [ "$install_pkgs" != "" ]; then
        echo "This new packages will be installed:$install_pkgs"
        read -r -p "Is this ok? [y|N] " response
        echo
        response=${response,,}
        if [[ ! $response =~ ^(yes|y) ]]; then
            echo "No changes were made"
            exit 0
        fi
        if [ "$APT_UPDATE" -ne "1" ]; then
            apt update -qq || (echo "Package lists could not be updated"; exit 1)
        fi
        APT_UPDATE=1
	apt install "$install_pkgs" -qq || (echo "An error occurs while package installation."; exit 1)
        install_pkgs=
    else
        echo "No new packages must be installed and all requirements are met."
    fi
}

# Check packages and add missing ones
function check_pkg()
{
    dpkg -s "$1" > /dev/null 2>&1
    if [ "$?" -ne "0" ]; then
        install_pkgs="$install_pkgs $1"
    else
        echo "Package '$1' is already installed."
    fi
}

# Define supported scanner models
function define_scanners()
{
    SCANNERS[1300]="1300_0C26"
    SCANNERS[1300i]="1300i_0D12"
    SCANNERS[300]="300_0C00"
    SCANNERS[300M]="300_0C00"
    SCANNERS[1100]="1000_0A00"
}

function appendIfMissing()
{
    f1=$(wc -c < "$1")
    diff  -y <(od -An -tx1 -w1 -v "$1") <(od -An -tx1 -w1 -v "$2") | \
    rev | cut -f2 | uniq -c | grep -v '[>|]' | numgrep /${f1}../ | \
    grep -q -m1 '.+*' || cat "$1" >> "$2";
}

define_scanners
sane_install

echo "Detecting scanner model..."
model=$(sane-find-scanner | grep -ioP '(?<=\[ScanSnap S)\d+i?(?=\])')

if [ "$model" == "" ]; then
    echo "No compatible scanner could be found"
    exit 1
fi

echo "Scanner ScanSnap S$model is detected."

if [ ! -d "$DRIVER_PATH" ]; then
    mkdir -p "$DRIVER_PATH"
    if [ "$?" -ne "0" ]; then
        echo "Error when creating required directory. ($?)"
        exit 1
    fi
fi

driver='drivers/S'${SCANNERS[$model]}'.nal'

if [ ! -f "$driver" ]; then
    install_pkgs="wget"
    check_pkg
    pkg_install
    wget -q "$REPO/raw/main/drivers/$driver" -O "$DRIVER_PATH/$driver"
else
    cp "$driver" "$DRIVER_PATH/"
fi

setting='settings/S'${SCANNERS[$model]'.conf"

if [ ! -f "$setting" ]; then
    setting="/tmp/${SCANNERS[$model]}.conf"
    wget -q "$REPO/raw/main/settings/$setting" -O "$setting"
    appendIfMissing "$setting" /etc/sane.d/epjitsu.conf
    rm "$setting"
else
    appendIfMissing "$setting" /etc/sane.d/epjitsu.conf
fi

adduser $USER scanner || echo "Could not add user to the group scanner" & exit 1

product_id=$(grep 0x "$setting" | cut -d" " -f3)

if [ "$product_id" == "" ]; then
    echo "Could not detect the product id"
    exit 1
fi

echo "ATTRS{idVendor}==\"04c5\", ATTRS{idProduct}==\"$product_id\", MODE=\"0664\", GROUP=\"scanner\", ENV{libsane_matched}=\"yes\"" >> /etc/udev/rules.d/99-local.rules || (echo "Could not create UDEV-rules"; exit 1)

chmod 744 $DRIVER_PATH/* || (echo "Could not set the correct permissions for the driver files"; exit 1)

echo "Installation is done. You have to reboot before you can use your scanner."

exit 0
