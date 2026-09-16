{
  inputs,
  ...
}:
{
  flake.modules.nixos.aurum =
    {
      config,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        system-desktop

        nvidia
        zsa
      ];

      home-manager.users.wlmiii.imports = [
        inputs.self.modules.homeManager.aurum
      ];

      networking.hostName = "aurum";

      programs.nh.flake = "${config.users.users.wlmiii.home}/nixos-config";
    };
}
