{
  flake.modules.nixos.keyd = {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
            leftalt = "layer(extension)";
            rightshift = "rightshift";
          };
          "extension:A" = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          };
        };
      };
    };
  };
}
