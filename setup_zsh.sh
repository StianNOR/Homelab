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
$INSTALL curl git zsh ruby ruby-devel gcc make || $INSTALL ruby ruby-dev gcc make

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

# ----- 8. Move up.sh to ~/Documents and set permissions -----
mkdir -p "$HOME/Documents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/up.sh" ]; then
    mv "$SCRIPT_DIR/up.sh" "$HOME/Documents/up.sh"
    chmod +x "$HOME/Documents/up.sh"
    echo "up.sh moved to $HOME/Documents and made executable."
else
    echo "ERROR: up.sh not found in $SCRIPT_DIR"
    exit 1
fi

# ----- 9. Copy .zshrc and .p10k.zsh from repo with error checking -----
REPO_ZSHRC="$SCRIPT_DIR/.zshrc"
DEST_ZSHRC="$HOME/.zshrc"
REPO_P10K="$SCRIPT_DIR/.p10k.zsh"
DEST_P10K="$HOME/.p10k.zsh"

echo "Attempting to copy $REPO_ZSHRC to $DEST_ZSHRC"
if [ -f "$REPO_ZSHRC" ]; then
  cp "$REPO_ZSHRC" "$DEST_ZSHRC"
  echo "SUCCESS: .zshrc copied to $DEST_ZSHRC"
else
  echo "ERROR: $REPO_ZSHRC not found. .zshrc was NOT copied."
  ls -l "$SCRIPT_DIR"
  exit 1
fi

if [ -f "$REPO_P10K" ]; then
  cp "$REPO_P10K" "$DEST_P10K"
  echo "SUCCESS: .p10k.zsh copied to $DEST_P10K"
else
  echo "No .p10k.zsh found in $SCRIPT_DIR. Skipping."
fi

# ----- 10. Change default shell to zsh if not already -----
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo "Default shell changed to zsh. Please log out and log in again for changes to take effect."
fi

echo "All Zsh plugins, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured!"
sleep 3
exec zsh
