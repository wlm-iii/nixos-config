{ 
  inputs,
  ... 
}:
{
  flake.modules.nixos.argentum = {
    imports = with inputs.self.modules.nixos; [
      wlmiii
    ];
  };
}
