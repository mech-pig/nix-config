{
  description = "Secure AI Agent Playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
  };

  outputs =
    {
      nixpkgs,
      jail-nix,
      llm-agents,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        jail = jail-nix.lib.init pkgs;

        # Define Security Policies
        commonJailOptions = with jail.combinators; [
          network
          time-zone
          no-new-session
          notifications
          wayland

          (set-env "COLORTERM" "truecolor")

          (add-runtime ''
            if [ -z "$PROJECT_DIR" ]; then
              echo "Error: PROJECT_DIR environment variable is not set" >&2
              exit 1
            fi
            if [ -d "$PROJECT_DIR" ]; then
              RUNTIME_ARGS+=(--bind "$PROJECT_DIR" "$PROJECT_DIR")
            else
              echo "Error: PROJECT_DIR '$PROJECT_DIR' does not exist" >&2
              exit 1
            fi
          '')
        ];

        commonPkgs =
          with pkgs;
          [
            bashInteractive
            curl
            wget
            git
            jq
            which
            ripgrep
            gnugrep
            gawkInteractive
            findutils
            diffutils
            ps
            libnotify
            wl-clipboard
            nodePackages_latest.prettier
            nixfmt
            shfmt
          ]
          ++ [
            llm-agents.packages.${system}.openspec
          ];

        claude-code-pkg =
          let
            raw = llm-agents.packages.${system}.claude-code;
          in
          pkgs.writeShellScriptBin "claude" ''
            exec ${raw}/bin/claude --dangerously-skip-permissions "$@"
          '';

        gemini-cli-pkg =
          let
            raw = llm-agents.packages.${system}.gemini-cli;
          in
          pkgs.writeShellScriptBin "gemini" ''
            exec ${raw}/bin/gemini --yolo "$@"
          '';

        opencode-pkg = llm-agents.packages.${system}.opencode;

        # --- The Sandboxes ---
        makeJailedClaude =
          {
            extraPkgs ? [ ],
          }:
          jail "jailed-claude" claude-code-pkg (
            with jail.combinators;
            (
              commonJailOptions
              ++ [
                (readwrite (noescape "~/.claude"))
                (readwrite (noescape "~/.claude.json"))

                (add-pkg-deps commonPkgs)
                (add-pkg-deps extraPkgs)
              ]
            )
          );

        makeJailedGemini =
          {
            extraPkgs ? [ ],
          }:
          jail "jailed-gemini" gemini-cli-pkg (
            with jail.combinators;
            (
              commonJailOptions
              ++ [
                (readwrite (noescape "~/.gemini"))
                (try-fwd-env "GEMINI_API_KEY")

                (add-pkg-deps commonPkgs)
                (add-pkg-deps extraPkgs)
              ]
            )
          );

        makeJailedOpenCode =
          {
            extraPkgs ? [ ],
          }:
          jail "jailed-opencode" opencode-pkg (
            with jail.combinators;
            (
              commonJailOptions
              ++ [
                (readwrite (noescape "~/.config/opencode"))
                (readwrite (noescape "~/.local/share/opencode"))
                (readwrite (noescape "~/.local/state/opencode"))

                # prevent re-downloading models and packages
                (readwrite (noescape "~/.cache/opencode"))
                (readwrite (noescape "~/.npm"))

                (add-pkg-deps commonPkgs)
                (add-pkg-deps extraPkgs)
              ]
            )
          );

        debug = jail "debug" pkgs.bashInteractive (
          with jail.combinators;
          (
            commonJailOptions
            ++ [
              (add-pkg-deps commonPkgs)
            ]
          )
        );
      in
      {
        lib = {
          inherit makeJailedClaude;
          inherit makeJailedGemini;
          inherit makeJailedOpenCode;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixd
            (makeJailedClaude { })
            (makeJailedGemini { })
            (makeJailedOpenCode { })
            debug
          ];
        };
      }
    );
}