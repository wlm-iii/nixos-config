{
  inputs,
  ...
}:
{
  flake.modules.nixos.praxis =
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
        inputs.self.modules.homeManager.praxis
      ];

      networking.hostName = "praxis";

      programs.nh.flake = "${config.users.users.wlmiii.home}/nixos-config";
    };
}
