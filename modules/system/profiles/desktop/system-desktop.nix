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
      bottles
      brave
      dconf
      disk
      gamescope
      greetd
      hyprland
      keepassxc
      localsend
      openconnect
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

      blanket
      brave
      chatgpt
      discord
      discordo
      dolphin
      firefox
      ghostty
      gtk
      hyprland
      keepassxc
      kitty
      libreoffice
      mgba
      mullvad-browser
      pdf-utils
      prismlauncher
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
