#!/bin/bash -e
cd ~

DF_BRANCH=$1
if [[ -z "$DF_BRANCH" ]]; then
	echo "WHAT BRANCH?"
	exit 4
fi

install() {
	sudo apt -qqy install "$@" 2>/dev/null | perl -p -e 's/^/  apt: /'
}


[[ -f ~/.ssh/id_ed25519 ]] || NEW_SSH_KEY=yes
if [[ ! -z "$NEW_SSH_KEY" ]]; then
	ssh-keygen -t ed25519 -a 200
fi
if [[ "$FORCE" =~ github || ! -z "$NEW_SSH_KEY" ]]; then
	curl -H 'Content-Type: application/json' --user tsprlng 'https://api.github.com/user/keys' -d "{\"title\": \"$(<~/.ssh/id_ed25519.pub perl -p -e 's/^.* //')\", \"key\":\"$(cat ~/.ssh/id_ed25519.pub)\"}"
fi

# git basics
install zsh git tig

git config --get user.name >/dev/null || git config --global user.name 'Tom Spurling'
if ! git config --get user.email >/dev/null; then
	read -e -p 'Default email for Git?: ' -i 'tom@' GIT_EMAIL
	git config --global user.email "$GIT_EMAIL"
fi


# clone dotfiles repo
if [[ "$FORCE" =~ clone || ! -d .dotfiles.git ]]; then
	git clone https://github.com/tsprlng/dotfiles.git --bare --branch "$DF_BRANCH" .dotfiles.git
	GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ git reset
	echo '**' > ~/.dotfiles.git/info/exclude
fi


# necessary utils for life
install htop vim-nox tree


# graphical desktop crap
install i3 xbacklight parcellite

# stop nautilus being annoying and taking over the whole screen
dconf write /org/gnome/desktop/background/show-desktop-icons false || true
dconf write /org/gnome/desktop/background/draw-background false || true
