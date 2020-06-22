{ pkgs, ... }:
let
  nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/739ca4468aab62ca046bf309ba815aceb248919d.tar.gz";
    sha256 = "0za8hrqq21qz4mf1xal581dqg2yfqxgn6m8jrsrwspyl9p7dahp3";
  }) {
    inherit pkgs;
  };
in {
  imports = [ <home-manager/nixos> ];

  # Define user account. Don't forget to set a password with ‘passwd’.
  users.users.mechpig = {
    isNormalUser = true;
    extraGroups = [
      "wheel"          # Enable ‘sudo’ for the user.
      "docker"         # Allow interaction with docker daemon.
      "networkmanager" # Has permission to change network settings.
    ];
  };

  home-manager.users.mechpig = { pkgs, ... }: {
    home.packages = [
      pkgs.atom
      pkgs.dropbox
      pkgs.gimp
      pkgs.google-chrome
      pkgs.google-cloud-sdk
      pkgs.httpie
      pkgs.inkscape
      pkgs.slack
      pkgs.standardnotes
    ];

    home.file.".atom" = {
      recursive = true;
      source = ../dotfiles/.atom;
    };

    programs.git = {
      enable = true;
      userEmail = "7295856+mech-pig@users.noreply.github.com";
      userName = "mechpig";
    };

    programs.firefox = {
      enable = true;
      # extensions do not seem to work
      # see https://github.com/rycee/home-manager/issues/1216
      extensions = with nur.repos.rycee.firefox-addons; [
        https-everywhere
        ublock-origin
      ];
    };
  };
}
