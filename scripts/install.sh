#!/usr/bin/env bash
set -euo pipefail

# constants
readonly GITHUB_URL="github.com"
readonly USERNAME="iamnewton"
readonly REPO="dotlog"
readonly INSTALL_DIR="$HOME/.$REPO"
readonly DEST_DIR="/usr/local/bin"

# If missing, download and extract the dotfiles repository
if [[ ! -d "$INSTALL_DIR" ]]; then
	mkdir -p "$INSTALL_DIR"
	curl -#fLo "/tmp/$REPO.tar.gz" "https://$GITHUB_URL/$USERNAME/$REPO/tarball/main"
	tar -zxf "/tmp/$REPO.tar.gz" --strip-components 1 -C "$INSTALL_DIR"
	rm -rf "/tmp/$REPO.tar.gz"
fi

# Check for git, install if not, intialize and pull down repo
if command -v 'git' &>/dev/null; then
	# Change to the dotfiles directory
	cd "$INSTALL_DIR" || exit
	git init
	git branch -m main
	git remote add origin "https://$GITHUB_URL/$USERNAME/$REPO.git"
	git fetch origin main
	git reset --hard FETCH_HEAD
	git clean -fd
	git pull --rebase origin main
fi

# Shell init updates (idempotent)
if ! grep -Fq 'DOTLOG="$HOME/.dotlog/bin/dotlog"' ~/.bashrc 2>/dev/null; then
  echo 'export DOTLOG="$HOME/.dotlog/bin/dotlog"' >> ~/.bashrc
  echo 'source "$DOTLOG"' >> ~/.bashrc
  echo '✔ dotlog auto-sourced in .bashrc'
fi

if ! grep -Fq 'DOTLOG="$HOME/.dotlog/bin/dotlog"' ~/.zshrc 2>/dev/null; then
  echo 'export DOTLOG="$HOME/.dotlog/bin/dotlog"' >> ~/.zshrc
  echo 'source "$DOTLOG"' >> ~/.zshrc
  echo '✔ dotlog auto-sourced in .zshrc'
fi

if [[ "${SHELL:-}" == */zsh && -f ~/.zshrc ]]; then
  source ~/.zshrc
elif [[ "${SHELL:-}" == */bash && -f ~/.bashrc ]]; then
  source ~/.bashrc
elif [[ -f ~/.zshrc ]]; then
  source ~/.zshrc
elif [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi

echo "✅ $REPO successfully installed and ready to use!"
