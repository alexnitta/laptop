#!/bin/sh

# Welcome to the laptop script!
# Be prepared to turn your laptop (or desktop, no haters here)
# into an awesome development machine.

# shellcheck disable=SC3043

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

append_to_bashrc() {
  local text="$1" bashrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.bashrc.local" ]; then
    bashrc="$HOME/.bashrc.local"
  else
    bashrc="$HOME/.bashrc"
  fi

  if ! grep -Fqs "$text" "$bashrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$bashrc"
    else
      printf "\\n%s\\n" "$text" >> "$bashrc"
    fi
  fi
}

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.bashrc" ]; then
  touch "$HOME/.bashrc"
fi

# shellcheck disable=SC2016
append_to_bashrc 'export PATH="$HOME/.bin:$PATH"'

# Determine Homebrew prefix
arch="$(uname -m)"
if [ "$arch" = "arm64" ]; then
  HOMEBREW_PREFIX="/opt/homebrew"
else
  HOMEBREW_PREFIX="/usr/local"
fi

update_shell() {
  local shell_path;
  shell_path="$(command -v bash)"

  fancy_echo "Changing your shell to bash ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

case "$SHELL" in
  */bash)
    if [ "$(command -v bash)" != '/usr/local/bin/bash' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    append_to_bashrc "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\""

    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
fi

if brew list | grep -Fq brew-cask; then
  fancy_echo "Uninstalling old Homebrew-Cask ..."
  brew uninstall --force brew-cask
fi

fancy_echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151
brew bundle --file=- <<EOF

# Unix
brew "git"
brew "openssl"
brew "rcm"
brew "bash"

# GitHub
brew "gh"

# Programming language prerequisites and package managers
brew "libyaml" # should come after openssl
brew "coreutils"

EOF

fancy_echo "Installing Volta ..."
curl https://get.volta.sh | bash

fancy_echo "Installing Node ..."
volta install node

fancy_echo "Setting up dotfiles ..."
env RCRC=$PWD/dotfiles/rcrc rcup

if [ -f ".laptop.local" ]; then
  fancy_echo "Running your customizations from .laptop.local ..."
  # shellcheck disable=SC1090
  . ".laptop.local"
fi
