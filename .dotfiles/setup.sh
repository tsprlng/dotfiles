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
	echo github key time
	curl -H 'Content-Type: application/json' --user tsprlng 'https://api.github.com/user/keys' -d "{\"title\": \"$(<~/.ssh/id_ed25519.pub perl -p -e 's/^.* //')\", \"key\":\"$(cat ~/.ssh/id_ed25519.pub)\"}"
fi

# git+shell basics
install zsh git tig

grep -q "$(whoami).*zsh" /etc/passwd || chsh -s /usr/bin/zsh

git config --global push.default simple
git config --global core.excludesFile ~/.cvsignore
git config --get user.name >/dev/null || git config --global user.name 'Tom Spurling'
if ! git config --get user.email >/dev/null; then
	read -e -p 'Default email for Git?: ' -i 'tom@' GIT_EMAIL
	git config --global user.email "$GIT_EMAIL"
fi


# clone dotfiles repo
if [[ "$FORCE" =~ clone || ! -d .dotfiles.git ]]; then
	git clone git@github.com:tsprlng/dotfiles.git --bare --branch "$DF_BRANCH" .dotfiles.git
	GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ git reset
	echo -e '/*\n!bin' > ~/.dotfiles.git/info/exclude
fi


# necessary utils for life
install htop vim-nox tree moreutils

# less necessary but nice to have
install jq aptitude inotify-tools entr


# graphical desktop crap
install i3 xbacklight parcellite xclip

# stop nautilus being annoying and taking over the whole screen
dconf write /org/gnome/desktop/background/show-desktop-icons false || true
dconf write /org/gnome/desktop/background/draw-background false || true

# gotta have my font
if [[ ! -f .fonts/FantasqueSansMono-Regular.ttf ]]; then
	mkdir -p .fonts
	curl -L https://github.com/belluzj/fantasque-sans/releases/download/v1.7.1/FantasqueSansMono.tar.gz -o /tmp/fantasque.tar.gz --fail
	tar -xvf /tmp/fantasque.tar.gz -C .fonts --wildcards \*.ttf
	rm /tmp/fantasque.tar.gz
fi

# make the mouse work
# sudo hciconfig hci0 sspmode 1
# sudo hciconfig hci0 down
# sudo hciconfig hci0 up
