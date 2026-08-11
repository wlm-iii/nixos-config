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
      tree-sitter
      lua-language-server
      nil
      ripgrep
      fzf
      gcc
      clang-tools
      fd
      pyright
      tinymist
      gnumake
    ];
    
    xdg.configFile.nvim.source = inputs.nvim-config;
  };
}
