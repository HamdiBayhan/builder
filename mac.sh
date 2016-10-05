#!/usr/bin/env zsh

## Exit trap
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

## Check home bin
if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  fancy_echo "1111111111111111111"
fi

## Fancy echo
fancy_echo() {
  printf "\n%b\n" "$1"
}

## Zsh fix
if [[ -f /etc/zshenv ]]; then
  fancy_echo "Fixing OSX zsh environment bug ..."
    sudo mv /etc/{zshenv,zshrc}
fi

## Homebrew
fancy_echo "Installing Homebrew, a good OS X package manager ..."
  ruby <(curl -fsS https://raw.github.com/mxcl/homebrew/go)
  brew update

if ! grep -qs "recommended by brew doctor" ~/.zshrc; then
  fancy_echo "Put Homebrew location earlier in PATH ..."
    echo "\n# recommended by brew doctor" >> ~/.zshrc
    echo "export PATH='/usr/local/bin:$PATH'\n" >> ~/.zshrc
    source ~/.zshrc
    fancy_echo "22222222222222222222"
fi

## Oh my zsh
fancy_echo "Installing Oh my zsh, community-driven framework for managing your ZSH configuration ..."
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

## Redis
fancy_echo "Installing Redis, a good key-value database ..."
  brew install redis

## Mac companents
fancy_echo "Installing ImageMagick, to crop and resize images ..."
  brew install imagemagick

fancy_echo "Installing QT, used by Capybara Webkit for headless Javascript integration testing ..."
  brew install qt

fancy_echo "Installing watch, to execute a program periodically and show the output ..."
  brew install watch

## Rbenv

fancy_echo "Installing rbenv, to change Ruby versions ..."
  brew install rbenv
fancy_echo "****"
  if ! grep -qs "rbenv init" ~/.zshrc; then
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc
fancy_echo "----"
    fancy_echo "Enable shims and autocompletion ..."
      eval "$(rbenv init -)"
  fi
fancy_echo "===="
  
fancy_echo "&&&&"
# fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
#  brew install rbenv-gem-rehash

fancy_echo "Installing ruby-build, to install Rubies ..."
  brew install ruby-build

## Compoler and libraries
fancy_echo "Installing GNU Compiler Collection, a necessary prerequisite to installing Ruby ..."
  brew tap homebrew/dupes
  brew install apple-gcc42

fancy_echo "Upgrading and linking OpenSSL ..."
  brew install openssl

export CC=gcc-4.2

fancy_echo "Configuring Ruby ..."
find_latest_ruby() {
  rbenv install -l | grep -v - | tail -1 | sed -e 's/^ *//'
}

ruby_version="$(find_latest_ruby)"
# shellcheck disable=SC2016
append_to_zshrc 'eval "$(rbenv init - --no-rehash)"' 1
eval "$(rbenv init -)"

if ! rbenv versions | grep -Fq "$ruby_version"; then
  RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr/local/opt/openssl rbenv install -s "$ruby_version"
fi

rbenv global "$ruby_version"
rbenv shell "$ruby_version"
gem update --system
gem_install_or_update 'bundler'
number_of_cores=$(sysctl -n hw.ncpu)
bundle config --global jobs $((number_of_cores - 1))

if [ -f "$HOME/.laptop.local" ]; then
  fancy_echo "Running your customizations from ~/.laptop.local ..."
  # shellcheck disable=SC1090
  . "$HOME/.laptop.local"
fi
