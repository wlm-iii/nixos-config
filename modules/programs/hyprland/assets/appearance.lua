local colors = {
    bg0_hard = "rgba(1d2021ff)",
    bg0      = "rgba(282828ff)",
    bg0_soft = "rgba(32302fff)",
    bg1      = "rgba(3c3836ff)",
    bg2      = "rgba(504945ff)",
    bg3      = "rgba(665c54ff)",
    bg4      = "rgba(7c6f64ff)",

    fg0      = "rgba(fbf1c7ff)",
    fg       = "rgba(ebdbb2ff)",
    fg2      = "rgba(d5c4a1ff)",
    fg3      = "rgba(bdae93ff)",
    fg4      = "rgba(a89984ff)",
    gray     = "rgba(928374ff)",

    red      = "rgba(cc241dff)",
    redBr    = "rgba(fb4934ff)",
    green    = "rgba(98971aff)",
    greenBr  = "rgba(b8bb26ff)",
    yellow   = "rgba(d79921ff)",
    yellowBr = "rgba(fabd2fff)",
    blue     = "rgba(458588ff)",
    blueBr   = "rgba(83a598ff)",
    purple   = "rgba(b16286ff)",
    purpleBr = "rgba(d3869bff)",
    aqua     = "rgba(689d6aff)",
    aquaBr   = "rgba(8ec07cff)",
    orange   = "rgba(d65d0eff)",
    orangeBr = "rgba(fe8019ff)",
}

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 4,
        border_size = 0,
        col = {
            active_border = { colors = { colors.orange, colors.orangeBr }, angle = 45 },
            inactive_border = "rgba(282828aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 5,
            passes = 3,
            noise = 0.03,
            vibrancy = 0.1696,
            ignore_opacity = true,
        },
    },
    animations = { enabled = false },
    group = {
        col = {
            border_active = { colors = { colors.orange, colors.orangeBr }, angle = 45 },
            border_inactive = colors.bg0,
            border_locked_active = { colors = { colors.red, colors.redBr }, angle = 45 },
            border_locked_inactive = colors.bg0,
        },
        groupbar = {
            enabled = true,
            font_family = "JetBrains Mono Nerd Font",
            font_size = 14,
            -- height = 16,
            height = 4,
            gradients = true,
            stacked = false,
            render_titles = false,
            text_color = colors.fg0,
            text_color_inactive = colors.fg3,
            text_color_locked_active = colors.red,
            text_color_locked_inactive = colors.redBr,
            col = {
                active = colors.bg1,
                inactive = colors.bg0_hard,
                locked_active = colors.bg1,
                locked_inactive = colors.bg0_hard,
            },
        },
    },
})

-- Curves and animations.
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "quick", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "quick", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "quick", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.config({ dwindle = { preserve_split = true } })
hl.config({ master = { new_status = "master" } })
hl.config({ scrolling = { fullscreen_on_one_column = true } })
hl.config({
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo = true,
    },
})
