#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with root privileges. Re-run with 'sudo'."
    exit 1
fi

echo "Uninstalling Python build dependencies..."

DEPENDENCIES=(
    build-essential
    zlib1g-dev
    libffi-dev
    libssl-dev
    libreadline-dev
    libbz2-dev
    libsqlite3-dev
    curl
)

for PACKAGE in "${DEPENDENCIES[@]}"; do
    if dpkg -s "$PACKAGE" &> /dev/null; then
        echo "Removing $PACKAGE..."
        apt remove -y "$PACKAGE"
    else
        echo "$PACKAGE is not installed, skipping..."
    fi
done

echo "Cleaning up unused packages..."
apt autoremove -y

echo "All specified dependencies have been uninstalled."
