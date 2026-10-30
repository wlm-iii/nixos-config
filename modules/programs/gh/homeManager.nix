{
  flake.modules.homeManager.gh = {
    programs.gh = {
      enable = true;
      settings = {
        git-protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
