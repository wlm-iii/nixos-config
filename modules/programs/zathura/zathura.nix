{
  flake.modules.homeManager.zathura = {
    programs.zathura = {
      enable = true;
      extraConfig = ''
        # For some reason, default-bg must be specified using HTML notation
        set default-bg "0000000ff"
        set default-fg "#ff0000"

        #set scroll-page-aware true
        set adjust-open width

        # Keep original image colors
        set recolor-reverse-video true

        set database "sqlite"

        # Show a vertical scrollbar
        # set guioptions 'v'

        set selection-clipboard clipboard

        set notification-error-bg       "rgba(40,40,40,1)"     # bg
        set notification-error-fg       "rgba(251,73,52,1)"    # bright:red
        set notification-warning-bg     "rgba(40,40,40,1)"     # bg
        set notification-warning-fg     "rgba(250,189,47,1)"   # bright:yellow
        set notification-bg             "rgba(40,40,40,1)"     # bg
        set notification-fg             "rgba(184,187,38,1)"   # bright:green

        set completion-bg               "rgba(80,73,69,1)"     # bg2
        set completion-fg               "rgba(235,219,178,1)"  # fg
        set completion-group-bg         "rgba(60,56,54,1)"     # bg1
        set completion-group-fg         "rgba(146,131,116,1)"  # gray
        set completion-highlight-bg     "rgba(131,165,152,1)"  # bright:blue
        set completion-highlight-fg     "rgba(80,73,69,1)"     # bg2

        set index-bg                    "rgba(80,73,69,1)"     # bg2
        set index-fg                    "rgba(235,219,178,1)"  # fg
        set index-active-bg             "rgba(131,165,152,1)"  # bright:blue
        set index-active-fg             "rgba(80,73,69,1)"     # bg2

        set inputbar-bg                 "rgba(40,40,40,1)"     # bg
        set inputbar-fg                 "rgba(235,219,178,1)"  # fg

        set statusbar-bg                "rgba(80,73,69,1)"     # bg2
        set statusbar-fg                "rgba(235,219,178,1)"  # fg

        set highlight-color             "rgba(250,189,47,0.5)" # bright:yellow
        set highlight-active-color      "rgba(254,128,25,0.5)" # bright:orange

        set default-bg                  "rgba(40,40,40,.9)"    # bg
        set default-fg                  "rgba(235,219,178,.9)" # fg
        set render-loading              true
        set render-loading-bg           "rgba(40,40,40,1)"     # bg
        set render-loading-fg           "rgba(235,219,178,1)"  # fg

        set recolor-lightcolor          rgba(40,40,40,1)       # bg
        set recolor-darkcolor           rgba(235,219,178,1)    # fg
        set recolor                     false
        set recolor-keephue             true
      '';
    };
  };
}
