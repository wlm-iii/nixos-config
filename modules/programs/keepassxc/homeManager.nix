{
  flake.modules.homeManager.keepassxc =
    {
      pkgs,
      ...
    }:
    {
      programs.keepassxc = {
        enable = true;
        autostart = true;
      };
      home.packages = with pkgs; [
        libsecret
      ];
    };
}
