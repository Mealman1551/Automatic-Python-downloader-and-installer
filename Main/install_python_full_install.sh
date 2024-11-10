#!/bin/bash

# Check if the script is being run with root privileges for the installation of dependencies
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with root privileges. Re-run with 'sudo'."
    exit 1
fi

# Install required dependencies
echo "Installing dependencies..."
apt update -y
apt install -y build-essential zlib1g-dev libffi-dev libssl-dev libreadline-dev libbz2-dev libsqlite3-dev curl
if [ $? -ne 0 ]; then
    echo "Installation of dependencies failed. Check your internet connection or package manager settings."
    exit 1
fi

# Set the base URL for Python and the URL of the source page
PYTHON_BASE_URL="https://www.python.org/ftp/python"
LATEST_URL="https://www.python.org/ftp/python/"

# Get the latest version of Python from the source page
echo "Looking up the latest Python version..."
LATEST_VERSION=$(curl -s https://www.python.org/ | grep -oP '(?<=Python )\d+\.\d+\.\d+' | head -n 1)

# Check if the version was retrieved
if [ -z "$LATEST_VERSION" ]; then
    echo "Could not retrieve the latest Python version."
    exit 1
fi

echo "Latest Python version: $LATEST_VERSION"

# Download the source tarball
TARBALL="Python-$LATEST_VERSION.tgz"
DOWNLOAD_URL="$PYTHON_BASE_URL/$LATEST_VERSION/$TARBALL"

echo "Downloading $TARBALL..."
curl -O "$DOWNLOAD_URL"

# Check if the download was successful
if [ ! -f "$TARBALL" ]; then
    echo "Download failed. Check if the URL is correct or try again later."
    exit 1
fi

echo "Download completed: $TARBALL"

# Extract the tarball
echo "Extracting $TARBALL..."
tar -xzf "$TARBALL"
if [ $? -ne 0 ]; then
    echo "Extraction failed."
    exit 1
fi

# Go to the extracted directory
cd "Python-$LATEST_VERSION" || { echo "Cannot find directory Python-$LATEST_VERSION."; exit 1; }

# Configure Python
echo "Configuring..."
./configure --enable-optimizations
if [ $? -ne 0 ]; then
    echo "Configuration failed. Check if all required dependencies are correctly installed."
    exit 1
fi

# Build Python
echo "Building Python..."
make -j "$(nproc)"
if [ $? -ne 0 ]; then
    echo "Build failed. Check the output for more details."
    exit 1
fi

# Install Python
echo "Installing Python..."
make install
if [ $? -ne 0 ]; then
    echo "Installation failed. Check if you have sudo privileges."
    exit 1
fi

echo "Python $LATEST_VERSION has been successfully installed."

