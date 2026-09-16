{
  flake.modules.nixos.aurum = 
  {
    config,
    lib,
    ...
  }:
  {
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/83b6bd53-ded0-45e1-8702-d36b63702ea7";
        fsType = "btrfs";
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/83b6bd53-ded0-45e1-8702-d36b63702ea7";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/83b6bd53-ded0-45e1-8702-d36b63702ea7";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/4A77-C273";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    fileSystems."/data" = {
        device = "/dev/disk/by-uuid/06628db3-e0bd-4f91-a4f6-bee6e21adc71";
        fsType = "btrfs";
        options = [ "compress=zstd" "nofail" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/4e56821f-31d7-402d-869a-9a36083f0145"; }
      ];
  };
}
