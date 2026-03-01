{ config, pkgs, home-manager, ... }:
let
  # https://github.com/nix-community/NUR
  nur = import (builtins.fetchTarball {
    name = "nur-master-2026-03-01";
    # git ls-remote https://github.com/nix-community/NUR master
    url = "https://github.com/nix-community/NUR/archive/7f4366be821b64f130c08dd47cbc22cad3003d97.tar.gz";
    # nix-prefetch-url --unpack https://github.com/nix-community/NUR/archive/7f4366be821b64f130c08dd47cbc22cad3003d97.tar.gz
    sha256 = "1vkhfqafcyr17r4ghxhrgcgh39rij8avqi0541nm7178c45yiwl2";
  }) {
    inherit pkgs;
  };

  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/4
  unstable = import (builtins.fetchGit {
    name = "nixos-unstable-2026-03-01";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    rev = "dd9b079222d43e1943b6ebd802f04fd959dc8e61";
  }) {
    config = config.nixpkgs.config;
  };

  # see https://nixos.wiki/wiki/VSCodium
  vscodium-with-extensions = unstable.vscode-with-extensions.override {
    vscode = unstable.vscodium;
    vscodeExtensions = (
      # look for extensions here: https://open-vsx.org/
      with unstable.vscode-extensions; [
        apollographql.vscode-apollo
        arrterian.nix-env-selector
        bbenoist.nix
        charliermarsh.ruff
        dbaeumer.vscode-eslint
        eamodio.gitlens
        elmtooling.elm-ls-vscode
        esbenp.prettier-vscode
        golang.go
        haskell.haskell
        justusadam.language-haskell
        rust-lang.rust-analyzer
        mkhl.direnv
        ms-azuretools.vscode-docker
        ms-python.python
        tamasfe.even-better-toml
        vscode-icons-team.vscode-icons
        ziglang.vscode-zig
      ]
    ) ++ unstable.vscode-utils.extensionsFromVscodeMarketplace [
      # in case required extensions are not found on openvsx
      # we can downloaded from the vscode marketplace
      # {
      #   name = "vscode-zig";
      #   publisher = "ziglang";
      #   version = "0.3.2";
      #   # curl -X GET -o out.zip https://ziglang.gallery.vsassets.io/_apis/public/gallery/publisher/ziglang/extension/vscode-zig/0.3.2/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
      #   # nix-hash --flat --base32 --type sha256 out.zip
      #   sha256 = "0zmjsszav43wj5nhq24m3nvzqjwqj3q3c61j466nai9sdwbbycdk";
      # }
      {
        name = "ty";
        publisher = "astral-sh";
        version = "2026.18.0";
        # curl -X GET -o out.zip https://astral-sh.gallery.vsassets.io/_apis/public/gallery/publisher/astral-sh/extension/ty/2026.18.0/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
        # nix-hash --flat --base32 --type sha256 out.zip
        sha256 = "B67gPxL0QSfg5e/HN5M5yaKAEIKesV+1gw3WihLW3GA=";
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

  fonts = {
    fontconfig.enable = true;
  };

  home-manager.users.mechpig = { pkgs, lib, ... }: {
    home.packages = (
      with pkgs; [
        bitwarden-desktop
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
        obsidian
        starship
        slack
        standardnotes
        unzip
        uv
        vlc
        zip
      ]
    ) ++ [
      vscodium-with-extensions
    ] ++
      builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    

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

          extensions = {
            packages = with nur.repos.rycee.firefox-addons; [
              bitwarden
              canvasblocker
              clearurls
              cookie-autodelete
              decentraleyes
              privacy-badger
              ublock-origin
            ];
          };
        };
      };
    };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      initContent = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
    };
  };
}
