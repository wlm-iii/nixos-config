{
  pkgs,
  ...
}:
{
  flake.modules.nixos.base-packages = {
    environment.systemPackages = with pkgs; [
      curl
      wget
      file
      tree
    ];
  };
}
