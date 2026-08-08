{
  pkgs,
  ...
}:
{
  flake.modules.nixos.gcc = {
    environment.systemPackages = with pkgs; [
      gcc
    ];
  };
}
