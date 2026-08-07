{ 
  inputs,
  ... 
}:
{
  flake.modules.nixos.praxis = {
    imports = with inputs.self.modules.nixos; [
      wlmiii
    ];
  };
}
