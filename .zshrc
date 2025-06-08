# ─── Ensure Ruby Gem Binaries Are in PATH ──────────────────────────────
# Handles all Ruby versions for user-installed gems like colorls
for dir in "$HOME/.gem/ruby/"*/bin ; do
  [[ -d $dir ]] && PATH="$PATH:$dir"
done
export PATH

# ─── Powerlevel10k Instant Prompt (Should stay close to the top) ───────
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

# ─── Plugins ──────────────────────────────────────────────────────────
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh

# ─── Aliases: Use colorls If Available, Fallback to ls ────────────────
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

# ─── User Aliases and Functions ───────────────────────────────────────
alias up="/home/$USER/Documents/up.sh"
alias p10="p10k configure"
alias fresh='source ~/.zshrc'
alias clear='clear && source ~/.zshrc'
#alias fix="mv ~/.zsh_history ~/.zsh_history_bad && strings ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history && rm ~/.zsh_history_bad"

# ─── Welcome Message and HomeDir Listing ──────────────────────────────
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                 \x1b[32mWelcome Back $USER\x1b[0m                                                         |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo ""
fastfetch
echo ""
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                 \x1b[32mEnjoy here is your HomeDir\x1b[0m                                                    |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "
sls
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "

# ─── Optional: Additional User Configuration ──────────────────────────
# export LANG=en_US.UTF-8
# export EDITOR='nvim'
# export MANPATH="/usr/local/man:$MANPATH"
# export ARCHFLAGS="-arch $(uname -m)"
# ZSH_CUSTOM=/path/to/new-custom-folder
# HIST_STAMPS="mm/dd/yyyy"
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' frequency 13

# End of .zshrc
