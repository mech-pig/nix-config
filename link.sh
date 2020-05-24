#!/usr/bin/env sh

set -e
dir=$(pwd)

ln -fs "${dir}/configuration.nix" /etc/nixos/configuration.nix
