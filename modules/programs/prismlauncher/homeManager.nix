{
  flake.modules.homeManager.prismlauncher =
    {
      pkgs,
      ...
    }:
    {
      programs.prismlauncher = {
        enable = true;
        extraPackages = with pkgs; [
          openjdk21
        ];
      };
    };
}
