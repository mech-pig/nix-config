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

Finally, activate the configuration:
```sh
sudo nixos-rebuild switch
```


## Warnings

Some things are not working as expected:
- firefox extensions are not loaded, probably because of https://github.com/rycee/home-manager/issues/1216
- [`standardnotes`](https://github.com/NixOS/nixpkgs/tree/nixos-20.03/pkgs/applications/editors/standardnotes) app crashes on start because of a segmentation fault


## References
- [NixOS/Win dual boot guide](https://github.com/andywhite37/nixos/blob/master/DUAL_BOOT_WINDOWS_GUIDE.md): I followed this guide to install NixOS alongside an existing Windows 10 installation.
- [NixOS manual](https://nixos.org/nixos/manual/)
- [home-manager manual](https://rycee.gitlab.io/home-manager/)
- [Nix User Repository](https://github.com/nix-community/NUR): a community-driven meta repository for Nix packages.
