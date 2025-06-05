#!/bin/bash
set -e

# Ensure all required packages are installed
sudo apt update
sudo apt install -y curl git zsh ruby ruby-dev gcc make nala

# Install colorls if not present
if ! gem list -i colorls >/dev/null 2>&1; then
  sudo gem install colorls
fi

# Install fastfetch if not present
if ! command -v fastfetch >/dev/null 2>&1; then
  curl -sSL https://alessandromrc.github.io/fastfetch-installer/installer.sh | sudo bash
fi

# Install Oh My Zsh if not present or incomplete
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  rm -rf "$HOME/.oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Powerlevel10k theme if not present
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Install plugins if not present
declare -A plugins
plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!plugins[@]}"; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# Create Documents directory if it doesn't exist
mkdir -p /home/stiannor/Documents

# Create up.sh maintenance script
cat <<'EOF' > /home/stiannor/Documents/up.sh
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
EOF

# Make up.sh executable
chmod +x /home/stiannor/Documents/up.sh

# Copy .zshrc and .p10k.zsh from repo if present
if [ -f ./Homelab/.zshrc ]; then
  cp ./Homelab/.zshrc ~/.zshrc
  echo ".zshrc copied to home directory."
fi

if [ -f ./Homelab/.p10k.zsh ]; then
  cp ./Homelab/.p10k.zsh ~/.p10k.zsh
  echo ".p10k.zsh copied to home directory."
fi

# Change default shell to zsh if not already
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo "Default shell changed to zsh. Please log out and log in again for changes to take effect."
fi

echo "All Zsh plugins, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured!"

