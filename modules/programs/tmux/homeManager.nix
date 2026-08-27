{
  flake.modules.homeManager.tmux =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;
    in
    {
      programs.tmux = {
        enable = true;
        sensibleOnTop = true;
        baseIndex = 1;
        keyMode = "vi";
        mouse = true;
        escapeTime = 0;
        extraConfig = ''
          # Enable truecolor 
          set -g default-terminal "tmux-256color"
          set -as terminal-features ",*:RGB"

          # Statusline basics
          set -g status on
          set -g status-position bottom
          set -g status-interval 5
          set -g status-justify centre
          set -g status-left-length 80
          set -g status-right-length 120
          set -g window-status-separator ""

          # Stylix base colors
          set -g status-style "bg=${c.base01},fg=${c.base06}"
          set -g message-style "bg=${c.base01},fg=${c.base05}"
          set -g message-command-style "bg=${c.base01},fg=${c.base0A}"

          # Pane borders
          set -g pane-border-style "fg=${c.base01}"
          set -g pane-active-border-style "fg=${c.base0D}"

          # Inactive windows
          set -g window-status-style "bg=${c.base00},fg=${c.base03}"
          set -g window-status-format "#[bg=${c.base01},fg=${c.base00}]#[bg=${c.base00},fg=${c.base0B}] #I:#W #[bg=${c.base01},fg=${c.base00}]"

          # Current window
          set -g window-status-current-style "bg=${c.base00},fg=${c.base00},bold"
          set -g window-status-current-format "#[bg=${c.base01},fg=${c.base09}]#[bg=${c.base09},fg=${c.base00},bold] #I:#W#{?window_zoomed_flag, 󰁌,} #[bg=${c.base01},fg=${c.base09}]"

          # Left: tmux icon + session, then pane index 
          set -g status-left "#[bg=${c.base04},fg=${c.base00},bold]  #S #[bg=${c.base02},fg=${c.base04}]#[bg=${c.base02},fg=${c.base05}] #I:#P #[bg=${c.base01},fg=${c.base02}]"

          # Right: current path basename + time
          set -g status-right "#[bg=${c.base01},fg=${c.base02}]#[bg=${c.base02},fg=${c.base05}] #{b:pane_current_path} #[bg=${c.base02},fg=${c.base04}]#[bg=${c.base04},fg=${c.base00},bold] %H:%M #[bg=${c.base04},fg=${c.base00}] "

          # Behavior options
          set -g renumber-windows on
          set -g set-clipboard on
          set -g base-index 1
          set -g extended-keys on
          set -g extended-keys-format csi-u
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
        '';
        plugins = with pkgs.tmuxPlugins; [
          prefix-highlight
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim 'session'
            '';
          }
          {
            plugin = yank;
            extraConfig = ''
              set -g @plugin 'tmux-plugins/tmux-yank'
            '';
          }
        ];
      };
    };
}
