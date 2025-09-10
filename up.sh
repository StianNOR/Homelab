#!/bin/bash

echo "Starting now!                                    " # Clear the line and add a final message

# --- End Countdown ---

echo "Starting system update and maintenance..."

# Detect package manager
if command -v nala &>/dev/null; then
    PM="nala"
elif command -v apt &>/dev/null; then
    PM="apt"
elif command -v dnf &>/dev/null; then
    PM="dnf"
elif command -v yum &>/dev/null; then
    PM="yum"
elif command -v pacman &>/dev/null; then
    PM="pacman"
elif command -v zypper &>/dev/null; then
    PM="zypper"
else
    echo "❌ No supported package manager found."
    exit 1
fi

# Update and upgrade system
echo "Updating package list and upgrading system..."
case "$PM" in
    nala)
        sudo nala update
        sudo nala upgrade -y
        sudo nala autoremove -y
        sudo nala clean
        ;;
    apt)
        sudo apt update
        sudo apt upgrade -y
        sudo apt autoremove -y
        sudo apt clean
        ;;
    dnf)
        sudo dnf upgrade --refresh -y
        sudo dnf autoremove -y
        sudo dnf clean all
        ;;
    yum)
        sudo yum update -y
        sudo yum autoremove -y
        sudo yum clean all
        ;;
    pacman)
        sudo pacman -Syu --noconfirm
        sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
        sudo pacman -Sc --noconfirm
        ;;
    zypper)
        sudo zypper refresh
        sudo zypper update -y
        sudo zypper clean --all
        ;;
esac

# Update flatpak packages if flatpak is installed
if command -v flatpak &>/dev/null; then
    echo "Updating Flatpak packages..."
    flatpak update -y
fi

# Update snap packages if snap is installed
if command -v snap &>/dev/null; then
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
if command -v updatedb &>/dev/null; then
    sudo updatedb
else
    if command -v apt &>/dev/null; then
        sudo apt install -y plocate || sudo apt install -y mlocate
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y plocate || sudo dnf install -y mlocate
    elif command -v yum &>/dev/null; then
        sudo yum install -y mlocate
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm mlocate
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y mlocate
    fi
    sudo updatedb
fi

echo "Update and maintenance process completed."
