{
  flake.modules.homeManager.rustup =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        rustup
      ];
    };
}
