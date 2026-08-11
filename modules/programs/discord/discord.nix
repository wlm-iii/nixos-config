{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.discord = {
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
