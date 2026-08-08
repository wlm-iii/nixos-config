{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos;
    [
      system-minimal
      home-manager

      archive
      base-packages
      clang
      efibootmgr
      firmware
      gcc
      gdb
      git
      grub
      kernel
      networkmanager
      ssh
      tmux
      vim
    ];
  };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager;
    [
      system-minimal

      git
    ];
  };
}
