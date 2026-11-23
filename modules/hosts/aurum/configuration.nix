{
  inputs,
  ...
}:
{
  flake.modules.nixos.aurum =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        system-desktop

        keyd
        keymapp
        nvidia
        openssh
        syncthing
        tailscale
        zsa
      ];

      home-manager.users.wlmiii.imports = [
        inputs.self.modules.homeManager.aurum
      ];

      networking.hostName = "aurum";

      programs.nh.flake = "${config.users.users.wlmiii.home}/nixos-config";

      security.wrappers.btop = {
        setuid = false;
        source = "${pkgs.btop.override { cudaSupport = true; }}/bin/btop";
        owner = "root";
        group = "root";
        capabilities = "CAP_PERFMON=+ep";
      };

      stylix.image = ./assets/autumn_mountains_painting.jpg;

      services.syncthing.settings = {
        devices.argentum = {
          id = "MTNTJFH-GACYYI6-KY4GSJD-G3VHAFY-6I7G4Y2-H3RWCWE-HEBWIB6-EEAY2AC";
          addresses = [ "tcp://argentum:22000" ];
        };

        folders.personal-sync.devices = [ "argentum" ];
      };

      system.stateVersion = "26.05";
    };
}
