{
  flake.modules.nixos.gpg = {
    programs.gnupg.agent.enable = true;
  };
}
