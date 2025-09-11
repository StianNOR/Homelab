#!/bin/bash
set -e
set -o pipefail

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

# --- Global error trap for fail-safe ---
trap '{
  error "Script failed at line $LINENO. Last command: $BASH_COMMAND"
  warn "Try running the failed command manually, or check your package manager and sudo configuration."
  warn "If on Arch/Manjaro, check pacman locks and mirrors. If on Ubuntu/Debian, check apt sources and network."
  exit 1
}' ERR

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
    ORPHANS="$(pacman -Qtdq 2>/dev/null || true)"
    if [[ -n "$ORPHANS" ]]; then
        AUTOREMOVE="sudo pacman -Rns $ORPHANS --noconfirm"
    else
        AUTOREMOVE="echo 'No orphaned packages to remove.'"
    fi
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
success "Detected package manager: $PM"

# ----- 2. Install zsh if missing -----
step "Ensuring zsh is installed..."
if ! command -v zsh >/dev/null 2>&1; then
    info "zsh not found, installing..."
    if ! $INSTALL zsh; then
        error "Failed to install zsh."
        exit 1
    fi
    success "zsh installed."
else
    success "zsh is already installed."
fi

# ----- 3. Install dependencies -----
step "Updating package lists and installing dependencies..."
if ! $UPDATE; then
  error "Package manager update failed. Check your network, mirrors, and sudo permissions."
  exit 1
fi
success "Package manager updated."

if [[ "$PM" == "pacman" ]]; then
    if ! $INSTALL curl git ruby gcc make; then
      error "Dependency install failed. Check pacman output."
      exit 1
    fi
else
    if ! $INSTALL curl git ruby ruby-devel gcc make && ! $INSTALL ruby ruby-dev gcc make; then
      error "Dependency install failed. Check package manager output."
      exit 1
    fi
fi
success "Dependencies installed."

# ----- 4. Update RubyGems and all gems -----
step "Updating RubyGems and all installed gems..."
if [[ "$PM" == "apt" ]]; then
    warn "RubyGems system update is disabled on Debian/Ubuntu. Use apt to update rubygems if needed."
else
    if gem update --system; then
        success "RubyGems system updated."
    else
        warn "RubyGems system update failed or is not supported on this distribution."
    fi
fi

if gem update; then
    success "All installed gems updated."
else
    warn "Gem update failed. Some gems may not have been updated."
fi

# ----- 5. Install colorls (user install, not sudo) -----
step "Checking for colorls Ruby gem..."
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$GEM_HOME/bin"

if ! gem list -i colorls >/dev/null 2>&1; then
    info "Installing colorls Ruby gem for your user..."
    if ! gem install --user-install colorls; then
      error "colorls install failed. Check Ruby/gem output."
      exit 1
    fi
    success "colorls installed."
else
    success "colorls is already installed."
fi

USER_GEM_BIN="$(ruby -e 'puts Gem.user_dir')/bin"
if ! grep -q "$USER_GEM_BIN" "$HOME/.zshrc"; then
  echo "export PATH=\"\$PATH:$USER_GEM_BIN\"" >> "$HOME/.zshrc"
  info "Added $USER_GEM_BIN to your PATH in .zshrc"
fi

if ! command -v colorls >/dev/null 2>&1; then
    warn "colorls binary not found in PATH. You may need to restart your shell or source your .zshrc."
fi

# ----- 6. Install fastfetch -----
step "Checking for fastfetch..."
if ! command -v fastfetch >/dev/null 2>&1; then
    info "fastfetch not found in PATH. Trying to install via package manager..."
    if $INSTALL fastfetch; then
        success "fastfetch installed via package manager."
    else
        warn "Fastfetch package install failed or not available in your repo."
        echo -e "${YELLOW}Please install fastfetch manually and then re-run this script.${RESET}"
        exit 1
    fi
else
    success "fastfetch is already installed."
fi

# ----- 7. Install Oh My Zsh -----
step "Checking for Oh My Zsh..."
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    info "Installing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    if ! RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
      error "Oh My Zsh install failed."
      exit 1
    fi
    success "Oh My Zsh installed."
else
    success "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ----- 8. Install Powerlevel10k theme -----
step "Checking for Powerlevel10k theme..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k theme..."
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"; then
      error "Powerlevel10k install failed."
      exit 1
    fi
    success "Powerlevel10k installed."
else
    success "Powerlevel10k theme is already installed."
fi

# ----- 9. Install plugins -----
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
    if ! git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"; then
      error "Plugin $plugin install failed."
      exit 1
    fi
    success "Plugin $plugin installed."
  else
    success "Plugin $plugin is already installed."
  fi
done

# ----- 10. Copy .zshrc and .p10k.zsh from repo with error checking -----
step "Copying .zshrc and .p10k.zsh from repo..."
SCRIPT_DIR="$HOME/Homelab"
REPO_ZSHRC="$SCRIPT_DIR/.zshrc"
DEST_ZSHRC="$HOME/.zshrc"
REPO_P10K="$SCRIPT_DIR/.p10k.zsh"
DEST_P10K="$HOME/.p10k.zsh"

if [ -f "$REPO_ZSHRC" ]; then
  cp "$REPO_ZSHRC" "$DEST_ZSHRC"
  success ".zshrc copied to $DEST_ZSHRC"
else
  warn "$REPO_ZSHRC not found. .zshrc was NOT copied."
  ls -l "$SCRIPT_DIR"
fi

if [ -f "$REPO_P10K" ]; then
  cp "$REPO_P10K" "$DEST_P10K"
  success ".p10k.zsh copied to $DEST_P10K"
else
  warn "No .p10k.zsh found in $SCRIPT_DIR. Skipping."
fi

# ----- 11. Change default shell to zsh if not already -----
step "Checking default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  if chsh -s "$(which zsh)"; then
    info "Default shell changed to zsh. Please log out and log in again for changes to take effect."
  else
    warn "Could not change default shell. You may need to do it manually."
  fi
else
  success "zsh is already the default shell."
fi

echo -e "${GREEN}${BOLD}
🎉 All Zsh plugins, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured! 🎉
${RESET}"

echo -e "${CYAN}The up.sh script is now located in: ~/Homelab/up.sh${RESET}"
echo -e "${CYAN}Refreshing your shell in 3 seconds...${RESET}"
sleep 3
exec zsh
