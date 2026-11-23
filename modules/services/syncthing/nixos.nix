{
  flake.modules.nixos.syncthing =
    {
      config,
      ...
    }:
    let
      user = "wlmiii";
      account = config.users.users.${user};
    in
    {
      services.syncthing = {
        enable = true;
        user = "wlmiii";
        inherit (account) group;
        dataDir = account.home;

        guiAddress = "127.0.0.1:8384";
        openDefaultPorts = false;
        overrideDevices = true;
        overrideFolders = true;

        settings = {
          options = {
            listenAddresses = [ "tcp://0.0.0.0:22000" ];
            globalAnnounceEnabled = false;
            localAnnounceEnabled = false;
            relaysEnabled = false;
            natEnabled = false;
          };

          folders.personal-sync = {
            label = "Personal Sync";
            path = "${account.home}/Sync";
            type = "sendreceive";
            versioning = {
              type = "simple";
              params.keep = "10";
            };
          };
        };
      };

      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
        22000
      ];
    };
}
