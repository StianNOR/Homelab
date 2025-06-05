#!/bin/bash

echo "Starting system update and maintenance..."

# Update package list and upgrade the system
echo "Updating package list and upgrading system..."
sudo nala update
sudo nala upgrade -y

# Clean the package cache
echo "Cleaning package cache..."
sudo nala clean

# Autoremove packages that are no longer needed
echo "Removing unnecessary packages..."
sudo nala autoremove -y

# Update flatpak packages if flatpak is installed
if command -v flatpak &> /dev/null; then
    echo "Updating Flatpak packages..."
    flatpak update -y
fi

# Update snap packages if snap is installed
if command -v snap &> /dev/null; then
    echo "Updating Snap packages..."
    sudo snap refresh
fi

# Clean journal logs
echo "Cleaning journal logs..."
sudo journalctl --vacuum-time=7d

# Clean thumbnails cache
echo "Cleaning thumbnails cache..."
rm -rf ~/.cache/thumbnails/*

# Update locate database
echo "Updating locate database..."
if ! command -v locate &> /dev/null; then
    echo "locate command not found. Installing plocate..."
    sudo apt install -y plocate
fi
sudo updatedb

echo "Update and maintenance process completed."
