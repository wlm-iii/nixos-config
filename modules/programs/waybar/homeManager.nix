{
  flake.modules.homeManager.waybar = 
  { 
    pkgs, 
    ... 
  }:
  {
    home.packages = with pkgs; [
      waybar
    ];

    xdg.configFile."waybar/config.jsonc".source = ./assets/config.jsonc;
    xdg.configFile."waybar/style.css".source = ./assets/style.css;
  };
}
