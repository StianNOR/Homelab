#!/bin/bash
set -e

# ----- 1. Detect package manager -----
if command -v apt >/dev/null 2>&1; then
    PM="apt"
    UPDATE="sudo apt update"
    INSTALL="sudo apt install -y"
    CLEAN="sudo apt clean"
    AUTOREMOVE="sudo apt autoremove -y"
elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
    UPDATE="sudo dnf check-update || true"
    INSTALL="sudo dnf install -y"
    CLEAN="sudo dnf clean all"
    AUTOREMOVE="sudo dnf autoremove -y"
elif command -v yum >/dev/null 2>&1; then
    PM="yum"
    UPDATE="sudo yum check-update || true"
    INSTALL="sudo yum install -y"
    CLEAN="sudo yum clean all"
    AUTOREMOVE="sudo yum autoremove -y"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    UPDATE="sudo pacman -Syu --noconfirm"
    INSTALL="sudo pacman -S --noconfirm"
    CLEAN="sudo pacman -Sc --noconfirm"
    AUTOREMOVE="sudo pacman -Rns $(pacman -Qtdq) --noconfirm || true"
elif command -v zypper >/dev/null 2>&1; then
    PM="zypper"
    UPDATE="sudo zypper refresh"
    INSTALL="sudo zypper install -y"
    CLEAN="sudo zypper clean"
    AUTOREMOVE="sudo zypper rm -u"
else
    echo "No supported package manager found."
    exit 1
fi

# ----- 2. Install dependencies -----
$UPDATE
$INSTALL curl git zsh ruby ruby-devel gcc make || $INSTALL ruby ruby-dev gcc make # handle ruby-dev/ruby-devel

# ----- 3. Install colorls -----
if ! gem list -i colorls >/dev/null 2>&1; then
    sudo gem install colorls
fi

# ----- 4. Install fastfetch -----
if ! command -v fastfetch >/dev/null 2>&1; then
    curl -sSL https://alessandromrc.github.io/fastfetch-installer/installer.sh | sudo bash
fi

# ----- 5. Install Oh My Zsh -----
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ----- 6. Install Powerlevel10k theme -----
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ----- 7. Install plugins -----
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

# ----- 8. Create up.sh maintenance script -----
mkdir -p "$HOME/Documents"

cat <<EOF > "$HOME/Documents/up.sh"
#!/bin/bash
echo "Starting system update and maintenance..."

# Update and upgrade system
echo "Updating and upgrading system..."
$UPDATE
if [[ "$PM" == "apt" || "$PM" == "dnf" || "$PM" == "yum" ]]; then
    $INSTALL
elif [[ "$PM" == "pacman" ]]; then
    sudo pacman -Syu --noconfirm
elif [[ "$PM" == "zypper" ]]; then
    sudo zypper update -y
fi

# Clean package cache
echo "Cleaning package cache..."
$CLEAN

# Autoremove
echo "Removing unnecessary packages..."
$AUTOREMOVE

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
if command -v journalctl &> /dev/null; then
    echo "Cleaning journal logs..."
    sudo journalctl --vacuum-time=7d
fi

# Clean thumbnails cache
echo "Cleaning thumbnails cache..."
rm -rf ~/.cache/thumbnails/*

# Update locate database
echo "Updating locate database..."
if ! command -v locate &> /dev/null; then
    if [[ "$PM" == "apt" ]]; then
        sudo apt install -y plocate
    elif [[ "$PM" == "dnf" || "$PM" == "yum" ]]; then
        sudo $PM install -y mlocate
    elif [[ "$PM" == "pacman" ]]; then
        sudo pacman -S --noconfirm mlocate
    elif [[ "$PM" == "zypper" ]]; then
        sudo zypper install -y mlocate
    fi
fi
sudo updatedb

echo "Update and maintenance process completed."
EOF

chmod +x "$HOME/Documents/up.sh"
echo "up.sh maintenance script created at \$HOME/Documents/up.sh"

# ----- 9. Copy .zshrc and .p10k.zsh from repo with error checking -----
REPO_ZSHRC="\$HOME/Homelab/.zshrc"
DEST_ZSHRC="\$HOME/.zshrc"
REPO_P10K="\$HOME/Homelab/.p10k.zsh"
DEST_P10K="\$HOME/.p10k.zsh"

echo "Attempting to copy \$REPO_ZSHRC to \$DEST_ZSHRC"
if [ -f "\$REPO_ZSHRC" ]; then
  cp "\$REPO_ZSHRC" "\$DEST_ZSHRC"
  echo "SUCCESS: .zshrc copied to \$DEST_ZSHRC"
else
  echo "ERROR: \$REPO_ZSHRC not found. .zshrc was NOT copied."
  ls -l "\$HOME/Homelab"
  exit 1
fi

if [ -f "\$REPO_P10K" ]; then
  cp "\$REPO_P10K" "\$DEST_P10K"
  echo "SUCCESS: .p10k.zsh copied to \$DEST_P10K"
else
  echo "No .p10k.zsh found in \$HOME/Homelab. Skipping."
fi

# ----- 10. Change default shell to zsh if not already -----
if [ "\$SHELL" != "\$(which zsh)" ]; then
  chsh -s "\$(which zsh)"
  echo "Default shell changed to zsh. Please log out and log in again for changes to take effect."
fi

echo "All Zsh plugins, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured!"
sleep 3
exec zsh
