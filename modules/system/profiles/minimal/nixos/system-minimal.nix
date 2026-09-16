{
  ...
}:
{
  flake.modules.nixos.system-minimal = {
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
