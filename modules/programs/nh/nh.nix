{
  flake.modules.nixos.nh =
    {
      lib,
      config,
      ...
    }:
    {
      programs.nh = {
        enable = true;

        # flake = "${config.home.homeDirectory}/nix-config";

        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep-since 7d --keep 3";
        };
      };
    };
}
