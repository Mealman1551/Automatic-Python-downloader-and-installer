# Automatic-Python-downloader-and-installer

## Overview

This script automates the process of installing the latest version of Python from source on an Ubuntu system. It includes steps to install required dependencies, download the latest Python source code, configure, build, and install Python.
Prerequisites

The script must be run with root privileges.
An internet connection is required to download dependencies and the Python source code.

## Usage

Save the script to a file, for example, install_python.sh.
Make the script executable:

    chmod +x install_python.sh

Run the script with root privileges:

    sudo ./install_python.sh

## Script Breakdown

Check for Root Privileges

The script first checks if it is being run with root privileges. If not, it exits with an error message.
```
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with root privileges. Re-run with 'sudo'."
    exit 1
fi
```
Install Dependencies

The script updates the package list and installs the required dependencies for building Python from source.

echo "Installing dependencies..."
apt update -y
apt install -y build-essential zlib1g-dev libffi-dev libssl-dev libreadline-dev libbz2-dev libsqlite3-dev curl
if [ $? -ne 0 ]; then
    echo "Installation of dependencies failed. Check your internet connection or package manager settings."
    exit 1
fi

Set URLs

The script sets the base URL for Python and the URL of the source page.

PYTHON_BASE_URL="https://www.python.org/ftp/python"
LATEST_URL="https://www.python.org/ftp/python/"

Get the Latest Python Version

The script retrieves the latest version of Python from the official Python website.

echo "Looking up the latest Python version..."
LATEST_VERSION=$(curl -s https://www.python.org/ | grep -oP '(?<=Python )\d+\.\d+\.\d+' | head -n 1)

if [ -z "$LATEST_VERSION" ]; then
    echo "Could not retrieve the latest Python version."
    exit 1
fi

echo "Latest Python version: $LATEST_VERSION"

Download the Source Tarball

The script downloads the source tarball for the latest Python version.

TARBALL="Python-$LATEST_VERSION.tgz"
DOWNLOAD_URL="$PYTHON_BASE_URL/$LATEST_VERSION/$TARBALL"

echo "Downloading $TARBALL..."
curl -O "$DOWNLOAD_URL"

if [ ! -f "$TARBALL" ]; then
    echo "Download failed. Check if the URL is correct or try again later."
    exit 1
fi

echo "Download completed: $TARBALL"

Extract the Tarball

The script extracts the downloaded tarball.

echo "Extracting $TARBALL..."
tar -xzf "$TARBALL"
if [ $? -ne 0 ]; then
    echo "Extraction failed."
    exit 1
fi

Configure Python

The script navigates to the extracted directory and configures Python with optimizations.

cd "Python-$LATEST_VERSION" || { echo "Cannot find directory Python-$LATEST_VERSION."; exit 1; }

echo "Configuring..."
./configure --enable-optimizations
if [ $? -ne 0 ]; then
    echo "Configuration failed. Check if all required dependencies are correctly installed."
    exit 1
fi

Build Python

The script builds Python using the number of available CPU cores.

echo "Building Python..."
make -j "$(nproc)"
if [ $? -ne 0 ]; then
    echo "Build failed. Check the output for more details."
    exit 1
fi

Install Python

The script installs Python using the altinstall method to avoid overwriting the default system Python.

echo "Installing Python..."
make altinstall
if [ $? -ne 0 ]; then
    echo "Installation failed. Check if you have sudo privileges."
    exit 1
fi

echo "Python $LATEST_VERSION has been successfully installed."

Notes

    The script uses curl to download the latest Python version and source tarball.
    The altinstall method is used to install Python to avoid overwriting the default system Python.
    The script exits with an error message if any step fails, providing guidance on what might have gone wrong.
