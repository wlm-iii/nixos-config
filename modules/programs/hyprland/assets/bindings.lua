local programs = require("programs")
local input = require("input")
local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd(programs.terminal2))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("ghostty -e sh -c 'fastfetch; exec \"$SHELL\"'"))
-- hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("kitty --hold fastfetch"))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
closeWindowBind:set_enabled(true)
hl.bind(mainMod .. " + SHIFT + Q",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(programs.browser .. " -P \"School\""))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(programs.browser .. " -P \"Personal\""))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu .. " -show drun"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("networkmanager_dmenu"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("rofi-bluetooth"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(programs.menu .. " -show window"))
hl.bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd(programs.menu .. " -modi emoji -show emoji"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + EQUAL", hl.dsp.exec_cmd(programs.menu .. " -show calc -modi calc -no-show-match -no-sort"))
hl.bind(mainMod .. " + Z", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client --toggle-panel --skip-wait"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("pkill waybar || waybar"))

hl.bind(mainMod .. " + SHIFT + M", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, { timeout = 500, type = "oneshot" })
end)

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down", group_aware = true }))

local resizeStep = 36
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -resizeStep, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = resizeStep, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -resizeStep, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = resizeStep, relative = true }), { repeating = true })

hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock())
hl.bind(mainMod .. " + right", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.group.move_window({ forward = true }))
hl.bind(mainMod .. " + left", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.group.move_window({ forward = false }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.group.active({ index = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + X", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("pwman"))
    hl.exec_cmd(
        'pgrep -u "$(id -u)" -x keepassxc >/dev/null || keepassxc'
    )
end)
hl.bind(mainMod .. " + CTRL + X", hl.dsp.window.move({ workspace = "special:pwman" }))

hl.bind(mainMod .. " + T", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("email"))
    hl.exec_cmd(
        'pgrep -u "$(id -u)" -x thunderbird >/dev/null || thunderbird'
    )
end)
hl.bind(mainMod .. " + CTRL + T", hl.dsp.window.move({ workspace = "special:email" }))

hl.bind(mainMod .. " + D", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("discord"))
    hl.exec_cmd(
        'pgrep -u "$(id -u)" -x vesktop >/dev/null || vesktop'
    )
end)
hl.bind(mainMod .. " + CTRL + D", hl.dsp.window.move({ workspace = "special:discord" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | swappy -f -"))
hl.bind(mainMod .. "+ I", input.toggle_while_typing)
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("$HOME/.config/hypr/hypr_switch_workspace.sh"))
hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.exec_cmd("$HOME/.config/hypr/hypr_move_to_workspace.sh"))
