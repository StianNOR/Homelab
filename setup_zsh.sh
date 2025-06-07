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

# ----- 1. Detect package manager -----
step "Detecting package manager..."
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
    error "No supported package manager found."
    exit 1
fi

# ----- 2. Install dependencies -----
step "Updating package lists and installing dependencies..."
$UPDATE
if [[ "$PM" == "pacman" ]]; then
    $INSTALL curl git zsh ruby gcc make
else
    $INSTALL curl git zsh ruby ruby-devel gcc make || $INSTALL ruby ruby-dev gcc make
fi

# ----- 3. Install colorls (user install, not sudo) -----
step "Checking for colorls..."
if ! gem list -i colorls >/dev/null 2>&1; then
    info "Installing colorls Ruby gem for your user..."
    gem install --user-install colorls
else
    success "colorls is already installed."
fi

# Add user gem bin dir to PATH in .zshrc if not present
USER_GEM_BIN="$(ruby -e 'puts Gem.user_dir')/bin"
if ! grep -q "$USER_GEM_BIN" "$HOME/.zshrc"; then
  echo "export PATH=\"\$PATH:$USER_GEM_BIN\"" >> "$HOME/.zshrc"
  info "Added $USER_GEM_BIN to your PATH in .zshrc"
fi

# ----- 4. Install fastfetch -----
step "Checking for fastfetch..."
if ! command -v fastfetch >/dev/null 2>&1; then
    info "Installing fastfetch..."
    curl -sSL https://alessandromrc.github.io/fastfetch-installer/installer.sh | sudo bash
else
    success "fastfetch is already installed."
fi

# ----- 5. Install Oh My Zsh -----
step "Checking for Oh My Zsh..."
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    info "Installing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    success "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ----- 6. Install Powerlevel10k theme -----
step "Checking for Powerlevel10k theme..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    success "Powerlevel10k theme is already installed."
fi

# ----- 7. Install plugins -----
step "Checking for Zsh plugins..."
declare -A plugins
plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!plugins[@]}"; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    info "Installing plugin: $plugin"
    git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
  else
    success "Plugin $plugin is already installed."
  fi
done

# ----- 8. Move up.sh to ~/Documents and set permissions -----
step "Setting up up.sh maintenance script..."
mkdir -p "$HOME/Documents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/up.sh" ]; then
    mv "$SCRIPT_DIR/up.sh" "$HOME/Documents/up.sh"
    chmod +x "$HOME/Documents/up.sh"
    success "up.sh moved to $HOME/Documents and made executable."
else
    error "up.sh not found in $SCRIPT_DIR"
    exit 1
fi

# ----- 9. Copy .zshrc and .p10k.zsh from repo with error checking -----
step "Copying .zshrc and .p10k.zsh from repo..."
REPO_ZSHRC="$SCRIPT_DIR/.zshrc"
DEST_ZSHRC="$HOME/.zshrc"
REPO_P10K="$SCRIPT_DIR/.p10k.zsh"
DEST_P10K="$HOME/.p10k.zsh"

if [ -f "$REPO_ZSHRC" ]; then
  cp "$REPO_ZSHRC" "$DEST_ZSHRC"
  success ".zshrc copied to $DEST_ZSHRC"
else
  error "$REPO_ZSHRC not found. .zshrc was NOT copied."
  ls -l "$SCRIPT_DIR"
  exit 1
fi

if [ -f "$REPO_P10K" ]; then
  cp "$REPO_P10K" "$DEST_P10K"
  success ".p10k.zsh copied to $DEST_P10K"
else
  warn "No .p10k.zsh found in $SCRIPT_DIR. Skipping."
fi

# ----- 10. Change default shell to zsh if not already -----
step "Checking default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  info "Default shell changed to zsh. Please log out and log in again for changes to take effect."
else
  success "zsh is already the default shell."
fi

echo -e "${GREEN}${BOLD}
🎉 All Zsh plugins, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured! 🎉
${RESET}"
echo -e "${CYAN}Refreshing your shell in 3 seconds...${RESET}"
sleep 3
exec zsh
