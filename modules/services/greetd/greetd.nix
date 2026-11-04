{
  flake.modules.nixos.greetd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.login.command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Command launched by tuigreet on login";
      };

      config = lib.mkIf (config.local.login.command != null) {
        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings = {
            default_session = {
              user = "greeter";
              command = lib.concatStringsSep " " [
                "${pkgs.tuigreet}/bin/tuigreet "
                "--time"
                "--remember"
                "--remember-session"
                "--cmd"
                (lib.escapeShellArg config.local.login.command)
                # Custom API to make graphical environment modular
              ];
            };
          };
        };
      };
    };
}
