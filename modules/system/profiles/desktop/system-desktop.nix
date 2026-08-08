{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; 
    [
      system-cli
      hyprland
      greetd

    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; 
    [
      system-cli
      hyprland
      waybar

    ];
  };
}
