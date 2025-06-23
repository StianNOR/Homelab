#!/bin/bash
set -e
set -o pipefail # Ensures script exits on any command failure in a pipeline

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
  local last_command="$BASH_COMMAND"
  error "Script failed at line $LINENO. Last command: '$last_command'"
  warn "Please review the error message. It might be a network issue, missing permissions, or a package problem."
  warn "If on Arch/Manjaro, check pacman locks and mirrors. If on Ubuntu/Debian, check apt sources and network."
  exit 1
}' ERR

# --- Configuration ---
# List of plugins and their GitHub URLs
declare -A ZSH_PLUGINS=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions"
)

# --- Functions ---

confirm() {
  local prompt="$1"
  while true; do
    read -rp "${YELLOW}$prompt (y/N): ${RESET}" yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo -e "${RED}Please answer yes or no.${RESET}";;
    esac
  done
}

install_fastfetch() {
  step "Installing fastfetch..."
  # It's safer to download the script first and then execute it,
  # allowing for inspection if desired, rather than direct curl | bash.
  local installer_url="https://alessandromrc.github.io/fastfetch-installer/installer.sh"
  local installer_path="/tmp/fastfetch_installer.sh"

  info "Downloading fastfetch installer from $installer_url..."
  if ! curl -sSL "$installer_url" -o "$installer_path"; then
    error "Failed to download fastfetch installer."
    return 1
  fi

  chmod +x "$installer_path"
  info "Running fastfetch installer..."
  if ! sudo "$installer_path"; then
    error "fastfetch installation failed."
    rm -f "$installer_path" # Clean up
    return 1
  fi
  rm -f "$installer_path" # Clean up
  success "fastfetch installed."
  return 0
}

# ----- 1. Initial Checks & Permissions -----
step "Starting setup script..."
if [[ "$EUID" -eq 0 ]]; then
  error "This script should NOT be run with 'sudo'. It will prompt for sudo when necessary."
  exit 1
fi

# ----- 2. Detect package manager -----
step "Detecting package manager..."
PM=""
UPDATE=""
INSTALL=""
CLEAN=""
AUTOREMOVE=""

if command -v apt >/dev/null 2>&1; then
    PM="apt"
    UPDATE="sudo apt update"
    INSTALL="sudo apt install -y"
    CLEAN="sudo apt clean"
    AUTOREMOVE="sudo apt autoremove -y"
elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
    UPDATE="sudo dnf check-update || true" # check-update returns non-zero if no updates, hence || true
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
elif command -v apk >/dev/null 2>&1; then # Added for Alpine Linux
    PM="apk"
    UPDATE="sudo apk update"
    INSTALL="sudo apk add" # apk doesn't typically need -y, it prompts.
    CLEAN="sudo apk cache clean"
    AUTOREMOVE="echo 'apk handles autoremove implicitly when packages are removed.'" # No direct autoremove
else
    error "No supported package manager found."
    exit 1
fi
success "Detected package manager: ${BOLD}$PM${RESET}"

---
## 3. Install Dependencies

step "Updating package lists and installing dependencies..."
if ! $UPDATE; then
  error "Package manager update failed. Check your network, mirrors, and sudo permissions."
  exit 1
fi
success "Package manager updated."

# Common dependencies for Ruby/Zsh development
CORE_DEPENDENCIES="curl git zsh ruby gcc make"
RUBY_DEV_PACKAGE="" # Will be set conditionally
BUILD_TOOLS_PACKAGE="" # Will be set conditionally

# Adjust dependencies for specific package managers and systems
if [[ "$PM" == "pacman" ]]; then
    # Arch doesn't use ruby-dev; gcc, make are standalone
    REQUIRED_DEPENDENCIES="$CORE_DEPENDENCIES"
elif [[ "$PM" == "apk" ]]; then
    # Alpine specific: ruby-dev provides headers for Ruby gems,
    # libc-dev provides general C headers (like locale.h),
    # build-base provides standard build tools (compiler, make, etc.)
    RUBY_DEV_PACKAGE="ruby-dev"
    BUILD_TOOLS_PACKAGE="libc-dev build-base" # Important for building native Ruby gems
    REQUIRED_DEPENDENCIES="$CORE_DEPENDENCIES $RUBY_DEV_PACKAGE $BUILD_TOOLS_PACKAGE"
