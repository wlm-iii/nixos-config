{
  flake.modules.nixos.openconnect =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.openconnect
      ];
    };
}
