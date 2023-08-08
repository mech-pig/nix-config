{ config, pkgs, home-manager, ... }:
let
  # https://github.com/nix-community/NUR
  nur = import (builtins.fetchTarball {
    # master branch (2023/05/27)
    # git ls-remote https://github.com/nix-community/NUR master
    url = "https://github.com/nix-community/NUR/archive/c469c2991971d13c39c5a221c61408475aa53b1a.tar.gz";
    # get sha with nix-prefetch-url --unpack <url>
    sha256 = "0vq7vr1x4pd1cks0gfsfijbdl0fvlk9p12cq2l3fh8vmawzl9b1d";
  }) {
    inherit pkgs;
  };

  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/4
  unstable = import (builtins.fetchGit {
    name = "nixos-unstable-2023-05-27";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    rev = "f91ee3065de91a3531329a674a45ddcb3467a650";
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
        vscode-icons-team.vscode-icons
      ]
    ) ++ unstable.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-zig";
        publisher = "ziglang";
        version = "0.3.2";
        # curl -X GET -o out.zip https://ziglang.gallery.vsassets.io/_apis/public/gallery/publisher/ziglang/extension/vscode-zig/0.3.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
        # nix-hash --flat --base32 --type sha256 out.zip
        sha256 = "0zmjsszav43wj5nhq24m3nvzqjwqj3q3c61j466nai9sdwbbycdk";
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
    home.packages = (
      with pkgs; [
        bitwarden
        calibre 
        cryptomator
        gimp
        google-chrome
        google-cloud-sdk
        httpie
        imagemagick
        inkscape
        maestral
        maestral-gui
        nerdfonts
        obsidian
        starship
        slack
        standardnotes
        unzip
        vlc
        zip
      ]
    ) ++ [
      vscodium-with-extensions
    ];

    home.file.".config/starship.toml" = {
      recursive = false;
      source = ./starship.toml;
    };

    home.stateVersion = "22.11";

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
            "dom.security_https_only_mode" = true;
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