else
    # Default for deb/rpm based systems
    if [[ "$PM" == "dnf" || "$PM" == "yum" ]]; then
        RUBY_DEV_PACKAGE="ruby-devel" # RPM-based distros use ruby-devel
    else # apt, zypper
        RUBY_DEV_PACKAGE="ruby-dev"
    fi
    REQUIRED_DEPENDENCIES="$CORE_DEPENDENCIES $RUBY_DEV_PACKAGE"
fi

info "Attempting to install: ${BOLD}$REQUIRED_DEPENDENCIES${RESET}"
if ! $INSTALL $REQUIRED_DEPENDENCIES; then
  error "Dependency install failed. Check package manager output."
  exit 1
fi
success "Dependencies installed."

---
## 4. Update RubyGems and all gems

step "Updating RubyGems and all installed gems..."

# On Debian/Ubuntu, gem system update is disabled by default for safety
if [[ "$PM" == "apt" ]]; then
    warn "RubyGems system update is often managed by your distribution's package manager on Debian/Ubuntu."
    info "Skipping 'gem update --system' to avoid potential conflicts."
elif [[ "$PM" == "apk" ]]; then
    warn "RubyGems system update is often handled by 'apk upgrade ruby'. Skipping 'gem update --system'."
else
    if gem update --system; then
        success "RubyGems system updated."
    else
        warn "RubyGems system update failed or is not supported on this distribution. Continuing anyway."
    fi
fi

if gem update; then
    success "All installed gems updated."
else
    warn "Gem update failed. Some gems may not have been updated. Continuing anyway."
fi

---
## 5. Install colorls (user install, not sudo)

step "Checking for colorls Ruby gem..."

# Ensure RubyGems is in PATH for user gem install
export GEM_HOME="${GEM_HOME:-$HOME/.gem}" # Use existing GEM_HOME if set, otherwise default
export PATH="$PATH:$GEM_HOME/bin"

if ! gem list -i colorls >/dev/null 2>&1; then
    info "Installing colorls Ruby gem for your user..."
    if ! gem install --user-install colorls; then
      error "colorls install failed. Check Ruby/gem output. Ensure you have necessary build tools (gcc, make, ruby-dev/devel, libc-dev for Alpine)."
      exit 1
    fi
    success "colorls installed."
else
    success "colorls is already installed."
fi

# Add user gem bin dir to PATH in .zshrc if not present
USER_GEM_BIN="$(ruby -e 'puts Gem.user_dir')/bin"
if [ ! -d "$USER_GEM_BIN" ]; then
    warn "$USER_GEM_BIN does not exist. This might indicate an issue with RubyGems setup."
fi

# We'll handle .zshrc modification in a later step when copying the template.
# For now, ensure the current shell session has it.
info "Ensuring $USER_GEM_BIN is in current session PATH."
PATH="$PATH:$USER_GEM_BIN"

# Double-check colorls binary is available
if ! command -v colorls >/dev/null 2>&1; then
    warn "colorls binary still not found in current PATH. You may need to restart your shell or source your .zshrc."
fi

---
## 6. Install fastfetch

step "Checking for fastfetch..."
if ! command -v fastfetch >/dev/null 2>&1; then
    if ! install_fastfetch; then
        error "Fastfetch installation failed. Exiting."
        exit 1
    fi
else
    success "fastfetch is already installed."
fi

---
## 7. Install Oh My Zsh

step "Checking for Oh My Zsh..."
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    if confirm "Oh My Zsh is not installed. Do you want to install it?"; then
        info "Installing Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh" # Clean up any failed/partial installs
        # Use a more robust temporary file for the installer
        local omz_installer=$(mktemp)
        if ! curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$omz_installer"; then
            error "Failed to download Oh My Zsh installer."
            rm -f "$omz_installer"
            exit 1
        fi
        chmod +x "$omz_installer"

        # KEEP_ZSHRC=yes ensures we don't overwrite user's .zshrc yet
        # RUNZSH=no prevents it from switching to zsh immediately
        if ! RUNZSH=no KEEP_ZSHRC=yes "$omz_installer"; then
            error "Oh My Zsh install failed."
            rm -f "$omz_installer"
            exit 1
        fi
        rm -f "$omz_installer" # Clean up
        success "Oh My Zsh installed."
    else
        warn "Skipping Oh My Zsh installation."
    fi
else
    success "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

---
## 8. Install Powerlevel10k theme

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

---
## 9. Install Zsh plugins

