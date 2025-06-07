#!/bin/bash
set -e

# ----- 1. Install Docker if missing -----
if ! command -v docker &>/dev/null; then
    echo "🐳 Docker not found. Installing Docker..."

    if command -v pacman &>/dev/null; then
        # Arch Linux
        sudo pacman -Sy --noconfirm docker
        sudo systemctl enable --now docker
    elif command -v apk &>/dev/null; then
        # Alpine Linux
        sudo apk add --update docker
        sudo rc-update add docker boot
        sudo service docker start
    else
        # Most other distros (Debian, Ubuntu, Fedora, CentOS, openSUSE, etc.)
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo systemctl enable --now docker || sudo service docker start || true
    fi

    # Add user to docker group for non-root usage
    sudo usermod -aG docker "$USER"
    echo "⚠️ Please log out and log back in, or run 'newgrp docker' to refresh group permissions."
    exit 0
fi

# ----- 2. Ensure Docker is running -----
if ! sudo systemctl is-active --quiet docker 2>/dev/null; then
    echo "🔧 Starting Docker service..."
    sudo systemctl start docker || sudo service docker start || true
fi

# ----- 3. Update or install Portainer -----
if docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
    echo "🔄 Stopping Portainer..."
    docker stop portainer || true
    echo "🧹 Removing old Portainer container..."
    docker rm portainer || true
else
    echo "ℹ️ Portainer is not currently installed. Proceeding with fresh installation."
fi

echo "🐳 Pulling latest Portainer image..."
docker pull portainer/portainer-ce:latest

echo "🚀 Starting Portainer container..."
docker run -d \
  -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo "✅ Portainer is now installed and running!"
