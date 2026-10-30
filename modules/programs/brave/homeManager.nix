{
  flake.modules.homeManager.brave =
    { pkgs, ... }:
    {
      # KeePassXC adds its native messaging host to programs.brave. Selecting
      # Origin here makes Home Manager install it in Brave-Origin, not Brave-Browser.
      programs.brave = {
        enable = true;
        package = pkgs.brave-origin;
      };
    };
}
