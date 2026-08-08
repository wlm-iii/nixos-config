{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.rustup = {
    home.packages = with pkgs; [
      rustup
    ];
  };
}
