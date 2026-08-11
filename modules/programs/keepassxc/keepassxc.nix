{
  pkgs,
  ...
}:
{
  flake.modules.homeManager.keepassxc = {
    programs.keepassxc = {
      enable = true;
      autostart = true;
    };
    home.packages = with pkgs; [
      libsecret
    ];
  };
}
