{
  flake.modules.nixos.efibootmgr =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        efibootmgr
      ];
    };
}
