{
  flake.modules.homeManager.shell =
    {
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        defaultKeymap = "viins";
        sessionVariables = {
          EDITOR = "nvim";
          BROWSER = "firefox";
          TERMINAL = "ghostty";
        };
        initContent = ''
          fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)

          prompt_pure_precustom() {
            if [[ -n $IN_NIX_SHELL ]]; then
              psvar[20]=$'\uf313'
              prompt_pure_colors[virtualenv]=cyan
            else
              prompt_pure_colors[virtualenv]=242
            fi
          }

          autoload -Uz prompt_pure_setup
          prompt_pure_setup
          zstyle :prompt:pure:environment:nix-shell symbol $'\uf313'
        '';
        shellAliases = {
          nv = "nvim";
          ff = "fastfetch";
        };
      };

      home.packages = with pkgs; [
        pure-prompt
      ];

      home.sessionPath = [
        "$HOME/.cargo/bin"
      ];
    };
}
