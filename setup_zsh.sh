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

trap 'error "Script failed at line $LINENO"; exit 1' ERR

# ----- 1. Detect package manager -----
step "Detecting package manager..."
if command -v apt >/dev/null 2>&1; then
    PM="apt"
    UPDATE="sudo apt update"
    INSTALL="sudo apt install -y"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    UPDATE="sudo pacman -Syu --noconfirm"
    INSTALL="sudo pacman -S --noconfirm"
else
    error "Only apt/pacman supported"
    exit 1
fi
success "Detected: $PM"

# ----- 2. Install packages -----
step "Installing zsh and tools via $PM..."
$UPDATE
$INSTALL zsh git curl fastfetch  # remove distro plugin pkgs; OMZ will use git clones
success "Core packages installed."

# ----- 3. Install Oh My Zsh -----
step "Installing Oh My Zsh..."
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed."
else
    success "Oh My Zsh exists."
fi

# ensure ZSH_CUSTOM is set
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ----- 4. Install Powerlevel10k -----
step "Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
    success "Powerlevel10k installed."
else
    success "Powerlevel10k already present."
fi

# ----- 5. Install OMZ plugins properly -----
step "Installing zsh-autosuggestions and zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
success "Oh My Zsh plugins installed."

# ----- 6. Install colorls -----
step "Installing colorls..."
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$GEM_HOME/bin"
if ! gem list -i colorls >/dev/null 2>&1; then
    gem install --user-install colorls
    success "colorls installed."
else
    success "colorls already installed."
fi

# ----- 7. YOUR .zshrc (plugins BEFORE source) -----
step "Installing YOUR exact .zshrc..."
cat > "$HOME/.zshrc" << 'EOF'
# ─── Ensure Ruby Gem Binaries Are in PATH ──────────────────────────────
setopt nullglob
for dir in "$HOME/.gem/ruby/"*/bin ; do
  [[ -d $dir ]] && PATH="$PATH:$dir"
done
export PATH

#Root
sudo() {
  if [[ "$1" == "nano" ]]; then
    TERM=xterm command sudo nano "${@:2}"
  else
    command sudo "$@"
  fi
}

# ─── Powerlevel10k Instant Prompt ───────
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
autoload -Uz compinit
compinit
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh My Zsh and Theme Setup ────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── Plugins (NO zsh-completions) ──────────────────────────────────────
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# load Oh My Zsh AFTER defining plugins
source $ZSH/oh-my-zsh.sh

# ─── FIX 1: Make autosuggestions VISIBLE ───────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan,bold'

# ─── Aliases: Use colorls If Available ────────────────
if command -v colorls >/dev/null 2>&1; then
  alias ls='colorls -d'
  alias ll='colorls -l'
  alias la='colorls -a'
  alias sls='colorls'
else
  alias ls='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias la='ls -a --color=auto'
  alias sls='ls'
fi

# ─── User Aliases ───────────────────────────────────────
alias up="/home/$USER/Homelab/up.sh"
alias pup="/home/$USER/Homelab/portainerup.sh"
alias p10="p10k configure"
alias fresh='source ~/.zshrc'
alias clear='clear && source ~/.zshrc'
alias portainerup='bash /home/$USER/Homelab/portainerup.sh'
alias nano='TERM=xterm nano'
alias ali='grep '^alias' ~/.zshrc'

# ─── Welcome Message ──────────────────────────────
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                \x1b[32mWelcome Back My Master\x1b[0m                                                         |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo ""
fastfetch
echo ""
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                 \x1b[32mEnjoy, here is your HomeDir\x1b[0m                                                   |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "
sls
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "

export EDITOR="nano"
export VISUAL="nano"

[[ -f /home/stiannor/.dart-cli-completion/zsh-config.zsh ]] && . /home/stiannor/.dart-cli-completion/zsh-config.zsh || true
EOF

success "YOUR .zshrc installed with cyan autosuggestions!"

# ----- 8. Set zsh default -----
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    info "Set zsh as default shell. Log out/in."
fi

echo -e "${GREEN}${BOLD}🎉 DONE! Cyan autosuggestions work NOW.${RESET}"
exec zsh
