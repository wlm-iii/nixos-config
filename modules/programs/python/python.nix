{ 
  pkgs, 
  ... 
}: 
{
  flake.modules.homeManager.python = {
    home.packages = with pkgs; [
      python314
    ];
  };
}
