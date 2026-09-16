{ 
  inputs,
  ... 
}:
{
  flake.modules.nixos.aurum = {
    imports = with inputs.self.modules.nixos; [
      wlmiii
    ];
  };
}
