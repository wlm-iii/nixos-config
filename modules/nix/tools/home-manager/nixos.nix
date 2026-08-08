{
  inputs,
  ...
}:
{
  flake.modules.nixos.home-manager =
    {
      lib,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
      };
    };
}
