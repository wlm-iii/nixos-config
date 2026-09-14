{
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;
      settings = {
        font-size = 14;
        window-decoration = "server";
        shell-integration-features = "ssh-env,ssh-terminfo,title";
        window-padding-balance = true;
      };
    };
  };
}
