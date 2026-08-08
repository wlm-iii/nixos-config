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
          TERMINAL = "kitty";
        };
        initContent = ''
          fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)
          autoload -U promptinit
          promptinit
          prompt pure
        '';
        shellAliases = {
          nv = "nvim";
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
