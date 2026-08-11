{
  flake.modules.nixos.gdb =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        gdb
      ];
    };
}
