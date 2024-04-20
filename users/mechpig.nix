{ config, pkgs, home-manager, ... }:
let
  # https://github.com/nix-community/NUR
  nur = import (builtins.fetchTarball {
    name = "nur-master-2024-04-18";
    # git ls-remote https://github.com/nix-community/NUR master
    url = "https://github.com/nix-community/NUR/archive/13455a253b4e890ae69925a7b554c660f63da85d.tar.gz";
    # get sha with nix-prefetch-url --unpack <url>
    sha256 = "1y0yid587znzab0rnds05j439r3pmavbik88dx9fkr5zsbc5j0rc";
  }) {
    inherit pkgs;
  };

  # https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/4
  unstable = import (builtins.fetchGit {
    name = "nixos-unstable-2024-04-18";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    # `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
    rev = "5672bc9dbf9d88246ddab5ac454e82318d094bb8";
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
        dbaeumer.vscode-eslint
        eamodio.gitlens
        elmtooling.elm-ls-vscode
        esbenp.prettier-vscode
        golang.go
        haskell.haskell
        justusadam.language-haskell
        matklad.rust-analyzer
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
      };
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
