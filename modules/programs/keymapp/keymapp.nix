{
  flake.modules.nixos.keymapp =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        keymapp
      ];
    };
}
