# Automatic Python Downloader and Installer

## Overview

This Bash script automates the installation of the latest version of Python from source on an Ubuntu-based system. The script handles the following steps:
1. Checks for root privileges.
2. Installs necessary build dependencies.
3. Retrieves and downloads the latest Python source tarball.
4. Configures, builds, and installs Python.

## Prerequisites

- **Root Privileges**: The script must be run with root privileges for installing dependencies.
- **Internet Connection**: Required to download dependencies and the Python source code.

---

## Usage

1. Save the script via the link down here `install_python.sh`.
 
[`install_python.sh`](https://github.com/Mealman1551/Automatic-Python-downloader-and-installer/releases/download/v1.0/install_python.sh)

   ```bash
   chmod +x install_python.sh
   ```
4. Run the script with root privileges:
   ```bash
   sudo ./install_python.sh
   ```

---

## Script Breakdown

### 1. Check for Root Privileges
The script first checks if it is being run as root, as root privileges are needed to install dependencies.

```bash
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with root privileges. Re-run with 'sudo'."
    exit 1
fi
```

### 2. Install Dependencies
The script updates the package list and installs the required dependencies for building Python from source.

```bash
echo "Installing dependencies..."
apt update -y
apt install -y build-essential zlib1g-dev libffi-dev libssl-dev libreadline-dev libbz2-dev libsqlite3-dev curl
if [ $? -ne 0 ]; then
    echo "Installation of dependencies failed. Check your internet connection or package manager settings."
    exit 1
fi
```

### 3. Set URLs
The script sets up the base URL for Python and the URL of the Python source page.

```bash
PYTHON_BASE_URL="https://www.python.org/ftp/python"
LATEST_URL="https://www.python.org/ftp/python/"
```

### 4. Get the Latest Python Version
The script retrieves the latest Python version by scraping the Python homepage.

```bash
echo "Looking up the latest Python version..."
LATEST_VERSION=$(curl -s https://www.python.org/ | grep -oP '(?<=Python )\d+\.\d+\.\d+' | head -n 1)

# Check if the version was retrieved
if [ -z "$LATEST_VERSION" ]; then
    echo "Could not retrieve the latest Python version."
    exit 1
fi

echo "Latest Python version: $LATEST_VERSION"
```

### 5. Download the Source Tarball
The script downloads the source tarball for the latest Python version.

```bash
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
```

### 6. Extract the Tarball
The script extracts the downloaded tarball.

```bash
echo "Extracting $TARBALL..."
tar -xzf "$TARBALL"
if [ $? -ne 0 ]; then
    echo "Extraction failed."
    exit 1
fi
```

### 7. Configure Python
The script navigates to the extracted directory and configures Python with optimizations.

```bash
cd "Python-$LATEST_VERSION" || { echo "Cannot find directory Python-$LATEST_VERSION."; exit 1; }

echo "Configuring..."
./configure --enable-optimizations
if [ $? -ne 0 ]; then
    echo "Configuration failed. Check if all required dependencies are correctly installed."
    exit 1
fi
```

### 8. Build Python
The script builds Python using all available CPU cores for faster compilation.

```bash
echo "Building Python..."
make -j "$(nproc)"
if [ $? -ne 0 ]; then
    echo "Build failed. Check the output for more details."
    exit 1
fi
```

### 9. Install Python
The script installs Python using `altinstall` to avoid overwriting the system’s default Python.

```bash
echo "Installing Python..."
make altinstall
if [ $? -ne 0 ]; then
    echo "Installation failed. Check if you have sudo privileges."
    exit 1
fi

echo "Python $LATEST_VERSION has been successfully installed."
```

### No altinstall but a full install?
Check out the script called 'install_python_full_install.sh' in: Main/install_python_full_install.sh for a full install.

Download source-code with this script: https://github.com/Mealman1551/Automatic-Python-downloader-and-installer/archive/refs/tags/v1.0.tar.gz

## Notes

- The script uses `curl` to retrieve the latest Python version and download the source tarball.
- `make altinstall` is used to install Python to avoid overwriting the default Python version on the system.
- If any step fails, the script exits with an error message to assist with troubleshooting.

