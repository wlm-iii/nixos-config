{
  flake.modules.homeManager.discord =
    {
      pkgs,
      ...
    }:
    {
      programs.discord = {
        enable = true;
        package = pkgs.discord.override {
          withVencord = true;
        };
      };
      programs.vesktop = {
        enable = true;
      };
    };
}
