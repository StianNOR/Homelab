# Disable Powerlevel10k instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

autoload -Uz compinit
compinit

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# Add Ruby gem path BEFORE Oh My Zsh initialization
export PATH="$PATH:$HOME/.gem/ruby/3.3.0/bin"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh

# User configuration

# Aliases - all home paths use $HOME for portability
alias up="$HOME/Documents/up.sh"
alias p10="p10k configure"
alias fresh='source ~/.zshrc'
alias clear='clear && source ~/.zshrc'
alias sls='colorls'
alias ls='colorls'
alias ls='colorls -d'
alias ll='colorls -l'
alias la='colorls -a'
#alias fix="mv ~/.zsh_history ~/.zsh_history_bad && strings ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history && rm ~/.zsh_history_bad"

# Welcome message
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
