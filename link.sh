#!/usr/bin/env sh

set -e
dir=$(pwd)

ln -fs "${dir}/configuratio.nix" /etc/nixos/configuration.nix
