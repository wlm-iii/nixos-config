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
        imports = with self.modules.nixos; [
            system-desktop
        ];
        users.users.wlmiii = {
          description = "Liam McCarthy";
          group = "audio";
          extraGroups = [
            "networkmanager"
            "lpadmin"
          ];
        };
      };

      homeManager.wlmiii =
        { pkgs, ... }:
        {
          imports = with self.modules.homeManager; [
            # system-desktop
          ];

          home.packages = with pkgs; [
          ];
          programs.home-manager.enable = true;
        };
    }
  ];
}
