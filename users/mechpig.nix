{ config, pkgs, home-manager, ... }:
let
  # https://github.com/nix-community/NUR
  nur = import (builtins.fetchTarball {
    # master branch (2022/10/05)
    url = "https://github.com/nix-community/NUR/archive/cfd6fe7cb30a28b2899387ae0171f3e29fa7e686.tar.gz";
    # get sha with nix-prefetch-url --unpack <url>
    sha256 = "0wslfgjzlvwx5zwgpljjss7nhmd6zfqxk8z6nmznwckpgwq9ppfb";
  }) {
    inherit pkgs;
  };

  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/4
  unstable = import (builtins.fetchGit {
    name = "nixos-unstable-2022-10-07";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    rev = "37bd39839acf99c5b738319f42478296f827f274";
  }) {
    config = config.nixpkgs.config;
  };

  # see https://nixos.wiki/wiki/VSCodium
  vscodium-with-extensions = unstable.vscode-with-extensions.override {
    vscode = unstable.vscodium;
    vscodeExtensions = (
      with unstable.vscode-extensions; [
        apollographql.vscode-apollo
        arrterian.nix-env-selector
        bbenoist.nix
        dbaeumer.vscode-eslint
        eamodio.gitlens
        elmtooling.elm-ls-vscode
        esbenp.prettier-vscode
        golang.go
        haskell.haskell
        justusadam.language-haskell
        matklad.rust-analyzer
        ms-azuretools.vscode-docker
        ms-python.python
        tamasfe.even-better-toml
      ]
    ) ++ unstable.vscode-utils.extensionsFromVscodeMarketplace [
      # to determine sha256
      # curl -X GET -o out.zip https://PUBLISHER.gallery.vsassets.io/_apis/public/gallery/publisher/PUBLISHER/extension/NAME/VERSION/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
      # nix-hash --flat --base32 --type sha256 out.zip
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "11.10.0";
        sha256 = "0n96jdmqqh2v7mni4qv08qjxyhp8h82ck9rhmwnxp66ni5ybmj63";
      }
      {
        name = "zls-vscode";
        publisher = "AugusteRame";
        version = "1.1.3";
        sha256 = "0dhq9g4yyjhdq1w9vlraml59xfjj8hrlvl195lsh76yf370a7lbi";
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
      pkgs.bitwarden
      pkgs.cryptomator
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
      pkgs.vlc
      pkgs.zip
      vscodium-with-extensions
    ];

    home.file.".config/starship.toml" = {
      recursive = false;
      source = ./starship.toml;
    };

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
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
