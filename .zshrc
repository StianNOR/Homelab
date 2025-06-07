# ----- Powerlevel10k Instant Prompt (must be at the very top) -----
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----- Add Ruby gem user bin directory to PATH (cross-distro) -----
export PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"

# ----- Oh My Zsh and Theme -----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ----- Aliases -----
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

# ----- Welcome Message and Info (after prompt initialization) -----
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                 \x1b[32mWelcome Back $USER\x1b[0m                                                         |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo ""
command -v fastfetch >/dev/null && fastfetch
echo ""
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|                                                 \x1b[32mEnjoy here is your HomeDir\x1b[0m                                                    |"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"              
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "
command -v colorls >/dev/null && sls
echo " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── "

