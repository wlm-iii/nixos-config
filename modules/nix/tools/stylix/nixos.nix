{
  inputs,
  ...
}:
{
  flake.modules.nixos.stylix =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = {
        enable = true;

        image = lib.mkDefault ./assets/nixos.png;

        polarity = "dark";

        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";

        fonts = {
          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
          };
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            terminal = 14;
          };
        };

        opacity.terminal = 0.90;

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 20;
        };

        targets = {
          grub = {
            enable = true;
            useWallpaper = false;
          };
          qt.enable = false;
        };
      };

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };
}
