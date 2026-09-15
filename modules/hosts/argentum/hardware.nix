{
  flake.modules.nixos.argentum =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];

      boot.kernelModules = [ "kvm-amd" ];

      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
