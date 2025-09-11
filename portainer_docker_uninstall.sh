#!/bin/bash
set -e
# --- Colors and Formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
info()    { echo -e "${CYAN}ℹ️  $*${RESET}"; }
success() { echo -e "${GREEN}✅ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $*${RESET}"; }
error()   { echo -e "${RED}❌ $*${RESET}"; }
step()    { echo -e "${BOLD}${BLUE}➤ $*${RESET}"; }

# Require sudo upfront
if ! sudo -v; then
    error "This script requires sudo privileges. Please run again with a sudo-capable user."
    exit 1
fi

step "Stopping Docker and Portainer containers/services..."

# Stop Portainer container if running
if docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
    info "Stopping Portainer container..."
    sudo docker stop portainer || true
    sudo docker rm portainer || true
else
    info "Portainer container not found."
fi

# Stop Docker service
info "Stopping Docker service..."
sudo systemctl stop docker || true

step "Removing Docker packages..."

# Detect distro to remove packages accordingly
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
else
    DISTRO_ID=""
fi

case "$DISTRO_ID" in
    ubuntu|debian|raspbian|linuxmint)
        sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker
        sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker
        ;;
    fedora)
        sudo dnf remove -y moby-engine docker-cli containerd docker-buildx docker-compose docker-compose-switch || true
        ;;
    centos|rhel|rocky|almalinux|ol|oracle)
        sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || true
        ;;
    arch|manjaro|endeavouros|garuda|artix|arcolinux|antergos|chakra|kaos)
        sudo pacman -Rns --noconfirm docker docker-compose
        ;;
    opensuse*|suse|sles)
        sudo zypper remove -y docker docker-compose
        ;;
    alpine)
        sudo apk del docker docker-compose
        ;;
    *)
        warn "Unsupported or unrecognized Linux distribution: $DISTRO_ID - skipping package removal"
        ;;
esac

step "Removing Docker data and configuration files..."

# Remove Docker directories and leftover files
sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker /etc/systemd/system/docker.service.d
sudo rm -rf ~/.docker

# Remove Docker group and socket if exist
sudo groupdel docker || true
sudo rm -f /var/run/docker.sock || true

step "Clean up completed."

success "Docker and Portainer have been uninstalled from this system."
