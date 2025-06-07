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

    elif command -v dnf &>/dev/null && grep -q -i 'fedora' /etc/os-release; then
        # Fedora 41+ (use Fedora's own packages)
        sudo dnf install -y moby-engine docker-compose docker-compose-switch docker-buildx
        sudo systemctl enable --now docker

    elif command -v zypper &>/dev/null; then
        sudo zypper install -y docker
        sudo systemctl enable --now docker

    elif command -v apt &>/dev/null; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo systemctl enable --now docker

    elif command -v yum &>/dev/null; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl enable --now docker

    else
        echo "❌ No supported package manager found. Please install Docker manually."
        exit 1
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
