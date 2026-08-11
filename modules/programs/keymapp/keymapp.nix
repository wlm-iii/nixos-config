{
  pkgs,
  ...
}:
{
  flake.modules.nixos.keymapp = {
    environment.systemPackages = with pkgs; [
      keymapp
    ];
  };
}
