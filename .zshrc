fastfetch

alias ls='eza --icons --group-directories-first --color=always'
alias ll='eza -lh --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias la='eza -a --icons'
alias lla='eza -lha --icons --group-directories-first'
alias cd='z'
alias cl='clear'

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

autoload -Uz compinit promptinit 
compinit && promptinit

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/

typeset -U PATH path

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

bindkey '^[[3~' delete-char
export PATH=$PATH:~/.spicetify
