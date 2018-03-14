# Set up the prompt

autoload -Uz promptinit colors; promptinit; colors
setopt prompt_subst

export VIRTUAL_ENV_DISABLE_PROMPT=please

zsh_theme_date() {
	date -u +'%-H.%M:%S'  # this is so that the shell shows UTC timestamps (like a good logger) even on a desktop which has "local time" adjustments
}
zsh_theme_pwd() {
	pwd
}
zsh_theme_ssh() {
	[ $SSH_CONNECTION ] && echo "%{$bg[yellow]%}%{$fg_bold[black]%}%M%{$reset_color%}:"
}
zsh_theme_rvm_venv() {
	if [ -f $HOME/.rvm/bin/rvm-prompt ]; then
		local rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null)
		[[ -n "$rvm_prompt" ]] && echo "%{$fg[grey]%} (${rvm_prompt})"
	fi
	if [[ -n "$VIRTUAL_ENV" ]]; then
		local components=(${(@s:/:)VIRTUAL_ENV})
		local short_venv="${components[-2]}/${components[-1]}"
		echo "%{$fg[grey]%} (${short_venv} $($VIRTUAL_ENV/bin/python --version 2>&1 | grep -o '[0-9\.]*'))"
	fi
}
zsh_theme_ssh_agent() {
	/usr/bin/ssh-add -l >/dev/null 2>&1; local state=$?
	((( $state == 1 )) && echo -n " %{$fg[red]%}🔑") || ((( $state == 0 )) && echo -n " %{$fg[green]%}🔑")
}
zsh_theme_git() {
	local ref
	ref=$(command git symbolic-ref HEAD 2> /dev/null) \
		|| ref=$(command git rev-parse --short HEAD 2> /dev/null) \
		|| return
	echo -n " %{$fg[red]%}${ref#refs/heads/}"
	if [[ -z "$ZSH_SKIP_GIT_STATUS" ]]; then
		local stuff="$(timeout 1 git status --porcelain -unormal --ignore-submodules=dirty . 2>/dev/null || echo FAIL)"
		if [[ -n "$stuff" ]]; then
			echo -n " %{$fg[yellow]%}"
			if [[ "$stuff" == FAIL ]]; then echo -n "X"; else
				(echo "$stuff" | grep -vq '^??') && echo -n "Δ"
				(echo "$stuff" | grep -q '^??') && echo -n "?"
			fi
		fi
	fi
}

PROMPT='%{%(!.$fg[cyan].$fg[red])%}%(?..    %B(%?%)---^%b
)
$(zsh_theme_ssh)%{%(!.$fg_bold[red].$fg_bold[cyan])%}$(zsh_theme_pwd)$(zsh_theme_git)$(zsh_theme_rvm_venv)
%{%(!.$fg_bold[red].$fg_bold[yellow])%}$(zsh_theme_date)%b$(zsh_theme_ssh_agent) %{$fg_bold[yellow]%}>: %{$reset_color%}'

accept-line() {
	if [[ -z "$BUFFER" ]]; then
		zle reset-prompt
		return
	fi
	if [[ -z "$ZSH_SKIP_GIT_STATUS" ]]; then local restore=yes; fi
	ZSH_SKIP_GIT_STATUS=yes
	zle reset-prompt
	zle .$WIDGET
	if [[ -n "$restore" ]]; then unset ZSH_SKIP_GIT_STATUS; fi
}
zle -N accept-line
TRAPINT() {}

setopt autocd autopushd pushdignoredups
alias d='dirs -v'
for i in {1..20}; do; alias $i="cd ~$i"; done

bindkey -e  # Use emacs keybindings even if our EDITOR is set to vi
WORDCHARS=''  # I like being able to ^W path components one by one. By default this was: *?_-.[]~=/&;!#$%^(){}<>
bindkey "^[[1;5C" forward-word ; bindkey "^[[1;5D" backward-word  # ctrl-left and -right
stty stop undef start undef  # I find ^s "stop" behaviour very annoying

setopt histverify histreduceblanks histignorespace
setopt histignorealldups sharehistory extendedhistory appendhistory incappendhistory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

bindkey '^[[Z' reverse-menu-complete  # shift+tab apparently

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
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

dotfiles() {
	if [[ "$1" == 'tig' ]]; then
		GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ "$@"
	else
		GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ git "$@"
	fi
}
compdef dotfiles=git

ssh_bootstrap() {
	ssh -t $1 -- mkdir -p .dotfiles
	ssh -t $1 -- curl -L https://github.com/tsprlng/dotfiles/raw/homedir-server/.dotfiles/setup.sh -o .dotfiles/setup.sh
	ssh -t $1 -- chmod +x .dotfiles/setup.sh
	ssh -t $1 -- .dotfiles/setup.sh homedir-server
	ssh $1 -- grep -q '"dotfiles()\s*{"' .zshrc || (whence -f dotfiles | ssh $1 -- tee -a .zshrc)
}

ssh-add() {
	if [ -z "$*" ]; then
		ssh-add -c ~/.ssh/id_ed25519 ~/.ssh/velo_id_ed25519
	else
		command ssh-add "$@"
	fi
}

alias ls='ls --color=auto'
alias l='ls -al'
alias les='less'
alias lef='less +F'
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias less='less -R'  # color control chars allowed through
alias grep='grep --color=auto'
alias mux='pgrep -lfa "ssh.*\[mux\]" -u "$USER"'
alias gtypist='gtypist -wSbq'

alias g='git'
alias gs='git status -s'
alias gss='git status -s'
alias gd='git diff -D'
alias gdc='git diff -D --cached'
alias gp='git pull'
alias gpr='git pull --rebase'
alias gup='git update'
alias gmm='git mm'
alias gpp='git push'
alias gppf='git push --force-with-lease'
alias tiga='tig --all'
alias tigc='git tigc'
alias gka='gitk --all&'

alias ack-tf='ack **/*.tfstate.d(P:--ignore-dir:) --ignore-file "match:/.*\.tfstate/"'

alias boldaws='aws --profile bold'

alias n='i3-sensible-terminal . >/dev/null 2>&1'

export VISUAL=vi
export EDITOR=vi

export PATH="/home/tds/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

if [[ -x /usr/local/bin/aws_zsh_completer.sh ]]; then
	source /usr/local/bin/aws_zsh_completer.sh
fi

dotfiles status -s
hash -d vg=~/Documents/velo/git
