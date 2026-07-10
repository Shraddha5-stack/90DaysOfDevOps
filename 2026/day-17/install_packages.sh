#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
then
    echo "Please run this script as root."
    exit 1
fi

# List of packages
packages=("nginx" "curl" "wget")

# Loop through packages
for package in "${packages[@]}"
do
    if dpkg -s "$package" &> /dev/null
    then
        echo "$package is already installed."
    else
        echo "Installing $package..."
        apt update
        apt install -y "$package"
        echo "$package installed successfully."
    fi
done
