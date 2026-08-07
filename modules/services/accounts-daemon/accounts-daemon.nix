{
  flake.modules.nixos.accounts-daemon = {
    services.accounts-daemon.enable = true;
  };
}
