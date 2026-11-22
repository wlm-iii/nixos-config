{
  flake.modules.homeManager.pi-agent =
    {
      pkgs,
      ...
    }:
    {
      programs.pi-coding-agent = {
        enable = true;

        settings = {
          defaultProvider = "openai";
          defaultModel = "gpt-6.2-sol";
          defaultThinkingLevel = "high";
          enableInstallTelemetry = false;
          tuiMode = "regular";
          quietStartup = "header";
          outputPad = 0;
          theme = "gruvbox-dark";

          packages = [
            "npm:pi-vim"
            "npm:@inobit/pi-permission"
            "npm:pi-web-access"
            "npm:@henryqw/pi-ask-question"
            "npm:pi-subagents"
          ];

        };

        mutableSettings = true;

        context = ''
          - Never read, modify, stage, or expose ignored credential or session files.
          - Do not install, update, remove, or enable Pi or other packages without expressed permission from the user.
          - Avoid potentially dangerous or harmful bash commands.
        '';

        extraPackages = with pkgs; [
          # Pi package management
          nodejs

          # cli tools
          ripgrep
          fd
          jq
        ];
      };

      home.file = {
        ".pi/agent/extensions" = {
          source = ./assets/extensions;
          recursive = true;
        };

        ".pi/agent/tests" = {
          source = ./assets/tests;
          recursive = true;
        };

        ".pi/agent/themes/gruvbox-dark.json".source = ./assets/themes/gruvbox-dark.json;

        ".pi/web-search.json".text = builtins.toJSON {
          searchRouting = {
            providers = [
              "openai"
              "duckduckgo"
            ];
            fallbackOn = [
              "transient"
              "quota"
              "network"
              "invalid-response"
            ];
          };

          fetchRouting = {
            providers = [ "http" ];
            allowRemoteHostedProviders = false;
          };

          workflow = "none";
        };
      };
    };
}
