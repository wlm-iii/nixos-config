{
  flake.modules.nixos.direnv = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      direnv
      nix-direnv
    ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
