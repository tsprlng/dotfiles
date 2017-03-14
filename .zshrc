# Set up the prompt

autoload -Uz promptinit colors; promptinit; colors
setopt prompt_subst

export VIRTUAL_ENV_DISABLE_PROMPT=please

zsh_theme_pwd_string() {
	pwd
}
zsh_theme_ssh_prompt() {
	[ $SSH_CONNECTION ] && echo "%{$bg[yellow]%}%{$fg_bold[black]%}%M%{$reset_color%}:"
}
zsh_theme_rvm_venv() {
	if [ -f $HOME/.rvm/bin/rvm-prompt ]; then
		local rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null)
		[[ "${rvm_prompt}x" == "x" ]] || echo "%{$fg[grey]%} (${rvm_prompt})"
	fi
	if [[ "${VIRTUAL_ENV}x" == "x" ]]; then : ; else
		local comps=(${(@s:/:)VIRTUAL_ENV})
		local short_venv="${comps[-2]}/${comps[-1]}"
		echo "%{$fg[grey]%} (${short_venv} $($VIRTUAL_ENV/bin/python --version 2>&1 | grep -o '[0-9\.]*'))"
	fi
}
zsh_theme_ssh_agent() {
	/usr/bin/ssh-add -l >/dev/null 2>&1; local state=$?
	((( $state == 1 )) && echo -n " %{$fg[red]%}🔑") || ((( $state == 0 )) && echo -n " %{$fg[green]%}🔑")
}
git_prompt_info() {
	ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
	ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	echo -n " %{$fg[red]%}${ref#refs/heads/}"
	if [[ -z "$ZSH_SKIP_GIT_STATUS" ]]; then :; else return; fi
	stuff="$(timeout 1 git status --porcelain -unormal --ignore-submodules=dirty . || echo X)"  # TODO pipe
	if [[ "$stuff" == X ]]; then
		echo -n " %{$fg[yellow]%}X"; return
	fi
	if [[ -z "$stuff" ]]; then; return; fi
	echo -n ' '
	(echo "$stuff" | grep -vq '^??') && echo -n "%{$fg[yellow]%}Δ"
	(echo "$stuff" | grep -q '^??') && echo -n "%{$fg[yellow]%}?"
}

PROMPT='%{%(!.$fg[cyan].$fg[red])%}%(?..    %B(%?%)---^%b
)
$(zsh_theme_ssh_prompt)%{%(!.$fg_bold[red].$fg_bold[cyan])%}$(zsh_theme_pwd_string)%{$fg_bold[blue]%}$(git_prompt_info)$(zsh_theme_rvm_venv)
%{%(!.$fg_bold[red].$fg_bold[yellow])%}%D{%K.%M:%S}%b$(zsh_theme_ssh_agent) %{$fg_bold[yellow]%}>: %{$reset_color%}'

alias tiga="tig --all"
alias tigc="git compare"
alias gppf="git push --force-with-lease"
alias gpp="git push"
alias gp="git pull"
alias gpr="git pull -r"
alias gka="gitk --all&"
accept-line() {
	if [[ -z "$ZSH_SKIP_GIT_STATUS" ]]; then local restore=yes; fi
	ZSH_SKIP_GIT_STATUS=yes
	zle reset-prompt
	zle .$WIDGET
	if [[ -z "$restore" ]]; then :; else unset ZSH_SKIP_GIT_STATUS; fi
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
alias ssh-add='ssh-add -c ~/.ssh/id_ed25519 ~/.ssh/id_rsa'

alias g='git'
alias gs='git status -s'
alias gss='git status -s'
alias gd='git diff'
alias gdc='git diff --cached'
alias gpr='git pull --rebase'
alias gpp='git push'
alias gppf='git push --force-with-lease'
alias tiga='tig --all'

export VISUAL=vi
export EDITOR=vi