step "Checking for Zsh plugins..."
for plugin_name in "${!ZSH_PLUGINS[@]}"; do
  plugin_url="${ZSH_PLUGINS[$plugin_name]}"
  plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"

  if [ ! -d "$plugin_dir" ]; then
    info "Installing plugin: ${BOLD}$plugin_name${RESET}"
    if ! git clone "$plugin_url" "$plugin_dir"; then
      error "Plugin $plugin_name install failed."
      exit 1
    fi
    success "Plugin $plugin_name installed."
  else
    success "Plugin $plugin_name is already installed."
  fi
done

---
## 10. Set up up.sh maintenance script

step "Setting up up.sh maintenance script..."
mkdir -p "$HOME/Documents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/up.sh" ]; then
    if confirm "Found 'up.sh' in the script's directory. Move it to $HOME/Documents and make it executable?"; then
        mv "$SCRIPT_DIR/up.sh" "$HOME/Documents/up.sh"
        chmod +x "$HOME/Documents/up.sh"
        success "up.sh moved to $HOME/Documents and made executable."
    else
        warn "Skipping moving 'up.sh'."
    fi
else
    warn "up.sh not found in $SCRIPT_DIR. Skipping."
fi

---
## 11. Copy .zshrc and .p10k.zsh from repo

step "Copying .zshrc and .p10k.zsh from repo..."
REPO_ZSHRC="$SCRIPT_DIR/.zshrc"
DEST_ZSHRC="$HOME/.zshrc"
REPO_P10K="$SCRIPT_DIR/.p10k.zsh"
DEST_P10K="$HOME/.p10k.zsh"

# Backup existing .zshrc
if [ -f "$DEST_ZSHRC" ]; then
  if confirm "A .zshrc file already exists at $DEST_ZSHRC. Do you want to back it up before overwriting?"; then
    cp "$DEST_ZSHRC" "${DEST_ZSHRC}.bak.$(date +%Y%m%d_%H%M%S)"
    success "Backed up existing .zshrc."
  else
    warn "Skipping backup of .zshrc."
  fi
fi

# Copy new .zshrc
if [ -f "$REPO_ZSHRC" ]; then
  cp "$REPO_ZSHRC" "$DEST_ZSHRC"
  success ".zshrc copied to $DEST_ZSHRC"
  # Append colorls path to .zshrc if not already there, after copying the main file
  if ! grep -q "$USER_GEM_BIN" "$DEST_ZSHRC"; then
    echo "export PATH=\"\$PATH:$USER_GEM_BIN\"" >> "$DEST_ZSHRC"
    info "Added \$GEM_HOME/bin to your PATH in .zshrc for colorls."
  else
    info "\$GEM_HOME/bin already present in .zshrc."
  fi
else
  warn "$REPO_ZSHRC not found. .zshrc was NOT copied. Please ensure it exists if you want your custom config."
  ls -l "$SCRIPT_DIR"
fi

# Copy .p10k.zsh
if [ -f "$REPO_P10K" ]; then
  if confirm "A .p10k.zsh file already exists at $DEST_P10K. Do you want to back it up before overwriting?"; then
    cp "$DEST_P10K" "${DEST_P10K}.bak.$(date +%Y%m%d_%H%M%S)"
    success "Backed up existing .p10k.zsh."
  else
    warn "Skipping backup of .p10k.zsh."
  fi
  cp "$REPO_P10K" "$DEST_P10K"
  success ".p10k.zsh copied to $DEST_P10K"
else
  warn "No .p10k.zsh found in $SCRIPT_DIR. Skipping. You may need to run p10k configure manually."
fi

---
## 12. Change default shell to zsh

step "Checking default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    if confirm "Your default shell is not zsh. Do you want to change it to zsh?"; then
        if chsh -s "$(which zsh)"; then
            info "Default shell changed to zsh. Please log out and log in again for changes to take effect."
        else
            warn "Could not change default shell. You may need to do it manually using 'chsh -s \$(which zsh)'."
        fi
    else
        warn "Skipping default shell change."
    fi
else
    success "zsh is already the default shell."
fi

---
## 13. Finalization

echo -e "${GREEN}${BOLD}
🎉 All Zsh components, Powerlevel10k, colorls, fastfetch, and up.sh are installed and configured! 🎉
${RESET}"
echo -e "${CYAN}To fully apply changes, please log out and log back in, or run 'exec zsh'.${RESET}"

# Instead of blindly executing zsh, inform the user.
# If they are in an interactive session, they can do it themselves.
# If the script is run non-interactively, `exec zsh` might hang.
# `exec zsh` is commented out to allow for a clean script exit.
# exec zsh
