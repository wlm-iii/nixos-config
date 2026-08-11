{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli

      accounts-daemon
      blueman
      bluetooth
      dconf
      disk
      greetd
      hyprland
      localsend
      pipewire
      polkit
      power
      printing
      steam
      xdg-portal
      xserver
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli

      discord
      dolphin
      firefox
      ghostty
      gtk
      hyprland
      keepassxc
      kitty
      libreoffice
      mullvad-browser
      pdf-utils
      qt
      rofi
      thunderbird
      waybar
      xonotic
      xournalpp
      youtube-music
      zathura
      zoom
    ];
  };
}
