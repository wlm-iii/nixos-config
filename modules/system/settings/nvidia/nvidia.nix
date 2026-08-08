{
  flake.modules.nixos.nvidia = { config, ... }: {
    hardware.graphics.enable = true;
    # For X11 _and_ Wayland even though the setting is called xserver
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;
      nvidiaSettings = true;
    };
  };
}
