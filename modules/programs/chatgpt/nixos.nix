{
  flake.modules.homeManager.chatgpt =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        chatgpt
      ];
    };
}
