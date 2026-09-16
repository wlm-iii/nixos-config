{
  inputs,
  ...
}:
{
  flake.modules.nixos.argentum =
    {
      config,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        system-desktop

        fprintd
        keyd
        keymapp
        zsa
      ];

      home-manager.users.wlmiii.imports = [
        inputs.self.modules.homeManager.argentum
      ];

      networking.hostName = "argentum";

      programs.nh.flake = "${config.users.users.wlmiii.home}/nixos-config";

      system.stateVersion = "25.11";
    };
}
