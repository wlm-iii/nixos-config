{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-cli = {
    imports = with inputs.self.modules.nixos; 
    [
      system-default
      stylix

      btop
      direnv
      nh
    ];
  };

  flake.modules.homeManager.system-cli = {
    imports = with inputs.self.modules.homeManager; 
    [
      system-default
      stylix

      btop
      cmake
      codex
      fastfetch
      neovim
      python
      rustup
      shell
      terminal-toys
      tmux
      typst
      yazi
    ];
  };
}
