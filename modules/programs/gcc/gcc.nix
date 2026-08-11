{
  flake.modules.nixos.gcc =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        gcc
      ];
    };
}
