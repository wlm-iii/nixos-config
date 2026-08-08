{
  pkgs,
  ...
}:
{
  flake.modules.nixos.clang = {
    environment.systemPackages = with pkgs; [
      clang
      clang-tools
    ];
  };
}
