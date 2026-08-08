{
  inputs,
  ...
}:
{
  flake.modules.nixos.stylix =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = {
        enable = true;

        image = ./assets/bohmer.jpg;

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
        };

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
        };
      };

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };
}
