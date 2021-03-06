#!/bin/bash

mkdir -p ~/.vim/swapfiles
mkdir -p ~/.yankring

## OSX only steps

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Doing OSX install of yadm"

  # Brew can be fiddly, install separately:
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  hash brew 2>/dev/null || (echo "install brew first" && exit 1)

  if hash yadm 2>/dev/null; then
    echo "yadm appears to be installed"
  else
    brew tap TheLocehiliosan/yadm
    brew update
    brew install git yadm
  fi
fi

## Other OS

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  echo "Doing Debian install of yadm"

  if hash yadm 2>/dev/null; then
    echo "yadm appears to be installed"
  else
    echo "installing git"
    sudo apt-get install -y git

    echo "installing yadm"
    sudo apt-get install alien dpkg-dev debhelper build-essential

    VERSION="1.02-1"
    curl -fLO https://dl.bintray.com/thelocehiliosan/rpm/yadm-${VERSION}.noarch.rpm
    sudo alien -k yadm-${VERSION}.noarch.rpm
    sudo dpkg -i yadm_${VERSION}_all.deb
  fi
fi

# Have ensured that yadm is available
hash yadm 2>/dev/null || (echo "yadm install failed" && exit 1)

## Extra packages

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "getting some important extra brew packages"
  brew install zsh tmux vim ack
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  echo "installing some essential packages"
  sudo apt-get install -y zsh vim-nox tmux ack-grep
fi

## Clone dotfiles

ssh-add -L | grep "LjftvPmaEFl69GkxMDhWd9ctr" || (echo "SSH key not loaded" && exit 1)

# fresh clone if required
yadm clone git@bitbucket.org:baxnick/settings.git

# always checkout and update
yadm checkout -f && \
  yadm pull --rebase && \
  yadm submodule && \
  yadm submodule update --init --recursive && \
  yadm alt && \
  yadm perms

# Download Hub
if [ ! -e "$HOME/.bin/hub" ]; then
  HUB_VERSION=2.2.2
  HUB_DOWNLOAD_URL=https://github.com/github/hub/releases/download
  HUB_OS=hub-linux-amd64

  if [[ "$OSTYPE" == "darwin"* ]]; then
    HUB_OS=hub-darwin-amd64
  fi

  FULL_URL=${HUB_DOWNLOAD_URL}/v${HUB_VERSION}/${HUB_OS}-${HUB_VERSION}.tgz

  echo "Downloading Hub ${HUB_VERSION}"

  curl -fL ${FULL_URL} > /tmp/hub.tgz && \
    tar zxf /tmp/hub.tgz -C /tmp && \
    mv /tmp/${HUB_OS}-${HUB_VERSION}/bin/hub ~/.bin/hub

  rm -Rf /tmp/hub*
else
  echo "Hub exists."
fi
