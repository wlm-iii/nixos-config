{
  flake.modules.nixos.xdg-portal = {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };
  };
}
