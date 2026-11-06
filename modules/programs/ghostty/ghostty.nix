{
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;
      settings = {
        adjust-cell-height = "-10%";
        background-blur = true;
        font-size = 14;
        quit-after-last-window-closed = false;
        shell-integration-features = "ssh-env,ssh-terminfo,title";
        window-decoration = "server";
        window-inherit-working-directory = false;
        window-padding-balance = true;
      };
    };
  };
}
