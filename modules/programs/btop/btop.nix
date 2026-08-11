{
  flake.modules = {
    nixos.btop =
      {
        pkgs,
        ...
      }:
      {
        security.wrappers.btop = {
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
          color_theme = "TTY";
          vim_keys = true;
        };
      };
    };
  };
}
