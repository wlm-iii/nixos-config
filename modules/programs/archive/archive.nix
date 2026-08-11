{
  flake.modules.nixos.archive =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        zip
        unzip
        gnutar
        gzip
      ];
    };
}
