{
  flake.modules.nixos.hyprland =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.hyprland.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      systemd.user.targets.hyprland-session = {
        description = "Hyprland session";
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
        unitConfig.PropagatesStopTo = [ "graphical-session.target" ];
      };

      # Custom API for making implementation with tuigreet modular
      local.login.command = lib.mkDefault "start-hyprland";

      security.pam.services.hyprlock.fprintAuth = true;

      environment.systemPackages = with pkgs; [
        hyprpolkitagent
        # hyprland-qtutils
      ];
    };
}
