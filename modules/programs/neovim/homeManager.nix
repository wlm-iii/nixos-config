{
  inputs,
  ...
}:
{
  flake.modules.homeManager.neovim = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    
    xdg.configFile.nvim.source = inputs.nvim-config;
  };
}
