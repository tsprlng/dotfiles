#!/bin/bash -e
cd ~

DF_BRANCH=$1
if [[ -z "$DF_BRANCH" ]]; then
	echo "WHAT BRANCH?"
	exit 4
fi

install() {
	dpkg --get-selections "$@" | grep -v 'install$' || true
}


mkdir -p .ssh/sockets
chmod 700 .ssh/sockets

# git+shell basics
install zsh git tig

grep -q "$(whoami).*zsh" /etc/passwd || sudo chsh -s /usr/bin/zsh "$USER"

git config --global push.default simple
git config --global core.excludesFile ~/.cvsignore
git config --global rerere.enabled true
git config --global rebase.autoSquash true

git config --global alias.ignore '!git update-index --assume-unchanged'
git config --global alias.unignore '!git update-index --no-assume-unchanged'
git config --global alias.ignored '!git ls-files -v | grep ^[a-z]'

git config --get user.name >/dev/null || git config --global user.name 'Tom Spurling'
if ! git config --get user.email >/dev/null; then
	read -e -p 'Default email for Git?: ' -i 'tom@' GIT_EMAIL
	git config --global user.email "$GIT_EMAIL"
fi

# clone dotfiles repo
if [[ "$FORCE" =~ clone || ! -d .dotfiles.git ]]; then
       git clone https://github.com/tsprlng/dotfiles.git --bare --branch "$DF_BRANCH" .dotfiles.git
       GIT_DIR=~/.dotfiles.git GIT_WORK_TREE=~ git reset
       echo -e '/*\n!bin' > ~/.dotfiles.git/info/exclude
fi

# necessary utils for life
install htop vim-nox tree moreutils

# less necessary but nice to have
install jq aptitude inotify-tools entr
