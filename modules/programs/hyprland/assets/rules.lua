-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

local suppressMaximizeRule = hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name = "blur waybar",
    match = { namespace = "waybar" },
    blur = true,
})

hl.layer_rule({
    name = "blur rofi",
    match = { namespace = "rofi" },
    blur = true,
})

hl.window_rule({
    name = "audio panel",
    match = {
        class = "^$",
        title = "^Volume Control$",
    },
    float = true,
    size = { 640, 480 },
    move = { "monitor_w-window_w-8", 42 },
})

hl.window_rule({
    name = "network panel",
    match = { class = "^nm-connection-editor$" },
    float = true,
    size = { 560, 420 },
    move = { "monitor_w-window_w-8", 42 },
})

hl.window_rule({ name = "disable animations in fullscreen", match = { fullscreen = true }, no_anim = true })
hl.window_rule({ name = "make kitty translucent", match = { class = "kitty" }, opacity = .9 })
-- hl.window_rule({ name = "make ghostty translucent", match = { class = "com.mitchellh.ghostty" }, opacity = .9 })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
