{
  flake.modules.homeManager.pdf-utils =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        poppler-utils
      ];
    };
}
