{
  ...
}:
{
  flake.modules.nixos.system-minimal = {
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "25.11";
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
