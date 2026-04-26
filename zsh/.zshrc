# ------------------------------------------------------------
# Zsh: fast, fuzzy, and a little bit pretty.
# ------------------------------------------------------------

export EDITOR="${EDITOR:-micro}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="-R --use-color -Dd+r -Du+b"

# History that behaves like a good memory instead of a junk drawer.
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

# Friendlier completion.
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Useful shell behavior.
setopt auto_cd
setopt auto_pushd
setopt correct
setopt interactive_comments
setopt no_beep
setopt prompt_subst
setopt pushd_ignore_dups

bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Plugins.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# Fuzzy navigation.
if [[ -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border=rounded
    --prompt='  '
    --pointer=''
    --marker=''
    --color=fg:#f2e9e1,bg:#191724,hl:#ebbcba
    --color=fg+:#f2e9e1,bg+:#26233a,hl+:#eb6f92
    --color=border:#31748f,gutter:#191724,header:#9ccfd8
    --color=info:#c4a7e7,prompt:#f6c177,pointer:#eb6f92
    --color=marker:#a6e3a1,spinner:#9ccfd8
  "

  if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  else
    source <(fzf --zsh)
  fi
fi

# Make normal Tab completion fuzzy instead of only using fzf after **<Tab>.
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border=rounded
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -A $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath} 2>/dev/null | head -200'
zinit light Aloxaf/fzf-tab

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Small comforts.
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ls='eza --icons'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias please='sudo'
alias reload='source ~/.zshrc'
