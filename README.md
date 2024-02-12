My [Nix/NixOS](https://nixos.org) configuration files.


## Install as NixOS configuration
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


## Update NixOS version

- Replace `nixos` channel alias to make it point to the correct version `sudo nix-channel --add https://nixos.org/channels/nixos-XX.YY nixos`
- Do the same for the `home-manager` channel: `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-XX.YY.tar.gz home-manager` (ensure the version of `home-manager` matches the `nixos` one)
- Update the channels: `sudo nix-channel --update`
- Build the system and reboot: `sudo nixos-rebuild --upgrade boot`


## References
- [NixOS/Win dual boot guide](https://github.com/andywhite37/nixos/blob/master/DUAL_BOOT_WINDOWS_GUIDE.md): I followed this guide to install NixOS alongside an existing Windows 10 installation.
- [NixOS manual](https://nixos.org/nixos/manual/)
- [home-manager manual](https://nix-community.github.io/home-manager/)
- [Nix User Repository](https://github.com/nix-community/NUR): a community-driven meta repository for Nix packages.
