My [Nix/NixOS](https://nixos.org) configuration files. Still a work in progress.

## Prerequisites

- nixpkgs-20.03 (probably works for other versions as well)
- [home-manager](https://rycee.gitlab.io/home-manager/)


## Install as NixOS configuration
This configuration assumes the presence of a `hardware-configuration.nix` file in `/etc/nixos/` folder. This file can be generated automatically using the `nixos-generate-config` command, usually when installing NixOS for the first time, or it can be compiled by hand (see https://github.com/NixOS/nixos-hardware for pre-compiled, known-hardware configuration files).

Clone repository and submodules:

```sh
git clone --recursive https://github.com/mech-pig/nix-config.git
```

Remove any existing `/etc/nixos/configuration.nix` file and link the new configuration with:

```sh
sudo sh link.sh
```
