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

# Prompt for sudo password upfront, so it caches for script duration
if ! sudo -v; then
    error "This script requires sudo privileges. Please run again with a sudo-capable user."
    exit 1
fi

# Keep-alive: update existing sudo time stamp until script is done
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
        warn "User '$USER' has been added to the 'docker' group."
        error "IMPORTANT: Docker group permissions will NOT be active in this current session."
        error "Please LOG OUT completely and LOG BACK IN (or open a NEW SSH/terminal session)."
        error "After re-logging in, please re-run this script: ./portainerup.sh"
        exit 1 # Exit immediately, user must re-login and re-run
    else
        success "User '$USER' is already in the 'docker' group."
        info "Current user groups: $(groups "$USER")"
    fi
}

# --- Main Logic ---
step "Checking for Docker..."
if ! command -v docker &>/dev/null; then
    warn "Docker not found. Starting installation..."
    install_docker # This call will install Docker and potentially exit if user added to group
else
    success "Docker is already installed."
fi

step "Verifying Docker daemon access permissions for current user..."
if ! docker info &>/dev/null; then
    error "Permission denied: Cannot connect to Docker daemon."
    error "Your user ('$USER') does not have correct permissions for Docker in this session."
    info "Current groups for user: $(groups $USER)"
    info "Docker socket permissions: $(ls -l /var/run/docker.sock 2>/dev/null || echo 'Socket not found')"
    error "Try running this command to refresh group membership in this terminal:"
    echo -e "${YELLOW}    newgrp docker${RESET}"
    error "Or LOG OUT completely and LOG BACK IN (or reboot the machine) then re-run this script."
    exit 1 # Exit, user must re-login and re-run for permissions to apply
else
    success "Docker daemon is accessible with current user permissions."
fi

step "Checking for Docker Compose plugin..."
if ! docker compose version &>/dev/null && ! command -v docker-compose &>/dev/null; then
    warn "Docker Compose (or plugin) not found. Attempting to install..."
    install_docker # This will install Docker Compose components if missing
else
    success "Docker Compose is already installed."
fi

step "Ensuring Docker service is running..."
if [[ "$DISTRO_ID" == "alpine" ]]; then
    if ! sudo service docker status 2>/dev/null | grep -q 'status: started'; then
        info "Starting Docker service..."
        sudo service docker start || true
    else
        success "Docker service is running."
    fi
else
    if ! sudo systemctl is-active --quiet docker; then
        info "Starting Docker service..."
        sudo systemctl start docker || true
    else
        success "Docker service is running."
    fi
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
