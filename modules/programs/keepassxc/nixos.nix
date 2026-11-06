{
  flake.modules.nixos.keepassxc =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        keepassxc
      ];
    };
}
