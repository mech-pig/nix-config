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

## Troubleshooting

### Repair the bootloader
This happened to me after I replaced an ssd with a new one. This operation has somehow corrupted the partition mapping and I was not able to boot neither into nixos nor into windows. I solved the problem by fixing the Windows EFI entry in the bootloader (references to disk partitions were wrong) followed by a rebuild of the nixos systemd-boot entries (this procedure is provided by nixos itself).

- [Repair UEFI bootloader in Windows](https://woshub.com/how-to-repair-uefi-bootloader-in-windows-8/) - I just fixed the boot manager and bootloader using `bcedit` from a recovery usb drive, no need to re-create the EFI partition as it was already there, cloned from the previous ssd
- [Re-installing the nixos bootloader](https://nixos.wiki/wiki/Bootloader#Re-installing_the_bootloader) - I used the [minimal nixos installer](https://nixos.org/download/#nixos-iso) to mount my existing `nixos` and `boot` partitions and just followed the procedure to re-install the bootloader.

## References
- [NixOS/Win dual boot guide](https://github.com/andywhite37/nixos/blob/master/DUAL_BOOT_WINDOWS_GUIDE.md): I followed this guide to install NixOS alongside an existing Windows 10 installation.
- [NixOS manual](https://nixos.org/nixos/manual/)
- [home-manager manual](https://nix-community.github.io/home-manager/)
- [Nix User Repository](https://github.com/nix-community/NUR): a community-driven meta repository for Nix packages.
