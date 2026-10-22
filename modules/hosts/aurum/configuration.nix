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

      system.stateVersion = "26.05";
    };
}
