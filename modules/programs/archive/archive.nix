{ 
  pkgs, 
  ... 
}:
{
  flake.modules.nixos.archive = {
    environment.systemPackages = with pkgs; [
      zip
      unzip
      gnutar
      gzip
    ];
  };
}
