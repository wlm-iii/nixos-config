{
  self,
  lib,
  ...
}:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "wlmiii" true)
    {
      nixos.wlmiii = {
        users.users.wlmiii = {
          description = "Liam McCarthy";
          group = "audio";
          extraGroups = [
            "networkmanager"
            "lpadmin"
          ];
        };
      };

      homeManager.wlmiii = {
        programs.home-manager.enable = true;
      };
    }
  ];
}
