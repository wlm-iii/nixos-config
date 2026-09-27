{
  flake.modules.nixos.openssh =
    {
      config,
      ...
    }:
    {
      services.openssh = {
        enable = true;
        openFirewall = false;
      };

      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts =
        config.services.openssh.ports;
    };
}
