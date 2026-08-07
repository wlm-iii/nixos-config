{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      services.avahi = {
        enable = false;
        nssmdns4 = true;
        openFirewall = true;
      };

      programs.system-config-printer.enable = true;

      services.printing = {
        enable = true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
          mfcj470dwlpr
          mfcj470dw-cupswrapper
        ];
      };
    };
}
