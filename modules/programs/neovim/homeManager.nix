{
  inputs,
  ...
}:
{
  flake.modules.homeManager.neovim = 
  {
    pkgs,
    ...
  }:
  {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = false;
      withRuby = false;
    };

    home.packages = with pkgs; [
      clang-tools
      fd
      fzf
      gcc
      gnumake
      lua-language-server
      nil
      nixd
      nixfmt
      pyright
      ripgrep
      tinymist
      tree-sitter
      websocat
    ];
    
    xdg.configFile.nvim.source = inputs.nvim-config;
  };
}
