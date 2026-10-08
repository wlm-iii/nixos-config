{
  flake.modules.nixos.networkmanager =
    {
      pkgs,
      ...
    }:
    {
      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-openconnect
        ];
      };

      environment.etc."openconnect/csd-wrapper.sh".source =
        "${pkgs.openconnect}/libexec/openconnect/csd-wrapper.sh";

      environment.etc."openconnect/csd-post.sh".source =
        "${pkgs.openconnect}/libexec/openconnect/csd-post.sh";
    };
}
