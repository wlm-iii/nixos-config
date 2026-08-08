{
  pkgs,
  ...
}:
{
  flake.modules.nixos.gdb = {
    environment.systemPackages = with pkgs; [
      gdb
    ];
  };
}
