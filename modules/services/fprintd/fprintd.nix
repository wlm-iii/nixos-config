{
  flake.modules.nixos.fprintd = {
    services.fprintd.enable = true;
    security.pam.services = {
      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
      login.fprintAuth = true;
    };
  };
}
