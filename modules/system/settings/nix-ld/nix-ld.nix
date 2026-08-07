{
  pkgs,
  ...
}:
{
  flake.modules.nixos.nix-ld = {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
      ];
    };
  };
}
