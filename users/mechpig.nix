{ pkgs, home-manager, ... }:
let
  nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
    sha256 = "01fnwys58jagvdby6463lggp1s23wr6whjdhgmg03xzwmj8wl3l9";
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
        ms-python.python
      ]
    ) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "elm-ls-vscode";
        publisher = "Elmtooling";
        version = "1.5.3";
        sha256 = "007v28j5h4z4g1dr8ch93hy0cvzj92iwjnq6q9wn2mqxgff91ykn";
      }
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
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "1.0.2";
        sha256 = "16pz637gx2kdm438irzx43jzjajhpjpzhgr15znkvaizy61s7vx1";
      }
      {
        name = "vscode-apollo";
        publisher = "apollographql";
        version = "1.17.0";
        sha256 = "1ip7csdb1ssxj4bh4ml1y3z0b546aagfjfjh354cgjc5vazrk6rx";
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
      pkgs.bitwarden
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
      pkgs.unzip
      pkgs.zip
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
      profiles = {
        mechpig = {
          id = 0;
          isDefault = true;
          settings = {
            "browser.formfill.enable" = false;
            "browser.search.region" = "IT";
            "browser.search.countryCode" = "IT";
            "browser.search.isUS" = false;
            "browser.search.suggest.enable" = false;
            "browser.sessionstore.privacy_level" = 2;
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "network.cookie.cookieBehavior" = 1;
            "network.http.referer.XOriginPolicy" = 2;
            "network.http.referer.XOriginTrimmingPolicy" = 2;
            "privacy.firstparty.isolate" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.clearOnShutdown.cache" = true;
            "privacy.clearOnShutdown.cookies" = true;
            "privacy.clearOnShutdown.downloads" = true;
            "privacy.clearOnShutdown.formdata" = true;
            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown.offlineApps" = true;
            "privacy.clearOnShutdown.openWindows" = true;
            "privacy.clearOnShutdown.siteSettings" = true;
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.cryptomining" = true;
            "privacy.trackingprotection.fingerprinting" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
            "signon.rememberSignons" = false;
          };
        };
      };
      extensions = with nur.repos.rycee.firefox-addons; [
        bitwarden
        canvasblocker
        clearurls
        cookie-autodelete
        decentraleyes
        https-everywhere
        privacy-badger
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
