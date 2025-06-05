#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${YELLOW}--- Uninstalling Zsh/Powerlevel10k setup and related tools ---${NC}"

# 1. Remove Oh My Zsh
echo -e "${YELLOW}Removing Oh My Zsh...${NC}"
rm -rf "$HOME/.oh-my-zsh"

# 2. Remove Zsh configuration files
echo -e "${YELLOW}Removing Zsh configuration files...${NC}"
rm -f "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zlogin" "$HOME/.p10k.zsh"

# 3. Remove up.sh maintenance script
echo -e "${YELLOW}Removing up.sh maintenance script...${NC}"
rm -f "$HOME/Documents/up.sh"

# 4. Uninstall colorls
echo -e "${YELLOW}Uninstalling colorls...${NC}"
sudo gem uninstall -x colorls || echo -e "${RED}colorls not found or already removed.${NC}"

# 5. Uninstall fastfetch
echo -e "${YELLOW}Uninstalling fastfetch...${NC}"
sudo rm -f /usr/local/bin/fastfetch
sudo rm -rf /usr/local/share/fastfetch

# 6. Uninstall nala
echo -e "${YELLOW}Uninstalling nala...${NC}"
sudo apt remove --purge -y nala

# 7. Optionally restore default shell to bash
if [ "$SHELL" != "/bin/bash" ]; then
  echo -e "${YELLOW}Restoring default shell to bash...${NC}"
  chsh -s /bin/bash
  echo -e "${GREEN}Default shell changed to bash. Please log out and log in again for changes to take effect.${NC}"
fi

echo -e "${BOLD}${GREEN}Uninstallation complete. Your environment is clean.${NC}"
