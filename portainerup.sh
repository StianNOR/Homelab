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

# --- Detect Distribution ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_VERSION="$VERSION_ID"
else
    error "Cannot detect Linux distribution."
    exit 1
fi

# --- Install Docker and Docker Compose ---
install_docker() {
    step "Installing Docker for ${BOLD}$DISTRO_ID $DISTRO_VERSION${RESET}..."
    case "$DISTRO_ID" in
        ubuntu|debian|raspbian|linuxmint)
            info "Adding Docker repository and installing Docker..."
            sudo apt update
            sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl enable --now docker
            ;;
        fedora)
            info "Installing Docker from Fedora repositories..."
            sudo dnf remove -y podman-docker || true
            sudo dnf install -y moby-engine docker-cli containerd docker-buildx docker-compose docker-compose-switch
            sudo systemctl enable --now docker
            ;;
        centos|rhel|rocky|almalinux|ol|oracle)
            info "Adding Docker repository and installing Docker..."
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl enable --now docker
            ;;
        arch|manjaro|endeavouros|garuda|artix|arcolinux|antergos|chakra|kaos)
            info "Installing Docker with pacman (Arch-based)..."
            sudo pacman -Sy --noconfirm docker docker-compose
            sudo systemctl enable --now docker
            ;;
        opensuse*|suse|sles)
            info "Installing Docker with zypper..."
            sudo zypper install -y docker docker-compose
            sudo systemctl enable --now docker
            ;;
        alpine)
            info "Installing Docker with apk..."
            sudo apk add --update docker docker-compose
            sudo rc-update add docker boot
            sudo service docker start
            ;;
        *)
            error "Unsupported or unrecognized Linux distribution: $DISTRO_ID"
            exit 1
            ;;
    esac

    # Add user to docker group if not already
    if ! groups "$USER" | grep -qw docker; then
        sudo usermod -aG docker "$USER"
        warn "A new shell is needed for Docker group permissions."
        echo -e "${YELLOW}⏳ Waiting 3 seconds, then running 'newgrp docker'...${RESET}"
        sleep 3
        exec newgrp docker
    fi
}

# --- Main Logic ---
step "Checking for Docker..."
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Starting installation..."
    install_docker
else
    success "Docker is already installed."
fi

step "Checking for Docker Compose plugin..."
if ! docker compose version &>/dev/null; then
    warn "Docker Compose plugin not found. Attempting to install..."
    install_docker
else
    success "Docker Compose is already installed."
fi

step "Ensuring Docker service is running..."
if ! (sudo systemctl is-active --quiet docker 2>/dev/null || sudo service docker status 2>/dev/null | grep -q running); then
    info "Starting Docker service..."
    sudo systemctl start docker 2>/dev/null || sudo service docker start || true
else
    success "Docker service is running."
fi

step "Checking for existing Portainer container..."
if docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
    warn "Stopping and removing existing Portainer container..."
    docker stop portainer || true
    docker rm portainer || true
else
    info "No existing Portainer container found. Proceeding with installation."
fi

step "Pulling latest Portainer image..."
docker pull portainer/portainer-ce:latest

step "Starting Portainer container..."

if [[ "$DISTRO_ID" == "fedora" ]]; then
  docker run -d \
    --privileged \
    -p 8000:8000 -p 9443:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
else
  docker run -d \
    -p 8000:8000 -p 9443:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
fi

success "Portainer is now installed and running!"

# --- Display Portainer Dashboard Link ---
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$IP" ]; then
    IP="localhost"
fi

echo -e "${BOLD}${CYAN}🌐 Access your Portainer dashboard at:${RESET} ${GREEN}https://$IP:9443${RESET}"
echo -e "${YELLOW}Note: You may need to accept a self-signed certificate in your browser for HTTPS.${RESET}"
