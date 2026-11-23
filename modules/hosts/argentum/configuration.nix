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

        docker
        fprintd
        keyd
        keymapp
        kubernetes
        syncthing
        tailscale
        zsa
      ];

      home-manager.users.wlmiii.imports = [
        inputs.self.modules.homeManager.argentum
      ];

      networking.hostName = "argentum";

      programs.nh.flake = "${config.users.users.wlmiii.home}/nixos-config";

      stylix.image = ./assets/autumn_painting.jpg;

      services.syncthing.settings = {
        devices.aurum = {
          id = "OQC77DA-G3ET6S2-RIJN4B3-RHVM4WT-VGLQQFV-53UUDLA-C5DFN6P-M5HPPAN";
          addresses = [ "tcp://aurum:22000" ];
        };

        folders.personal-sync.devices = [ "aurum" ];
      };

      system.stateVersion = "25.11";
    };
}
