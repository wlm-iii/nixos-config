{
  flake.modules.nixos.praxis =
    {
      config,
      lib,
      ...
    }:
    {
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/ab85dca1-ab17-4bfb-a969-6473ab7f3be1";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/ab85dca1-ab17-4bfb-a969-6473ab7f3be1";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/DC2B-A6B6";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        {
          device = "/dev/disk/by-partuuid/2b5f94f3-8f0a-45ca-8185-980e4a5e80a3";
          randomEncryption.enable = true;
          priority = 0;
        }
      ];
    };
}
