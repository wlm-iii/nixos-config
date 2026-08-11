{
  flake.modules.nixos.xserver =
    {
      pkgs,
      ...
    }:
    {
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
