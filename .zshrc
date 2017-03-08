# Set up the prompt

autoload -Uz promptinit colors
promptinit; colors
setopt prompt_subst

zsh_theme_pwd_string() {
	pwd
}
zsh_theme_ssh_prompt() {
	[ $SSH_CONNECTION ] && echo "%{$bg[yellow]%}%{$fg_bold[black]%}%M%{$reset_color%}:"
}
zsh_theme_rvm() {}  # TODO copy oh-my-zsh
git_prompt_info() {
	ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	echo -n " %{$fg[red]%}${ref#refs/heads/}"
	stuff="$(timeout 1 git status --porcelain -unormal --ignore-submodules=dirty . || echo X)"  # TODO pipe
	if [[ "$stuff" == X ]]; then
		echo -n X; return
	fi
	if [[ -z "$stuff" ]]; then; return; fi
	echo -n ' '
	(echo "$stuff" | grep -vq '^??') && echo -n "%{$fg[yellow]%}Δ"
	(echo "$stuff" | grep -q '^??') && echo -n "%{$fg[yellow]%}?"
}

PROMPT='%{%(!.$fg[cyan].$fg[red])%}%(?..    %B(%?%)---^%b
)
$(zsh_theme_ssh_prompt)%{%(!.$fg_bold[red].$fg_bold[cyan])%}$(zsh_theme_pwd_string)%{$fg_bold[blue]%}$(git_prompt_info)$(zsh_theme_rvm)
%{%(!.$fg_bold[red].$fg_bold[yellow])%}%D{%K.%M:%S} >: %{$reset_color%}'

accept-line() {
	zle reset-prompt
	zle .$WIDGET
}
zle -N accept-line

setopt histignorealldups sharehistory autocd

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

dotfiles() {
	if [[ "$1" == 'tig' ]]; then
		(cd ~/.dotfiles.git/; "$@")
	else
		GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ git "$@"
	fi
}

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias less='less -R'  # color control chars allowed through
alias grep='grep --color=auto'

alias g='git'
alias gs='git status -s'
alias gss='git status -s'
