{
  pkgs,
  ...
}:
{
  flake.modules.nixos.efibootmgr = {
    environment.systemPackages = with pkgs; [
      efibootmgr
    ];
  };
}
