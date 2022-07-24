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

# # shellcheck disable=SC2016
# append_to_bashrc 'export PATH="$HOME/.bin:$PATH"'

# Determine Homebrew prefix
arch="$(uname -m)"
if [ "$arch" = "arm64" ]; then
  HOMEBREW_PREFIX="/opt/homebrew"
else
  HOMEBREW_PREFIX="/usr/local"
fi

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

fancy_echo "Configuring asdf version manager ..."
if [ ! -d "$HOME/.asdf" ]; then
  brew install asdf
  append_to_bashrc "source $(brew --prefix asdf)/asdf.sh" 1
fi

alias install_asdf_plugin=add_or_update_asdf_plugin
add_or_update_asdf_plugin() {
  local name="$1"
  local url="$2"

  if ! asdf plugin-list | grep -Fq "$name"; then
    asdf plugin-add "$name" "$url"
  else
    asdf plugin-update "$name"
  fi
}

# shellcheck disable=SC1090
. "$(brew --prefix asdf)/asdf.sh"
add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"

install_asdf_language() {
  local language="$1"
  local version
  version="$(asdf list-all "$language" | grep -v "[a-z]" | tail -1)"

  if ! asdf list "$language" | grep -Fq "$version"; then
    asdf install "$language" "$version"
    asdf global "$language" "$version"
  fi
}

fancy_echo "Installing latest Node ..."
install_asdf_language "nodejs"

if [ -f ".laptop.local" ]; then
  fancy_echo "Running your customizations from .laptop.local ..."
  # shellcheck disable=SC1090
  . ".laptop.local"
fi
