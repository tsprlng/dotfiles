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


mkdir -p .ssh/sockets
chmod 700 .ssh/sockets

# git+shell basics
install zsh git tig

grep -q "$(whoami).*zsh" /etc/passwd || sudo chsh -s /usr/bin/zsh "$USER"

git config --global push.default simple
git config --global core.excludesFile ~/.cvsignore
git config --get user.name >/dev/null || git config --global user.name 'Tom Spurling'
if ! git config --get user.email >/dev/null; then
	read -e -p 'Default email for Git?: ' -i 'tom@' GIT_EMAIL
	git config --global user.email "$GIT_EMAIL"
fi

# necessary utils for life
install htop vim-nox tree moreutils

# less necessary but nice to have
install jq aptitude inotify-tools entr
