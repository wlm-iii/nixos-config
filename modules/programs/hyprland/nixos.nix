{
  flake.modules.nixos.hyprland =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.hyprland.enable = true;

      # Custom API for making implementation with tuigreet modular
      local.login.command = lib.mkDefault "Hyprland";

      security.pam.services.hyprlock.fprintAuth = true;

      environment.systemPackages = with pkgs; [
        hyprpolkitagent
        hyprland-qtutils
      ];
    };
}
