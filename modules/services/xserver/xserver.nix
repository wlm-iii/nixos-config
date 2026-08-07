{
  pkgs,
  ...
}:
{
  flake.modules.nixos.xserver = {
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
