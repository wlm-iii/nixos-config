{
  flake.modules = {
    nixos.btop =
      {
        lib,
        pkgs,
        ...
      }:
      {
        security.wrappers.btop = lib.mkDefault {
          setuid = false;
          source = "${pkgs.btop}/bin/btop";
          owner = "root";
          group = "root";
          capabilities = "CAP_PERFMON=+ep";
        };
      };

    homeManager.btop = {
      programs.btop = {
        enable = true;
        settings = {
          color_theme = "gruvbox_dark";
          vim_keys = true;
          theme_background = false;
        };
      };
    };
  };
}
