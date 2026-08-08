{
  flake.modules.homeManager.stylix = {
    stylix.targets = {
      qt = {
        enable = true;
        standardDialogs = "xdgdesktopportal";
      };
      firefox.enable = false;
      btop.enable = false;
      tmux.enable = false;
    };
  };
}
