{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos.praxis = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
    ];

    home-manager.users.wlmiii.imports = [
      inputs.self.modules.homeManager.praxis
    ];

    programs.nh.flake = "${config.users.users.wlmiii.home}/Projects/dendritic-nix";
  };
}
