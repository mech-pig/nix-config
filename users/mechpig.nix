{ pkgs, home-manager, ... }:
let
  nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/739ca4468aab62ca046bf309ba815aceb248919d.tar.gz";
    sha256 = "0za8hrqq21qz4mf1xal581dqg2yfqxgn6m8jrsrwspyl9p7dahp3";
  }) {
    inherit pkgs;
  };

  # see https://nixos.wiki/wiki/VSCodium
  vscodium-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = (
      with pkgs.vscode-extensions; [
        bbenoist.Nix
        ms-azuretools.vscode-docker
      ]
    ) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "gitlens";
        publisher = "eamodio";
        version = "10.2.3";
        sha256 = "00pddp8jlmqmc9c50vwm6bnkwg9gvvfn8mvrz1l9fl1w88ia1nz0";
      }
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "11.0.0";
        sha256 = "18gf6ikkvqrihblwpmb4zpxg792la5yg8pwfaqm07dzwzfzxxvmv";
      }
    ];
  };
in {

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
      vscodium-with-extensions
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
