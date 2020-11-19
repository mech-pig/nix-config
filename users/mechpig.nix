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
        name = "even-better-toml";
        publisher = "tamasfe";
        version = "0.9.3";
        sha256 = "16x2y58hkankazpwm93j8lqdn3mala7iayck548kki9zx4qrhhck";
      }
      {
        name = "gitlens";
        publisher = "eamodio";
        version = "10.2.3";
        sha256 = "00pddp8jlmqmc9c50vwm6bnkwg9gvvfn8mvrz1l9fl1w88ia1nz0";
      }
      {
        name = "vscode-eslint";
        publisher = "dbaeumer";
        version = "2.1.8";
        sha256 = "18yw1c2yylwbvg5cfqfw8h1r2nk9vlixh0im2px8lr7lw0airl28";
      }
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "11.0.0";
        sha256 = "18gf6ikkvqrihblwpmb4zpxg792la5yg8pwfaqm07dzwzfzxxvmv";
      }
    ];
  };
in
{
  # Define user account. Don't forget to set a password with ‘passwd’.
  users.users.mechpig = {
    isNormalUser = true;
    extraGroups = [
      "wheel"          # Enable ‘sudo’ for the user.
      "docker"         # Allow interaction with docker daemon.
      "networkmanager" # Has permission to change network settings.
    ];
    shell = pkgs.zsh;
  };

  fonts.fontconfig.enable = true;

  home-manager.users.mechpig = { pkgs, ... }: {
    home.packages = [
      pkgs.atom
      pkgs.dropbox
      pkgs.gimp
      pkgs.google-chrome
      pkgs.google-cloud-sdk
      pkgs.httpie
      pkgs.inkscape
      pkgs.nerdfonts
      pkgs.starship
      pkgs.slack
      pkgs.standardnotes
      vscodium-with-extensions
    ];

    home.file.".atom" = {
      recursive = true;
      source = ../dotfiles/.atom;
    };

    home.file.".config/starship.toml" = {
      recursive = false;
      source = ./starship.toml;
    };

    programs.direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
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

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      initExtra = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
    };
  };
}
