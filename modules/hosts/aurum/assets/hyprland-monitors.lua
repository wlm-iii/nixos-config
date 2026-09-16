-- Monitors for Aurum

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@164.84Hz",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "auto-left",
    scale    = "auto",
})
