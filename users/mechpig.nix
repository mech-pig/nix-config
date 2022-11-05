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
    name = "nixos-unstable-2022-11-04";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    rev = "a2a777538d971c6b01c6e54af89ddd6567c055e8";
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
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "12.0.1";
        # curl -X GET -o out.zip https://vscode-icons-team.gallery.vsassets.io/_apis/public/gallery/publisher/vscode-icons-team/extension/vscode-icons/12.0.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
        # nix-hash --flat --base32 --type sha256 out.zip
        sha256 = "0dfgjawrykw4iw0lc3i1zpkbcvy00x93ylwc6rda1ffzqgxq64ng";
      }
      {
        name = "zls-vscode";
        publisher = "AugusteRame";
        version = "1.1.5";
        # curl -X GET -o out.zip https://AugusteRame.gallery.vsassets.io/_apis/public/gallery/publisher/AugusteRame/extension/zls-vscode/1.1.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
        # nix-hash --flat --base32 --type sha256 out.zip
        sha256 = "0j0fjvwihx7mqilhpjyrizrc0w2d9gkph2vhn13i2mglzxiknsrs";
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
