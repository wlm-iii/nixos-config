{
  flake.modules.homeManager.pi-agent = 
  {
    pkgs,
    ...
  }:
  {
    programs.pi-coding-agent = {
      enable = true;

      extraPackages = with pkgs; [
        # Pi Package Management
        nodejs

        # Cli tools
        ripgrep
        fd
        jq
      ];
    };
  };
}
