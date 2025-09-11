#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()    { echo -e "${YELLOW}ℹ️  $*${NC}"; }
success() { echo -e "${GREEN}✅ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $*${NC}"; }
error()   { echo -e "${RED}❌ $*${NC}"; }
step()    { echo -e "${BOLD}${YELLOW}--- $* ---${NC}"; }

step "Uninstalling Zsh/Powerlevel10k setup and related tools"

# 1. Remove Oh My Zsh directory
info "Removing Oh My Zsh directory..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    success "Oh My Zsh directory removed."
else
    warn "Oh My Zsh directory not found."
fi

# 2. Remove Zsh configuration files
info "Removing Zsh configuration files..."
ZSH_CONFIG_FILES=("$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zlogin" "$HOME/.p10k.zsh")
for file in "${ZSH_CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        success "Removed $file"
    else
        warn "$file not found."
    fi
done

# 3. Remove up.sh maintenance script
info "Removing up.sh maintenance script..."
if [ -f "$HOME/Documents/up.sh" ]; then
    rm -f "$HOME/Documents/up.sh"
    success "up.sh maintenance script removed."
else
    warn "up.sh maintenance script not found."
fi

# 4. Uninstall colorls (user gem)
info "Uninstalling colorls Ruby gem..."
# Ensure GEM_HOME and PATH are set correctly for user gems
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$GEM_HOME/bin"
if gem list -i colorls >/dev/null 2>&1; then
    if gem uninstall colorls; then # Removed -x and sudo
        success "colorls uninstalled."
    else
        error "Failed to uninstall colorls."
    fi
else
    warn "colorls gem not found."
fi

# 5. Uninstall fastfetch
info "Uninstalling fastfetch..."
if command -v fastfetch >/dev/null 2>&1; then
    # Assume it was installed via the curl installer which puts files in /usr/local
    if sudo rm -f /usr/local/bin/fastfetch && sudo rm -rf /usr/local/share/fastfetch; then
        success "fastfetch uninstalled."
    else
        error "Failed to remove fastfetch binaries. Manual removal may be needed."
    fi
else
    warn "fastfetch not found."
fi


# 6. Optionally restore default shell to bash
# Check if zsh is the current default shell before attempting to change
CURRENT_DEFAULT_SHELL=$(getent passwd "$USER" | awk -F: '{print $NF}')
if [ "$CURRENT_DEFAULT_SHELL" != "/bin/bash" ] && [ -f "/bin/bash" ]; then
    info "Restoring default shell to /bin/bash..."
    if chsh -s /bin/bash "$USER"; then # Specify user for chsh
        success "Default shell changed to /bin/bash."
        echo -e "${GREEN}Please log out and log in again for shell changes to take effect.${NC}"
    else
        error "Failed to change default shell to /bin/bash. You may need to do it manually."
    fi
else
    success "Default shell is already /bin/bash or /bin/bash not found."
fi

echo -e "${BOLD}${GREEN}✅ Uninstallation complete.${NC}"
echo -e "${BOLD}${GREEN}Note: Log out and log back in for shell changes to fully apply.${NC}"
